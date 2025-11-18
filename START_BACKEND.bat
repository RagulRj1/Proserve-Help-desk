@echo off
echo ========================================
echo   IT Help Desk - Starting Backend
echo ========================================
echo.

cd backend

echo Activating virtual environment...
call venv\Scripts\activate

echo.
echo Starting FastAPI server...
python main.py

pause
