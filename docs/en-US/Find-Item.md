---
external help file: PSItems-help.xml
Module Name: PSItems
online version: https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-6.0
schema: 2.0.0
---

# Find-Item

## SYNOPSIS
Simple and fast function for finding any item on the filesystem (like find on linux/unix)

## SYNTAX

```
Find-Item [[-Path] <String>] [[-Name] <String[]>] [-Type <String>] [-Recurse] [-IgnoreInaccessible <Boolean>]
 [-As <String>] [-MatchCasing <String>] [-AttributesToSkip <String[]>] [-MatchType <String>] [-Depth <Int32>]
 [-ReturnSpecialDirectories] [<CommonParameters>]
```

## DESCRIPTION
Function that uses the EnumerateFiles, EnumerateDirectories, EnumerateFileSystemEntries method from the dotnet class System.Io.Directory to quickly find any item on the filesystem
Item could be a directory or a file or anything else

Class System.IO.EnumerationOptions does not exist in Powershell \< 6 (so this function is not supported in the normal PowerShell, only in PowerShell Core/7)

## EXAMPLES

### EXAMPLE 1
```
Find-Item -Path c:\windows -Name '*.exe' -As FileInfo
```

Find all items with file format exe in c:\windows without subdirectory and return each file as FileSystemInfo object

### EXAMPLE 2
```
search
```

uses alias search for Find-Item.
returns all items (files + directories) with full path in current folder

## PARAMETERS

### -Path
Root path to search objects for.
Defaults to current working directory

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $pwd
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Default is '*' = all objects
One ore more strings to search for (f.e.
'*.exe' OR '*.exe','*.log' OR 'foo*.log')

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

### -Type
Only search items of specific type: Directory, File or All

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
EnumerationOptions property RecurseSubdirectories.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

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
EnumerationOptions property IgnoreInaccessible.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

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
Could be String or FileInfo.
OutputType of found items will be an array of strings or an array of FileSystemInfo Objects.

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
EnumerationOptions property MatchCasing.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

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
EnumerationOptions property AttributesToSkip.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('Hidden', 'System')
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchType
EnumerationOptions property MatchType.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth
EnumerationOptions property Depth.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

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

### -ReturnSpecialDirectories
EnumerationOptions property ReturnSpecialDirectories.
Check https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0 for more information.

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

## OUTPUTS

### System.String
### System.IO.FileSystemInfo
## NOTES
Author: Eizedev
Last Modified: Jul 13, 2022
Version: 1.1

## RELATED LINKS

[https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-6.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-6.0)

[https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-6.0)

