@echo off
echo ========================================
echo   Starting IT Help Desk System
echo ========================================
echo.
echo This will open TWO terminal windows:
echo   1. Backend Server (Port 8000)
echo   2. Frontend Server (Port 3000)
echo.
echo KEEP BOTH WINDOWS OPEN!
echo.
pause

echo Starting Backend Server...
start "IT Help Desk - Backend" cmd /k "cd /d "%~dp0backend" && venv\Scripts\activate && python main.py"

timeout /t 3 /nobreak >nul

echo Starting Frontend Server...
start "IT Help Desk - Frontend" cmd /k "cd /d "%~dp0frontend" && npm run dev"

echo.
echo ========================================
echo   Servers Starting!
echo ========================================
echo.
echo Wait 5-10 seconds for servers to start, then:
echo.
echo 1. Open browser: http://localhost:3000
echo 2. Login with:
echo    Username: admin
echo    Password: admin123
echo.
echo ⚠️  IMPORTANT: Keep both terminal windows open!
echo.
