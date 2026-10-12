# OpenCode adapter installer (Windows PowerShell).
#
# Deploys repository content to live OpenCode configuration:
#   core/instructions/AGENTS.md  -> $HOME/.config/opencode/AGENTS.md
#   core/skills/*                -> $HOME/.config/opencode/skills/*
#   adapters/opencode/config/opencode.jsonc (template, placeholders rendered)
#                                -> $HOME/.config/opencode/opencode.jsonc
#
# Safety contract (mirrors install.sh):
# - --dry-run is the DEFAULT. It prints the full deployment plan and changes
#   nothing. --check performs read-only validation and exits before any
#   write. --apply is the ONLY mode permitted to write live configuration.
# - Failure-before-write: every input is resolved and validated, and every
#   rendered output is verified, BEFORE the first write. Any failure aborts
#   with a clear message before anything is written.
# - Timestamped backups (<name>.bak-yyyyMMdd-HHmmss) precede every
#   replacement. Deployment is ordered per file, NOT atomic across files.
# - A working live configuration is never overwritten without explicit
#   deployment approval (an explicit --apply invocation by the operator).
# - No automatic installation of Node, GitNexus, or any package. No
#   repository indexing. Impeccable is an optional existing dependency
#   documented in README.md; this installer does not install it.
#
# NOTE: PowerShell cannot be runtime-tested on the maintainer's Mac (no
# pwsh available there). Behavior was mirrored from install.sh by
# construction and review only; first Windows execution must be --check
# followed by --dry-run, and its output reviewed before any --apply.
#
# Usage: .\install.ps1 [--dry-run] [--check] [--apply]

