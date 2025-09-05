function Find-Item {
    <#
    .SYNOPSIS
    Simple and fast function for finding any item on the filesystem (like find on Linux/Unix)

    .DESCRIPTION
    Function that uses the EnumerateFiles, EnumerateDirectories, EnumerateFileSystemEntries method from the dotnet class System.Io.Directory
    (and System.IO.DirectoryInfo for typed output) to quickly find any item on the filesystem.
    Item could be a directory or a file or anything else.

    Class System.IO.EnumerationOptions does not exist in PowerShell < 6 (so this function is not supported in the normal Windows PowerShell, only in PowerShell Core/7)

    .PARAMETER Path
    Root path to search items for. Defaults to current working directory.
    The relative or absolute path to the directory to search. This string is not case-sensitive.
    Wildcards ARE allowed (e.g., 'C:\Users\*\Documents') and will expand to MULTIPLE root paths (Linux-like behavior).

    .PARAMETER Name
    (Default: '*')
    This is the searchPattern for the Enumeration class.
    The search string to match against the names of items in path.
    This parameter can contain a combination of valid literal and wildcard characters,
    but it doesn't support regular expressions.
    You can use the * (asterisk) to match zero or more characters in that position.
    You can also use the ? (question mark) to exactly match one character in that position.

    Default is '*' = all items

    One ore more strings to search for (f.e. '*.exe' OR '*.exe','*.log' OR 'foo*.log').

    NOTE: Platform casing behavior
      - Windows: PlatformDefault is case-insensitive (=> -Name behaves like Linux -iname).
      - Linux/macOS: PlatformDefault is case-sensitive (=> -Name behaves like Linux -name).

    .PARAMETER Iname
    Case-insensitive variant of -Name (like Linux find -iname).
    If provided, it sets MatchCasing to CaseInsensitive (unless MatchCasing was explicitly specified)
    and uses these patterns in addition to or instead of -Name.
    On Windows, -Name and -Iname behave the same (both case-insensitive). On Linux/macOS they differ.

    .PARAMETER Type
    Only search items of specific type: Directory, File or All

    .PARAMETER Recurse
    EnumerationOptions property RecurseSubdirectories. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.

    .PARAMETER IgnoreInaccessible
    EnumerationOptions property IgnoreInaccessible. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.

    .PARAMETER As
    Could be 'String', 'FileSystemInfo' or 'FileInfo'.
    OutputType of found items will be:
      - String          : array of full paths (fastest)
      - FileSystemInfo  : native typed objects (FileInfo/DirectoryInfo) using DirectoryInfo.Enumerate*
      - FileInfo        : backward compatibility; for files returns FileInfo, for directories returns DirectoryInfo (no breaking change)

    .PARAMETER MatchCasing
    EnumerationOptions property MatchCasing. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.

    .PARAMETER AttributesToSkip
    EnumerationOptions property AttributesToSkip. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.
    Defaults to FileAttributes.Hidden | FileAttributes.System. Specify 0 to disable.

    .PARAMETER MatchType
    EnumerationOptions property MatchType. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.

    .PARAMETER Depth
    EnumerationOptions property MaxRecursionDepth. Implies RecurseSubdirectories = $true when provided.

    .PARAMETER MinDepth
    Minimum directory depth relative to Path before items are returned (like Linux -mindepth). Default 0.

    .PARAMETER IncludeSpecialDirectories
    EnumerationOptions property ReturnSpecialDirectories. Check https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions for more information.

    .EXAMPLE
    PS C:\> Find-Item -Path c:\windows -Name '*.exe' -As FileSystemInfo
    Find all items with file format exe in c:\windows without subdirectory and return each file as FileSystemInfo object

    .EXAMPLE
    PS C:\> psfind
    uses alias psfind for Find-Item. returns all items (files + directories) with full path in current folder

    .EXAMPLE
    PS C:\> search
    uses alias search for Find-Item. returns all items (files + directories) with full path in current folder

    .EXAMPLE
    PS C:\> psfind / -Iname '*.exe' -Recurse
    Linux-like: find / -iname '*.exe' (case-insensitive on all platforms).

    .EXAMPLE
    PS C:\> psfind -Path 'C:\Users\*\Documents' -Type File -Name '*.log' -Recurse
    Linux-like wildcard expansion of multiple root paths: searches every matching Users\<name>\Documents.

    .LINK
    https://github.com/eizedev/PSItems

    .LINK
    https://learn.microsoft.com/dotnet/api/system.io.directoryinfo

    .LINK
    https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions

    .NOTES
    Author: Eizedev

    Last Modified: Sep 5, 2025

    Version: 1.7
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

        # Case-insensitive name(s), like Linux find -iname. Merges with or replaces -Name.
        [Parameter(Mandatory = $false)]
        [string[]]
        $Iname,

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

        # Convert given file path to FileSystemInfo or String. 'FileInfo' kelspt for backward compatibility.
        [Parameter(Mandatory = $false)]
        [ValidateSet('String', 'FileSystemInfo', 'FileInfo')]
        [string]
        $As = 'String',

        # Match case if given
        [Parameter(Mandatory = $false)]
        [System.IO.MatchCasing]
        [ValidateSet('PlatformDefault', 'CaseSensitive', 'CaseInsensitive')]
        $MatchCasing = [System.IO.MatchCasing]::PlatformDefault,

        # Attributes of files to skip (not to search for) (Defaults to FileAttributes.Hidden | FileAttributes.System). Specify 0 to disable
        [Parameter(Mandatory = $false)]
        [ValidateSet(0, 'ReadOnly', 'Hidden', 'System', 'Directory', 'Archive', 'Device', 'Normal', 'Temporary', 'SparseFile', 'ReparsePoint', 'Compressed', 'Offline', 'NotContentIndexed', 'Encrypted', 'IntegrityStream', 'NoScrubData')]
        [object[]]
        $AttributesToSkip = @('Hidden', 'System'),

        # sets the match type
        [Parameter(Mandatory = $false)]
        [System.IO.MatchType]
        [ValidateSet('Simple', 'Win32')]
        $MatchType = [System.IO.MatchType]::Simple,

        # sets a value that indicates the maximum directory depth to recurse while enumerating (RecurseSubdirectories (-Recurse) must be to true)
        [Parameter(Mandatory = $false)]
        [int32]
        $Depth,

        # Minimum directory depth to return (like Linux -mindepth). 0 = include items at root level.
        [Parameter(Mandatory = $false)]
        [int32]
        $MinDepth = 0,

        # if given, return the special directory entries "." and ".."; otherwise, false
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeSpecialDirectories
    )

    # Outputs all function parameters of type string[], bool, switch and int32 (including defaults) as verbose messages.
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $PSCmdlet.MyInvocation.MyCommand.Parameters.Keys | ForEach-Object {
            $val = Get-Variable -Name $_ -ValueOnly -ErrorAction SilentlyContinue
            if ($null -ne $val) {
                if ($val -is [Array]) {
                    Write-Verbose "$($_): '$($val -join "', '")'"
                } else {
                    Write-Verbose "$($_): '$val'"
                }
            }
        }
    }

    # If -Iname is used, merge/override patterns and default to case-insensitive if user didn't set MatchCasing
    if ($PSBoundParameters.ContainsKey('Iname')) {
        if (-not $PSBoundParameters.ContainsKey('Name') -or ($Name -eq '*')) {
            $Name = $Iname
        } else {
            $Name += $Iname
        }
        if (-not $PSBoundParameters.ContainsKey('MatchCasing')) {
            $MatchCasing = [System.IO.MatchCasing]::CaseInsensitive
        }
    }

    # Build EnumerationOptions
    $opt = [System.IO.EnumerationOptions]::new()
    $opt.IgnoreInaccessible = $IgnoreInaccessible
    $opt.MatchCasing = $MatchCasing
    $opt.MatchType = $MatchType
    $opt.ReturnSpecialDirectories = $IncludeSpecialDirectories.IsPresent

    # Depth implies recurse; otherwise use -Recurse switch
    if ($PSBoundParameters.ContainsKey('Depth')) {
        if ($Depth -lt 0) { throw 'Depth must be >= 0.' }
        $opt.MaxRecursionDepth = $Depth
        $opt.RecurseSubdirectories = $true
    } else {
        $opt.RecurseSubdirectories = $Recurse.IsPresent
    }

    # AttributesToSkip: 0 or aggregate bitflags
    if ($AttributesToSkip.Count -eq 1 -and $AttributesToSkip[0] -is [int] -and $AttributesToSkip[0] -eq 0) {
        $opt.AttributesToSkip = [System.IO.FileAttributes]0
    } else {
        $fa = [System.IO.FileAttributes]0
        foreach ($a in $AttributesToSkip) { $fa = $fa -bor ([System.IO.FileAttributes]$a) }
        $opt.AttributesToSkip = $fa
    }

    # Resolve one or many root paths (wildcards allowed)
    try {
        [ref]$prov = $null
        $rootPaths = $PSCmdlet.GetResolvedProviderPathFromPSPath($Path, $prov)
        if (-not $rootPaths -or $rootPaths.Count -eq 0) {
            throw "Path not found: $Path"
        }
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            Write-Verbose "rootPaths: '$($rootPaths -join "', '")'"
        }
    } catch {
        Write-Error $_.Exception.Message
        return
    }

    # Precompute MinDepth helpers once
    $needsMin = ($MinDepth -gt 0)
    $sep1 = [IO.Path]::DirectorySeparatorChar
    $sep2 = [IO.Path]::AltDirectorySeparatorChar

    foreach ($root in $rootPaths) {
        # For backward-friendly verbose wording
        $absolutePath = $root
        if ($PSBoundParameters.ContainsKey('Verbose')) {
            Write-Verbose "absolutePath: '$absolutePath'"
        }

        # Choose API per root based on -As (String => Directory.*, typed => DirectoryInfo.*)
        $useTyped = ($As -ieq 'FileSystemInfo' -or $As -ieq 'FileInfo')
        if ($useTyped) {
            $di = [System.IO.DirectoryInfo]::new($root)
            switch ($Type) {
                'Directory' { $enumerator = { param($pat) $di.EnumerateDirectories($pat, $opt) } }
                'File' { $enumerator = { param($pat) $di.EnumerateFiles($pat, $opt) } }
                default { $enumerator = { param($pat) $di.EnumerateFileSystemInfos($pat, $opt) } }
            }
        } else {
            switch ($Type) {
                'Directory' { $enumerator = { param($pat, $r) [System.IO.Directory]::EnumerateDirectories($r, $pat, $opt) } }
                'File' { $enumerator = { param($pat, $r) [System.IO.Directory]::EnumerateFiles($r, $pat, $opt) } }
                default { $enumerator = { param($pat, $r) [System.IO.Directory]::EnumerateFileSystemEntries($r, $pat, $opt) } }
            }
        }

        # Optional one-time warning when using legacy -As FileInfo with non-File types (only when -Verbose)
        if ($As -ieq 'FileInfo' -and $Type -ne 'File' -and $PSBoundParameters.ContainsKey('Verbose')) {
            Write-Warning "Using -As FileInfo with -Type $Type returns DirectoryInfo for directories. Consider -As FileSystemInfo for clarity."
        }

        foreach ($pattern in $Name) {
            if ($PSBoundParameters.ContainsKey('Verbose')) {
                Write-Verbose "pattern: '$pattern'"
            }

            # Invoke enumerator (note: pass root when using Directory.*)
            $seq = if ($useTyped) { & $enumerator $pattern } else { & $enumerator $pattern $root }

            foreach ($item in $seq) {
                # Full path string for MinDepth calc depending on output mode
                $itemPath = if ($useTyped) { $item.FullName } else { $item }

                # Inline MinDepth filter relative to this root
                if ($needsMin) {
                    $rel = [IO.Path]::GetRelativePath($root, $itemPath)
                    if ($rel -eq '.' -or [string]::IsNullOrEmpty($rel)) {
                        if ($MinDepth -gt 0) { continue }
                    } else {
                        $depth = 0
                        foreach ($ch in $rel.ToCharArray()) {
                            if ($ch -eq $sep1 -or $ch -eq $sep2) { $depth++ }
                        }
                        if ($depth -lt $MinDepth) { continue }
                    }
                }

                # Output
                if ($useTyped) {
                    $item  # FileInfo/DirectoryInfo as-is
                } else {
                    $itemPath  # full path string
                }
            }
        }
    }
}

Set-Alias -Name psfind -Value Find-Item -Force
Set-Alias -Name ff -Value Find-Item -Force
Set-Alias -Name fi -Value Find-Item -Force
Set-Alias -Name search -Value Find-Item -Force
