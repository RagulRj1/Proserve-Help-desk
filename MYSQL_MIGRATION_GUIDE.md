# 🗄️ MySQL Database Migration Guide

## Overview
Migrate your IT Help Desk from SQLite to MySQL for better performance, scalability, and production readiness.

---

## ✨ Benefits of MySQL

### **Why Switch to MySQL?**
✅ **Better Performance** - Handles more concurrent users  
✅ **Scalability** - Grow without limitations  
✅ **Production Ready** - Industry standard for web apps  
✅ **Advanced Features** - Replication, clustering, backups  
✅ **Better Concurrency** - Multiple users editing simultaneously  
✅ **Network Access** - Connect from different machines  

### **SQLite vs MySQL:**
| Feature | SQLite | MySQL |
|---------|--------|-------|
| **Concurrent Users** | Limited | Excellent |
| **Database Size** | Max 140TB | Unlimited |
| **Performance** | Good for <100K records | Excellent for millions |
| **Network Access** | No | Yes |
| **Backup** | File copy | Native tools |
| **Use Case** | Development/Small apps | Production/Enterprise |

---

## 📋 Prerequisites

### **1. MySQL 8.0 Installed** ✅
You already have MySQL 8.0! Great!

Check it's running:
```powershell
# Open Services (Win+R, type: services.msc)
# Look for: MySQL80
# Status should be: Running
```

Or in PowerShell:
```powershell
Get-Service MySQL80
```

### **2. Know Your MySQL Root Password**
You'll need this to create the database.

### **3. Backup Your Current Data**
Your SQLite database will be preserved, but it's good practice!

---

## 🚀 Automatic Migration (Recommended)

### **Method 1: Use the Automated Script**

This script does everything for you!

```powershell
# Stop any running servers first
.\STOP_SERVERS.bat

# Run the automated setup
.\SETUP_MYSQL.bat
```

**What it does:**
1. ✅ Installs Python packages (pymysql)
2. ✅ Creates MySQL database and user
3. ✅ Creates all tables
4. ✅ Migrates your data (users + tickets)
5. ✅ Updates configuration

**When prompted:**
- Enter MySQL **root** password
- Press Enter to continue

---

## 🔧 Manual Migration (Step by Step)

### **Step 1: Install Python MySQL Driver**

```powershell
cd backend
.\venv\Scripts\activate
pip install pymysql cryptography
```

### **Step 2: Create MySQL Database**

**Option A: Using MySQL Command Line**
```powershell
mysql -u root -p < backend/setup_mysql.sql
```

**Option B: Using MySQL Workbench**
1. Open MySQL Workbench
2. Connect to localhost
3. File → Open SQL Script → `backend/setup_mysql.sql`
4. Click Execute (⚡ icon)

**Option C: Manually in MySQL**
```sql
-- Connect to MySQL as root
mysql -u root -p

-- Run these commands:
CREATE DATABASE IF NOT EXISTS helpdesk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'helpdesk_user'@'localhost' IDENTIFIED BY 'HelpDesk@2024';
GRANT ALL PRIVILEGES ON helpdesk_db.* TO 'helpdesk_user'@'localhost';
FLUSH PRIVILEGES;
```

### **Step 3: Update Configuration**

Edit `backend/.env` file:

```env
# Change from:
# DATABASE_URL=sqlite:///./helpdesk.db

# To:
DATABASE_URL=mysql+pymysql://helpdesk_user:HelpDesk@2024@localhost:3306/helpdesk_db
```

**Or copy the template:**
```powershell
cd backend
copy .env.mysql .env
```

### **Step 4: Create Tables**

```powershell
cd backend
python -c "from main import Base, engine; Base.metadata.create_all(bind=engine)"
```

You should see:
```
[Database] Using MySQL/PostgreSQL: localhost:3306/helpdesk_db
```

### **Step 5: Migrate Data**

```powershell
python migrate_to_mysql.py
```

Output:
```
========================================
  SQLite to MySQL Migration
  Transferring Your Data
========================================

✅ Connected to MySQL database: helpdesk_db

📋 Migrating users...
✅ Migrated 5 users

📋 Migrating tickets...
✅ Migrated 2 tickets

========================================
  Migration Summary
========================================
👥 Users in MySQL: 5
🎫 Tickets in MySQL: 2

========================================
  Migration Complete!
========================================

✅ All data transferred successfully!
✅ MySQL database is ready to use!
```

