#requires -Version 5.1
$ErrorActionPreference = 'Continue'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'lib\pkg.ps1')

Write-BotstrapInfo 'Phase 4 (Windows): verify core and optional tools'

if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'yq missing; cannot verify registry.'
    exit 1
}

$coreYaml = Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml'
$optionalYaml = Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml'

$toolNames = & yq -r '.tools[].name' $coreYaml 2>$null
$failures = 0

foreach ($line in @($toolNames -split "`r?`n")) {
    $t = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($t)) { continue }
    if (-not (Test-BotstrapPackageFromRegistry -ToolName $t -RegistryPath $coreYaml)) {
        Write-BotstrapWarn "Verify failed: $t"
        $failures++
    }
}

if (-not $env:BOTSTRAP_THEME) { $env:BOTSTRAP_THEME = 'catppuccin' }
if (-not $env:BOTSTRAP_EDITOR) { $env:BOTSTRAP_EDITOR = 'none' }

Write-BotstrapInfo 'Phase 4 (Windows): verify optional selections'
if (-not (Test-BotstrapOptionalItemVerify -GroupId 'editor' -ItemName $env:BOTSTRAP_EDITOR -RegistryPath $optionalYaml)) {
    $failures++
}

foreach ($raw in @(@($env:BOTSTRAP_LANGUAGES -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne 'none' })) {
    if (-not (Test-BotstrapOptionalItemVerify -GroupId 'languages' -ItemName $raw -RegistryPath $optionalYaml)) {
        $failures++
    }
}
foreach ($raw in @(@($env:BOTSTRAP_DATABASES -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne 'none' })) {
    if (-not (Test-BotstrapOptionalItemVerify -GroupId 'databases' -ItemName $raw -RegistryPath $optionalYaml)) {
        $failures++
    }
}
foreach ($raw in @(@($env:BOTSTRAP_AI_TOOLS -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne 'none' })) {
    if (-not (Test-BotstrapOptionalItemVerify -GroupId 'ai_tools' -ItemName $raw -RegistryPath $optionalYaml)) {
        $failures++
    }
}
if (-not (Test-BotstrapOptionalItemVerify -GroupId 'theme' -ItemName $env:BOTSTRAP_THEME -RegistryPath $optionalYaml)) {
    $failures++
}
foreach ($raw in @(@($env:BOTSTRAP_OPTIONAL_APPS -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -and $_ -ne 'none' })) {
    if (-not (Test-BotstrapOptionalItemVerify -GroupId 'optional_apps' -ItemName $raw -RegistryPath $optionalYaml)) {
        $failures++
    }
}

$__botstrapIsWin = ($env:OS -eq 'Windows_NT')
if (-not $__botstrapIsWin -and $null -ne $PSVersionTable.PSPlatform) {
    $__botstrapIsWin = ($PSVersionTable.PSPlatform -eq 'Win32NT')
}
if ($__botstrapIsWin) {
    . (Join-Path $env:BOTSTRAP_ROOT 'lib\os-tune-windows.ps1')
    Write-BotstrapInfo 'OS developer tuning status:'
    foreach ($line in Get-BotstrapWindowsOsTuneDoctorLines) {
        Write-Host "  $line"
    }
}

$verPath = Join-Path $env:BOTSTRAP_ROOT 'version'
$verText = 'unknown'
if (Test-Path -LiteralPath $verPath) {
    $verText = (Get-Content -LiteralPath $verPath -Raw).Trim()
}
Write-BotstrapInfo "Verification finished with $failures failure(s)."
Write-BotstrapInfo "Version file: $verText"
Write-BotstrapInfo "Re-run TUI: . `"$($env:BOTSTRAP_ROOT)\install\phase-2-tui.ps1`" then . `"$($env:BOTSTRAP_ROOT)\install\phase-3-configure.ps1`""

if ($failures -gt 0) {
    exit 1
}
