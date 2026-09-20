---
name: slide-deck
description: HTMLスライドを作る・直すときに使う。1ファイル完結・依存ゼロの閲覧用HTMLとして原稿を書き、版面のはみ出しを実測し、crit でレビューして仕上げる。「スライド」「プレゼン」「提案資料」「報告資料」「デッキ」「発表資料」を作る/直す/枚数を減らす/密度を上げる、と言われたとき、および既存のスライドHTMLの中身を書き換えるときに使う。ブラウザ上で人が直接編集したい、発表モードで見せたいときは slide-editor に渡す。
---

# スライドを作る（slide-deck）

受領者がそのまま開いて読める**閲覧用HTML 1ファイル**を作る。外部依存はゼロで、ダブルクリックで開き、印刷すれば PDF になる。
編集 UI と発表機能は持たない。人がブラウザ上で直したくなったら slide-editor に渡す。

## 成果物の構造

閲覧用HTMLは 3 つの部品でできている。**書き換えてよいのは原稿だけ。**

| 部品 | 中身 | 触ってよいか |
|---|---|---|
| `<style id="deck-style">` | 意匠層。マスター一式（色・余白・ブロックの体裁） | 触らない |
| `<div class="dm-deck" id="dmDeck">` | **原稿**。`<section class="slide">` の並び | ここだけを書く |
| `<script id="deck-layout">` | 束ね層。並べる・ページ番号を振る・画面幅に合わせて縮める | 触らない |

`<html>` のマスター・テーマ属性（`data-master` / `data-theme`）と `<title>` は変えてよい。
意匠そのものを変えたくなったら、成果物ではなく `assets/new.html` を直して作り直す。

## 使い方

1. `assets/new.html` を `slides/<name>/<name>.html` に複製する（置き場所は指定があればそちら）
2. `#dmDeck` の中に `<section class="slide">` を並べる。書き方に迷ったら見本 `assets/example.html`、仕様は `references/FORMAT.md`
3. 版面を実測する。**これは必ずやる**

   ```bash
   python3 scripts/audit-overflow.py slides/<name>/<name>.html
   ```

   マスターごとにはみ出したスライドと px が出る。はみ出しが残っている状態で次に進まない
4. crit でレビューする。既定はこの流れ

   ```bash
   crit slides/<name>/<name>.html            # 中身を行単位で見る
   crit preview slides/<name>/<name>.html    # 版面を描画したまま見る
   ```

   コメントが付いたら原稿を直し、`crit --session <id>` で次のラウンドへ。crit が入っていない場合や、
   人が直接いじりたいと言われた場合は slide-editor に渡す
5. 配布は HTML をそのまま渡すか、ブラウザの印刷で PDF にする

既存のスライドを直すときも、対象ファイルの `#dmDeck` の中だけを触る。

## スライドの骨格

```html
<section class="slide" data-layout="body" data-chapter="01 章名">
  <div class="s-tabs" data-block="tabs"><i class="on">第1部</i><i>第2部</i></div>
  <h2 class="s-title"><span class="n">01</span>スライドタイトル</h2>
  <div class="s-rule"></div>
  <div class="s-msg" data-block="msg">このスライドの主張を1行で。</div>
  <div class="s-main">
    …ブロックを並べる…
  </div>
  <div class="s-note"><b>出典</b> …　<b>※</b> …</div>
</section>
```

`s-tabs` `s-msg` `s-note` `s-logo` は任意。`s-main` の中身だけが本文。

## レイアウト（`data-layout`）8種

`cover` 表紙 ／ `agenda` 目次 ／ `section` 章扉 ／ `body` 標準 ／
`split` 2カラム ／ `visual` 図表全面 ／ `statement` 主張1枚 ／ `closing` 締め

`cover` `section` `statement` は見出しとリード（`.s-kicker` `.s-title` `.s-lead` `.s-meta`）だけで組む。
`body` `split` `visual` は `.s-main` にブロックを入れる。

## ブロック（`data-block`）

いずれも `<div data-block="…">` でくるむ。中の構造は決まっている。

