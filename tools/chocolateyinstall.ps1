$ErrorActionPreference = 'Stop'

Confirm-WinMinimumBuild -ReqBuild 7601

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

#Only check for legacy packages on Windows 10+
#These functions use cmdlets and/or parameters that did not exist prior to Server 2012 R2
if ([Environment]::OSVersion.Version.Major -ge 10) {
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
}

$fileName = 'LocalSend-1.15.3-windows-x86-64.exe'
$filePath = Join-Path -Path $toolsDir -ChildPath $fileName

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
