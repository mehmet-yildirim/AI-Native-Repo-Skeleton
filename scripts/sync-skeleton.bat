@echo off
:: =============================================================================
:: sync-skeleton.bat — Apply skeleton updates to your derived project (Windows)
:: =============================================================================
:: Runs sync-skeleton.sh via Git Bash or WSL (preferred).
:: Falls back to sync-skeleton.ps1 via PowerShell only if bash is unavailable.
::
:: Usage:
::   scripts\sync-skeleton.bat              Interactive mode
::   scripts\sync-skeleton.bat --auto       Auto-apply skeleton-owned files
::   scripts\sync-skeleton.bat --dry-run    Preview changes; apply nothing
::   scripts\sync-skeleton.bat --check      Check if update is available
::   scripts\sync-skeleton.bat --help       Show help
:: =============================================================================

setlocal

:: Show help
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

:: Build argument strings for bash and PowerShell
set SH_ARGS=
set PS_ARGS=

:parse_args
if "%~1"=="" goto run
if /I "%~1"=="--auto"     set SH_ARGS=%SH_ARGS% --auto
if /I "%~1"=="--auto"     set PS_ARGS=%PS_ARGS% -Auto
if /I "%~1"=="--dry-run"  set SH_ARGS=%SH_ARGS% --dry-run
if /I "%~1"=="--dry-run"  set PS_ARGS=%PS_ARGS% -DryRun
if /I "%~1"=="--check"    set SH_ARGS=%SH_ARGS% --check
if /I "%~1"=="--check"    set PS_ARGS=%PS_ARGS% -Check
shift
goto parse_args

:run
set SH_SCRIPT=scripts/sync-skeleton.sh
set PS_SCRIPT=%~dp0sync-skeleton.ps1

:: ---------------------------------------------------------------------------
:: Attempt 1: bash (Git for Windows / Git Bash)
:: Git for Windows puts bash.exe in PATH when installed with default options.
:: ---------------------------------------------------------------------------
where bash >nul 2>&1
if errorlevel 1 goto try_wsl
echo [INFO]  Using bash ^(Git Bash^)
bash %SH_SCRIPT%%SH_ARGS%
exit /b %errorlevel%

:try_wsl
:: ---------------------------------------------------------------------------
:: Attempt 2: WSL (Windows Subsystem for Linux)
:: ---------------------------------------------------------------------------
where wsl >nul 2>&1
if errorlevel 1 goto try_pwsh
echo [INFO]  Using WSL
wsl bash %SH_SCRIPT%%SH_ARGS%
exit /b %errorlevel%

:try_pwsh
:: ---------------------------------------------------------------------------
:: Attempt 3: PowerShell 7+ with sync-skeleton.ps1 (optional fallback)
:: ---------------------------------------------------------------------------
where pwsh >nul 2>&1
if errorlevel 1 goto try_ps51
if not exist "%PS_SCRIPT%" goto no_runner
echo [INFO]  Using PowerShell 7 ^(pwsh^)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %PS_ARGS%
exit /b %errorlevel%

:try_ps51
:: ---------------------------------------------------------------------------
:: Attempt 4: Windows PowerShell 5.1 with sync-skeleton.ps1 (optional fallback)
:: ---------------------------------------------------------------------------
where powershell >nul 2>&1
if errorlevel 1 goto no_runner
if not exist "%PS_SCRIPT%" goto no_runner
echo [INFO]  Using Windows PowerShell 5.1
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" %PS_ARGS%
exit /b %errorlevel%

:no_runner
:: ---------------------------------------------------------------------------
:: Nothing found — provide instructions
:: ---------------------------------------------------------------------------
echo.
echo [ERROR] No suitable runner found ^(bash, WSL, or PowerShell^).
echo.
echo  Install one of the following:
echo.
echo    Option A - Git for Windows ^(recommended^):
echo      https://git-scm.com/download/win
echo      Includes bash. Re-run this script after installing.
echo.
echo    Option B - WSL ^(Windows Subsystem for Linux^):
echo      Open PowerShell as Administrator and run: wsl --install
echo      Then re-run this script.
echo.
echo    Option C - Manual sync ^(no tools required^):
echo      See docs\skeleton-sync.md for step-by-step instructions.
echo.
exit /b 1
