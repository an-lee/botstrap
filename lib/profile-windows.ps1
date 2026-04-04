#requires -Version 5.1
# Windows native PowerShell: profile paths for Windows PowerShell 5.1 and PowerShell 7 (pwsh), plus current host.

function Get-BotstrapWindowsPowerShellProfilePaths {
    $ordered = New-Object System.Collections.Generic.List[string]
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' @([StringComparer]::OrdinalIgnoreCase)
    function Add-BotstrapProfilePathCandidate {
        param([Parameter(Mandatory)][string]$Path)
        $full = [System.IO.Path]::GetFullPath($Path)
        if ($seen.Add($full)) {
            [void]$ordered.Add($full)
        }
    }
    Add-BotstrapProfilePathCandidate -Path (Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
    Add-BotstrapProfilePathCandidate -Path (Join-Path $env:USERPROFILE 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1')
    if (-not [string]::IsNullOrWhiteSpace($PROFILE)) {
        Add-BotstrapProfilePathCandidate -Path $PROFILE
    }
    return @($ordered)
}
