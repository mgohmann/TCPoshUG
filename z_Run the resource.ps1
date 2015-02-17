Configuration LCM
{
Node (hostname)
    {
    LocalConfigurationManager
        {
        ConfigurationMode = "ApplyAndMonitor"
        ConfigurationModeFrequencyMins = 1440
        RefreshMode = "Push"
        RefreshFrequencyMins = 720
        RebootNodeIfNeeded = $false
        }
    }
}

Configuration LCM
{
Node (hostname)
    {
    LocalConfigurationManager
        {
        ConfigurationMode = "ApplyAndAutoCorrect"
        ConfigurationModeFrequencyMins = 15
        RefreshMode = "Push"
        RefreshFrequencyMins = 30
        RebootNodeIfNeeded = $true
        }
    }
}
LCM -OutputPath C:\Mofs


configuration MyConfig
{
Import-DSCResource -ModuleName "TimeZone"
node (hostname)
    {
    TimeZone SetTimeZone {TimeZone = "Central Standard Time"}
    }
}
MyConfig -OutputPath C:\Mofs 


# Set the LCM settings
Set-DscLocalConfigurationManager -Path "c:\Mofs"

# Check the LCM settings
Get-DscLocalConfigurationManager

# Run the Config
Start-DscConfiguration -Path "C:\Mofs" -Force -Wait