#requires -Version 5.1
# Shared Git bootstrap for Windows (phase-0-prerequisites.ps1). boot.ps1 inlines the
# same functions so irm | iex works without a script path; keep both copies aligned.

function Update-BotstrapPathFromRegistry {
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [System.Environment]::GetEnvironmentVariable("Path", "User")
    if ($machine -or $user) {
        $env:Path = "${machine};${user}"
    }
}

function Test-BotstrapGitAvailable {
    return [bool](Get-Command git -ErrorAction SilentlyContinue)
}

function Install-BotstrapGitIfNeeded {
    if (Test-BotstrapGitAvailable) {
        return
    }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "[botstrap] Git not found; installing via winget..."
        winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        Update-BotstrapPathFromRegistry
    }
    if (-not (Test-BotstrapGitAvailable)) {
        $gitCmd = "C:\Program Files\Git\cmd\git.exe"
        if (Test-Path $gitCmd) {
            $env:Path = "C:\Program Files\Git\cmd;" + $env:Path
        }
    }
}
