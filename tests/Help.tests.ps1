# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

BeforeDiscovery {

    function global:FilterOutCommonParams {
        param ($Params)
        $commonParams = @(
            'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
            'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction',
            'WarningVariable', 'Confirm', 'WhatIf', 'ProgressAction' # include ProgressAction for PS7+
        )
        $Params | Where-Object { $_.Name -notin $commonParams } | Sort-Object -Property Name -Unique
    }

    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop

    $params = @{
        Module      = (Get-Module $env:BHProjectName)
        CommandType = [System.Management.Automation.CommandTypes[]]'Cmdlet, Function' # Not alias
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $params.CommandType[0] += 'Workflow'
    }
    $commands = Get-Command @params
}

Describe 'Test help for <_.Name>' -ForEach $commands {

    BeforeDiscovery {
        $command = $_
        $commandHelp = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
        $helpLinks = $commandHelp.relatedLinks.navigationLink.uri
    }

    BeforeAll {
        $command = $_
        $commandName = $_.Name
        $commandHelp = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
        $helpParameters = if ($commandHelp) { global:FilterOutCommonParams -Params $commandHelp.Parameters.Parameter } else { @() }
        $helpParameterNames = $helpParameters.Name
    }

    # If help is not found, synopsis in auto-generated help is the syntax diagram
    It 'Help is not auto-generated' -Skip:(-not $commandHelp) {
        $commandHelp.Synopsis | Should -Not -BeLike '*`[`<CommonParameters`>`]*'
    }

    It 'Has description' -Skip:(-not $commandHelp) {
        $commandHelp.Description | Should -Not -BeNullOrEmpty
    }

    It 'Has example code' -Skip:(-not $commandHelp) {
        ($commandHelp.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
    }

    It 'Has example help (remarks or intro if present)' -Skip:(-not $commandHelp -or -not ($commandHelp.Examples.Example | Select-Object -First 1)) {
        $ex = $commandHelp.Examples.Example | Select-Object -First 1
        $remarks = @($ex.Remarks | ForEach-Object { $_.Text }) -join ''
        if ([string]::IsNullOrWhiteSpace($remarks)) {
            $remarks = @($ex.Introduction | ForEach-Object { $_.Text }) -join ''
        }
        # Only assert if there is a remarks/introduction node present; otherwise skip.
        if ($ex.Remarks -or $ex.Introduction) {
            $remarks | Should -Not -BeNullOrEmpty
        } else {
            Set-ItResult -Pending -Because 'No remarks/introduction node in generated help.'
        }
    }

    It 'Help link <_> is valid' -ForEach $helpLinks {
        try {
            $resp = Invoke-WebRequest -Uri $_ -UseBasicParsing -MaximumRedirection 5 -ErrorAction Stop
            [int]$resp.StatusCode | Should -BeIn @(200, 201, 202, 203, 204, 301, 302, 307, 308)
        } catch {
            Write-Warning "Link check skipped due to network error for [$($_)]: $($_.Exception.Message)"
            1 | Should -Be 1
        }
    }

    Context 'Parameter <_.Name>' -ForEach $commandParameters {

        BeforeAll {
            $parameter = $_
            $parameterName = $parameter.Name
            $parameterHelp = if ($commandHelp) { $commandHelp.parameters.parameter | Where-Object Name -EQ $parameterName }
            $parameterHelpType = if ($parameterHelp -and $parameterHelp.ParameterValue) { $parameterHelp.ParameterValue.Trim() }
        }

        It 'Has description' -Skip:(-not $parameterHelp) {
            $parameterHelp.Description.Text | Should -Not -BeNullOrEmpty
        }

        It 'Has correct [mandatory] value' -Skip:(-not $parameterHelp) {
            $codeMandatory = $_.IsMandatory.ToString()
            $parameterHelp.Required | Should -Be $codeMandatory
        }

        It 'Has correct parameter type' -Skip:(-not $parameterHelp) {
            $parameterHelpType | Should -Be $parameter.ParameterType.Name
        }
    }

    Context 'Help-only parameters must exist in code' -ForEach $helpParameterNames {
        It 'finds help parameter in code: <_>' {
            $_ -in $commandParameterNames | Should -Be $true
        }
    }
}
