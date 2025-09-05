# Linux `find` ↔ PowerShell `Find-Item` Compatibility

This guide maps common **Linux `find`** features to **`Find-Item`** in the PSItems module.

> **Copy note:** In the tables below, the pipeline character is escaped as `\|` to render correctly.
> When copying commands to a shell, **remove the backslashes** before `|`.

---

## Quick mapping table

| Linux `find` feature                           | Meaning                            | `Find-Item` equivalent                                            | Example (remember to unescape `\|`)                                                                                                                                                   |
| ---------------------------------------------- | ---------------------------------- | ----------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Multiple start paths / wildcard-expanded roots | Shell expands to multiple roots    | **Supported**: the provider expands **`-Path`** wildcards         | **Windows:** `psfind -Path 'C:\Users\*\Documents' -Name *.log -Recurse`  \|  **POSIX:** `psfind -Path '/var/*/log' -Name '*.log' -Recurse`                                            |
| `/`                                            | Root directory                     | On Windows, `/` resolves to `C:\`                                 | `psfind / -Name '*' -Recurse`                                                                                                                                                         |
| `-name PATTERN`                                | Case-sensitive (Linux)             | `-Name PATTERN` uses platform default casing                      | `psfind / -Name '*.log' -Recurse`                                                                                                                                                     |
| `-iname PATTERN`                               | Case-insensitive                   | `-Iname PATTERN` (always case-insensitive)                        | `psfind / -Iname '*.exe' -Recurse`                                                                                                                                                    |
| Casing behavior                                | Varies by OS                       | Windows: `-Name` is case-insensitive; Linux/macOS: case-sensitive | —                                                                                                                                                                                     |
| `-type f`                                      | Files only                         | `-Type File`                                                      | `psfind / -Type File -Name '*.txt' -Recurse`                                                                                                                                          |
| `-type d`                                      | Directories only                   | `-Type Directory`                                                 | `psfind / -Type Directory -Name 'Pro*' -Recurse`                                                                                                                                      |
| `-maxdepth N`                                  | Limit recursion depth              | `-Depth N` (also implies recurse)                                 | `psfind / -Depth 2 -Name '*.dll'`                                                                                                                                                     |
| `-mindepth N`                                  | Minimum depth before matching      | `-MinDepth N`                                                     | `psfind / -MinDepth 3 -Iname '*temp*' -Recurse`                                                                                                                                       |
| `-ls`                                          | Detailed listing                   | `-As FileSystemInfo`                                              | `psfind / -As FileSystemInfo -Recurse`                                                                                                                                                |
| `-exec … {}`                                   | Run command per match              | Pipe to PowerShell                                                | `psfind $HOME -Type File -Iname '*.txt' -Recurse \| ForEach-Object { (Get-Content $_ \| Measure-Object -Line).Lines }`                                                                |
| `-perm`, `-size`, `-mtime`                     | Permission/size/time filtering     | Not built-in → filter in pipeline                                 | **Typed**: `psfind $HOME -Type File -As FileSystemInfo -Recurse \| Where-Object Length -gt 1MB` — or — **String**: `psfind $HOME -Type File -Recurse \| Get-Item \| ? Length -gt 1MB` |
| `-prune`                                       | Exclude directories from traversal | Not built-in → pattern/pipeline filtering                         | `psfind $HOME -Recurse \| Where-Object { $_ -notlike '*\node_modules\*' }`                                                                                                            |

**Notes**
- `-Path` wildcards expand to **multiple roots** (Linux-like behavior). Each root is searched independently, and `-MinDepth` applies per root.
- Casing: Use `-Iname` for consistent case-insensitive pattern matching across platforms.
- Output modes: `-As String` (fastest), `-As FileSystemInfo` (recommended typed output), `-As FileInfo` retained for backward compatibility (directories still return `DirectoryInfo`).

---

## Cheat‑sheet conversions

- `find / -name '*.log'` → `psfind / -Name '*.log'`
- `find / -iname '*.log'` → `psfind / -Iname '*.log'`
- `find / -type f -maxdepth 2` → `psfind / -Type File -Depth 2`
- `find / -type d -name 'Pro*'` → `psfind / -Type Directory -Name 'Pro*'`
- `find / -mindepth 3 -maxdepth 5 -name '*.tmp'` → `psfind / -MinDepth 3 -Depth 5 -Name '*.tmp'`
- `find /var -name '*.log' -exec wc -l {} \;` → `psfind /var -Name '*.log' \| ForEach-Object { wc -l $_ }` *(or a PowerShell-native equivalent)*

---

## Examples

### 1) Search multiple home profiles for logs (Windows)
```pwsh
# Expands to multiple roots (one per matching profile):
psfind -Path 'C:\Users\*\Documents' -Iname '*.log' -Recurse
```

### 2) Case-insensitive search under /var (Linux/macOS)
```pwsh
psfind /var -Iname 'readme*' -Recurse
```

### 3) Typed output for size filtering
```pwsh
psfind / -Type File -As FileSystemInfo -Recurse |
  Where-Object Length -gt 10MB
```

### 4) Exclude node_modules with pipeline filtering
```pwsh
psfind $HOME -Recurse |
  Where-Object { $_ -notlike '*\node_modules\*' }
```

---

## Troubleshooting

- If your shell treats `*` or `?` differently, quote patterns: `-Name '*.log'`.
- On Windows, `/` resolves to the system drive root (typically `C:\`) when used as the start path.
- For consistent case-insensitive matching across platforms, prefer `-Iname`.
