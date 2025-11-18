# 🔧 Login Troubleshooting Guide

## Issue: Cannot login with admin or other users

### ✅ Solution Steps

#### Step 1: Make Sure Dependencies Are Installed

Open terminal in the backend folder and run:

```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\backend"
venv\Scripts\activate
pip install -r requirements.txt
```

Wait for all packages to install.

#### Step 2: Initialize the Database (If Not Already Done)

```bash
python init_db.py
```

You should see:
```
Database initialized successfully!

Default users created:
1. Admin - username: admin, password: admin123
2. Technician - username: technician, password: tech123
3. User - username: user, password: user123
```

#### Step 3: Start Backend Server

**Keep this terminal open!**

```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk"
START_BACKEND.bat
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

#### Step 4: Start Frontend Server (In a NEW Terminal)

Open a **NEW terminal window** and run:

```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk"
START_FRONTEND.bat
```

You should see:
```
VITE v5.x.x  ready in xxx ms

➜  Local:   http://localhost:3000/
```

#### Step 5: Test Login

1. Open browser and go to: **http://localhost:3000**
2. Try logging in with:

**Admin:**
- Username: `admin`
- Password: `admin123`

**Technician:**
- Username: `technician`
- Password: `tech123`

**User:**
- Username: `user`
- Password: `user123`

---

## Common Issues & Solutions

### ❌ "Module not found" errors
**Solution:** Run this in the backend folder:
```bash
venv\Scripts\activate
pip install -r requirements.txt
```

### ❌ "Cannot connect to server" or "Network Error"
**Solution:** 
- Make sure **BOTH** backend and frontend are running
- Backend should be on http://localhost:8000
- Frontend should be on http://localhost:3000
- Don't close either terminal!

### ❌ "Incorrect username or password"
**Solution:** 
1. Check if database is initialized:
```bash
cd backend
python init_db.py
```
2. Make sure you're using the correct credentials (see above)
3. Username and password are case-sensitive!

### ❌ Login page won't load
**Solution:**
- Frontend might not be running
- Check if http://localhost:3000 is accessible
- Restart the frontend: `START_FRONTEND.bat`

### ❌ "Port already in use"
**Solution:**
Kill the process using the port:
```bash
# For port 8000 (backend)
netstat -ano | findstr :8000
taskkill /PID <process_id> /F

# For port 3000 (frontend)
netstat -ano | findstr :3000
taskkill /PID <process_id> /F
```

---

## Quick Checklist

Before trying to login, verify:

- [ ] Backend dependencies installed (`pip install -r requirements.txt`)
- [ ] Database initialized (`python init_db.py`)
- [ ] Backend server running on port 8000
- [ ] Frontend server running on port 3000
- [ ] Browser pointing to http://localhost:3000
- [ ] Using correct credentials (admin/admin123)

---

## Still Having Issues?

### Check if users exist in database:

```bash
cd backend
python check_users.py
```

This will show all users in the database.

### Reinitialize everything:

```bash
cd backend
# Delete the database
del helpdesk.db

# Reinitialize
python init_db.py

# Restart backend
cd ..
START_BACKEND.bat
```

---

## Need More Help?

1. Check the terminal output for error messages
2. Look for red error text in the backend terminal
3. Open browser console (F12) and check for errors
4. Verify both servers are running simultaneously
