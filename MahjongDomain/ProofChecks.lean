module

import MahjongDomain.Representation
import MahjongDomain.Tenhou
import MahjongDomain.Parts
import MahjongDomain.Orphans
import MahjongDomain.HandKey
import Mathlib.Util.AssertNoSorry

namespace MahjongDomain

assert_no_sorry Tile.all_length
assert_no_sorry Tile.mem_all
assert_no_sorry Tile.index_injective
assert_no_sorry TileCounts.valid_add_one_iff
assert_no_sorry mem_orphanKinds
assert_no_sorry orphanKinds_card
assert_no_sorry orphanTiles_count
assert_no_sorry orphanTiles_card
assert_no_sorry Int37Index.tile_int37Index
assert_no_sorry TenhouId.tile_index
assert_no_sorry TenhouId.int34Index_val
assert_no_sorry TenhouId.int34Index_eq_int37Index
assert_no_sorry TenhouId.int37_capacity_count
assert_no_sorry TenhouId.tile_capacity_count
assert_no_sorry TileCounts.ofTenhou_sum
assert_no_sorry aggregateInt37_add
assert_no_sorry aggregateInt37_total
assert_no_sorry aggregateInt37_capacity
assert_no_sorry aggregateInt37_le_four
assert_no_sorry Pair.tiles_eq_replicate
assert_no_sorry Pair.tiles_card
assert_no_sorry MentsuCandidate.tiles_card
assert_no_sorry MentsuCandidateList.tiles_card
assert_no_sorry TileCounts.ofMultiset_sum_eq_card
assert_no_sorry TileCounts.ofList_sum_eq_length
assert_no_sorry MentsuHandCompletion.counts_total
assert_no_sorry Kan.occupiedTiles_card
assert_no_sorry Pair.counts_eq_pair_add_remaining
assert_no_sorry MentsuCandidateList.counts_cons
assert_no_sorry TileCounts.ofList_apply
assert_no_sorry MentsuCandidateList.counts_eq_list_count
assert_no_sorry MentsuCandidate.orderedTiles_length
assert_no_sorry MentsuCandidateList.flatMap_orderedTiles_length
assert_no_sorry MentsuHandDecomposition.counts_eq_parts
assert_no_sorry mentsuHandCompletion_iff_parts
assert_no_sorry MeldedHand.valid
assert_no_sorry MeldedHand.encode
assert_no_sorry MeldedHand.decode
assert_no_sorry TileCollection.encode
assert_no_sorry TileCollection.decode

example :
    (Shuntsu.orderedTiles ⟨.man, ⟨0, by decide⟩⟩) =
      [.suited .man 0, .suited .man 1, .suited .man 2] ∧
    (Shuntsu.orderedTiles ⟨.sou, ⟨6, by decide⟩⟩) =
      [.suited .sou 6, .suited .sou 7, .suited .sou 8] := by
  constructor <;> rfl

example (tile : Tile) :
    (Pair.mk tile).orderedTiles = [tile, tile] ∧
    (MentsuCandidate.koutsu tile).orderedTiles = [tile, tile, tile] := by
  constructor <;> rfl

example (sequence : Shuntsu) :
    (MentsuCandidate.shuntsu sequence).orderedTiles = sequence.orderedTiles := rfl
example (pair : Pair) : Multiset.ofList pair.orderedTiles = pair.tiles := rfl
example (candidate : MentsuCandidate) :
    Multiset.ofList candidate.orderedTiles = candidate.tiles := rfl

example (suit : Suit) (rank : Rank) :
    Tile.suited suit rank ∈ orphanKinds ↔ rank.val = 0 ∨ rank.val = 8 :=
  mem_orphanKinds _

example (honor : Honor) : Tile.honor honor ∈ orphanKinds :=
  (mem_orphanKinds _).mpr trivial

example (tile : Tile) :
    TileCounts.ofMultiset (Multiset.replicate 4 tile) tile = 4 := by
  simp [TileCounts.ofMultiset]

example (tile : Tile) : TileCounts.ofList [tile, tile, tile, tile] tile = 4 := by
  simp [TileCounts.ofList, TileCounts.ofMultiset]

example (tile : Tile) :
    TileCounts.CanAdd (fun _ => 3) tile ∧
      ¬ TileCounts.CanAdd (fun _ => 4) tile ∧
      ¬ TileCounts.Valid (fun _ => 5) := by
  letI : Nonempty Tile := ⟨tile⟩
  simp [TileCounts.CanAdd, TileCounts.Valid]

example : (∑ tile : Tile, TileCounts.ofMultiset 0 tile) = 0 := by
  rw [TileCounts.ofMultiset_sum_eq_card]
  rfl

example (candidate : MentsuCandidate) :
    (MentsuCandidateList.tiles [candidate, candidate]).card = 6 := by
  rw [MentsuCandidateList.tiles_card]
  rfl

example : (MentsuCandidateList.tiles []).card = 0 := rfl

end MahjongDomain
