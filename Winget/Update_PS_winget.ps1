# Check if the system has the required permissions to run the script
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not ($currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
    Write-Output "You need to run this script as an administrator."
    exit
}

# Check the version of Microsoft.UI package for the current user
$package = Get-AppxPackage -Name Microsoft.UI.Xaml* -User $env:UserName
if ($package) {
    # Sort the array of versions in descending order and select the first element
    $version = $package.Version | Sort-Object -Descending | Select-Object -First 1
    Write-Output "Microsoft.UI package version: $version"
    # If the version is lower than 2.7, upgrade it
    # Cast the version strings to [version] objects to compare them numerically
    if ([version]$version -lt [version]"2.7") {
        Write-Output "Upgrading Microsoft.UI package to 2.7"
        # Download the raw nupkg file for the package from the NuGet Gallery [1]
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3" -OutFile "Microsoft.UI.Xaml.2.7.3.nupkg"
        # Change the extension to .zip and extract the appx file
        Rename-Item -Path "Microsoft.UI.Xaml.2.7.3.nupkg" -NewName "Microsoft.UI.Xaml.2.7.3.zip"
        Expand-Archive -Path "Microsoft.UI.Xaml.2.7.3.zip" -DestinationPath "Microsoft.UI.Xaml.2.7.3" -Force
        # Install the appx package
        Add-AppxPackage -Path ".\Microsoft.UI.Xaml.2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"
        # Remove the downloaded and extracted files
        Write-Output "Removing the downloaded and extracted files"
        Remove-Item -Path "Microsoft.UI.Xaml.2.7.3.zip" -Force
        Remove-Item -Path "Microsoft.UI.Xaml.2.7.3" -Recurse -Force
    }
}
else {
    Write-Output "Microsoft.UI package is not installed"
}

# Check if winget is installed
$winget = Get-Command winget -ErrorAction SilentlyContinue
if ($winget) {
    Write-Output "winget is installed"
    # Check the current winget version
    Write-Output "Checking the current winget version"
    # Get the current winget version
    $currentVersion = (winget --version).Split()[-1]
    $currentVersion = $currentVersion.Replace("v", "")
    # Get the latest winget version without the prefix v
    $latestVersion = (Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest" -UseBasicParsing).BaseResponse.ResponseUri.Segments[-1].TrimStart('v')
    # Compare the versions and update if needed
    if ([Version]$currentVersion -lt [Version]$latestVersion) {
        # Update winget to the latest version
        Write-Output "Updating winget to the latest version"
        # Download the raw msix file for the winget package from the GitHub repo
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v$latestVersion/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "winget.msix" -ContentType 'application/x-msix'
        # Install the msix package with administrator privileges
        Add-AppxPackage -Path "winget.msix" -Force
        # Delete the downloaded file
        Remove-Item "winget.msix"
    }
    else {
        Write-Output "Winget is already up to date"
    }
}
else {
    Write-Output "winget is not installed"
    # Install winget using the MSIX Packaging Tool [^1^][2]
    Write-Output "Installing winget using the MSIX Packaging Tool"
    # Download the raw msix file for the winget package from the GitHub repo
    $latestVersion = (Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest" -UseBasicParsing).BaseResponse.ResponseUri.Segments[-1].TrimStart('https://github.com/microsoft/winget-cli/releases/tag/')
    # Download the raw msix file for the winget package from the GitHub repo
    Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/$latestVersion/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "winget.msix" -ContentType 'application/x-msix'
    # Install the msix package
    Add-AppxPackage -Path "winget.msix"
    # Remove the downloaded file
    Write-Output "Removing the downloaded file"
    Remove-Item -Path "winget.msix" -Force
}

# Get the source.msix file from the web and execute it
Write-Output "Getting the source.msix file from the web and executing it"
# Download the source.msix file from the winget's default repo
Invoke-WebRequest -Uri "https://winget.azureedge.net/cache/source.msix" -OutFile "source.msix"
# Execute the source.msix file
# Run the source.msix file silently
Add-AppxPackage -Path  "source.msix"
# Remove the downloaded file
Write-Output "Removing the downloaded file"
Remove-Item -Path "source.msix" -Force

# Check the PowerShell version
$ps_version = $PSVersionTable.PSVersion.Major
Write-Output "PowerShell version: $ps_version"
# If the version is not 7, upgrade it
if ($ps_version -ne 7) {
    Write-Output "Upgrading PowerShell to version 7"
    # Install PowerShell 7 using winget
    winget install --id Microsoft.PowerShell --silent
}