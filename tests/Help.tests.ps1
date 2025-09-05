# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)
# Hardened for PSItems:
# - Fails when external help is missing or auto-generated.
# - Validates examples (code + remarks/introduction).
# - Validates parameter presence, mandatory flag, and type (robust for platyPS output).
# - Link checks are lenient by default; set HELP_LINKS_STRICT=true to fail on link errors.

BeforeDiscovery {

    function global:FilterOutCommonParams {
        <#
            .SYNOPSIS
            Filters out the common PowerShell parameters from a ParameterMetadata collection.

            .DESCRIPTION
            Returns a sorted, unique list of parameters excluding the built-in common parameters.
            Includes ProgressAction for PS7+ hosts.

            .PARAMETER Params
            A collection of parameter metadata objects (e.g. $command.ParameterSets.Parameters).
        #>
        param ($Params)

        $commonParams = @(
            'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
            'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction',
            'WarningVariable', 'Confirm', 'WhatIf', 'ProgressAction' # PS7+
        )

        $Params | Where-Object { $_.Name -notin $commonParams } | Sort-Object -Property Name -Unique
    }

    # Resolve the built module under Output/<Name>/<Version>/<Name>.psd1 produced by PowerShellBuild.
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir = Join-Path -Path $env:BHProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputModVerManifest = Join-Path -Path $outputModVerDir -ChildPath "$($env:BHProjectName).psd1"

    # Ensure only the just-built version is loaded (Pester cannot handle multiple loaded versions well).
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop

    # Collect commands (Functions/Cmdlets only; aliases are not validated here).
    $params = @{
        Module      = (Get-Module $env:BHProjectName)
        CommandType = [System.Management.Automation.CommandTypes[]]'Cmdlet, Function'
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $params.CommandType[0] += 'Workflow'
    }
    $commands = Get-Command @params
}

Describe 'Test help for <_.Name>' -ForEach $commands {

    BeforeDiscovery {
        # Gather help & metadata for discovery-time ForEach rendering.
        $command = $_
        $commandHelp = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
        $helpLinks = if ($commandHelp) { $commandHelp.relatedLinks.navigationLink.uri } else { @() }
    }

    BeforeAll {
        # Duplicate into test phase scope.
        $command = $_
        $commandName = $_.Name
        $commandHelp = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters = global:FilterOutCommonParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
        $helpParameters = if ($commandHelp) { global:FilterOutCommonParams -Params $commandHelp.Parameters.Parameter } else { @() }
        $helpParameterNames = $helpParameters.Name
        $strictLinks = [bool]($env:HELP_LINKS_STRICT -eq 'true')
    }

    It 'Has external help loaded (no auto-generated help)' {
        # If help is auto-generated, the synopsis usually shows the syntax including [<CommonParameters>]
        $commandHelp | Should -Not -BeNullOrEmpty
        $commandHelp.Synopsis | Should -Not -BeLike '*`[`<CommonParameters`>`]*'
    }

    It 'Has description' {
        $commandHelp.Description | Should -Not -BeNullOrEmpty
    }

    It 'Has example code' {
        ($commandHelp.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
    }

    It 'Has example help (remarks or introduction)' {
        $ex = $commandHelp.Examples.Example | Select-Object -First 1
        $ex | Should -Not -BeNullOrEmpty

        # Prefer Remarks.Text; fall back to Introduction.Text if Remarks is empty/missing.
        $remarks = @($ex.Remarks | ForEach-Object { $_.Text }) -join ''
        if ([string]::IsNullOrWhiteSpace($remarks)) {
            $remarks = @($ex.Introduction | ForEach-Object { $_.Text }) -join ''
        }
        $remarks | Should -Not -BeNullOrEmpty
    }

    It 'Help link <_> is valid' -ForEach $helpLinks {
        try {
            $resp = Invoke-WebRequest -Uri $_ -UseBasicParsing -MaximumRedirection 5 -ErrorAction Stop
            [int]$resp.StatusCode | Should -BeIn @(200, 201, 202, 203, 204, 301, 302, 307, 308)
        } catch {
            if ($strictLinks) {
                throw
            } else {
                Write-Warning "Link check skipped due to network error for [$($_)]: $($_.Exception.Message)"
                Set-ItResult -Pending -Because 'Network error while validating link.'
            }
        }
    }

    Context 'Parameter <_.Name>' -ForEach $commandParameters {

        BeforeAll {
            $parameter = $_
            $parameterName = $parameter.Name
            $parameterHelp = if ($commandHelp) { $commandHelp.parameters.parameter | Where-Object Name -EQ $parameterName } else { $null }
        }

        It 'Has help entry for parameter' {
            $parameterHelp | Should -Not -BeNullOrEmpty
        }

        It 'Has description' {
            # Do not skip: if it's missing, we want a clear failure.
            $ph = $parameterHelp
            $ph | Should -Not -BeNullOrEmpty
            $ph.Description.Text | Should -Not -BeNullOrEmpty
        }

        It 'Has correct [mandatory] value' {
            $ph = $parameterHelp
            $ph | Should -Not -BeNullOrEmpty
            $codeMandatory = $parameter.IsMandatory.ToString()
            $ph.Required | Should -Be $codeMandatory
        }

        It 'Has correct parameter type' {
            $ph = $parameterHelp
            $ph | Should -Not -BeNullOrEmpty

            # Robust extraction of type from platyPS-generated help:
            #  - Many parameters use .ParameterValue (e.g. "String", "SwitchParameter", "String[]")
            #  - Enum-like parameters (e.g. MatchCasing/MatchType) are emitted as .Type.Name
            $helpType = $null
            if ($ph.PSObject.Properties.Match('ParameterValue').Count -gt 0 -and $ph.ParameterValue) {
                $helpType = $ph.ParameterValue.Trim()
            } elseif ($ph.PSObject.Properties.Match('Type').Count -gt 0 -and $ph.Type -and $ph.Type.Name) {
                $helpType = $ph.Type.Name.Trim()
            }

            $expectedType = $parameter.ParameterType.Name
            $helpType | Should -Be $expectedType
        }
    }

    Context 'Help-only parameters must exist in code' -ForEach $helpParameterNames {
        It 'finds help parameter in code: <_>' {
            $_ -in $commandParameterNames | Should -Be $true
        }
    }
}
