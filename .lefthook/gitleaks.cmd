@echo off
setlocal enabledelayedexpansion

where /q gitleaks
if !ERRORLEVEL! EQU 0 (
    gitleaks protect --staged
    exit /b !ERRORLEVEL!
)

set "fallback=%LOCALAPPDATA%\Programs\gitleaks\gitleaks.exe"
if exist "!fallback!" (
    "!fallback!" protect --staged
    exit /b !ERRORLEVEL!
)

echo [gitleaks] not found. Install: choco install gitleaks
exit /b 1
