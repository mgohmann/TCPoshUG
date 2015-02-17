# Default time zone...
$TimeZone = "Pacific Standard Time"
# Change it to this...
$TimeZone = "Central Standard Time"

#Get
Write-Output @{TimeZone = (C:\windows\system32\tzutil.exe /g)}

#Set
C:\windows\system32\tzutil.exe /s $TimeZone

#Test
(C:\windows\system32\tzutil.exe /g) -eq $TimeZone