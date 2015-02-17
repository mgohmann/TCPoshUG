
# The DSC Resource Designer Tool is GREAT!


#Define your properties
$Property = New-xDscResourceProperty -Name "TimeZone" -Attribute Key -Type String -ValidateSet "UTC","Eastern Standard Time","Central Standard Time","Mountain Standard Time","Pacific Standard Time","Alaskan Standard Time","Hawaiian Standard Time"


#Create the starting structure of the resource.
New-xDscResource -Name "TimeZone" -Path C:\Users\Administrator\Documents\Resource -ModuleName "TimeZone" -FriendlyName "TimeZone" -Property $Property
