# Mahjong Domain Glossary / 麻雀ドメイン用語集

This is the canonical glossary for concepts defined by Mahjong Domain Core.
It records shared meanings, scope, assumptions, and the Lean declarations that
implement them. Client-specific meanings and differences belong in client
documentation and should link here rather than duplicate shared definitions.

この文書はMahjong Domain Coreで定義する共通概念の正本です。共有する意味、
適用範囲、前提、および対応するLean識別子を記録します。利用側固有の意味や差分は
各プロジェクトの文書に記し、共通定義を複製せず本書を参照してください。

## Shared terms / 共通用語

| English term | 日本語 | Definition and scope / 定義・対象範囲 | Preconditions / 前提 | Lean declaration |
|---|---|---|---|---|
| Normalized tile kind | 正規化牌種 | One of the 34 base kinds used by shape calculations. Red fives normalize to their ordinary five. / 形状計算に使う34種の基底牌種です。赤5は同じスートの通常5へ正規化します。 | Numbered ranks are zero-based; honors follow east, south, west, north, white, green, red. / 数牌ランクは0始まり、字牌は東南西北白發中の順です。 | `MahjongDomain.Tile`, `MahjongDomain.Tile.index` |
| Red-aware tile identity | 赤牌区別付き牌種 | One of 37 identities: 34 normalized kinds plus separate red 5m, 5p, and 5s identities. / 正規化牌種34種に赤5萬・赤5筒・赤5索を加えた37種です。 | `Tile37.normalized` is a lossy projection to the 34-kind shape representation. / `Tile37.normalized`は34種の形状表現への情報損失を伴う射影です。 | `MahjongDomain.Tile37`, `Tile37.normalized`, `Tile37.index` |
| Terminal or honor | 么九牌 | The 1 and 9 of each suit and all seven honors: 13 distinct normalized kinds. / 各スートの1・9と字牌7種、計13牌種です。 | `orphanKinds` is an unordered, computable set; `orphanTiles` contains one of each. Neither defines a completed hand. / 集合に列挙順の契約はなく、`orphanTiles`は各種1枚です。完成形は定義しません。 | `Tile.IsTerminalOrHonor`, `orphanKinds`, `mem_orphanKinds`, `orphanTiles` |
| Tile display format | 牌の表示形式 | Ready-to-use rendering of a normalized tile as a Unicode Mahjong glyph or mpsz notation. / 正規化牌種をUnicode麻雀牌またはmpsz表記に変換する、すぐ使える表示形式です。 | Red fives are normalized, so their display does not retain aka identity. / 赤5は正規化されるため、表示でも赤の区別は保持されません。 | `MahjongDomain.TileFormat`, `MahjongDomain.Tile.format` |
| Tenhou ID | Tenhou ID | A protocol-specific code in Tenhou's 136-code ordering. It belongs at an input/output boundary, not in the normalized domain model. / Tenhouの136コード順における形式固有IDです。正規化ドメイン表現ではなく入出力境界で扱います。 | Copy zero of 5m, 5p, and 5s is the red five. / 5萬・5筒・5索のcopy 0を赤5とします。 | `MahjongDomain.TenhouId`, `MahjongDomain.TenhouId.decode`, `MahjongDomain.TenhouId.int37Index` |
| Int37 slot | Int37スロット | One input slot preserving red-five identity: red fives use 0, 10, 20; ordinary fives use 5, 15, 25; honors use 30–36. / 赤5を区別する入力スロット。赤5は0・10・20、通常5は5・15・25、字牌は30–36です。 | Suited slots are grouped by suit; indices 0, 10, and 20 are reserved for red fives. / 数牌は色ごとに並び、0・10・20は赤5専用です。 | `MahjongDomain.Int37Index`, `Int37Index.tile`, `Tile37.index`, `Tile37.ofIndex` |
| 37-kind counts | 37種カウント | Natural counts over red-aware tile identities. / 赤牌を区別した牌種ごとの自然数カウントです。 | Red fives have capacity 1, ordinary fives capacity 3, and other kinds capacity 4; aggregation preserves the four-copy base-kind limit. / 赤5は1枚、通常5は3枚、その他は4枚までで、集約後も基底牌種ごとに4枚を超えません。 | `Tile37Counts`, `Tile37Counts.Valid`, `Tile37Counts.normalized` |
| Int34 index and counts | Int34添字・カウント | A normalized index in `0..33` and signed counts over those indices, in the stable `Tile.index` order. / `Tile.index`と同じ安定順の正規化牌種`0..33`添字と、その添字ごとの符号付き枚数です。 | Red fives are merged with ordinary fives. The Tenhou adapter decodes and checks raw IDs before producing these counts. / 赤5は通常5へ統合します。Tenhouアダプターはカウント化の前に生IDの範囲と重複を検査します。 | `MahjongDomain.Int34Index`, `MahjongDomain.Int34Counts`, `Int34Counts.ofTenhou` |
| Count-based hand | カウント型手牌基底 | The hand-held tiles represented by normalized tile-kind counts. It is the shared base for consumer-specific hand states. / 正規化牌種カウントで表す手元牌。consumer固有の手牌状態が共有する基底です。 | It does not include fixed-meld contents or impose validity, tile-count, or hand-shape constraints. Use `TileCounts.Valid` and consumer-specific predicates where required. / 固定面子の内訳を含まず、妥当性・総枚数・手牌形状の制約も課しません。必要な場合は`TileCounts.Valid`およびconsumer固有述語を使います。 | `MahjongDomain.Hand`, `MahjongDomain.Hand.counts` |
| Red-aware hand snapshot | 赤牌区別付き牌姿 | Standing counts and fixed melds retain all 37 tile identities, including each meld's exact tile composition and call details. / 手元カウントと固定面子が、鳴き情報および面子内の牌構成とともに37種すべてを保持します。 | Meld order is ignored but multiplicity and red identity are retained. `FixedMeld.hasValidComposition` and `HandSnapshot.hasValidPhysicalCopies` check properties explicitly; construction does not validate them. / 面子順は無視しますが、多重度と赤牌の区別を保持します。面子構成と合算枚数は明示的な述語で検査し、構築時には検査しません。 | `HandSnapshot`, `FixedMeldShape`, `FixedMeld`, `HandSnapshot.Equivalent`, `HandSnapshot.same`, `HandSnapshot.occupiedCounts` |
| Tenhou conversion | Tenhou変換 | Decodes raw Tenhou codes and projects them to 37-kind, signed Int37, or normalized Int34 counts. / 生のTenhouコードをデコードし、37種・Int37・正規化Int34の各カウントへ射影します。 | Out-of-range and duplicate IDs are rejected; hand size is checked by the consumer that knows the hand context. / 範囲外と重複IDは拒否し、手牌枚数は文脈を知るconsumerが検査します。 | `MahjongDomain.TenhouId.decode`, `decodeTenhouIds`, `Tile37Counts.decodeTenhou`, `Int37Counts.decodeTenhou`, `Int34Counts.decodeTenhou` |
| Normalization | 正規化 | Maps a `Tile37` identity to the 34-kind shape used by calculations, merging red and ordinary fives. / `Tile37`を計算用の34種へ写し、赤5と通常5を統合します。 | This is a lossy projection; it does not preserve red-five identity. / 情報を失う射影で、赤5の区別は復元できません。 | `Tile37.normalized`, `Int37Index.tile`, `Tile37Counts.normalized` |
| Aggregation | 集約 | Sums signed Int37 counts over all slots that normalize to a given tile kind. / 正規化後に同じ牌種となる全スロットの符号付きカウントを合算します。 | Counts may be signed; nonnegativity is a client input-validity condition. / カウントは符号付きで、非負性は利用側の入力妥当性条件です。 | `MahjongDomain.Int37Counts`, `MahjongDomain.aggregateInt37` |
| Tile-kind capacity | 牌種容量 | Each normalized base kind has four physical copies. / 正規化後の各基底牌種は物理的に4枚です。 | In the 37-kind representation, red-five slots have capacity 1, ordinary-five slots 3, and others 4. / 37種表現では赤5枠は1、通常5枠は3、それ以外は4です。 | `copiesPerTile`, `TileCounts.Valid`, `TileCounts.CanAdd`, `Tile37.capacity`, `Int37Index.capacity` |
| Full-hand tile total | 牌姿全体の牌数 | A count vector has 13–18 tiles, the possible physical totals of a 13- or 14-tile-equivalent four-player hand. / カウントの総数が13〜18枚で、四人麻雀の13・14枚相当の牌姿における物理牌の総数の範囲です。 | This count condition alone does not establish a valid fixed-meld arrangement or a reachable position, and is not required of the hand-held component. / この枚数条件だけでは固定面子の構成可能性や到達可能性を保証せず、手元牌の部品に課す条件でもありません。 | `TileCounts.total`, `TileCounts.HasFullHandSize` |
| Count conservation | 枚数保存 | Aggregation preserves the signed total, distributes over pointwise addition, and maps per-slot capacities to four copies per kind. / 集約は符号付き総数を保ち、点ごとの加算に分配し、スロット容量を牌種ごとの4枚へ写します。 | Capacity bounds must hold for every Int37 slot. / 各Int37スロットで容量上限を満たす必要があります。 | `aggregateInt37_add`, `aggregateInt37_total`, `aggregateInt37_capacity` |
| Pair / head | 対子・雀頭 | Two copies of one tile kind; in a mentsu-hand decomposition exactly one pair is retained as the head. / 同一牌種2枚の組。面子手分解では1組を雀頭として保持します。 | A pair is distinct from a two-tile incomplete block and from seven-pairs structure. It can be selected from a `TileCounts` entry of at least two; the remaining counts reconstruct the original vector. / 搭子や七対子の対とは別の役割です。`TileCounts`で2枚以上ある牌種から選べ、残余カウントと合わせると元のベクトルを再構成できます。 | `Pair`, `Pair.tiles`, `Pair.remainingCounts`, `Pair.counts_eq_pair_add_remaining` |
| Shuntsu | 順子 | Three consecutive numbered tile kinds in one suit, with a starting rank from one through seven. / 同一スートの連続する数牌3種で、開始ランクは1から7です。 | Honors cannot be part of a sequence. / 字牌は順子に含まれません。 | `Shuntsu`, `Shuntsu.tiles` |
| Mentsu candidate | 面子候補 | One mentsu-hand triplet or suited sequence, each occupying three tiles. / 面子手の刻子または順子で、いずれも牌を3枚使います。 | A kan is not a mentsu-hand candidate. This is a shape, not a fixed/open meld state. / 槓は面子手候補ではありません。副露・固定状態ではなく牌種構成を表します。 | `MentsuCandidate`, `MentsuCandidate.tiles` |
| Kan occupancy | 槓占有 | The four tile copies occupied by a fixed kan, while the kan counts as one fixed meld at the client boundary. / 固定槓が占有する同一牌種4枚。利用側の面子数では1個です。 | Occupancy is separate from the mentsu-hand candidate type. / 面子手候補とは別の表現です。 | `Kan.occupiedTiles` |
| Mentsu-hand decomposition | 面子手分解 | One chosen pair and an ordered list of mentsu-hand candidates, preserving repeated equal candidates. / 選択した雀頭1組と順序付き面子候補リスト。同じ候補の反復も保持します。 | The represented count vector is defined by tile-kind multiplicity, not list order. / 対応するカウントは列順ではなく牌種ごとの多重度で定まります。 | `MentsuHandDecomposition`, `MentsuHandDecomposition.tiles`, `MentsuHandDecomposition.counts` |
| Mentsu-hand completion | 面子手完成仕様 | A witness-bearing mentsu-hand decomposition with exactly the requested number of melds and the specified tile-kind counts. / 指定数の面子を持ち、指定カウントに一致する証人付き面子手分解です。 | The decomposition witness is retained; distinct decompositions of equal counts are not collapsed. / 分解証人を保持し、同じカウントの異なる分解を潰しません。 | `MentsuHandCompletion`, `mentsuHandCompletion_iff_parts` |

