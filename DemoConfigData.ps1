# A Friendly document for storing configuration!

<#
VALID SERVER ROLES:
"2008R2PrimaryADDC"
"2008R2SecondaryADDC"
"2008R2Server"
"2008R2RDS"
"2008R2SQL"
"2008R2Exchange"
"2008R2IIS"
"2012R2PrimaryADDC"
"2012R2SecondaryADDC"
"2012R2Server"
"2012R2SQL"
"2012R2RDS"
"2012R2Exchange"
"2012R2IIS"	
#>

#Function for doing a Deep Copy of the hashtable so the same memory references aren't used.
function Clone-Object {
    param($DeepCopyObject)
    $memStream = New-Object IO.MemoryStream
    $formatter = New-Object Runtime.Serialization.Formatters.Binary.BinaryFormatter
    $formatter.Serialize($memStream,$DeepCopyObject)
    $memStream.Position=0
    $formatter.Deserialize($memStream)
}
<#
$ConfigurationData is passed into a configuration as a parameter. Which processes it and deals with the data via the $AllNodes automatic variable. 
Individual nodes are given the automatic variable $node. The contents of $node is created from the combination of the Global Settings section and the individual node section.
#>
$ConfigurationData =  @{
    AllNodes =
    @(
        @{
            #Global Settings:
            NodeName = "*"
            TimeZone = "Central Standard Time"
            IPv6Enabled = $false
            DomainName = "domain.local"
            ExistingDomain = $false
            NTPPeer = "192.168.1.50"
            RetryCount = 1440
            RetryIntervalSec = 60
            DefaultGateway = "192.168.20.1"
            SubnetMask = "255.255.255.0"
            PrimaryDNS = "192.168.20.5"
            SecondaryDNS = "192.168.20.6"
            RebootNodeIfNeeded= $true
            VMNetworkVLAN = "123Demo"
            CertificateFile = "C:\Certs\Cert.cer"
        }
        @{
            NodeName = "node1"
            ServerRole = "2012R2PrimaryADDC"
            ComputerOUDN = ""
            VMTemplate = "2012R2"
            VMCPUs = 1
            VMPreProdMemory = 1
            VMProdMemory = 1
            Description = "node1 - Domain Controller"
            IPAddress = "192.168.20.5"
            #The individual node's settings can override the Global Settings. Like below:
            PrimaryDNS = "192.168.20.6"
        }
        @{
            NodeName = "node2"
            ServerRole = "2012R2RDS"
            ComputerOUDN = "OU=2012R2,OU=RDS Servers,OU=Servers,"
            VMTemplate = "2012R2"  
            VMCPUs = 1
            VMPreProdMemory = 1
            VMProdMemory = 4
            Description = "node2 - 2012R2 RDS"
            IPAddress = "192.168.20.20"
        }
        @{
            NodeName = "node3"
            ServerRole = "2008R2RDS"
            ComputerOUDN = "OU=RDS Servers,OU=Servers,"
            VMTemplate = "2008R2"   
            VMCPUs = 1
            VMPreProdMemory = 1
            VMProdMemory = 4
            Description = "node3 - 2008R2 RDS"
            IPAddress = "192.168.20.21"
        }
        @{
            NodeName = "node4"
            ServerRole = "2012R2FileServer","2012R2SQLServer" 
            ComputerOUDN = "OU=Servers,"
            VMTemplate = "2012R2"  
            VMCPUs = 1
            VMPreProdMemory = 1
            VMProdMemory = 4
            Description = "node4 - File / SQL Server"
            IPAddress = "192.168.20.30"
        }
    )
}

$LCMConfigData = Clone-Object $ConfigurationData
$VMConfigData = Clone-Object $ConfigurationData