#!/usr/bin/env bash
# agent-kit を使うホストの初期化。何度実行しても安全(冪等)。
# 導入するもの: apm CLI、crit CLI と Claude Code / Codex 用プラグイン、draw.io Desktop(Linux では xvfb も)。
# 途中で失敗しても残りの導入は続け、最後に未完了をまとめて報告する。
set -uo pipefail

OS="$(uname -s)"
FAILED=()
log()  { printf '\n== %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
fail() { FAILED+=("$1"); printf '警告: %s\n' "$1" >&2; }

# ---- 1. apm ----------------------------------------------------------------
log "apm"
if have apm; then
  echo "apm 既存: $(apm --version)"
  APM_BIN="$(command -v apm)"
  APM_REAL="$(readlink -f "$APM_BIN")"
  if have pipx && pipx list 2>/dev/null | grep -q 'package apm-cli'; then
    pipx upgrade apm-cli >/dev/null || fail "apm の更新(pipx)に失敗"
  elif [[ "$OS" == "Darwin" ]] && have brew && brew list apm >/dev/null 2>&1; then
    brew upgrade apm >/dev/null || fail "apm の更新(brew)に失敗"
  elif [[ "$APM_REAL" == "$HOME"/* ]]; then
    curl -sSL https://aka.ms/apm-unix | sh || fail "apm の更新に失敗"
  else
    # ホーム外(root 権限)の導入はインストーラが上書きを拒む。手で入れ直すしかない
    fail "apm が $APM_REAL にある。インストーラは上書きを拒否するので次で入れ直す: sudo rm -rf ${APM_REAL%/*} $APM_BIN && curl -sSL https://aka.ms/apm-unix | sh"
  fi
elif [[ "$OS" == "Darwin" ]] && have brew; then
  brew install apm || fail "apm の導入に失敗"
else
  curl -sSL https://aka.ms/apm-unix | sh || fail "apm の導入に失敗"
fi
have apm && apm --version || fail "apm が PATH に無い"

# ---- 2. crit と両ツールのプラグイン ------------------------------------------
log "crit"
if ! have crit; then
  if [[ "$OS" == "Darwin" ]] && have brew; then
    brew install crit || fail "crit の導入(brew)に失敗"
  elif have go; then
    go install github.com/tomasz-tomczyk/crit/cmd/crit@latest || fail "crit の導入(go)に失敗"
  else
    fail "crit を導入できない(brew か go が要る)"
  fi
fi
have crit && crit --version

if have crit && have claude; then
  if claude plugin list 2>/dev/null | grep -q 'crit@crit'; then
    echo "Claude Code の crit プラグイン 既存"
  else
    claude plugin marketplace add tomasz-tomczyk/crit >/dev/null 2>&1 || true
    claude plugin install crit@crit || fail "Claude Code の crit プラグイン導入に失敗"
  fi
elif ! have claude; then
  fail "claude CLI が無いため Claude Code 側の crit プラグインを入れていない"
fi

if have crit && [[ -d "$HOME/.codex" ]]; then
  if [[ -f "$HOME/.codex/plugins/crit/.codex-plugin/plugin.json" ]]; then
    echo "Codex の crit プラグイン 既存"
  else
    ( cd "$HOME" && crit install codex-plugin ) || fail "Codex の crit プラグイン導入に失敗"
  fi
  # crit install codex-plugin の副産物(loose skill)。プラグインと二重に見えるので除く
  rm -rf "$HOME/.agents/skills/crit" "$HOME/.agents/skills/crit-cli"
fi

# ---- 3. draw.io Desktop(CLI) -----------------------------------------------
log "draw.io Desktop"
if [[ "$OS" == "Darwin" ]]; then
  if [[ -d /Applications/draw.io.app ]]; then
    echo "draw.io 既存"
  elif have brew; then
    brew install --cask drawio || fail "draw.io の導入(brew cask)に失敗"
  else
    fail "draw.io を導入できない(brew が要る)"
  fi
  # brew の cask は /opt/homebrew/bin/drawio を作る。無い場合だけ ~/.local/bin に置く
  if ! have drawio && [[ -x /Applications/draw.io.app/Contents/MacOS/draw.io ]] && [[ ! -e "$HOME/.local/bin/drawio" ]]; then
    mkdir -p "$HOME/.local/bin"
    ln -s /Applications/draw.io.app/Contents/MacOS/draw.io "$HOME/.local/bin/drawio"
    echo "~/.local/bin/drawio を作成(PATH に ~/.local/bin が必要)"
  fi
  drawio --version >/dev/null 2>&1 && echo "drawio CLI OK" || fail "drawio コマンドが PATH に無い"
elif [[ "$OS" == "Linux" ]]; then
  if have drawio; then
    echo "draw.io 既存"
  else
    ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"
    TAG="$(curl -fsSL https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | sed -n 's/.*"tag_name": *"\(v[^"]*\)".*/\1/p')"
    if [[ -z "$TAG" ]]; then
      fail "draw.io の最新リリースを取得できない"
    else
      VER="${TAG#v}"
      TMP="$(mktemp -d)"
      if curl -fsSLo "$TMP/drawio.deb" "https://github.com/jgraph/drawio-desktop/releases/download/${TAG}/drawio-${ARCH}-${VER}.deb"; then
        sudo apt-get update -qq && sudo apt-get install -y "$TMP/drawio.deb" xvfb || fail "draw.io の導入(apt)に失敗"
      else
        fail "draw.io のダウンロードに失敗(${TAG}/${ARCH})"
      fi
      rm -rf "$TMP"
    fi
  fi
  have xvfb-run || sudo apt-get install -y xvfb || fail "xvfb の導入に失敗"
  if have drawio; then
    xvfb-run -a drawio --version >/dev/null 2>&1 \
      && echo "drawio CLI(xvfb)OK" \
      || fail "ヘッドレスで drawio を起動できない(--no-sandbox / --disable-gpu を検討)"
  fi
fi

# ---- 4. 結果 ----------------------------------------------------------------
if ((${#FAILED[@]})); then
  log "未完了 ${#FAILED[@]} 件"
  printf ' - %s\n' "${FAILED[@]}"
  echo
  echo "解消してから再実行する。完了した分は再実行しても壊れない。"
  exit 1
fi

log "完了。プロジェクトへの導入は README の手順 B へ"
