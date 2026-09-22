#!/usr/bin/env pwsh
# agent-kit を使うホスト(Windows)の初期化。何度実行しても安全(冪等)。
# 導入するもの: apm CLI、crit CLI と Claude Code / Codex 用プラグイン、draw.io Desktop と drawio シム。
# 途中で失敗しても残りの導入は続け、最後に未完了をまとめて報告する。
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'   # Invoke-WebRequest の進捗表示は遅いので切る
$global:LASTEXITCODE = 0                   # StrictMode 下で未設定参照にならないようにする

$script:Failed = @()
function Log  { param([string]$Message) Write-Host "`n== $Message" }
function Have { param([string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }
function Fail { param([string]$Message) $script:Failed += $Message; Write-Warning $Message }

# winget などで入れた直後は現プロセスの PATH に載らないので、登録簿から引き直す
function Sync-Path {
  $parts = @(
    [Environment]::GetEnvironmentVariable('Path', 'Machine')
    [Environment]::GetEnvironmentVariable('Path', 'User')
  ) | Where-Object { $_ }
  $env:Path = $parts -join ';'
}

# 公式インストーラは StrictMode 下だと動かないことがあるので、別プロセスに逃がす
$PwshExe = (Get-Process -Id $PID).Path
function Install-ApmStandalone {
  # Out-Host を挟まないとインストーラの出力が戻り値に化けて、画面にも出ず判定も壊れる
  & $PwshExe -NoProfile -Command 'Invoke-RestMethod https://aka.ms/apm-windows | Invoke-Expression' 2>&1 | Out-Host
  if ($LASTEXITCODE -ne 0) { return $false }
  Sync-Path
  return [bool](Get-Command apm -ErrorAction SilentlyContinue)
}

$LocalBin = Join-Path $HOME '.local\bin'
function Initialize-LocalBin {
  New-Item -ItemType Directory -Force -Path $LocalBin | Out-Null
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (-not $userPath) { $userPath = '' }
  if (($userPath -split ';') -notcontains $LocalBin) {
    [Environment]::SetEnvironmentVariable('Path', ($LocalBin, $userPath | Where-Object { $_ }) -join ';', 'User')
    Write-Host "ユーザー PATH に $LocalBin を追加(反映は新しいシェルから)"
  }
  if (($env:Path -split ';') -notcontains $LocalBin) { $env:Path = "$LocalBin;$env:Path" }
}

# ---- 1. apm ----------------------------------------------------------------
Log 'apm'
if (Have apm) {
  $apmSource = (Get-Command apm).Source
  Write-Host "apm 既存: $(apm --version)"
  if ((Have pipx) -and ((pipx list 2>$null | Out-String) -match 'package apm-cli')) {
    pipx upgrade apm-cli *> $null
    if ($LASTEXITCODE -ne 0) { Fail 'apm の更新(pipx)に失敗' }
  } elseif ((Have winget) -and ((winget list --id Microsoft.APM --exact --source winget 2>$null | Out-String) -match 'Microsoft\.APM')) {
    winget upgrade --id Microsoft.APM --exact --source winget --accept-source-agreements --accept-package-agreements
    # 0x8A15002B は「適用できる更新が無い」。最新なだけなので失敗扱いしない
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne -1978335189) { Fail 'apm の更新(winget)に失敗' }
  } elseif ($apmSource.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase)) {
    # apm self-update は staged した exe の実行確認で落ちることがある。インストーラを直接叩けば通る
    if (-not (Install-ApmStandalone)) { Fail 'apm の更新(インストーラ)に失敗' }
  } else {
    # ホーム外(管理者権限)の導入はインストーラが上書きを拒む。手で入れ直すしかない
    Fail "apm が $apmSource にある。インストーラは上書きを拒否するので、消してから次で入れ直す: irm https://aka.ms/apm-windows | iex"
  }
} else {
  $installed = $false
  if (Have winget) {
    winget install --id Microsoft.APM --exact --source winget --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) { Sync-Path; $installed = Have apm }
  }
  if (-not $installed) { $installed = Install-ApmStandalone }
  if (-not $installed) { Fail 'apm の導入に失敗' }
}
if (Have apm) { apm --version } else { Fail 'apm が PATH に無い' }

# ---- 2. crit と両ツールのプラグイン ------------------------------------------
Log 'crit'
Initialize-LocalBin
# Windows は公式リリースに単体バイナリがあるので、Go を入れずにそれを使う
if (-not (Have crit)) {
  $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'amd64' }
  $asset = "crit-windows-$arch.exe"
  $url = $null
  try {
    $release = Invoke-RestMethod 'https://api.github.com/repos/tomasz-tomczyk/crit/releases/latest' -Headers @{ 'User-Agent' = 'agent-kit' }
    $url = ($release.assets | Where-Object { $_.name -eq $asset }).browser_download_url
  } catch { $url = $null }
  if (-not $url) {
    Fail "crit の最新リリース($asset)を取得できない"
  } else {
    try {
      Invoke-WebRequest $url -OutFile (Join-Path $LocalBin 'crit.exe')
      Write-Host "crit 導入: $LocalBin\crit.exe"
    } catch { Fail "crit のダウンロードに失敗($asset)" }
  }
}
if (Have crit) { crit --version } else { Fail 'crit が PATH に無い' }

