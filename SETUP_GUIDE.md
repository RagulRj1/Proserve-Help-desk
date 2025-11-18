# Complete Setup Guide - IT Help Desk System

Follow these steps to get your IT Help Desk system up and running.

## Step 1: Backend Setup

### 1.1 Open Terminal in Backend Directory
```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\backend"
```

### 1.2 Create Virtual Environment
```bash
python -m venv venv
```

### 1.3 Activate Virtual Environment

**Windows:**
```bash
venv\Scripts\activate
```

**Linux/Mac:**
```bash
source venv/bin/activate
```

### 1.4 Install Python Dependencies
```bash
pip install -r requirements.txt
```

### 1.5 Initialize Database
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

### 1.6 Start Backend Server
```bash
python main.py
```

Server will start at: `http://localhost:8000`

**Keep this terminal window open!**

## Step 2: Frontend Setup

### 2.1 Open New Terminal in Frontend Directory
```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\frontend"
```

### 2.2 Install Node Dependencies
```bash
npm install
```

This might take a few minutes...

### 2.3 Start Frontend Development Server
```bash
npm run dev
```

Frontend will start at: `http://localhost:3000`

**Keep this terminal window open too!**

## Step 3: Access the Application

### 3.1 Open Browser
Navigate to: `http://localhost:3000`

### 3.2 Login with Default Credentials

**As Admin:**
- Username: `admin`
- Password: `admin123`

**As Technician:**
- Username: `technician`
- Password: `tech123`

**As Regular User:**
- Username: `user`
- Password: `user123`

## Step 4: Test the System

### 4.1 Test as User
1. Login as `user` / `user123`
2. Click "Create Ticket"
3. Fill in ticket details
4. Submit and view your ticket

### 4.2 Test as Technician
1. Logout and login as `technician` / `tech123`
2. View the ticket created by user
3. Click "Assign to me"
4. Update ticket status to "In Progress"
5. Change status to "Resolved"

### 4.3 Test as Admin
1. Logout and login as `admin` / `admin123`
2. View all tickets and users
3. Create a new user
4. Assign tickets to technicians
5. View system statistics

## Troubleshooting

### Port Already in Use

**Backend (Port 8000):**
```bash
# Find and kill process on Windows
netstat -ano | findstr :8000
taskkill /PID <process_id> /F
```

**Frontend (Port 3000):**
```bash
# Find and kill process on Windows
netstat -ano | findstr :3000
taskkill /PID <process_id> /F
```

### Module Not Found Errors

**Backend:**
```bash
cd backend
venv\Scripts\activate
pip install -r requirements.txt
```

**Frontend:**
```bash
cd frontend
rm -rf node_modules
npm install
```

### Database Errors
```bash
cd backend
# Delete the database file
del helpdesk.db  # Windows
rm helpdesk.db   # Linux/Mac

# Reinitialize
python init_db.py
```

### CORS Errors
Make sure:
1. Backend is running on `http://localhost:8000`
2. Frontend is running on `http://localhost:3000`
3. Both servers are running simultaneously

## Quick Reference Commands

### Start Everything (Two Terminals Required)

**Terminal 1 - Backend:**
```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\backend"
venv\Scripts\activate
python main.py
```

**Terminal 2 - Frontend:**
```bash
cd "c:\Users\RAGUL\OneDrive\Desktop\IT Help Desk\frontend"
npm run dev
```

## API Documentation

View interactive API docs at: `http://localhost:8000/docs`

## Success Checklist

- [ ] Backend server running on port 8000
- [ ] Frontend server running on port 3000
- [ ] Can access login page
- [ ] Can login with default credentials
- [ ] Can create tickets as user
- [ ] Can manage tickets as technician
- [ ] Can access admin dashboard
- [ ] All statistics showing correctly

## Next Steps

1. **Change Default Passwords**: Create new users and delete default ones
2. **Customize Categories**: Add your own ticket categories
3. **Configure Email**: Set up email notifications (future enhancement)
4. **Production Deploy**: Use proper database (PostgreSQL) for production

## Getting Help

- Check API docs: `http://localhost:8000/docs`
- View browser console for frontend errors (F12)
- Check terminal output for backend errors
- Ensure all dependencies are installed

---

**Enjoy your IT Help Desk System! 🎉**
