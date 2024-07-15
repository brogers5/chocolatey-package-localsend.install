$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$storeSignedPackage = Get-StoreSignedPackage
if ($null -ne $storeSignedPackage) {
    Write-Warning "A legacy store-signed version of LocalSend (v$($storeSignedPackage.Version)) was detected.
    LocalSend has since migrated to a separate developer-signed package as it was removed from the Microsoft Store.
    To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
}

$developerSignedPackage = Get-LegacyDeveloperSignedPackage
if ($null -ne $developerSignedPackage) {
    Write-Warning "A legacy developer-signed version of LocalSend (v$($developerSignedPackage.Version)) was detected.
    To prevent possible issues with installation coexistence, this version will be uninstalled."
    Uninstall-LegacyDeveloperPackage
}

$fileName = 'LocalSend-1.14.0-windows-x86-64.exe'
$filePath = Join-Path -Path $toolsDir -ChildPath $fileName

Confirm-WinMinimumBuild -ReqBuild 7601

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'EXE'
    file64         = $filePath
    softwareName   = 'LocalSend version *'
    silentArgs     = "/LOG=`"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).Install.log`" /VERYSILENT /ALLUSERS"
    validExitCodes = @(0)
}

Install-ChocolateyInstallPackage @packageArgs

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
