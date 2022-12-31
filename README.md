# PSItems

| GitHub Actions                                                         | PS Gallery                                          | License                              | Issues                            |
| ---------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------ | --------------------------------- |
| [![GitHub Actions Status][github-actions-badge]][github-actions-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] | [![License][license-badge]][license] | [![Open Issues][issues-badge]][issues]  |

---

A PowerShell module that finds files and directories as well as file content and file and directory information the quick and easy way!

![Logo](res/logo.png)

---

- [PSItems](#psitems)
  - [Overview](#overview)
  - [Roadmap](#roadmap)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Functions](#functions)
    - [Help](#help)
  - [Testing and Speed](#testing-and-speed)
    - [1 - Windows directory recursively - Return FullName strings](#1---windows-directory-recursively---return-fullname-strings)
    - [2 - Windows directory recursively - Return FileInfo objects](#2---windows-directory-recursively---return-fileinfo-objects)
  - [Contributions](#contributions)

---

## Overview

| PowerShell  | Linux/Unix    |    Description   |
| --------------------------| --------------------- | ------------------------|
| `psfind` -> Find-Item       | `find`        | `psfind` is similiar to linux/unix `find` command       |
| `psgrep` -> Find-ItemContent  | `grep` | `psgrep` is similiar to linux/unix `grep` command |
| `pssize` -> Get-ItemSize  | `du` | `pssize` is similiar to linux/unix `du` command |

| CmdLet  | Command    |    Description   |
| --------------------------| --------------------- | ------------------------|
| `psfind`       | `psfind`       | Without parameter psfind returns all items (files, junctions, directories...) with full path in current directory     |
| `pssize`  | `pssize` | `Without parameter psfind rUses all items (files, junctions, directories...) in current directory and return size in MB |
| `psgrep`  | `psgrep 'test'` | returns all files where `'test'` was found in format `filename: line` in the current directory |

> ``📝`` The functions of the module do not run with Windows PowerShell, they require at least PowerShell > 6.0 or a newer version. The [latest, stable PowerShell version](https://github.com/PowerShell/PowerShell/releases) is always recommended

As a person who works a lot with Linux distributions and had not found a way on Windows to find files or folders or their information in a FAST way, I developed this module or functions.
At the beginning I was looking for an alternative to the Linux `find` and developed `Find-Item`.

Of course, all the functions in this module will be working on Windows, Linux and macOS.

`Get-ChildItem` works great to get an overview of current files and folders, but is very, very slow when dealing with a lot of filesystem objects.
So I decided to use the .NET classes directly and used only the functionalities I really need for the particular case.

Since then, I don't have to bother with the Windows Explorer built-in search or struggle around with slowly calling `Get-ChildItem`.

The term "**item**" in PSItems or also the individual function names is a collective term for all file system objects, such as files and directories.
Therefore, for example, the function is called `Find-Item` and not `Find-File`, because with it also junctions, directories, shortcuts etc. can be found.

## Roadmap

> ``📝`` This module is currently under construction and therefore in BETA. The already integrated functions work basically but can still have errors.

- Tests
  - Add Pester Tests for `Get-ItemSize` and `Find-Item` and `Find-ItemContent`
    - [ ] Windows
      - in progress
    - [ ] Linux
    - [ ] macOS
      - in progress
- Documentation
  - Update documentation for functions with more, detailed examples
    - [ ] `Find-Item`
    - [ ] `Get-ItemSize`
    - [ ] `Find-ItemContent`
- Security
  - Add code scanning using github workflow
- New functions and features
  - Further functions around FileSystem objects will be integrated if required. Suggestions are welcome

## Installation

Installation of this module is straight forward, just install it and import it.

```pwsh
Install-Module -Name PSItems
Import-Module -Name PSItems
```

## Usage

The usage and a few examples can be found in the [documentation folder](docs/en-US/) or by using the `Get-Help` cmdlet.

| Cmdlet                                            | Description                                                                                         | Documentation                                  |
| ------------------------------------------------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------- |
| [Find-Item](PSItems/Public/Find-Item.ps1)       | Simple and fast function for finding any item on the filesystem (like find on linux/unix)           | [Find-Item](docs/en-US/Find-Item.md)       |
| [Get-ItemSize](PSItems/Public/Get-ItemSize.ps1) | Simple and fast function for getting the size of any item on the filesystem (like du on linux/unix) | [Get-ItemSize](docs/en-US/Get-ItemSize.md) |
| [Find-ItemContent](PSItems/Public/Find-ItemContent.ps1) | Simple and fast function for finding any given string (regex pattern) in files on the filesystem (like grep on linux/unix) | [Find-ItemContent](docs/en-US/Find-ItemContent.md) |

---

### Functions

Get functions of module:

```pwsh
Get-Command -Module PSItems -CommandType All
```

```pwsh
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           psfind -> Find-Item                                0.3.1      PSItems
Alias           psgrep -> Find-ItemContent                         0.3.1      PSItems
Alias           pssize -> Get-ItemSize                             0.3.1      PSItems
Alias           search -> Find-Item                                0.3.1      PSItems
Alias           size -> Get-ItemSize                               0.3.1      PSItems
Function        Find-Item                                          0.3.1      PSItems
Function        Find-ItemContent                                   0.3.1      PSItems
Function        Get-ItemSize                                       0.3.1      PSItems
```

---

### Help

Get help of function:

```pwsh
Get-Help Find-Item
```

```pwsh
NAME
    Find-Item

SYNOPSIS
    Simple and fast function for finding any item on the filesystem (like find on linux/unix)


SYNTAX
    Find-Item [[-Path] <String>] [[-Name] <String[]>] [-Type <String>] [-Recurse] [-IgnoreInaccessible <Boolean>] [-As <String>] [-MatchCasing <String>] [-AttributesToSkip <String[]>] [-MatchType
    <String>] [-Depth <Int32>] [-ReturnSpecialDirectories] [<CommonParameters>]
...
```

## Testing and Speed

> Testsystem was a windows 10 Lenovo T480 (SSD + Indexing disabled).

### 1 - Windows directory recursively - Return FullName strings

Returned will be an array of the path of all files (FullName).

`Measure-Command { $windir = search C:\Windows\ '*' -Recurse -AttributesToSkip 0 }`

Finding all items (files, directories...) in `C:Windows` directory including all subdirectories (`-Recurse`) as well as hidden and system files (`-AttributesToSkip 0`) using the `Find-Item` function

The alias `search` was used and for the `-Path` (`C:\windows`) and `-Name` (`'*'`) parameter the first and second position were used:

![image](https://user-images.githubusercontent.com/6794362/183594261-2f14beb8-be96-4181-8719-1b95ff271e62.png)

In about 1 minute the function found all files, directories etc. in the complete windows directory and returned an array of all item `FullName` properties.

### 2 - Windows directory recursively - Return FileInfo objects

Returned will be an array of objects (FileInfo) of all items. Same as using Get-ChildItem.

`Measure-Command { $windir = search C:\Windows\ '*' -Recurse -AttributesToSkip 0 -As FileInfo }`

Finding all items (files, directories...) in `C:Windows` directory including all subdirectories (`-Recurse`) as well as hidden and system files (`-AttributesToSkip 0`) using the `Find-Item` function.

The alias `search` was used and for the `-Path` (`C:\windows`) and `-Name` (`'*'`) parameter the first and second position were used:

![image](https://user-images.githubusercontent.com/6794362/183596627-73995cca-a602-4ae7-9e75-8fe8b6d14d4a.png)
![image](https://user-images.githubusercontent.com/6794362/183596709-de8718c9-e361-4843-96f5-34e9677f840e.png)

In about 2 minutes the function found all files, directories etc. in the complete windows directory and returned an array of FileInfo objects of all items with all properties. As with Get-ChildItem, you can simply continue to use the individual objects.

## Contributions

The goal of this project is to write simple but (very) fast functions for finding (and perhaps managing) FileSystem Objects and their information.

Additional features or capabilities that benefit the community are welcome.

If you find bugs, please report them on the [issues page](https://github.com/eizedev/PSItems/issues) or, if you can, open a pull request directly with a solution.
If you have a good idea for improving individual features or for new features, feel free to let me know as well.

[github-actions-badge]: https://github.com/eizedev/PSItems/workflows/CI/badge.svg
[github-actions-build]: https://github.com/eizedev/PSItems/actions
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/PSItems.svg
[psgallery]: https://www.powershellgallery.com/packages/PSItems
[license-badge]: https://img.shields.io/github/license/eizedev/PSItems.svg
[license]: https://www.powershellgallery.com/packages/PSItems
[issues-badge]: https://img.shields.io/github/issues-raw/eizedev/PSItems.svg
[issues]: https://github.com/eizedev/PSItems/issues
