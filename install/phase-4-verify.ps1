#requires -Version 5.1
$ErrorActionPreference = "Continue"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")

Write-BotstrapInfo "Phase 4 (Windows): verify / doctor"

$__botstrapIsWin = ($env:OS -eq 'Windows_NT')
if (-not $__botstrapIsWin -and $null -ne $PSVersionTable.PSPlatform) {
    $__botstrapIsWin = ($PSVersionTable.PSPlatform -eq 'Win32NT')
}
if ($__botstrapIsWin) {
    . (Join-Path $env:BOTSTRAP_ROOT "lib\os-tune-windows.ps1")
    Write-BotstrapInfo "OS developer tuning status:"
    foreach ($line in Get-BotstrapWindowsOsTuneDoctorLines) {
        Write-Host "  $line"
    }
}

Write-BotstrapInfo "Run botstrap doctor after full Windows core installs; registry-driven Phase 1 may still be partial."
