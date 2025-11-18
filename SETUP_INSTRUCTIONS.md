# 🚀 Complete Setup Instructions

## ✅ All Changes Complete!

Your IT Help Desk system now has:
1. ✅ **Registration without role selection** - Always creates "User" accounts
2. ✅ **Administrator role** (full access) - Can delete users and change roles
3. ✅ **Manager role** (limited access) - Cannot delete users or change roles

---

## 📋 Step-by-Step Setup

### Step 1: Stop Any Running Servers
```bash
# Double-click this file:
STOP_SERVERS.bat
```
This will kill all Python and Node processes.

### Step 2: Upgrade Database
```bash
# Double-click this file:
UPGRADE_DATABASE.bat
```
This will:
- Backup your old database
- Create new database with updated roles
- Initialize 4 default accounts

### Step 3: Start Backend Server
```bash
# Double-click or run in terminal:
START_BACKEND.bat
```
Wait for: `Uvicorn running on http://0.0.0.0:8000`

### Step 4: Start Frontend Server (New Terminal)
```bash
# Double-click or run in terminal:
START_FRONTEND.bat
```
Wait for: `Local: http://localhost:3000/`

### Step 5: Test the System
Open browser: `http://localhost:3000`

---

## 🔑 Login Credentials

### 🔴 Administrator (Full Access)
```
Username: admin
Password: admin123

Permissions:
✅ Delete users
✅ Change any user's role
✅ Create manager/admin accounts
✅ Edit tickets
✅ Reassign tickets
✅ Full system control
```

### 🟣 Manager (Limited Access)
```
Username: manager
Password: manager123

Permissions:
✅ Create User/Technician accounts
✅ Edit user info (name, email)
✅ Edit tickets
✅ Reassign tickets
❌ Cannot delete users
❌ Cannot change roles
```

### 🔵 Technician
```
Username: technician
Password: tech123

Permissions:
✅ View all tickets
✅ Self-assign tickets
✅ Update ticket status
✅ Change ticket priority
✅ Add comments
```

### 🟢 User
```
Username: user
Password: user123

Permissions:
✅ Create tickets
✅ View own tickets
✅ Add comments to own tickets
✅ Track ticket status
```

---

## 🧪 Testing Scenarios

### Test 1: Registration (No Role Selection)
1. Go to `http://localhost:3000/register`
2. Fill in: Email, Username, Full Name, Password
3. **Notice:** No role dropdown visible
4. Click "Create Account"
5. Account created as "User" automatically
6. Login and verify you can only create tickets

**Expected:** ✅ No role selection, account is User

---

### Test 2: Administrator Powers
1. Login as `admin` / `admin123`
2. Go to **User Management**
3. Click **Add User** → See all role options (User, Technician, Manager, Administrator)
4. Create a test user
5. Click **Edit** on any user → See role dropdown
6. Change role to "Technician" → Save
7. Click **Delete** button → User deleted
8. Go to **All Tickets** → Can edit and reassign

**Expected:** ✅ All features work, full control

---

### Test 3: Manager Limitations
1. Login as `manager` / `manager123`
2. Go to **User Management**
3. Click **Add User** → Only see User and Technician options
4. Try to create a Manager → Not possible
5. Click **Edit** on any user → See "Only Administrators can change roles"
6. Notice: **No Delete button** visible
7. Go to **All Tickets** → Can edit and reassign
8. Edit ticket status → Works fine

**Expected:** ✅ Limited permissions working correctly

---

### Test 4: Ticket Management (Both Admins)
1. Login as `admin` or `manager`
2. Go to **All Tickets**
3. Click **Edit** on any ticket
4. Change status, priority, or assign to technician
5. Save changes
6. Verify ticket updated

**Expected:** ✅ Both can manage tickets

---

## 📊 Role Comparison Table

| Feature | Administrator | Manager | Technician | User |
|---------|---------------|---------|------------|------|
| **Registration Role** | ❌ Admin only | ❌ Admin only | ❌ Admin only | ✅ Auto |
| **Delete Users** | ✅ | ❌ | ❌ | ❌ |
| **Change Roles** | ✅ | ❌ | ❌ | ❌ |
| **Create Admins** | ✅ | ❌ | ❌ | ❌ |
| **Create Managers** | ✅ | ❌ | ❌ | ❌ |
| **Create Users/Techs** | ✅ | ✅ | ❌ | ❌ |
| **Edit User Info** | ✅ | ✅ (no roles) | ❌ | Own only |
| **View All Tickets** | ✅ | ✅ | ✅ | Own only |
| **Edit Tickets** | ✅ | ✅ | ✅ | ❌ |
| **Reassign Tickets** | ✅ | ✅ | Self | ❌ |
| **Delete Tickets** | ✅ | ✅ | ❌ | ❌ |
| **Create Tickets** | ✅ | ✅ | ✅ | ✅ |

