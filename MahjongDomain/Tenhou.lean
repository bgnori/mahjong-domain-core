module

public import MahjongDomain.Representation
public import MahjongDomain.Parts
public import MahjongDomain.Tile37
import Mathlib.Tactic.FinCases

/-!
# Tenhou input adapter

This module isolates Tenhou's physical-code ordering from normalized tile
representations and provides checked decoding into count representations.
-/

@[expose] public section

namespace MahjongDomain

/-- A Tenhou tile code in its stable 0-based ordering. -/
abbrev TenhouId := Fin (34 * copiesPerTile)

inductive TenhouDecodeError where
  | idOutOfRange (value : Nat)
  | duplicateId
  deriving DecidableEq, Repr

namespace TenhouId

/-- Decode a raw Tenhou tile code after checking its range. -/
def decode (value : Nat) : Except TenhouDecodeError TenhouId :=
  if h : value < 34 * copiesPerTile then
    .ok ⟨value, h⟩
  else
    .error (.idOutOfRange value)

/-- Map a Tenhou tile code to its aka37 slot. Copy zero of each five is red. -/
def int37Index (id : TenhouId) : Int37Index :=
  let kind := id.val / copiesPerTile
  let copy := id.val % copiesPerTile
  let index :=
    if kind = 4 ∧ copy = 0 then 0
    else if kind = 13 ∧ copy = 0 then 10
    else if kind = 22 ∧ copy = 0 then 20
    else if kind < 27 then kind / 9 * 10 + kind % 9 + 1
    else kind + 3
  ⟨index, by
    have hkind : kind < 34 := by dsimp [kind, copiesPerTile]; omega
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

/-- The normalized tile kind represented by a Tenhou tile code. -/
def tile (id : TenhouId) : Tile :=
  id.int37Index.tile

/-- Map a Tenhou tile code to its red-aware 37-kind identity. -/
def tile37 (id : TenhouId) : Tile37 :=
  Tile37.ofIndex id.int37Index

/-- Map a Tenhou tile code directly to its normalized Int34 index. -/
def int34Index (id : TenhouId) : Int34Index :=
  ⟨id.val / 4, by
    have h : id.val < 136 := by simp [copiesPerTile]
    omega⟩

set_option maxRecDepth 8192 in
theorem tile_index (id : TenhouId) :
    id.tile.index.val = id.val / copiesPerTile := by
  fin_cases id <;> decide

theorem int34Index_val (id : TenhouId) :
    id.int34Index.val = id.val / copiesPerTile := by
  rfl

theorem int34Index_eq_int37Index (id : TenhouId) :
    id.int34Index = id.int37Index.tile.index := by
  apply Fin.ext
  exact (int34Index_val id).trans (tile_index id).symm

set_option maxRecDepth 8192 in
theorem int37_capacity_count (index : Int37Index) :
    (∑ id : TenhouId, if id.int37Index = index then (1 : Nat) else 0) =
      index.capacity := by
  fin_cases index <;> decide

set_option maxRecDepth 8192 in
theorem tile_capacity_count (tile : Tile) :
    (∑ id : TenhouId, if id.tile = tile then (1 : Nat) else 0) =
      copiesPerTile := by
  cases tile with
  | suited suit rank => cases suit <;> fin_cases rank <;> decide
  | honor rank => fin_cases rank <;> decide

end TenhouId

/-- Decode a list of raw Tenhou codes, rejecting out-of-range and repeated IDs. -/
def decodeTenhouIds (values : List Nat) : Except TenhouDecodeError (List TenhouId) := do
  let ids ← values.mapM TenhouId.decode
  if ids.Nodup then
    pure ids
  else
    .error .duplicateId

namespace Int37Counts

/-- Convert distinct Tenhou tile codes to signed aka37 counts. -/
def ofTenhou (ids : List TenhouId) : Int37Counts :=
  fun index =>
    Int.ofNat (ids.countP fun id => decide (id.int37Index = index))

