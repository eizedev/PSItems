---
external help file: PSItems-help.xml
Module Name: PSItems
online version: https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0
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

Root path to search items for.
Defaults to current working directory.
The relative or absolute path to the directory to search. This string is not case-sensitive.

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

This is the searchPattern for the Enumeration class.
The search string to match against the names of items in path.
This parameter can contain a combination of valid literal and wildcard characters,
but it doesn't support regular expressions.
You can use the * (asterisk) to match zero or more characters in that position.
You can also use the ? (question mark) to exactly match one character in that position.

Default is '*' = all items

Characters other than the wildcard are literal characters.
For example, the searchPattern string "*t" searches for all names in path ending with the letter "t". The searchPattern string "s*" searches for all names in path beginning with the letter "s".

One ore more strings to search for (f.e.
'*.exe' OR '*.exe','*.log' OR 'foo*.log')

When you use the asterisk wildcard character in a searchPattern such as "*.txt", the number of characters in the specified extension affects the search as follows:

- If the specified extension is exactly three characters long, the method returns files with extensions that begin with the specified extension. For example, "*.xls" returns both "book.xls" and "book.xlsx".
- In all other cases, the method returns files that exactly match the specified extension. For example, "*.ai" returns "file.ai" but not "file.aif".

When you use the question mark wildcard character, this method returns only files that match the specified file extension. For example, given two files, "file1.txt" and "file1.txtother", in a directory, a search pattern of "file?.txt" returns just the first file, whereas a search pattern of "file*.txt" returns both files.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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
Check <https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0> for more information.

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

[https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0)

[https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0)
