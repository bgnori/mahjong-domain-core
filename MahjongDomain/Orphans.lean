module

public import MahjongDomain.Parts
import Mathlib.Tactic.FinCases

@[expose] public section

namespace MahjongDomain

/-- A terminal suited tile or an honor tile. -/
def Tile.IsTerminalOrHonor : Tile → Prop
  | .suited _ rank => rank.val = 0 ∨ rank.val = 8
  | .honor _ => True

instance (tile : Tile) : Decidable tile.IsTerminalOrHonor := by
  cases tile <;> unfold Tile.IsTerminalOrHonor <;> infer_instance

/-- The thirteen terminal and honor kinds, as an unordered computable set. -/
def orphanKinds : Finset Tile :=
  { .suited .man 0, .suited .man 8
  , .suited .pin 0, .suited .pin 8
  , .suited .sou 0, .suited .sou 8
  , .honor 0, .honor 1, .honor 2, .honor 3
  , .honor 4, .honor 5, .honor 6 }

theorem mem_orphanKinds (tile : Tile) :
    tile ∈ orphanKinds ↔ tile.IsTerminalOrHonor := by
  cases tile with
  | suited suit rank => cases suit <;> fin_cases rank <;> decide
  | honor rank => fin_cases rank <;> decide

theorem orphanKinds_card : orphanKinds.card = 13 := by
  decide

/-- One of each terminal or honor kind, with no meaningful order. -/
def orphanTiles : Multiset Tile :=
  orphanKinds.val

theorem orphanTiles_count (tile : Tile) :
    orphanTiles.count tile = if tile ∈ orphanKinds then 1 else 0 := by
  exact Multiset.count_eq_of_nodup orphanKinds.nodup

theorem orphanTiles_card : orphanTiles.card = 13 := by
  exact orphanKinds_card

end MahjongDomain
