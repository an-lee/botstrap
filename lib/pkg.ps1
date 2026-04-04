#requires -Version 5.1
# Registry-driven install helpers (Windows). Requires mikefarah/yq on PATH after Phase 0.

function Test-BotstrapHostWindows {
    if ($PSVersionTable.PSEdition -eq 'Core') {
        try {
            return [bool]$IsWindows
        }
        catch {
            return ($env:OS -eq 'Windows_NT')
        }
    }
    return ($env:OS -eq 'Windows_NT')
}

function Refresh-BotstrapPath {
    $machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    if ($machine -or $user) {
        $env:Path = "${machine};${user}"
    }
}

function Add-BotstrapMiseBinsToPath {
    $parts = @(
        (Join-Path $env:LOCALAPPDATA 'mise\bin'),
        (Join-Path $env:USERPROFILE '.local\bin')
    )
    foreach ($p in $parts) {
        if ($p -and (Test-Path -LiteralPath $p) -and ($env:Path -notlike "*${p}*")) {
            $env:Path = "${p};${env:Path}"
        }
    }
}

function Get-BotstrapPkgResolveKeys {
    if (Test-BotstrapHostWindows) {
        return @('windows', 'all')
    }
    return @('all')
}

function Invoke-BotstrapYq {
    param(
        [Parameter(Mandatory)][string]$Expression,
        [Parameter(Mandatory)][string]$FilePath
    )
    if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
        Write-BotstrapErr 'yq is required for registry-driven operations. Re-run Phase 0.'
        return $null
    }
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        $out = & yq -r $Expression $FilePath 2>$stderrFile
        if ($LASTEXITCODE -ne 0) {
            $errText = ''
            if (Test-Path -LiteralPath $stderrFile) {
                $errText = (Get-Content -LiteralPath $stderrFile -Raw -ErrorAction SilentlyContinue).Trim()
            }
            if ($errText) {
                Write-BotstrapWarn "yq failed (exit $LASTEXITCODE): $errText"
            }
            else {
                Write-BotstrapWarn "yq failed (exit $LASTEXITCODE) with no stderr captured."
            }
            return $null
        }
        return $out
    }
    finally {
        Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
    }
}

function Invoke-BotstrapPowerShellSnippet {
    param(
        [Parameter(Mandatory)][string]$Snippet
    )
    if ([string]::IsNullOrWhiteSpace($Snippet) -or $Snippet -eq 'null') {
        return
    }
    $trim = $Snippet.Trim()
    if ([string]::IsNullOrWhiteSpace($trim)) {
        return
    }
    Add-BotstrapMiseBinsToPath
    Refresh-BotstrapPath
    $sb = [scriptblock]::Create($trim)
    & $sb
}

function Get-BotstrapCoreInstallSnippet {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [Parameter(Mandatory)][string]$Key,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml')
    )
    $escaped = $ToolName.Replace('\', '\\').Replace('"', '\"')
    $expr = ".tools[] | select(.name == `"$escaped`") | .install[`"${Key}`"] // `"`""
    $val = Invoke-BotstrapYq -Expression $expr -FilePath $RegistryPath
    if ($null -eq $val) { return '' }
    $s = [string]$val.Trim()
    if ($s -eq '' -or $s -eq 'null') { return '' }
    return $s
}

function Normalize-BotstrapVerifyForWindows {
    param([string]$VerifyCmd)
    if ([string]::IsNullOrWhiteSpace($VerifyCmd) -or $VerifyCmd -eq 'null') {
        return ''
    }
    $v = $VerifyCmd.Trim()
    if ($v -match '^bash\s+-c\s+"([^"]*)"$') {
        return $Matches[1]
    }
    if ($v -match "^bash\s+-c\s+'([^']*)'$") {
        return $Matches[1]
    }
    return $v
}

