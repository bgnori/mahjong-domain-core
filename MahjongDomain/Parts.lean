module

public import MahjongDomain.Tile
public import Mathlib.Data.Multiset.Basic
public import Mathlib.Data.Fintype.Sigma
public import Mathlib.Data.Fintype.Sum
public import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.DeriveFintype

@[expose] public section

namespace MahjongDomain

/-- A pair of identical tile kinds, used as the head of a mentsu hand. -/
structure Pair where
  tile : Tile
  deriving DecidableEq

/-- The two tile kinds of a pair. -/
def Pair.orderedTiles (pair : Pair) : List Tile :=
  [pair.tile, pair.tile]

/-- The tile-kind multiset occupied by a pair. -/
def Pair.tiles (pair : Pair) : Multiset Tile :=
  Multiset.ofList pair.orderedTiles

theorem Pair.tiles_eq_replicate (pair : Pair) :
    pair.tiles = Multiset.replicate 2 pair.tile := rfl

namespace ShuntsuStart

/-- The first rank in a sequence beginning at this zero-based position. -/
def firstRank (start : Fin 7) : Rank := ⟨start.val, by omega⟩

/-- The middle rank in a sequence beginning at this zero-based position. -/
def middleRank (start : Fin 7) : Rank := ⟨start.val + 1, by omega⟩

/-- The last rank in a sequence beginning at this zero-based position. -/
def lastRank (start : Fin 7) : Rank := ⟨start.val + 2, by omega⟩

end ShuntsuStart

/-- A suited sequence of three consecutive numbered tile kinds. -/
structure Shuntsu where
  suit : Suit
  start : Fin 7
  deriving DecidableEq, Fintype

/-- Sequence tile kinds in ascending rank order. -/
def Shuntsu.orderedTiles (shuntsu : Shuntsu) : List Tile :=
  [ Tile.suited shuntsu.suit (ShuntsuStart.firstRank shuntsu.start)
  , Tile.suited shuntsu.suit (ShuntsuStart.middleRank shuntsu.start)
  , Tile.suited shuntsu.suit (ShuntsuStart.lastRank shuntsu.start)
  ]

/-- The tile-kind multiset occupied by a suited sequence. -/
def Shuntsu.tiles (shuntsu : Shuntsu) : Multiset Tile :=
  Multiset.ofList shuntsu.orderedTiles

/-- A mentsu-hand meld candidate: a suited sequence or a triplet. -/
inductive MentsuCandidate
  | shuntsu (shuntsu : Shuntsu)
  | koutsu (tile : Tile)
  deriving DecidableEq, Fintype

/-- Meld tile kinds, with a sequence in ascending rank order. -/
def MentsuCandidate.orderedTiles : MentsuCandidate → List Tile
  | .shuntsu sequence => sequence.orderedTiles
  | .koutsu tile => [tile, tile, tile]

/-- The tile-kind multiset occupied by a mentsu-hand meld candidate. -/
def MentsuCandidate.tiles (candidate : MentsuCandidate) : Multiset Tile :=
  Multiset.ofList candidate.orderedTiles

theorem MentsuCandidate.orderedTiles_length (candidate : MentsuCandidate) :
    candidate.orderedTiles.length = 3 := by
  cases candidate with
  | shuntsu sequence => cases sequence; rfl
  | koutsu tile => rfl

theorem MentsuCandidateList.flatMap_orderedTiles_length
    (candidates : List MentsuCandidate) :
    (candidates.flatMap MentsuCandidate.orderedTiles).length = candidates.length * 3 := by
  induction candidates with
  | nil => rfl
  | cons first rest inductionHypothesis =>
      simp only [List.flatMap_cons, List.length_append, List.length_cons]
      rw [MentsuCandidate.orderedTiles_length, inductionHypothesis]
      simp [Nat.add_mul, Nat.add_comm]

/-- The tile-kind multiset occupied by a fixed kan; it is not a mentsu candidate. -/
def Kan.occupiedTiles (tile : Tile) : Multiset Tile :=
  Multiset.replicate copiesPerTile tile

