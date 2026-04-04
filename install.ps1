#requires -Version 5.1
$ErrorActionPreference = "Stop"

$env:BOTSTRAP_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $env:BOTSTRAP_ROOT

. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\detect.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "lib\pkg.ps1")

Get-BotstrapEnvironment
Write-BotstrapInfo "Detected OS=$BotstrapOS distro=$BotstrapDistro pkg=$BotstrapPkg"

if ($BotstrapOS -eq 'windows') {
    $pr = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-BotstrapWarn 'Not running as Administrator. OS tuning steps that require elevation (developer_mode, long_paths) will be skipped. Re-run from an elevated PowerShell for full effect.'
    }
}

$phaseSteps = @(
    @{ Rel = 'install\phase-0-prerequisites.ps1'; Num = 1; Total = 5; Label = 'Prerequisites - git, curl, jq, yq, gum' }
    @{ Rel = 'install\phase-0b-os-tune.ps1'; Num = 2; Total = 5; Label = 'OS developer tuning' }
    @{ Rel = 'install\phase-2-tui.ps1'; Num = 3; Total = 5; Label = 'Interactive configuration' }
    @{ Rel = 'install\phase-3-configure.ps1'; Num = 4; Total = 5; Label = 'Apply installs and dotfiles' }
    @{ Rel = 'install\phase-4-verify.ps1'; Num = 5; Total = 5; Label = 'Verification' }
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
