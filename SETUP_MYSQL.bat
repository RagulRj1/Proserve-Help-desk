@echo off
echo ========================================
echo   MySQL Setup for IT Help Desk
echo ========================================
echo.
echo This will:
echo 1. Install required Python packages
echo 2. Create MySQL database and user
echo 3. Create tables in MySQL
echo 4. Migrate your existing data from SQLite
echo 5. Update configuration to use MySQL
echo.
echo Prerequisites:
echo - MySQL 8.0 installed and running
echo - MySQL root password ready
echo.
pause

echo.
echo ========================================
echo   Step 1: Install MySQL Python Driver
echo ========================================
cd backend
call venv\Scripts\activate
pip install pymysql cryptography
echo ✅ Packages installed
echo.

echo ========================================
echo   Step 2: Create MySQL Database
echo ========================================
echo.
echo You'll be prompted for MySQL root password.
echo.
pause

mysql -u root -p < setup_mysql.sql

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Failed to create database!
    echo.
    echo Try manually:
    echo 1. Open MySQL Command Line Client
    echo 2. Enter root password
    echo 3. Run: source C:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\backend\setup_mysql.sql
    echo.
    pause
    exit /b 1
)

echo ✅ Database created successfully!
echo.

echo ========================================
echo   Step 3: Create Tables in MySQL
echo ========================================
echo.
echo Updating .env file...

REM Backup current .env
if exist .env (
    copy .env .env.sqlite.backup
    echo ✅ Backed up current .env to .env.sqlite.backup
)

REM Copy MySQL configuration
copy .env.mysql .env
echo ✅ Updated .env with MySQL configuration
echo.

echo Creating tables...
python -c "from main import Base, engine; Base.metadata.create_all(bind=engine); print('✅ Tables created successfully!')"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ Failed to create tables!
    echo Restoring SQLite configuration...
    copy .env.sqlite.backup .env
    pause
    exit /b 1
)

echo.

echo ========================================
echo   Step 4: Migrate Data from SQLite
echo ========================================
echo.
echo Transferring your existing data...
python migrate_to_mysql.py

echo.

echo ========================================
echo   Setup Complete!
echo ========================================
echo.
echo ✅ MySQL database configured
echo ✅ Tables created
echo ✅ Data migrated
echo.
echo You can now start the servers:
echo    cd ..
echo    START_BOTH_SERVERS.bat
echo.
echo Your old SQLite database is preserved as: helpdesk.db
echo Your old configuration is backed up as: .env.sqlite.backup
echo.
pause
