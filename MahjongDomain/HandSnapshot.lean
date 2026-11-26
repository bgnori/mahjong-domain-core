module

public import MahjongDomain.Hand
public import MahjongDomain.Parts

@[expose] public section

namespace MahjongDomain

inductive RelativeCaller
  | shimocha
  | toimen
  | kamicha
  deriving DecidableEq, Repr, BEq

/-- A fixed meld, including the information needed to distinguish calls. -/
inductive FixedMeld
  | chi (sequence : Shuntsu) (calledOffset : Fin 3)
  | pon (tile : Tile) (caller : RelativeCaller)
  | daiminkan (tile : Tile) (caller : RelativeCaller)
  | kakan (tile : Tile) (caller : RelativeCaller)
  | ankan (tile : Tile)
  deriving DecidableEq

instance : BEq FixedMeld where
  beq a b := decide (a = b)

/-- A normalized hand and its fixed melds; list order is not part of its identity. -/
structure HandSnapshot where
  standing : TileCounts
  fixedMelds : List FixedMeld

def FixedMeld.occupiedTiles : FixedMeld → Multiset Tile
  | .chi sequence _ => sequence.tiles
  | .pon tile _ => (MentsuCandidate.koutsu tile).tiles
  | .daiminkan tile _ => Kan.occupiedTiles tile
  | .kakan tile _ => Kan.occupiedTiles tile
  | .ankan tile => Kan.occupiedTiles tile

def FixedMeld.occupiedCounts (meld : FixedMeld) : TileCounts :=
  TileCounts.ofMultiset meld.occupiedTiles

def HandSnapshot.occupiedCounts (input : HandSnapshot) : TileCounts :=
  fun tile => input.standing tile +
    input.fixedMelds.foldl (fun count meld => count + meld.occupiedCounts tile) 0

/-- Identity ignores fixed-meld order but retains multiplicity. -/
def HandSnapshot.Equivalent (left right : HandSnapshot) : Prop :=
  left.standing = right.standing ∧ left.fixedMelds.Perm right.fixedMelds

def HandSnapshot.same (left right : HandSnapshot) : Bool :=
  Tile.all.all (fun tile => left.standing tile == right.standing tile) &&
    decide (left.fixedMelds.Perm right.fixedMelds)

end MahjongDomain
