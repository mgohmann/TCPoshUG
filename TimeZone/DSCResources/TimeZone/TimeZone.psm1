function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[ValidateSet("UTC","Eastern Standard Time","Central Standard Time","Mountain Standard Time","Pacific Standard Time","Alaskan Standard Time","Hawaiian Standard Time")]
		[System.String]
		$TimeZone
	)

Write-Output @{TimeZone = (C:\windows\system32\tzutil.exe /g)}
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[ValidateSet("UTC","Eastern Standard Time","Central Standard Time","Mountain Standard Time","Pacific Standard Time","Alaskan Standard Time","Hawaiian Standard Time")]
		[System.String]
		$TimeZone
	)

C:\windows\system32\tzutil.exe /s $TimeZone
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[ValidateSet("UTC","Eastern Standard Time","Central Standard Time","Mountain Standard Time","Pacific Standard Time","Alaskan Standard Time","Hawaiian Standard Time")]
		[System.String]
		$TimeZone
	)
(C:\windows\system32\tzutil.exe /g) -eq $TimeZone
}


Export-ModuleMember -Function *-TargetResource

