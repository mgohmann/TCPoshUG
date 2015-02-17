Function Invoke-VMDesiredState {
<#
.Synopsis
   Invoke DSC to configure a VM.
.DESCRIPTION
   Invoke DSC to configure a VM.
.EXAMPLE
   1. Generate the Config Mof
   2. Generate the Schema Mof
   3. Create the VMs (if applicable).
   4. Use this function to apply both.
#>
[CmdletBinding()]
Param 
(
[Parameter(Mandatory=$true)]
[String[]]$ComputerName,
[Parameter(Mandatory=$true)]
[PSCredential]$AdministratorCredential,
[Parameter(Mandatory=$true)]
[String]$VCenter,
[ValidateScript({Test-Path $_})]
[String]$ConfigFilesPath = "C:\Mofs",
#This should be appshare repository?
[Switch]$Apply
)
Begin 
    {
    Add-PSSnapin VMware.VimAutomation.Core,VMware.VimAutomation.Vds
    Connect-VIServer $vcenter -erroraction silentlycontinue -warningaction silentlycontinue | out-null
    }
Process
    {
    $ComputerName | ForEach-Object {
        if((Test-Path "$ConfigFilesPath\$_.meta.mof") -and (Test-Path "$ConfigFilesPath\$_.mof")){
            Write-Verbose "Copying Resources to Computer."
            Copy-VMGuestFile -Source "C:\Program Files\WindowsPowerShell\Modules" -Destination "C:\Program Files\WindowsPowerShell\Modules" -localToGuest -VM $_ -GuestCredential $AdministratorCredential -Force
            
            Write-Verbose "Copying and setting Local Config Manager state."
            Copy-VMGuestFile -Source "$ConfigFilesPath\$_.meta.mof" -Destination "C:\Mofs\" -localToGuest -VM $_ -GuestCredential $AdministratorCredential -Force
            Invoke-VMscript -ScriptText {Set-DscLocalConfigurationManager -Path "C:\Mofs"} -VM $_ -GuestCredential $AdministratorCredential -erroraction stop -ScriptType Powershell
            
            Write-Verbose "Copying and setting Local Config Manager state."
            Copy-VMGuestFile -Source "$ConfigFilesPath\$_.mof" -Destination "C:\Mofs\" -localToGuest -VM $_ -GuestCredential $AdministratorCredential -Force
            
            if ($Apply)
                {
                Invoke-VMscript -ScriptText {Start-DscConfiguration -Path "C:\Mofs" -ComputerName $_ -Force} -VM $_ -GuestCredential $AdministratorCredential -erroraction stop -ScriptType Powershell -RunAsync
                }
            }
        else {Write-Error "Mof files not found. Ensure you have config and schema mof files in $ConfigFilesPath for $ComputerName"}
        }
    }
}