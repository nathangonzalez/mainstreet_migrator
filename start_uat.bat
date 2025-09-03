@echo off
echo ===================================================
echo   Main Street Migrator - UAT Environment
echo ===================================================
echo.

echo Starting UAT server on port 8081...
echo.

REM Start the PowerShell UAT server that we've already created
powershell -ExecutionPolicy Bypass -File uat_server.ps1

echo.
echo UAT server stopped.
pause
