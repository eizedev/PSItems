# PSItems — fast filesystem search & content scanning for PowerShell

<!-- === Badges: Core status & distribution === -->
| GitHub Actions                                                         | PS Gallery (downloads + version)                                                                          | License                              | Issues / PRs                                                              |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------- |
| [![GitHub Actions Status][github-actions-badge]][github-actions-build] | [![PowerShell Gallery][psgallery-badge]][psgallery] [![PS Gallery Version][psgallery-version]][psgallery] | [![License][license-badge]][license] | [![Open Issues][issues-badge]][issues] [![Open PRs][prs-badge]][prs-link] |

<!-- === Badges: Quality & health (slim) === -->
| Runtime (pwsh)         | Platforms                     | Quality & Maintenance                                                                                                                 |
| ---------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| ![pwsh 7+][pwsh-badge] | ![Platforms][platforms-badge] | [![PSSA][pssa-badge]][pssa-workflow] [![DevSkim][devskim-badge]][devskim-workflow] [![Dependabot][dependabot-badge]][dependabot-link] |

![Logo](res/logo.png)

---

A Linux-style toolkit for PowerShell that’s **fast by default**. It streams from `.NET System.IO.Enumerate*` to keep memory low and throughput high.

## Features at a glance
- **Cross-platform**: Windows • Linux • macOS (PowerShell **7+**).
- **Commands**: `psfind` (find files/dirs), `psgrep` (search content), `pssize` (measure sizes).
- **Linux-like UX**: switches such as `-Iname`, `-Type`, `-Depth`, `-MinDepth`. `-Path` wildcards expand to multiple roots.
- **Fast**: streaming enumeration with minimal allocations.

---

## Installation

```pwsh
Install-Module -Name PSItems -Scope CurrentUser
Import-Module -Name PSItems
```

---

## Aliases at a glance

| Aliases                        | Underlying cmdlet  | Linux/Unix analog | Description                         |
| ------------------------------ | ------------------ | ----------------- | ----------------------------------- |
| `psfind`, `search`, `ff`, `fi` | `Find-Item`        | `find`            | Find items (files/directories/etc.) |
| `psgrep`                       | `Find-ItemContent` | `grep`            | Search for text/regex in files      |
| `pssize`, `size`               | `Get-ItemSize`     | `du`              | Measure size of files/directories   |

---

## Quick start

```pwsh
# Find: list everything one level down as fast strings
psfind $HOME -Name '*' -Depth 1

# Find: case-insensitive *.log anywhere
psfind $HOME -Type File -Iname '*.log' -Recurse

# Size: quick size of your home (one level down), in MB (default)
pssize $HOME -Depth 1

# Grep: find 'TODO' in all PowerShell scripts under your home (recursive)
psgrep 'TODO' $HOME -Name '*.ps1' -Recurse
```

> Complete docs for each cmdlet live in `docs/en-US/` and via `Get-Help <CmdletName> -Full`.

---

## Linux `find` ↔︎ `Find-Item` (quick map)

> Full guide with more options & examples: [docs/guides/Linux-find-compatibility.md](docs/guides/Linux-find-compatibility.md)

| Linux `find` feature          | `Find-Item` equivalent             | Example (unescape `\|` when copying)                                                |
| ----------------------------- | ---------------------------------- | ----------------------------------------------------------------------------------- |
| Wildcard roots (`/var/*/log`) | `-Path` expands to multiple roots  | `psfind -Path '/var/*/log' -Name '*.log' -Recurse`                                  |
| Root `/`                      | `/` → `C:\` on Windows             | `psfind / -Name '*' -Recurse`                                                       |
| `-name PATTERN`               | `-Name` (platform default casing)  | `psfind / -Name '*.log' -Recurse`                                                   |
| `-iname PATTERN`              | `-Iname` (always case-insensitive) | `psfind / -Iname '*.exe' -Recurse`                                                  |
| `-type f` / `-type d`         | `-Type File` / `-Type Directory`   | `psfind / -Type File -Name '*.txt' -Recurse`                                        |
| `-maxdepth N` / `-mindepth N` | `-Depth N` / `-MinDepth N`         | `psfind / -Depth 2 -Name '*.dll'`                                                   |
| `-ls`                         | `-As FileSystemInfo`               | `psfind / -As FileSystemInfo -Recurse`                                              |
| `-exec … {}`                  | Pipe to PowerShell                 | `psfind $HOME -Type File -Iname '*.txt' -Recurse \| ForEach-Object { Get-Item $_ }` |

**Notes:** Use `-Iname` for portable case-insensitive matching; `-Path` wildcards expand to **multiple roots**; filter size/time/perm in the pipeline.

---

## Testing & Speed

Reproducible, copy‑pasteable benchmarks live here:

- **[docs/benchmarks/Testing-and-Speed.md](docs/benchmarks/Testing-and-Speed.md)**

**Highlights from a sample run (Windows, SSD):**
- Names only (strings): PSItems ~**3.23 s** vs Get-ChildItem ~**17.16 s** → **~5.3× faster**
- Typed output (objects): PSItems ~**3.56 s** vs Get-ChildItem ~**14.19 s** → **~4.0× faster**
- Depth-limited (Depth = 2): PSItems ~**2.14 s** vs Get-ChildItem ~**11.96 s** → **~5.6× faster**
- PSItems 0.7.0 vs 0.3.6 (names-only): ~**3.37 s** vs ~**5.70 s** → **~1.7× faster**

> Numbers vary by machine and dataset. The linked doc shows the exact commands you can re-run locally.

---

## Contributing

PRs that improve performance, reliability, cross‑platform behavior, or docs are welcome.

- Issues: <https://github.com/eizedev/PSItems/issues>
- Full guide (local dev, platyPS, publishing, DevContainer): **[CONTRIBUTING.md](.github/CONTRIBUTING.md)**

> Publishing to the PowerShell Gallery is automated via GitHub Actions; tags like `v0.7.0` trigger a release.

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
