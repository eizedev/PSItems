# PSItems

<!-- === Badges: Core status & distribution === -->
| GitHub Actions                                                         | PS Gallery (downloads + version)                                                                          | License                              | Issues / PRs                                                              |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------- |
| [![GitHub Actions Status][github-actions-badge]][github-actions-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] [![PS Gallery Version][psgallery-version]][psgallery] | [![License][license-badge]][license] | [![Open Issues][issues-badge]][issues] [![Open PRs][prs-badge]][prs-link] |


<!-- === Badges: Quality & health (slim) === -->
| Runtime (pwsh)         | Platforms                     | Quality & Maintenance                                                                                                                 |
| ---------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| ![pwsh 7+][pwsh-badge] | ![Platforms][platforms-badge] | [![PSSA][pssa-badge]][pssa-workflow] [![DevSkim][devskim-badge]][devskim-workflow] [![Dependabot][dependabot-badge]][dependabot-link] |

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
  - [Testing \& Speed](#testing--speed)
  - [Contributing](#contributing)

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

## Testing & Speed

Reproducible benchmarks (including copy-pasteable commands) live here:

- [docs/benchmarks/Testing-and-Speed.md](docs/benchmarks/Testing-and-Speed.md)

**Highlights from the sample run in that doc (Windows, SSD):**
- Names only (strings): PSItems ~**3.23 s** vs Get-ChildItem ~**17.16 s** → **~5.3× faster**
- Typed output (objects): PSItems ~**3.56 s** vs Get-ChildItem ~**14.19 s** → **~4.0× faster**
- Depth-limited (Depth = 2): PSItems ~**2.14 s** vs Get-ChildItem ~**11.96 s** → **~5.6× faster**
- PSItems 0.7.0 vs 0.3.6 (names-only): ~**3.37 s** vs ~**5.70 s** → **~1.7× faster**

> Results vary by machine and dataset. The linked doc shows the exact commands and tables you can re-run locally.
> If you find better/other test cases, please open a PR or issue.

---

## Contributing

The goal is simple, ergonomic, **fast** filesystem utilities.
PRs that improve performance, reliability, cross‑platform behavior, or docs are welcome.

- File issues: <https://github.com/eizedev/PSItems/issues>
- Read the full guide (Contributing, Local Development, platyPS Documentation, Publish Releases, DevContainer): **[CONTRIBUTING.md](.github/CONTRIBUTING.md)**

> Publishing to the PowerShell Gallery is automated via GitHub Actions and triggered by tags like `v0.7.0`. See **[CONTRIBUTING.md](.github/CONTRIBUTING.md)** for the exact steps.




---

<!-- Badge references -->
[github-actions-badge]: https://github.com/eizedev/PSItems/workflows/CI/badge.svg
[github-actions-build]: https://github.com/eizedev/PSItems/actions
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/PSItems.svg
[psgallery-version]: https://img.shields.io/powershellgallery/v/PSItems.svg
[psgallery]: https://www.powershellgallery.com/packages/PSItems
[license-badge]: https://img.shields.io/github/license/eizedev/PSItems.svg
[license]: LICENSE
[issues-badge]: https://img.shields.io/github/issues-raw/eizedev/PSItems.svg
[issues]: https://github.com/eizedev/PSItems/issues
[prs-badge]: https://img.shields.io/github/issues-pr/eizedev/PSItems.svg
[prs-link]: https://github.com/eizedev/PSItems/pulls
[lastcommit-badge]: https://img.shields.io/github/last-commit/eizedev/PSItems.svg
[repo]: https://github.com/eizedev/PSItems

[pwsh-badge]: https://img.shields.io/badge/pwsh-7%2B-blue?logo=powershell
[platforms-badge]: https://img.shields.io/badge/platforms-Windows%20%7C%20Linux%20%7C%20macOS-informational
[dependabot-badge]: https://img.shields.io/badge/Dependabot-enabled-brightgreen?logo=dependabot
[dependabot-link]: https://github.com/eizedev/PSItems/security/dependabot

[pssa-badge]: https://github.com/eizedev/PSItems/actions/workflows/powershell.yml/badge.svg
[pssa-workflow]: https://github.com/eizedev/PSItems/actions/workflows/powershell.yml
[devskim-badge]: https://github.com/eizedev/PSItems/actions/workflows/devskim.yml/badge.svg
[devskim-workflow]: https://github.com/eizedev/PSItems/actions/workflows/devskim.yml
