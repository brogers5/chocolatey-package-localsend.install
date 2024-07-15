$packageName = '11157TienDoNam.LocalSend'
$storePublisher = 'CN=0A8E9755-183F-4F0B-823F-1B8C991D7B97'
$developerPublisher = 'CN=Tien Do Nam, O=Tien Do Nam, S=Sachsen, C=DE'

function Get-StoreSignedPackage {
    [array] $packages = Get-AppxPackage -Name $packageName -Publisher $storePublisher -PackageTypeFilter Main -AllUsers

    if ($packages.Count -gt 0) {
        return $packages[0]
    }

    return $null
}

function Get-LegacyDeveloperSignedPackage {
    [array] $packages = Get-AppxPackage -Name $packageName -Publisher $developerPublisher -PackageTypeFilter Main -AllUsers

    if ($packages.Count -gt 0) {
        return $packages[0]
    }

    return $null
}

function Uninstall-LegacyDeveloperPackage {
    [array] $packages = Get-AppxPackage -Name $packageName -Publisher $developerPublisher -PackageTypeFilter Main -AllUsers

    if ($packages.Count -eq 1) {
        Remove-AppxPackage -Package $packages[0] -AllUsers
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
}
