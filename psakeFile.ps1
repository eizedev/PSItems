Properties {
    # Set this to $true to create a module with a monolithic PSM1
    $PSBPreference.Build.CompileModule = $false
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Publish.PSRepositoryApiKey = $env:PSGALLERY_API_KEY
}

Task Default -depends Test

Task Test -FromModule PowerShellBuild -minimumVersion '0.6.1'

Task Analyze -FromModule PowerShellBuild -minimumVersion '0.6.1'

Task Publish -FromModule PowerShellBuild -minimumVersion '0.6.1'
