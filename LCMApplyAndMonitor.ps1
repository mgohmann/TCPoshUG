Configuration LCM
{
Node $AllNodes.NodeName
    {
    LocalConfigurationManager
        {
        ConfigurationMode = "ApplyAndMonitor"
        ConfigurationModeFrequencyMins = 1440
        RefreshMode = "Push"
        RefreshFrequencyMins = 720
        RebootNodeIfNeeded = $false
        CertificateId = "ID goes here"
        }
    }
}
#LCM -ConfigurationData $ConfigurationData -OutputPath C:\Mofs