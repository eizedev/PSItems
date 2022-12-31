function Get-ItemSize {
    <#

    .SYNOPSIS
    Simple and fast function for getting the size of any item on the filesystem (like du on linux/unix)

    .DESCRIPTION
    Function that uses the EnumerateFiles, EnumerateDirectories, EnumerateFileSystemEntries method from the dotnet class System.Io.Directory to quickly find any item on the filesystem.
    Item could be a directory or a file or anything else.
    The it converts the found item to a FileInfo object and uses Measure-Object on the Length property to calculate the sum

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
    (Default: All) Only search items of specific type: Directory, File or All

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

    .PARAMETER MaxRecursionDepth
    EnumerationOptions property MatchType. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER Depth
    EnumerationOptions property Depth. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER ReturnSpecialDirectories
    EnumerationOptions property ReturnSpecialDirectories. Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information.

    .PARAMETER Format
    Format (ByteSize) in which the size will be calculated and returned (KB, MB, TB, PB)

    .PARAMETER Raw
    if given, return size as raw value in Bytes without formatting

    .PARAMETER Decimals
    (Default: 2) Number of decimals (rounding digits) used for rounding the returned ByteSize into specified format ($Format)

    .PARAMETER FormatRaw
    if given, return formatted size as raw value in the format specified with -Format

    .EXAMPLE
    PS C:\> Get-ItemSize -Path c:\windows -Raw

    Find all items in c:\windows without subdirectory and return size in raw format (Bytes)

    .EXAMPLE
    PS C:\> Get-ItemSize -Path c:\windows -Name '*.exe'

    Find all items with file ending exe in c:\windows without subdirectory and return size in MB (default)

    .EXAMPLE
    PS C:\> size

    uses alias size for Get-ItemSize. Uses all items (files + directories) in current folder and return size in MB

    .LINK
    https://github.com/eizedev/PSItems

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0

    .LINK
    https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0

    .NOTES
    Author: Eizedev

    Last Modified: Aug 08, 2022

    Version: 1.1

    #>

    #Requires -PSEdition Core

    [CmdletBinding()]
    [OutputType('System.Int32', 'System.Int64')]
    param (
        # Path to search for files. Default = CurrentDirectory the function is running
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
        # Match case if given
        [Parameter(Mandatory = $false)]
        [string]
        [ValidateSet('PlatformDefault', 'CaseSensitive', 'CaseInsensitive')]
        $MatchCasing = 'PlatformDefault',
        # Attributes of files to skip (not to search for) (Could be a string or an string array like @('Hidden', 'System')). Defaults to 0 = disabled
        [Parameter(Mandatory = $false)]
        [ValidateSet(0, 'ReadOnly', 'Hidden', 'System', 'Directory', 'Archive', 'Device', 'Normal', 'Temporary', 'SparseFile', 'ReparsePoint', 'Compressed', 'Offline', 'NotContentIndexed', 'Encrypted', 'IntegrityStream', 'NoScrubData')]
        [string[]]
        $AttributesToSkip = 0,
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
        $ReturnSpecialDirectories,
        # Format (ByteSize) in which the size will be returned
        [ValidateSet ('KB', 'MB', 'GB', 'TB')]
        [string]
        $Format = 'MB',
        # number of decimals (rounding digits) used for rounding the returned ByteSize into specified format ($Format)
        [ValidateScript(
            {
                if ($_ -in 0..15) { $true }
                else {
                    throw 'Decimals (Rounding digits) must be between 0 and 15, inclusive.'
                }
            }
        )]
        [int32]
        $Decimals = 2,
        # if given, return formatted size as raw value in the format specified with -Format
        [Parameter(Mandatory = $false)]
        [switch]
        $FormatRaw,
        # if given, return size as raw value in Bytes without formatting
        [Parameter(Mandatory = $false)]
        [switch]
        $Raw
    )

    # Input Validation
    if ($Type -eq 'Directory') { Write-Warning 'Directories are only containers and will not have any size (length) at all. Specify -Type File or -Type All instead' }

    # Check https://docs.microsoft.com/de-de/dotnet/api/system.io.enumerationoptions?view=net-7.0 for more information and implementations
    $EnumerationOptions = [System.IO.EnumerationOptions]::new()
    $EnumerationOptions.IgnoreInaccessible = $IgnoreInaccessible
    $EnumerationOptions.RecurseSubdirectories = $Recurse.IsPresent
    $EnumerationOptions.MatchCasing = $MatchCasing
    $EnumerationOptions.AttributesToSkip = $AttributesToSkip
    if ($PSBoundParameters.ContainsKey('MatchType')) { $EnumerationOptions.MaxRecursionDepth = $MatchType }
    if ($PSBoundParameters.ContainsKey('Depth')) { $EnumerationOptions.MaxRecursionDepth = $Depth; $EnumerationOptions.RecurseSubdirectories = $true }
    $EnumerationOptions.ReturnSpecialDirectories = $ReturnSpecialDirectories.IsPresent

    # Use specific method of class System.IO.Directory
    switch ($Type) {
        'Directory' { $Method = 'EnumerateDirectories' }
        'File' { $Method = 'EnumerateFiles' }
        Default { $Method = 'EnumerateFileSystemEntries' }
    }

    # Initialize variables
    $ItemSize = 0
    $ItemSizeList = [System.Collections.Generic.List[Int64]]::new()
    try {
        # if more than one string was given use foreach (so if input $Name is a string array)
        foreach ($input in $Name) {
            $list = [System.Collections.Generic.List[Int64]]::new()
            foreach ($item in [System.IO.Directory]::$($Method)($path, $input, $EnumerationOptions)) {
                Write-Verbose $item
                # Convert string of path to FileInfo object and calculate size (sum)
                #$ItemSize = $ItemSize + ([System.IO.FileInfo]::new($item) | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
                $list.Add(([System.IO.FileInfo]::new($item)).Length)
            }
            # sum all items found in directory structure
            $ItemSizeList.Add([System.Linq.Enumerable]::Sum([Int64[]] $list))
        }
        # Sum all items found with all names in directory structure
        $ItemSize = [System.Linq.Enumerable]::Sum([Int64[]] $ItemSizeList)
    } catch {
        throw $_.Exception.Message
    }

    if ($Raw.IsPresent) {
        Write-Output $ItemSize
    } else {
        switch ($Format) {
            'KB' { $ItemSize = [System.Math]::Round($ItemSize / 1KB, $Decimals) }
            'MB' { $ItemSize = [System.Math]::Round($ItemSize / 1MB, $Decimals) }
            'GB' { $ItemSize = [System.Math]::Round($ItemSize / 1GB, $Decimals) }
            'TB' { $ItemSize = [System.Math]::Round($ItemSize / 1TB, $Decimals) }
            'PB' { $ItemSize = [System.Math]::Round($ItemSize / 1PB, $Decimals) }
        }
        if ($FormatRaw.IsPresent) {
            Write-Output $ItemSize
        } else {
            Write-Output $("{0} $($Format)" -f $ItemSize)
        }
    }
}

Set-Alias -Name pssize -Value Get-ItemSize -Force
Set-Alias -Name gis -Value Get-ItemSize -Force
Set-Alias -Name size -Value Get-ItemSize -Force
