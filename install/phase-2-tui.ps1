#requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")

if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-BotstrapWarn "gum not found; using non-interactive defaults."
    $env:BOTSTRAP_EDITOR = "none"
    $env:BOTSTRAP_THEME = "catppuccin"
    return
}

Write-BotstrapWarn "Phase 2 TUI on Windows: run gum flows manually or use WSL for the full experience."
