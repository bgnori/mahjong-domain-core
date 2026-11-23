(() => {
  const svgNS = "http://www.w3.org/2000/svg";
  function element(tag, text) {
    const result = document.createElement(tag);
    if (text !== undefined) result.textContent = text;
    return result;
  }
  function chart(title, records, value) {
    const section = element("section");
    section.append(element("h3", title));
    const points = records.map((record, index) => ({ index, record, value: value(record) }))
      .filter(point => typeof point.value === "number");
    if (!points.length) {
      section.append(element("p", "計測値がありません。"));
      return section;
    }
    const svg = document.createElementNS(svgNS, "svg");
    svg.setAttribute("viewBox", "0 0 800 220");
    svg.setAttribute("role", "img");
    svg.setAttribute("aria-label", title + "、詳細は下の表を参照");
    const maximum = Math.max(...points.map(point => point.value), 1);
    const x = point => 50 + (records.length > 1 ? point.index * 720 / (records.length - 1) : 360);
    const y = point => 190 - point.value * 170 / maximum;
    const segments = [];
    for (const point of points) {
      const previous = segments.at(-1);
      if (!previous || previous.at(-1).index + 1 !== point.index) segments.push([point]);
      else previous.push(point);
    }
    for (const segment of segments) {
      const line = document.createElementNS(svgNS, "polyline");
      line.setAttribute("class", "line");
      line.setAttribute("points", segment.map(point => `${x(point)},${y(point)}`).join(" "));
      svg.append(line);
    }
    for (const point of points) {
      const circle = document.createElementNS(svgNS, "circle");
      circle.setAttribute("class", "point");
      circle.setAttribute("cx", x(point));
      circle.setAttribute("cy", y(point));
      circle.setAttribute("r", "4");
      const tooltip = document.createElementNS(svgNS, "title");
      tooltip.textContent = `${point.record.startedAt}: ${point.value}`;
      circle.append(tooltip);
      svg.append(circle);
    }
    for (const [label, position] of [[maximum.toFixed(1), 25], ["0", 195]]) {
      const text = document.createElementNS(svgNS, "text");
      text.setAttribute("x", "0"); text.setAttribute("y", position);
      text.setAttribute("fill", "currentColor"); text.setAttribute("font-size", "12");
      text.textContent = label;
      svg.append(text);
    }
    for (const [label, position, anchor] of [
      [records[0].startedAt.slice(0, 10), 50, "start"],
      [records[records.length - 1].startedAt.slice(0, 10), 770, "end"]
    ]) {
      const text = document.createElementNS(svgNS, "text");
      text.setAttribute("x", position); text.setAttribute("y", "215");
      text.setAttribute("text-anchor", anchor); text.setAttribute("fill", "currentColor");
      text.setAttribute("font-size", "12"); text.textContent = label;
      svg.append(text);
    }
    section.append(svg);
    return section;
  }
  window.renderLeanMetrics = (records, results, { showRepository = true } = {}) => {
    for (const repository of [...new Set(records.map(record => record.repository))].sort()) {
      const items = records.filter(record => record.repository === repository);
      const section = element("section");
      if (showRepository) section.append(element("h2", repository));
      section.append(chart("ビルド全体のピークPSS (MiB)", items, record => record.peakTreePssMiB));
      const modules = [...new Set(items.flatMap(record => Object.keys(record.modulePeakPssMiB)))].sort();
      for (const module of modules) {
        section.append(chart(`代表モジュール ${module} のピークPSS (MiB)`, items,
          record => record.modulePeakPssMiB[module]));
      }
      section.append(chart("経過時間 (秒)", items, record => record.elapsedSeconds));
      const scroll = element("div"); scroll.className = "scroll";
      const table = element("table");
      const header = element("tr");
      for (const name of ["日時", "commit", "全体 MiB", "モジュール MiB", "秒", "Lean", "threads", "runner", "runner image", "Core commit"]) {
        header.append(element("th", name));
      }
      table.append(header);
      for (const record of [...items].reverse()) {
        const row = element("tr");
        const values = [record.startedAt, record.commit.slice(0, 7), record.peakTreePssMiB ?? "未採取",
          Object.entries(record.modulePeakPssMiB)
            .map(([module, value]) => `${module}: ${value ?? "未採取"}`).join(", ") || "未採取",
          record.elapsedSeconds,
          record.leanToolchain, record.leanThreads ?? "不明",
          `${record.runnerOs ?? "不明"} / ${record.runnerArch ?? "不明"}`,
          record.runnerImage ?? "不明", record.coreCommit.slice(0, 7)];
        for (const value of values) row.append(element("td", String(value)));
        table.append(row);
      }
      scroll.append(table); section.append(scroll); results.append(section);
    }
  };
})();
