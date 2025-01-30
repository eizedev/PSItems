function Find-Item {
    <#
    .SYNOPSIS
    Simple and fast function for finding any item on the filesystem (like find on linux/unix)

    .DESCRIPTION
    Function that uses the EnumerateFiles, EnumerateDirectories, EnumerateFileSystemEntries method from the dotnet class System.Io.Directory to quickly find any item on the filesystem
    Item could be a directory or a file or anything else

    Class System.IO.EnumerationOptions does not exist in Powershell < 6 (so this function is not supported in the normal PowerShell, only in PowerShell Core/7)

    .PARAMETER Path
    Root path to search items for. Defaults to current working directory.
    The relative or absolute path to the directory to search. This string is not case-sensitive.

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



    .PARAMETER Type
    Only search items of specific type: Directory, File or All

    .PARAMETER Recurse
    EnumerationOptions property RecurseSubdirectories. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER IgnoreInaccessible
    EnumerationOptions property IgnoreInaccessible. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER As
    Could be String or FileInfo.
    OutputType of found items will be an array of strings or an array of FileSystemInfo Objects.

    .PARAMETER MatchCasing
    EnumerationOptions property MatchCasing. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER AttributesToSkip
    EnumerationOptions property AttributesToSkip. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER MatchType
    EnumerationOptions property MatchType. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER MaxRecursionDepth
    EnumerationOptions property MatchType. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER Depth
    EnumerationOptions property Depth. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER IncludeSpecialDirectories
    EnumerationOptions property ReturnSpecialDirectories. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .EXAMPLE
    PS C:\> Find-Item -Path c:\windows -Name '*.exe' -As FileInfo

    Find all items with file format exe in c:\windows without subdirectory and return each file as FileSystemInfo object

    .EXAMPLE
    PS C:\> psfind

    uses alias psfind for Find-Item. returns all items (files + directories) with full path in current folder

    .EXAMPLE
    PS C:\> search

    uses alias search for Find-Item. returns all items (files + directories) with full path in current folder

    .LINK
    https://github.com/eizedev/PSItems

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0

    .NOTES
    Author: Eizedev

    Last Modified: Dec 31, 2022

    Version: 1.2

    #>

    #Requires -PSEdition Core

    [CmdletBinding()]
    [OutputType('System.String', 'System.IO.FileSystemInfo')]
    param (
        # Path to search for files.  Defaults to current directory.
        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $Path = $pwd,
        # Name for searching for files
        [Parameter(Mandatory = $false, Position = 1)]
        [string[]]
        $Name = '*',
        # Type if the items
        [Parameter(Mandatory = $false)]
        [ValidateSet('Directory', 'File', 'All')]
        [string]
        $Type = 'All',
        # Include subdirectories if given
        [Parameter(Mandatory = $false)]
        [switch]
        $Recurse,
        # Sets a value that indicates whether to skip files or directories when access is denied (for example, UnauthorizedAccessException or SecurityException). Default is true
        [Parameter(Mandatory = $false)]
        [bool]
        $IgnoreInaccessible = $true,
        # Convert given file path to FileInfo attribute if FileInfo is specified
        [Parameter(Mandatory = $false)]
        [ValidateSet('String', 'FileInfo')]
        [string]
        $As = 'string',
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
        $IncludeSpecialDirectories
    )

    # Check https://docs.microsoft.com/de-de/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information and implementations
    $EnumerationOptions = [System.IO.EnumerationOptions]::new()
    $EnumerationOptions.IgnoreInaccessible = $IgnoreInaccessible
    $EnumerationOptions.RecurseSubdirectories = $Recurse.IsPresent
    $EnumerationOptions.MatchCasing = $MatchCasing
    $EnumerationOptions.AttributesToSkip = $AttributesToSkip
    if ($PSBoundParameters.ContainsKey('MatchType')) { $EnumerationOptions.MaxRecursionDepth = $MatchType }
    if ($PSBoundParameters.ContainsKey('Depth')) { $EnumerationOptions.MaxRecursionDepth = $Depth; $EnumerationOptions.RecurseSubdirectories = $true }
    $EnumerationOptions.ReturnSpecialDirectories = $IncludeSpecialDirectories.IsPresent

    # Use specific method of class System.IO.Directory
    switch ($Type) {
        'Directory' { $Method = 'EnumerateDirectories' }
        'File' { $Method = 'EnumerateFiles' }
        Default { $Method = 'EnumerateFileSystemEntries' }
    }

    # Resolve absolute path in case it is relative
    [ref] $dummy = $null
    $Path = $PSCmdlet.GetResolvedProviderPathFromPSPath($Path, $dummy)

    try {
        # if more than one string was given use foreach (so if input $Name is a string array)
        foreach ($input in $Name) {
            foreach ($item in [System.IO.Directory]::$($Method)($path, $input, $EnumerationOptions)) {
                if ($As -eq 'FileInfo') { $file = [System.IO.FileInfo]::new($item) } else { $file = [string]::new($item) }
                Write-Output $file
            }
        }
    } catch {
        throw $_.Exception.Message
    }
}

Set-Alias -Name psfind -Value Find-Item -Force
Set-Alias -Name ff -Value Find-Item -Force
Set-Alias -Name fi -Value Find-Item -Force
Set-Alias -Name search -Value Find-Item -Force
