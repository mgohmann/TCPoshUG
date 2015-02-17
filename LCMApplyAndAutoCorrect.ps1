Configuration LCM
{
Node $AllNodes.NodeName
    {
    LocalConfigurationManager
        {
        ConfigurationMode = "ApplyAndAutoCorrect"
        ConfigurationModeFrequencyMins = 15
        RefreshMode = "Push"
        RefreshFrequencyMins = 30
        RebootNodeIfNeeded = $true
        CertificateId = "ID goes here"
        }
    }
}
#LCM -ConfigurationData $LCMConfigData -OutputPath C:\Mofs