# 🗺️ React Router System Documentation

## Overview
Complete client-side routing with role-based access control, protected routes, and automatic redirection based on user authentication and roles.

---

## 🏗️ Architecture Overview

```
App.jsx
├── AuthProvider (Context)
│   └── User state management
│
├── Router (React Router)
│   ├── Public Routes
│   │   ├── /login
│   │   └── /register
│   │
│   ├── Root Route (/)
│   │   └── DashboardRouter (auto-redirect)
│   │
│   └── Protected Routes (PrivateRoute wrapper)
│       ├── /dashboard (User only)
│       ├── /technician (Technician only)
│       ├── /admin (Admin + Manager)
│       └── /profile (All authenticated)
```

---

## 🔐 PrivateRoute Component

### Purpose
Protects routes from unauthorized access based on authentication and role.

### Implementation
```javascript
// App.jsx:11-23
const PrivateRoute = ({ children, allowedRoles }) => {
  const { user } = useAuth();
  
  // Check 1: Is user authenticated?
  if (!user) {
    return <Navigate to="/login" />;
  }
  
  // Check 2: Does user have required role?
  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return <Navigate to="/login" />;
  }
  
  // All checks passed - render the protected component
  return children;
};
```

### Protection Logic

#### Step 1: Authentication Check
```javascript
if (!user) {
  return <Navigate to="/login" />;
}
```
**Checks:** Is the user logged in?
- ✅ User object exists in AuthContext → Continue
- ❌ No user object → Redirect to `/login`

#### Step 2: Role Authorization Check
```javascript
if (allowedRoles && !allowedRoles.includes(user.role)) {
  return <Navigate to="/login" />;
}
```
**Checks:** Does the user's role match allowed roles?
- ✅ user.role is in allowedRoles → Continue
- ❌ user.role not in allowedRoles → Redirect to `/login`

#### Step 3: Grant Access
```javascript
return children;
```
**Action:** Render the protected component

---

## 🧭 DashboardRouter Component

### Purpose
Automatically redirects authenticated users to their role-specific dashboard.

### Implementation
```javascript
// App.jsx:25-43
const DashboardRouter = () => {
  const { user } = useAuth();
  
  // Not logged in - go to login
  if (!user) {
    return <Navigate to="/login" />;
  }
  
  // Role-based redirection
  switch (user.role) {
    case 'admin':
    case 'manager':
      return <Navigate to="/admin" />;
    case 'technician':
      return <Navigate to="/technician" />;
    case 'user':
      return <Navigate to="/dashboard" />;
    default:
      return <Navigate to="/login" />;
  }
};
```

### Redirection Logic

| User Role | Redirect To | Dashboard Type |
|-----------|-------------|----------------|
| **admin** | `/admin` | Full access admin dashboard |
| **manager** | `/admin` | Limited access admin dashboard |
| **technician** | `/technician` | Technician dashboard |
| **user** | `/dashboard` | User dashboard |
| **null/unknown** | `/login` | Login page |

**Usage:**
```javascript
<Route path="/" element={<DashboardRouter />} />
```

When users visit the root URL (`/`), they're automatically sent to their dashboard.

---

## 📍 Route Definitions

### Public Routes (No Protection)

#### Login Route
```javascript
// App.jsx:50
<Route path="/login" element={<Login />} />
```
**Access:** Anyone (logged in or not)  
**Purpose:** User authentication  
**Redirect:** After login → role-specific dashboard

#### Register Route
```javascript
// App.jsx:51
<Route path="/register" element={<Register />} />
```
**Access:** Anyone (logged in or not)  
**Purpose:** New user registration  
**Note:** All new users created with 'user' role

---

### Protected Routes (PrivateRoute wrapper)

#### User Dashboard Route
```javascript
// App.jsx:54-61
<Route
  path="/dashboard"
  element={
    <PrivateRoute allowedRoles={['user']}>
      <UserDashboard />
    </PrivateRoute>
  }
/>
```
**Allowed Roles:** `['user']`  
**Access Control:**
- ✅ Users: Full access
- ❌ Technicians: Redirected to `/login`
- ❌ Managers: Redirected to `/login`
- ❌ Administrators: Redirected to `/login`

**Features:**
- Create tickets
- View own tickets
- Track ticket status
- Add comments

---

#### Technician Dashboard Route
```javascript
// App.jsx:63-70
<Route
  path="/technician"
  element={
    <PrivateRoute allowedRoles={['technician']}>
      <TechnicianDashboard />
    </PrivateRoute>
  }
/>
```
**Allowed Roles:** `['technician']`  
**Access Control:**
- ❌ Users: Redirected to `/login`
- ✅ Technicians: Full access
- ❌ Managers: Redirected to `/login`
- ❌ Administrators: Redirected to `/login`

**Features:**
- View assigned tickets
- View unassigned tickets
- Self-assign tickets
- Update ticket status
- Change priority

---

