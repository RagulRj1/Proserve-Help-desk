@echo off
echo ========================================
echo   Fixing Login Issue
echo ========================================
echo.

cd backend

echo [Step 1] Activating virtual environment...
call venv\Scripts\activate

echo.
echo [Step 2] Installing all required dependencies...
pip install -r requirements.txt

echo.
echo [Step 3] Checking if database is initialized...
python check_users.py

echo.
echo ========================================
echo   Fix Complete!
echo ========================================
echo.
echo Now run these commands in TWO separate terminals:
echo.
echo Terminal 1: START_BACKEND.bat
echo Terminal 2: START_FRONTEND.bat
echo.
echo Then go to http://localhost:3000 and login with:
echo Username: admin
echo Password: admin123
echo.

pause
