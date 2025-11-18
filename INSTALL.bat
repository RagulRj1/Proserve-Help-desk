@echo off
echo ========================================
echo   IT Help Desk - Installation Script
echo ========================================
echo.

echo [1/4] Setting up Backend...
cd backend

echo Creating virtual environment...
python -m venv venv

echo Activating virtual environment...
call venv\Scripts\activate

echo Installing Python dependencies...
pip install -r requirements.txt

echo Initializing database...
python init_db.py

echo.
echo [2/4] Backend setup complete!
echo.

cd ..

echo [3/4] Setting up Frontend...
cd frontend

echo Installing Node dependencies...
npm install

echo.
echo [4/4] Frontend setup complete!
echo.

cd ..

echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo To start the application:
echo 1. Run START_BACKEND.bat in one terminal
echo 2. Run START_FRONTEND.bat in another terminal
echo 3. Open http://localhost:3000 in your browser
echo.
echo Default credentials:
echo - Admin: admin / admin123
echo - Technician: technician / tech123
echo - User: user / user123
echo.

pause
