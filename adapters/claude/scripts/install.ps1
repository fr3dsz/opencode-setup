# Claude Code adapter installer (Windows PowerShell).
#
# Deploys repository content to live Claude Code configuration
# (%USERPROFILE%\.claude):
#   core/skills/*                         -> skills/*        (directory junctions)
#   adapters/claude/skills/*              -> skills/*        (directory junctions)
#   adapters/claude/agents/*.md           -> agents/*.md     (copies)
#   adapters/claude/rules/*.md            -> rules/*.md      (copies)
#   adapters/claude/config/CLAUDE.md      -> CLAUDE.md       (rendered)
#   adapters/claude/config/settings.json  -> settings.json   (rendered, seed only)
#
# Differences from install.sh, both forced by Windows:
# - Skills use directory junctions, which need neither administrator rights
#   nor Developer Mode, so repository edits take effect immediately.
# - Agents and rules are single files; file symlinks need elevation or
#   Developer Mode, so they are copied. After `git pull`, re-run --apply.
#
# Safety contract (mirrors install.sh):
# - --dry-run is the DEFAULT and changes nothing. --check validates and
#   exits non-zero on drift. --apply is the only mode that writes.
# - Every replaced entry is first moved to
#   setup-backups\yyyyMMdd-HHmmss\<relative path>. Nothing is deleted.
# - settings.json is only seeded when missing: Claude Code edits it at
#   runtime, so drift is reported, never overwritten.
# - Machine-local content (memory, projects, sessions, plugins, Impeccable,
#   ~/.claude.json and its MCP servers) is never touched.
# - CLAUDE_SETUP_DEST overrides ~/.claude for tests; it must be an absolute
#   path that is not the live ~/.claude.
#
# NOTE: not runtime-tested on the maintainer's Mac (no PowerShell there).
# First Windows run must be --check, then --dry-run, reviewed before --apply.
# Requires Windows PowerShell 5.1 or PowerShell 7+.
#
# Usage: .\adapters\claude\scripts\install.ps1 [--dry-run|--check|--apply]
# (-DryRun / -Check / -Apply are accepted too.)

$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    Write-Host "Error: $Message" -ForegroundColor Red
    exit 1
}

