Import-Module PowerShellForGitHub

$owner = 'localsend'
$repository = 'localsend'
$assetPattern = 'LocalSend-([\d\.]+)(-windows-x86-64)?\.exe$'

function Get-LatestStableVersion {
    # Get multiple recent releases to find one with the required asset
    $releases = Get-GitHubRelease -OwnerName $owner -RepositoryName $repository
    
    foreach ($release in $releases) {
        $version = $release.tag_name.Substring(1)
        
        # Get the list of assets for this release
        $releaseAssets = Get-GitHubReleaseAsset -OwnerName $owner -RepositoryName $repository -Release $release.ID
        
        # Check if the required asset exists in this release
        $matchingAsset = $null
        foreach ($asset in $releaseAssets) {
            if ($asset.name -match $assetPattern) {
                $matchingAsset = $asset
                break
            }
        }
        
        if ($matchingAsset) {
            return $version
        }
        else {
            Write-Warning "Skipping over LocalSend release v$version, as it does not contain the required asset: LocalSend-$version-windows-x86-64.exe"
        }
    }
    
    throw 'No release was found with the required asset (LocalSend-*-windows-x86-64.exe)!'
}

function Get-SoftwareUri($Version) {
    if ($null -eq $Version) {
        #Default to latest stable version
        $release = (Get-GitHubRelease -OwnerName $owner -RepositoryName $repository -Latest)[0]
    }
    else {
        $release = Get-GitHubRelease -OwnerName $owner -RepositoryName $repository -Tag "v$($Version.ToString())"
    }

    $releaseAssets = Get-GitHubReleaseAsset -OwnerName $owner -RepositoryName $repository -Release $release.ID

    $windowsInstallerAsset = $null
    foreach ($asset in $releaseAssets) {
        if ($asset.name -match $assetPattern) {
            $windowsInstallerAsset = $asset
            break
        }
        else {
            continue
        }
    }

    if ($null -eq $windowsInstallerAsset) {
        throw 'Cannot find published Windows installer asset!'
    }

    return $windowsInstallerAsset.browser_download_url
}
