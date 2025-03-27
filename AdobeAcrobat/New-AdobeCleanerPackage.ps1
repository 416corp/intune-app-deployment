function Invoke-AcroCleaner {
    [CmdletBinding()]
    param()

    BEGIN {

        $acroCleanerLocalPath = $PSScriptRoot + "AdbeArCleaner.exe"
        $acroCleanerArgumentList = "/silent"
        $acroCleanerLog = $env:TEMP + "\RaftLogs\AdbeArCleaner.log"    

        $acroCleanerDownloadUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2100120135/x64/AdobeAcroCleaner_DC2021.exe"

        # Download AcroCleaner
        if (-not (Test-Path -Path $acroCleanerLocalPath)) {
            Invoke-WebRequest -Uri $acroCleanerDownloadUrl -OutFile $acroCleanerLocalPath
        }
    }

    PROCESS {

        Write-Host "Running AcroCleaner"
        Start-Process -Wait -FilePath $acroCleanerLocalPath -ArgumentList $acroCleanerArgumentList

    }

    END {

        Write-Host "Removing AcroCleaner"
        Remove-Item -Path $acroCleanerLocalPath
        Write-Host "Check $acroCleanerLog for more information."
        
    }

}