module

public import MahjongDomain.Tile
public import Mathlib.Data.Multiset.Basic

@[expose] public section

namespace MahjongDomain

/-- A pair of identical tile kinds, used as the head of a standard hand. -/
structure Pair where
  tile : Tile
  deriving DecidableEq

/-- The tile-kind multiset occupied by a pair. -/
def Pair.tiles (pair : Pair) : Multiset Tile :=
  Multiset.replicate 2 pair.tile

/-- A concealed standard meld: a triplet or a suited sequence. -/
inductive Meld
  | triplet (tile : Tile)
  | sequence (suit : Suit) (start : Fin 7)
  deriving DecidableEq

/-- The tile-kind multiset occupied by a standard meld. -/
def Meld.tiles : Meld → Multiset Tile
  | .triplet tile => Multiset.replicate 3 tile
  | .sequence suit start =>
      Multiset.ofList
        [ Tile.suited suit ⟨start.val, by omega⟩
        , Tile.suited suit ⟨start.val + 1, by omega⟩
        , Tile.suited suit ⟨start.val + 2, by omega⟩
        ]

/-- The tile-kind multiset occupied by a fixed kan; it is not a standard meld. -/
def Kan.occupiedTiles (tile : Tile) : Multiset Tile :=
  Multiset.replicate 4 tile

/-- Expand an ordered meld list without forgetting repeated equal melds. -/
def MeldList.tiles : List Meld → Multiset Tile
  | [] => 0
  | meld :: rest => meld.tiles + MeldList.tiles rest

/-- Tile-kind multiplicities of a tile multiset. -/
def TileCounts.ofMultiset (tiles : Multiset Tile) : TileCounts :=
  fun tile => tiles.count tile

/-- Tile-kind multiplicities contributed by an ordered meld list. -/
def MeldList.counts (melds : List Meld) : TileCounts :=
  fun tile => (MeldList.tiles melds).count tile

/-- One standard decomposition, retaining the chosen pair and ordered meld list. -/
structure StandardDecomposition where
  pair : Pair
  melds : List Meld
  deriving DecidableEq

/-- The tile-kind multiset represented by one standard decomposition. -/
def StandardDecomposition.tiles (decomposition : StandardDecomposition) :
    Multiset Tile :=
  decomposition.pair.tiles + MeldList.tiles decomposition.melds

/-- The tile-kind multiplicities represented by one standard decomposition. -/
def StandardDecomposition.counts (decomposition : StandardDecomposition) :
    TileCounts :=
  TileCounts.ofMultiset decomposition.tiles

/-- A count vector has a witness consisting of one pair and exactly `meldCount` melds. -/
def StandardCompletion (meldCount : Nat) (counts : TileCounts) : Prop :=
  ∃ decomposition : StandardDecomposition,
    decomposition.melds.length = meldCount ∧ decomposition.counts = counts

theorem Pair.tiles_card (pair : Pair) : pair.tiles.card = 2 := by
  simp [Pair.tiles]

theorem Meld.tiles_card (meld : Meld) : meld.tiles.card = 3 := by
  cases meld with
  | triplet tile => simp [Meld.tiles]
  | sequence suit start => simp [Meld.tiles]

theorem Kan.occupiedTiles_card (tile : Tile) :
    (Kan.occupiedTiles tile).card = 4 := by
  simp [Kan.occupiedTiles]

theorem MeldList.counts_cons (meld : Meld) (melds : List Meld) :
    MeldList.counts (meld :: melds) =
      fun tile => meld.tiles.count tile + MeldList.counts melds tile := by
  funext tile
  simp [MeldList.counts, MeldList.tiles, Multiset.count_add]

theorem StandardDecomposition.counts_eq_parts
    (decomposition : StandardDecomposition) :
    decomposition.counts =
      fun tile => decomposition.pair.tiles.count tile +
        MeldList.counts decomposition.melds tile := by
  funext tile
  simp [StandardDecomposition.counts, StandardDecomposition.tiles,
    TileCounts.ofMultiset, Multiset.count_add, MeldList.counts]

theorem standardCompletion_iff_parts (meldCount : Nat) (counts : TileCounts) :
    StandardCompletion meldCount counts ↔
      ∃ pair : Pair, ∃ melds : List Meld,
        melds.length = meldCount ∧
        (fun tile => pair.tiles.count tile + MeldList.counts melds tile) = counts := by
  constructor
  · rintro ⟨decomposition, hlength, hcounts⟩
    exact ⟨decomposition.pair, decomposition.melds, hlength, by
      rw [← decomposition.counts_eq_parts, hcounts]⟩
  · rintro ⟨pair, melds, hlength, hcounts⟩
    refine ⟨⟨pair, melds⟩, hlength, ?_⟩
    rw [StandardDecomposition.counts_eq_parts]
    exact hcounts

end MahjongDomain