if ((Have crit) -and (Have claude)) {
  if ((claude plugin list 2>$null | Out-String) -match 'crit@crit') {
    Write-Host 'Claude Code の crit プラグイン 既存'
  } else {
    claude plugin marketplace add tomasz-tomczyk/crit *> $null
    claude plugin install crit@crit
    if ($LASTEXITCODE -ne 0) { Fail 'Claude Code の crit プラグイン導入に失敗' }
  }
} elseif (-not (Have claude)) {
  Fail 'claude CLI が無いため Claude Code 側の crit プラグインを入れていない'
}

$CodexHome = Join-Path $HOME '.codex'
if ((Have crit) -and (Test-Path $CodexHome)) {
  if (Test-Path (Join-Path $CodexHome 'plugins\crit\.codex-plugin\plugin.json')) {
    Write-Host 'Codex の crit プラグイン 既存'
  } else {
    Push-Location $HOME
    crit install codex-plugin
    if ($LASTEXITCODE -ne 0) { Fail 'Codex の crit プラグイン導入に失敗' }
    Pop-Location
  }
  # crit install codex-plugin の副産物(loose skill)。プラグインと二重に見えるので除く
  foreach ($name in 'crit', 'crit-cli', 'crit-story') {
    $loose = Join-Path $HOME ".agents\skills\$name"
    if (Test-Path $loose) { Remove-Item -Recurse -Force $loose }
  }
}

# ---- 3. draw.io Desktop(CLI) -----------------------------------------------
Log 'draw.io Desktop'
function Find-DrawioExe {
  $dirs = @(
    $env:ProgramFiles
    [Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
    (Join-Path $env:LOCALAPPDATA 'Programs')
  ) | Where-Object { $_ -and (Test-Path $_) } | ForEach-Object { Join-Path $_ 'draw.io' }
  foreach ($dir in $dirs) {
    foreach ($exeName in 'draw.io.exe', 'drawio.exe') {
      $path = Join-Path $dir $exeName
      if (Test-Path $path) { return $path }
    }
  }
  return $null
}

$DrawioExe = Find-DrawioExe
if ($DrawioExe) {
  Write-Host "draw.io 既存: $DrawioExe"
} elseif (Have winget) {
  winget install --id JGraph.Draw --exact --source winget --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -ne 0) { Fail 'draw.io の導入(winget)に失敗' }
  $DrawioExe = Find-DrawioExe
} else {
  Fail 'draw.io を導入できない(winget が要る)'
}

$DrawioShim = Join-Path $LocalBin 'drawio.cmd'
if ($DrawioExe) {
  # Windows 版の実体は GUI サブシステムのアプリで、呼び出し元に終了も標準出力も返さない。
  # 書き出しの完了を待たせるため、cmd/PowerShell 用は start /wait 越しに呼ぶシムを置く。
  $cmdShim = "@echo off`r`nstart `"`" /wait `"$DrawioExe`" %*`r`n"
  [IO.File]::WriteAllText($DrawioShim, $cmdShim, [Text.UTF8Encoding]::new($false))
  # Git Bash は拡張子無しを探し、GUI アプリでも終了を待つので素通しでよい
  $shShim = "#!/bin/sh`nexec `"$($DrawioExe.Replace([char]92, '/'))`" `"`$@`"`n"
  [IO.File]::WriteAllText((Join-Path $LocalBin 'drawio'), $shShim, [Text.UTF8Encoding]::new($false))
  Write-Host "drawio シムを作成: $DrawioShim"

  # 標準出力が返らない以上 --version では確かめられないので、スキルが使う経路ごと書き出して確かめる
  $probe = Join-Path ([IO.Path]::GetTempPath()) ("drawio-probe-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $probe | Out-Null
  $probeSrc = Join-Path $probe 'in.drawio'
  $probeOut = Join-Path $probe 'out.drawio.svg'
  $diagram = '<mxfile><diagram id="d" name="Page-1"><mxGraphModel><root><mxCell id="0"/><mxCell id="1" parent="0"/>' +
             '<mxCell id="2" value="ok" style="rounded=0" vertex="1" parent="1">' +
             '<mxGeometry x="0" y="0" width="80" height="40" as="geometry"/></mxCell></root></mxGraphModel></diagram></mxfile>'
  [IO.File]::WriteAllText($probeSrc, $diagram, [Text.UTF8Encoding]::new($false))
  & $DrawioShim -x -f svg -e -b 10 -o $probeOut $probeSrc *> $null
  if (Test-Path $probeOut) {
    Write-Host 'drawio CLI OK'
  } else {
    Fail 'drawio で書き出しを確認できない(デスクトップセッションが要る。サービスや一部のリモート接続では動かない)'
  }
  Remove-Item -Recurse -Force $probe
}

# ---- 4. 結果 ----------------------------------------------------------------
if ($script:Failed.Count -gt 0) {
  Log "未完了 $($script:Failed.Count) 件"
  $script:Failed | ForEach-Object { Write-Host " - $_" }
  Write-Host ''
  Write-Host '解消してから再実行する。完了した分は再実行しても壊れない。'
  exit 1
}

Log '完了。プロジェクトへの導入は README の手順 B へ'
