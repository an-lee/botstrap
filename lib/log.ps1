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

function Write-BotstrapPhase {
    param(
        [int]$Num,
        [int]$Total,
        [string]$Label
    )
    $text = "Step $Num/${Total}: $Label"
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        Write-Host ''
        & gum style --border rounded --padding "0 2" --border-foreground 212 $text
    }
    else {
        Write-Host ''
        Write-Host "== $text ==" -ForegroundColor Magenta
        Write-Host ''
    }
}

function Write-BotstrapStep {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Label,
        [string]$Activity = 'Botstrap'
    )
    Write-BotstrapInfo "[$Current/$Total] $Label"
    if ($Total -gt 0) {
        $pct = [math]::Round(100.0 * $Current / $Total)
        Write-Progress -Activity $Activity -Status $Label -PercentComplete $pct -Id 0
    }
}

function Write-BotstrapProgressComplete {
    param([string]$Activity = 'Botstrap')
    Write-Progress -Activity $Activity -Id 0 -Completed
}