# No param() block: both --check and -Check arrive here as plain strings.
$Mode = "dry-run"
foreach ($Arg in $args) {
    switch -Regex ($Arg) {
        '^--?dry-?run$' { $Mode = "dry-run" }
        '^--?check$' { $Mode = "check" }
        '^--?apply$' { $Mode = "apply" }
        '^(--?help|-h|/\?)$' {
            Write-Host "Usage: install.ps1 [--dry-run] [--check] [--apply]"
            Write-Host "  --dry-run   Print the deployment plan; change nothing (default)."
            Write-Host "  --check     Read-only: exit 1 if live config differs from the repo."
            Write-Host "  --apply     Back up and replace drifted entries."
            exit 0
        }
        default { Fail "unknown argument: $Arg" }
    }
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# adapters/claude/scripts -> repository root is three levels up.
$RepoDir = (Resolve-Path (Join-Path $ScriptDir "..\..\..")).Path.TrimEnd('\')
$Adapter = Join-Path $RepoDir "adapters\claude"
foreach ($Marker in @("core\instructions\AGENTS.md", "core\skills", "adapters\claude\config\CLAUDE.md")) {
    if (-not (Test-Path (Join-Path $RepoDir $Marker))) { Fail "invalid repository root (missing $Marker): $RepoDir" }
}

$LiveDest = Join-Path $HOME ".claude"
$Dest = $LiveDest
$Override = [System.Environment]::GetEnvironmentVariable('CLAUDE_SETUP_DEST')
if ($null -ne $Override) {
    if (-not [System.IO.Path]::IsPathRooted($Override)) { Fail "CLAUDE_SETUP_DEST must be an absolute path." }
    if ($Override.TrimEnd('\', '/') -ieq ([System.IO.Path]::GetPathRoot($Override)).TrimEnd('\', '/')) { Fail "CLAUDE_SETUP_DEST must not be a filesystem root." }
    New-Item -ItemType Directory -Force -Path $Override | Out-Null
    $Dest = (Resolve-Path $Override).Path.TrimEnd('\')
    if ($Dest -ieq $LiveDest.TrimEnd('\')) { Fail "CLAUDE_SETUP_DEST must not be the live ~/.claude." }
    Write-Host "SANDBOX MODE: $Dest"
}

if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    Write-Host "Note: bash not on PATH. Claude Code on Windows needs Git for Windows (Git Bash); the opencode-delegate script runs there."
}
if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "Note: opencode not on PATH; the opencode-delegate skill will report errors until it is installed."
}

$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$script:Drift = $false

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    # Set-Content -Encoding utf8NoBOM does not exist on Windows PowerShell 5.1.
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding $false))
}

function Normalize([string]$Path) {
    # Junction targets can come back with a \\?\ or \??\ prefix.
    return ($Path -replace '^(\\\\\?\\|\\\?\?\\)', '').TrimEnd('\')
}

function Backup([string]$Path) {
    $Relative = $Path.Substring($Dest.Length).TrimStart('\')
    $Target = Join-Path (Join-Path (Join-Path $Dest "setup-backups") $Stamp) $Relative
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
    Move-Item -LiteralPath $Path -Destination $Target
    Write-Host "  backup  $Target"
}

# Link-Dir <source> <target>: target must be a junction to source.
function Link-Dir([string]$Src, [string]$Dst) {
    $Item = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
    if ($Item -and $Item.LinkType -eq "Junction" -and (Normalize (@($Item.Target)[0])) -ieq (Normalize $Src)) { return }
    $script:Drift = $true
    if ($Item) { Write-Host "replace  $Dst -> $Src" } else { Write-Host "link     $Dst -> $Src" }
    if ($Mode -ne "apply") { return }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dst) | Out-Null
    if ($Item) { Backup $Dst }
    New-Item -ItemType Junction -Path $Dst -Target $Src | Out-Null
}

# Write-Managed <content> <target> [seed]: target must hold exactly content.
function Write-Managed([string]$Content, [string]$Dst, [string]$Seed = "") {
    $Item = Get-Item -LiteralPath $Dst -Force -ErrorAction SilentlyContinue
    if ($Item -and -not $Item.PSIsContainer -and -not $Item.LinkType -and
        [System.IO.File]::ReadAllText($Dst) -ceq $Content) { return }
    if ($Seed -and $Item) {
        Write-Host "differs  $Dst (runtime-managed; not replaced, compare with rendered $Seed)"
        return
    }
    $script:Drift = $true
    if ($Item) { Write-Host "replace  $Dst" } else { Write-Host "write    $Dst" }
    if ($Mode -ne "apply") { return }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Dst) | Out-Null
    if ($Item) { Backup $Dst }
    Write-Utf8NoBom $Dst $Content
}

# Placeholders render with forward slashes: valid in JSON strings without
# escaping, and accepted by Claude Code @imports and Git Bash paths.
function Render([string]$Path) {
    $Text = [System.IO.File]::ReadAllText($Path)
    $Text = $Text.Replace("@@REPO_DIR@@", ($RepoDir -replace '\\', '/')).Replace("@@HOME@@", ($HOME -replace '\\', '/'))
    if ($Text.Contains("@@")) { Fail "unrendered placeholder left in $Path" }
    return $Text
}

Write-Host "Mode: $Mode   Repo: $RepoDir   Dest: $Dest"

$SkillDirs = @(Get-ChildItem -Directory (Join-Path $RepoDir "core\skills")) + @(Get-ChildItem -Directory (Join-Path $Adapter "skills"))
foreach ($D in $SkillDirs) { Link-Dir $D.FullName (Join-Path $Dest "skills\$($D.Name)") }
foreach ($Kind in @("agents", "rules")) {
    foreach ($F in Get-ChildItem -File -Filter *.md (Join-Path $Adapter $Kind)) {
        Write-Managed ([System.IO.File]::ReadAllText($F.FullName)) (Join-Path $Dest "$Kind\$($F.Name)")
    }
}

$ClaudeMd = Render (Join-Path $Adapter "config\CLAUDE.md")
$Settings = Render (Join-Path $Adapter "config\settings.json")
try { $Settings | ConvertFrom-Json | Out-Null } catch { Fail "rendered settings.json is not valid JSON" }
Write-Managed $ClaudeMd (Join-Path $Dest "CLAUDE.md")
Write-Managed $Settings (Join-Path $Dest "settings.json") "adapters/claude/config/settings.json"

if (-not $script:Drift) { Write-Host "Up to date."; exit 0 }
switch ($Mode) {
    "check" { Write-Host "Drift found; run --apply to deploy."; exit 1 }
    "dry-run" { Write-Host "Dry run: nothing changed. Run --apply to deploy." }
    "apply" { Write-Host "Applied. Run --check to confirm." }
}