---

## 🎯 What Changed From Original Design

### Original:
- ❌ Registration had role dropdown
- ❌ Single "admin" role with full access
- ❌ Anyone could register as admin

### Now:
- ✅ Registration creates only User accounts
- ✅ Two admin levels: Administrator (full) and Manager (limited)
- ✅ Only Administrator can create other admins
- ✅ Protection against unauthorized privilege escalation

---

## 🔧 Project Structure

```
IT Help Desk/
├── backend/
│   ├── main.py              # Updated with new roles
│   ├── init_db.py           # Creates 4 default accounts
│   ├── requirements.txt
│   └── helpdesk.db          # Database (created after init)
│
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx      # Role dropdown removed
│   │   │   ├── AdminDashboard.jsx # Updated for 2-tier system
│   │   │   ├── UserDashboard.jsx
│   │   │   ├── TechnicianDashboard.jsx
│   │   │   └── Profile.jsx       # Updated role badges
│   │   ├── context/
│   │   │   └── AuthContext.jsx
│   │   └── App.jsx               # Updated routes
│   └── package.json
│
├── STOP_SERVERS.bat         # New - Stop all servers
├── UPGRADE_DATABASE.bat     # Updated - New role names
├── START_BACKEND.bat
├── START_FRONTEND.bat
├── NEW_ROLE_NAMES.md        # New - Role change guide
└── SETUP_INSTRUCTIONS.md    # This file
```

---

## ⚠️ Common Issues & Solutions

### Issue: "Cannot delete database file"
**Cause:** Backend server still running
**Solution:** 
```bash
1. Run STOP_SERVERS.bat
2. Wait 5 seconds
3. Run UPGRADE_DATABASE.bat again
```

### Issue: "Login failed with admin/admin123"
**Cause:** Database not upgraded
**Solution:**
```bash
1. Make sure servers are stopped
2. Run UPGRADE_DATABASE.bat
3. Wait for "Database initialized successfully!"
4. Start servers again
```

### Issue: "Still see old role names in UI"
**Cause:** Browser cache
**Solution:**
```bash
1. Clear browser cache (Ctrl+Shift+Delete)
2. Or use Incognito/Private mode
3. Refresh page
```

### Issue: "Can't change roles as manager"
**Cause:** Working as designed!
**Solution:**
- This is correct behavior
- Only Administrator can change roles
- Login as admin/admin123 for role changes

---

## 📞 Support & Documentation

### Documentation Files:
- **SETUP_INSTRUCTIONS.md** (this file) - Complete setup guide
- **NEW_ROLE_NAMES.md** - Role name changes explained
- **README.md** - Project overview
- **ROLE_SYSTEM.md** - Detailed role documentation
- **LOGIN_FIX_STEPS.md** - Login troubleshooting
- **QUICK_REFERENCE.md** - Quick command reference

### Help Resources:
1. Check documentation files first
2. Review error messages in terminal
3. Check browser console (F12)
4. Verify both servers are running
5. Confirm database was upgraded

---

## ✅ Success Checklist

After setup, verify:

- [ ] STOP_SERVERS.bat stopped all processes
- [ ] UPGRADE_DATABASE.bat completed successfully
- [ ] Backend server running on port 8000
- [ ] Frontend server running on port 3000
- [ ] Can access http://localhost:3000
- [ ] Registration page has no role field
- [ ] Can login as admin/admin123
- [ ] Can see delete buttons as admin
- [ ] Can change roles as admin
- [ ] Login as manager/manager123
- [ ] No delete buttons visible as manager
- [ ] Cannot change roles as manager
- [ ] Can edit tickets as both admin/manager
- [ ] Can create users as both admin/manager

---

## 🎉 All Done!

Your IT Help Desk system is now configured with:
- ✅ Secure registration (User accounts only)
- ✅ Two-tier admin system (Administrator & Manager)
- ✅ Role-based access control
- ✅ Protected user management
- ✅ Full ticket management

**Main Administrator Account:**
- Username: `admin`
- Password: `admin123`
- Full system control

**Remember to change default passwords for security!**

---

**Status:** Ready to use  
**Version:** 2.0  
**Last Updated:** November 2024
