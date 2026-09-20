#!/usr/bin/env python3
"""閲覧用HTMLの版面はみ出しを測る。

ヘッドレスブラウザで開き、各スライドが本文領域から何 px はみ出しているかを
論理px(1280×720 基準)で報告する。はみ出しが 1 件でもあれば終了コード 1。

    python3 audit-overflow.py <閲覧用HTML> [master ...]

master を省くと report / jtc / mono の 3 種すべてで測る。
"""

import base64
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

CHROME_CANDIDATES = [
    "google-chrome", "google-chrome-stable", "chromium", "chromium-browser",
    "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe",
    "/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
]

AUDIT_JS = """
<script id="deck-audit">
(function () {
  var MASTERS = __MASTERS__;
  var root = document.documentElement, stage = document.getElementById('dmStage');
  function measure() {
    var z = parseFloat(getComputedStyle(stage).getPropertyValue('--s')) || 1;
    return [].slice.call(document.querySelectorAll('#dmDeck > .dm-holder')).map(function (h) {
      var s = h.querySelector('.slide');
      if (!s) return 0;
      var m = s.querySelector('.s-main') || s;
      var bottom = m.getBoundingClientRect().bottom, worst = 0;
      [].slice.call(m.querySelectorAll('*')).forEach(function (el) {
        var b = el.getBoundingClientRect();
        if (!b.height && !b.width) return;
        var d = b.bottom - bottom;
        if (d > worst) worst = d;
      });
      return Math.round(worst / z);
    });
  }
  var keep = root.dataset.master || 'report', out = {};
  MASTERS.forEach(function (id) {
    root.dataset.master = id;
    out[id] = measure()
      .map(function (v, i) { return { i: i + 1, over: v }; })
      .filter(function (x) { return x.over > 1; });
  });
  root.dataset.master = keep;
  document.title = 'AUDIT:' + btoa(unescape(encodeURIComponent(JSON.stringify(out))));
})();
</script>
"""


def find_chrome() -> str:
    for cand in CHROME_CANDIDATES:
        path = shutil.which(cand) if not cand.startswith("/") else (cand if os.access(cand, os.X_OK) else None)
        if path:
            return path
    sys.exit("ヘッドレスで動かせるブラウザが見つかりません(chrome / chromium / WSL の chrome.exe)")


def to_url(path: str, chrome: str) -> tuple[str, str | None]:
    """Windows 側の Chrome を使うときは Windows から見えるパスへ写す。"""
    if not chrome.startswith("/mnt/c/"):
        return "file://" + os.path.abspath(path), None
    dest_dir = "/mnt/c/Users/%s/AppData/Local/Temp/deck-audit" % os.environ.get("USER", "Public")
    os.makedirs(dest_dir, exist_ok=True)
    dest = os.path.join(dest_dir, "audit.html")
    shutil.copy(path, dest)
    win = subprocess.run(["wslpath", "-w", dest], capture_output=True, text=True).stdout.strip()
    return "file:///" + win.replace("\\", "/"), dest_dir


def main() -> int:
    if len(sys.argv) < 2 or not os.path.isfile(sys.argv[1]):
        sys.exit("使い方: audit-overflow.py <閲覧用HTML> [master ...]")
    target = sys.argv[1]
    masters = sys.argv[2:] or ["report", "jtc", "mono"]

    html = open(target, encoding="utf-8").read()
    if "dmDeck" not in html or "dmStage" not in html:
        sys.exit("対象が閲覧用HTMLではありません(#dmDeck と #dmStage が要ります)")
    injected = html.replace("</body>", AUDIT_JS.replace("__MASTERS__", json.dumps(masters)) + "</body>", 1)

    chrome = find_chrome()
    with tempfile.TemporaryDirectory() as tmp:
        tmp_html = os.path.join(tmp, "audit.html")
        open(tmp_html, "w", encoding="utf-8").write(injected)
        url, cleanup = to_url(tmp_html, chrome)
        proc = subprocess.run(
            [chrome, "--headless=new", "--disable-gpu", "--hide-scrollbars",
             "--window-size=1400,900", "--virtual-time-budget=8000", "--dump-dom", url],
            capture_output=True, text=True, timeout=180,
        )
        if cleanup:
            shutil.rmtree(cleanup, ignore_errors=True)

    m = re.search(r"<title>AUDIT:([A-Za-z0-9+/=]*)</title>", proc.stdout)
    if not m:
        sys.exit("計測できませんでした。ブラウザがページを描画できているか確認してください。")
    result = json.loads(base64.b64decode(m.group(1)).decode("utf-8"))

    ng = 0
    for master, items in result.items():
        if not items:
            print(f"{master:8} OK")
            continue
        ng += len(items)
        detail = "、".join(f"{x['i']}枚目 +{x['over']}px" for x in items)
        print(f"{master:8} はみ出し {len(items)}件  {detail}")
    if ng:
        print("\n文章を締める → data-density=\"tight\" を足す → それでも収まらなければスライドを分ける。")
    return 1 if ng else 0


if __name__ == "__main__":
    sys.exit(main())
