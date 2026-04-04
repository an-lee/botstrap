#requires -Version 5.1
<#
.SYNOPSIS
  Botstrap Windows boot entry (irm | iex). Clones the repo and runs install.ps1.
  Git install via winget mirrors install/boot-prereqs-git.ps1 (keep in sync).
#>
$ErrorActionPreference = "Stop"

function Update-BotstrapPathFromRegistry {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($machine -or $user) {
        $env:Path = "${machine};${user}"
    }
}

function Test-BotstrapGitAvailable {
    return [bool](Get-Command git -ErrorAction SilentlyContinue)
}

function Install-BotstrapGitIfNeeded {
    if (Test-BotstrapGitAvailable) {
        return
    }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[botstrap] Git not found; installing via winget..."
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        Update-BotstrapPathFromRegistry
    }
    if (-not (Test-BotstrapGitAvailable)) {
        $gitCmd = "C:\Program Files\Git\cmd\git.exe"
        if (Test-Path $gitCmd) {
            $env:Path = "C:\Program Files\Git\cmd;" + $env:Path
        }
    }
}

$BotstrapHome = if ($env:BOTSTRAP_HOME) { $env:BOTSTRAP_HOME } else { Join-Path $env:USERPROFILE ".botstrap" }
$BotstrapRepo = if ($env:BOTSTRAP_REPO) { $env:BOTSTRAP_REPO } else { "https://github.com/an-lee/botstrap.git" }

Install-BotstrapGitIfNeeded

if (-not (Test-BotstrapGitAvailable)) {
    Write-Host "[botstrap] Git is required. Install Git for Windows or ensure winget can install Git.Git, then re-run." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path (Join-Path $BotstrapHome ".git"))) {
    Write-Host "[botstrap] Cloning $BotstrapRepo -> $BotstrapHome"
    git clone $BotstrapRepo $BotstrapHome
}

& (Join-Path $BotstrapHome "install.ps1")
