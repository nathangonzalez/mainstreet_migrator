@echo off
echo ===================================================
echo   Main Street Migrator - WWW Access via Cloudflare
echo ===================================================
echo.

echo Checking if cloudflared is installed...
where cloudflared >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo cloudflared is not installed. 
    echo Installing cloudflared using winget...
    
    winget install Cloudflare.cloudflared
    if %ERRORLEVEL% NEQ 0 (
        echo Failed to install cloudflared.
        echo Please install it manually from https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation
        goto :error
    )
)

echo.
echo Starting Cloudflare tunnel to port 8081...
echo This will create a temporary public URL for your application.
echo.
echo When you're done testing, press Ctrl+C to stop the tunnel.
echo.

cloudflared tunnel --url http://localhost:8081

goto :end

:error
echo.
echo Error occurred during setup!
pause
exit /b 1

:end
pause
