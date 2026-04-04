#requires -Version 5.1
$ErrorActionPreference = "Continue"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")

Write-BotstrapInfo "Phase 4 (Windows): run doctor/update flows after full Windows support lands."
