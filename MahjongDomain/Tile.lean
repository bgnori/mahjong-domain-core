module

public import MahjongDomain.Prelude

@[expose] public section

namespace MahjongDomain

/-- The three numbered suits, in stable man-pin-sou order. -/
inductive Suit
  | man
  | pin
  | sou
  deriving DecidableEq, Repr

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

namespace Honor

def east : Honor := 0
def south : Honor := 1
def west : Honor := 2
def north : Honor := 3
def white : Honor := 4
def green : Honor := 5
def red : Honor := 6

end Honor

/-- A normalized tile kind; red fives share their numbered tile kind. -/
inductive Tile
  | suited (suit : Suit) (rank : Rank)
  | honor (rank : Honor)
  deriving DecidableEq, Repr

/-- Counts of normalized tile kinds. -/
abbrev TileCounts := Tile → Nat

/-- Each normalized tile kind has four physical copies. -/
abbrev copiesPerTile : Nat := 4

/-- Every tile-kind count is within the physical copy limit. -/
abbrev TileCounts.Valid (counts : TileCounts) : Prop :=
  ∀ tile, counts tile ≤ copiesPerTile

/-- One more tile of this kind fits within the physical copy limit. -/
abbrev TileCounts.CanAdd (counts : TileCounts) (tile : Tile) : Prop :=
  counts tile < copiesPerTile

theorem TileCounts.valid_add_one_iff (counts : TileCounts) (added : Tile) :
    TileCounts.Valid (fun tile => counts tile + if tile = added then 1 else 0) ↔
      counts.Valid ∧ counts.CanAdd added := by
  constructor
  · intro valid
    constructor
    · intro tile
      have h := valid tile
      dsimp only at h
      split at h <;> omega
    · have h := valid added
      simp only [ite_true] at h
      exact h
  · rintro ⟨valid, canAdd⟩ tile
    by_cases h : tile = added
    · subst tile
      simp only [ite_true]
      exact canAdd
    · simp only [h, ite_false, Nat.add_zero]
      exact valid tile

namespace Tile

/-- Construct suited tile kinds from an ordered list of ranks. -/
def suitedTiles (suit : Suit) (ranks : List Rank) : List Tile :=
  ranks.map (.suited suit)

/-- All 34 tile kinds in stable suit-major order followed by honors. -/
def all : List Tile :=
  (Suit.all.flatMap fun suit =>
    List.ofFn fun rank : Rank => Tile.suited suit rank) ++
  List.ofFn fun rank : Honor => Tile.honor rank

theorem mem_all (tile : Tile) : tile ∈ all := by
  cases tile with
  | suited suit rank =>
      simp only [all, List.mem_append, List.mem_flatMap]
      left
      exact ⟨suit, by cases suit <;> simp [Suit.all],
        List.mem_ofFn.mpr ⟨rank, rfl⟩⟩
  | honor rank =>
      simp only [all, List.mem_append]
      right
      exact List.mem_ofFn.mpr ⟨rank, rfl⟩

instance : Fintype Tile :=
  Fintype.ofList all mem_all

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

/-- A ready-to-use display format for a normalized tile kind. -/
inductive TileFormat
  | unicode
  | mpsz
  deriving BEq, DecidableEq, Repr

namespace Tile

/-- Render a normalized tile kind as a Mahjong glyph or as mpsz notation. -/
def format (output : TileFormat) : Tile → String
  | .suited suit rank =>
      match output with
      | .unicode =>
          let offset :=
            match suit with
            | .man => 0x1F007
            | .pin => 0x1F019
            | .sou => 0x1F010
          String.singleton (Char.ofNat (offset + rank.val))
      | .mpsz =>
          let suffix :=
            match suit with
            | .man => "m"
            | .pin => "p"
            | .sou => "s"
          s!"{rank.val + 1}{suffix}"
  | .honor rank =>
      match output with
      | .unicode =>
          let codepoint :=
            match rank.val with
            | 0 => 0x1F000
            | 1 => 0x1F001
            | 2 => 0x1F002
            | 3 => 0x1F003
            | 4 => 0x1F006
            | 5 => 0x1F005
            | _ => 0x1F004
          String.singleton (Char.ofNat codepoint)
      | .mpsz => s!"{rank.val + 1}z"

example :
    (Suit.all.map fun suit =>
      format .unicode (.suited suit ⟨0, by decide⟩)) = ["🀇", "🀙", "🀐"] := by
  native_decide

example :
    (List.ofFn fun rank : Honor => format .unicode (.honor rank)) =
      ["🀀", "🀁", "🀂", "🀃", "🀆", "🀅", "🀄"] := by
  native_decide

example :
    (Suit.all.map fun suit =>
      format .mpsz (.suited suit ⟨8, by decide⟩)) = ["9m", "9p", "9s"] := by
  native_decide

example :
    (List.ofFn fun rank : Honor => format .mpsz (.honor rank)) =
      ["1z", "2z", "3z", "4z", "5z", "6z", "7z"] := by
  native_decide

end Tile

end MahjongDomain
