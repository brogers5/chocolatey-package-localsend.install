$ErrorActionPreference = 'Stop'

$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

$storeSignedPackage = Get-StoreSignedPackage
if ($null -ne $storeSignedPackage) {
    Write-Warning "A legacy version of LocalSend (v$($storeSignedPackage.Version)) was detected.
    LocalSend has migrated to a developer-signed package since it was removed from the Microsoft Store.
    To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
}

$msixFileName = 'LocalSend-1.12.0-windows-x86-64.msix'
$exeFileName = 'LocalSend-1.12.0-windows-x86-64.exe'

$msixFilePath = Join-Path -Path $toolsDir -ChildPath $msixFileName
$exeFilePath = Join-Path -Path $toolsDir -ChildPath $exeFileName

[version] $softwareVersion = '1.12.0'
$pp = Get-PackageParameters
if ($pp.UseMsix) {
    Write-Output 'Forcing use of MSIX installer package'
    $currentVersion = Get-CurrentMsixVersion
    $useMsix = $true

    $exeVersion = Get-CurrentExeVersion
    if ($null -ne $exeVersion) {
        Write-Warning "An existing EXE installation of LocalSend (v$exeVersion) was detected.
        To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
    }
}
elseif ($pp.UseExe) {
    Write-Output 'Forcing use of EXE installer package'
    $currentVersion = Get-CurrentExeVersion
    $useExe = $true

    $msixVersion = Get-CurrentMsixVersion
    if ($null -ne $msixVersion) {
        Write-Warning "An existing MSIX installation of LocalSend (v$msixVersion) was detected.
        To prevent possible issues with package coexistence, please manually uninstall this version at your earliest convenience."
    }
}
else {
    Write-Output 'No package preference was defined'

    $exeVersion = Get-CurrentExeVersion
    if ($null -eq $exeVersion) {
        Write-Output 'Could not find EXE installation, checking for developer-signed MSIX installation'

        $msixVersion = Get-CurrentMsixVersion
        if ($null -ne $msixVersion) {
            Write-Output "Existing MSIX installation (v$msixVersion) was detected, using MSIX package"
            $useMsix = $true
        }
        else {
            Write-Output 'No supported installation was detected, defaulting to EXE package'
            $useExe = $true
        }
    }
    else {
        Write-Output "Existing EXE installation (v$exeVersion) was detected, using EXE package"
        $useExe = $true
    }
}

if ($useExe) {
    Confirm-WinMinimumBuild -ReqBuild 7601

    $packageArgs = @{
        packageName    = $env:ChocolateyPackageName
        fileType       = 'EXE'
        file64         = $exeFilePath
        softwareName   = 'LocalSend version *'
        silentArgs     = "/LOG=`"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).Install.log`" /VERYSILENT /ALLUSERS"
        validExitCodes = @(0)
    }

    Install-ChocolateyInstallPackage @packageArgs
}
elseif ($useMsix) {
    Confirm-Win10 -ReqBuild 19041

    $shouldForceUpdate = ($softwareVersion -lt $currentVersion)
    Add-AppxPackage -Path $msixFilePath -ForceUpdateFromAnyVersion:$shouldForceUpdate -ForceApplicationShutdown
}

#Remove installer binaries post-install to prevent disk bloat
Remove-Item -Path $msixFilePath -Force -ErrorAction SilentlyContinue
Remove-Item -Path $exeFilePath -Force -ErrorAction SilentlyContinue
