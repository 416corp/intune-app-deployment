# Install Script
$acroProExe = 'C:\Program Files\Adobe\Acrobat DC\Acrobat\Acrobat.exe'
$workingDirectory = "$PSScriptRoot\Adobe Acrobat"
$acroProPatchLocalPath = $workingDirectory + "\AcrobatDCx64Upd2400520320.msp"
$acroProPatchVersion = [System.Version]"24.5.20320.0"

$installedVersion = (Get-Item -Path $acroProExe -ErrorAction SilentlyContinue).VersionInfo.ProductVersion

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
