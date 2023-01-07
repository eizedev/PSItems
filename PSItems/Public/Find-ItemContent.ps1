function Find-ItemContent {
    <#
    .SYNOPSIS
    Simple and fast function for finding any given string (regex pattern) in files on the filesystem (like grep on linux/unix)

    .DESCRIPTION
    Function that uses the EnumerateFiles method from the dotnet class System.Io.Directory to quickly find any file on the filesystem
    and will then search for the given pattern in any found file using System.IO.StreamReader with System.Regex.

    Class System.IO.EnumerationOptions does not exist in Powershell < 6 (so this function is not supported in the normal PowerShell, only in PowerShell Core/7)

    .PARAMETER Path
    Root path to search items for. Defaults to current working directory.
    The relative or absolute path to the directory to search. This string is not case-sensitive.

    .PARAMETER Pattern
    string or regex pattern that will be used to find this pattern/string in the files found on the filesystem

    .PARAMETER Name
    (Default: '*')
    This is the searchPattern for the Enumeration class.
    The search string to match against the names of items in path.
    This parameter can contain a combination of valid literal and wildcard characters,
    but it doesn't support regular expressions.
    You can use the * (asterisk) to match zero or more characters in that position.
    You can also use the ? (question mark) to exactly match one character in that position.

    Default is '*' = all items

    One ore more strings to search for (f.e. '*.exe' OR '*.exe','*.log' OR 'foo*.log')

    .PARAMETER Recurse
    EnumerationOptions property RecurseSubdirectories. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER IgnoreInaccessible
    EnumerationOptions property IgnoreInaccessible. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER MatchCasing
    EnumerationOptions property MatchCasing. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER AttributesToSkip
    EnumerationOptions property AttributesToSkip. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER MatchType
    EnumerationOptions property MatchType. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER Depth
    EnumerationOptions property Depth. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER IncludeSpecialDirectories
    EnumerationOptions property ReturnSpecialDirectories. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER Options
    RegexOptions. Check hhttps://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0 for more information.

    .PARAMETER Highlight
    Using Microsoft.PowerShell.Commands.MatchInfo class (Select-String) to pre filtered highlight output.
    Direct usage of MatchInfo class is not possible since i also want to output the file where the pattern was found.
    So we first use Regex class to find the pattern in a fast way and then use Select-String to output all as MatchInfo type to highlight the pattern.

    .PARAMETER NotMatch
    negates the matched pattern, so, show all results if pattern not matches.
    Currently, pipelining is not supported (yet). Therefore we would need an InputObject parameter that accepts pipeline input and need to bypass the Enumeration of filesystem objects

    .EXAMPLE
    PS C:\> Find-ItemContent -Path c:\windows -Pattern 'WindowsUpdate' -Name '*.log' -Recurse

    Using the alias psgrep. Search for pattern 'tinysvc' in all files in the current working directory recursively

    .EXAMPLE
    PS C:\> psgrep $pwd 'tinysvc' '*' -Recurse

    Search for pattern 'WindowsUpdate' in all .log files in c:\windows directory recursively

    .EXAMPLE
    PS C:\> psgrep 'test'

    Shortest possible command line call. Searching for 'test' in (-Path) the current directory and -Name will be '*' (all files in current directory)

    .EXAMPLE
    PS C:\> psgrep 'test' -H

    Same as above example but the pattern 'test' will be highlightet (-H/-Highlight) in the output

    .EXAMPLE
    PS C:\> psgrep 'measure' -H -O IgnoreCase

    Same as above (only with pattern 'measure') but it ignores casing (so it is not CaseSensitive). -O is the short version of -Options and -Options is an alias of -RegexOptions

    .EXAMPLE
    PS C:\> psgrep 'measure' -H -R -O IgnoreCase

    Equivalent to linux/unix grep: grep -HiR 'measure'

    .EXAMPLE
    PS C:\> psgrep 'output' -Name 'CHANGELOG.md'

    Searches for pattern 'output' in file 'CHANGELOG.md' in current directory

    .EXAMPLE
    PS C:\> psgrep 'output' -Name 'CHANGELOG.md' -Not

    Negates above search (grep -v). Searches for pattern 'output' in file 'CHANGELOG.md' in current directory and outputs all lines that are not match to this pattern.
    .LINK
    https://github.com/eizedev/PSItems

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0

    .LINK
    https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0

    .NOTES
    Author: Eizedev

    Last Modified: Jan 01, 2023

    Version: 1.3

    #>

    #Requires -PSEdition Core

    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # Pattern for searching for in files
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Pattern,
        # Path to search for files
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Path = $pwd,
        # Name for searching for files
        [Parameter(Mandatory = $false, Position = 2)]
        [string[]]
        $Name = '*',
        # Include subdirectories if given
        [Parameter(Mandatory = $false)]
        [switch]
        $Recurse,
        # Sets a value that indicates whether to skip files or directories when access is denied (for example, UnauthorizedAccessException or SecurityException). Default is true
        [Parameter(Mandatory = $false)]
        [bool]
        $IgnoreInaccessible = $true,
        # Match case if given
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('PlatformDefault', 'CaseSensitive', 'CaseInsensitive')]
        $MatchCasing = 'PlatformDefault',
        # Attributes of files to skip (not to search for) (Defaults to FileAttributes.Hidden | FileAttributes.System). Specify 0 to disable
        [Parameter(Mandatory = $false)]
        [ValidateSet(0, 'ReadOnly', 'Hidden', 'System', 'Directory', 'Archive', 'Device', 'Normal', 'Temporary', 'SparseFile', 'ReparsePoint', 'Compressed', 'Offline', 'NotContentIndexed', 'Encrypted', 'IntegrityStream', 'NoScrubData')]
        [string[]]
        $AttributesToSkip = @('Hidden', 'System'),
        # sets the match type
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('Simple', 'Win32')]
        $MatchType,
        # sets a value that indicates the maximum directory depth to recurse while enumerating (RecurseSubdirectories (-Recurse) must be to true)
        [Parameter(Mandatory = $false)]
        [int32]
        $Depth,
        # if given, return the special directory entries "." and ".."; otherwise, false
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeSpecialDirectories,
        # Regex Options, check https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0
        [Parameter(Mandatory = $false)]
        [ValidateSet('None', 'Compiled', 'CultureInvariant', 'ECMAScript', 'ExplicitCapture', 'IgnoreCase', 'IgnorePatternWhitespace', 'Multiline', 'NonBacktracking', 'RightToLeft', 'Singleline')]
        [string[]]
        $Options = @('None'),
        # Using Microsoft.PowerShell.Commands.MatchInfo class (Select-String) to pre filtered highlight output
        [Parameter(Mandatory = $false)]
        [switch]
        $Highlight,
        # negates the matched pattern, so, show all results if pattern not matches
        [Parameter(Mandatory = $false)]
        [switch]
        $NotMatch
    )

    # System.IO Enumeration Options
    # Check https://docs.microsoft.com/de-de/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information and implementations
    $EnumerationOptions = [System.IO.EnumerationOptions]::new()
    $EnumerationOptions.IgnoreInaccessible = $IgnoreInaccessible
    $EnumerationOptions.RecurseSubdirectories = $Recurse.IsPresent
    $EnumerationOptions.MatchCasing = $MatchCasing
    $EnumerationOptions.AttributesToSkip = $AttributesToSkip
    if ($PSBoundParameters.ContainsKey('MatchType')) { $EnumerationOptions.MaxRecursionDepth = $MatchType }
    if ($PSBoundParameters.ContainsKey('Depth')) { $EnumerationOptions.MaxRecursionDepth = $Depth; $EnumerationOptions.RecurseSubdirectories = $true }
    $EnumerationOptions.ReturnSpecialDirectories = $IncludeSpecialDirectories.IsPresent

    # Use specific method of class System.IO.Directory for files
    $Method = 'EnumerateFiles'

    # Regex matching RegexOptions
    # check https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0 for more information and implementations
    $Options = [Text.RegularExpressions.RegexOptions]$(($Options -join ', ').TrimEnd(', '))

    try {
        # if more than one string was given use foreach (so if input $Name is a string array)
        foreach ($input in $Name) {
            foreach ($item in [System.IO.Directory]::$($Method)($path, $input, $EnumerationOptions)) {
                $file = [string]::new($item)
                # Read each line using streamreader and use regex to find given pattern in each line. Output filename and matched line
                $reader = [System.IO.StreamReader]::new($file)
                while ($reader.EndOfStream -eq $false) {
                    $line = $reader.ReadLine()
                    $match = [Regex]::Matches($line, $pattern, $Options)
                    if (-Not $NotMatch) {
                        if (-Not [string]::IsNullOrEmpty($match)) {
                            $Output = "$($file): $($line.Trim())"
                            if ($Highlight.IsPresent) {
                                if ($Options -match 'IgnoreCase') {
                                    $Output = Select-String -InputObject $Output -Pattern $Pattern -AllMatches
                                } else {
                                    $Output = Select-String -InputObject $Output -Pattern $Pattern -AllMatches -CaseSensitive
                                }
                            }
                            Write-Output $Output
                        }
                    } elseif ([string]::IsNullOrEmpty($match)) {
                        $Output = "$($file): $($line.Trim())"
                        Write-Output $Output
                    }
                }
                $reader.Close()
                $reader.Dispose()
            }
        }
    } catch {
        throw $_.Exception.Message
    }
}

Set-Alias -Name psgrep -Value Find-ItemContent -Force
