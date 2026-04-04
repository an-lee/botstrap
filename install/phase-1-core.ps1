#requires -Version 5.1
$ErrorActionPreference = 'Continue'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'lib\pkg.ps1')

if (-not (Get-Command yq -ErrorAction SilentlyContinue)) {
    Write-BotstrapErr 'yq missing; re-run phase-0-prerequisites.ps1.'
    exit 1
}

$coreYaml = Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml'
$names = & yq -r '.tools[].name' $coreYaml 2>$null
if (-not $names) {
    Write-BotstrapErr "Could not read tools from $coreYaml"
    exit 1
}

foreach ($line in @($names -split "`r?`n")) {
    $tool = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($tool)) { continue }
    $ok = Install-BotstrapPackageFromRegistry -ToolName $tool -RegistryPath $coreYaml
    if (-not $ok) {
        Write-BotstrapWarn "Phase 1 reported a problem for ${tool} (continuing)."
    }
}

Write-BotstrapInfo 'Phase 1 (Windows) complete.'
