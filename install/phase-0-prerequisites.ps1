#requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")
. (Join-Path $env:BOTSTRAP_ROOT "install\boot-prereqs-git.ps1")

Write-BotstrapInfo "Phase 0 (Windows): ensure Git and winget are available; install jq/yq/gum manually or via winget when packages exist."

Install-BotstrapGitIfNeeded
if (-not (Test-BotstrapGitAvailable)) {
    Write-BotstrapErr "Git is required. Install Git for Windows or ensure winget can install Git.Git, then re-run."
    exit 1
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-BotstrapWarn "winget not found. Install App Installer / winget, then re-run."
}
