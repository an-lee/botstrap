# Botstrap Windows OS tuning helpers — idempotent Test/Set and doctor diagnostics.
# Requires PowerShell 5.1+. Do not dot-source with $ErrorActionPreference Stop unless callers handle errors.

function Test-BotstrapRunningAsAdmin {
    $p = [Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Read-BotstrapWindowsOsTuneManifest {
    param(
        [Parameter(Mandatory)][string]$Path
    )
    $tuning = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $tuning
    }
    $lines = Get-Content -LiteralPath $Path -ErrorAction Stop
    $inTuning = $false
    $currentKey = $null
    foreach ($line in $lines) {
        $trim = $line.Trim()
        if ($trim.StartsWith('#') -or $trim -eq '') { continue }
        if ($line -match '^\s*tuning:\s*$') {
            $inTuning = $true
            $currentKey = $null
            continue
        }
        if (-not $inTuning) { continue }
        if ($line -match '^\s{2}([a-z][a-z0-9_]*):\s*$') {
            $currentKey = $Matches[1]
            $tuning[$currentKey] = @{
                default          = $false
                requires_admin = $false
                risk           = 'low'
            }
            continue
        }
        if ($null -eq $currentKey) { continue }
        if ($line -match '^\s+default:\s*(true|false)\s*$') {
            $tuning[$currentKey].default = ($Matches[1] -eq 'true')
            continue
        }
        if ($line -match '^\s+requires_admin:\s*(true|false)\s*$') {
            $tuning[$currentKey].requires_admin = ($Matches[1] -eq 'true')
            continue
        }
        if ($line -match '^\s+risk:\s*(low|medium|high)\s*$') {
            $tuning[$currentKey].risk = $Matches[1]
            continue
        }
    }
    return $tuning
}

function Test-BotstrapDeveloperModeEnabled {
    try {
        $p = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        if (Test-Path -LiteralPath $p) {
            $v = Get-ItemProperty -LiteralPath $p -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
            if ($v.AllowDevelopmentWithoutDevLicense -eq 1) { return $true }
        }
        $pCu = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
        if (Test-Path -LiteralPath $pCu) {
            $v2 = Get-ItemProperty -LiteralPath $pCu -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue
            if ($v2.AllowDevelopmentWithoutDevLicense -eq 1) { return $true }
        }
    }
    catch { }
    return $false
}

function Set-BotstrapDeveloperMode {
    $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    if (-not (Test-Path -LiteralPath $path)) {
        New-Item -LiteralPath $path -Force | Out-Null
    }
    New-ItemProperty -LiteralPath $path -Name AllowDevelopmentWithoutDevLicense -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -LiteralPath $path -Name AllowAllTrustedApps -PropertyType DWord -Value 1 -Force -ErrorAction SilentlyContinue | Out-Null
}

function Test-BotstrapLongPathsEnabled {
    try {
        $fs = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
        $v = Get-ItemProperty -LiteralPath $fs -Name LongPathsEnabled -ErrorAction SilentlyContinue
        return ($v.LongPathsEnabled -eq 1)
    }
    catch {
        return $false
    }
}

function Set-BotstrapLongPathsEnabled {
    $fs = 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem'
    Set-ItemProperty -LiteralPath $fs -Name LongPathsEnabled -Value 1 -Type DWord -Force
}

function Test-BotstrapExecutionPolicyRemoteSigned {
    $cur = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue
    if ($cur -in @('RemoteSigned', 'Unrestricted', 'Bypass')) { return $true }
    return $false
}

function Set-BotstrapExecutionPolicyRemoteSigned {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

function Test-BotstrapGitLongPaths {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return $false }
    try {
        $out = & git config --global --get core.longpaths 2>$null
        return ($out -eq 'true')
    }
    catch {
        return $false
    }
}

function Set-BotstrapGitLongPaths {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { return }
    & git config --global core.longpaths true
}

function Test-BotstrapStorePythonShimActive {
    param([string[]]$Names = @('python', 'python3'))
    foreach ($name in $Names) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -eq $cmd) { continue }
        $src = $cmd.Source
        if ($src -like '*\WindowsApps\*' -or $src -like '*\Microsoft\WindowsApps\*') {
            return @{ Active = $true; Command = $name; Source = $src }
        }
    }
    return @{ Active = $false; Command = $null; Source = $null }
}

function Test-BotstrapUtf8SystemCodePageHeuristic {
    try {
        $cp = Get-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\CodePage' -ErrorAction SilentlyContinue
        $acp = [string]$cp.ACP
        # UTF-8 active code page often signals "Beta: Unicode UTF-8" (not definitive for all builds).
        return ($acp -eq '65001')
    }
    catch {
        return $false
    }
}

function Get-BotstrapOsTuneDeepLink {
    param([ValidateSet('developers', 'apps', 'region')][string]$Target)
    switch ($Target) {
        'developers' { return 'ms-settings:developers' }
        'apps' { return 'ms-settings:apps-feature' }
        'region' { return 'ms-settings:regionlanguage' }
    }
}

function New-BotstrapOsTuneResult {
    param(
        [string]$Id,
        [ValidateSet('applied', 'skipped', 'needs_admin', 'failed', 'already_ok', 'manual_required')][string]$Status,
        [string]$Detail = ''
    )
    [pscustomobject]@{
        Id     = $Id
        Status = $Status
        Detail = $Detail
    }
}

function Get-BotstrapWindowsOsTuneDoctorLines {
    $lines = [System.Collections.Generic.List[string]]::new()
    $dev = Test-BotstrapDeveloperModeEnabled
    $lines.Add("developer_mode: $(if ($dev) { 'ok' } else { 'off' })")
    $long = Test-BotstrapLongPathsEnabled
    $lines.Add("long_paths: $(if ($long) { 'ok' } else { 'off' })")
    $lines.Add("powershell_execution_policy: $(Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue)")
    $gitOk = Test-BotstrapGitLongPaths
    $lines.Add("git_core.longpaths: $(if ($gitOk) { 'true' } else { 'unset/false' })")
    $shim = Test-BotstrapStorePythonShimActive
    if ($shim.Active) {
        $lines.Add("app_execution_aliases: warn (Store shim for $($shim.Command) at $($shim.Source))")
    }
    else {
        $lines.Add('app_execution_aliases: ok (no WindowsApps python/python3 on PATH)')
    }
    $utf = Test-BotstrapUtf8SystemCodePageHeuristic
    $lines.Add("utf8_system_locale heuristic (ACP 65001): $(if ($utf) { 'likely on' } else { 'off or unknown' })")
    $lines.Add("elevated_session: $(Test-BotstrapRunningAsAdmin)")
    return $lines
}
