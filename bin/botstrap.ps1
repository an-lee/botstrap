#requires -Version 5.1
# Thin CLI for local Botstrap checkout (update / self-update / reconfigure / doctor) on Windows PowerShell.
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$VersionPath = Join-Path $Root 'version'
$Version = if (Test-Path -LiteralPath $VersionPath) {
    (Get-Content -LiteralPath $VersionPath -Raw).Trim()
} else {
    'unknown'
}

function Show-BotstrapUsage {
    Write-Host 'Usage: botstrap {update|self-update|reconfigure|doctor|version}'
    Write-Host '       botstrap update [--self|--tools|--all]'
    Write-Host 'Run with no arguments for an interactive menu (console + gum).'
}

function Invoke-BotstrapSelfUpdate {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error 'git is required for botstrap self-update / repo update.'
        exit 1
    }
    & git -C $Root pull --ff-only
    $short = & git -C $Root rev-parse --short HEAD 2>$null
    if (-not $short) { $short = 'unknown' }
    Write-Host "Updated Botstrap at $Root to $short."
}

function Invoke-BotstrapUpdateTools {
    $env:BOTSTRAP_ROOT = $Root
    . (Join-Path $Root 'install\update-tools.ps1')
}

$sub = $null
if ($args.Count -eq 0) {
    if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected -and (Get-Command gum -ErrorAction SilentlyContinue)) {
        & gum style --border rounded --padding '1 2' --foreground 212 'Botstrap' '' 'Choose an action (or pass a subcommand for scripts).'
        $choice = & gum choose --header 'Action' update self-update reconfigure doctor version quit
        if (-not $?) { exit 1 }
        $choice = if ($null -eq $choice) { '' } else { $choice.Trim() }
        if ($choice -eq 'quit') { exit 0 }
        $sub = $choice
    }
    else {
        Show-BotstrapUsage
        exit 1
    }
}
else {
    $sub = $args[0]
}

if ($sub -eq 'update') {
    $doSelf = $false
    $doTools = $false
    $i = 1
    while ($i -lt $args.Count) {
        switch ($args[$i]) {
            '--self' { $doSelf = $true }
            '--tools' { $doTools = $true }
            '--all' { $doSelf = $true; $doTools = $true }
            default {
                Show-BotstrapUsage
                exit 1
            }
        }
        $i++
    }
    if (-not $doSelf -and -not $doTools) {
        if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected -and (Get-Command gum -ErrorAction SilentlyContinue)) {
            $uchoice = & gum choose --header 'Update' 'Botstrap repo only' 'Installed tools only' 'Both' 'Cancel'
            if (-not $?) { exit 1 }
            $uchoice = if ($null -eq $uchoice) { '' } else { $uchoice.Trim() }
            switch ($uchoice) {
                'Botstrap repo only' { $doSelf = $true }
                'Installed tools only' { $doTools = $true }
                'Both' { $doSelf = $true; $doTools = $true }
                'Cancel' { exit 0 }
                default {
                    Show-BotstrapUsage
                    exit 1
                }
            }
        }
        else {
            Invoke-BotstrapSelfUpdate
            Write-Host 'Hint: use botstrap update --tools to upgrade installed tools, botstrap update --all for repo + tools, or botstrap self-update for repo only.'
            exit 0
        }
    }
    if ($doSelf) {
        Invoke-BotstrapSelfUpdate
    }
    if ($doTools) {
        Invoke-BotstrapUpdateTools
    }
    exit 0
}

switch ($sub) {
    'self-update' {
        Invoke-BotstrapSelfUpdate
    }
    'reconfigure' {
        $env:BOTSTRAP_ROOT = $Root
        . (Join-Path $Root 'install\phase-2-tui.ps1')
        . (Join-Path $Root 'install\phase-3-configure.ps1')
    }
    'doctor' {
        $env:BOTSTRAP_ROOT = $Root
        . (Join-Path $Root 'lib\log.ps1')
        Write-BotstrapInfo "Doctor: BOTSTRAP_ROOT=$Root"
        Write-BotstrapInfo "Doctor: version=$Version"
        if (Test-Path -LiteralPath (Join-Path $Root '.git')) {
            $head = & git -C $Root rev-parse --short HEAD 2>$null
            if (-not $head) { $head = 'unknown' }
            Write-BotstrapInfo "Doctor: git_head=$head"
        }
        else {
            Write-BotstrapInfo 'Doctor: git_head=(not a git checkout)'
        }
        $profilePath = $PROFILE
        if ([string]::IsNullOrWhiteSpace($profilePath)) {
            $profilePath = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
        }
        $hookPresent = $false
        if (Test-Path -LiteralPath $profilePath) {
            $raw = Get-Content -LiteralPath $profilePath -Raw -ErrorAction SilentlyContinue
            if ($raw -and $raw.Contains('# botstrap PATH')) { $hookPresent = $true }
        }
        if ($hookPresent) {
            Write-BotstrapInfo "Doctor: PowerShell profile hook present ($profilePath)"
        }
        else {
            Write-BotstrapInfo 'Doctor: PowerShell profile hook missing (run Phase 3 or botstrap reconfigure to add botstrap command)'
        }
        . (Join-Path $Root 'install\phase-4-verify.ps1')
    }
    'version' {
        Write-Host "botstrap $Version"
    }
    default {
        Show-BotstrapUsage
        exit 1
    }
}
