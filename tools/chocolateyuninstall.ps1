$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

[array] $packages = Get-Packages -Publisher $developerPublisher
    
if ($packages.Count -eq 1) {
    Remove-AppxPackage -Package $packages[0]
}
elseif ($packages.Count -eq 0) {
    Write-Warning "$env:ChocolateyPackageName has already been uninstalled by other means."
}
elseif ($packages.Count -gt 1) {
    Write-Warning "$($packages.Count) matches found!"
    Write-Warning 'To prevent accidental data loss, no programs will be uninstalled.'
    Write-Warning 'Please alert package maintainer the following packages were matched:'
    $packages | ForEach-Object { Write-Warning "- $($_.PackageFullName)" }
}
