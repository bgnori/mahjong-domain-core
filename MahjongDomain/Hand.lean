module

public import MahjongDomain.Tile

@[expose] public section

namespace MahjongDomain

/-- The hand-held tile counts, independent of fixed melds and hand-shape constraints. -/
structure Hand where
  counts : TileCounts

end MahjongDomain
