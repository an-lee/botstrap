#requires -Version 5.1
<#
.SYNOPSIS
  Botstrap Windows boot entry (irm | iex). Clones the repo and runs install.ps1.
#>
$ErrorActionPreference = "Stop"

$BotstrapHome = if ($env:BOTSTRAP_HOME) { $env:BOTSTRAP_HOME } else { Join-Path $env:USERPROFILE ".botstrap" }
$BotstrapRepo = if ($env:BOTSTRAP_REPO) { $env:BOTSTRAP_REPO } else { "https://github.com/botstrap/botstrap.git" }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[botstrap] Install Git for Windows, then re-run this script." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path (Join-Path $BotstrapHome ".git"))) {
    Write-Host "[botstrap] Cloning $BotstrapRepo -> $BotstrapHome"
    git clone $BotstrapRepo $BotstrapHome
}

& (Join-Path $BotstrapHome "install.ps1")
