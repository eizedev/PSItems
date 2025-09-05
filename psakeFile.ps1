Properties {
    # Build a monolithic PSM1 if desired (kept false to use the module layout as-is)
    $PSBPreference.Build.CompileModule = $false

    # Default help locale for generated help content
    $PSBPreference.Help.DefaultLocale = 'en-US'

    # Pester test results path used by the CI artifact upload
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'

    # API key is taken from the environment variable (set by CI from repo Secret)
    $PSBPreference.Publish.PSRepositoryApiKey = $env:PSGALLERY_API_KEY
}

# Default target runs the test suite
Task Default -Depends Test

# Delegate to PowerShellBuild built-in tasks (require at least these versions)
Task Test -FromModule PowerShellBuild -MinimumVersion '0.7.1'
Task Analyze -FromModule PowerShellBuild -MinimumVersion '0.7.1'
Task Publish -FromModule PowerShellBuild -MinimumVersion '0.7.1'