function Get-BotstrapCoreVerifySnippet {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml')
    )
    $escaped = $ToolName.Replace('\', '\\').Replace('"', '\"')
    $vw = Invoke-BotstrapYq -Expression ".tools[] | select(.name == `"$escaped`") | .verify_windows // `"`"" -FilePath $RegistryPath
    if ($null -ne $vw -and [string]$vw -ne '' -and [string]$vw -ne 'null') {
        return [string]$vw
    }
    $v = Invoke-BotstrapYq -Expression ".tools[] | select(.name == `"$escaped`") | .verify // `"`"" -FilePath $RegistryPath
    if ($null -eq $v) { return '' }
    return (Normalize-BotstrapVerifyForWindows -VerifyCmd ([string]$v))
}

function Install-BotstrapPackageFromRegistry {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml')
    )
    if (-not $env:BOTSTRAP_ROOT) {
        Write-BotstrapErr 'BOTSTRAP_ROOT is not set.'
        return $false
    }
    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        Write-BotstrapErr "Registry not found: $RegistryPath"
        return $false
    }
    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath

    $snippet = ''
    $usedKey = ''
    foreach ($key in (Get-BotstrapPkgResolveKeys)) {
        $snippet = Get-BotstrapCoreInstallSnippet -ToolName $ToolName -Key $key -RegistryPath $RegistryPath
        if (-not [string]::IsNullOrWhiteSpace($snippet)) {
            $usedKey = $key
            break
        }
    }

    if ([string]::IsNullOrWhiteSpace($snippet)) {
        Write-BotstrapInfo "Skipping '${ToolName}' (no install snippet for Windows)."
        return $true
    }

    Write-BotstrapInfo "Installing ${ToolName} (registry key: ${usedKey})"
    try {
        $ErrorActionPreference = 'Continue'
        Invoke-BotstrapPowerShellSnippet -Snippet $snippet
    }
    catch {
        Write-BotstrapWarn "Install snippet reported an error for '${ToolName}': $($_.Exception.Message)"
    }

    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath

    $escaped = $ToolName.Replace('\', '\\').Replace('"', '\"')
    $postWin = Invoke-BotstrapYq -Expression ".tools[] | select(.name == `"$escaped`") | .post_install_windows // `"`"" -FilePath $RegistryPath
    if ($null -ne $postWin -and [string]$postWin.Trim() -ne '' -and [string]$postWin -ne 'null') {
        Write-BotstrapInfo "Running post_install_windows for ${ToolName}"
        try {
            Invoke-BotstrapPowerShellSnippet -Snippet ([string]$postWin)
        }
        catch {
            Write-BotstrapWarn "post_install_windows for '${ToolName}': $($_.Exception.Message)"
        }
    }

    return $true
}

function Test-BotstrapPackageFromRegistry {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml')
    )
    if (-not (Test-Path -LiteralPath $RegistryPath)) {
        Write-BotstrapWarn "Registry not found for verify: $RegistryPath"
        return $false
    }
    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath

    $escaped = $ToolName.Replace('\', '\\').Replace('"', '\"')
    $hasWinInstall = Invoke-BotstrapYq -Expression ".tools[] | select(.name == `"$escaped`") | .install.windows // `"`"" -FilePath $RegistryPath
    $hasAllInstall = Invoke-BotstrapYq -Expression ".tools[] | select(.name == `"$escaped`") | .install.all // `"`"" -FilePath $RegistryPath
    if (([string]::IsNullOrWhiteSpace($hasWinInstall) -or $hasWinInstall -eq 'null') -and ([string]::IsNullOrWhiteSpace($hasAllInstall) -or $hasAllInstall -eq 'null')) {
        Write-BotstrapInfo "Verify skipped for '${ToolName}' (not installed on Windows)."
        return $true
    }

    $verifyCmd = Get-BotstrapCoreVerifySnippet -ToolName $ToolName -RegistryPath $RegistryPath
    if ([string]::IsNullOrWhiteSpace($verifyCmd)) {
        Write-BotstrapWarn "No verify command for '${ToolName}'; trying Get-Command."
        $exe = $ToolName
        if ($ToolName -eq 'ripgrep') { $exe = 'rg' }
        elseif ($ToolName -eq 'git-delta') { $exe = 'delta' }
        elseif ($ToolName -eq 'curlie') { $exe = 'http' }
        if (Get-Command $exe -ErrorAction SilentlyContinue) {
            return $true
        }
        return $false
    }

    Write-BotstrapInfo "Verifying ${ToolName}: $verifyCmd"
    try {
        $ErrorActionPreference = 'Continue'
        Invoke-BotstrapPowerShellSnippet -Snippet $verifyCmd
        if (-not $?) {
            return $false
        }
        if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            return $false
        }
        return $true
    }
    catch {
        Write-BotstrapWarn "Verify failed for '${ToolName}': $($_.Exception.Message)"
        return $false
    }
}

