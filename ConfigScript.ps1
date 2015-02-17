Configuration NetgainDSC 
{
[CmdletBinding()]
Param
(
# Param help description
[Parameter(Mandatory=$True,ParameterSetName='Default')]
[PSCredential]$DomainCredential,
# Param help description
[Parameter(Mandatory=$True,ParameterSetName='Default')]
[PSCredential]$SafeModeCredential,
# Param help description
[Parameter(Mandatory=$True,ParameterSetName='Default')]
[PSCredential]$TrustTargetDomainCredential
)

Import-DSCResource -ModuleName "xActiveDirectory","xComputerManagement","xSystemSecurity","NetgainDSC"

#There is an implicit foreach loop that cycles through the $AllNodes variable. Which is generated automatically when the $ConfigurationData is fed into the Configuration. The current item in the All Nodes implicit loop is given the automatic variable $Node.

#region All Nodes
if ($AllNodes.NodeName -ne $null){
Node $AllNodes.NodeName
    {
    #region General Config
    Write-Host "`nProcessing $($Node.NodeName)" -ForegroundColor White
    WindowsFeature ADAdminCenter {Name = "RSAT-ADDS-Tools";Ensure = "Present"}
    WindowsFeature RSATADAdminCenter {Name = "RSAT-AD-AdminCenter";Ensure = "Present"}
    WindowsFeature RSATADPowerShell {Name = "RSAT-AD-PowerShell";Ensure = "Present"}
    WindowsFeature RSATADTools {Name = "RSAT-AD-Tools";Ensure = "Present"}
    WindowsFeature RSATDNSServer {Name = "RSAT-DNS-Server";Ensure = "Present"}
    Netgain_WindowsUpdate WindowsUpdate {WUEnabled = $true}
    Netgain_WindowsActivation Activate {ActivateWindows = $true}
    Registry EnableRDP
        {
        Ensure = "Present"
        Key = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server"
        ValueName = "fDenyTSConnections"
        ValueType = "DWORD"
        ValueData = "0"
        }
    Service WindowsFirewall
        {
        Name = "MpsSvc"
        StartupType = "Automatic"
        State = "Running"
        }
    Netgain_TimeZone SetTimeZone {TimeZone = $Node.TimeZone}
    #endregion General Config
    if ($Node.ServerRole -match "PrimaryADDC")
        {
        Write-Host "PrimaryADDC $($Node.NodeName)" -ForegroundColor Green
        WindowsFeature ADDSInstall 
            {
            Name = 'AD-Domain-Services';Ensure = 'Present'
            }
        if (!$Node.ExistingDomain)
            {
            Netgain_ADDomain DomainInstall
                {
                DomainName = $Node.DomainName
                DomainAdministratorCredential = $domaincredential
                SafemodeAdministratorPassword = $SafeModeCredential
                DomainMode = 'Win2008R2'
                ForestMode = 'Win2008R2'
                }
            $MultiDependsOn = '[Netgain_ADDomain]DomainInstall'
            }
        if ($Node.ExistingDomain)
            {
            xWaitForADDomain ADForestWait
                { 
                DomainName = $Node.DomainName 
                DomainUserCredential = $DomainCredential 
                RetryCount = $Node.RetryCount
                RetryIntervalSec = $Node.RetryIntervalSec
                DependsOn = '[WindowsFeature]ADDSInstall'
                }
            if ($Node.ServerRole -match "2008R2PrimaryADDC")
                {
                Netgain_ADDomainController NetgainPrimaryDomainController 
                    {
                    DomainName = $Node.DomainName
                    DomainAdministratorCredential = $DomainCredential
                    SafemodeAdministratorPassword = $SafeModeCredential
                    DependsOn = '[xWaitForADDomain]ADForestWait'
                    }
                $MultiDependsOn = '[Netgain_ADDomainController]NetgainPrimaryDomainController'
                }
            elseif ($Node.ServerRole -match "2012R2PrimaryADDC")
                {
                xADDomainController MSFTPrimaryDomainController 
                    {
                    DomainName = $Node.DomainName
                    DomainAdministratorCredential = $DomainCredential
                    SafemodeAdministratorPassword = $SafeModeCredential
                    DependsOn = '[xWaitForADDomain]ADForestWait'
                    }
                $MultiDependsOn = '[xADDomainController]MSFTPrimaryDomainController'
                }
            }
        Netgain_RootHints EnsureRootHintsAreUpToDate 
            {
            RootHintsUpToDate = $true
            DependsOn = $MultiDependsOn 
            }
        Netgain_NTP SetPeer 
            {
            NTPPeer = $Node.NTPPeer
            DependsOn = $MultiDependsOn
            }
        Netgain_ADRecycleBin EnableADRecycleBin
            {
            Enabled = $true
            DependsOn = $MultiDependsOn
            }
        } #end ServerRole PrimaryADDC       
    if ($Node.ServerRole -match "SecondaryADDC")
        {} #end ServerRole SecondaryADDC 
    if ($Node.ServerRole -match "2008R2SecondaryADDC")
        {} #end ServerRole 2008R2SecondaryADDC
    elseif ($Node.ServerRole -match "2012R2SecondaryADDC")
        {} #end ServerRole 2012R2SecondaryADDC
    $MemberServerNodeNames = ($AllNodes | where {$_.NodeName -notin ($AllNodes.Where{$_.ServerRole -match "ADDC"}.NodeName)}).NodeName | where {$_ -ne $null}
    if ($Node.NodeName -in $MemberServerNodeNames) {
    } #end ServerRole MemberServer
    if ($Node.ServerRole -match "FileServer") {
    } #end ServerRole FileServer
    if ($Node.ServerRole -match "Exchange") {
    } #end ServerRole Exchange
    if ($Node.ServerRole -match "SQL") {
    } #end ServerRole SQL
    if ($Node.ServerRole -match "IIS") {
    } #end ServerRole IIS
    } #end Node AllNodes
} #end If AllNodes -ne $null
} #end Configuration NetgainDSC

#$Configuration Data is generated from the DemoConfigData.ps1
#NetgainDSC -OutputPath C:\Mofs -ConfigurationData $ConfigurationData