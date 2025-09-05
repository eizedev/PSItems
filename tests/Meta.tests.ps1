BeforeAll {

    Set-StrictMode -Version latest

    # Make sure MetaFixers.psm1 is loaded - it contains Get-TextFilesList
    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'MetaFixers.psm1') -Verbose:$false -Force

    $projectRoot = $ENV:BHProjectPath
    if (-not $projectRoot) { $projectRoot = $PSScriptRoot }

    # Exclude common generated/third-party dirs
    $excludeDirs = @('\.git', '\.github', '\.vscode', '\out', '\Output', '\bin', '\obj', '\res')
    $excludeRegex = [regex]::new('(' + ($excludeDirs -join '|') + ')(\\|/)', 'IgnoreCase')

    $allTextFiles = Get-TextFilesList $projectRoot | Where-Object { -not $excludeRegex.IsMatch($_.FullName) }

    $unicodeFilesCount = 0
    $totalTabsCount = 0

    foreach ($textFile in $allTextFiles) {
        if (Test-FileUnicode $textFile) {
            $unicodeFilesCount++
            Write-Warning (
                "File $($textFile.FullName) contains 0x00 bytes. " +
                'It probably uses UTF-16 and needs to be converted to UTF-8. ' +
                "Use Fixer: Get-UnicodeFilesList `$pwd | ConvertTo-UTF8"
            )
        }

        $fileName = $textFile.FullName
        (Get-Content $fileName -Raw) | Select-String "`t" | ForEach-Object {
            Write-Warning (
                "There are tabs in $fileName. " +
                "Use Fixer: Get-TextFilesList `$pwd | ConvertTo-SpaceIndentation"
            )
            $totalTabsCount++
        }
    }
}

Describe 'Text files formatting' {
    Context 'File encoding' {
        It 'No text file uses Unicode/UTF-16 encoding' {
            $unicodeFilesCount | Should -Be 0
        }
    }

    Context 'Indentations' {
        It 'No text file uses tabs for indentation' {
            $totalTabsCount | Should -Be 0
        }
    }
}