### **Step 6: Test the Migration**

```powershell
cd ..
.\START_BOTH_SERVERS.bat
```

Check backend terminal for:
```
[Database] Using MySQL/PostgreSQL: localhost:3306/helpdesk_db
INFO:     Application startup complete.
```

Login with: `admin` / `admin123`

---

## 🔍 Verify Migration

### **Check Data in MySQL:**

**Option 1: MySQL Command Line**
```sql
mysql -u helpdesk_user -p
# Password: HelpDesk@2024

USE helpdesk_db;

-- Check users
SELECT id, username, full_name, role FROM users;

-- Check tickets
SELECT id, title, status, priority FROM tickets;
```

**Option 2: MySQL Workbench**
1. Open MySQL Workbench
2. Connect: `helpdesk_user@localhost`
3. Password: `HelpDesk@2024`
4. Browse `helpdesk_db` → Tables
5. Right-click `users` → Select Rows
6. Right-click `tickets` → Select Rows

---

## ⚙️ Configuration Details

### **Database Connection String Format:**
```
mysql+pymysql://[user]:[password]@[host]:[port]/[database]
```

### **Default Configuration:**
```env
DATABASE_URL=mysql+pymysql://helpdesk_user:HelpDesk@2024@localhost:3306/helpdesk_db

MYSQL_USER=helpdesk_user
MYSQL_PASSWORD=HelpDesk@2024
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=helpdesk_db
```

### **Change MySQL Password:**

If you want a different password:

1. **Update MySQL:**
```sql
ALTER USER 'helpdesk_user'@'localhost' IDENTIFIED BY 'YourNewPassword';
```

2. **Update `.env` file:**
```env
DATABASE_URL=mysql+pymysql://helpdesk_user:YourNewPassword@localhost:3306/helpdesk_db
MYSQL_PASSWORD=YourNewPassword
```

---

## 🐛 Troubleshooting

### **Issue 1: "Access denied for user"**

**Cause:** Wrong password or user doesn't exist

**Fix:**
```sql
-- Connect as root
mysql -u root -p

-- Recreate user
DROP USER IF EXISTS 'helpdesk_user'@'localhost';
CREATE USER 'helpdesk_user'@'localhost' IDENTIFIED BY 'HelpDesk@2024';
GRANT ALL PRIVILEGES ON helpdesk_db.* TO 'helpdesk_user'@'localhost';
FLUSH PRIVILEGES;
```

### **Issue 2: "Can't connect to MySQL server"**

**Cause:** MySQL not running

**Fix:**
```powershell
# Start MySQL service
net start MySQL80

# Or use Services app:
# Win+R → services.msc → Find MySQL80 → Start
```

### **Issue 3: "Unknown database 'helpdesk_db'"**

**Cause:** Database not created

**Fix:**
```sql
mysql -u root -p
CREATE DATABASE helpdesk_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### **Issue 4: "No module named 'pymysql'"**

**Cause:** Package not installed

**Fix:**
```powershell
cd backend
pip install pymysql cryptography
```

### **Issue 5: Backend shows SQLite not MySQL**

**Cause:** `.env` file not updated

**Check:**
```powershell
cd backend
type .env | findstr DATABASE_URL
```

Should show:
```
DATABASE_URL=mysql+pymysql://...
```

**Fix:**
```powershell
copy .env.mysql .env
```

### **Issue 6: Migration script fails**

**Cause:** Tables don't exist in MySQL

**Fix:**
```powershell
cd backend
python -c "from main import Base, engine; Base.metadata.create_all(bind=engine)"
python migrate_to_mysql.py
```

---

## 📊 Database Schema

### **Tables Created:**

**1. users**
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255),
    hashed_password VARCHAR(255),
    role ENUM('user', 'technician', 'manager', 'admin'),
    phone VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    is_active TINYINT DEFAULT 1
);
```

**2. tickets**
```sql
CREATE TABLE tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    category VARCHAR(100),
    created_by INT,
    assigned_to INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (assigned_to) REFERENCES users(id)
);
```