function Test-BotstrapOptionalRequiresSatisfied {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$ItemName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath
    $escapedGroup = $GroupId.Replace('\', '\\').Replace('"', '\"')
    $escapedItem = $ItemName.Replace('\', '\\').Replace('"', '\"')
    $reqExpr = ".groups[] | select(.id == `"$escapedGroup`") | .items[] | select(.name == `"$escapedItem`") | .requires[]?"
    $reqsRaw = & yq -r $reqExpr $RegistryPath 2>$null
    if ([string]::IsNullOrWhiteSpace($reqsRaw)) {
        return $true
    }
    $reqLines = @($reqsRaw -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' -and $_ -ne 'null' })
    if ($reqLines.Count -eq 0) {
        return $true
    }
    foreach ($line in $reqLines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        switch -Wildcard ($line.Trim()) {
            'node' {
                if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
                    Write-BotstrapWarn "Optional '${ItemName}' requires node; skipping."
                    return $false
                }
            }
            'docker' {
                if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
                    Write-BotstrapWarn "Optional '${ItemName}' requires docker; skipping."
                    return $false
                }
            }
            'mise' {
                if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
                    Write-BotstrapWarn "Optional '${ItemName}' requires mise; skipping."
                    return $false
                }
            }
            default {
                Write-BotstrapWarn "Unknown requires '$line' for '${ItemName}'; skipping."
                return $false
            }
        }
    }
    return $true
}

