# Shared domain across the workspace / workspaceでのドメイン共有

この文書は、`mahjong-domain-core`、`mahjong-formalization`、`shanten`を
別々のGitリポジトリとして保ちながら、共有ドメインを共同で開発する方法と
その利点を説明します。共有用語の定義そのものは
[`GLOSSARY.md`](GLOSSARY.md)を参照してください。

## 得られること

### 用語をコードと証明に結び付ける

共有するのは名前や説明文だけではありません。牌種、正規化、牌数集約、
対子、面子、槓占有、通常形分解などをcoreの型・関数・述語として一度定義し、
それらの性質をLeanで証明します。利用側は同じ宣言をimportできるため、
同じ言葉に別の意味を与えたり、同じ基本構造を独立に実装してずれたりする
リスクを減らせます。用語と宣言の対応、適用範囲、前提は用語集を正本とします。

### 定義とアルゴリズムの責務を分ける

coreには複数のプロジェクトが必要とする安定したドメイン部品を置きます。
待ち分類・分解分類は`mahjong-formalization`に、向聴数の探索と評価は
`shanten`に残します。これにより、共通の数学的対象は共有しつつ、各プロジェクト
固有の問題設定、公開API、計算方法はそれぞれ独立して進化できます。

### 移行中の型も対応関係を明示できる

利用側が既存の型やAPIをすぐに捨てる必要はありません。各プロジェクトの
ローカルな型からcoreの型への変換をadapterに集め、往復変換や牌数保存などの
対応を定理として示せます。たとえば両consumerは既存の牌表現を保ちながら
coreの牌表現へ接続し、`mahjong-formalization`は牌・対子・面子の対応を、
`shanten`は牌・面子・標準形完成仕様との対応を検証します。
この境界により、共有部品を段階的に導入できます。

## workspaceの構成

各リポジトリは独立したGit履歴、Lean package、依存マニフェストを保ちます。
VS Codeのmulti-root workspaceは3つを一度に開くためのもので、単一のGit
リポジトリや単一のLake packageに統合するものではありません。

```text
mahjong/
├── mahjong.code-workspace
├── mahjong-domain-core/
├── mahjong-formalization/
└── shanten/
```

両consumerの`lakefile.lean`は、Lakeのpath dependencyとして
`../mahjong-domain-core`を指定しています。したがって、consumerのLake環境で
`MahjongDomain`をimportすると、公開・バージョン取得を待たずに隣のcheckoutの
ソースが使われます。coreの変更を保存してconsumerをビルドすれば、その変更を
同じ開発環境で直ちに検証できます。`lake-manifest.json`にもこの依存はpath
として記録されます。

## 開発手順

1. 3つのリポジトリを同じ親ディレクトリにcloneします。
2. 親ディレクトリの`mahjong.code-workspace`をVS Codeで開きます。
3. 共有対象が複数consumerで使えるドメイン概念かを確認し、そうであればcoreに
   定義と必要な性質を追加します。プロジェクト固有の用語やアルゴリズムは
   consumerに残します。
4. consumer側では`MahjongDomain`の公開moduleをimportし、必要なら既存型との
   adapterと対応定理を追加します。意味の差や前提は隠さず、consumerの文書に
   記します。
5. 各packageのルートでビルドします。

```sh
# mahjong-domain-core/
MATHLIB_NO_CACHE_ON_UPDATE=1 lake build

# mahjong-formalization/
lake build

# shanten/
lake build
```

core、各consumerは別々にcommit・review・releaseできます。共有APIを変える場合は、
coreだけでなく両consumerのビルドと対応定理も確認してください。path dependencyは
ローカルcheckoutを直接使うため、CIや配布時には検証したcoreとconsumerのcommit
の組み合わせを明示して再現性を確保します。Leanとmathlibの版は各packageの
toolchain・Lake設定で揃えます。

## 共有範囲の判断

- 牌の同一性、牌数、共通部品、標準形のように、複数consumerで意味が変わらない
  対象はcoreで定義します。
- 待ち、向聴数、探索戦略、分類キーなど、consumerごとの目的や前提に依存する
  対象はconsumerに置きます。
- client固有の語彙やcoreとの相違は各consumerの文書に書き、coreの共通定義を
  コピーせず[`GLOSSARY.md`](GLOSSARY.md)へリンクします。
- coreの公開範囲は必要な共通概念に絞り、利用側の実装詳細をcoreへ逆流させません。

この分割によって、語彙・データ構造・数学的仕様は共有しながら、各研究・計算
プロジェクトの独立性を保てます。