/-- Expand an ordered candidate list without forgetting repeated equal candidates. -/
def MentsuCandidateList.tiles : List MentsuCandidate → Multiset Tile
  | [] => 0
  | candidate :: rest => candidate.tiles + MentsuCandidateList.tiles rest

/-- Tile-kind multiplicities of a tile multiset. -/
def TileCounts.ofMultiset (tiles : Multiset Tile) : TileCounts :=
  fun tile => tiles.count tile

/-- Tile-kind multiplicities of a tile list, independent of list order. -/
def TileCounts.ofList (tiles : List Tile) : TileCounts :=
  TileCounts.ofMultiset (Multiset.ofList tiles)

theorem TileCounts.ofList_apply [BEq Tile] [LawfulBEq Tile]
    (tiles : List Tile) (tile : Tile) :
    TileCounts.ofList tiles tile = tiles.count tile := by
  induction tiles with
  | nil => rfl
  | cons first rest inductionHypothesis =>
      change (Multiset.ofList rest).count tile = rest.count tile at inductionHypothesis
      change Multiset.count tile (first ::ₘ Multiset.ofList rest) = _
      rw [Multiset.count_cons, List.count_cons, inductionHypothesis]
      by_cases equal : tile = first
      · subst first
        simp
      · have unequal : first ≠ tile := Ne.symm equal
        simp [equal, unequal]

/-- Tile-kind multiplicities contributed by an ordered candidate list. -/
def MentsuCandidateList.counts (candidates : List MentsuCandidate) : TileCounts :=
  fun tile => (MentsuCandidateList.tiles candidates).count tile

/-- The remaining tile-kind counts after selecting this pair from a count vector. -/
def Pair.remainingCounts (counts : TileCounts) (pair : Pair) : TileCounts :=
  fun tile => counts tile - pair.tiles.count tile

/-- One mentsu-hand decomposition, retaining the chosen pair and ordered candidate list. -/
structure MentsuHandDecomposition where
  pair : Pair
  mentsuCandidates : List MentsuCandidate
  deriving DecidableEq

/-- The tile-kind multiset represented by one mentsu-hand decomposition. -/
def MentsuHandDecomposition.tiles (decomposition : MentsuHandDecomposition) :
    Multiset Tile :=
  decomposition.pair.tiles + MentsuCandidateList.tiles decomposition.mentsuCandidates

/-- The tile-kind multiplicities represented by one mentsu-hand decomposition. -/
def MentsuHandDecomposition.counts (decomposition : MentsuHandDecomposition) :
    TileCounts :=
  TileCounts.ofMultiset decomposition.tiles

/-- A count vector has a witness consisting of one pair and exactly `candidateCount` candidates. -/
def MentsuHandCompletion (candidateCount : Nat) (counts : TileCounts) : Prop :=
  ∃ decomposition : MentsuHandDecomposition,
    decomposition.mentsuCandidates.length = candidateCount ∧ decomposition.counts = counts

theorem Pair.tiles_card (pair : Pair) : pair.tiles.card = 2 := by
  simp [Pair.tiles, Pair.orderedTiles]

theorem MentsuCandidate.tiles_card (candidate : MentsuCandidate) :
    candidate.tiles.card = 3 := by
  cases candidate with
  | shuntsu shuntsu => simp [MentsuCandidate.tiles, MentsuCandidate.orderedTiles, Shuntsu.orderedTiles]
  | koutsu tile => simp [MentsuCandidate.tiles, MentsuCandidate.orderedTiles]

theorem MentsuCandidateList.tiles_card (candidates : List MentsuCandidate) :
    (MentsuCandidateList.tiles candidates).card = 3 * candidates.length := by
  induction candidates with
  | nil => rfl
  | cons candidate rest ih =>
      change (candidate.tiles + MentsuCandidateList.tiles rest).card =
        3 * (rest.length + 1)
      rw [Multiset.card_add, MentsuCandidate.tiles_card, ih]
      omega

theorem TileCounts.ofMultiset_sum_eq_card (tiles : Multiset Tile) :
    (∑ tile : Tile, TileCounts.ofMultiset tiles tile) = tiles.card := by
  induction tiles using Multiset.induction_on with
  | empty => simp [TileCounts.ofMultiset]
  | @cons tile tiles ih =>
      simp [TileCounts.ofMultiset, ih, Finset.sum_add_distrib]