`Pair.orderedTiles`, `Shuntsu.orderedTiles`, and `MentsuCandidate.orderedTiles`
are the canonical tile-kind lists for these parts; a sequence is ordered by
ascending rank. Their `tiles` multisets are obtained from those lists by
`Multiset.ofList`. The rank operations are `ShuntsuStart.firstRank`,
`middleRank`, and `lastRank`.

各部品の`orderedTiles`は共有牌種の列であり、順子はランク昇順です。`tiles`は
その列から`Multiset.ofList`で得ます。順子の各ランクは`ShuntsuStart`で得られます。

`Tile.suitedTiles` constructs an ordered suited list; `Tile.mem_all` proves the
shared enumeration is exhaustive. `TileCounts.ofList` counts a tile-kind list
and `MentsuCandidateList.counts_eq_list_count` relates ordered meld expansion
to its multiset counts.

`Tile.suitedTiles`は順序付き数牌列を構成し、`Tile.mem_all`は牌種列挙の網羅性を示します。
`TileCounts.ofList`は牌種列を数え、`MentsuCandidateList.counts_eq_list_count`は
面子の順序付き展開と多重集合の計数を対応させます。
`TileCounts.ofMultiset_sum_eq_card`は多重集合の牌数とカウント総数の一致、
`MentsuCandidateList.tiles_card`は反復を含む面子候補列の総牌数を保証します。
`TileCounts.valid_add_one_iff`は、全牌種が上限内で、加える牌種が上限未満である
ことと、加牌後も全牌種が上限内であることの同値を示します。どの牌を数えるかや
Int37の赤牌枠の検査は利用側の文脈によります。
