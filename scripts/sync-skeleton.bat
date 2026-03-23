@echo off
:: =============================================================================
:: sync-skeleton.bat — Apply skeleton updates to your derived project (Windows)
:: =============================================================================
:: Delegates to sync-skeleton.ps1 for the full implementation.
:: If PowerShell execution policy blocks the script, see the note below.
::
:: Usage:
::   scripts\sync-skeleton.bat              Interactive mode
::   scripts\sync-skeleton.bat --auto       Auto-apply skeleton-owned files
::   scripts\sync-skeleton.bat --dry-run    Preview changes; apply nothing
::   scripts\sync-skeleton.bat --check      Check if update is available
::   scripts\sync-skeleton.bat --help       Show help
:: =============================================================================

setlocal

:: Show help without launching PowerShell
if /I "%~1"=="--help" (
    echo.
    echo  sync-skeleton.bat -- Apply upstream skeleton updates to this project
    echo.
    echo  Usage:
    echo    scripts\sync-skeleton.bat              Interactive mode
    echo    scripts\sync-skeleton.bat --auto       Auto-apply skeleton-owned files
    echo    scripts\sync-skeleton.bat --dry-run    Preview only; no changes applied
    echo    scripts\sync-skeleton.bat --check      Check for update availability
    echo.
    echo  What it does:
    echo    1. Adds the upstream skeleton repo as a git remote ^(once^)
    echo    2. Fetches latest commits from the skeleton
    echo    3. skeleton_owned files  -^> applied automatically ^(safe^)
    echo    4. merge_required files  -^> shown as diff; you choose per file
    echo    5. project_owned files   -^> never touched ^(your customisations^)
    echo    6. Updates skeleton.json with the new version and commit SHA
    echo.
    echo  File ownership is defined in skeleton.json at the repo root.
    echo  Full guide: docs\skeleton-sync.md
    echo.
    exit /b 0
)

:: Verify skeleton.json exists
if not exist "skeleton.json" (
    echo [ERROR] skeleton.json not found. Is this a skeleton-based project?
    exit /b 1
)

:: Verify git is available
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] git not found in PATH. Install Git for Windows: https://git-scm.com/download/win
    exit /b 1
)

:: Build PowerShell argument list from batch arguments
set PS_ARGS=
:parse_args
if "%~1"=="" goto run_ps
if /I "%~1"=="--auto"     set PS_ARGS=%PS_ARGS% -Auto
if /I "%~1"=="--dry-run"  set PS_ARGS=%PS_ARGS% -DryRun
if /I "%~1"=="--check"    set PS_ARGS=%PS_ARGS% -Check
shift
goto parse_args

:run_ps
:: ---------------------------------------------------------------------------
:: Try to run sync-skeleton.ps1 via PowerShell
:: ---------------------------------------------------------------------------
set PS_SCRIPT=%~dp0sync-skeleton.ps1

if not exist "%PS_SCRIPT%" (
    echo [ERROR] scripts\sync-skeleton.ps1 not found.
    echo         Run: bash scripts/sync-skeleton.sh    if using Git Bash or WSL
    exit /b 1
)

:: Attempt 1: PowerShell 7+ (pwsh)
:: Use goto instead of if (...) so that %errorlevel% after pwsh is captured correctly.
where pwsh >nul 2>&1
if errorlevel 1 goto try_ps51
echo [INFO]  Using PowerShell 7 ^(pwsh^)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %PS_ARGS%
exit /b %errorlevel%

:try_ps51
:: Attempt 2: Windows PowerShell 5.1 (powershell)
where powershell >nul 2>&1
if errorlevel 1 goto no_ps
echo [INFO]  Using Windows PowerShell 5.1
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %PS_ARGS%
exit /b %errorlevel%

:no_ps
:: ---------------------------------------------------------------------------
:: No PowerShell found — offer Git Bash / WSL fallback
:: ---------------------------------------------------------------------------
echo.
echo [ERROR] PowerShell not found. Cannot run sync-skeleton.ps1.
echo.
echo  Alternatives:
echo.
echo    Option A - Git Bash ^(recommended^):
echo      Right-click folder -^> "Git Bash Here"
echo      bash scripts/sync-skeleton.sh%PS_ARGS: =--%
echo.
echo    Option B - WSL ^(Windows Subsystem for Linux^):
echo      wsl bash scripts/sync-skeleton.sh%PS_ARGS: =--%
echo.
echo    Option C - Manual sync ^(no scripts^):
echo      See docs\skeleton-sync.md for step-by-step instructions
echo.
exit /b 1
