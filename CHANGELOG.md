# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.3.4]

- `psgrep`
  - Added `IgnoreCase` support if `Highlight` (`-H`) is also present (`-H -O IgnoreCase`)
- Updated parameter naming so that `-R` is exlusive in all functions (`-R` = `-Recurse`)

## [0.3.3]

- Added `Hightlight` (`-H`) switch to highlight the pattern in the output when using `psgrep` (`Find-ItemContent`)

## [0.3.2]

- The parameter order for `psgrep` has been changed so that specifying the parameter name -Pattern is no longer mandatory, since it is now the first parameter

## [0.3.1]

- Removed alias `look` of function `Find-ItemContent` as it correlates with the linux/unix command look
- Added alias `psfind` for `Find-Item`
- Added alias `pssize` for `Get-ItemSize`

## [0.3.0]

- Added new function `Find-ItemContent` with aliases `psgrep` and `look` as a fast alternative for linux/unix grep

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

[0.3.4]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.4...v0.3.0
[0.2.4]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.1.0...v0.1.1
