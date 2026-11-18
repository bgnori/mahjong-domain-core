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

The initial shared type is `MahjongDomain.Tile`, with a stable 34-kind index.
Further shared definitions and adapters will be added in small, verified steps.

## License

MIT. See [`LICENSE`](LICENSE).
