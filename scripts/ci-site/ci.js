fetch("data.json")
  .then(response => {
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  })
  .then(records => {
    if (!Array.isArray(records)) throw new Error("データの形式が不正です");
    window.renderLeanMetrics(records, document.querySelector("#results"));
    document.querySelector("#status").textContent =
      records.length ? `${records.length}件の結果` : "計測結果はまだありません。";
  })
  .catch(error => { document.querySelector("#status").textContent = `読み込み失敗: ${error.message}`; });
