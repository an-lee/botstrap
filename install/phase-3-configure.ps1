#requires -Version 5.1
$ErrorActionPreference = 'Stop'
. (Join-Path $env:BOTSTRAP_ROOT 'lib\log.ps1')
. (Join-Path $env:BOTSTRAP_ROOT 'lib\pkg.ps1')

Refresh-BotstrapPath

if (-not $env:BOTSTRAP_THEME) { $env:BOTSTRAP_THEME = 'catppuccin' }
if (-not $env:BOTSTRAP_EDITOR) { $env:BOTSTRAP_EDITOR = 'none' }

$root = $env:BOTSTRAP_ROOT
$optionalReg = Join-Path $root 'registry\optional.yaml'

Write-BotstrapInfo 'Phase 3 (Windows): optional installs from registry'
[void](Install-BotstrapOptionalItem -GroupId 'editor' -ItemName $env:BOTSTRAP_EDITOR -RegistryPath $optionalReg)
Install-BotstrapOptionalCsv -GroupId 'languages' -Csv $env:BOTSTRAP_LANGUAGES -RegistryPath $optionalReg
Install-BotstrapOptionalCsv -GroupId 'databases' -Csv $env:BOTSTRAP_DATABASES -RegistryPath $optionalReg
Install-BotstrapOptionalCsv -GroupId 'ai_tools' -Csv $env:BOTSTRAP_AI_TOOLS -RegistryPath $optionalReg
[void](Install-BotstrapOptionalItem -GroupId 'theme' -ItemName $env:BOTSTRAP_THEME -RegistryPath $optionalReg)
Install-BotstrapOptionalCsv -GroupId 'optional_apps' -Csv $env:BOTSTRAP_OPTIONAL_APPS -RegistryPath $optionalReg

Refresh-BotstrapPath

$configBase = Join-Path $env:USERPROFILE '.config'
$configRoot = Join-Path $configBase 'botstrap'
$gitConfigDir = Join-Path $configBase 'git'

New-Item -ItemType Directory -Force -Path $configRoot | Out-Null
New-Item -ItemType Directory -Force -Path $gitConfigDir | Out-Null
"theme=$($env:BOTSTRAP_THEME)" | Set-Content (Join-Path $configRoot 'theme.env')
"editor=$($env:BOTSTRAP_EDITOR)" | Set-Content (Join-Path $configRoot 'editor.env')

$userGitconfig = Join-Path $env:USERPROFILE '.gitconfig'
$tplGitconfig = Join-Path $root 'configs\git\gitconfig'
if ((Test-Path -LiteralPath $tplGitconfig) -and -not (Test-Path -LiteralPath $userGitconfig)) {
    Copy-Item -LiteralPath $tplGitconfig -Destination $userGitconfig -Force
}

$globalGitignore = Join-Path $env:USERPROFILE '.gitignore_global'
$tplIgnore = Join-Path $root 'configs\git\gitignore_global'
if (Test-Path -LiteralPath $tplIgnore) {
    Copy-Item -LiteralPath $tplIgnore -Destination $globalGitignore -Force
    if (Get-Command git -ErrorAction SilentlyContinue) {
        & git config --global core.excludesfile $globalGitignore
    }
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    & git config --global core.longpaths true
    if ($env:BOTSTRAP_GIT_NAME) {
        & git config --global user.name $env:BOTSTRAP_GIT_NAME
    }
    if ($env:BOTSTRAP_GIT_EMAIL) {
        & git config --global user.email $env:BOTSTRAP_GIT_EMAIL
    }
}

$promptTpl = Join-Path $root 'configs\shell\prompt.toml'
$starshipOut = Join-Path $configBase 'starship.toml'
if (Test-Path -LiteralPath $promptTpl) {
    Copy-Item -LiteralPath $promptTpl -Destination $starshipOut -Force
}

