---
external help file: PSItems-help.xml
Module Name: PSItems
online version: https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0
schema: 2.0.0
---

# Get-ItemSize

## SYNOPSIS

Simple and fast function for getting the size of any item on the filesystem (like du on linux/unix)

## SYNTAX

```
Get-ItemSize [[-Path] <String>] [[-Name] <String[]>] [-Type <String>] [-Recurse]
 [-IgnoreInaccessible <Boolean>] [-MatchCasing <String>] [-AttributesToSkip <String[]>] [-MatchType <String>]
 [-Depth <Int32>] [-ReturnSpecialDirectories] [-Format <String>] [-Decimals <Int32>] [-FormatRaw] [-Raw]
 [<CommonParameters>]
```

## DESCRIPTION

Function that uses the EnumerateFiles, EnumerateDirectories, EnumerateFileSystemEntries method from the dotnet class System.Io.Directory to quickly find any item on the filesystem.
Item could be a directory or a file or anything else.
The it converts the found item to a FileInfo object and uses Measure-Object on the Length property to calculate the sum

Class System.IO.EnumerationOptions does not exist in Powershell \< 6 (so this function is not supported in the normal PowerShell, only in PowerShell Core/7)

## EXAMPLES

### EXAMPLE 1

```
Get-ItemSize -Path c:\windows -Raw
```

Find all items in c:\windows without subdirectory and return size in raw format (Bytes)

### EXAMPLE 2

```
Get-ItemSize -Path c:\windows -Name '*.exe'
```

Find all items with file ending exe in c:\windows without subdirectory and return size in MB (default)

### EXAMPLE 3

```
size
```

uses alias size for Get-ItemSize.
Uses all items (files + directories) in current folder and return size in MB

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

Default is `'*'` = all items

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

(Default: All) Only search items of specific type: Directory, File or All

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
Default value: 0
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

### -Format

Format (ByteSize) in which the size will be calculated and returned (KB, MB, TB, PB)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: MB
Accept pipeline input: False
Accept wildcard characters: False
```

### -Decimals

(Default: 2) Number of decimals (rounding digits) used for rounding the returned ByteSize into specified format ($Format)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 2
Accept pipeline input: False
Accept wildcard characters: False
```

### -FormatRaw

if given, return formatted size as raw value in the format specified with -Format

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

### -Raw

if given, return size as raw value in Bytes without formatting

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

### System.Int32

### System.Int64

## NOTES

Author: Eizedev
Last Modified: Aug 08, 2022
Version: 1.1

## RELATED LINKS

[https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0)

[https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0)
