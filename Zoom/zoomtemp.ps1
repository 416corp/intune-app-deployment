# 2024-12-14 v.vinogradov@treadwelltx.com
#
# Deployment notes
# https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0064484
#
# Download 
# https://zoom.us/download/admin
# https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64
# https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=winarm64
#
# Intune install command
# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -noprofile -executionpolicy bypass -command "& { . .\DeployZoom.ps1; Install-Application }"
#
# Intune uninstall command
# "C:\Windows\Sysnative\WindowsPowerShell\v1.0\powershell.exe" -noprofile -executionpolicy bypass -command "& { . .\DeployZoom.ps1; Uninstall-Application }"
#
# Intune detect command
# MSI {6FB428F1-BEAC-41DE-A15C-24EDFD4C503B}
# MSI {6659CA3B-0788-43D8-895F-705929DFB6DF}
# 
# Build Deployment Package
# . .\DeployZoom.ps1; New-AppDeploymentPackage 
#


$config = [PSCustomObject]@{
    name = "Zoom"
    version = "5,17,10,33775"
    installer = "$env:SystemRoot\System32\msiexec.exe"
    installerArgs = "/package ZoomInstallerFull.msi /quiet /qn /norestart /lex $ENV:SystemRoot\Treadwell\zoominstall.log MSIRestartManagerControl=Disable zNoDesktopShortCut=True ZoomAutoUpdate=1 ZConfig=""nogoogle=1;nofacebook=1"""
    uninstaller = "$PSScriptRoot\CleanZoom.exe"
    uninstallerArgs = "/silent"
    uninstallerDir = "$ENV:SystemRoot\Treadwell"
    detectionPath = "$env:ProgramFiles\Zoom\bin\Zoom.exe"
    $logFolder = "$ENV:SystemRoot\Treadwell\"
    $logFile = "$($config.name).log"
    $logPath = Join-Path -Path $logFolder -ChildPath $logFile
}

function Install-Application {


    msiexec /i "ZoomOutlookPluginSetup.msi" /qn

    $app = Get-Item -Path $config.detectionPath -ErrorAction SilentlyContinue

    if ($app) {
        Add-Content -Path $logPath -Value "$(Get-TimeStamp) Found $($config.detectionPath)"
        return $true
    } else {
        Add-Content -Path $logPath -Value "$(Get-TimeStamp) Previous installation not found"
        return $false
    }

    Add-Content -Path $logPath -Value "$(Get-TimeStamp) Starting Invoke-ApplicationInstall process"
    Start-Process -FilePath $config.installer -WorkingDirectory $PSScriptRoot -ArgumentList $config.installerArgs -NoNewWindow -Wait
 
}

function Uninstall-Application {
    # MsiExec.exe /X {6659CA3B-0788-43D8-895F-705929DFB6DF}
    # msiexec /x "{6FB428F1-BEAC-41DE-A15C-24EDFD4C503B}" /qn
    Add-Content -Path $logPath -Value "$(Get-TimeStamp) Starting Invoke-ApplicationCleanup process"
    Start-Process -FilePath $config.uninstaller -WorkingDirectory $config.uninstallerDir -ArgumentList $config.uninstallerArgs -NoNewWindow -Wait
    Test-ApplicationInstall

}

function New-AppDeploymentPackage {
    https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64
    https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=winarm64
}

Function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}



Function Invoke-Script {
    [CmdletBinding()]
    Param()

    Begin {
        If (!(Test-Path -Path $logPath)) {
            New-Item -Path $logFolder -Name $logFile -type File -Force
        }
    }
    Process {
        if (Test-ApplicationInstall) {

            $installedVersion = (Get-Item -Path $config.detectionPath -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
            # if ([string]::IsNullOrEmpty($installedVersion)){
            if ($installedVersion -eq $config.version) {
                Add-Content -Path $logPath -Value "$(Get-TimeStamp) Application already installed - exiting."
                Break
            }
            elseif ($installedVersion -ne $config.version) {
                Add-Content -Path $logPath -Value "$(Get-TimeStamp) Found existing version: $installedVersion"
    
                Invoke-ApplicationCleanup

                Invoke-ApplicationInstall
    
            }
            else {
                Add-Content -Path $logPath -Value "$(Get-TimeStamp) Unknown condition: $installedVersion"
                Break
            }
        } else {
            Invoke-ApplicationInstall

        }
        
    }
    End {
        Write-Output "$(Get-TimeStamp) Invoke-Script process completed" | Out-File $logPath -Append
    }

}


