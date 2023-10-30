Import-Module au

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$toolsDir = Join-Path -Path $currentPath -ChildPath 'tools'
$softwareRepo = 'localsend/localsend'

function global:au_GetLatest {
    $version = Get-LatestStableVersion
    $msixUri = Get-SoftwareMsixUri
    $exeUri = Get-SoftwareExeUri

    return @{
        ExeUrl64        = $exeUri
        FileType        = 'msix'
        MsixUrl64       = $msixUri
        SoftwareVersion = $version
        Url64           = $msixUri
        Version         = $version #This may change if building a package fix version
    }
}

function global:au_BeforeUpdate($Package) {
    $Latest.ChecksumType64 = 'SHA256'

    Get-RemoteFiles -Purge -NoSuffix -Algorithm $Latest.ChecksumType64
    #Persist the MSIX's values before running Get-RemoteFiles again for the EXE, which will change the source variables
    $Latest.MsixFileName64 = $Latest.FileName64
    $Latest.MsixChecksum64 = $Latest.Checksum64

    #Set up for the EXE package
    $Latest.FileName64 = ([uri] $Latest.ExeUrl64).Segments[-1]
    $Latest.FileType = 'exe'
    $Latest.Url64 = $Latest.ExeUrl64

    Get-RemoteFiles -Purge -NoSuffix -Algorithm $Latest.ChecksumType64
    $Latest.ExeFileName64 = $Latest.FileName64
    $Latest.ExeChecksum64 = $Latest.Checksum64

    $templateFilePath = Join-Path -Path $toolsDir -ChildPath 'VERIFICATION.txt.template'
    $verificationFilePath = Join-Path -Path $toolsDir -ChildPath 'VERIFICATION.txt'
    Copy-Item -Path $templateFilePath -Destination $verificationFilePath -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath '.\DESCRIPTION.md'
}

function global:au_AfterUpdate {
    $licenseUri = "https://raw.githubusercontent.com/$($softwareRepo)/v$($Latest.SoftwareVersion)/LICENSE"
    $licenseContents = Invoke-WebRequest -Uri $licenseUri -UseBasicParsing

    $licensePath = Join-Path -Path $toolsDir -ChildPath 'LICENSE.txt'
    Set-Content -Path $licensePath -Value "From: $licenseUri`r`n`r`n$licenseContents"
}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            '(<packageSourceUrl>)[^<]*(</packageSourceUrl>)' = "`$1https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)`$2"
            '(<licenseUrl>)[^<]*(</licenseUrl>)'             = "`$1https://github.com/$($softwareRepo)/blob/v$($Latest.SoftwareVersion)/LICENSE`$2"
            '(<projectSourceUrl>)[^<]*(</projectSourceUrl>)' = "`$1https://github.com/$($softwareRepo)/tree/v$($Latest.SoftwareVersion)`$2"
            '(<releaseNotes>)[^<]*(</releaseNotes>)'         = "`$1https://github.com/$($softwareRepo)/releases/tag/v$($Latest.SoftwareVersion)`$2"
            '(<copyright>)[^<]*(</copyright>)'               = "`$1Copyright (c) 2022-$(Get-Date -Format yyyy) Tien Do Nam`$2"
        }
        'tools\VERIFICATION.txt'        = @{
            '%exeChecksumValue%'      = "$($Latest.ExeChecksum64)"
            '%msixChecksumValue%'     = "$($Latest.MsixChecksum64)"
            '%checksumType%'          = "$($Latest.ChecksumType64.ToUpper())"
            '%tagReleaseUrl%'         = "https://github.com/$($softwareRepo)/releases/tag/v$($Latest.SoftwareVersion)"
            '%exeInstallerUrl%'       = "$($Latest.ExeUrl64)"
            '%msixInstallerUrl%'      = "$($Latest.MsixUrl64)"
            '%exeInstallerFileName%'  = "$($Latest.ExeFileName64)"
            '%msixInstallerFileName%' = "$($Latest.MsixFileName64)"
        }
        'tools\chocolateyinstall.ps1'   = @{
            '(^[$]exeFileName\s*=\s*)(''.*'')'               = "`$1'$($Latest.ExeFileName64)'"
            '(^[$]msixFileName\s*=\s*)(''.*'')'              = "`$1'$($Latest.MsixFileName64)'"
            "(^\[version\] [$]softwareVersion\s*=\s*)('.*')" = "`$1'$($Latest.SoftwareVersion)'"
        }
    }
}

Update-Package -ChecksumFor None -NoReadme
