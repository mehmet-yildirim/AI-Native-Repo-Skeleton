@echo off
:: =============================================================================
:: sync-initium.cmd — Apply skeleton updates to your derived project (Windows)
:: =============================================================================
:: Delegates to sync-initium.ps1 via PowerShell 7 (pwsh) or
:: Windows PowerShell 5.1 (powershell.exe) — both are built into Windows.
:: No bash, WSL, or any additional tool required.
::
:: Usage:
::   scripts\sync-initium.cmd              Interactive mode
::   scripts\sync-initium.cmd --auto       Auto-apply skeleton-owned files
::   scripts\sync-initium.cmd --dry-run    Preview changes; apply nothing
::   scripts\sync-initium.cmd --check      Check if update is available
::   scripts\sync-initium.cmd --help       Show help
:: =============================================================================

setlocal

:: Show help
if /I "%~1"=="--help" (
    echo.
    echo  sync-initium.cmd -- Apply upstream skeleton updates to this project
    echo.
    echo  Usage:
    echo    scripts\sync-initium.cmd              Interactive mode
    echo    scripts\sync-initium.cmd --auto       Auto-apply skeleton-owned files
    echo    scripts\sync-initium.cmd --dry-run    Preview only; no changes applied
    echo    scripts\sync-initium.cmd --check      Check for update availability
    echo.
    echo  What it does:
    echo    1. Adds the upstream skeleton repo as a git remote ^(once^)
    echo    2. Fetches latest commits from the skeleton
    echo    3. skeleton_owned files  -^> applied automatically ^(safe^)
    echo    4. merge_required files  -^> shown as diff; you choose per file
    echo    5. project_owned files   -^> never touched ^(your customisations^)
    echo    6. Updates initium.json with the new version and commit SHA
    echo.
    echo  File ownership is defined in initium.json at the repo root.
    echo  Full guide: docs\initium-sync.md
    echo.
    exit /b 0
)

:: Verify initium.json exists
if not exist "initium.json" (
    echo [ERROR] initium.json not found. Is this a skeleton-based project?
    exit /b 1
)

:: Verify git is available
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] git not found in PATH. Install Git for Windows: https://git-scm.com/download/win
    exit /b 1
)

:: Build PowerShell argument string from CMD arguments
set PS_ARGS=

:parse_args
if "%~1"=="" goto run
if /I "%~1"=="--auto"     set PS_ARGS=%PS_ARGS% -Auto
if /I "%~1"=="--dry-run"  set PS_ARGS=%PS_ARGS% -DryRun
if /I "%~1"=="--check"    set PS_ARGS=%PS_ARGS% -Check
shift
goto parse_args

:run
set PS_SCRIPT=%~dp0sync-initium.ps1

:: ---------------------------------------------------------------------------
:: Attempt 1: PowerShell 7+ (pwsh) — preferred, ships with Windows 11 / 10
:: ---------------------------------------------------------------------------
where pwsh >nul 2>&1
if errorlevel 1 goto try_ps51
pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"%PS_ARGS%
exit /b %errorlevel%

:try_ps51
:: ---------------------------------------------------------------------------
:: Attempt 2: Windows PowerShell 5.1 — built into every Windows 7+ system
:: ---------------------------------------------------------------------------
where powershell >nul 2>&1
if errorlevel 1 goto no_powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"%PS_ARGS%
exit /b %errorlevel%

:no_powershell
:: ---------------------------------------------------------------------------
:: PowerShell missing — extremely unlikely on any modern Windows system
:: ---------------------------------------------------------------------------
echo.
echo [ERROR] PowerShell not found in PATH.
echo.
echo  PowerShell is built into Windows 7 and later. If it is missing:
echo.
echo    Option A - Restore Windows PowerShell 5.1:
echo      Open "Turn Windows features on or off" and enable
echo      "Windows PowerShell 2.0" (re-enables 5.1 on modern Windows).
echo.
echo    Option B - Install PowerShell 7:
echo      https://aka.ms/powershell
echo.
echo    Option C - Manual sync ^(no tools required^):
echo      See docs\initium-sync.md for step-by-step instructions.
echo.
exit /b 1
