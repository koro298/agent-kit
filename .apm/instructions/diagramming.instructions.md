---
applyTo: "**/*.drawio, **/*.drawio.svg, **/*.mmd, **/*.excalidraw"
description: 作図(draw.io / Excalidraw)を行うときの生成物の形式と実行手順
---

# 作図の規約

- 生成物は `.drawio.svg`(描画済み SVG に draw.io XML を埋め込んだファイル)に統一する。XML だけの `.drawio` と Mermaid の `.mmd` は中間物とし、成果物として残さない。
- Excalidraw(`.excalidraw`)は、ユーザーが明示的に Excalidraw を求めたときだけ使う。
- 書き出しは draw.io スキルの二段方式に従う。
  - Mermaid で書いた場合: `drawio -x -f xml -o <name>.drawio <name>.mmd` で先に `.drawio` へ変換する。`.mmd` から直接 `-e` 付きで画像に書き出さない。
  - `.drawio` から `drawio -x -f svg -e -b 10 -o <name>.drawio.svg <name>.drawio` で書き出す。
- Linux で環境変数 `DISPLAY` が無い(ヘッドレス)ときは、`drawio` の各呼び出しを `xvfb-run -a` で包む。例: `xvfb-run -a drawio -x -f svg -e -b 10 -o out.drawio.svg in.drawio`。
- 配色・粒度・命名などの作図規約は本書では定めない。
