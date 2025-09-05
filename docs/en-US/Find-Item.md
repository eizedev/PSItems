---
external help file: PSItems-help.xml
Module Name: PSItems
online version: https://learn.microsoft.com/dotnet/api/system.io.directoryinfo?view=net-7.0
schema: 2.0.0
---

# Find-Item

## SYNOPSIS

Simple and fast function for finding any item on the filesystem (similar to `find` on Linux/Unix).

## SYNTAX

```
Find-Item [[-Path] <String>] [[-Name] <String[]>] [-Iname <String[]>] [-Type <String>] [-Recurse]
 [-IgnoreInaccessible <Boolean>] [-As <String>] [-MatchCasing <String>] [-AttributesToSkip <Object[]>]
 [-MatchType <String>] [-Depth <Int32>] [-MinDepth <Int32>] [-IncludeSpecialDirectories]
 [<CommonParameters>]
```

## DESCRIPTION

Uses the .NET `System.IO.Directory` / `System.IO.DirectoryInfo` `Enumerate*` methods together with
`System.IO.EnumerationOptions` to quickly enumerate items (directories, files, or both).

- Requires **PowerShell 7+** (`EnumerationOptions` is not available in Windows PowerShell 5.1).
- `-Path` **supports wildcards** and expands to **multiple root paths** (Linux-like shell globbing behavior).
- `-Name` matches according to **platform default casing**
  (Windows: case-insensitive; Linux/macOS: case-sensitive).
- `-Iname` forces **case-insensitive** matching (Linux `find -iname`).
- `-Depth` maps to `MaxRecursionDepth` (and implies recursion); `-MinDepth` behaves like Linux `-mindepth`.
- Output can be **strings** (fastest) or **typed** `FileSystemInfo` (`FileInfo`/`DirectoryInfo`).

## EXAMPLES

### EXAMPLE 1

```
Find-Item -Path $PSHOME -Name '*.psd1' -Recurse
```

Find all module manifest files under the PowerShell installation directory (cross-platform).

### EXAMPLE 2

```
Find-Item -Path $PSHOME -Iname '*.psm1' -Recurse | Select-Object -First 5
```

Linux-style case-insensitive name match on all platforms; show first 5 module files.

### EXAMPLE 3

```
Find-Item -Path $PSHOME -Depth 1 -Name '*.dll'
```

Limit search to the start directory and its immediate subdirectories (Linux `-maxdepth 1`).

### EXAMPLE 4

```
Find-Item -Path $PSHOME -MinDepth 2 -Iname '*module*' -Recurse
```

Only return items at depth ≥ 2 relative to `-Path` (Linux `-mindepth`).

### EXAMPLE 5

```
Find-Item -Path $PSHOME -Type File -As FileSystemInfo -Recurse |
  Where-Object Length -gt 1MB |
  Select-Object -First 5 FullName, Length
```

Typed output with a size filter that works cross-platform (PowerShell supports size literals like `1MB`).

### EXAMPLE 6

```
Find-Item -Path 'C:\Users\*\Documents' -Type File -Name '*.txt' -Depth 2
```

Windows example: wildcard-expanded **multiple roots** (every matching `Users\<name>\Documents`).

## PARAMETERS

### -Path

Root path to search items for. Defaults to current working directory.
Relative or absolute path to the directory to search.

> Wildcards are allowed (e.g., `C:\Users\*\Documents`) and will expand to **multiple** root paths.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $pwd
Accept pipeline input: False
Accept wildcard characters: True
```

### -Name

Search pattern(s) for enumeration. Supports `*` and `?` wildcards (no regex).
On **Windows** (platform default), matching is case-insensitive. On **Linux/macOS**, it is case-sensitive.

Default is `'*'` (all items). Accepts multiple patterns (e.g., `'*.exe','*.log'`).

> Wildcard notes from .NET:
> - A three-character extension like `*.xls` may also match longer extensions (e.g., `.xlsx`).
> - `?` matches exactly one character; `*` matches zero or more characters.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Iname

Case-insensitive variant of `-Name` (Linux `find -iname`). If provided and `-MatchCasing` is not set,
the function uses `CaseInsensitive` matching. Patterns are merged with or replace `-Name`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (not set)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type

Only search items of a specific type: `Directory`, `File`, or `All`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse

Recurse into subdirectories. Maps to `EnumerationOptions.RecurseSubdirectories`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -IgnoreInaccessible

Skip entries when access is denied (e.g., `UnauthorizedAccessException`, `SecurityException`).
Maps to `EnumerationOptions.IgnoreInaccessible`.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -As

Output type:
- `String` → full paths (fastest)
- `FileSystemInfo` → native `FileInfo`/`DirectoryInfo` via `DirectoryInfo.Enumerate*`
- `FileInfo` → backward compatibility; files as `FileInfo`, directories as `DirectoryInfo`

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: String
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchCasing

Controls case sensitivity of pattern matching (maps to `EnumerationOptions.MatchCasing`).
`PlatformDefault` = case-insensitive on Windows, case-sensitive on Linux/macOS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PlatformDefault
Accept pipeline input: False
Accept wildcard characters: False
```

### -AttributesToSkip

File attributes to skip (maps to `EnumerationOptions.AttributesToSkip`).
Defaults to `Hidden` and `System`. Use `0` to disable skipping.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('Hidden','System')
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchType

Pattern matching engine (maps to `EnumerationOptions.MatchType`): `Simple` or `Win32`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Simple
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth

Maximum recursion depth (maps to `EnumerationOptions.MaxRecursionDepth`).
When specified, recursion is implied. `0` means only the start directory.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (not set)
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinDepth

Minimum directory depth relative to `-Path` before items are returned (Linux `-mindepth`).
`0` includes items at the root level.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeSpecialDirectories

Return the special directory entries `.` and `..` if specified (maps to `EnumerationOptions.ReturnSpecialDirectories`).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

_None._

## OUTPUTS

### System.String

### System.IO.FileSystemInfo

## NOTES

Author: Eizedev
Last Modified: Sep 5, 2025
Version: 0.7.0

## RELATED LINKS

- https://learn.microsoft.com/dotnet/api/system.io.directoryinfo
- https://learn.microsoft.com/dotnet/api/system.io.enumerationoptions