switch ($env:BOTSTRAP_EDITOR) {
    'cursor' {
        $cursorDir = Join-Path $env:USERPROFILE '.cursor'
        New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null
        $cs = Join-Path $root 'configs\editor\cursor-settings.json'
        if (Test-Path -LiteralPath $cs) {
            Copy-Item -LiteralPath $cs -Destination (Join-Path $cursorDir 'settings.json') -Force
        }
    }
    'vscode' {
        $codeUser = Join-Path $env:APPDATA 'Code\User'
        New-Item -ItemType Directory -Force -Path $codeUser | Out-Null
        $vs = Join-Path $root 'configs\editor\vscode.json'
        if (Test-Path -LiteralPath $vs) {
            Copy-Item -LiteralPath $vs -Destination (Join-Path $codeUser 'settings.json') -Force
        }
    }
    'neovim' {
        $nvim = Join-Path $configBase 'nvim'
        New-Item -ItemType Directory -Force -Path $nvim | Out-Null
        $init = Join-Path $root 'configs\editor\neovim\init.lua'
        if (Test-Path -LiteralPath $init) {
            Copy-Item -LiteralPath $init -Destination (Join-Path $nvim 'init.lua') -Force
        }
    }
    default { }
}

$agentDir = Join-Path $configRoot 'agent'
New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
Copy-Item -LiteralPath (Join-Path $root 'configs\agent\AGENTS.md') -Destination (Join-Path $agentDir 'AGENTS.md.sample') -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $root 'configs\agent\cursorrules') -Destination (Join-Path $agentDir 'cursorrules.sample') -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $root 'configs\agent\claude-config.json') -Destination (Join-Path $agentDir 'claude-config.json.sample') -Force -ErrorAction SilentlyContinue

function Add-BotstrapProfileBlock {
    param(
        [Parameter(Mandatory)][string]$ProfilePath,
        [Parameter(Mandatory)][string]$Marker,
        [Parameter(Mandatory)][string]$Block
    )
    $dir = Split-Path -Parent $ProfilePath
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        New-Item -ItemType File -Force -Path $ProfilePath | Out-Null
    }
    $existing = Get-Content -LiteralPath $ProfilePath -Raw -ErrorAction SilentlyContinue
    if ($existing -and $existing.Contains("# $Marker")) {
        return
    }
    Add-Content -LiteralPath $ProfilePath -Value "`n# $Marker`n$Block`n"
}

$profilePath = $PROFILE
if ([string]::IsNullOrWhiteSpace($profilePath)) {
    $profileDir = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell'
    $profilePath = Join-Path $profileDir 'Microsoft.PowerShell_profile.ps1'
}

$starshipBlock = @'
if (Get-Command starship -ErrorAction SilentlyContinue) {
  Invoke-Expression (&starship init powershell)
}
'@

$zoxideBlock = @'
$env:PATH = "$env:LOCALAPPDATA\mise\bin;$env:USERPROFILE\.local\bin;$env:PATH"
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
'@

$aliasesBlock = @'
if (Get-Command bat -ErrorAction SilentlyContinue) {
  Set-Alias -Name cat -Value bat -Scope Global -Force -ErrorAction SilentlyContinue
}
if (-not (Get-Command BotstrapLl -ErrorAction SilentlyContinue)) {
  function Global:BotstrapLl {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
      & eza -la @args
    }
    else {
      Get-ChildItem @args
    }
  }
}
Set-Alias -Name ll -Value BotstrapLl -Scope Global -Force -ErrorAction SilentlyContinue
'@

Add-BotstrapProfileBlock -ProfilePath $profilePath -Marker 'botstrap starship' -Block $starshipBlock
Add-BotstrapProfileBlock -ProfilePath $profilePath -Marker 'botstrap zoxide' -Block $zoxideBlock
Add-BotstrapProfileBlock -ProfilePath $profilePath -Marker 'botstrap aliases' -Block $aliasesBlock

Write-BotstrapInfo "Phase 3 (Windows): config under $configRoot (git, editor=$($env:BOTSTRAP_EDITOR), theme=$($env:BOTSTRAP_THEME)); profile: $profilePath"
