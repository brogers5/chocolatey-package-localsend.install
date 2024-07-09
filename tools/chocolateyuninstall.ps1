$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

[array] $packages = Get-Packages -Publisher $developerPublisher
    
if ($packages.Count -eq 1) {
    Remove-AppxPackage -Package $packages[0] -AllUsers
}

$exePackages = [array] (Get-UninstallRegistryKey -SoftwareName $exeSoftwareNamePattern)
if ($null -ne $exePackages) {
    $programs.AddRange($exePackages)
}

if ($programs.Count -eq 1) {
    $program = $programs[0]

    if ($program.GetType().Name -eq 'PSCustomObject') {
        $packageArgs = @{
            packageName    = $env:ChocolateyPackageName
            fileType       = 'EXE'
            file           = $program.UninstallString
            softwareName   = 'LocalSend version *'
            silentArgs     = '/VERYSILENT /norestart'
            validExitCodes = @(0)
        }

        Uninstall-ChocolateyPackage @packageArgs
    }
    else {
        Remove-AppxPackage -Package $program -AllUsers
    }
}
elseif ($programs.Count -eq 0) {
    Write-Warning "$env:ChocolateyPackageName has already been uninstalled by other means."
}
elseif ($programs.Count -gt 1) {
    Write-Warning "$($programs.Count) matches found!"
    Write-Warning 'To prevent accidental data loss, no programs will be uninstalled by the package.'
    Write-Warning 'The Auto Uninstaller service may still run if enabled, and if a registry snapshot was captured during install.'
    Write-Warning 'The following programs were matched:'
    $programs | ForEach-Object { 
        if ($_.GetType().Name -eq 'PSCustomObject') {
            Write-Warning "- $($_.DisplayName)"
        }
        else {
            Write-Warning "- $($_.PackageFullName)"
        }
    }
    Write-Warning 'If multiple LocalSend installations were detected, these may need to be uninstalled manually.'
    Write-Warning 'If non-LocalSend programs were detected, please alert the package''s maintainer.'
}
