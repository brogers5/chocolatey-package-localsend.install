$packageName = '11157TienDoNam.LocalSend'
$storePublisher = 'CN=0A8E9755-183F-4F0B-823F-1B8C991D7B97'
$developerPublisher = 'CN=Tien Do Nam, O=Tien Do Nam, S=Sachsen, C=DE'

function Get-Packages($Publisher) {
    if ([string]::IsNullOrEmpty($Publisher)) {
        return Get-AppxPackage -Name $packageName -PackageTypeFilter Main
    }

    return Get-AppxPackage -Name $packageName -Publisher $Publisher -PackageTypeFilter Main
}

function Get-CurrentVersion {
    [array] $packages = Get-Packages -Publisher $developerPublisher

    if ($packages.Count -gt 0) {
        return [version] $($packages[0]).Version
    }

    return $null
}

function Get-StoreSignedPackage {
    [array] $packages = Get-Packages -Publisher $storePublisher

    if ($packages.Count -gt 0) {
        return $packages[0]
    }

    return $null
}