theorem TileCounts.ofList_sum_eq_length (tiles : List Tile) :
    (∑ tile : Tile, TileCounts.ofList tiles tile) = tiles.length := by
  simpa [TileCounts.ofList] using TileCounts.ofMultiset_sum_eq_card (Multiset.ofList tiles)

theorem MentsuHandCompletion.counts_total
    (completion : MentsuHandCompletion candidateCount counts) :
    (∑ tile : Tile, counts tile) = 2 + 3 * candidateCount := by
  obtain ⟨decomposition, hlength, hcounts⟩ := completion
  rw [← hcounts]
  unfold MentsuHandDecomposition.counts MentsuHandDecomposition.tiles
  rw [TileCounts.ofMultiset_sum_eq_card, Multiset.card_add, Pair.tiles_card,
    MentsuCandidateList.tiles_card, hlength]

theorem Kan.occupiedTiles_card (tile : Tile) :
    (Kan.occupiedTiles tile).card = copiesPerTile := by
  simp [Kan.occupiedTiles]

theorem Pair.counts_eq_pair_add_remaining (counts : TileCounts) (pair : Pair)
    (hcount : 2 ≤ counts pair.tile) :
    counts = fun tile => pair.tiles.count tile + Pair.remainingCounts counts pair tile := by
  funext tile
  by_cases htile : tile = pair.tile
  · subst tile
    simp [Pair.remainingCounts, Pair.tiles, Pair.orderedTiles]
    omega
  · simp [Pair.remainingCounts, Pair.tiles, Pair.orderedTiles, htile]

theorem MentsuCandidateList.counts_cons (candidate : MentsuCandidate)
    (candidates : List MentsuCandidate) :
    MentsuCandidateList.counts (candidate :: candidates) =
      fun tile => candidate.tiles.count tile + MentsuCandidateList.counts candidates tile := by
  funext tile
  simp [MentsuCandidateList.counts, MentsuCandidateList.tiles, Multiset.count_add]

theorem MentsuCandidateList.counts_eq_list_count [BEq Tile] [LawfulBEq Tile]
    (candidates : List MentsuCandidate) (tile : Tile) :
    MentsuCandidateList.counts candidates tile =
      (candidates.flatMap MentsuCandidate.orderedTiles).count tile := by
  induction candidates with
  | nil => rfl
  | cons first rest inductionHypothesis =>
      rw [MentsuCandidateList.counts_cons]
      simp only [List.flatMap_cons, List.count_append, inductionHypothesis]
      exact congrArg (· + _) (TileCounts.ofList_apply first.orderedTiles tile)

theorem MentsuHandDecomposition.counts_eq_parts
    (decomposition : MentsuHandDecomposition) :
    decomposition.counts =
      fun tile => decomposition.pair.tiles.count tile +
        MentsuCandidateList.counts decomposition.mentsuCandidates tile := by
  funext tile
  simp [MentsuHandDecomposition.counts, MentsuHandDecomposition.tiles,
    TileCounts.ofMultiset, Multiset.count_add, MentsuCandidateList.counts]

theorem mentsuHandCompletion_iff_parts (candidateCount : Nat) (counts : TileCounts) :
    MentsuHandCompletion candidateCount counts ↔
      ∃ pair : Pair, ∃ candidates : List MentsuCandidate,
        candidates.length = candidateCount ∧
        (fun tile => pair.tiles.count tile + MentsuCandidateList.counts candidates tile) = counts := by
  constructor
  · rintro ⟨decomposition, hlength, hcounts⟩
    exact ⟨decomposition.pair, decomposition.mentsuCandidates, hlength, by
      rw [← decomposition.counts_eq_parts, hcounts]⟩
  · rintro ⟨pair, candidates, hlength, hcounts⟩
    refine ⟨⟨pair, candidates⟩, hlength, ?_⟩
    rw [MentsuHandDecomposition.counts_eq_parts]
    exact hcounts

end MahjongDomain
