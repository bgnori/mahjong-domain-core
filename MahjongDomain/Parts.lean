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

/-- A suited sequence of three consecutive numbered tile kinds. -/
structure Shuntsu where
  suit : Suit
  start : Fin 7
  deriving DecidableEq

/-- The tile-kind multiset occupied by a suited sequence. -/
def Shuntsu.tiles (shuntsu : Shuntsu) : Multiset Tile :=
  Multiset.ofList
    [ Tile.suited shuntsu.suit ⟨shuntsu.start.val, by omega⟩
    , Tile.suited shuntsu.suit ⟨shuntsu.start.val + 1, by omega⟩
    , Tile.suited shuntsu.suit ⟨shuntsu.start.val + 2, by omega⟩
    ]

/-- A standard-form meld candidate: a suited sequence or a triplet. -/
inductive MentsuCandidate
  | shuntsu (shuntsu : Shuntsu)
  | koutsu (tile : Tile)
  deriving DecidableEq

/-- The tile-kind multiset occupied by a standard-form meld candidate. -/
def MentsuCandidate.tiles : MentsuCandidate → Multiset Tile
  | .shuntsu sequence => sequence.tiles
  | .koutsu tile => Multiset.replicate 3 tile

/-- The tile-kind multiset occupied by a fixed kan; it is not a standard meld. -/
def Kan.occupiedTiles (tile : Tile) : Multiset Tile :=
  Multiset.replicate 4 tile

/-- Expand an ordered candidate list without forgetting repeated equal candidates. -/
def MentsuCandidateList.tiles : List MentsuCandidate → Multiset Tile
  | [] => 0
  | candidate :: rest => candidate.tiles + MentsuCandidateList.tiles rest

/-- Tile-kind multiplicities of a tile multiset. -/
def TileCounts.ofMultiset (tiles : Multiset Tile) : TileCounts :=
  fun tile => tiles.count tile

/-- Tile-kind multiplicities contributed by an ordered candidate list. -/
def MentsuCandidateList.counts (candidates : List MentsuCandidate) : TileCounts :=
  fun tile => (MentsuCandidateList.tiles candidates).count tile

/-- The remaining tile-kind counts after selecting this pair from a count vector. -/
def Pair.remainingCounts (counts : TileCounts) (pair : Pair) : TileCounts :=
  fun tile => counts tile - pair.tiles.count tile

/-- One standard decomposition, retaining the chosen pair and ordered candidate list. -/
structure StandardDecomposition where
  pair : Pair
  mentsuCandidates : List MentsuCandidate
  deriving DecidableEq

/-- The tile-kind multiset represented by one standard decomposition. -/
def StandardDecomposition.tiles (decomposition : StandardDecomposition) :
    Multiset Tile :=
  decomposition.pair.tiles + MentsuCandidateList.tiles decomposition.mentsuCandidates

/-- The tile-kind multiplicities represented by one standard decomposition. -/
def StandardDecomposition.counts (decomposition : StandardDecomposition) :
    TileCounts :=
  TileCounts.ofMultiset decomposition.tiles

/-- A count vector has a witness consisting of one pair and exactly `candidateCount` candidates. -/
def StandardCompletion (candidateCount : Nat) (counts : TileCounts) : Prop :=
  ∃ decomposition : StandardDecomposition,
    decomposition.mentsuCandidates.length = candidateCount ∧ decomposition.counts = counts

theorem Pair.tiles_card (pair : Pair) : pair.tiles.card = 2 := by
  simp [Pair.tiles]

theorem MentsuCandidate.tiles_card (candidate : MentsuCandidate) :
    candidate.tiles.card = 3 := by
  cases candidate with
  | shuntsu shuntsu => simp [MentsuCandidate.tiles, Shuntsu.tiles]
  | koutsu tile => simp [MentsuCandidate.tiles]

theorem Kan.occupiedTiles_card (tile : Tile) :
    (Kan.occupiedTiles tile).card = 4 := by
  simp [Kan.occupiedTiles]

theorem Pair.counts_eq_pair_add_remaining (counts : TileCounts) (pair : Pair)
    (hcount : 2 ≤ counts pair.tile) :
    counts = fun tile => pair.tiles.count tile + Pair.remainingCounts counts pair tile := by
  funext tile
  by_cases htile : tile = pair.tile
  · subst tile
    simp [Pair.remainingCounts, Pair.tiles]
    omega
  · simp [Pair.remainingCounts, Pair.tiles, htile]

theorem MentsuCandidateList.counts_cons (candidate : MentsuCandidate)
    (candidates : List MentsuCandidate) :
    MentsuCandidateList.counts (candidate :: candidates) =
      fun tile => candidate.tiles.count tile + MentsuCandidateList.counts candidates tile := by
  funext tile
  simp [MentsuCandidateList.counts, MentsuCandidateList.tiles, Multiset.count_add]

theorem StandardDecomposition.counts_eq_parts
    (decomposition : StandardDecomposition) :
    decomposition.counts =
      fun tile => decomposition.pair.tiles.count tile +
        MentsuCandidateList.counts decomposition.mentsuCandidates tile := by
  funext tile
  simp [StandardDecomposition.counts, StandardDecomposition.tiles,
    TileCounts.ofMultiset, Multiset.count_add, MentsuCandidateList.counts]

theorem standardCompletion_iff_parts (candidateCount : Nat) (counts : TileCounts) :
    StandardCompletion candidateCount counts ↔
      ∃ pair : Pair, ∃ candidates : List MentsuCandidate,
        candidates.length = candidateCount ∧
        (fun tile => pair.tiles.count tile + MentsuCandidateList.counts candidates tile) = counts := by
  constructor
  · rintro ⟨decomposition, hlength, hcounts⟩
    exact ⟨decomposition.pair, decomposition.mentsuCandidates, hlength, by
      rw [← decomposition.counts_eq_parts, hcounts]⟩
  · rintro ⟨pair, candidates, hlength, hcounts⟩
    refine ⟨⟨pair, candidates⟩, hlength, ?_⟩
    rw [StandardDecomposition.counts_eq_parts]
    exact hcounts

end MahjongDomain
