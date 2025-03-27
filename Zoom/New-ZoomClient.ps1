# 2024-12-14
# 
# Deployment notes
# https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064484
#
# Download 
# https://zoom.us/download/admin
# https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0060407
# https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64
#
# Intune install command
# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -noprofile -executionpolicy bypass -command "& { . .\ZoomClient.ps1; Install-Application }"
#
# Intune uninstall command
# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -noprofile -executionpolicy bypass -command "& { . .\ZoomClient.ps1; Uninstall-Application }"
#
# Build Deployment Package
# . .\DeployZoom.ps1; New-AppDeploymentPackage 

BEGIN {
    
    $ProgressPreference = 'SilentlyContinue' 

    $workDirectory = $PSScriptRoot + "\ZoomClient"
    if (-not (Test-Path -Path $workDirectory)) {
        New-Item -ItemType Directory -Path $workDirectory
    }

    $localInstallerPathx64 = $workDirectory + "\ZoomInstallerFull-x64.msi"
    if (-not (Test-Path -Path $localInstallerPathx64)) {
        $downloadUrlx64 = "https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64"
        Invoke-WebRequest -Uri $downloadUrlx64 -OutFile $localInstallerPathx64
    }

    $localInstallerPatharm = $workDirectory + "\ZoomInstallerFull-winarm.msi"
    if (-not (Test-Path -Path $localInstallerPatharm)) {
        $downloadUrlarm = "https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=winarm64"
        Invoke-WebRequest -Uri $downloadUrlarm -OutFile $localInstallerPatharm
    }

    $localUninstallerArchive = $workDirectory + "\CleanZoom.zip"
    $localUninstaller = $workDirectory + "\CleanZoom.exe"
    if (-not (Test-Path -Path $localUninstaller)) {
        if (-not (Test-Path -Path $localUninstallerArchive)) {
            $downloadUrl = "https://assets.zoom.us/docs/msi-templates/CleanZoom.zip"
            Invoke-WebRequest -Uri $downloadUrl -OutFile $localUninstallerArchive
        }
        Expand-Archive -Path $localUninstallerArchive -DestinationPath $workDirectory
        Remove-Item -Path $localUninstallerArchive
    }
    
    Copy-Item .\Manage-ZoomClient.ps1 -Destination $workDirectory + "\ZoomClient.ps1" 

PROCESS {
    
}

END {

}


