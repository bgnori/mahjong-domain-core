module

public import MahjongDomain.Tile
public import Mathlib.Algebra.BigOperators.Group.Finset.Defs
public import Mathlib.Data.Fintype.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.FinCases

@[expose] public section

namespace MahjongDomain

/-- A physical tile ID in the stable Tenhou 0-based ordering. -/
abbrev PhysicalTileId := Fin 136

/-- An aka37 slot; red fives have separate slots from ordinary fives. -/
abbrev Int37Index := Fin 37

/-- A normalized Int34 tile-kind index. -/
abbrev Int34Index := Fin 34

/-- Signed counts in the aka37 representation. -/
abbrev Int37Counts := Int37Index → Int

/-- Signed counts in the normalized Int34 representation. -/
abbrev Int34Counts := Int34Index → Int

/-- The aka37 slot for the normalized tile, choosing the ordinary five slot. -/
def Tile.int37Index : Tile → Int37Index
  | .suited .man rank => ⟨rank.val + 1, by omega⟩
  | .suited .pin rank => ⟨rank.val + 11, by omega⟩
  | .suited .sou rank => ⟨rank.val + 21, by omega⟩
  | .honor rank => ⟨rank.val + 30, by omega⟩

/-- The normalized tile kind represented by an aka37 slot. -/
def Int37Index.tile : Int37Index → Tile
  | ⟨i, _⟩ =>
    if h : i < 10 then
      .suited .man ⟨if i = 0 then 4 else i - 1, by
        split <;> omega⟩
    else if h : i < 20 then
      .suited .pin ⟨if i = 10 then 4 else i - 11, by
        split <;> omega⟩
    else if h : i < 30 then
      .suited .sou ⟨if i = 20 then 4 else i - 21, by
        split <;> omega⟩
    else
      .honor ⟨i - 30, by omega⟩

/-- The physical-copy capacity of an aka37 slot. -/
def Int37Index.capacity (index : Int37Index) : Nat :=
  if index.val = 0 || index.val = 10 || index.val = 20 then 1
  else if index.val = 5 || index.val = 15 || index.val = 25 then 3
  else 4

/-- Map a Tenhou physical tile ID to its aka37 slot. Copy zero of each five is red. -/
def PhysicalTileId.int37Index (id : PhysicalTileId) : Int37Index :=
  let kind := id.val / 4
  let copy := id.val % 4
  let index :=
    if kind = 4 ∧ copy = 0 then 0
    else if kind = 13 ∧ copy = 0 then 10
    else if kind = 22 ∧ copy = 0 then 20
    else if kind < 27 then kind / 9 * 10 + kind % 9 + 1
    else
      kind + 3
  ⟨index, by
    have hkind : kind < 34 := by dsimp [kind]; omega
    by_cases h0 : kind = 4 ∧ copy = 0
    · simp [index, h0]
    · by_cases h1 : kind = 13 ∧ copy = 0
      · simp [index, h1]
      · by_cases h2 : kind = 22 ∧ copy = 0
        · simp [index, h2]
        · by_cases hnumbered : kind < 27
          · have hsuit : kind / 9 < 3 := by omega
            have hrank : kind % 9 < 9 := Nat.mod_lt _ (by decide)
            simp [index, h0, h1, h2, hnumbered]
            omega
          · simp [index, h0, h1, h2, hnumbered]
            omega⟩

/-- The normalized kind of a physical tile ID. -/
def PhysicalTileId.tile (id : PhysicalTileId) : Tile :=
  id.int37Index.tile

/-- Map a Tenhou physical tile ID directly to its normalized Int34 index. -/
def PhysicalTileId.int34Index (id : PhysicalTileId) : Int34Index :=
  ⟨id.val / 4, by
    have hkind : id.val / 4 < 34 := by omega
    exact hkind⟩

/--
Convert valid Tenhou physical tile IDs to signed Int37 counts. Hand length and
physical-ID uniqueness are caller responsibilities.
-/
def Int37Counts.ofTenhou (ids : List PhysicalTileId) : Int37Counts :=
  fun index =>
    Int.ofNat (ids.countP fun id => decide (id.int37Index = index))