---

## 🔒 Security Best Practices

### **1. Change Default Password**
```sql
ALTER USER 'helpdesk_user'@'localhost' IDENTIFIED BY 'YourStrongPassword123!';
```

Update `.env` accordingly.

### **2. Limit Network Access**
```sql
-- Only allow localhost
CREATE USER 'helpdesk_user'@'localhost' IDENTIFIED BY 'password';

-- Allow specific IP
CREATE USER 'helpdesk_user'@'192.168.1.100' IDENTIFIED BY 'password';
```

### **3. Use Strong Passwords**
- Minimum 12 characters
- Mix of upper/lower/numbers/symbols
- Not dictionary words

### **4. Regular Backups**
```powershell
# Backup database
mysqldump -u helpdesk_user -p helpdesk_db > backup_YYYYMMDD.sql

# Restore from backup
mysql -u helpdesk_user -p helpdesk_db < backup_YYYYMMDD.sql
```

---

## 🔄 Rollback to SQLite

If you need to go back to SQLite:

### **Step 1: Stop Servers**
```powershell
.\STOP_SERVERS.bat
```

### **Step 2: Restore SQLite Configuration**
```powershell
cd backend
copy .env.sqlite.backup .env
```

Or manually edit `.env`:
```env
DATABASE_URL=sqlite:///./helpdesk.db
```

### **Step 3: Start Servers**
```powershell
cd ..
.\START_BOTH_SERVERS.bat
```

Your old SQLite database (`helpdesk.db`) is still there!

---

## 📈 Performance Tips

### **1. Enable Connection Pooling** ✅
Already enabled in `main.py`:
```python
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=3600
)
```

### **2. Add Indexes (Optional)**
For better query performance:
```sql
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_assigned ON tickets(assigned_to);
CREATE INDEX idx_tickets_created ON tickets(created_by);
```

### **3. Optimize MySQL Configuration**
Edit `my.ini` (MySQL config):
```ini
[mysqld]
max_connections=200
innodb_buffer_pool_size=256M
```

---

## ✅ Post-Migration Checklist

- [ ] MySQL service running
- [ ] Database created successfully
- [ ] Tables created (users, tickets)
- [ ] Data migrated (check counts match)
- [ ] `.env` updated with MySQL URL
- [ ] Backend starts without errors
- [ ] Backend shows "Using MySQL" message
- [ ] Can login successfully
- [ ] Can see all users
- [ ] Can see all tickets
- [ ] Can create new tickets
- [ ] Can edit users
- [ ] SQLite backup preserved

---

## 🎯 Quick Reference

### **Common Commands:**

```powershell
# Start MySQL
net start MySQL80

# Stop MySQL
net stop MySQL80

# Connect to MySQL
mysql -u helpdesk_user -p

# Backup database
mysqldump -u helpdesk_user -p helpdesk_db > backup.sql

# Restore database
mysql -u helpdesk_user -p helpdesk_db < backup.sql

# Check MySQL status
Get-Service MySQL80
```

### **MySQL Workbench:**
- Download: https://dev.mysql.com/downloads/workbench/
- Connect: `helpdesk_user@localhost:3306`
- Password: `HelpDesk@2024`

---

## 🚀 Summary

**Automated Migration:**
```powershell
.\STOP_SERVERS.bat
.\SETUP_MYSQL.bat
.\START_BOTH_SERVERS.bat
```

**Manual Migration:**
1. Install pymysql: `pip install pymysql cryptography`
2. Create database: `mysql -u root -p < backend/setup_mysql.sql`
3. Update `.env`: Copy `backend/.env.mysql` to `backend/.env`
4. Create tables: `python -c "from main import Base, engine; Base.metadata.create_all(bind=engine)"`
5. Migrate data: `python backend/migrate_to_mysql.py`
6. Start servers: `.\START_BOTH_SERVERS.bat`

**Verify:**
- Backend terminal shows: `[Database] Using MySQL/PostgreSQL`
- Login works
- Data is accessible

---

**🎉 Your IT Help Desk is now running on MySQL!**

Enterprise-ready database with better performance and scalability! 🚀
