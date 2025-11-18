# 🔧 LOGIN FIX - Step by Step

## ✅ Good News!
Your database is working correctly! All users exist with valid passwords.

**Verified Working Credentials:**
- ✅ Username: `admin` | Password: `admin123`
- ✅ Username: `technician` | Password: `tech123`
- ✅ Username: `user` | Password: `user123`

---

## 🚀 EASY FIX - Use This Single Command:

### **Double-click this file:**
```
START_BOTH_SERVERS.bat
```

This will:
1. Open Backend server in one window
2. Open Frontend server in another window
3. Keep both running automatically

**Then:**
1. Wait 5-10 seconds
2. Open browser: `http://localhost:3000`
3. Login with: `admin` / `admin123`

---

## 🔍 If Still Having Login Issues:

### Common Mistakes:

#### ❌ Typing errors:
- Make sure username is lowercase: `admin` (not `Admin`)
- Password is: `admin123` (not `Admin123`)
- No spaces before or after the username/password

#### ❌ Wrong URL:
- Use: `http://localhost:3000` 
- NOT: `http://localhost:8000`

#### ❌ One server not running:
- You need BOTH servers running
- Backend on port 8000
- Frontend on port 3000

---

## 🐛 Detailed Troubleshooting:

### Test 1: Check Backend is Running

Open browser and go to: `http://localhost:8000/docs`

**Expected:** You should see Swagger API documentation page

**If not working:**
```bash
cd backend
venv\Scripts\activate
python main.py
```

### Test 2: Check Frontend is Running

Open browser and go to: `http://localhost:3000`

**Expected:** You should see the login page

**If not working:**
```bash
cd frontend
npm run dev
```

### Test 3: Check Browser Console

1. Open the login page: `http://localhost:3000`
2. Press `F12` to open Developer Tools
3. Click on "Console" tab
4. Try to login
5. Look for error messages

**Common errors and fixes:**

- **"Network Error" or "ERR_CONNECTION_REFUSED"**
  - Backend is not running
  - Start backend: `START_BACKEND.bat`

- **"CORS policy" error**
  - Clear browser cache
  - Try in incognito/private window

- **"401 Unauthorized"**
  - Wrong username/password
  - Try exactly: `admin` / `admin123`

---

## 🔄 Nuclear Option - Full Reset:

If nothing works, do a complete reset:

```bash
# 1. Stop all servers (close all terminal windows)

# 2. Delete database
cd backend
del helpdesk.db

# 3. Reinstall dependencies
pip install -r requirements.txt

# 4. Reinitialize database
python init_db.py

# 5. Start both servers
cd ..
START_BOTH_SERVERS.bat
```

---

## ✅ Checklist Before Login:

- [ ] Backend running (Terminal 1 showing: "Uvicorn running on http://0.0.0.0:8000")
- [ ] Frontend running (Terminal 2 showing: "Local: http://localhost:3000/")
- [ ] Browser open at: `http://localhost:3000`
- [ ] Using correct credentials: `admin` / `admin123`
- [ ] No typos in username/password
- [ ] No extra spaces in fields

---

## 📞 Still Stuck?

### Check these files for more help:
1. `LOGIN_TROUBLESHOOTING.md` - Detailed troubleshooting
2. `README.md` - Full setup instructions

### Get system status:
```bash
cd backend
python verify_login.py
```

This shows:
- All users in database
- Password verification
- What's working/not working