| 値 | 中身 |
|---|---|
| `heading` | `<h3>` 小見出し |
| `text` | `<p>` 段落 |
| `list` | `<ul>` / `<ol>`（番号付きも `data-block="list"`） |
| `note` `warn` `key` | `.note` / `.warnbox` / `.keybox`。中に `<span class="lbl">見出し</span>` と `<p>` |
| `table` | `.tw > table`。`<table class="compact">` で詰まる |
| `steps` | `.steps > .step`（`.sn` ＋ `<div><h4>…</h4><p>…</p></div>`） |
| `cards` | `.cards > .card`（`.pn` `.pt` `.pd`）。`style="--n: 3"` で列数 |
| `kpi` | `.kpis > .kpi`（`.kl` `.kv` `.kn`）。`data-tone="warn\|alarm\|plain"` |
| `qa` | `.qa > .q` + `.a` |
| `figure` | `figure > .figbox`（インラインSVGか画像）+ `figcaption` |
| `flow` | `.flow > .fl-node` と `.fl-arrow`（矢印はインラインSVG） |
| `bars` | `.bars > .bar`（`.bl` `.bt[style="--w: 60%"]` `.bv`） |
| `stack` | `.stack > .st-row`（`.st-k` `.st-b` `.st-n`）。所与の層と決める層を分ける |
| `chain` | `.chain > .ch-cell` と `.ch-link`。日をまたぐ鎖 |
| `roadmap` | 年度×ワークストリームの工程表。**後述の専用節を読むこと** |
| `embed` | `.embed[data-ew] > iframe[srcdoc]`。既存の自己完結HTMLアプリをそのまま載せる |
| `code` `quote` `spacer` | 見たとおり |

2カラムは `.s-cols > .s-col`（`style="--split: 1.3fr 1fr"` で配分）。
ブロックではなく素の入れ物なので `.s-main` の直下に置いてよい。

## インライン装飾

`<strong>` 強調 ／ `<span class="ok">` 良 ／ `<span class="mid">` 注意 ／
`<span class="ng">` 否 ／ `<code>` 識別子 ／ `<td class="num-cell">` 数値（右寄せ・等幅）

## マスター（`<html data-master="…">`）3種

| 値 | 用途 |
|---|---|
| `report` | **既定。** 読み物寄り。余白を広めに取り、文章主体の資料向け |
| `jtc` | **1枚に詰めたいとき**。本文18.5px（14pt相当）のまま余白・行間・表を詰める |
| `mono` | 投影・白黒印刷。黒＋朱の1色、罫のみ |

構造は共通なので、同じ原稿のまま意匠だけ差し替わる。
ただし**書体と基準サイズが変わるので版面は動く**。`jtc` 前提の原稿は他マスターではまず収まらない。

## 版面の確認（必ずやる）

スライドは 1280×720 で `overflow: hidden`。**はみ出しても画面上は静かに切れる**ので、書いたら必ず測る。

```bash
python3 scripts/audit-overflow.py <閲覧用HTML>
```

ヘッドレスブラウザで開いて実測し、マスターごとに `<n>枚目 +<px>` を出す。**すべて OK になるまで直す。**
はみ出したら、文章を締める → `data-density="tight"` を足す → それでも駄目ならスライドを分割する。

## 工程表（`roadmap`）の書き方

年度 × ワークストリームの工程表。**横位置はすべて「列番号」で指定する。**
ピクセルも日付も書かない。これが書ければ、あとは機械的に組める。

### 手順

**① 総列数を決める。** 20〜28 が扱いやすい。年度ごとの列数は重要度で変える。
検討が集中する年度は他の2〜3倍の幅を取ると、実物の資料の見た目に近くなる。

```
FY2025 → 4列 (1..5)    FY2026 → 10列 (5..15)   ← 重点年度なので広い
FY2027 → 4列 (15..19)  FY2028 → 2列 (19..21)   FY2029 → 2列  FY2030 → 2列
総列数 24（--cols: 24、最後の --b は 25）
```

**② `--a`（開始列）と `--b`（終了列）を書く。** `--b` は**その手前まで**を意味する
（CSS Grid の流儀）。`--a:5; --b:15` なら5列目から14列目まで。

**③ 塗り分けを選ぶ。**

| `data-tone` | 見え方 | 使いどころ |
|---|---|---|
| （なし） | 白地＋濃色の枠、右が矢じり | 確定している作業。既定はこれ |
| `hi` | 黄色く塗る | いま進めている／重点の作業 |
| `plan` | 破線の枠、矢じりも破線 | 未確定・構想段階 |
| `fill` | 濃色でベタ塗り、白抜き文字 | 到達点、本格運用 |
| `open` | 矢じりなしの箱 | 「★使用開始」のような節目の宣言 |

### 骨格