param(
    [switch]$DryRun,
    [switch]$Check,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

$RequiredNodeVersion = "v22.23.2"
$RequiredGitNexusVersion = "1.6.12"

function Fail([string]$Message) {
    Write-Error $Message
    exit 1
}

$Mode = "dry-run"
$ModeFlags = @($DryRun.IsPresent, $Check.IsPresent, $Apply.IsPresent) | Where-Object { $_ }
if ($ModeFlags.Count -gt 1) { Fail "Pass only one of --dry-run, --check, --apply." }
if ($Check.IsPresent) { $Mode = "check" }
if ($Apply.IsPresent) { $Mode = "apply" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
# adapters/opencode/scripts -> repository root is three levels up.
$RepoDir = (Resolve-Path (Join-Path $ScriptDir "../../..")).Path

# Verify the resolved root before using it (marker files, not machine paths).
foreach ($Marker in @("core/instructions/AGENTS.md", "core/skills", "adapters/opencode/config/opencode.jsonc")) {
    if (-not (Test-Path (Join-Path $RepoDir $Marker))) {
        Fail "Resolved repository root is invalid (missing $Marker): $RepoDir"
    }
}

$LiveDefaultDir = Join-Path $HOME ".config\opencode"
$OverrideRaw = [System.Environment]::GetEnvironmentVariable('OPENCODE_SETUP_DEST')
if ($null -ne $OverrideRaw) {
    # Test-only destination override. The production default is unchanged
    # when OPENCODE_SETUP_DEST is unset. Every managed write and backup below
    # derives from $OpenCodeConfigDir, so validation here covers all of them.
    if ([string]::IsNullOrEmpty($OverrideRaw)) { Fail "OPENCODE_SETUP_DEST must not be empty." }
    if (-not [System.IO.Path]::IsPathRooted($OverrideRaw)) { Fail "OPENCODE_SETUP_DEST must be an absolute path: $OverrideRaw" }
    $OverrideRoot = [System.IO.Path]::GetPathRoot($OverrideRaw)
    if ($OverrideRaw.TrimEnd('\', '/') -ieq $OverrideRoot.TrimEnd('\', '/')) { Fail "OPENCODE_SETUP_DEST must not be a filesystem root." }
    New-Item -ItemType Directory -Force -Path $OverrideRaw | Out-Null
    # Canonicalize (resolving symlinks/junctions) before any containment check.
    $SandboxDir = (Resolve-Path $OverrideRaw).Path.TrimEnd('\')
    if (Test-Path $LiveDefaultDir -PathType Container) {
        $LiveCanon = (Resolve-Path $LiveDefaultDir).Path.TrimEnd('\')
    } else {
        $LiveCanon = $LiveDefaultDir.TrimEnd('\')
    }
    $SandboxPrefix = "$SandboxDir\"
    $LivePrefix = "$LiveCanon\"
    if ($SandboxDir -ieq $LiveCanon) { Fail "OPENCODE_SETUP_DEST resolves to the live configuration; refusing unsafe destination." }
    if ($LiveCanon.StartsWith($SandboxPrefix, [System.StringComparison]::OrdinalIgnoreCase)) { Fail "OPENCODE_SETUP_DEST is an ancestor of the live configuration; refusing unsafe destination." }
    if ($SandboxDir.StartsWith($LivePrefix, [System.StringComparison]::OrdinalIgnoreCase)) { Fail "OPENCODE_SETUP_DEST is inside the live configuration; refusing unsafe destination." }
    $OpenCodeConfigDir = $SandboxDir
    Write-Host "SANDBOX MODE: all writes redirected to $OpenCodeConfigDir"
} else {
    $OpenCodeConfigDir = $LiveDefaultDir
}
$OpenCodeSkillsDir = Join-Path $OpenCodeConfigDir "skills"
$SourceSkillsDir = Join-Path $RepoDir "core/skills"
$SourceAgents = Join-Path $RepoDir "core/instructions/AGENTS.md"
$SourceTemplate = Join-Path $RepoDir "adapters/opencode/config/opencode.jsonc"
$TargetAgents = Join-Path $OpenCodeConfigDir "AGENTS.md"
$TargetConfig = Join-Path $OpenCodeConfigDir "opencode.jsonc"

function Find-Node {
    # Candidate Node locations across common Windows layouts ($HOME and
    # well-known system paths only; never personal absolute paths). Every
    # candidate is exact-version validated; PATH is a gated fallback, never
    # an assumed default. NOTE (B3): layout coverage is review-only and has
    # not been runtime-tested; first Windows run must be --check.
    $Candidates = @(
        (Join-Path $HOME ".nvm/versions/node/$RequiredNodeVersion/bin/node.exe"),
        (Join-Path $HOME ".nvm/versions/node/$RequiredNodeVersion/node.exe")
    )
    if ($env:APPDATA) { $Candidates += Join-Path $env:APPDATA "nvm/$RequiredNodeVersion/node.exe" }
    $Candidates += "C:\Program Files\nodejs\node.exe"
    foreach ($Candidate in $Candidates) {
        if (Test-Path $Candidate -PathType Leaf) {
            $V = (& $Candidate --version 2>$null)
            if ($V -eq $RequiredNodeVersion) { return $Candidate }
            Write-Host "Warning: candidate node $Candidate reports '$V', required '$RequiredNodeVersion'."
        }
    }
    $PathNode = Get-Command node -ErrorAction SilentlyContinue
    if ($PathNode) {
        $V = (& $PathNode.Source --version 2>$null)
        if ($V -eq $RequiredNodeVersion) { return $PathNode.Source }
        Write-Host "Warning: PATH node reports '$V', required '$RequiredNodeVersion'; ignoring PATH node."
    }
    return $null
}

function Find-GitNexusCli([string]$NodeBin) {
    # Candidate CLI locations for each Node layout (flat and bin/ trees,
    # plus the machine-global npm tree). The caller exact-version-validates
    # the winner; discovery order is preference only. NOTE (B3): review-only,
    # not runtime-tested; the PATH fallback below stays version-gated.
    $NodeParent = Split-Path -Parent $NodeBin
    $NodeGrandParent = Split-Path -Parent $NodeParent
    $Candidates = @()
    foreach ($Base in @($NodeParent, $NodeGrandParent)) {
        $Candidates += Join-Path $Base "lib/node_modules/gitnexus/dist/cli/index.js"
        $Candidates += Join-Path $Base "node_modules/gitnexus/dist/cli/index.js"
    }
    if ($env:APPDATA) { $Candidates += Join-Path $env:APPDATA "npm/node_modules/gitnexus/dist/cli/index.js" }
    foreach ($Candidate in $Candidates) {
        if (Test-Path $Candidate -PathType Leaf) { return $Candidate }
    }
    $PathCli = Get-Command gitnexus -ErrorAction SilentlyContinue
    if ($PathCli) {
        Write-Host "Warning: no GitNexus CLI in the resolved Node tree; falling back to PATH gitnexus (version still verified)."
        return $PathCli.Source
    }
    return $null
}

function Skills-Equal([string]$Source, [string]$Target) {
    if (-not (Test-Path $Target -PathType Container)) { return $false }
    # Backup-pattern files are live-operator artifacts: excluded from the
    # payload comparison on both sides (see install.sh skills_equal).
    $BackupPatterns = @('*.backup', '*.bak-*', '*.pre-gitnexus-*')
    $SourceFiles = Get-ChildItem $Source -File -Recurse | Where-Object {
        $N = $_.Name; -not ($BackupPatterns | Where-Object { $N -like $_ })
    }
    $TargetFiles = Get-ChildItem $Target -File -Recurse | Where-Object {
        $N = $_.Name; -not ($BackupPatterns | Where-Object { $N -like $_ })
    }
    if ($SourceFiles.Count -ne $TargetFiles.Count) { return $false }
    foreach ($SourceFile in $SourceFiles) {
        $RelativePath = $SourceFile.FullName.Substring($Source.Length).TrimStart('\', '/')
        $TargetFile = Join-Path $Target $RelativePath
        if (-not (Test-Path $TargetFile -PathType Leaf)) { return $false }
        if ((Get-FileHash $SourceFile.FullName).Hash -ne (Get-FileHash $TargetFile).Hash) { return $false }
    }
    return $true
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    # Deterministic UTF-8 without BOM on every supported PowerShell version.
    # Set-Content -Encoding utf8NoBOM does not exist on Windows PowerShell
    # 5.1, so write via .NET directly (supported since .NET Framework 2.0).
    # Minimum supported version: Windows PowerShell 5.1 or PowerShell 7+.
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding $false))
}

Write-Host "Mode: $Mode"
Write-Host "Repository: $RepoDir"

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Fail "OpenCode is required but was not found on PATH."
}
Write-Host "OpenCode found."

$NodeBin = Find-Node
if (-not $NodeBin) { Fail "No suitable Node found (required $RequiredNodeVersion). Install it and re-run with --check." }
Write-Host "Node: $NodeBin ($(& $NodeBin --version))"

$GitNexusCli = Find-GitNexusCli $NodeBin
if (-not $GitNexusCli) { Fail "GitNexus CLI not found for the resolved Node tree." }
$GitNexusVersion = (& $NodeBin $GitNexusCli --version 2>$null)
if ($GitNexusVersion -ne $RequiredGitNexusVersion) {
    Fail "GitNexus reports '$GitNexusVersion', required '$RequiredGitNexusVersion'. Will not proceed."
}
Write-Host "GitNexus: $GitNexusCli ($GitNexusVersion)"

# --- Template validation and rendering (installer-owned @@PLACEHOLDER@@ syntax) ---

$TemplateText = Get-Content $SourceTemplate -Raw -Encoding UTF8
if ($TemplateText -notmatch '@@GITNEXUS_NODE@@') { Fail "Template missing @@GITNEXUS_NODE@@ placeholder." }
if ($TemplateText -notmatch '@@GITNEXUS_CLI@@') { Fail "Template missing @@GITNEXUS_CLI@@ placeholder." }

$Rendered = $TemplateText.Replace('@@GITNEXUS_NODE@@', $NodeBin).Replace('@@GITNEXUS_CLI@@', $GitNexusCli)
# Template documentation uses full-line comments only; strip them so the
# deployed live config stays minimal JSONC.
$Rendered = (($Rendered -split "`n") | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
if (-not $Rendered.EndsWith("`n")) { $Rendered += "`n" }
if ($Rendered -match '@@[A-Z_]+@@') {
    Fail "Unresolved placeholders remain in rendered config; refusing to deploy."
}
if ($Rendered -match '(?m)^\s*//') {
    Fail "Template documentation comments leaked into rendered config; refusing to deploy."
}
if ($Rendered -notmatch '"gitnexus"') { Fail "Rendered config missing gitnexus entry; refusing to deploy." }
if ([string]::IsNullOrWhiteSpace($Rendered)) { Fail "Rendered config is empty; refusing to deploy." }
Write-Host "Template rendered and verified (placeholders resolved, gitnexus entry present)."

# --- Deployment plan (computed without writing) ---

$PlanAgents = "up-to-date"
if (-not ((Test-Path $TargetAgents -PathType Leaf) -and
    ((Get-FileHash $SourceAgents).Hash -eq (Get-FileHash $TargetAgents).Hash))) {
    $PlanAgents = "will-write"
}
$PlanConfig = "up-to-date"
if (-not ((Test-Path $TargetConfig -PathType Leaf))) {
    $PlanConfig = "will-write"
} else {
    $RenderedTmp = Join-Path ([System.IO.Path]::GetTempPath()) ("opencode.jsonc.plan." + [System.IO.Path]::GetRandomFileName() + ".tmp")
    try {
        Write-Utf8NoBom $RenderedTmp $Rendered
        if ((Get-FileHash $RenderedTmp).Hash -ne (Get-FileHash $TargetConfig).Hash) { $PlanConfig = "will-write" }
    } finally {
        if (Test-Path $RenderedTmp) { Remove-Item $RenderedTmp -Force }
    }
}

Write-Host "Plan:"
Write-Host "  AGENTS.md ($TargetAgents): $PlanAgents"
Write-Host "  opencode.jsonc ($TargetConfig): $PlanConfig [rendered, absolute-path stdio launch]"
$SkillPlans = @{}
Get-ChildItem -Path $SourceSkillsDir -Directory | ForEach-Object {
    $SkillName = $_.Name
    if (-not (Test-Path (Join-Path $_.FullName "SKILL.md") -PathType Leaf)) {
        Fail "Source skill missing SKILL.md: $SkillName"
    }
    $TargetSkill = Join-Path $OpenCodeSkillsDir $SkillName
    if (Skills-Equal $_.FullName $TargetSkill) {
        $Extras = Get-ChildItem $TargetSkill -File -Recurse -Include '*.backup','*.bak-*','*.pre-gitnexus-*' | Select-Object -First 5
        if ($Extras) {
            Write-Host "  skill ${SkillName}: up-to-date (live-only extras preserved, not deployed)"
        } else {
            Write-Host "  skill ${SkillName}: up-to-date"
        }
        $SkillPlans[$SkillName] = "up-to-date"
    } else {
        Write-Host "  skill ${SkillName}: will-write"
        $SkillPlans[$SkillName] = "will-write"
    }
}

if ($Mode -eq "check") {
    Write-Host "Check passed: all inputs and rendered outputs valid. No changes made."
    exit 0
}
if ($Mode -eq "dry-run") {
    Write-Host "Dry run: no changes made. Re-run with --apply to deploy with timestamped backups."
    exit 0
}

# --- --apply: ordered, per-file backup + replace (NOT atomic across files) ---

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
# B2: collision-safe backup names. An existing backup is never overwritten;
# a numeric suffix is appended until the name is free.
function Get-UniqueBackupPath([string]$Base) {
    $Candidate = "$Base.bak-$Timestamp"
    $i = 1
    while (Test-Path $Candidate) {
        $Candidate = "$Base.bak-$Timestamp-$i"
        $i++
    }
    return $Candidate
}
function Backup-File([string]$File) {
    if (Test-Path $File) {
        $Backup = Get-UniqueBackupPath $File
        Copy-Item -Path $File -Destination $Backup
        if (-not (Test-Path $Backup)) { Fail "Backup failed for $File; aborting before further writes." }
        Write-Host "Backed up: $File -> $Backup"
    }
}

New-Item -ItemType Directory -Force -Path $OpenCodeConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $OpenCodeSkillsDir | Out-Null

if ($PlanAgents -eq "will-write") {
    Backup-File $TargetAgents
    Copy-Item -Path $SourceAgents -Destination $TargetAgents -Force
    Write-Host "Installed AGENTS.md."
} else {
    Write-Host "AGENTS.md already up to date."
}

Get-ChildItem -Path $SourceSkillsDir -Directory | ForEach-Object {
    $SkillName = $_.Name
    if ($SkillPlans[$SkillName] -eq "up-to-date") {
        Write-Host "Skill already up to date: $SkillName"
        return
    }
    $TargetSkill = Join-Path $OpenCodeSkillsDir $SkillName
    if (Test-Path $TargetSkill -PathType Container) {
        $BackupSkill = Get-UniqueBackupPath $TargetSkill
        Copy-Item -Path $TargetSkill -Destination $BackupSkill -Recurse
        Write-Host "Backed up skill: $SkillName -> $BackupSkill"
        Remove-Item -Path $TargetSkill -Recurse -Force
    }
    Copy-Item -Path $_.FullName -Destination $TargetSkill -Recurse -Force
    Write-Host "Installed skill: $SkillName"
}

if ($PlanConfig -eq "will-write") {
    $Staging = Join-Path $OpenCodeConfigDir ("opencode.jsonc.tmp.$Timestamp." + [System.IO.Path]::GetRandomFileName())
    Write-Utf8NoBom $Staging $Rendered
    Backup-File $TargetConfig
    try {
        Move-Item -Path $Staging -Destination $TargetConfig -Force
    } catch {
        if (Test-Path $Staging) { Remove-Item $Staging -Force }
        Fail "Failed activating rendered config: $($_.Exception.Message)"
    }
    Write-Host "Installed opencode.jsonc (rendered)."
} else {
    Write-Host "opencode.jsonc already up to date."
}

Write-Host "Deployment complete (ordered per-file replacement with backups; verify with --check)."
Write-Host "Repository: $RepoDir"
Write-Host "OpenCode config: $OpenCodeConfigDir"
Write-Host "OpenCode skills: $OpenCodeSkillsDir"
