# agent-kit

Claude Code と Codex に配る自作スキル・自作ルール・採用した市中スキルを 1 か所で管理する APM(microsoft/apm)パッケージ。プロジェクトは `apm.yml` にこのリポジトリを 1 行書いて `apm install` すると、両ツールのネイティブな場所に同じ内容が配置される。

- 収容品目

| 品目 | 種別 | 実体 |
|---|---|---|
| desk-loop | 自作スキル | `.apm/skills/desk-loop/` |
| smart-commit | 自作スキル | `.apm/skills/smart-commit/` |
| deck(HTML スライド) | 自作スキル | `.apm/skills/deck/` |
| doc-style | 自作ルール(全ファイル) | `.apm/instructions/doc-style.instructions.md` |
| python-coding | 自作ルール(`**/*.py`、`pyproject.toml`) | `.apm/instructions/python-coding.instructions.md` |
| diagramming | 自作ルール(作図ファイル) | `.apm/instructions/diagramming.instructions.md` |
| drawio | 市中スキル | `apm.yml` の依存(jgraph/drawio-mcp、SHA ピン) |
| excalidraw-diagram-generator | 市中スキル | `apm.yml` の依存(github/awesome-copilot、SHA ピン) |
| skill-creator | 市中スキル | `apm.yml` の依存(anthropics/skills、SHA ピン) |

- 配置先(プロジェクトで `apm install` したとき)

| 品目 | Claude Code | Codex |
|---|---|---|
| スキル | `.claude/skills/<name>/` | `.agents/skills/<name>/` |
| ルール | `.claude/rules/<name>.md` | `AGENTS.md`(`apm compile` で生成) |

- A. ホストの初期化(1 回)。apm、crit と両ツールのプラグイン、draw.io Desktop(Linux は xvfb も)を入れる。`host.sh` は自己完結しているので取得方法は問わない。例として clone して実行する。非公開のまま運用する場合は、先に GitHub の認証(`gh auth login` か SSH 鍵、または credential helper)を済ませる。手順 B の `apm install` も同じ認証を使う。

```bash
git clone https://github.com/koro298/agent-kit.git ~/Workspace/agent-kit
bash ~/Workspace/agent-kit/bootstrap/host.sh
```

- B. プロジェクトへの導入。プロジェクト直下に `apm.yml` を次の内容で作り(`<project>` を書き換える)、install する。

```yaml
name: <project>
version: 0.1.0
description: <project> のエージェント設定
targets:
  - claude
  - codex
dependencies:
  apm:
    - koro298/agent-kit#^1.0.0
  mcp: []
includes: auto
```

```bash
apm install && apm compile
git add apm.yml apm.lock.yaml .claude .agents AGENTS.md .gitignore && git commit -m "chore: agent-kit を導入"
```

  - `apm_modules/` は自動で `.gitignore` に入る。配置先ディレクトリと lock はコミットする。
  - 既に手書きの `AGENTS.md` がある場合、compile は上書きしない。手書き分を `.apm/instructions/<name>.instructions.md` に移す。

- C. プロジェクトの更新

```bash
apm outdated                          # 新しいタグが出ているか見る
apm install --update && apm compile   # レンジに合う最新タグへ解決し直す(apm.yml は触らない)
```

  - メジャーを上げたときだけ `apm.yml` の `#^2.0.0` への書き換えが要る。
