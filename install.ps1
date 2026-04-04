#requires -Version 5.1
$ErrorActionPreference = "Stop"

$env:BOTSTRAP_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $env:BOTSTRAP_ROOT

. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\detect.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\pkg.ps1")

Get-BotstrapEnvironment
Write-BotstrapInfo "Detected OS=$BotstrapOS distro=$BotstrapDistro pkg=$BotstrapPkg"

$phaseSteps = @(
    @{ Rel = 'install\phase-0-prerequisites.ps1'; Num = 1; Total = 6; Label = 'Prerequisites - git, curl, jq, yq, gum' }
    @{ Rel = 'install\phase-0b-os-tune.ps1'; Num = 2; Total = 6; Label = 'OS developer tuning' }
    @{ Rel = 'install\phase-1-core.ps1'; Num = 3; Total = 6; Label = 'Core tools' }
    @{ Rel = 'install\phase-2-tui.ps1'; Num = 4; Total = 6; Label = 'Configuration' }
    @{ Rel = 'install\phase-3-configure.ps1'; Num = 5; Total = 6; Label = 'Optional installs' }
    @{ Rel = 'install\phase-4-verify.ps1'; Num = 6; Total = 6; Label = 'Verification' }
)

foreach ($step in $phaseSteps) {
    $path = Join-Path $env:BOTSTRAP_ROOT $step.Rel
    Write-BotstrapPhase -Num $step.Num -Total $step.Total -Label $step.Label
    if (Test-Path $path) {
        . $path
    }
    else {
        Write-BotstrapWarn "Missing phase script: $($step.Rel)"
    }
}

Write-BotstrapInfo 'Botstrap install phases finished.'