/-- Decode distinct raw Tenhou codes and convert them to signed aka37 counts. -/
def decodeTenhou (values : List Nat) : Except TenhouDecodeError Int37Counts := do
  let ids ← decodeTenhouIds values
  pure (ofTenhou ids)

end Int37Counts

namespace Int34Counts

/-- Convert distinct Tenhou tile codes to signed normalized Int34 counts. -/
def ofTenhou (ids : List TenhouId) : Int34Counts :=
  fun index =>
    Int.ofNat (ids.countP fun id => decide (id.int34Index = index))

/-- Decode distinct raw Tenhou codes and convert them to signed Int34 counts. -/
def decodeTenhou (values : List Nat) : Except TenhouDecodeError Int34Counts := do
  let ids ← decodeTenhouIds values
  pure (ofTenhou ids)

end Int34Counts

namespace Tile37Counts

/-- Convert distinct Tenhou tile codes to red-aware 37-kind counts. -/
def ofTenhou (ids : List TenhouId) : Tile37Counts :=
  Tile37Counts.ofList (ids.map TenhouId.tile37)

theorem ofTenhou_sum (ids : List TenhouId) :
    (∑ tile : Tile37, ofTenhou ids tile) = ids.length := by
  simpa [ofTenhou] using
    Tile37Counts.ofList_sum_eq_length (ids.map TenhouId.tile37)

/-- Decode distinct raw Tenhou codes and preserve red-five identity. -/
def decodeTenhou (values : List Nat) : Except TenhouDecodeError Tile37Counts := do
  let ids ← decodeTenhouIds values
  pure (ofTenhou ids)

end Tile37Counts

namespace TileCounts

/-- Convert distinct Tenhou tile codes to normalized natural tile-kind counts. -/
def ofTenhou (ids : List TenhouId) : TileCounts :=
  TileCounts.ofList (ids.map TenhouId.tile)

/-- The normalized counts preserve the number of decoded Tenhou IDs. -/
theorem ofTenhou_sum (ids : List TenhouId) :
    (∑ tile : Tile, ofTenhou ids tile) = ids.length := by
  unfold ofTenhou
  rw [TileCounts.ofList_sum_eq_length]
  simp

/-- Decode distinct raw Tenhou codes and convert them to normalized tile counts. -/
def decodeTenhou (values : List Nat) : Except TenhouDecodeError TileCounts := do
  let ids ← decodeTenhouIds values
  pure (ofTenhou ids)

end TileCounts

example : TenhouId.decode 16 = .ok ⟨16, by decide⟩ := by rfl

example : TenhouId.decode 136 = .error (.idOutOfRange 136) := by rfl

example :
    decodeTenhouIds [16, 17, 16] = .error .duplicateId := by rfl

example :
    (Int37Counts.decodeTenhou [16, 17, 52]).map
        (fun counts => counts ⟨0, by decide⟩) = .ok 1 := by
  rfl

example :
    (Int37Counts.decodeTenhou [16, 17, 52, 53]).map
        (fun counts =>
          (counts ⟨0, by decide⟩, counts ⟨5, by decide⟩,
            counts ⟨10, by decide⟩, counts ⟨15, by decide⟩)) =
      .ok (1, 1, 1, 1) := by
  rfl

example :
    (TenhouId.decode 16).map TenhouId.tile37 = .ok (.akaFive .man) := by
  rfl

example :
    (Tile37Counts.decodeTenhou [16, 17, 52, 53]).map
        (fun counts =>
          (counts (.akaFive .man), counts (.normal (.suited .man 4)),
            counts (.akaFive .pin), counts (.normal (.suited .pin 4)))) =
      .ok (1, 1, 1, 1) := by
  rfl

example :
    (Int34Counts.decodeTenhou [16, 17, 52, 53]).map
        (fun counts => (counts ⟨4, by decide⟩, counts ⟨13, by decide⟩)) =
      .ok (2, 2) := by
  rfl

end MahjongDomain
