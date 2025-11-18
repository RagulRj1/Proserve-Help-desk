@echo off
echo ========================================
echo   Stopping All Servers
echo ========================================
echo.

echo Checking for running Python processes...
tasklist | findstr python.exe
if %errorlevel% == 0 (
    echo.
    echo Found Python processes. Stopping...
    taskkill /F /IM python.exe /T
    echo Python servers stopped.
)

echo.
echo Checking for running Node processes...
tasklist | findstr node.exe
if %errorlevel% == 0 (
    echo.
    echo Found Node processes. Stopping...
    taskkill /F /IM node.exe /T
    echo Node servers stopped.
)

echo.
echo ========================================
echo   All servers stopped!
echo ========================================
echo.
echo You can now run UPGRADE_DATABASE.bat
echo.
pause
