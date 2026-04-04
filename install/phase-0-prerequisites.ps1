#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'install\boot-prereqs-git.ps1')

Write-BotstrapInfo 'Phase 0 (Windows): ensure winget, Git, yq, jq, and gum'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'winget is required. Install App Installer from the Microsoft Store or update Windows, then re-run.'
    exit 1
}

Install-BotstrapGitIfNeeded
if (-not (Test-BotstrapGitAvailable)) {
    Write-BotstrapErr 'Git is required. Install Git for Windows or ensure winget can install Git.Git, then re-run.'
    exit 1
}

function Install-BotstrapWingetToolIfMissing {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$TestCommand
    )
    if (Get-Command $TestCommand -ErrorAction SilentlyContinue) {
        Write-BotstrapInfo "${TestCommand} already on PATH."
        return
    }
    Write-BotstrapInfo "Installing ${Id} via winget..."
    $ErrorActionPreference = 'Continue'
    & winget install --id $Id -e --accept-package-agreements --accept-source-agreements
    Update-BotstrapPathFromRegistry
    if (-not (Get-Command $TestCommand -ErrorAction SilentlyContinue)) {
        Write-BotstrapWarn "${TestCommand} still not on PATH after install; you may need a new terminal."
    }
}

Install-BotstrapWingetToolIfMissing -Id 'MikeFarah.yq' -TestCommand 'yq'
Install-BotstrapWingetToolIfMissing -Id 'jqlang.jq' -TestCommand 'jq'
Install-BotstrapWingetToolIfMissing -Id 'charmbracelet.gum' -TestCommand 'gum'

if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'yq is required for Phase 1. Install MikeFarah.yq and re-run.'
    exit 1
}

Write-BotstrapInfo 'Phase 0 (Windows) complete.'
