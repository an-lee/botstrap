# Orchestrates Windows OS tuning from configs/os/windows.yaml (BOTSTRAP_ROOT).

function Get-BotstrapOsTuneSkipSet {
    $raw = $env:BOTSTRAP_OS_TUNE_SKIP
    if ([string]::IsNullOrWhiteSpace($raw)) { return @{} }
    $set = @{}
    foreach ($p in $raw.Split(',')) {
        $t = $p.Trim().ToLowerInvariant()
        if ($t) { $set[$t] = $true }
    }
    return $set
}

function Invoke-BotstrapWindowsOsTune {
    $ErrorActionPreference = 'Continue'
    if ($env:BOTSTRAP_OS_TUNE -eq '0') {
        Write-BotstrapInfo 'OS tune: skipped (BOTSTRAP_OS_TUNE=0).'
        return @()
    }
    $root = $env:BOTSTRAP_ROOT
    if ([string]::IsNullOrWhiteSpace($root)) {
        Write-BotstrapWarn 'OS tune: BOTSTRAP_ROOT unset; skipping.'
        return @()
    }
    $manifestPath = Join-Path $root 'configs\os\windows.yaml'
    $manifest = Read-BotstrapWindowsOsTuneManifest -Path $manifestPath
    if ($manifest.Count -eq 0) {
        Write-BotstrapWarn "OS tune: no manifest at $manifestPath; skipping."
        return @()
    }
    $skip = Get-BotstrapOsTuneSkipSet
    $admin = Test-BotstrapRunningAsAdmin
    $results = [System.Collections.Generic.List[object]]::new()

    foreach ($entry in (@(
                @{ Id = 'developer_mode'; },
                @{ Id = 'long_paths'; },
                @{ Id = 'powershell_execution_policy'; },
                @{ Id = 'git_longpaths'; },
                @{ Id = 'app_execution_aliases'; },
                @{ Id = 'utf8_system_locale'; }
            ))) {
        $id = $entry.Id
        if (-not $manifest.ContainsKey($id)) { continue }
        $meta = $manifest[$id]
        $wantDefault = [bool]$meta.default
        if ($id -eq 'utf8_system_locale') {
            $want = ($wantDefault -or ($env:BOTSTRAP_OS_TUNE_UTF8 -eq '1'))
        }
        else {
            $want = $wantDefault
        }
        if (-not $want) {
            $results.Add((New-BotstrapOsTuneResult -Id $id -Status skipped -Detail 'default off'))
            continue
        }
        if ($skip.ContainsKey($id)) {
            $results.Add((New-BotstrapOsTuneResult -Id $id -Status skipped -Detail 'BOTSTRAP_OS_TUNE_SKIP'))
            continue
        }

        switch ($id) {
            'developer_mode' {
                if (Test-BotstrapDeveloperModeEnabled) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail 'Developer Mode on'))
                }
                elseif (-not $admin) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status needs_admin -Detail 'Enable via Settings or re-run elevated'))
                    Write-BotstrapWarn "OS tune ($id): requires administrator. Open: $(Get-BotstrapOsTuneDeepLink developers)"
                }
                else {
                    try {
                        Set-BotstrapDeveloperMode
                        if (Test-BotstrapDeveloperModeEnabled) {
                            $results.Add((New-BotstrapOsTuneResult -Id $id -Status applied -Detail 'registry set'))
                        }
                        else {
                            $results.Add((New-BotstrapOsTuneResult -Id $id -Status manual_required -Detail 'Settings may override; open ms-settings:developers'))
                        }
                    }
                    catch {
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status failed -Detail $_.Exception.Message))
                    }
                }
            }
            'long_paths' {
                if (Test-BotstrapLongPathsEnabled) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail 'LongPathsEnabled=1'))
                }
                elseif (-not $admin) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status needs_admin -Detail 'HKLM LongPathsEnabled'))
                    Write-BotstrapWarn "OS tune ($id): requires administrator. Set HKLM LongPathsEnabled (reboot may be needed). See docs/CROSS_PLATFORM.md."
                }
                else {
                    try {
                        Set-BotstrapLongPathsEnabled
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status applied -Detail 'LongPathsEnabled set; reboot if paths still fail'))
                    }
                    catch {
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status failed -Detail $_.Exception.Message))
                    }
                }
            }
            'powershell_execution_policy' {
                if (Test-BotstrapExecutionPolicyRemoteSigned) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail (Get-ExecutionPolicy -Scope CurrentUser)))
                }
                else {
                    try {
                        Set-BotstrapExecutionPolicyRemoteSigned
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status applied -Detail 'CurrentUser RemoteSigned'))
                    }
                    catch {
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status failed -Detail $_.Exception.Message))
                    }
                }
            }
            'git_longpaths' {
                if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status skipped -Detail 'git not on PATH'))
                }
                elseif (Test-BotstrapGitLongPaths) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail 'core.longpaths true'))
                }
                else {
                    try {
                        Set-BotstrapGitLongPaths
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status applied -Detail 'git config --global core.longpaths true'))
                    }
                    catch {
                        $results.Add((New-BotstrapOsTuneResult -Id $id -Status failed -Detail $_.Exception.Message))
                    }
                }
            }
            'app_execution_aliases' {
                $shim = Test-BotstrapStorePythonShimActive
                if (-not $shim.Active) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail 'no Store python shim'))
                }
                else {
                    Write-BotstrapWarn "OS tune ($id): $($shim.Command) resolves to WindowsApps stub: $($shim.Source). Disable aliases: Settings > Apps > Advanced app settings > App execution aliases (or: Start-Process 'ms-settings:apps-feature')."
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status manual_required -Detail 'toggle off python.exe/python3.exe aliases'))
                }
            }
            'utf8_system_locale' {
                if (Test-BotstrapUtf8SystemCodePageHeuristic) {
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status already_ok -Detail 'ACP suggests UTF-8'))
                }
                else {
                    Write-BotstrapWarn "OS tune ($id): system-wide UTF-8 is opt-in. Region > Administrative language settings > Beta: Unicode UTF-8. Deep link: Start-Process '$(Get-BotstrapOsTuneDeepLink region)'. Reboot likely."
                    $results.Add((New-BotstrapOsTuneResult -Id $id -Status manual_required -Detail 'org policy may block; high blast radius'))
                }
            }
        }
    }

    Write-BotstrapInfo 'OS tune summary:'
    foreach ($r in $results) {
        Write-Host "  [$($r.Status)] $($r.Id): $($r.Detail)"
    }
    return $results
}
