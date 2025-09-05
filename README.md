# PSItems

| GitHub Actions                                                         | PS Gallery                                          | License                              | Issues                                 |
| ---------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------ | -------------------------------------- |
| [![GitHub Actions Status][github-actions-badge]][github-actions-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] | [![License][license-badge]][license] | [![Open Issues][issues-badge]][issues] |

---

A PowerShell module to **find files/directories**, **search file content**, and **inspect sizes** — fast and with an easy, Linux-like UX.

![Logo](res/logo.png)

---

- [PSItems](#psitems)
  - [Overview](#overview)
    - [Aliases at a glance](#aliases-at-a-glance)
  - [Linux `find` ↔︎ `Find-Item` Compatibility](#linux-find-︎-find-item-compatibility)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Functions](#functions)
    - [Quick start](#quick-start)
      - [Find-Item (`psfind`)](#find-item-psfind)
      - [Get-ItemSize (`pssize`)](#get-itemsize-pssize)
      - [Find-ItemContent (`psgrep`)](#find-itemcontent-psgrep)
  - [Testing and Speed](#testing-and-speed)
    - [1 - Windows directory recursively - Return FullName strings](#1---windows-directory-recursively---return-fullname-strings)
    - [2 - Windows directory recursively - Return FileInfo objects](#2---windows-directory-recursively---return-fileinfo-objects)
  - [Contributing](#contributing)
    - [Validate docs locally (platyPS)](#validate-docs-locally-platyps)

---

## Overview

- Cross-platform: **Windows**, **Linux**, **macOS**
- Requires **PowerShell 7+** (PowerShell Core)
- Uses .NET’s high-performance `System.IO.Directory.Enumerate*` APIs to keep memory low and throughput high
- “Item” means any filesystem object: files, directories, junctions, symlinks, etc.

> See the [Changelog](CHANGELOG.md) for what’s new in each release.

> 📝 **Note:** The module does **not** support Windows PowerShell 5.1; it requires PowerShell 7 or newer.

PSItems grew out of my need for a fast, Linux-like way to search the filesystem on Windows.
While Get-ChildItem is fine for casual listing, it becomes slow at scale, so this module uses .NET’s streaming System.IO.Directory.Enumerate* APIs and focuses on just the features that matter.
"Item" is intentional: these tools work with any filesystem object—files, directories, junctions, symlinks—across Windows, Linux, and macOS.

### Aliases at a glance

| Aliases                        | Underlying cmdlet  | Linux/Unix analog | Description                         |
| ------------------------------ | ------------------ | ----------------- | ----------------------------------- |
| `psfind`, `search`, `ff`, `fi` | `Find-Item`        | `find`            | Find items (files/directories/etc.) |
| `psgrep`                       | `Find-ItemContent` | `grep`            | Search for text/regex in files      |
| `pssize`, `size`               | `Get-ItemSize`     | `du`              | Measure size of files/directories   |


---

## Linux `find` ↔︎ `Find-Item` Compatibility

> **Copy note:** In the table below the pipeline character is escaped as `\|` so the table renders.
> When copying to a shell, **remove the backslashes** before `|`.

| Linux `find` feature                           | Meaning                            | `Find-Item` equivalent                                            | Example (remember to unescape `\|`)                                                                                                                                                                     |
| ---------------------------------------------- | ---------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multiple start paths / wildcard-expanded roots | Shell expands to multiple roots    | **Supported**: the provider expands **`-Path`** wildcards         | `psfind -Path 'C:\Users\*\Documents' -Name *.log -Recurse`                                                                                                                                              |
| `/`                                            | Root directory                     | On Windows, `/` resolves to `C:\`                                 | `psfind / -Name '*' -Recurse`                                                                                                                                                                           |
| `-name PATTERN`                                | Case-sensitive (Linux)             | `-Name PATTERN` uses platform default casing                      | `psfind / -Name '*.log' -Recurse`                                                                                                                                                                       |
| `-iname PATTERN`                               | Case-insensitive                   | `-Iname PATTERN` (always case-insensitive)                        | `psfind / -Iname '*.exe' -Recurse`                                                                                                                                                                      |
| Casing behavior                                | Varies by OS                       | Windows: `-Name` is case-insensitive; Linux/macOS: case-sensitive | —                                                                                                                                                                                                       |
| `-type f`                                      | Files only                         | `-Type File`                                                      | `psfind / -Type File -Name '*.txt' -Recurse`                                                                                                                                                            |
| `-type d`                                      | Directories only                   | `-Type Directory`                                                 | `psfind / -Type Directory -Name 'Pro*' -Recurse`                                                                                                                                                        |
| `-maxdepth N`                                  | Limit recursion depth              | `-Depth N` (also implies recurse)                                 | `psfind / -Depth 2 -Name '*.dll'`                                                                                                                                                                       |
| `-mindepth N`                                  | Minimum depth before matching      | `-MinDepth N`                                                     | `psfind / -MinDepth 3 -Iname '*temp*' -Recurse`                                                                                                                                                         |
| `-ls`                                          | Detailed listing                   | `-As FileSystemInfo`                                              | `psfind / -As FileSystemInfo -Recurse`                                                                                                                                                                  |
| `-exec … {}`                                   | Run command per match              | Pipe to PowerShell                                                | `psfind $HOME -Type File -Iname '*.txt' -Recurse \| ForEach-Object { (Get-Content $_ -ReadCount 0 \| Measure-Object -Line).Lines }`                                                                     |
| `-perm`, `-size`, `-mtime`                     | Permission/size/time filtering     | Not built-in → filter in pipeline                                 | **Typed**: `psfind $HOME -Type File -As FileSystemInfo -Recurse -Depth 1 \| Where-Object Length -gt 1MB` — or — **String**: `psfind $HOME -Type File -Recurse -Depth 1 \| Get-Item \| ? Length -gt 1MB` |
| `-prune`                                       | Exclude directories from traversal | Not built-in → pattern/pipeline filtering                         | `psfind $HOME -Recurse \| Where-Object { $_ -notlike '*\node_modules\*' }`                                                                                                                              |

**Notes**
- `-Path` wildcards expand to **multiple roots** (Linux-like behavior). Each root is searched independently, and `-MinDepth` applies per root.
- Casing: Use `-Iname` for consistent case-insensitive pattern matching across platforms.
- Output modes: `-As String` (fastest), `-As FileSystemInfo` (recommended typed output), `-As FileInfo` kept for backward compatibility (directories still return `DirectoryInfo`).

---

## Installation

Install from the PowerShell Gallery:

    Install-Module -Name PSItems -Scope CurrentUser
    Import-Module -Name PSItems

> You can also vendor the module: clone the repo and `Import-Module` from its path for local development.

---

## Usage

Full docs are in [`docs/en-US`](docs/en-US/) and via `Get-Help`.

| Cmdlet                                                  | Description                                         | Documentation                                      |
| ------------------------------------------------------- | --------------------------------------------------- | -------------------------------------------------- |
| [Find-Item](PSItems/Public/Find-Item.ps1)               | Find any item on the filesystem (Linux-like `find`) | [Find-Item](docs/en-US/Find-Item.md)               |
| [Get-ItemSize](PSItems/Public/Get-ItemSize.ps1)         | Get the size of items (Linux-like `du`)             | [Get-ItemSize](docs/en-US/Get-ItemSize.md)         |
| [Find-ItemContent](PSItems/Public/Find-ItemContent.ps1) | Find a string/regex in files (Linux-like `grep`)    | [Find-ItemContent](docs/en-US/Find-ItemContent.md) |

### Functions

List all exported commands:

    Get-Command -Module PSItems -CommandType All

### Quick start

These examples are conservative and should work on most machines.

#### Find-Item (`psfind`)
```powershell
# List everything in your home directory (one level down), as fast strings
psfind $HOME -Name '*' -Depth 1

# Case-insensitive search for *.log anywhere under $HOME
psfind $HOME -Type File -Iname '*.log' -Recurse
```

#### Get-ItemSize (`pssize`)
```powershell
# Total size of your home directory (one level down), in MB (default)
pssize $HOME -Depth 1

# Size of only files under Documents, returned as a raw byte count
Get-ItemSize -Path (Join-Path $HOME 'Documents') -Type File -Raw
```

#### Find-ItemContent (`psgrep`)
```powershell
# Find 'TODO' in all PowerShell scripts under your home directory (recursive)
psgrep 'TODO' $HOME -Name '*.ps1' -Recurse

# Count lines for each *.txt file under $HOME (pipeline "exec"-style)
psfind $HOME -Type File -Iname '*.txt' -Recurse |
ForEach-Object {
  [pscustomobject]@{
    Path  = $_
    Lines = (Get-Content $_ | Measure-Object -Line).Lines
  }
}
```

> More examples and full parameter docs: see [`docs/en-US`](docs/en-US/) or `Get-Help <CmdletName> -Full`.

---

## Testing and Speed

> You’ll find historical measurements below. New benchmarks are coming soon. Much faster now.

> Testsystem was a windows 10 Lenovo T480 (SSD + Indexing disabled).

### 1 - Windows directory recursively - Return FullName strings

Returned will be an array of the path of all files (FullName).

```powershell
Measure-Command { $windir = search C:\Windows\ '*' -Recurse -AttributesToSkip 0 }
```

Finding all items (files, directories...) in `C:Windows` directory including all subdirectories (`-Recurse`) as well as hidden and system files (`-AttributesToSkip 0`) using the `Find-Item` function

The alias `search` was used and for the `-Path` (`C:\windows`) and `-Name` (`'*'`) parameter the first and second position were used:

![image](https://user-images.githubusercontent.com/6794362/183594261-2f14beb8-be96-4181-8719-1b95ff271e62.png)

In about 1 minute the function found all files, directories etc. in the complete windows directory and returned an array of all item `FullName` properties.

### 2 - Windows directory recursively - Return FileInfo objects

Returned will be an array of objects (FileInfo) of all items. Same as using Get-ChildItem.

```powershell
Measure-Command { $windir = search C:\Windows\ '*' -Recurse -AttributesToSkip 0 -As FileInfo }
```

Finding all items (files, directories...) in `C:Windows` directory including all subdirectories (`-Recurse`) as well as hidden and system files (`-AttributesToSkip 0`) using the `Find-Item` function.

The alias `search` was used and for the `-Path` (`C:\windows`) and `-Name` (`'*'`) parameter the first and second position were used:

![image](https://user-images.githubusercontent.com/6794362/183596627-73995cca-a602-4ae7-9e75-8fe8b6d14d4a.png)
![image](https://user-images.githubusercontent.com/6794362/183596709-de8718c9-e361-4843-96f5-34e9677f840e.png)

In about 2 minutes the function found all files, directories etc. in the complete windows directory and returned an array of FileInfo objects of all items with all properties. As with Get-ChildItem, you can simply continue to use the individual objects.

---

## Contributing

The goal is simple, ergonomic, **fast** filesystem utilities.
PRs that improve performance, reliability, cross-platform behavior, or docs are very welcome.

- File issues if you have some: <https://github.com/eizedev/PSItems/issues>
- Run tests locally: `./build.ps1 -Bootstrap; ./build.ps1 -Task Analyze,Test`

### Validate docs locally (platyPS)

Before pushing, validate that the Markdown help converts to external help (MAML) without errors:

```pwsh
pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; New-ExternalHelp -Path 'docs/en-US' -OutputPath 'out/en-US' -Force -ErrorAction Stop"
```

**What this does**
- Installs/updates **platyPS** for the current user.
- Converts all Markdown help under `docs/en-US` into MAML files in `out/en-US`.
- Exits with an error if structural issues are detected (useful for catching CI failures early).

> Tip: If you see “**Expect Heading**” errors, it almost always means a missing `###` subheading or an unclosed code block above the failing line.


---

[github-actions-badge]: https://github.com/eizedev/PSItems/workflows/CI/badge.svg
[github-actions-build]: https://github.com/eizedev/PSItems/actions
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/PSItems.svg
[psgallery]: https://www.powershellgallery.com/packages/PSItems
[license-badge]: https://img.shields.io/github/license/eizedev/PSItems.svg
[license]: LICENSE
[issues-badge]: https://img.shields.io/github/issues-raw/eizedev/PSItems.svg
[issues]: https://github.com/eizedev/PSItems/issues
