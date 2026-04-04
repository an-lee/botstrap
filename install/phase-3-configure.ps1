#requires -Version 5.1
$ErrorActionPreference = "Stop"
. (Join-Path $env:BOTSTRAP_ROOT "lib\log.ps1")

$root = $env:BOTSTRAP_ROOT
$configBase = Join-Path $env:USERPROFILE ".config"
$configRoot = Join-Path $configBase "botstrap"
$gitConfigDir = Join-Path $configBase "git"

New-Item -ItemType Directory -Force -Path $configRoot | Out-Null
New-Item -ItemType Directory -Force -Path $gitConfigDir | Out-Null
"theme=$($env:BOTSTRAP_THEME)" | Set-Content (Join-Path $configRoot "theme.env")
"editor=$($env:BOTSTRAP_EDITOR)" | Set-Content (Join-Path $configRoot "editor.env")

$userGitconfig = Join-Path $env:USERPROFILE ".gitconfig"
$tplGitconfig = Join-Path $root "configs\git\gitconfig"
if ((Test-Path -LiteralPath $tplGitconfig) -and -not (Test-Path -LiteralPath $userGitconfig)) {
    Copy-Item -LiteralPath $tplGitconfig -Destination $userGitconfig -Force
}

$globalGitignore = Join-Path $env:USERPROFILE ".gitignore_global"
$tplIgnore = Join-Path $root "configs\git\gitignore_global"
if (Test-Path -LiteralPath $tplIgnore) {
    Copy-Item -LiteralPath $tplIgnore -Destination $globalGitignore -Force
    if (Get-Command git -ErrorAction SilentlyContinue) {
        & git config --global core.excludesfile $globalGitignore
    }
}

if ((Get-Command git -ErrorAction SilentlyContinue)) {
    & git config --global core.longpaths true
    if ($env:BOTSTRAP_GIT_NAME) {
        & git config --global user.name $env:BOTSTRAP_GIT_NAME
    }
    if ($env:BOTSTRAP_GIT_EMAIL) {
        & git config --global user.email $env:BOTSTRAP_GIT_EMAIL
    }
}

$promptTpl = Join-Path $root "configs\shell\prompt.toml"
$starshipOut = Join-Path $configBase "starship.toml"
if (Test-Path -LiteralPath $promptTpl) {
    Copy-Item -LiteralPath $promptTpl -Destination $starshipOut -Force
}

switch ($env:BOTSTRAP_EDITOR) {
    "cursor" {
        $cursorDir = Join-Path $env:USERPROFILE ".cursor"
        New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null
        $cs = Join-Path $root "configs\editor\cursor-settings.json"
        if (Test-Path -LiteralPath $cs) {
            Copy-Item -LiteralPath $cs -Destination (Join-Path $cursorDir "settings.json") -Force
        }
    }
    "vscode" {
        $codeUser = Join-Path $env:APPDATA "Code\User"
        New-Item -ItemType Directory -Force -Path $codeUser | Out-Null
        $vs = Join-Path $root "configs\editor\vscode.json"
        if (Test-Path -LiteralPath $vs) {
            Copy-Item -LiteralPath $vs -Destination (Join-Path $codeUser "settings.json") -Force
        }
    }
    "neovim" {
        $nvim = Join-Path $configBase "nvim"
        New-Item -ItemType Directory -Force -Path $nvim | Out-Null
        $init = Join-Path $root "configs\editor\neovim\init.lua"
        if (Test-Path -LiteralPath $init) {
            Copy-Item -LiteralPath $init -Destination (Join-Path $nvim "init.lua") -Force
        }
    }
    default { }
}

$agentDir = Join-Path $configRoot "agent"
New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
Copy-Item -LiteralPath (Join-Path $root "configs\agent\AGENTS.md") -Destination (Join-Path $agentDir "AGENTS.md.sample") -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $root "configs\agent\cursorrules") -Destination (Join-Path $agentDir "cursorrules.sample") -Force -ErrorAction SilentlyContinue
Copy-Item -LiteralPath (Join-Path $root "configs\agent\claude-config.json") -Destination (Join-Path $agentDir "claude-config.json.sample") -Force -ErrorAction SilentlyContinue

Write-BotstrapInfo "Phase 3 (Windows): config under $configRoot (git, editor=$($env:BOTSTRAP_EDITOR), theme=$($env:BOTSTRAP_THEME))."
