function Install-BotstrapPackageFromRegistry {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT "registry\core.yaml")
    )
    Write-BotstrapWarn "Windows registry-driven install is not fully implemented yet for '${ToolName}'."
    Write-BotstrapWarn "Install manually or use WSL and run install.sh. Registry: ${RegistryPath}"
}

function Test-BotstrapPackageFromRegistry {
    param(
        [Parameter(Mandatory)][string]$ToolName,
        [string]$RegistryPath = (Join-Path $env:BOTSTRAP_ROOT "registry\core.yaml")
    )
    Write-BotstrapWarn "pkg_verify stub for '${ToolName}' (${RegistryPath})."
}
