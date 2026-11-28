module

public import MahjongDomain.Hand
public import MahjongDomain.Parts
public import MahjongDomain.Tile37

@[expose] public section

namespace MahjongDomain

inductive RelativeCaller
  | shimocha
  | toimen
  | kamicha
  deriving DecidableEq, Repr, BEq

/-- The shape and call details of one fixed meld, independent of red-five identity. -/
inductive FixedMeldShape
  | chi (sequence : Shuntsu) (calledOffset : Fin 3)
  | pon (tile : Tile) (caller : RelativeCaller)
  | daiminkan (tile : Tile) (caller : RelativeCaller)
  | kakan (tile : Tile) (caller : RelativeCaller)
  | ankan (tile : Tile)
  deriving DecidableEq

/-- A fixed meld shape together with the exact 37-kind tiles it occupies. -/
structure FixedMeld where
  shape : FixedMeldShape
  tiles : Multiset Tile37
  deriving DecidableEq

namespace FixedMeldShape

def occupiedTiles : FixedMeldShape → Multiset Tile
  | .chi sequence _ => sequence.tiles
  | .pon tile _ => (MentsuCandidate.koutsu tile).tiles
  | .daiminkan tile _ => Kan.occupiedTiles tile
  | .kakan tile _ => Kan.occupiedTiles tile
  | .ankan tile => Kan.occupiedTiles tile

end FixedMeldShape

namespace FixedMeld

/-- Construct the ordinary-tile composition for a fixed meld shape. -/
def ofShape (shape : FixedMeldShape) : FixedMeld :=
  { shape := shape
    tiles := (shape.occupiedTiles.map Tile37.normal) }

/-- Construct a fixed meld with an explicitly supplied physical composition. -/
def withTiles (shape : FixedMeldShape) (tiles : Multiset Tile37) : FixedMeld :=
  { shape, tiles }

def chi (sequence : Shuntsu) (calledOffset : Fin 3) : FixedMeld :=
  ofShape (.chi sequence calledOffset)

def chiWithTiles (sequence : Shuntsu) (calledOffset : Fin 3)
    (tiles : Multiset Tile37) : FixedMeld :=
  withTiles (.chi sequence calledOffset) tiles

def pon (tile : Tile) (caller : RelativeCaller) : FixedMeld :=
  ofShape (.pon tile caller)

def ponWithTiles (tile : Tile) (caller : RelativeCaller)
    (tiles : Multiset Tile37) : FixedMeld :=
  withTiles (.pon tile caller) tiles

def daiminkan (tile : Tile) (caller : RelativeCaller) : FixedMeld :=
  ofShape (.daiminkan tile caller)

def daiminkanWithTiles (tile : Tile) (caller : RelativeCaller)
    (tiles : Multiset Tile37) : FixedMeld :=
  withTiles (.daiminkan tile caller) tiles

def kakan (tile : Tile) (caller : RelativeCaller) : FixedMeld :=
  ofShape (.kakan tile caller)

def kakanWithTiles (tile : Tile) (caller : RelativeCaller)
    (tiles : Multiset Tile37) : FixedMeld :=
  withTiles (.kakan tile caller) tiles

def ankan (tile : Tile) : FixedMeld :=
  ofShape (.ankan tile)

def ankanWithTiles (tile : Tile) (tiles : Multiset Tile37) : FixedMeld :=
  withTiles (.ankan tile) tiles

/-- The exact 37-kind tiles occupied by this meld. -/
def occupiedTiles (meld : FixedMeld) : Multiset Tile37 :=
  meld.tiles

def occupiedCounts (meld : FixedMeld) : Tile37Counts :=
  Tile37Counts.ofMultiset meld.occupiedTiles

/-- Whether the supplied tile identities have the declared meld shape. -/
def hasValidComposition (meld : FixedMeld) : Bool :=
  decide (meld.tiles.map Tile37.normalized = meld.shape.occupiedTiles)

end FixedMeld

/-- A standing hand and fixed melds, preserving red-five identity. -/
structure HandSnapshot where
  standing : Tile37Counts
  fixedMelds : List FixedMeld

def HandSnapshot.normalizedStanding (input : HandSnapshot) : TileCounts :=
  input.standing.normalized

def HandSnapshot.occupiedCounts (input : HandSnapshot) : Tile37Counts :=
  fun tile => input.standing tile +
    input.fixedMelds.foldl (fun count meld => count + meld.occupiedCounts tile) 0

/-- Project all occupied tiles to the normalized 34-kind representation. -/
def HandSnapshot.normalizedOccupiedCounts (input : HandSnapshot) : TileCounts :=
  input.occupiedCounts.normalized

def HandSnapshot.hasValidMeldCompositions (input : HandSnapshot) : Bool :=
  input.fixedMelds.all FixedMeld.hasValidComposition

def HandSnapshot.hasValidPhysicalCopies (input : HandSnapshot) : Prop :=
  input.occupiedCounts.Valid

/-- Identity ignores fixed-meld order but retains red-five identity and multiplicity. -/
def HandSnapshot.Equivalent (left right : HandSnapshot) : Prop :=
  left.standing = right.standing ∧ left.fixedMelds.Perm right.fixedMelds

def HandSnapshot.same (left right : HandSnapshot) : Bool :=
  Tile37.all.all (fun tile => left.standing tile == right.standing tile) &&
    decide (left.fixedMelds.Perm right.fixedMelds)

end MahjongDomain
