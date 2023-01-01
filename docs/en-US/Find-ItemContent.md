---
external help file: PSItems-help.xml
Module Name: PSItems
online version: https://github.com/eizedev/PSItems
schema: 2.0.0
---

# Find-ItemContent

## SYNOPSIS

Simple and fast function for finding any given string (regex pattern) in files on the filesystem (like grep on linux/unix)

## SYNTAX

```
Find-ItemContent [-Pattern] <String> [[-Path] <String>] [[-Name] <String[]>] [-Recurse]
 [-IgnoreInaccessible <Boolean>] [-MatchCasing <String>] [-AttributesToSkip <String[]>] [-MatchType <String>]
 [-Depth <Int32>] [-ReturnSpecialDirectories] [-RegexOptions <String[]>] [-Highlight] [<CommonParameters>]
```

## DESCRIPTION

Function that uses the EnumerateFiles method from the dotnet class System.Io.Directory to quickly find any file on the filesystem
and will then search for the given pattern in any found file using System.IO.StreamReader with System.Regex.

Class System.IO.EnumerationOptions does not exist in Powershell \< 6 (so this function is not supported in the normal PowerShell, only in PowerShell Core/7)

## EXAMPLES

### EXAMPLE 1

```
Find-ItemContent -Path c:\windows -Pattern 'WindowsUpdate' -Name '*.log' -Recurse
```

Using the alias psgrep.
Search for pattern 'tinysvc' in all files in the current working directory recursively

### EXAMPLE 2

```
psgrep $pwd 'tinysvc' '*' -Recurse
```

Search for pattern 'WindowsUpdate' in all .log files in c:\windows directory recursively

### EXAMPLE 3

```
psgrep 'test'
```

Shortest possible command line call. Searching for 'test' in (-Path) the current directory and -Name will be '*' (all files in current directory)

### EXAMPLE 4

```
psgrep 'test'
```

Same as above example but the pattern 'test' will be highlightet (-H/-Highlight) in the output

### EXAMPLE 5

```
psgrep 'measure' -H -O IgnoreCase
```

Same as above (only with pattern 'measure') but it ignores casing (so it is not CaseSensitive). -O is the short version of -Options and -Options is an alias of -RegexOptions

## PARAMETERS

### -Pattern

string or regex pattern that will be used to find this pattern/string in the files found on the filesystem

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Root path to search items for.
Defaults to current working directory.
The relative or absolute path to the directory to search.
This string is not case-sensitive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $pwd
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

(Default: '*')
This is the searchPattern for the Enumeration class.
The search string to match against the names of items in path.
This parameter can contain a combination of valid literal and wildcard characters,
but it doesn't support regular expressions.
You can use the* (asterisk) to match zero or more characters in that position.
You can also use the ?
(question mark) to exactly match one character in that position.

Default is '*' = all items

One ore more strings to search for (f.e.
'*.exe' OR '*.exe','*.log' OR 'foo*.log')

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: *
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

### -RegexOptions

RegexOptions.
Check h<https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0> for more information.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Options

Required: False
Position: Named
Default value: @('None')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Highlight

Using Microsoft.PowerShell.Commands.MatchInfo class (Select-String) to pre filtered highlight output

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

## NOTES

Author: Eizedev

Last Modified: Dez 30, 2022

Version: 1.0

## RELATED LINKS

[https://github.com/eizedev/PSItems](https://github.com/eizedev/PSItems)

[https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=net-7.0)

[https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0](https://docs.microsoft.com/en-us/dotnet/api/system.io.enumerationoptions?view=net-7.0)

[https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0](https://learn.microsoft.com/en-us/dotnet/api/system.text.regularexpressions.regexoptions?view=net-7.0)
