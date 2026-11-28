module

public import MahjongDomain.Representation
public import Mathlib.Data.Multiset.Basic
public import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.FinCases

@[expose] public section

namespace MahjongDomain

/-- A tile identity that distinguishes each red five from its ordinary five. -/
inductive Tile37
  | normal (tile : Tile)
  | akaFive (suit : Suit)
  deriving DecidableEq, Repr

namespace Tile37

/-- Normalize a red five to the ordinary tile kind used by shape calculations. -/
def normalized : Tile37 → Tile
  | .normal tile => tile
  | .akaFive suit => .suited suit ⟨4, by decide⟩

/-- The stable aka37 index for this tile identity. -/
def index : Tile37 → Int37Index
  | .normal tile => tile.int37Index
  | .akaFive .man => 0
  | .akaFive .pin => 10
  | .akaFive .sou => 20

/-- The physical-copy capacity of a 37-kind tile identity. -/
def capacity : Tile37 → Nat
  | .normal (.suited _ rank) => if rank.val = 4 then 3 else copiesPerTile
  | .normal (.honor _) => copiesPerTile
  | .akaFive _ => 1

/-- Render tile identity, using `0m`, `0p`, and `0s` for red fives in mpsz. -/
def format (output : TileFormat) : Tile37 → String
  | .normal tile => tile.format output
  | .akaFive suit =>
      match output with
      | .unicode => (Tile.suited suit ⟨4, by decide⟩).format .unicode
      | .mpsz =>
          let suffix :=
            match suit with
            | .man => "m"
            | .pin => "p"
            | .sou => "s"
          s!"0{suffix}"

/-- Decode a stable aka37 index without losing red-five identity. -/
def ofIndex (index : Int37Index) : Tile37 :=
  if index.val = 0 then .akaFive .man
  else if index.val = 10 then .akaFive .pin
  else if index.val = 20 then .akaFive .sou
  else .normal index.tile

/-- All 37 tile identities in aka37 index order. -/
def all : List Tile37 :=
  List.ofFn fun index : Int37Index => ofIndex index

theorem index_ofIndex (index : Int37Index) : (ofIndex index).index = index := by
  fin_cases index <;> decide

theorem ofIndex_index (tile : Tile37) : ofIndex tile.index = tile := by
  cases tile with
  | normal tile =>
      cases tile with
      | suited suit rank => cases suit <;> fin_cases rank <;> decide
      | honor rank => fin_cases rank <;> decide
  | akaFive suit => cases suit <;> decide

theorem mem_all (tile : Tile37) : tile ∈ all := by
  rw [all]
  exact List.mem_ofFn.mpr ⟨tile.index, ofIndex_index tile⟩

theorem all_length : all.length = 37 := by
  simp [all]

end Tile37

instance : Fintype Tile37 :=
  Fintype.ofList Tile37.all Tile37.mem_all

/-- Counts over 37 tile identities, preserving red-five multiplicities. -/
abbrev Tile37Counts := Tile37 → Nat

namespace Tile37Counts

/-- Count each tile identity in a multiset. -/
def ofMultiset (tiles : Multiset Tile37) : Tile37Counts :=
  fun tile => tiles.count tile

/-- Count each tile identity in a list. -/
def ofList (tiles : List Tile37) : Tile37Counts :=
  ofMultiset (Multiset.ofList tiles)

/-- Count normalized tile kinds in the ordinary slots of the 37-kind vector. -/
def ofNormalizedList (tiles : List Tile) : Tile37Counts :=
  ofList (tiles.map Tile37.normal)

/-- Embed normalized counts into ordinary slots, leaving red-five slots empty. -/
def fromNormalized (counts : TileCounts) : Tile37Counts
  | .normal tile => counts tile
  | .akaFive _ => 0

/-- The total physical tiles represented by the counts. -/
def total (counts : Tile37Counts) : Nat :=
  ∑ tile : Tile37, counts tile

/-- The count vector respects the physical capacity of each aka37 slot. -/
def Valid (counts : Tile37Counts) : Prop :=
  ∀ tile, counts tile ≤ tile.capacity

instance (counts : Tile37Counts) : Decidable counts.Valid :=
  Fintype.decidableForallFintype

/-- Aggregate red and ordinary fives into normalized 34-kind counts. -/
def normalized (counts : Tile37Counts) : TileCounts :=
  fun tile =>
    counts (.normal tile) +
      match tile with
      | .suited suit rank =>
          if rank.val = 4 then counts (.akaFive suit) else 0
      | .honor _ => 0

theorem ofMultiset_sum_eq_card (tiles : Multiset Tile37) :
    (∑ tile : Tile37, ofMultiset tiles tile) = tiles.card := by
  induction tiles using Multiset.induction_on with
  | empty => simp [ofMultiset]
  | @cons tile tiles ih =>
      simp [ofMultiset]

theorem ofList_sum_eq_length (tiles : List Tile37) :
    (∑ tile : Tile37, ofList tiles tile) = tiles.length := by
  simpa [ofList] using ofMultiset_sum_eq_card (Multiset.ofList tiles)

theorem normalized_le_four (counts : Tile37Counts) (hvalid : counts.Valid)
    (tile : Tile) : counts.normalized tile ≤ copiesPerTile := by
  cases tile with
  | suited suit rank =>
      by_cases hrank : rank.val = 4
      · have hnormal := hvalid (.normal (.suited suit rank))
        have haka := hvalid (.akaFive suit)
        simp [Tile37.capacity, hrank] at hnormal haka
        simp [normalized, hrank]
        change counts (.normal (.suited suit rank)) + counts (.akaFive suit) ≤ 4
        omega
      · have hnormal := hvalid (.normal (.suited suit rank))
        simpa [normalized, Tile37.capacity, hrank] using hnormal
  | honor rank =>
      have hnormal := hvalid (.normal (.honor rank))
      simpa [normalized, Tile37.capacity] using hnormal

theorem normalized_valid (counts : Tile37Counts) (hvalid : counts.Valid) :
    counts.normalized.Valid :=
  normalized_le_four counts hvalid

end Tile37Counts

end MahjongDomain
