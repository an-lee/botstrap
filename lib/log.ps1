function Write-BotstrapInfo {
    param([string]$Message)
    Write-Host "[botstrap] $Message" -ForegroundColor Cyan
}

function Write-BotstrapWarn {
    param([string]$Message)
    Write-Host "[botstrap] $Message" -ForegroundColor Yellow
}

function Write-BotstrapErr {
    param([string]$Message)
    Write-Host "[botstrap] $Message" -ForegroundColor Red
}
