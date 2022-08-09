# PSItems

| GitHub Actions                                                         | PS Gallery                                          | License                              | Issues                            |
| ---------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------ | --------------------------------- |
| [![GitHub Actions Status][github-actions-badge]][github-actions-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] | [![License][license-badge]][license] | [![Open Issues][issues-badge]][issues]  |

---

A PowerShell module that finds files and directories as well as file and directory information the quick and easy way!

![PSItems_small](https://user-images.githubusercontent.com/6794362/183587608-69d4adab-aeee-4f5f-8073-50685aa0c626.png)

---

- [PSItems](#psitems)
  - [Overview](#overview)
  - [Roadmap](#roadmap)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Contributions](#contributions)

---

## Overview

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
  - Add Pester Tests for `Get-ItemSize` and `Find-Item`
    - [ ] Windows
      - in progress
    - [ ] Linux
    - [ ] macOS
      - in progress
- Documentation
  - Update documentation for functions with more, detailed examples
    - [ ] `Find-Item`
    - [ ] `Get-ItemSize`
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

---

### Functions 

Get functions of module:

```pwsh
Get-Command -Module PSItems -CommandType All
```

```pwsh
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Alias           ff -> Find-Item                                    0.2.3      PSItems
Alias           fi -> Find-Item                                    0.2.3      PSItems
Alias           gis -> Get-ItemSize                                0.2.3      PSItems
Alias           search -> Find-Item                                0.2.3      PSItems
Alias           size -> Get-ItemSize                               0.2.3      PSItems
Function        Find-Item                                          0.2.3      PSItems
Function        Get-ItemSize                                       0.2.3      PSItems
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
