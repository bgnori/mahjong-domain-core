import MahjongDomain.Prelude

namespace MahjongDomain

/-- The three numbered suits, in stable man-pin-sou order. -/
inductive Suit
  | man
  | pin
  | sou
  deriving DecidableEq

namespace Suit

def all : List Suit := [.man, .pin, .sou]

end Suit

instance : Fintype Suit :=
  Fintype.ofList Suit.all (by
    intro suit
    cases suit <;> simp [Suit.all])

/-- Numbered ranks use zero-based values, where `0` represents rank one. -/
abbrev Rank := Fin 9

/-- Honor kinds use east, south, west, north, white, green, red order. -/
abbrev Honor := Fin 7

/-- A normalized tile kind; red fives share their numbered tile kind. -/
inductive Tile
  | suited (suit : Suit) (rank : Rank)
  | honor (rank : Honor)
  deriving DecidableEq

/-- Counts of normalized tile kinds. -/
abbrev TileCounts := Tile → Nat

namespace Tile

/-- All 34 tile kinds in stable suit-major order followed by honors. -/
def all : List Tile :=
  (Suit.all.flatMap fun suit =>
    List.ofFn fun rank : Rank => Tile.suited suit rank) ++
  List.ofFn fun rank : Honor => Tile.honor rank

instance : Fintype Tile :=
  Fintype.ofList all (by
    intro tile
    cases tile with
    | suited suit rank =>
        simp only [all, List.mem_append, List.mem_flatMap]
        left
        exact ⟨suit, by cases suit <;> simp [Suit.all],
          List.mem_ofFn.mpr ⟨rank, rfl⟩⟩
    | honor rank =>
        simp only [all, List.mem_append]
        right
        exact List.mem_ofFn.mpr ⟨rank, rfl⟩)

/-- Stable 0-based index: numbered tiles suit-major, then honors. -/
def index : Tile → Fin 34
  | .suited .man rank =>
      ⟨rank.val, Nat.lt_of_lt_of_le rank.isLt (by decide)⟩
  | .suited .pin rank =>
      ⟨9 + rank.val,
        Nat.lt_of_lt_of_le (Nat.add_lt_add_left rank.isLt 9) (by decide)⟩
  | .suited .sou rank =>
      ⟨18 + rank.val,
        Nat.lt_of_lt_of_le (Nat.add_lt_add_left rank.isLt 18) (by decide)⟩
  | .honor rank =>
      ⟨27 + rank.val,
        Nat.lt_of_lt_of_le (Nat.add_lt_add_left rank.isLt 27) (by decide)⟩

theorem all_length : all.length = 34 := by
  decide

theorem index_injective : Function.Injective index := by
  decide

end Tile

end MahjongDomain
