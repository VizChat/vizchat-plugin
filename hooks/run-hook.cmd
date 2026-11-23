: << 'CMDBLOCK'
@echo off
REM Cross-platform wrapper for the VizChat plugin hooks: run-hook.cmd <script> [args...]
REM Adapted from obra/superpowers hooks/run-hook.cmd (MIT, Copyright (c) 2025 Jesse Vincent; see NOTICE).
REM Windows: cmd.exe runs this batch half, which finds Git Bash and runs the named script with it.
REM Unix: the shell treats the batch half as a heredoc (":" is a no-op) and runs the shell half below.
REM Scripts are extensionless so Claude Code's Windows auto-detection (which prepends bash to *.sh) stays out of the way.

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

setlocal
set "HOOK_DIR=%~dp0"
set "BASH_EXE="

if exist "C:\Program Files\Git\bin\bash.exe" set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
if not defined BASH_EXE if exist "C:\Program Files (x86)\Git\bin\bash.exe" set "BASH_EXE=C:\Program Files (x86)\Git\bin\bash.exe"
REM Per-user Git for Windows; the defined check keeps an unset LOCALAPPDATA from collapsing to a path any user can create.
if not defined BASH_EXE if defined LOCALAPPDATA if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "BASH_EXE=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
REM bash on PATH (MSYS2, Cygwin, other Git installs), skipping the WSL launchers that fail without a Linux distro.
if not defined BASH_EXE if defined SystemRoot for /f "delims=" %%B in ('"%SystemRoot%\System32\where.exe" $PATH:bash 2^>nul') do if not defined BASH_EXE if not "%%~xB"=="" if /i not "%%~dpB"=="%SystemRoot%\System32\" if /i not "%%~dpB"=="%SystemRoot%\Sysnative\" if /i not "%%~dpB"=="%LOCALAPPDATA%\Microsoft\WindowsApps\" set "BASH_EXE=%%B"

REM No bash: exit quietly; the plugin still works, only without its hooks.
if not defined BASH_EXE exit /b 0

"%BASH_EXE%" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
CMDBLOCK

# Unix half. No dirname and no PATH lookup for the shell where avoidable: SessionStart can start with a broken PATH
# (anthropics/claude-code#43127). $BASH is bash's own absolute path; the scripts are POSIX sh, so sh works too.
case "$0" in
  */*|*\\*) SCRIPT_DIR="${0%[/\\]*}" ;;
  *) SCRIPT_DIR="." ;;
esac
SCRIPT_NAME="$1"
shift

if [ -n "${BASH:-}" ]; then
  shell="$BASH"
elif command -v sh >/dev/null 2>&1; then
  shell="sh"
elif [ -x /bin/sh ]; then
  shell="/bin/sh"
else
  exit 0
fi

exec "$shell" "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
