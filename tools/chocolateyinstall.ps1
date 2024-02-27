$ErrorActionPreference = 'Stop'

Confirm-Win10 -ReqBuild 19041

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$storeSignedPackage = Get-StoreSignedPackage
if ($null -ne $storeSignedPackage) {
    Write-Warning "A legacy version of LocalSend (v$($storeSignedPackage.Version)) was detected.
    LocalSend has migrated to a developer-signed package since it was removed from the Microsoft Store.
    To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
}

$msixFileName = 'LocalSend-1.14.0-windows-x86-64.msix'
$msixFilePath = Join-Path -Path $toolsDir -ChildPath $msixFileName

$dismImageObject = Add-AppxProvisionedPackage -PackagePath $msixFilePath -Online -SkipLicense
if ($dismImageObject.RestartNeeded) {
    Set-PowerShellExitCode -ExitCode 3010
}

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $msixFilePath -Force -ErrorAction SilentlyContinue
