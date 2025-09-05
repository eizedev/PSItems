BeforeAll {
    $moduleName = $env:BHProjectName
    $manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $outputDir = Join-Path -Path $ENV:BHProjectPath -ChildPath 'Output'
    $outputModDir = Join-Path -Path $outputDir -ChildPath $env:BHProjectName
    $outputModVerDir = Join-Path -Path $outputModDir -ChildPath $manifest.ModuleVersion
    $outputManifestPath = Join-Path -Path $outputModVerDir -Child "$($moduleName).psd1"
    $manifestData = Test-ModuleManifest -Path $outputManifestPath -Verbose:$false -ErrorAction Stop -WarningAction SilentlyContinue

    $changelogPath = Join-Path -Path $env:BHProjectPath -Child 'CHANGELOG.md'
    $changelogVersion = Get-Content $changelogPath | ForEach-Object {
        if ($_ -match '^##\s\[(?<Version>(\d+\.){1,3}\d+)\]') {
            $changelogVersion = $matches.Version
            break
        }
    }

    $script:manifest = $null
}

Describe 'Module manifest' {

    Context 'Validation' {

        It 'Has a valid manifest' {
            $manifestData | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid name in the manifest' {
            $manifestData.Name | Should -Be $moduleName
        }

        It 'Has a valid root module' {
            $manifestData.RootModule | Should -Be "$($moduleName).psm1"
        }

        It 'Has a valid version in the manifest' {
            $manifestData.Version -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid description' {
            $manifestData.Description | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid author' {
            $manifestData.Author | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid guid' {
            { [guid]::Parse($manifestData.Guid) } | Should -Not -Throw
        }

        It 'Has a valid copyright' {
            $manifestData.CopyRight | Should -Not -BeNullOrEmpty
        }

        It 'Has a valid version in the changelog' {
            $changelogVersion | Should -Not -BeNullOrEmpty
            $changelogVersion -as [Version] | Should -Not -BeNullOrEmpty
        }

        It 'Changelog and manifest versions are the same' {
            $changelogVersion -as [Version] | Should -Be ( $manifestData.Version -as [Version] )
        }
    }
}

# Git tagging tests:
# - Only run when HEAD is actually tagged (local or CI tag build).
# - CI NOTE: Ensure actions/checkout fetches tags (fetch-depth: 0, fetch-tags: true).
Describe 'Git tagging' {

    BeforeAll {
        $isTagBuild = $false
        $headTag = $null
        $manifestVersion = $manifestData.Version -as [Version]

        # Try to locate git (available in GitHub runners, but guarded for safety)
        try {
            $git = Get-Command git -ErrorAction Stop
        } catch {
            $git = $null
        }

        # CI hint: if the workflow is running on a tag ref (e.g., refs/tags/v0.7.0), treat it as tag-build
        if ($env:GITHUB_REF -like 'refs/tags/*') {
            $isTagBuild = $true
        }

        # Robust detection: is there a tag pointing at HEAD?
        if ($git) {
            try {
                # Prefer exact tag at HEAD. If multiple, pick first.
                $headTag = (& $git tag --points-at HEAD | Select-Object -First 1)
                if ($headTag) {
                    $isTagBuild = $true
                }
            } catch {
                # Ignore git errors and leave $isTagBuild as-is
            }
        }
    }

    It 'Is tagged with a valid version' -Skip:(-not $isTagBuild) {
        # Expected format: vX.Y.Z (leading 'v' is required by the CI publish trigger)
        $headTag | Should -Not -BeNullOrEmpty
        ($headTag -match '^v\d+(\.\d+){1,3}$') | Should -BeTrue
        (($headTag -replace '^v') -as [Version]) | Should -Not -BeNullOrEmpty
    }

    It 'Matches manifest version' -Skip:(-not $isTagBuild) {
        # Compare tag version (without leading 'v') to ModuleVersion
        (($headTag -replace '^v') -as [Version]) | Should -Be $manifestVersion
    }
}
