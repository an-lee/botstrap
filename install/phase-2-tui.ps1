#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')

if (-not (Get-Command gum -ErrorAction SilentlyContinue)) {
    Write-BotstrapWarn 'gum not found; using non-interactive defaults.'
    $env:BOTSTRAP_GIT_NAME = $env:BOTSTRAP_GIT_NAME
    $env:BOTSTRAP_GIT_EMAIL = $env:BOTSTRAP_GIT_EMAIL
    if (-not $env:BOTSTRAP_CORE_TOOLS) {
        $coreYaml = Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml'
        $rawNames = & yq -r '.tools[].name' $coreYaml 2>$null
        $parts = @($rawNames -split "`r?`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        $env:BOTSTRAP_CORE_TOOLS = $parts -join ','
    }
    if (-not $env:BOTSTRAP_EDITOR) { $env:BOTSTRAP_EDITOR = 'none' }
    if (-not $env:BOTSTRAP_LANGUAGES) { $env:BOTSTRAP_LANGUAGES = '' }
    if (-not $env:BOTSTRAP_DATABASES) { $env:BOTSTRAP_DATABASES = '' }
    if (-not $env:BOTSTRAP_AI_TOOLS) { $env:BOTSTRAP_AI_TOOLS = '' }
    if (-not $env:BOTSTRAP_THEME) { $env:BOTSTRAP_THEME = 'catppuccin' }
    if (-not $env:BOTSTRAP_OPTIONAL_APPS) { $env:BOTSTRAP_OPTIONAL_APPS = '' }
    return
}

$ErrorActionPreference = 'Continue'
& gum style --border rounded --padding '1 2' --foreground 212 'Botstrap' '' 'Cross-platform developer bootstrap.'

$ErrorActionPreference = 'Stop'
$gitNameDefault = $env:GIT_AUTHOR_NAME
if (-not $gitNameDefault) { $gitNameDefault = '' }
$gitEmailDefault = $env:GIT_AUTHOR_EMAIL
if (-not $gitEmailDefault) { $gitEmailDefault = '' }

if (-not $env:BOTSTRAP_GIT_NAME) {
    $nameArgs = if ($gitNameDefault) { @('--value', $gitNameDefault) } else { @() }
    $env:BOTSTRAP_GIT_NAME = & gum input --placeholder 'Git user name' @nameArgs
}
if (-not $env:BOTSTRAP_GIT_EMAIL) {
    $emailArgs = if ($gitEmailDefault) { @('--value', $gitEmailDefault) } else { @() }
    $env:BOTSTRAP_GIT_EMAIL = & gum input --placeholder 'Git email' @emailArgs
}

$ErrorActionPreference = 'Stop'
$coreYaml = Join-Path $env:BOTSTRAP_ROOT 'registry\core.yaml'
$coreNames = @(& yq -r '.tools[].name' $coreYaml 2>$null | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
$selectedFlag = '*'
$coreEnvFile = Join-Path $env:USERPROFILE '.config\botstrap\core-tools.env'
if (Test-Path -LiteralPath $coreEnvFile) {
    $match = @(Get-Content -LiteralPath $coreEnvFile -ErrorAction SilentlyContinue | Where-Object { $_ -match '^\s*core_tools=' } | Select-Object -First 1)
    if ($match.Count -gt 0) {
        $v = ($match[0] -replace '^\s*core_tools=', '').Trim()
        if ($v) { $selectedFlag = $v }
    }
}
$ErrorActionPreference = 'Continue'
$coreChooseArgs = @(
    'choose', '--no-limit', '--ordered',
    '--header', 'Core tools (registry/core.yaml)',
    '--selected', $selectedFlag
) + $coreNames
$coreLines = @( & gum @coreChooseArgs )
$env:BOTSTRAP_CORE_TOOLS = ($coreLines | ForEach-Object { "$_".Trim() } | Where-Object { $_ }) -join ','

$ErrorActionPreference = 'Continue'
$editorChoice = & gum choose --header 'Primary editor' cursor vscode neovim zed none
$env:BOTSTRAP_EDITOR = "$editorChoice".Trim()

$langLines = @( & gum choose --no-limit --header 'Programming languages (mise)' node python ruby go rust java elixir php none )
if ($langLines.Count -gt 0) {
    $env:BOTSTRAP_LANGUAGES = ($langLines | ForEach-Object { "$_".Trim() } | Where-Object { $_ -ne '' }) -join ','
}
else {
    $env:BOTSTRAP_LANGUAGES = ''
}

$dbLines = @( & gum choose --no-limit --header 'Databases (Docker)' postgresql mysql redis sqlite none )
if ($dbLines.Count -gt 0) {
    $env:BOTSTRAP_DATABASES = ($dbLines | ForEach-Object { "$_".Trim() } | Where-Object { $_ -ne '' }) -join ','
}
else {
    $env:BOTSTRAP_DATABASES = ''
}

$aiLines = @( & gum choose --no-limit --header 'AI agent CLIs' claude-code openclaw codex gemini ollama none )
if ($aiLines.Count -gt 0) {
    $env:BOTSTRAP_AI_TOOLS = ($aiLines | ForEach-Object { "$_".Trim() } | Where-Object { $_ -ne '' }) -join ','
}
else {
    $env:BOTSTRAP_AI_TOOLS = ''
}

$ErrorActionPreference = 'Stop'
$themeChoice = & gum choose --header 'Theme' catppuccin tokyo-night gruvbox nord rose-pine
$env:BOTSTRAP_THEME = "$themeChoice".Trim()

$ErrorActionPreference = 'Continue'
$appLines = @( & gum choose --no-limit --header 'Optional apps' 1password-cli tailscale ngrok postman none )
if ($appLines.Count -gt 0) {
    $env:BOTSTRAP_OPTIONAL_APPS = ($appLines | ForEach-Object { "$_".Trim() } | Where-Object { $_ -ne '' }) -join ','
}
else {
    $env:BOTSTRAP_OPTIONAL_APPS = ''
}

$ErrorActionPreference = 'Stop'
& gum confirm 'Apply these choices and continue?'
# gum confirm uses exit code only (no stdout); $? reflects native exit status (works on Windows PowerShell 5.1+).
if (-not $?) {
    Write-BotstrapWarn 'Aborted at confirmation; exiting.'
    exit 1
}

Write-BotstrapInfo 'Phase 2 (Windows) complete.'
