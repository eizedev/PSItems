# Testing and Speed

This section provides **reproducible, lightweight benchmarks** you can run locally to compare PSItems with built-in cmdlets and (optionally) compare module versions.

> **Environment tips**
> - Use PowerShell **7+**.
> - Prefer an SSD and run on AC power.
> - Close other heavy workloads and disable real-time indexing temporarily if possible.
> - Run each test **3 times** and take the **average**.

---

## 1) Names only (strings)

Compare `Get-ChildItem` vs `psfind` returning **strings** (fastest path).

> **Target path**: On Windows use `$Env:WINDIR`; on macOS/Linux use `$HOME`.
> **Parity**: `-Force` on GCI ≈ `-AttributesToSkip 0` on `psfind` (includes hidden/system).

```pwsh
# Built-in (names only)
1..3 | ForEach-Object {
  Measure-Command {
    Get-ChildItem -Path $Env:WINDIR -Recurse -Force -ErrorAction SilentlyContinue |
      ForEach-Object FullName > $null
  } | Select-Object TotalMilliseconds
}

# PSItems (names only)
1..3 | ForEach-Object {
  Measure-Command {
    psfind $Env:WINDIR -Name '*' -Recurse -AttributesToSkip 0 > $null
  } | Select-Object TotalMilliseconds
}
```

### Benchmark: Names only (strings)

| Tool                  | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | **Average (ms)** | Items returned | Speedup vs built-in |
| --------------------- | ---------: | ---------: | ---------: | ---------------: | -------------: | ------------------: |
| Built-in (names only) |   22025.28 |   14916.15 |   14547.40 |    **17162.943** |         222994 |               1.00× |
| PSItems (names only)  |    3365.52 |    3171.32 |    3138.15 |     **3224.997** |         222994 |           **5.32×** |

---

## 2) Typed output (objects)

Compare **typed objects** when you need metadata for further filtering.

```pwsh
# Built-in (typed objects)
1..3 | ForEach-Object {
  Measure-Command {
    Get-ChildItem -Path $Env:WINDIR -Recurse -Force -ErrorAction SilentlyContinue > $null
  } | Select-Object TotalMilliseconds
}

# PSItems (recommended typed output)
1..3 | ForEach-Object {
  Measure-Command {
    Find-Item -Path $Env:WINDIR -As FileSystemInfo -Recurse -AttributesToSkip 0 > $null
  } | Select-Object TotalMilliseconds
}
```

### Benchmark: Typed output (objects)

| Tool                               | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | **Average (ms)** | Items returned | Speedup vs built-in |
| ---------------------------------- | ---------: | ---------: | ---------: | ---------------: | -------------: | ------------------: |
| Built-in (typed objects)           |   14688,29 |   14246,31 |   13645,11 |    **14193,237** |         222994 |               1.00× |
| PSItems (recommended typed output) |    3883,52 |    3335,14 |    3469,71 |     **3562,790** |         222994 |           **3,99x** |

---

## 3) Content search (regex/text)

> NOT AVAILABLE YET

### Benchmark: Content search

| Tool                            | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | **Average (ms)** | Matches (single pass) | Speedup vs built-in |
| ------------------------------- | ---------: | ---------: | ---------: | ---------------: | --------------------: | ------------------: |
| Built-in (`Select-String` path) |          — |          — |          — |                — |                     — |               1.00× |
| PSItems (`psgrep` path)         |          — |          — |          — |                — |                     — |                   — |

---

## 4) Optional: depth-limited scan

Depth-limited enumeration to simulate a common “top-N levels” scan.

```pwsh
# Built-in (PowerShell 7+ supports -Depth)
1..3 | ForEach-Object {
  Measure-Command {
    Get-ChildItem $HOME -Depth 10 -Force -ErrorAction SilentlyContinue > $null
  } | Select-Object TotalMilliseconds
}

# PSItems
1..3 | ForEach-Object {
  Measure-Command {
    Find-Item $HOME -Name '*' -Depth 10 > $null
  } | Select-Object TotalMilliseconds
}
```

### Benchmark: Depth-limited (Depth = 10)

| Tool                                     | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | **Average (ms)** | Items returned | Speedup vs built-in |
| ---------------------------------------- | ---------: | ---------: | ---------: | ---------------: | -------------: | ------------------: |
| Built-in (PowerShell 7+ supports -Depth) |   11851,16 |   11169,29 |   12852,64 |    **11957,697** |         243687 |               1.00× |
| PSItems                                  |    2200,08 |    2212,61 |    1994,19 |     **2135,627** |         243687 |           **5,60x** |

---

## (Optional) Historical comparison: PSItems 0.3.6 vs 0.7.0

Run the same **names-only** benchmark under two PSItems versions.

> **Target path**: On Windows use `$Env:WINDIR`; on macOS/Linux use `$HOME`.

```pwsh
function Test-PSItemsVersion {
  param([string]$Path = $HOME)
  1..3 | ForEach-Object {
    (Measure-Command { psfind $Env:WINDIR -Name '*' -Recurse -AttributesToSkip 0 > $null }).TotalMilliseconds
  } | Measure-Object -Average | Select-Object -ExpandProperty Average
}

$versions = '0.3.6','0.7.0'
foreach ($v in $versions) {
  try {
    Get-Module PSItems | Remove-Module -Force -ErrorAction SilentlyContinue
    Install-Module PSItems -RequiredVersion $v -Scope CurrentUser -Force -ErrorAction Stop
    Import-Module PSItems -Force
    '{0} -> Average(ms): {1:n0}' -f $v, (Test-PSItemsVersion)
  } catch {
    Write-Warning "Failed to test PSItems $($v): $($_.Exception.Message)"
  }
}
```

### Benchmark: Historical (names only)

| PSItems version | Average (ms) |
| --------------- | -----------: |
| 0.3.6           |         5704 |
| 0.7.0           |         3370 |

---

## Overall summary (filled)

| Scenario                   | Built-in (avg ms) | PSItems (avg ms) | Speed-up (×) |
| -------------------------- | ----------------: | ---------------: | -----------: |
| Names only (strings)       |         17162.943 |         3224.997 |        5.32× |
| Typed output (objects)     |         14193.237 |         3562.790 |        3.98× |
| Content search             |                 — |                — |            — |
| Depth-limited (Depth = 10) |         11957.697 |         2135.627 |        5.60× |
| PSItems 0.3.6 vs 0.7.0     |              5704 |             3370 |        1,69× |

> **Tip**: To compute *Speed-up (×)*: divide the built-in average by the PSItems average, e.g. `25000 / 10000 = 2.5×`.
