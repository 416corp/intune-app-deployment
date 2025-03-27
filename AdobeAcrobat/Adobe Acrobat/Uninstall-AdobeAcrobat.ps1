# Uninstall Script
Start-Process "$ENV:SystemRoot\system32\msiexec.exe" -ArgumentList "/x {AC76BA86-1033-FFFF-7760-BC15014EA700} /qn" -Wait
