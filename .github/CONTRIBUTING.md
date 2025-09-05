# Contributing to PSItems

Thanks for helping improve PSItems! The goal is simple, ergonomic, **fast** filesystem utilities.
PRs that improve performance, reliability, cross‑platform behavior, or docs are very welcome.

- File issues: <https://github.com/eizedev/PSItems/issues>
- Discuss ideas in issues before large changes.
- Keep PRs focused. Add tests and docs when relevant.

---

## Local development quickstart

```pwsh
# 1) Install / update build dependencies (PSDepend, Pester, PSScriptAnalyzer, PowerShellBuild, etc.)
./build.ps1 -Bootstrap

# 2) Lint & test everything
./build.ps1 -Task Analyze,Test -Verbose
```

This project uses **PowerShellBuild** under the hood. The default tasks will stage the module into `Output/`, generate help from Markdown, run **PSScriptAnalyzer**, and execute **Pester** tests.

---

## Sync & validate docs with platyPS

PSItems keeps its user help in Markdown under `docs/en-US` and generates external help (MAML) for runtime. Use platyPS to keep the two in sync.

### A) Quick sync (update Markdown from live module metadata)

If you changed parameters/types/examples, update the Markdown based on the module:

pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; Update-MarkdownHelpModule -Path 'docs/en-US' -Module 'PSItems'"

> This **modifies** files in `docs/en-US`. Review and commit the changes.

### B) Structural validation (catch malformed Markdown before CI)

Make sure Markdown can be converted into external help (fails on missing headings, unclosed code fences, etc.):

pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; New-ExternalHelp -Path 'docs/en-US' -OutputPath 'docs/en-US' -Force -ErrorAction Stop"

- Succeeds silently if docs are structurally valid.
- Fails with a useful error if something is off (“Expect Heading” usually means a missing `###` subheading or an unclosed code block).

### (Optional) CI guard to enforce up-to-date Markdown

Add a lightweight check that fails if `Update-MarkdownHelpModule` would change files:

pwsh -NoProfile -Command "
  Install-Module platyPS -Scope CurrentUser -Force;
  Update-MarkdownHelpModule -Path 'docs/en-US' -Module 'PSItems';
  if (git -c core.safecrlf=false status --porcelain docs/en-US) {
    Write-Error 'Markdown help is out of date. Run Update-MarkdownHelpModule and commit.' -ErrorAction Stop
  }
"

---

## Release & Publish (via GitHub Actions)

This project is published **only** through the GitHub Actions pipeline defined in `.github/workflows/CI.yml`.
Publishing is triggered by **annotated tags** that start with `v` (e.g., `v0.7.0`). The publish job runs on Windows and pushes to the PowerShell Gallery using the repo secret `PSGALLERY_API_KEY`.

> **Prerequisite (one-time):** Add `PSGALLERY_API_KEY` in GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**.

### Step-by-step

1) **Sync version and changelog**
   - Edit `PSItems/PSItems.psd1` → set `ModuleVersion = 'X.Y.Z'`.
   - Edit `CHANGELOG.md`:
     - Move items from `[Unreleased]` into a new `## [X.Y.Z] - YYYY-MM-DD` section.
     - Update the compare links at the bottom (e.g., `[Unreleased]` and `[X.Y.Z]`).

2) **(Recommended) Rebuild external help**

```pwsh
pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; New-ExternalHelp -Path 'docs/en-US' -OutputPath 'out/en-US' -Force -ErrorAction Stop"
```

3) **Verify locally**

```pwsh
pwsh -NoProfile -Command "./build.ps1 -Bootstrap; ./build.ps1 -Task Analyze,Test -Verbose"
```

4) **Commit & tag**