/--
Convert valid Tenhou physical tile IDs to signed Int34 counts. Hand length and
physical-ID uniqueness are caller responsibilities.
-/
def Int34Counts.ofTenhou (ids : List PhysicalTileId) : Int34Counts :=
  fun index =>
    Int.ofNat (ids.countP fun id => decide (id.int34Index = index))

/-- Aggregate signed aka37 counts by normalized 34-kind tile. -/
def aggregateInt37 (counts : Int37Counts) : Tile → Int :=
  fun tile => ∑ index : Int37Index, if tile = index.tile then counts index else 0

/-- The total in an aka37 count vector. -/
def Int37Counts.total (counts : Int37Counts) : Int :=
  ∑ index, counts index

/-- The total after aggregation to normalized tile kinds. -/
def Tile.intCountsTotal (counts : Tile → Int) : Int :=
  ∑ tile, counts tile

theorem Int37Index.tile_int37Index (tile : Tile) :
    tile.int37Index.tile = tile := by
  cases tile with
  | suited suit rank => cases suit <;> fin_cases rank <;> decide
  | honor rank => fin_cases rank <;> decide

theorem PhysicalTileId.tile_index (id : PhysicalTileId) :
    id.tile.index.val = id.val / 4 := by
  fin_cases id <;> decide

theorem PhysicalTileId.int34Index_val (id : PhysicalTileId) :
    id.int34Index.val = id.val / 4 := by
  rfl

theorem PhysicalTileId.int34Index_eq_int37Index (id : PhysicalTileId) :
    id.int34Index = id.int37Index.tile.index := by
  apply Fin.ext
  exact (PhysicalTileId.tile_index id).symm

theorem aggregateInt37_add (left right : Int37Counts) :
    aggregateInt37 (fun index => left index + right index) =
      fun tile => aggregateInt37 left tile + aggregateInt37 right tile := by
  funext tile
  simp only [aggregateInt37, ← Finset.sum_add_distrib]
  apply Finset.sum_congr rfl
  intro index _
  split <;> simp

theorem aggregateInt37_total (counts : Int37Counts) :
    Tile.intCountsTotal (aggregateInt37 counts) = counts.total := by
  unfold Tile.intCountsTotal aggregateInt37 Int37Counts.total
  rw [Finset.sum_comm]
  simp only [Fintype.sum_ite_eq']

set_option maxRecDepth 8192 in
theorem aggregateInt37_capacity :
    aggregateInt37 (fun index => (index.capacity : Int)) = fun _ => 4 := by
  funext tile
  cases tile with
  | suited suit rank => cases suit <;> fin_cases rank <;> decide
  | honor rank => fin_cases rank <;> decide

theorem aggregateInt37_le_four (counts : Int37Counts)
    (hcapacity : ∀ index, counts index ≤ (index.capacity : Int)) (tile : Tile) :
    aggregateInt37 counts tile ≤ 4 := by
  rw [← congrFun aggregateInt37_capacity tile]
  unfold aggregateInt37
  apply Finset.sum_le_sum
  intro index _
  split
  · exact hcapacity index
  · omega

set_option maxRecDepth 8192 in
theorem PhysicalTileId.int37_capacity_count (index : Int37Index) :
    (∑ id : PhysicalTileId, if id.int37Index = index then (1 : Nat) else 0) =
      index.capacity := by
  fin_cases index <;> decide

example :
    Int37Counts.ofTenhou
        [⟨16, by decide⟩, ⟨17, by decide⟩, ⟨52, by decide⟩] ⟨0, by decide⟩ = 1 := by
  native_decide

example :
    Int37Counts.ofTenhou
        [⟨16, by decide⟩, ⟨17, by decide⟩, ⟨52, by decide⟩] ⟨5, by decide⟩ = 1 := by
  native_decide

example :
    Int37Counts.ofTenhou
        [⟨16, by decide⟩, ⟨17, by decide⟩, ⟨52, by decide⟩] ⟨10, by decide⟩ = 1 := by
  native_decide

example :
    Int34Counts.ofTenhou
        [⟨16, by decide⟩, ⟨17, by decide⟩, ⟨52, by decide⟩] ⟨4, by decide⟩ = 2 := by
  native_decide

example :
    Int34Counts.ofTenhou
        [⟨16, by decide⟩, ⟨17, by decide⟩, ⟨52, by decide⟩] ⟨13, by decide⟩ = 1 := by
  native_decide

end MahjongDomain
