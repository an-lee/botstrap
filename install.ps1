#requires -Version 5.1
$ErrorActionPreference = "Stop"

$env:BOTSTRAP_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $env:BOTSTRAP_ROOT

. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\detect.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\pkg.ps1")

Get-BotstrapEnvironment
Write-BotstrapInfo "Detected OS=$BotstrapOS distro=$BotstrapDistro pkg=$BotstrapPkg"

$phases = @(
    "install\phase-0-prerequisites.ps1",
    "install\phase-0b-os-tune.ps1",
    "install\phase-1-core.ps1",
    "install\phase-2-tui.ps1",
    "install\phase-3-configure.ps1",
    "install\phase-4-verify.ps1"
)

foreach ($rel in $phases) {
    $path = Join-Path $env:BOTSTRAP_ROOT $rel
    if (Test-Path $path) {
        . $path
    }
    else {
        Write-BotstrapWarn "Missing phase script: $rel"
    }
}

Write-BotstrapInfo "Botstrap install phases finished (Windows path may be partial; prefer WSL + install.sh for parity)."