function Get-BotstrapOptionalInstallSnippet {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$ItemName,
        [Parameter(Mandatory)][string]$Key,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    $escapedGroup = $GroupId.Replace('\', '\\').Replace('"', '\"')
    $escapedItem = $ItemName.Replace('\', '\\').Replace('"', '\"')
    $expr = ".groups[] | select(.id == `"$escapedGroup`") | .items[] | select(.name == `"$escapedItem`") | .install[`"${Key}`"] // `"`""
    $val = Invoke-BotstrapYq -Expression $expr -FilePath $RegistryPath
    if ($null -eq $val) { return '' }
    $s = [string]$val.Trim()
    if ($s -eq '' -or $s -eq 'null') { return '' }
    return $s
}

function Get-BotstrapOptionalVerifySnippet {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$ItemName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    $escapedGroup = $GroupId.Replace('\', '\\').Replace('"', '\"')
    $escapedItem = $ItemName.Replace('\', '\\').Replace('"', '\"')
    $vw = Invoke-BotstrapYq -Expression ".groups[] | select(.id == `"$escapedGroup`") | .items[] | select(.name == `"$escapedItem`") | .verify_windows // `"`"" -FilePath $RegistryPath
    if ($null -ne $vw -and [string]$vw -ne '' -and [string]$vw -ne 'null') {
        return [string]$vw
    }
    $v = Invoke-BotstrapYq -Expression ".groups[] | select(.id == `"$escapedGroup`") | .items[] | select(.name == `"$escapedItem`") | .verify // `"`"" -FilePath $RegistryPath
    if ($null -eq $v) { return '' }
    return (Normalize-BotstrapVerifyForWindows -VerifyCmd ([string]$v))
}

function Install-BotstrapOptionalItem {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$ItemName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    if ([string]::IsNullOrWhiteSpace($ItemName) -or $ItemName -eq 'none') {
        return $true
    }
    if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
        Write-BotstrapErr 'yq is required for optional installs.'
        return $false
    }
    if (-not (Test-BotstrapOptionalRequiresSatisfied -GroupId $GroupId -ItemName $ItemName -RegistryPath $RegistryPath)) {
        return $true
    }

    $snippet = ''
    $usedKey = ''
    foreach ($key in (Get-BotstrapPkgResolveKeys)) {
        $snippet = Get-BotstrapOptionalInstallSnippet -GroupId $GroupId -ItemName $ItemName -Key $key -RegistryPath $RegistryPath
        if (-not [string]::IsNullOrWhiteSpace($snippet)) {
            $usedKey = $key
            break
        }
    }

    if ([string]::IsNullOrWhiteSpace($snippet)) {
        Write-BotstrapWarn "No optional install snippet for ${GroupId}/${ItemName} on Windows."
        return $true
    }

    Write-BotstrapInfo "Installing optional ${GroupId}/${ItemName} (registry key: ${usedKey})"
    try {
        Invoke-BotstrapPowerShellSnippet -Snippet $snippet
    }
    catch {
        Write-BotstrapWarn "Optional install ${GroupId}/${ItemName}: $($_.Exception.Message)"
    }

    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath

    $escapedGroup = $GroupId.Replace('\', '\\').Replace('"', '\"')
    $escapedItem = $ItemName.Replace('\', '\\').Replace('"', '\"')
    $postWin = Invoke-BotstrapYq -Expression ".groups[] | select(.id == `"$escapedGroup`") | .items[] | select(.name == `"$escapedItem`") | .post_install_windows // `"`"" -FilePath $RegistryPath
    if ($null -ne $postWin -and [string]$postWin.Trim() -ne '' -and [string]$postWin -ne 'null') {
        try {
            Invoke-BotstrapPowerShellSnippet -Snippet ([string]$postWin)
        }
        catch {
            Write-BotstrapWarn "post_install_windows optional ${GroupId}/${ItemName}: $($_.Exception.Message)"
        }
    }

    return $true
}

function Install-BotstrapOptionalCsv {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [string]$Csv,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    if ([string]::IsNullOrWhiteSpace($Csv)) {
        return
    }
    foreach ($raw in $Csv.Split(',')) {
        $item = $raw.Trim()
        if ([string]::IsNullOrWhiteSpace($item) -or $item -eq 'none') {
            continue
        }
        [void](Install-BotstrapOptionalItem -GroupId $GroupId -ItemName $item -RegistryPath $RegistryPath)
    }
}

function Test-BotstrapOptionalItemVerify {
    param(
        [Parameter(Mandatory)][string]$GroupId,
        [Parameter(Mandatory)][string]$ItemName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml')
    )
    if ([string]::IsNullOrWhiteSpace($ItemName) -or $ItemName -eq 'none') {
        return $true
    }
    Refresh-BotstrapPath
    Add-BotstrapMiseBinsToPath
    $verifyCmd = Get-BotstrapOptionalVerifySnippet -GroupId $GroupId -ItemName $ItemName -RegistryPath $RegistryPath
    if ([string]::IsNullOrWhiteSpace($verifyCmd)) {
        return $true
    }
    try {
        $ErrorActionPreference = 'Stop'
        Invoke-BotstrapPowerShellSnippet -Snippet $verifyCmd
        if (-not $?) {
            return $false
        }
        if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            return $false
        }
        return $true
    }
    catch {
        Write-BotstrapWarn "Optional verify failed ${GroupId}/${ItemName}: $($_.Exception.Message)"
        return $false
    }
}
