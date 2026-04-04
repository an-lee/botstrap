#requires -Version 5.1
# Thin CLI for local Botstrap checkout (update / reconfigure / doctor) on Windows PowerShell.
$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$VersionPath = Join-Path $Root 'version'
$Version = if (Test-Path -LiteralPath $VersionPath) {
    (Get-Content -LiteralPath $VersionPath -Raw).Trim()
} else {
    'unknown'
}

function Show-BotstrapUsage {
    Write-Host 'Usage: botstrap {update|reconfigure|doctor|version}'
    Write-Host 'Run with no arguments for an interactive menu (console + gum).'
}

$sub = $null
if ($args.Count -eq 0) {
    if (-not [Console]::IsInputRedirected -and -not [Console]::IsOutputRedirected -and (Get-Command gum -ErrorAction SilentlyContinue)) {
        & gum style --border rounded --padding '1 2' --foreground 212 'Botstrap' '' 'Choose an action (or pass a subcommand for scripts).'
        $choice = & gum choose --header 'Action' update reconfigure doctor version quit
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

switch ($sub) {
    'update' {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Error 'git is required for botstrap update.'
            exit 1
        }
        & git -C $Root pull --ff-only
        $short = & git -C $Root rev-parse --short HEAD 2>$null
        if (-not $short) { $short = 'unknown' }
        Write-Host "Updated Botstrap at $Root to $short."
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
