@echo off
echo ========================================
echo   Database Migration (Keeps Your Data!)
echo ========================================
echo.
echo This will:
echo 1. Add new columns (phone, last_login)
echo 2. Keep all your existing data
echo 3. Keep all your tickets
echo 4. Keep all your users
echo.
echo ⚠️ IMPORTANT: Stop servers first!
echo.
pause

echo.
echo [Step 1] Checking if servers are stopped...
tasklist /FI "IMAGENAME eq python.exe" 2>NUL | find /I /N "python.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo ❌ Backend server is still running!
    echo Please run: STOP_SERVERS.bat first
    echo.
    pause
    exit /b 1
)
echo ✅ Servers are stopped
echo.

echo [Step 2] Activating virtual environment...
cd backend
call venv\Scripts\activate

echo.
echo [Step 3] Running migration...
python migrate_db.py

echo.
echo ========================================
echo   Migration Complete!
echo ========================================
echo.
echo You can now start your servers:
echo    START_BOTH_SERVERS.bat
echo.
echo All your data is preserved! ✅
echo.
pause
