#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'install\boot-prereqs-git.ps1')

Write-BotstrapInfo 'Phase 0 (Windows): ensure winget, Git, yq, then registry prerequisites'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'winget is required. Install App Installer from the Microsoft Store or update Windows, then re-run.'
    exit 1
}

Install-BotstrapGitIfNeeded
if (-not (Test-BotstrapGitAvailable)) {
    Write-BotstrapErr 'Git is required. Install Git for Windows or ensure winget can install Git.Git, then re-run.'
    exit 1
}

function Test-BotstrapYqIsMikefarah {
    try {
        $raw = & yq --version 2>&1
        $s = ($raw | Out-String).Trim()
        return ($s -match '(?i)mikefarah')
    }
    catch {
        return $false
    }
}

function Install-BotstrapWingetToolIfMissing {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$TestCommand,
        [scriptblock]$PresentIsOk = $null
    )
    $onPath = [bool](Get-Command $TestCommand -ErrorAction SilentlyContinue)
    if ($onPath) {
        if ($null -ne $PresentIsOk) {
            $ok = & $PresentIsOk
            if (-not $ok) {
                Write-BotstrapWarn "${TestCommand} on PATH is not Mike Farah yq (required for registry parsing); reinstalling ${Id} via winget..."
            }
            else {
                Write-BotstrapInfo "${TestCommand} already on PATH."
                return
            }
        }
        else {
            Write-BotstrapInfo "${TestCommand} already on PATH."
            return
        }
    }
    Write-BotstrapInfo "Installing ${Id} via winget..."
    $ErrorActionPreference = 'Continue'
    $wingetArgs = @('install', '--id', $Id, '-e', '--accept-package-agreements', '--accept-source-agreements')
    if ($onPath) {
        $wingetArgs += '--force'
    }
    & winget @wingetArgs
    Update-BotstrapPathFromRegistry
    if (-not (Get-Command $TestCommand -ErrorAction SilentlyContinue)) {
        Write-BotstrapWarn "${TestCommand} still not on PATH after install; you may need a new terminal."
    }
}

# yq must exist before reading registry/prerequisites.yaml for the remaining tools.
Install-BotstrapWingetToolIfMissing -Id 'MikeFarah.yq' -TestCommand 'yq' -PresentIsOk { Test-BotstrapYqIsMikefarah }

if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'yq is required. Install MikeFarah.yq and re-run.'
    exit 1
}
if (-not (Test-BotstrapYqIsMikefarah)) {
    Write-BotstrapErr 'Mike Farah yq is required for registry YAML. Remove other yq implementations from PATH or run winget install MikeFarah.yq --force, then re-run.'
    exit 1
}

$ErrorActionPreference = 'Stop'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\pkg.ps1')

$prereqReg = Join-Path $env:BOTSTRAP_ROOT 'registry\prerequisites.yaml'
$names = & yq -r '.tools[].name' $prereqReg 2>$null
if (-not $names) {
    Write-BotstrapErr "Could not read tools from $prereqReg"
    exit 1
}

$tools = @($names -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$total = $tools.Count
$current = 0
foreach ($tool in $tools) {
    $current++
    Write-BotstrapStep -Current $current -Total $total -Label "Prerequisite $tool" -Activity 'Prerequisites'
    $ok = Install-BotstrapPackageFromRegistry -ToolName $tool -RegistryPath $prereqReg
    if (-not $ok) {
        Write-BotstrapWarn "Phase 0 reported a problem for ${tool} (continuing)."
    }
}
Write-BotstrapProgressComplete -Activity 'Prerequisites'

if (-not (Get-Command jq -ErrorAction SilentlyContinue)) {
    Write-BotstrapWarn 'jq not installed; some scripts may skip JSON helpers.'
}
if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-BotstrapWarn 'gum missing; Phase 2 TUI will be limited.'
}

Write-BotstrapInfo 'Phase 0 (Windows) complete.'
