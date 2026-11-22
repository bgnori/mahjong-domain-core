module

import MahjongDomain.Representation
import MahjongDomain.Parts
import Mathlib.Util.AssertNoSorry

namespace MahjongDomain

assert_no_sorry Tile.all_length
assert_no_sorry Tile.index_injective
assert_no_sorry Int37Index.tile_int37Index
assert_no_sorry PhysicalTileId.tile_index
assert_no_sorry PhysicalTileId.int34Index_val
assert_no_sorry PhysicalTileId.int34Index_eq_int37Index
assert_no_sorry PhysicalTileId.int37_capacity_count
assert_no_sorry aggregateInt37_add
assert_no_sorry aggregateInt37_total
assert_no_sorry aggregateInt37_capacity
assert_no_sorry aggregateInt37_le_four
assert_no_sorry Pair.tiles_eq_replicate
assert_no_sorry Pair.tiles_card
assert_no_sorry MentsuCandidate.tiles_card
assert_no_sorry Kan.occupiedTiles_card
assert_no_sorry Pair.counts_eq_pair_add_remaining
assert_no_sorry MentsuCandidateList.counts_cons
assert_no_sorry StandardDecomposition.counts_eq_parts
assert_no_sorry standardCompletion_iff_parts

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

end MahjongDomain
