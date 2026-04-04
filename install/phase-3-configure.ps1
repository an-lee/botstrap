#requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")

$configRoot = Join-Path $env:USERPROFILE ".config\botstrap"
New-Item -ItemType Directory -Force -Path $configRoot | Out-Null
"theme=$($env:BOTSTRAP_THEME)" | Set-Content (Join-Path $configRoot "theme.env")
"editor=$($env:BOTSTRAP_EDITOR)" | Set-Content (Join-Path $configRoot "editor.env")

Write-BotstrapInfo "Phase 3 (Windows): wrote minimal botstrap config under $configRoot"
