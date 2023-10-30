$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'localsend.install.nuspec'

[xml] $nuspec = Get-Content $nuspecFileRelativePath
$version = $nuspec.package.metadata.version

$global:Latest = @{
    FileType = 'msix'
    Url64 = Get-SoftwareMsixUri -Version $version
}

Write-Output 'Downloading MSIX...'
Get-RemoteFiles -Purge -NoSuffix

$global:Latest = @{
    FileType = 'exe'
    Url64 = Get-SoftwareExeUri -Version $version
}

Write-Output 'Downloading EXE...'
Get-RemoteFiles -Purge -NoSuffix

Write-Output 'Creating package...'
choco pack $nuspecFileRelativePath
