#!/usr/bin/env python3
"""Sample the existing Lake build and write CI metrics without rebuilding."""

import argparse
import datetime
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path


def processes(root: int) -> dict[int, Path]:
    parents = {}
    paths = {}
    for path in Path("/proc").iterdir():
        if not path.name.isdigit():
            continue
        try:
            stat = (path / "stat").read_text()
            parents[int(path.name)] = int(stat[stat.rfind(")") + 2 :].split()[1])
            paths[int(path.name)] = path
        except FileNotFoundError:
            continue
    tree = {root}
    while True:
        children = {pid for pid, parent in parents.items() if parent in tree}
        if children <= tree:
            return {pid: paths[pid] for pid in tree if pid in paths}
        tree.update(children)


def sample(root: int, modules: list[str]) -> tuple[int, dict[str, int]]:
    total = 0
    module_pss = {}
    for path in processes(root).values():
        try:
            pss = next(
                int(line.split()[1])
                for line in (path / "smaps_rollup").read_text().splitlines()
                if line.startswith("Pss:")
            )
            total += pss
            args = (path / "cmdline").read_bytes().split(b"\0")
            for module in modules:
                if any(arg.decode(errors="replace").endswith("/" + module) for arg in args):
                    module_pss[module] = max(module_pss.get(module, 0), pss)
        except (FileNotFoundError, ProcessLookupError):
            continue
    return total, module_pss


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--module", action="append", default=[])
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        parser.error("a build command is required after --")

    start = time.monotonic()
    started_at = datetime.datetime.now(datetime.timezone.utc).isoformat()
    process = subprocess.Popen(command, start_new_session=True)
    peak = 0
    peaks = {module: None for module in args.module}
    try:
        while process.poll() is None:
            total, modules = sample(process.pid, args.module)
            peak = max(peak, total)
            for module, pss in modules.items():
                peaks[module] = max(peaks[module] or 0, pss)
            time.sleep(0.25)
    except Exception:
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        process.wait()
        raise
    elapsed = time.monotonic() - start
    core = Path(".") if Path.cwd().name == "mahjong-domain-core" else Path("../mahjong-domain-core")
    core_commit = subprocess.run(
        ["git", "-C", str(core), "rev-parse", "HEAD"],
        check=True, capture_output=True, text=True,
    ).stdout.strip()
    result = {
        "schemaVersion": 1,
        "repository": os.environ.get("GITHUB_REPOSITORY"),
        "commit": os.environ.get("GITHUB_SHA"),
        "coreCommit": core_commit,
        "runId": os.environ.get("GITHUB_RUN_ID"),
        "runAttempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
        "startedAt": started_at,
        "runnerOs": os.environ.get("RUNNER_OS"),
        "runnerArch": os.environ.get("RUNNER_ARCH"),
        "runnerImage": os.environ.get("ImageVersion"),
        "leanToolchain": Path("lean-toolchain").read_text().strip(),
        "leanThreads": os.environ.get("LEAN_NUM_THREADS"),
        "command": command,
        "exitCode": process.returncode,
        "elapsedSeconds": round(elapsed, 2),
        "peakTreePssMiB": round(peak / 1024, 1) if peak else None,
        "modulePeakPssMiB": {
            module: round(pss / 1024, 1) if pss is not None else None
            for module, pss in peaks.items()
        },
        "sampleIntervalSeconds": 0.25,
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(
        f"Build: {result['elapsedSeconds']} s, peak tree PSS: "
        f"{result['peakTreePssMiB']} MiB; modules: {result['modulePeakPssMiB']}",
        flush=True,
    )
    if summary := os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(summary, "a", encoding="utf-8") as file:
            file.write(f"\nLean build metrics: `{json.dumps(result)}`\n")
    return process.returncode


if __name__ == "__main__":
    sys.exit(main())
