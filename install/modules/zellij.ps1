# Zellij Windows: set default_shell in config.kdl so new panes use PowerShell, not cmd.exe.
# Expects Write-Botstrap* from lib/log.ps1 (Phase 3 loads log before dot-sourcing this file).

function Get-BotstrapZellijConfigDirectory {
    if (Get-Command zellij -ErrorAction SilentlyContinue) {
        try {
            $ErrorActionPreference = 'Continue'
            $raw = & zellij setup --check 2>&1
            $lines = @($raw | ForEach-Object { "$_" })
            $text = $lines -join "`n"
            $m = [regex]::Match($text, '\[CONFIG DIR\]:\s*"([^"]+)"')
            if ($m.Success) {
                $dir = $m.Groups[1].Value.Trim()
                if ($dir -and $dir -ne 'Not Found') {
                    return $dir
                }
            }
        }
        catch {
            # Use fallbacks below.
        }
    }

    $homeZellij = Join-Path $env:USERPROFILE '.config\zellij'
    $appDataZellij = Join-Path $env:APPDATA 'Zellij\config'
    $kdlHome = Join-Path $homeZellij 'config.kdl'
    $kdlApp = Join-Path $appDataZellij 'config.kdl'
    if (Test-Path -LiteralPath $kdlHome) {
        return $homeZellij
    }
    if (Test-Path -LiteralPath $kdlApp) {
        return $appDataZellij
    }
    return $homeZellij
}

function Initialize-BotstrapZellijWindowsConfig {
    $shellCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $shellCmd) {
        $shellCmd = Get-Command powershell -ErrorAction SilentlyContinue
    }
    if (-not $shellCmd) {
        Write-BotstrapWarn 'Zellij: pwsh and powershell not on PATH; skipping default_shell in config.kdl'
        return
    }

    $fullPath = [System.IO.Path]::GetFullPath($shellCmd.Source)
    $kdlPath = $fullPath -replace '\\', '/'
    $newLine = "default_shell `"$kdlPath`""
    $markerLine = '// botstrap: default_shell (Windows)'

    $configDir = Get-BotstrapZellijConfigDirectory
    New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    $configFile = Join-Path $configDir 'config.kdl'

    $pattern = '^\s*default_shell\s+"[^"]*"\s*\r?$'
    $rx = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

    if (Test-Path -LiteralPath $configFile) {
        $content = Get-Content -LiteralPath $configFile -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) { $content = '' }
        $first = $rx.Match($content)
        if ($first.Success) {
            $updated = $content.Substring(0, $first.Index) + $newLine + $content.Substring($first.Index + $first.Length)
        }
        else {
            $block = "$markerLine`r`n$newLine`r`n`r`n"
            $updated = $block + $content
        }
    }
    else {
        $updated = "$markerLine`r`n$newLine`r`n"
    }

    Set-Content -LiteralPath $configFile -Value $updated -Encoding utf8
    Write-BotstrapInfo "Zellij: default_shell -> $kdlPath ($configFile)"
}