#### Admin Dashboard Route
```javascript
// App.jsx:72-79
<Route
  path="/admin"
  element={
    <PrivateRoute allowedRoles={['admin', 'manager']}>
      <AdminDashboard />
    </PrivateRoute>
  }
/>
```
**Allowed Roles:** `['admin', 'manager']`  
**Access Control:**
- ❌ Users: Redirected to `/login`
- ❌ Technicians: Redirected to `/login`
- ✅ Managers: Full access (limited controls)
- ✅ Administrators: Full access (full controls)

**Features:**
- **Both Admin & Manager:**
  - View all tickets
  - Edit tickets
  - Delete tickets
  - Assign tickets
  - View all users
  - Create users (manager limited to User/Tech)
  - Edit user info
  - View statistics

- **Admin Only:**
  - Delete users
  - Change user roles
  - Create admin/manager accounts

**UI Differences:**
- Administrator: Delete buttons visible, role dropdown editable
- Manager: Delete buttons hidden, role field read-only

---

#### Profile Route
```javascript
// App.jsx:81-88
<Route
  path="/profile"
  element={
    <PrivateRoute allowedRoles={['user', 'technician', 'manager', 'admin']}>
      <Profile />
    </PrivateRoute>
  }
/>
```
**Allowed Roles:** `['user', 'technician', 'manager', 'admin']`  
**Access Control:**
- ✅ Users: Full access
- ✅ Technicians: Full access
- ✅ Managers: Full access
- ✅ Administrators: Full access
- ❌ Not logged in: Redirected to `/login`

**Features:**
- View profile information
- Edit full name
- Edit email
- Change password
- View account creation date
- See current role

---

## 🔄 Navigation Flow Examples

### Example 1: Administrator Visits Root URL
```
1. User visits: http://localhost:3000/
2. DashboardRouter checks user.role → 'admin'
3. Redirect to: /admin
4. PrivateRoute checks: allowedRoles.includes('admin') → true
5. Render: <AdminDashboard /> with full controls
```

### Example 2: Manager Visits Root URL
```
1. User visits: http://localhost:3000/
2. DashboardRouter checks user.role → 'manager'
3. Redirect to: /admin
4. PrivateRoute checks: allowedRoles.includes('manager') → true
5. Render: <AdminDashboard /> with limited controls
```

### Example 3: User Tries to Access Admin Dashboard
```
1. User visits: http://localhost:3000/admin
2. PrivateRoute checks user.role → 'user'
3. Check: allowedRoles.includes('user') → ['admin', 'manager'].includes('user') → false
4. Redirect to: /login
5. User cannot access admin dashboard
```

### Example 4: Unauthenticated User Visits Protected Route
```
1. User visits: http://localhost:3000/dashboard
2. PrivateRoute checks user → null
3. Redirect to: /login
4. After login, can manually navigate to /dashboard
```

### Example 5: Technician Logs In
```
1. Technician logs in successfully
2. Login.jsx checks user.role → 'technician'
3. navigate('/technician')
4. PrivateRoute checks: allowedRoles.includes('technician') → true
5. Render: <TechnicianDashboard />
```

---

## 🛡️ Security Features

### 1. Double Protection
```
Frontend Route Protection:
├── PrivateRoute component (blocks UI access)
└── Backend API Protection (blocks data access)
```

**Why Both?**
- Frontend: Better UX (instant redirect)
- Backend: Real security (cannot be bypassed)

### 2. Role Validation
```javascript
// Every protected route checks:
1. Is user authenticated? (user !== null)
2. Does user have required role? (allowedRoles.includes(user.role))
```

### 3. Automatic Redirection
```
Unauthorized access → /login
No endless loops or blank screens
```

### 4. AuthProvider Wrapping
```javascript
// App.jsx:47-91
<AuthProvider>
  <Router>
    {/* All routes have access to auth context */}
  </Router>
</AuthProvider>
```

**Benefits:**
- Global user state
- All components can access `useAuth()`
- Consistent authentication across app

---

## 📊 Complete Route Matrix

| Route | Public | User | Technician | Manager | Admin |
|-------|--------|------|------------|---------|-------|
| **/** (root) | → /login | → /dashboard | → /technician | → /admin | → /admin |
| **/login** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **/register** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **/dashboard** | ❌ | ✅ | ❌ | ❌ | ❌ |
| **/technician** | ❌ | ❌ | ✅ | ❌ | ❌ |
| **/admin** | ❌ | ❌ | ❌ | ✅ | ✅ |
| **/profile** | ❌ | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- ✅ = Can access
- ❌ = Redirected to /login
- → = Auto-redirected to

---

## 🔄 Navigation Methods

### 1. Programmatic Navigation (Login)
```javascript
// Login.jsx:23-36
switch (user.role) {
  case 'admin':
  case 'manager':
    navigate('/admin');
    break;
  // ...
}
```

### 2. Link Components
```javascript
// In any component
import { Link } from 'react-router-dom';

<Link to="/profile">My Profile</Link>
```

### 3. Navigate Component
```javascript
// Declarative redirect
<Navigate to="/login" />
```

### 4. useNavigate Hook
```javascript
// In component
const navigate = useNavigate();
navigate('/dashboard');
```

