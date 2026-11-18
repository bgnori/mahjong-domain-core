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

```sh
lake build
```

The initial repository scaffold does not yet contain extracted domain
definitions. Shared code will be added in small, verified steps.

## License

MIT. See [`LICENSE`](LICENSE).
