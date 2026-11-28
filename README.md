# Mahjong Domain Core

A small shared Lean 4 library for Mahjong tile representations, ready-to-use
notation, capacities, melds, and standard-hand specifications. The core is
intended to provide common definitions and verified properties to independent
Mahjong projects; it is not a shanten, wait-classification, or score-calculation
engine.

The public Lean namespace and root module are `MahjongDomain`. The package
uses Lean and mathlib `v4.35.0`.

The canonical shared glossary is [`docs/GLOSSARY.md`](docs/GLOSSARY.md).
It records shared terms together with their scope, assumptions, and Lean
declarations. Client-specific terminology and differences remain in each
client project's own documentation.

The rationale and workflow for sharing this domain across the sibling
`mahjong-wait-classification` and `mahjong-shanten-calculation` repositories are documented in
[`docs/SHARED_WORKSPACE.md`](docs/SHARED_WORKSPACE.md).

## Import policy

Do not use the umbrella `import Mathlib`. Each module should import only the
specific Mathlib modules it needs. If several core modules share the same
small set of imports, collect those imports in an internal curated
`MahjongDomain.Prelude`; keep the public `MahjongDomain` root focused on
re-exporting the core API, not on acting as a Mathlib umbrella.

Consumers should import `MahjongDomain` or a specific domain module to use
this library. They should import specific Mathlib modules directly only when
their own code uses Mathlib APIs beyond the core's public interface.

```sh
MATHLIB_NO_CACHE_ON_UPDATE=1 lake build
```

The core defines `MahjongDomain.Tile` as a normalized 34-kind tile shape and
`MahjongDomain.Tile37` as the red-aware 37-kind tile identity. `Tile37Counts`
preserves red-five counts, enforces the aka37 per-slot capacities, and projects
to normalized counts while preserving the four-copy limit. Signed Int37 and
Int34 counts remain available for input adapters.
`MahjongDomain.Hand` provides the shared count-based hand-held tile component.
`MahjongDomain.HandSnapshot` combines 37-kind standing counts with fixed meld
shapes, call details, and exact 37-kind tile composition. `FixedMeld.withTiles`
supports red fives in fixed melds; `FixedMeld.hasValidComposition` checks that
the identity counts match the declared meld shape. Fixed-meld list order is
ignored by `HandSnapshot.Equivalent` and `HandSnapshot.same`; repeated melds
are retained. Construction does not validate hand size, meld composition, or
combined physical capacity.
Tenhou's 136-code input format is isolated in the optional
`MahjongDomain.Tenhou` adapter module, which can decode codes into red-aware
`Tile37Counts` or normalized `TileCounts`.
The core also provides exact two-tile pairs, `Shuntsu` and
`MentsuCandidate` standard-form shapes, separate fixed-kan occupancy, and
standard-decomposition specifications that preserve component and tile-kind
multiplicities. `MahjongDomain.Tile.format` renders normalized tile kinds;
`Tile37.format` renders red fives as `0m`, `0p`, or `0s` in mpsz notation.
Tile terms can also be written directly in mpsz form:
`m1` through `m9` for manzu, `p1` through `p9` for pinzu, `s1` through `s9`
for souzu, and `z1` through `z7` for honors. For example, `[m1, m2, m3, z1]`
is a `List Tile`. The `m0`, `p0`, and `s0` aliases denote their respective
normalized fives and equal `m5`, `p5`, and `s5`. Use `Tile37.akaFive` or
`Tile37Counts` when the red-five distinction must be retained. See
[`docs/GLOSSARY.md`](docs/GLOSSARY.md) for the canonical terms and the scope
of each representation.

## Development container

Open the repository in a VS Code Dev Container, or build the image from the
repository root with `docker build -f .devcontainer/Dockerfile -t mahjong-domain-core-dev .`.
The image installs the version from [`lean-toolchain`](lean-toolchain) at build
time. Rebuild the image when the pin changes; new containers from the same
image do not download Lean again. Lake dependencies are still resolved in
the workspace. The container shares the host's `~/.cache/mathlib` with the
other Mahjong Dev Containers, so downloaded mathlib artifacts are reused
across container recreations on the same host.

## License

MIT. See [`LICENSE`](LICENSE).
