$ErrorActionPreference = 'Stop'

Confirm-Win10 -ReqBuild 19041

$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$storeSignedPackage = Get-StoreSignedPackage
if ($null -ne $storeSignedPackage) {
    Write-Warning "A legacy version of LocalSend (v$($storeSignedPackage.Version)) was detected.
    LocalSend has migrated to a developer-signed package since it was removed from the Microsoft Store.
    To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
}

$msixFileName = 'LocalSend-1.11.1-windows-x86-64.msix'
$msixFilePath = Join-Path -Path $toolsDir -ChildPath $msixFileName

[version] $softwareVersion = '1.11.1'
$currentVersion = Get-CurrentVersion
$shouldForceUpdate = ($softwareVersion -lt $currentVersion)

Add-AppxPackage -Path $msixFilePath -ForceUpdateFromAnyVersion:$shouldForceUpdate -ForceApplicationShutdown

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $msixFilePath -Force -ErrorAction SilentlyContinue
