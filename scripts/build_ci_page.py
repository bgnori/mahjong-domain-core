#!/usr/bin/env python3
"""Add the reserved CI page to an already assembled Pages site."""

import argparse
import shutil
from pathlib import Path


ASSETS = Path(__file__).resolve().parent / "ci-site"
CI_FILES = ("index.html", "ci.js", "metrics.js", "metrics.css")


def build(site: Path) -> None:
    if not site.is_dir():
        raise ValueError(f"Pages site directory does not exist: {site}")
    ci = site / "ci"
    ci.mkdir()
    for name in CI_FILES:
        shutil.copy2(ASSETS / name, ci / name)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("site", type=Path)
    build(parser.parse_args().site)
