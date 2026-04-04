#requires -Version 5.1
$ErrorActionPreference = "Continue"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\pkg.ps1")

Write-BotstrapWarn "Phase 1 (Windows): registry-driven installs are stubs; use WSL + install.sh for full core installs."
