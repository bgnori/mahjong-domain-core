# Mahjong Domain Glossary / 麻雀ドメイン用語集

This is the canonical glossary for concepts defined by Mahjong Domain Core.
It records shared meanings, scope, assumptions, and the Lean declarations that
implement them. Client-specific meanings and differences belong in client
documentation and should link here rather than duplicate shared definitions.

この文書はMahjong Domain Coreで定義する共通概念の正本です。共有する意味、
適用範囲、前提、および対応するLean識別子を記録します。利用側固有の意味や差分は
各プロジェクトの文書に記し、共通定義を複製せず本書を参照してください。

| English term | 日本語 | Definition and scope / 定義・対象範囲 | Preconditions / 前提 | Lean declaration |
|---|---|---|---|---|
| Tile kind | 牌種 | One of the 34 normalized kinds. Red fives are not separate kinds. / 正規化後の34種類。赤5は独立した牌種ではありません。 | Numbered ranks are zero-based; honors follow east, south, west, north, white, green, red. / 数牌ランクは0始まり、字牌は東南西北白發中の順です。 | `MahjongDomain.Tile`, `MahjongDomain.Tile.index` |
| Physical tile ID | 物理牌ID | One physical tile in the 136-ID Tenhou ordering. The four IDs for a kind are consecutive. / Tenhou順の136個のIDのうちの1つ。同じ牌種の4個は連続します。 | Copy zero of 5m, 5p, and 5s is the red five. / 5萬・5筒・5索のcopy 0を赤5とします。 | `MahjongDomain.PhysicalTileId`, `PhysicalTileId.int37Index`, `PhysicalTileId.tile` |
| Int37 slot | Int37スロット | One input slot preserving red-five identity: red fives use 0, 10, 20; ordinary fives use 5, 15, 25; honors use 30–36. / 赤5を区別する入力スロット。赤5は0・10・20、通常5は5・15・25、字牌は30–36です。 | Suited slots are grouped by suit; indices 0, 10, and 20 are reserved for red fives. / 数牌は色ごとに並び、0・10・20は赤5専用です。 | `MahjongDomain.Int37Index`, `Int37Index.tile`, `Tile.int37Index` |
| Normalization | 正規化 | Maps each Int37 slot to its normalized tile kind, merging a red five with the ordinary five of the same suit. / Int37スロットを牌種へ写し、赤5を同じ色の通常5へ統合します。 | This is a lossy projection; it does not preserve red-five identity. / 情報を失う射影で、赤5の区別は復元できません。 | `Int37Index.tile` |
| Aggregation | 集約 | Sums signed Int37 counts over all slots that normalize to a given tile kind. / 正規化後に同じ牌種となる全スロットの符号付きカウントを合算します。 | Counts may be signed; nonnegativity is a client input-validity condition. / カウントは符号付きで、非負性は利用側の入力妥当性条件です。 | `MahjongDomain.Int37Counts`, `MahjongDomain.aggregateInt37` |
| Tile-kind capacity | 牌種容量 | At most four physical copies exist for each normalized tile kind. / 正規化後の各牌種に物理牌は最大4枚あります。 | Int37 capacity is 1 for a red-five slot, 3 for the corresponding ordinary-five slot, and 4 otherwise. / Int37では赤5枠が1、対応する通常5枠が3、それ以外が4です。 | `Int37Index.capacity`, `aggregateInt37_capacity`, `aggregateInt37_le_four` |
| Count conservation | 枚数保存 | Aggregation preserves the signed total, distributes over pointwise addition, and maps per-slot physical capacities to four copies per kind. / 集約は符号付き総数を保ち、点ごとの加算に分配し、スロット容量を牌種ごとの4枚へ写します。 | Capacity bounds must hold for every Int37 slot. / 各Int37スロットで容量上限を満たす必要があります。 | `aggregateInt37_add`, `aggregateInt37_total`, `aggregateInt37_capacity`, `PhysicalTileId.int37_capacity_count` |
| Pair / head | 対子・雀頭 | Two copies of one tile kind; in a standard decomposition exactly one pair is retained as the head. / 同一牌種2枚の組。通常形分解では1組を雀頭として保持します。 | A pair is distinct from a two-tile incomplete block and from seven-pairs structure. / 搭子や七対子の対とは別の役割です。 | `Pair`, `Pair.tiles` |
| Standard meld | 通常面子 | One triplet or one suited sequence, each occupying three tiles. / 刻子または同一スートの順子で、いずれも牌を3枚使います。 | A kan is not a `Meld` candidate in standard decomposition. / 槓は通常形分解の`Meld`候補ではありません。 | `Meld`, `Meld.tiles` |
| Kan occupancy | 槓占有 | The four tile copies occupied by a fixed kan, while the kan counts as one fixed meld at the client boundary. / 固定槓が占有する同一牌種4枚。利用側の面子数では1個です。 | Occupancy is separate from the concealed standard-meld type. / 門前通常面子型とは別の表現です。 | `Kan.occupiedTiles` |
| Standard decomposition | 通常形分解 | One chosen pair and an ordered list of standard melds, preserving repeated equal melds. / 選択した雀頭1組と順序付き面子リスト。同じ面子の反復も保持します。 | The represented count vector is defined by tile-kind multiplicity, not list order. / 対応するカウントは列順ではなく牌種ごとの多重度で定まります。 | `StandardDecomposition`, `StandardDecomposition.tiles`, `StandardDecomposition.counts` |
| Standard completion | 通常形完成仕様 | A witness-bearing standard decomposition with exactly the requested number of melds and the specified tile-kind counts. / 指定数の面子を持ち、指定カウントに一致する証人付き通常形分解です。 | The decomposition witness is retained; distinct decompositions of equal counts are not collapsed. / 分解証人を保持し、同じカウントの異なる分解を潰しません。 | `StandardCompletion`, `standardCompletion_iff_parts` |
