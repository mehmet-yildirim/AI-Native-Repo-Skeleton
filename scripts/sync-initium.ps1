<#
.SYNOPSIS
    Apply skeleton updates to your derived project (Windows PowerShell)

.DESCRIPTION
    Fetches the upstream AI-Native skeleton, classifies every changed file
    by ownership (skeleton_owned / merge_required / project_owned), auto-applies
    safe files, and prompts for manual review on files you have customised.

.PARAMETER Auto
    Apply all skeleton_owned files without interactive prompting.

.PARAMETER DryRun
    Show what would change; apply nothing.

.PARAMETER Check
    Report whether a skeleton update is available, then exit.

.EXAMPLE
    .\scripts\sync-initium.ps1
    .\scripts\sync-initium.ps1 -Auto
    .\scripts\sync-initium.ps1 -DryRun
    .\scripts\sync-initium.ps1 -Check
#>

[CmdletBinding()]
param(
    [switch]$Auto,
    [switch]$DryRun,
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function Write-Info    { param($Msg) Write-Host "[INFO]  $Msg" -ForegroundColor Cyan }
function Write-OK      { param($Msg) Write-Host "[OK]    $Msg" -ForegroundColor Green }
function Write-Warn    { param($Msg) Write-Host "[WARN]  $Msg" -ForegroundColor Yellow }
function Write-Err     { param($Msg) Write-Host "[ERROR] $Msg" -ForegroundColor Red; exit 1 }
function Write-Heading { param($Msg) Write-Host "`n$Msg" -ForegroundColor White; Write-Host ('─' * 60) }

function Confirm-Yes {
    param([string]$Prompt, [bool]$DefaultYes = $false)
    $hint = if ($DefaultYes) { '[Y/n]' } else { '[y/N]' }
    $answer = Read-Host "$Prompt $hint"
    if ($DefaultYes) { return ($answer -notmatch '^[Nn]') }
    return ($answer -match '^[Yy]')
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
Write-Heading 'Pre-flight Checks'

$SkeletonJson = 'initium.json'
$SkeletonRemote = 'skeleton'

if (-not (Test-Path $SkeletonJson)) {
    Write-Err "initium.json not found. Is this a skeleton-based project?"
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "git is required but not found in PATH."
}

# Check working tree cleanliness
$gitStatus = git status --porcelain 2>&1
if ($gitStatus) {
    Write-Warn 'Your working tree has uncommitted changes.'
    Write-Warn 'Stash or commit them before syncing:  git stash'
    if (-not $DryRun -and -not $Check) {
        if (-not (Confirm-Yes 'Continue anyway?')) { exit 1 }
    }
}

Write-OK "Working directory: $(Get-Location)"

# ---------------------------------------------------------------------------
# Read initium.json (no jq needed — PowerShell has native JSON support)
# ---------------------------------------------------------------------------
$skeleton = Get-Content $SkeletonJson -Raw | ConvertFrom-Json

$SkeletonRepo    = $skeleton.skeleton.repository
$CurrentCommit   = $skeleton.skeleton.commit
$CurrentSynced   = $skeleton.skeleton.syncedAt
$SkeletonOwned   = $skeleton.fileOwnership.skeleton_owned
$ProjectOwned    = $skeleton.fileOwnership.project_owned
$MergeRequired   = $skeleton.fileOwnership.merge_required

Write-Info "Skeleton repo  : $SkeletonRepo"
Write-Info "Last synced at : $CurrentSynced"
Write-Info "Last sync SHA  : $CurrentCommit"

# ---------------------------------------------------------------------------
# Set up skeleton remote
# ---------------------------------------------------------------------------
Write-Heading 'Connecting to Skeleton Repository'

$existingRemote = git remote get-url $SkeletonRemote 2>$null
if (-not $existingRemote) {
    Write-Info "Adding skeleton remote: $SkeletonRepo"
    git remote add $SkeletonRemote $SkeletonRepo
} elseif ($existingRemote.Trim() -ne $SkeletonRepo) {
    Write-Warn "Remote '$SkeletonRemote' points to: $($existingRemote.Trim())"
    Write-Warn "Expected: $SkeletonRepo"
    if (Confirm-Yes 'Update remote URL?') {
        git remote set-url $SkeletonRemote $SkeletonRepo
    }
}

Write-Info 'Fetching skeleton...'
git fetch $SkeletonRemote --quiet
$LatestCommit = (git rev-parse "$SkeletonRemote/main").Trim()
$LatestShort  = (git rev-parse --short "$SkeletonRemote/main").Trim()

Write-OK "Latest skeleton commit: $LatestShort"

# ---------------------------------------------------------------------------
# Version comparison
# ---------------------------------------------------------------------------
if ($CurrentCommit -eq $LatestCommit) {
    Write-OK 'Already up to date — skeleton commit matches your last sync.'
    if ($Check) { exit 0 }
    Write-Host ''
    if (-not (Confirm-Yes 'Force re-sync anyway?')) {
        Write-Info 'Nothing to do.'; exit 0
    }
} else {
    Write-Info 'Updates available since your last sync.'
}

if ($Check) {
    Write-Host ''
    Write-Host "Run '.\scripts\sync-initium.ps1' to apply updates."
    exit 0
}

# ---------------------------------------------------------------------------
# Show changelog
# ---------------------------------------------------------------------------
Write-Heading 'What Changed in the Skeleton'
Write-Host ''
Write-Host 'Commits since your last sync:'
try {
    git log --oneline "${CurrentCommit}..${SkeletonRemote}/main" 2>$null
} catch {
    git log --oneline "$SkeletonRemote/main" --max-count=20
}
Write-Host ''
Write-Info "Full migration notes: $SkeletonRepo/blob/main/INITIUM-UPDATES.md"
Write-Host ''

if (-not $Auto) {
    if (-not (Confirm-Yes 'Continue with sync?' -DefaultYes $true)) {
        Write-Info 'Sync cancelled.'; exit 0
    }
}

# ---------------------------------------------------------------------------
# Get changed files since last sync
# ---------------------------------------------------------------------------
$changedFiles = @()
git cat-file -e $CurrentCommit 2>$null
if ($LASTEXITCODE -eq 0) {
    $changedFiles = (git diff --name-only $CurrentCommit "$SkeletonRemote/main") -split "`n" |
                    Where-Object { $_ -ne '' }
} else {
    # First sync — list every file tracked in the skeleton tree
    $changedFiles = (git ls-tree -r --name-only "$SkeletonRemote/main") -split "`n" |
                    Where-Object { $_ -ne '' }
}

$applied = 0
$skipped = 0
$needsMerge = @()

# ---------------------------------------------------------------------------
# Helper: check file ownership
# ---------------------------------------------------------------------------
function Test-InList {
    param([string]$File, [array]$List)
    foreach ($entry in $List) {
        if ($File -eq $entry) { return $true }
        # Directory prefix match (entry ends with /)
        if ($entry.EndsWith('/') -and $File.StartsWith($entry)) { return $true }
    }
    return $false
}

# ---------------------------------------------------------------------------
# Apply skeleton_owned files
# ---------------------------------------------------------------------------
Write-Heading 'Applying Skeleton-Owned Files (safe overwrite)'

foreach ($file in $changedFiles) {
    if (-not (Test-InList $file $SkeletonOwned)) { continue }

    # Check if file exists in skeleton remote
    $existsInSkeleton = git show "${SkeletonRemote}/main:$file" 2>$null
    if (-not $existsInSkeleton -and $LASTEXITCODE -ne 0) {
        Write-Warn "  REMOVED in skeleton: $file"
        Write-Warn "    Leaving local copy — remove manually if no longer needed"
        continue
    }

    if ($DryRun) {
        Write-Host "  [DRY-RUN WOULD UPDATE] $file" -ForegroundColor Green
        $applied++
    } else {
        $dir = Split-Path $file -Parent
        if ($dir -and -not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        git show "${SkeletonRemote}/main:$file" | Set-Content $file -Encoding UTF8 -NoNewline
        Write-OK "  Updated: $file"
        $applied++
    }
}

# ---------------------------------------------------------------------------
# Identify merge_required files that changed
# ---------------------------------------------------------------------------
Write-Heading 'Merge-Required Files (manual review needed)'

foreach ($file in $changedFiles) {
    if (-not (Test-InList $file $MergeRequired)) { continue }
    $existsInSkeleton = git show "${SkeletonRemote}/main:$file" 2>$null
    if (-not $existsInSkeleton -and $LASTEXITCODE -ne 0) { continue }
    $needsMerge += $file
}

if ($needsMerge.Count -eq 0) {
    Write-Info 'No merge-required files changed in this skeleton update.'
} else {
    Write-Host ''
    Write-Warn 'These files changed in the skeleton but require manual merge'
    Write-Warn 'because your project has likely customised them:'
    Write-Host ''
    foreach ($file in $needsMerge) {
        Write-Host "  -> $file" -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host 'For each file above:'
    Write-Host "  1. View skeleton version: git show ${SkeletonRemote}/main:<file>"
    Write-Host '  2. View your version:     Get-Content <file>'
    Write-Host '  3. Apply only the relevant new sections from the skeleton'
    Write-Host ''

    if (-not $DryRun) {
        foreach ($file in $needsMerge) {
            Write-Host ''
            Write-Host ('━' * 60)
            Write-Host " MERGE: $file" -ForegroundColor Yellow
            Write-Host ('━' * 60)
            Write-Host ''
            Write-Host 'Diff (skeleton vs your version):'
            try {
                git diff "${SkeletonRemote}/main:$file" $file 2>$null
            } catch {
                Write-Host '  [file is new in skeleton — no local version to diff]'
            }
            Write-Host ''

            if (-not $Auto) {
                Write-Host 'Options:'
                Write-Host '  a) Overwrite with skeleton version (discards your changes)'
                Write-Host '  s) Skip this file (merge manually later)'
                Write-Host '  c) Open side-by-side in VS Code diff'
                $choice = Read-Host 'Choice [a/S/c]'

                switch ($choice.ToLower()) {
                    'a' {
                        $dir = Split-Path $file -Parent
                        if ($dir -and -not (Test-Path $dir)) {
                            New-Item -ItemType Directory -Path $dir -Force | Out-Null
                        }
                        git show "${SkeletonRemote}/main:$file" | Set-Content $file -Encoding UTF8 -NoNewline
                        Write-OK "  Overwritten: $file"
                        $applied++
                    }
                    'c' {
                        # Open in VS Code diff (skeleton version as left, your version as right)
                        $tmpFile = [System.IO.Path]::GetTempFileName()
                        git show "${SkeletonRemote}/main:$file" | Set-Content $tmpFile -Encoding UTF8 -NoNewline
                        if (Get-Command code -ErrorAction SilentlyContinue) {
                            code --diff $tmpFile $file
                            Write-Warn '  VS Code diff opened. Save your file after merging, then press Enter.'
                            Read-Host 'Press Enter when done'
                        } else {
                            Write-Warn '  VS Code not found. Showing diff output only.'
                            git diff "${SkeletonRemote}/main:$file" $file 2>$null
                        }
                        Remove-Item $tmpFile -ErrorAction SilentlyContinue
                        Write-Warn "  Review complete. Stage manually if you edited: git add $file"
                        $skipped++
                    }
                    default {
                        Write-Warn "  Skipped: $file — merge manually"
                        $skipped++
                    }
                }
            } else {
                Write-Warn "  Skipped (--auto mode): $file — merge manually"
                $skipped++
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Report project_owned files changed in skeleton (informational only)
# ---------------------------------------------------------------------------
$projectTemplateChanges = @()
foreach ($file in $changedFiles) {
    if (Test-InList $file $ProjectOwned) {
        $projectTemplateChanges += $file
    }
}

if ($projectTemplateChanges.Count -gt 0) {
    Write-Heading 'Skeleton Template Files Changed (for your reference)'
    Write-Warn 'These project-owned files were updated in the skeleton template.'
    Write-Warn 'Review them to see if new guidance applies to your project:'
    Write-Host ''
    foreach ($file in $projectTemplateChanges) {
        Write-Host "  i  $file" -ForegroundColor Cyan
        Write-Host "     -> Review: git show ${SkeletonRemote}/main:$file"
    }
}

# ---------------------------------------------------------------------------
# Update initium.json
# ---------------------------------------------------------------------------
if (-not $DryRun -and $applied -gt 0) {
    Write-Heading 'Updating initium.json'

    try {
        $updates = git show "${SkeletonRemote}/main:INITIUM-UPDATES.md" 2>$null
        $versionLine = $updates -split "`n" | Where-Object { $_ -match '^## v' } | Select-Object -First 1
        $skeletonVersion = if ($versionLine) { ($versionLine -replace '^## v', '').Split(' ')[0] } else { 'unknown' }
    } catch {
        $skeletonVersion = 'unknown'
    }

    $today = Get-Date -Format 'yyyy-MM-dd'
    $json = Get-Content $SkeletonJson -Raw | ConvertFrom-Json
    $json.skeleton.commit    = $LatestCommit
    $json.skeleton.syncedAt  = $today
    $json.skeleton.version   = $skeletonVersion
    $json | ConvertTo-Json -Depth 10 | Set-Content $SkeletonJson -Encoding UTF8

    Write-OK "initium.json updated (version=$skeletonVersion, commit=$LatestShort)"
}

# ---------------------------------------------------------------------------
# Run validator
# ---------------------------------------------------------------------------
if (-not $DryRun -and $applied -gt 0) {
    Write-Heading 'Validating Configuration'
    if (Test-Path 'scripts\validate-ai-config.ps1') {
        try {
            & .\scripts\validate-ai-config.ps1
        } catch {
            Write-Warn 'Validator found issues — review above'
        }
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Heading 'Sync Complete'
Write-Host ''
Write-Host "  Applied (auto)   : $applied files" -ForegroundColor Green
Write-Host "  Skipped (manual) : $skipped files — merge these manually" -ForegroundColor Yellow
if ($projectTemplateChanges.Count -gt 0) {
    Write-Host "  Template notices : $($projectTemplateChanges.Count) project-owned files changed in skeleton" -ForegroundColor Cyan
}
Write-Host ''
if (-not $DryRun -and $applied -gt 0) {
    Write-Host 'Suggested next steps:'
    Write-Host '  1. Review changes:  git diff'
    Write-Host "  2. Stage and commit: git add -p; git commit -m 'chore: sync skeleton to $LatestShort'"
    if ($skipped -gt 0) {
        Write-Host '  3. Merge skipped files manually, then commit'
    }
} elseif ($DryRun) {
    Write-Host '  (Dry run — no files changed)'
}
Write-Host ''