```html
<div data-block="roadmap">
  <div class="rm" style="--cols: 24; --lw: 74px;">

    <!-- 年度ヘッダ -->
    <div class="rm-row">
      <div class="rm-lab"></div>
      <div class="rm-track">
        <div class="rm-y" style="--a:1; --b:5">FY2025</div>
        <div class="rm-y" style="--a:5; --b:15">FY2026</div>
      </div>
    </div>

    <!-- マイルストン。--w は横幅（列数）、既定3 -->
    <div class="rm-row">
      <div class="rm-lab">マイルストン</div>
      <div class="rm-track">
        <div class="rm-m" style="--a:1; --w:3"><b>部会</b><i>2026.1</i></div>
        <div class="rm-m" data-tone="key" style="--a:10; --w:3"><b>意思決定</b><i>2026.9</i></div>
      </div>
    </div>

    <!-- グループ（縦書きラベル＋複数行） -->
    <div class="rm-sec">
      <div class="rm-lab rm-lab--v">全体像</div>
      <div class="rm-sec-body">
        <div class="rm-row"><div class="rm-track">
          <div class="rm-bar" data-tone="hi" style="--a:1; --b:6"><span><b>①対象項目の検討</b></span></div>
          <div class="rm-bar" style="--a:6; --b:15"><span><b>②設計</b><i>補足は小さく添える</i></span></div>
          <div class="rm-bar" data-tone="plan" style="--a:15; --b:25"><span><b>③展開</b></span></div>
        </div></div>
        <div class="rm-row"><div class="rm-track"> … 2行目 … </div></div>
      </div>
    </div>

  </div>
</div>
```

### 決まりごと

- バーの中身は必ず `<span>` で包む。`<b>` が主題、`<i>` が小さい補足（省略可）
- `.rm-sec-body` の中の `.rm-row` は**ラベル列を書かない**（自動で消える）
- 3階層にしたいときは `.rm-sec-body` の中にもう1つ `.rm-sec` を入れ子にする
- マイルストンの `data-tone="key"` は**1枚に1つだけ**。赤で出るので、複数付けると効かなくなる
- 1行に詰め込むバーは3〜4本まで。それ以上は文字が読めなくなるので行を分ける

### よくある失敗

- **`--b` を「最終列」と勘違いする。** `--b` は終端の1つ先。最後まで伸ばすなら「総列数＋1」
- **年度を均等幅にしてしまう。** 重点年度を広く取らないと、細かい工程が潰れる
- **`hi` を多用する。** 重点が全部になると何も強調されない。1〜3本に絞る

## 第一原則：1枚に詰める

**枚数を増やす前に、1枚に収まらないかを必ず考える。** 関連する内容が同じ1枚に
載っているほうが、読む側は全体を掴みやすい。

- 関連する論点は同じスライドにまとめる。2カラム・3カラムを恐れない
- 章扉や主張だけのスライドは、よほど転換点でない限り作らない
- **ただし文字は14pt相当（18.5px）を下回らせない。** 下回るくらいなら分割する
- 目安：本文のブロックが2〜3個しかない `body` スライドは、隣と統合できないか疑う

## 見た目の原則（重要）

**生成AIらしい見た目にしないこと。** 直角・細罫・影なしを既定にしてある。

- **色は青に集約する。** 見出し・罫・肯定（`.ok`）はアクセントの青、保留（`.mid`）は
  落ち着いた青。**赤（`.ng`）は、はっきり否定・警告するときだけ**。緑・褐色・黄は使わない
- **箱は白地・ほぼ直角・全辺同じ細罫・影なし。** 淡色のベタ塗りで塗り分けない。
  **左端だけ太い罫を引かない**（Webアプリのアラート表現であって、スライドの作法ではない）
- **要素どうしの隙間は詰める。** CSSが既定で詰めてあるので、余白を足さない
- **色は罫と文字にだけ使う。** 面を色で塗るのは `fill` 指定のバーや章扉など、意図がある場所だけ
- `note` / `warn` / `key` の違いは左端の罫の色で出る。CSSが面倒を見るので、
  マークアップ側で色を足さない
- 角丸・影・グラデーションを自前で足さない。マスターが決めた見え方から外れる

## 書くときの原則

- **0手目で本題が見えていること。** 表紙・章扉・主張スライドの見出しを隠さない
- **数字には出典を添える。** 仮置きの数字と、出典のある数字を `.s-note` で明示的に分ける
- 図はまず `flow` `bars` `stack` `chain` で組めないか考える。SVGは折れ線や曲線が要るときだけ

## 踏みやすい落とし穴

- 反転スライド（章扉など）の背景は**実色で書く**。同じ規則の中で `--accent` を再定義すると
  `background: var(--accent)` が新しい値で解決され、地と文字が同色になって白飛びする
- `.s-cols` を `body` レイアウトの途中に置くとき、高さを 100% にしない。後ろのブロックが版面の外へ出る
- `figure` は素のブロックなので、`visual` レイアウトで伸縮させたいときは flex を通す必要がある
- 埋め込み（`embed`）は `data-ew` に論理幅だけ書けば、高さは束ね層が実測して合わせる
