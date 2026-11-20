# Mahjong Domain Core

A small shared Lean 4 library for Mahjong tile representations, capacities,
melds, and standard-hand specifications. The core is intended to provide
common definitions and verified properties to independent Mahjong projects;
it is not a shanten, wait-classification, or score-calculation engine.

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

The core defines `MahjongDomain.Tile` with a stable 34-kind index, bridges
Tenhou's 136 physical IDs through the aka37 representation, and proves total,
addition, and four-copy capacity preservation when aka37 counts are aggregated
to normalized tile kinds. It also provides witness-bearing pair, meld, kan
occupancy, and standard-decomposition specifications that preserve component
and tile-kind multiplicities. See [`docs/GLOSSARY.md`](docs/GLOSSARY.md) for
the canonical terms and the scope of each representation.

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
