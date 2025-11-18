# Database Initialization - Production Safety Guide

## Problem Solved
**Before:** Running `init_db.py` would **always reset all user passwords to defaults**, even if you'd changed them on live data. This was dangerous and broke production systems.

**After:** `init_db.py` now **PROTECTS existing users** and only seeds defaults on a fresh database.

---

## How It Works Now

### 1. **First-Time Setup** (Fresh Database)
```bash
python init_db.py
```
✓ Creates all tables  
✓ Creates default users (admin, registrant, technician, user)  
✓ All users are active and ready to use  

### 2. **Subsequent Runs** (Database Already Has Users)
```bash
python init_db.py
```
✓ Creates any missing tables  
✓ **DOES NOT TOUCH EXISTING USERS** ← SAFE!  
✓ Print shows: "Existing users will NOT be modified"  

### 3. **Development Password Reset** (ONLY When Needed)
If you need to reset passwords back to defaults **for testing in development**:

```bash
python reset_dev_passwords.py
```
- Prompts for confirmation first  
- Resets ONLY known default users (admin, registrant, technician, user)  
- Custom users you created are NOT affected  
- **NEVER use this on production!**

---

## Default Credentials (Development Only)

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Registrant | `registant_entry_code` | `registant123` |
| Technician | `technician` | `tech123` |
| User | `user` | `user123` |

---

## For Production / Going Live

✓ Change all default passwords immediately  
✓ Use `reset_dev_passwords.py` only in development environments  
✓ `init_db.py` is safe to run multiple times; it will never reset existing users  
✓ Back up your database before any major changes  

---

## File Changes Made

- **`init_db.py`** – Updated to protect existing users (never resets them)
- **`reset_dev_passwords.py`** – New development-only script for manual password resets

---

## Why This Matters

This change prevents:
- ❌ Accidental password resets on live systems
- ❌ Loss of custom user accounts
- ❌ Database corruption from unexpected modifications
- ✅ Safe, repeatable database initialization
- ✅ Clear separation between first-time setup and ongoing operations
