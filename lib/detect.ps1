function Get-BotstrapEnvironment {
    if ($PSVersionTable.PSEdition -eq "Core") {
        if ($IsWindows) {
            $script:BotstrapOS = "windows"
            $script:BotstrapDistro = "windows"
            $script:BotstrapPkg = "winget"
        }
        elseif ($IsMacOS) {
            $script:BotstrapOS = "darwin"
            $script:BotstrapDistro = "darwin"
            $script:BotstrapPkg = "brew"
        }
        elseif ($IsLinux) {
            $script:BotstrapOS = "linux"
            $script:BotstrapDistro = "unknown"
            $script:BotstrapPkg = "unknown"
            if (Test-Path /etc/os-release) {
                $release = Get-Content /etc/os-release -Raw
                if ($release -match 'ID=(.+)') {
                    $script:BotstrapDistro = $Matches[1].Trim('"')
                }
                switch -Regex ($script:BotstrapDistro) {
                    "ubuntu|debian" { $script:BotstrapPkg = "apt" }
                    "fedora|rhel|centos|rocky|alma" { $script:BotstrapPkg = "dnf" }
                    "arch|endeavouros|manjaro" { $script:BotstrapPkg = "pacman" }
                    default { $script:BotstrapPkg = "apt" }
                }
            }
        }
        else {
            $script:BotstrapOS = "unknown"
            $script:BotstrapDistro = "unknown"
            $script:BotstrapPkg = "unknown"
        }
    }
    else {
        $script:BotstrapOS = "windows"
        $script:BotstrapDistro = "windows"
        $script:BotstrapPkg = "winget"
    }
}