---

## 🧪 Testing Routing System

### Test 1: Unauthenticated Access
```bash
1. Open browser in incognito mode
2. Visit http://localhost:3000/admin
✅ Expected: Redirected to /login
```

### Test 2: Wrong Role Access
```bash
1. Login as user (user/user123)
2. Manually type /admin in URL
✅ Expected: Redirected to /login
```

### Test 3: Root URL Redirect
```bash
1. Login as admin
2. Visit http://localhost:3000/
✅ Expected: Auto-redirected to /admin
```

### Test 4: Profile Access (All Roles)
```bash
1. Login as any role
2. Click profile button
3. Visit /profile
✅ Expected: Profile page loads
```

### Test 5: Direct Dashboard Access
```bash
1. Login as user
2. Visit http://localhost:3000/dashboard
✅ Expected: UserDashboard loads
```

### Test 6: Back Button After Logout
```bash
1. Login successfully
2. Visit /admin
3. Logout
4. Click browser back button
✅ Expected: Redirected to /login (not /admin)
```

---

## 🎯 Best Practices Implemented

### 1. Centralized Route Definitions
```javascript
// All routes in one place (App.jsx)
// Easy to maintain and update
```

### 2. Reusable PrivateRoute Component
```javascript
// Don't repeat protection logic
// Single source of truth
```

### 3. Role-Based Redirection
```javascript
// Users land on their relevant dashboard
// No manual navigation needed
```

### 4. Default Fallback
```javascript
// Unknown roles → /login
// Prevents blank screens
```

### 5. Consistent Auth Context
```javascript
// All components use same user state
// No prop drilling
```

---

## 🔧 Configuration

### Adding New Protected Route
```javascript
// 1. Create new component
import NewDashboard from './pages/NewDashboard';

// 2. Add route with protection
<Route
  path="/new-dashboard"
  element={
    <PrivateRoute allowedRoles={['newrole']}>
      <NewDashboard />
    </PrivateRoute>
  }
/>

// 3. Update DashboardRouter if needed
case 'newrole':
  return <Navigate to="/new-dashboard" />;
```

### Adding Public Route
```javascript
// Just add without PrivateRoute wrapper
<Route path="/public-page" element={<PublicPage />} />
```

---

## 📝 Route Props Summary

### PrivateRoute Props
| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `children` | React.Node | ✅ | Component to render if authorized |
| `allowedRoles` | Array<string> | ❌ | List of roles that can access |

**Examples:**
```javascript
// Single role
<PrivateRoute allowedRoles={['user']}>

// Multiple roles
<PrivateRoute allowedRoles={['admin', 'manager']}>

// All authenticated (no role check)
<PrivateRoute>
```

---

## 🚨 Common Issues & Solutions

### Issue: "Infinite redirect loop"
**Cause:** User role doesn't match any route
**Solution:** Add default case in DashboardRouter
```javascript
default:
  return <Navigate to="/login" />;
```

### Issue: "Can access route I shouldn't"
**Cause:** Missing PrivateRoute wrapper
**Solution:** Wrap route in PrivateRoute with allowedRoles

### Issue: "Blank page after login"
**Cause:** No redirect logic after successful login
**Solution:** Check Login.jsx has role-based navigation

### Issue: "User state lost on refresh"
**Cause:** localStorage not being read
**Solution:** Check AuthContext useEffect restores from localStorage

---

## ✅ Implementation Checklist

- [✅] AuthProvider wraps entire app
- [✅] PrivateRoute checks authentication
- [✅] PrivateRoute checks role authorization
- [✅] DashboardRouter handles root redirect
- [✅] All sensitive routes protected
- [✅] Public routes accessible to all
- [✅] Login has role-based redirection
- [✅] Profile accessible to all authenticated
- [✅] Admin/Manager share same route
- [✅] Default fallback to login

---

## 📊 Flow Diagram

```
┌──────────────────────────────────────────────┐
│         User Navigates to Route              │
└──────────────────────────────────────────────┘
                    │
                    ▼
         ┌──────────────────────┐
         │   Is Route Public?   │
         └──────────────────────┘
              │           │
            YES          NO
              │           │
              ▼           ▼
      ┌──────────┐  ┌──────────────┐
      │  Render  │  │ PrivateRoute │
      │   Page   │  │    Check     │
      └──────────┘  └──────────────┘
                            │
                    ┌───────┴───────┐
                    │               │
              Is Authenticated?   NO → /login
                    │
                   YES
                    │
                    ▼
            ┌──────────────────┐
            │  Has Required    │
            │     Role?        │
            └──────────────────┘
                    │
              ┌─────┴─────┐
              │           │
             YES         NO
              │           │
              ▼           ▼
        ┌─────────┐  ┌─────────┐
        │ Render  │  │→ /login │
        │  Page   │  └─────────┘
        └─────────┘
```

---

**Status:** ✅ Complete routing system with role-based access control  
**Security:** Frontend + Backend double protection  
**UX:** Automatic role-based redirection  
**Maintainability:** Centralized, reusable components
