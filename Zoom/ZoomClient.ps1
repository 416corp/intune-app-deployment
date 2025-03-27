
         function Install-Application {
            BEGIN {
                # Detect Installation
                 = Get-Item -Path C:\Program Files\Zoom\bin\Zoom.exe -ErrorAction SilentlyContinue
                # if () {
                #     Add-Content -Path  -Value "[12/15/24 23:54:42] Found "
                #     return True
                # } else {
                #     Add-Content -Path  -Value "[12/15/24 23:54:42] Previous installation not found"
                #     return False
                # }

                # Remove Old Version
                
    
            }
            PROCESS {
                
                Start-Process -FilePath C:\Windows\System32\msiexec.exe -ArgumentList /package .\ZoomInstallerFull.msi /quiet /qn /norestart MSIRestartManagerControl=Disable zNoDesktopShortCut=True ZoomAutoUpdate=1 ZConfig="nogoogle=1;nofacebook=1" -WorkingDirectory C:\intune-app-deployment -NoNewWindow -Wait

            }
            END {
    
            }
        }

        function Uninstall-Application {
            BEGIN{}
            PROCESS{
                
                Start-Process -FilePath  -ArgumentList  -WorkingDirectory C:\intune-app-deployment -NoNewWindow -Wait

            }
            END{}
        }
        function Get-TimeStamp {
            return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
        }
    

