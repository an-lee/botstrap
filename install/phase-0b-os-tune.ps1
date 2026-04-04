#requires -Version 5.1
# Optional Windows developer OS settings (registry, Git, execution policy). Never fails the full install.
$ErrorActionPreference = 'Continue'

$__botstrapIsWin = ($env:OS -eq 'Windows_NT')
if (-not $__botstrapIsWin -and $null -ne $PSVersionTable.PSPlatform) {
    $__botstrapIsWin = ($PSVersionTable.PSPlatform -eq 'Win32NT')
}
if (-not $__botstrapIsWin) {
    return
}

. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\os-tune-windows.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "install\modules\os-tune-windows.ps1")

Write-BotstrapInfo 'Phase 0b (Windows): OS developer tuning'
[void](Invoke-BotstrapWindowsOsTune)
