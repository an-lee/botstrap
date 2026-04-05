#requires -Version 5.1
# Clone LazyVim starter into %LOCALAPPDATA%\nvim. Idempotent.

function Install-BotstrapLazyVim {
    $root = $env:BOTSTRAP_ROOT
    if ([string]::IsNullOrWhiteSpace($root)) {
        throw 'BOTSTRAP_ROOT must be set'
    }
    . (Join-Path $root 'lib\log.ps1')

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-BotstrapErr 'git is required to install the LazyVim starter.'
        throw 'git not found'
    }

    $nvimDir = Join-Path $env:LOCALAPPDATA 'nvim'
    $lazyLua = Join-Path $nvimDir 'lua\config\lazy.lua'
    $starterUrl = 'https://github.com/LazyVim/starter'

    if (Test-Path -LiteralPath $lazyLua) {
        Write-BotstrapInfo "LazyVim starter already present ($lazyLua); skipping clone."
        return
    }

    $isEmptyOrMissing = $false
    if (-not (Test-Path -LiteralPath $nvimDir)) {
        $isEmptyOrMissing = $true
    }
    else {
        $children = @(Get-ChildItem -LiteralPath $nvimDir -Force -ErrorAction SilentlyContinue)
        if ($children.Count -eq 0) { $isEmptyOrMissing = $true }
    }

    if ($isEmptyOrMissing) {
        if (Test-Path -LiteralPath $nvimDir) {
            Remove-Item -LiteralPath $nvimDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-BotstrapInfo "Installing LazyVim starter into $nvimDir"
        & git clone --filter=blob:none $starterUrl $nvimDir
        $gitDir = Join-Path $nvimDir '.git'
        if (Test-Path -LiteralPath $gitDir) {
            Remove-Item -LiteralPath $gitDir -Recurse -Force
        }
        return
    }

    $initLua = Join-Path $nvimDir 'init.lua'
    $luaDir = Join-Path $nvimDir 'lua'
    if ((Test-Path -LiteralPath $initLua) -and -not (Test-Path -LiteralPath $luaDir)) {
        $backup = "${nvimDir}.botstrap.bak"
        if (Test-Path -LiteralPath $backup) {
            $backup = "${nvimDir}.botstrap.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
        }
        Write-BotstrapInfo "Backing up existing Neovim config to $backup"
        Move-Item -LiteralPath $nvimDir -Destination $backup -Force
        Write-BotstrapInfo "Installing LazyVim starter into $nvimDir"
        & git clone --filter=blob:none $starterUrl $nvimDir
        $gitDir = Join-Path $nvimDir '.git'
        if (Test-Path -LiteralPath $gitDir) {
            Remove-Item -LiteralPath $gitDir -Recurse -Force
        }
        return
    }

    Write-BotstrapWarn "Existing $nvimDir has a custom layout; not replacing with LazyVim."
}
