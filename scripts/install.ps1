$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir

$OpenCodeConfigDir = Join-Path $HOME ".config\opencode"
$OpenCodeSkillsDir = Join-Path $OpenCodeConfigDir "skills"
$SourceSkillsDir = Join-Path $RepoDir "skills"
$SourceConfig = Join-Path $RepoDir "config\opencode.jsonc"
$TargetConfig = Join-Path $OpenCodeConfigDir "opencode.jsonc"

function Backup-File {
    param (
        [string]$File
    )

    $Backup = "$File.backup"

    if ((Test-Path $File -PathType Leaf) -and -not (Test-Path $Backup -PathType Leaf)) {
        Copy-Item -Path $File -Destination $Backup
        Write-Host "Backed up: $File -> $Backup"
    }
}


if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is required but was not found."
    exit 1
}

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm is required but was not found."
    exit 1
}

if (-not (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Error "OpenCode is required but was not found."
    exit 1
}


if (-not (Get-Command codegraph -ErrorAction SilentlyContinue)) {
    Write-Host "CodeGraph not found. Installing..."

    npm install -g @colbymchenry/codegraph@1.6.0

    if (-not (Get-Command codegraph -ErrorAction SilentlyContinue)) {
        Write-Error "CodeGraph installation completed, but the command is not available on PATH. Check your user npm PATH."
        exit 1
    }
}
else {
    $CodeGraphVersion = codegraph --version
    Write-Host "CodeGraph found: $CodeGraphVersion"
}


$ImpeccableSkill = Join-Path $HOME ".agents\skills\impeccable\SKILL.md"

if (-not (Test-Path $ImpeccableSkill -PathType Leaf)) {
    Write-Host "Impeccable not found. Installing..."

    npx skills add pbakaus/impeccable `
        --skill impeccable `
        --global `
        --agent opencode `
        --yes
}
else {
    Write-Host "Impeccable found."
}


New-Item -ItemType Directory -Force -Path $OpenCodeConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path $OpenCodeSkillsDir | Out-Null

$SourceAgents = Join-Path $RepoDir "AGENTS.md"
$TargetAgents = Join-Path $OpenCodeConfigDir "AGENTS.md"

if ((Test-Path $TargetAgents -PathType Leaf) -and
    ((Get-FileHash $SourceAgents).Hash -eq (Get-FileHash $TargetAgents).Hash)) {

    Write-Host "AGENTS.md already up to date."
}
else {
    Backup-File $TargetAgents
    Copy-Item -Path $SourceAgents -Destination $TargetAgents -Force
    Write-Host "Installed AGENTS.md."
}

Get-ChildItem -Path $SourceSkillsDir -Directory | ForEach-Object {
    $SkillName = $_.Name
    $SourceSkill = $_.FullName
    $TargetSkill = Join-Path $OpenCodeSkillsDir $SkillName

    $NeedsInstall = $true

    if (Test-Path $TargetSkill -PathType Container) {
        $SourceFiles = Get-ChildItem $SourceSkill -File -Recurse
        $TargetFiles = Get-ChildItem $TargetSkill -File -Recurse

        if ($SourceFiles.Count -eq $TargetFiles.Count) {
            $NeedsInstall = $false

            foreach ($SourceFile in $SourceFiles) {
                $RelativePath = $SourceFile.FullName.Substring($SourceSkill.Length).TrimStart('\', '/')
                $TargetFile = Join-Path $TargetSkill $RelativePath

                if (-not (Test-Path $TargetFile -PathType Leaf) -or
                    ((Get-FileHash $SourceFile.FullName).Hash -ne (Get-FileHash $TargetFile).Hash)) {
                    $NeedsInstall = $true
                    break
                }
            }
        }
    }

if (-not $NeedsInstall) {
    Write-Host "Skill already up to date: $SkillName"
}
else {
    if (Test-Path $TargetSkill -PathType Container) {
        $BackupSkill = "$TargetSkill.backup"

        if (-not (Test-Path $BackupSkill)) {
            Copy-Item -Path $TargetSkill -Destination $BackupSkill -Recurse
            Write-Host "Backed up skill: $SkillName"
        }

        Remove-Item -Path $TargetSkill -Recurse -Force
    }

    Copy-Item -Path $SourceSkill -Destination $TargetSkill -Recurse
    Write-Host "Installed skill: $SkillName"
}
}

if ((Test-Path $TargetConfig -PathType Leaf) -and
    ((Get-FileHash $SourceConfig).Hash -eq (Get-FileHash $TargetConfig).Hash)) {

    Write-Host "opencode.jsonc already up to date."
}
else {
    Backup-File $TargetConfig
    Copy-Item -Path $SourceConfig -Destination $TargetConfig -Force
    Write-Host "Installed opencode.jsonc."
}


Write-Host "OpenCode Setup"
Write-Host "Repository: $RepoDir"
Write-Host "OpenCode config: $OpenCodeConfigDir"
Write-Host "OpenCode skills: $OpenCodeSkillsDir"

