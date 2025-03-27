# 2024-12-14
# vlad@416corp.com
#

# Releases
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html?msockid=224e3e7e878f6be730d12b4786256ad8

# Msi command line options
# https://www.adobe.com/devnet-docs/acrobatetk/tools/DesktopDeployment/cmdline.html?msockid=224e3e7e878f6be730d12b4786256ad8

# Download 
# https://helpx.adobe.com/acrobat/kb/download-64-bit-installer.html
# https://helpx.adobe.com/ca/acrobat/kb/acrobat-dc-downloads.html

# Intune Deployment
# https://helpx.adobe.com/ca/enterprise/kb/deploy-packages-using-ms-intune.html

# AcroCleaner
# https://www.adobe.com/devnet-docs/acrobatetk/tools/Labs/cleaner.html
# https://helpx.adobe.com/ca/creative-cloud/help/uninstall-creative-cloud-desktop-app.html

# Patch 24.005.20320, December 10, 2024
# https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/continuous/dccontinuousdec2024qfe.html#dccontinuousdectwentytwentyfourqfe
# https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2400520320/AcrobatDCx64Upd2400520320.msp

#
# "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{AC76BA86-1033-FFFF-7760-BC15014EA700}"
#

# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\PowerShell.exe" -noprofile -executionpolicy bypass -command "& { . .\DeployAdobeAcrobat.ps1; Install-AdobeAcrobat }"
# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\PowerShell.exe" -noprofile -executionpolicy bypass -command "& { . .\DeployAdobeAcrobat.ps1; Uninstall-AdobeAcrobat }"

$ProgressPreference = 'SilentlyContinue' 

# Check if local source exists
$localSource = Join-Path -Path $PSScriptRoot -ChildPath "Adobe Acrobat"
if (-not (Test-Path -Path  $localSource)) {
    Write-Hsot "$localSource not found."
    
    # Check if local archive exists
    $localArchive = $PSScriptRoot + "\AdobeAcrobatPro.zip"
    if (-not (Test-Path -Path $localArchive)) {
        Write-Host "$localArchive not found. Downloading."
        # Download AcrobatPro Archive
        $downloadUrl = "https://trials.adobe.com/AdobeProducts/APRO/Acrobat_HelpX/win32/Acrobat_DC_Web_x64_WWMUI.zip"
        Invoke-WebRequest -Uri $downloadUrl -OutFile $localArchive
    }
    
    # Extract
    Write-Host "Extracting $localArchive"
    Expand-Archive -Path $localArchive -DestinationPath $PSScriptRoot

    Write-Host "Removing $localArchive"
    Remove-Item -Path $localArchive
}


$installFile = Join-Path -Path $localSource -ChildPath "Install-AdobeAcrobat.ps1"
Set-Content -Path $installFile -Value 



# Install Script

$workingDirectory = "$PSScriptRoot\Adobe Acrobat"
$acroProPatchLocalPath = $workingDirectory + "\AcrobatDCx64Upd2400520320.msp"
$acroProPatchVersion = [System.Version]"24.5.20320.0"

$installedVersion = (Get-Item -Path 'C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe' -ErrorAction SilentlyContinue).VersionInfo.ProductVersion

switch ($installedVersion) {
    { $_ -eq $null } {
        Write-Host "Installing.."
        Start-Process -FilePath "setup.exe" -ArgumentList "--silent" -WorkingDirectory "$PSScriptRoot\Adobe Acrobat" -NoNewWindow -Wait
        return
    }
    { $_ -ne $null -and $_ -lt $acroProPatchVersion} {
        Write-Host "Updating from $_ to $acroProPatchVersion"
        Start-Process "$ENV:SystemRoot\system32\msiexec.exe" -ArgumentList "/update $acroProPatchLocalPath /qn" -WorkingDirectory "$ENV:SystemRoot\system32" -NoNewWindow -Wait
        return
    }
    Default {
        Write-Host "Nothing to be done."
        return
    }
}



$uninstallFile = Join-Path -Path $localSource -ChildPath "Uninstall-AdobeAcrobat.ps1"
Set-Content -Path $uninstallFile -Value @'
# Uninstall Script
Start-Process "$ENV:SystemRoot\system32\msiexec.exe" -ArgumentList "/x {AC76BA86-1033-FFFF-7760-BC15014EA700} /qn" -Wait
'@

# Create .intinewin package
$intunewin = $PSScriptRoot + "\IntuneWinAppUtil.exe"
$intunewinArgs = "-c `"$localSource`" -s $setupfile -o `"$PSScriptRoot`" -q"
if (-not(Test-Path -path $intunewin)) {
    Write-Host "$intunewin not found. Downloading."
    $downloadUrl = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/blob/master/IntuneWinAppUtil.exe"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $intunewin
}

Write-Host "Creating .intunewin package"
# Start-Process -FilePath $intunewin -ArgumentList $intunewinArgs -NoNewWindow -Wait

Write-Host "done."








