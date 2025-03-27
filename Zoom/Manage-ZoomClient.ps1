$config = [PSCustomObject]@{
    $detectionPath = "$env:ProgramFiles\Zoom\bin\Zoom.exe"
    # "/i ZoomOutlookPluginSetup.msi /qn"
    # /lex $ENV:SystemRoot\twt\zoominstall.log
    $installerPath = "$env:SystemRoot\System32\msiexec.exe"
    $installerArgs = "/package .\ZoomInstallerFull.msi /quiet /qn /norestart MSIRestartManagerControl=Disable zNoDesktopShortCut=True ZoomAutoUpdate=1 ZConfig=""nogoogle=1;nofacebook=1"""
    $uninstallerPath = "$PSScriptRoot\CleanZoom.exe"
    $uninstallerArgs = "/silent"
    version = "5,17,10,33775"
}



#     $logFolder = "$ENV:SystemRoot\twt\"
#     $logFile = "$($config.name).log"
#     $logPath = Join-Path -Path $logFolder -ChildPath $logFile
# }



function Install-Application {
    BEGIN {
        # Detect Previous Installation
        $app = Get-Item -Path $config.detectionPath -ErrorAction SilentlyContinue

        if ($app) {
            Write-Host "Detected. Uninstalling"
            Uninstall-Application
            break
        }

    }

    PROCESS {
        
        Start-Process -FilePath $config.installerPath -ArgumentList $config.installerArgs `
            -WorkingDirectory $PSScriptRoot -NoNewWindow -Wait

    }
    END {
        Write-Host "Installer finished."
    }
}

function Uninstall-Application {
    BEGIN{}
    PROCESS{
        
        # log may be written to workingdirectory. redirect 
        Start-Process -FilePath $config.uninstallerPath -ArgumentList $config.uninstallerArgs `
            -WorkingDirectory $PSScriptRoot -NoNewWindow -Wait

    }
    END{}
}
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}






# Function Invoke-Script {
#     [CmdletBinding()]
#     Param()

#     Begin {
#         If (!(Test-Path -Path $logPath)) {
#             New-Item -Path $logFolder -Name $logFile -type File -Force
#         }
#     }
#     Process {
#         if (Test-ApplicationInstall) {

#             $installedVersion = (Get-Item -Path $config.detectionPath -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
#             # if ([string]::IsNullOrEmpty($installedVersion)){
#             if ($installedVersion -eq $config.version) {
#                 Add-Content -Path $logPath -Value "$(Get-TimeStamp) Application already installed - exiting."
#                 Break
#             }
#             elseif ($installedVersion -ne $config.version) {
#                 Add-Content -Path $logPath -Value "$(Get-TimeStamp) Found existing version: $installedVersion"
    
#                 Invoke-ApplicationCleanup

#                 Invoke-ApplicationInstall
    
#             }
#             else {
#                 Add-Content -Path $logPath -Value "$(Get-TimeStamp) Unknown condition: $installedVersion"
#                 Break
#             }
#         } else {
#             Invoke-ApplicationInstall

#         }
        
#     }
#     End {
#         Write-Output "$(Get-TimeStamp) Invoke-Script process completed" | Out-File $logPath -Append
#     }

# }


