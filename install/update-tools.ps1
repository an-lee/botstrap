#requires -Version 5.1
# Registry-driven upgrades for prerequisites, selected core, and persisted optional selections.
$ErrorActionPreference = 'Stop'

if (-not $env:BOTSTRAP_ROOT) {
    $Root = Split-Path -Parent $PSScriptRoot
    $env:BOTSTRAP_ROOT = $Root
}

. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'lib\pkg.ps1')

Refresh-BotstrapPath
Add-BotstrapMiseBinsToPath

$prereqReg = Join-Path $env:BOTSTRAP_ROOT 'registry\prerequisites.yaml'
$coreReg = Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml'
$optionalReg = Join-Path $env:BOTSTRAP_ROOT 'registry\optional.yaml'
$configRoot = Join-Path $env:USERPROFILE '.config\botstrap'
$optionalSel = Join-Path $configRoot 'optional-selections.env'
$editorEnv = Join-Path $configRoot 'editor.env'
$themeEnv = Join-Path $configRoot 'theme.env'

function Get-BotstrapKvFromFile {
    param(
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)][string]$FilePath
    )
    if (-not (Test-Path -LiteralPath $FilePath)) {
        return $null
    }
    $match = @(Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue | Where-Object { $_ -match "^\s*${Key}=" } | Select-Object -First 1)
    if ($match.Count -eq 0) {
        return $null
    }
    return ($match[0] -replace "^\s*${Key}=", '').Trim()
}

Write-BotstrapInfo "Update tools: prerequisites ($prereqReg)"
$preNames = @(& yq -r '.tools[].name' $prereqReg 2>$null | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
foreach ($tname in $preNames) {
    [void](Update-BotstrapCoreToolFromRegistry -ToolName $tname -RegistryPath $prereqReg)
}

$coreNames = @(Get-BotstrapCoreToolNamesForVerify)
$coreCsv = ($coreNames | Where-Object { $_ }) -join ','
Write-BotstrapInfo "Update tools: core (resolved selection, $coreReg)"
Update-BotstrapCoreToolsFromCsv -Csv $coreCsv -RegistryPath $coreReg

$editor = [Environment]::GetEnvironmentVariable('BOTSTRAP_EDITOR', 'Process')
if ([string]::IsNullOrWhiteSpace($editor)) {
    $editor = Get-BotstrapKvFromFile -Key 'editor' -FilePath $editorEnv
}
if ([string]::IsNullOrWhiteSpace($editor)) { $editor = 'none' }

$theme = [Environment]::GetEnvironmentVariable('BOTSTRAP_THEME', 'Process')
if ([string]::IsNullOrWhiteSpace($theme)) {
    $theme = Get-BotstrapKvFromFile -Key 'theme' -FilePath $themeEnv
}
if ([string]::IsNullOrWhiteSpace($theme)) { $theme = 'catppuccin' }

$langs = [Environment]::GetEnvironmentVariable('BOTSTRAP_LANGUAGES', 'Process')
if ([string]::IsNullOrWhiteSpace($langs)) {
    $langs = Get-BotstrapKvFromFile -Key 'languages' -FilePath $optionalSel
}
if ($null -eq $langs) { $langs = '' }

$dbs = [Environment]::GetEnvironmentVariable('BOTSTRAP_DATABASES', 'Process')
if ([string]::IsNullOrWhiteSpace($dbs)) {
    $dbs = Get-BotstrapKvFromFile -Key 'databases' -FilePath $optionalSel
}
if ($null -eq $dbs) { $dbs = '' }

$ai = [Environment]::GetEnvironmentVariable('BOTSTRAP_AI_TOOLS', 'Process')
if ([string]::IsNullOrWhiteSpace($ai)) {
    $ai = Get-BotstrapKvFromFile -Key 'ai_tools' -FilePath $optionalSel
}
if ($null -eq $ai) { $ai = '' }

$apps = [Environment]::GetEnvironmentVariable('BOTSTRAP_OPTIONAL_APPS', 'Process')
if ([string]::IsNullOrWhiteSpace($apps)) {
    $apps = Get-BotstrapKvFromFile -Key 'optional_apps' -FilePath $optionalSel
}
if ($null -eq $apps) { $apps = '' }

Write-BotstrapInfo "Update tools: optional registry ($optionalReg)"
[void](Update-BotstrapOptionalItemFromRegistry -GroupId 'editor' -ItemName $editor -RegistryPath $optionalReg)
Update-BotstrapOptionalItemsFromCsv -GroupId 'languages' -Csv $langs -RegistryPath $optionalReg
Update-BotstrapOptionalItemsFromCsv -GroupId 'databases' -Csv $dbs -RegistryPath $optionalReg
Update-BotstrapOptionalItemsFromCsv -GroupId 'ai_tools' -Csv $ai -RegistryPath $optionalReg
[void](Update-BotstrapOptionalItemFromRegistry -GroupId 'theme' -ItemName $theme -RegistryPath $optionalReg)
Update-BotstrapOptionalItemsFromCsv -GroupId 'optional_apps' -Csv $apps -RegistryPath $optionalReg

Write-BotstrapInfo 'Update tools finished.'
