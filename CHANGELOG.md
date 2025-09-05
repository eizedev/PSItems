# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

_No changes yet._

## [0.7.0] - 2025-09-05

### `Find-Item`

#### Added
- **Wildcard-expanded roots**: `-Path` can include wildcards (e.g., `C:\Users\*\Documents`) and is expanded to **multiple root paths**, searched one by one (Linux-like behavior).
- Examples for multi-root usage added to help.

#### Changed
- Per-root verbose output (`absolutePath`) and pattern logging retained with multi-root awareness.
- Documentation clarifies that `-As FileSystemInfo` is the recommended typed output; `-As FileInfo` remains supported for backward compatibility.

#### Fixed
- Ensured `MinDepth` is applied **per root**.
- Kept streaming enumeration (`Enumerate*`) for low memory footprint across multiple roots.

### CI/CD & Infrastructure

#### Added
- **Code scanning outputs**: SARIF uploads to the Security tab for DevSkim and PSScriptAnalyzer.

#### Changed
- **Cross-platform CI**: Updated GitHub Actions to run **Build/Analyze/Test** on `ubuntu-latest`, `windows-latest`, and `macos-latest` with `pwsh`.
- **Faster CI**: Caching of user-scoped PowerShell modules keyed by `requirements.psd1`.
- **Publish flow**: Tag-based publish job on Windows.
- **Auto-maintenance**: New workflow to **remove “stale” labels immediately on any new comment** (issues and PRs).
- **Dev tooling bumps** (build/runtime neutral):
  - Pester **5.7.1**
  - PSScriptAnalyzer **1.24.0**
  - PowerShellBuild **0.7.1**
  - psake **4.9.1**
- **VS Code tasks**: Unified on `pwsh` and `${workspaceFolder}` for consistent local runs.

---

## [0.6.1] - (not released)

### `Find-Item`

#### Changed
- Internal consolidation of typed vs. string enumeration paths (`DirectoryInfo.Enumerate*` vs `Directory.*`).
- Refined verbose wording and minor doc tweaks.

---

## [0.6.0] - (not released)

### `Find-Item`

#### Added
- `-Iname` (Linux-style, always case-insensitive). If specified and `MatchCasing` not set, forces `CaseInsensitive`.
- `-MinDepth` (Linux `-mindepth`) with an inline, allocation-light depth check.

#### Changed
- Documentation clarified cross-platform casing: Windows (`-Name` ≈ `-Iname`), Linux/macOS (`-Name` is case-sensitive).

---

## [0.5.0] - (not released)

### `Find-Item`

#### Added
- Backward compatibility note for `-As FileInfo`; introduced **`-As FileSystemInfo`** (recommended typed output).

#### Fixed
- `AttributesToSkip` aggregated into proper `[FileAttributes]` bit flags (supports `0` to disable).
- `Depth` correctly implies recursion via `MaxRecursionDepth` + `RecurseSubdirectories = $true`.
- Restored `absolutePath` verbose output.

---

## [0.4.0] - (not released)

### `Find-Item`

#### Changed
- Enums typed for performance: `[System.IO.MatchCasing]`, `[System.IO.MatchType]`.
- Added Verbose parameter dump and `absolutePath` verbose logging.

#### Fixed
- Correct mapping of `EnumerationOptions.MatchType`.

## [0.3.7] - (not released)

### `Find-Item`

#### Fixed
- [Find-Item: relative paths are resolved to the wrong directory - added absolutePath](https://github.com/eizedev/PSItems/issues/19) thanks to @cdonnellytx
  - Added provider resolution via `GetResolvedProviderPathFromPSPath`

## [0.3.6]

- [psgrep - Close StreamReader](https://github.com/eizedev/PSItems/issues/11)
- [psgrep - Use ReadOnly FileStream instead of direct access with Streamreader](https://github.com/eizedev/PSItems/issues/10)

## [0.3.5]

- Added switch `NotMatch` (`-Not`) to `psgrep` to negate the grep (similar to `grep -v`)

## [0.3.4]

- `psgrep`
  - Added `IgnoreCase` support if `Highlight` (`-H`) is also present (`-H -O IgnoreCase`)
- Updated parameter naming so that `-R` is exclusive in all functions (`-R` = `-Recurse`)
  - All functions
    - Renamed `ReturnSpecialDirectories` to `IncludeSpecialDirectories`
  - `pssize`/`size`/`Get-ItemSize`
    - Renamed `Raw` to `AsRaw`
  - `psgrep`/`Find-ItemContent`
    - Renamed `RegexOptions` to `Options`

## [0.3.3]

- Added `Highlight` (`-H`) switch to highlight the pattern in the output when using `psgrep` (`Find-ItemContent`)

## [0.3.2]

- The parameter order for `psgrep` has been changed so that specifying the parameter name `-Pattern` is no longer mandatory, since it is now the first parameter

## [0.3.1]

- Removed alias `look` of function `Find-ItemContent` as it correlates with the Linux/Unix command `look`
- Added alias `psfind` for `Find-Item`
- Added alias `pssize` for `Get-ItemSize`

## [0.3.0]

- Added new function `Find-ItemContent` with aliases `psgrep` and `look` as a fast alternative for Linux/Unix `grep`

## [0.2.4]

- Updated module manifest to include Functions/Aliases to export (This will support auto loading of the functions during pwsh start)
- Updated logo
- Added extended documentation for `-Path` and `-Name` parameter to make the use cases more clear

## [0.2.3]

Also export aliases

## [0.2.2]

Disabled private functions

## [0.2.1]

Second public release using tags

## [0.2.0]

First public release

## [0.1.1]

Second testing release

## [0.1.0]

First testing release

---

[Unreleased]: https://github.com/eizedev/PSItems/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/eizedev/PSItems/compare/v0.3.6...v0.7.0
[0.3.6]: https://github.com/eizedev/PSItems/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/eizedev/PSItems/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/eizedev/PSItems/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/eizedev/PSItems/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/eizedev/PSItems/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/eizedev/PSItems/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/eizedev/PSItems/compare/v0.2.4...v0.3.0
[0.2.4]: https://github.com/eizedev/PSItems/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/eizedev/PSItems/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/eizedev/PSItems/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/eizedev/PSItems/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/eizedev/PSItems/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/eizedev/PSItems/compare/v0.1.0...v0.1.1
