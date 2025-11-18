@echo off
echo ========================================
echo   Database Upgrade Script
echo   Adding Super Admin Role Support
echo ========================================
echo.
echo This script will:
echo 1. Backup your current database
echo 2. Delete old database
echo 3. Create new database with super_admin role
echo 4. Initialize default users
echo.
echo ⚠️  WARNING: All existing data will be lost!
echo    Make sure to backup important data first.
echo.
pause

cd backend

echo.
echo [Step 1] Creating backup...
if exist helpdesk.db (
    copy helpdesk.db helpdesk.db.backup
    echo ✅ Backup created: helpdesk.db.backup
) else (
    echo ℹ️  No existing database found
)

echo.
echo [Step 2] Activating virtual environment...
call venv\Scripts\activate

echo.
echo [Step 3] Removing old database...
if exist helpdesk.db (
    del helpdesk.db
    echo ✅ Old database deleted
)

echo.
echo [Step 4] Creating new database with super_admin support...
python init_db.py

echo.
echo ========================================
echo   Database Upgrade Complete!
echo ========================================
echo.
echo New Login Credentials:
echo.
echo 1. Administrator (Full Access)
echo    Username: admin
echo    Password: admin123
echo.
echo 2. Manager (Limited Access)
echo    Username: manager
echo    Password: manager123
echo.
echo 3. Technician
echo    Username: technician
echo    Password: tech123
echo.
echo 4. User
echo    Username: user
echo    Password: user123
echo.
echo ========================================
echo   Important Changes:
echo ========================================
echo.
echo ✅ Registration now creates ONLY User accounts
echo ✅ Administrator can delete users and change roles
echo ✅ Manager has limited permissions
echo ✅ Manager cannot delete users or change roles
echo.
echo For more details, see ROLE_SYSTEM.md
echo.
pause