```pwsh
git add -A
git commit -m "chore(release): vX.Y.Z"
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

5) **Push (triggers CI + publish)**

```pwsh
git push origin HEAD
git push origin vX.Y.Z
```

6) **Watch the pipeline**
- CI runs on Windows, macOS, and Linux (**Analyze + Test**).
- **Publish** runs on Windows only for tags that start with `v` and publishes to the PowerShell Gallery using `PSGALLERY_API_KEY`.

7) **Sanity check after publish**

```pwsh
pwsh -NoProfile -Command "Find-Module PSItems -Repository PSGallery | Select-Object -First 1 Name,Version"
# Optionally install the fresh version to verify:
# pwsh -NoProfile -Command "Install-Module PSItems -Scope CurrentUser -Force; (Get-Module PSItems -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version"
```

### Example: releasing **v0.7.0**

```pwsh
# 1) Update:
# - PSItems/PSItems.psd1 → ModuleVersion = '0.7.0'
# - CHANGELOG.md → new "## [0.7.0] - 2025-09-05" section + updated compare links

# 2) Rebuild help (optional but recommended)
pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; New-ExternalHelp -Path 'docs/en-US' -OutputPath 'out/en-US' -Force -ErrorAction Stop"

# 3) Verify
pwsh -NoProfile -Command "./build.ps1 -Bootstrap; ./build.ps1 -Task Analyze,Test -Verbose"

# 4) Commit & tag
git add -A
git commit -m "chore(release): v0.7.0"
git tag -a v0.7.0 -m "Release v0.7.0"

# 5) Push (triggers CI + publish)
git push origin HEAD
git push origin v0.7.0
```

**Notes**
- The tag must be `vX.Y.Z` to trigger the publish job.
- The pipeline uploads the Pester console log and (optionally) JUnit XML test results as artifacts.
- If the changelog version and `ModuleVersion` differ, tests will fail by design.

## Developing with the Dev Container

This project ships a ready‑to‑use **Dev Container** for a consistent, cross‑platform setup.

### Prerequisites
- **Docker** (Docker Desktop on Windows/macOS; Docker Engine on Linux)
- **Visual Studio Code**
- **Dev Containers** extension (`ms-vscode-remote.remote-containers`)
- (Windows) Recommended: **WSL2**

### Open in the Dev Container

1. Open the repository in VS Code.
2. Press `F1` → **Dev Containers: Reopen in Container**.
3. VS Code builds the image from `Dockerfile` and creates the container using `.devcontainer/devcontainer.json`.

> The first run can take a few minutes (image build + dependency restore).

### What the container does
- Uses the official `mcr.microsoft.com/powershell` base image (pwsh 7+).
- Installs recommended VS Code extensions (PowerShell, markdownlint).
- Sets terminal shell to **pwsh**.
- Runs post‑create bootstrap: `./build.ps1 -Task Init -Bootstrap` (install build/test deps).

### Common tasks inside the container
```pwsh
# Run code style / static analysis
./build.ps1 -Task Analyze -Verbose

# Run tests (Pester via PowerShellBuild)
./build.ps1 -Task Test -Verbose

# Build & validate help (platyPS)
pwsh -NoProfile -Command "Install-Module platyPS -Scope CurrentUser -Force; update-MarkdownHelpModule -Path 'docs/en-US' -Module 'PSItems'"
pwsh -NoProfile -Command "New-ExternalHelp -Path 'docs/en-US' -OutputPath 'docs/en-US' -Force"
```

### Update or reset the container
- **Rebuild** after changing `Dockerfile`/`devcontainer.json` → `F1` → **Dev Containers: Rebuild Container**.
- **Clean rebuild** (no cache) → `F1` → **Dev Containers: Rebuild and Reopen in Container**.

### Tips
- Windows + WSL2: store the repo under your Linux home (`/home/<you>/repo`) for best I/O performance.
- If you need environment secrets locally, add them to **.devcontainer/devcontainer.json** under `containerEnv` (do **not** commit real secrets).

### Troubleshooting
- **Docker not running** → start Docker Desktop / service, then retry **Reopen in Container**.
- **Proxy / TLS errors** when restoring modules → configure Docker/OS proxy and retry.
- **Stale tools** after edits → use **Rebuild Container**.
- **Module cache is slow** → this setup uses user‑scoped modules inside the container; caches are isolated per container.

---

**Related files**
- `.devcontainer/devcontainer.json` — Dev Container definition (settings, extensions, post‑create).
- `Dockerfile` — base image and OS packages for the environment.

