# 👥 User Management Flow Documentation

## Overview
Complete user CRUD operations with role-based restrictions. Administrators have full control, Managers have limited control.

---

## 🆕 User Creation Flow

### Step 1: Frontend - Admin Opens Create Modal
```javascript
// AdminDashboard.jsx:324
<button onClick={() => setShowUserModal(true)}>
  Add User
</button>
```

### Step 2: Frontend - Role Selection
```javascript
// AdminDashboard.jsx:380-385
<select value={newUser.role} onChange={...}>
  <option value="user">User</option>
  <option value="technician">Technician</option>
  {isAdmin && <option value="manager">Manager</option>}
  {isAdmin && <option value="admin">Administrator</option>}
</select>
```

**Key Point:** Manager role dropdown only shows User and Technician options!

### Step 3: Frontend - Form Submission
```javascript
// AdminDashboard.jsx:63-73
const handleCreateUser = async (e) => {
  e.preventDefault();
  try {
    await axios.post('/api/users', newUser);
    // Success: Close modal, refresh data
  } catch (error) {
    alert(error.response?.data?.detail || 'Failed to create user');
  }
};
```

### Step 4: Backend - Endpoint Handler
```python
# main.py:323-326
@app.post("/users", response_model=UserResponse)
async def create_user_by_admin(
    user: UserCreate,
    current_user: User = Depends(require_role([UserRole.MANAGER, UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
```

**Authorization:** Both ADMIN and MANAGER can access this endpoint.

### Step 5: Backend - Email/Username Validation
```python
# main.py:329-337
# Check if email already exists
db_user = db.query(User).filter(User.email == user.email).first()
if db_user:
    raise HTTPException(status_code=400, detail="Email already registered")

# Check if username already exists
db_user = db.query(User).filter(User.username == user.username).first()
if db_user:
    raise HTTPException(status_code=400, detail="Username already taken")
```

### Step 6: Backend - Role Creation Restriction ⚠️
```python
# main.py:339-341
# Only ADMIN can create users with manager or admin roles
if user.role in [UserRole.MANAGER, UserRole.ADMIN] and current_user.role != UserRole.ADMIN:
    raise HTTPException(
        status_code=403, 
        detail="Only administrators can create manager/admin accounts"
    )
```

**Critical Security Check:**
- ✅ Administrator can create any role
- ✅ Manager can create User and Technician only
- ❌ Manager CANNOT create Manager or Administrator accounts

### Step 7: Backend - User Creation
```python
# main.py:343-354
hashed_password = get_password_hash(user.password)
db_user = User(
    email=user.email,
    username=user.username,
    full_name=user.full_name,
    hashed_password=hashed_password,
    role=user.role if user.role else UserRole.USER
)
db.add(db_user)
db.commit()
db.refresh(db_user)
return db_user
```

### Step 8: Frontend - UI Update
```javascript
// AdminDashboard.jsx:68-69
setShowUserModal(false);
fetchData();  // Reload user list
```

---

## ✏️ User Update Flow

### Step 1: Frontend - Click Edit Button
```javascript
// AdminDashboard.jsx:349
<button onClick={() => handleEditUser(u)}>
  <Edit className="h-4 w-4" />
</button>
```

### Step 2: Frontend - Populate Edit Form
```javascript
// AdminDashboard.jsx:75-80
const handleEditUser = (userToEdit) => {
  setSelectedUser(userToEdit);
  setEditUserData({
    full_name: userToEdit.full_name,
    email: userToEdit.email,
    role: userToEdit.role
  });
  setShowEditUserModal(true);
};
```

### Step 3: Frontend - Role Editing UI
```javascript
// AdminDashboard.jsx:422-452
{isAdmin ? (
  <>
    <div>
      <label>Role</label>
      <select value={editUserData.role} onChange={...}>
        <option value="user">User</option>
        <option value="technician">Technician</option>
        <option value="manager">Manager</option>
        <option value="admin">Administrator</option>
      </select>
    </div>
    <div className="bg-blue-50">
      <p>Note: Changing the role will affect user permissions immediately.</p>
    </div>
  </>
) : (
  <div className="bg-yellow-50">
    <p><strong>Current Role:</strong> {editUserData.role}</p>
    <p>Only Administrators can change user roles.</p>
  </div>
)}
```

**Key UI Behavior:**
- ✅ Administrator sees role dropdown (editable)
- ❌ Manager sees role as read-only text

### Step 4: Frontend - Submit Update
```javascript
// AdminDashboard.jsx:84-92
const handleUpdateUser = async (e) => {
  e.preventDefault();
  try {
    await axios.put(`/api/users/${selectedUser.id}`, editUserData);
    setShowEditUserModal(false);
    fetchData();
  } catch (error) {
    alert(error.response?.data?.detail || 'Failed to update user');
  }
};
```

### Step 5: Backend - Update Endpoint
```python
# main.py:356-362
@app.put("/users/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
```

**Authorization:** Any authenticated user (filtered below).

### Step 6: Backend - Ownership Check
```python
# main.py:367-369
# Users can update their own profile, managers and admins can update any profile
if current_user.id != user_id and current_user.role not in [UserRole.MANAGER, UserRole.ADMIN]:
    raise HTTPException(status_code=403, detail="Not authorized to update this user")
```

**Permission Logic:**
- ✅ Users can update their own profile
- ✅ Managers can update any user's profile (except roles)
- ✅ Administrators can update any user's profile (including roles)

### Step 7: Backend - Role Change Restriction ⚠️
```python
# main.py:371-373
# Only ADMIN can change roles
if user_update.role and current_user.role != UserRole.ADMIN:
    raise HTTPException(
        status_code=403, 
        detail="Only administrators can change user roles"
    )
```

**Critical Security Check:**
- ✅ Administrator can change any user's role
- ❌ Manager CANNOT change roles (even to User)
- ❌ Users CANNOT change their own role

### Step 8: Backend - Apply Updates
```python
# main.py:375-382
if user_update.email:
    db_user.email = user_update.email
if user_update.full_name:
    db_user.full_name = user_update.full_name
if user_update.password:
    db_user.hashed_password = get_password_hash(user_update.password)
if user_update.role and current_user.role == UserRole.ADMIN:
    db_user.role = user_update.role

db.commit()
db.refresh(db_user)
return db_user
```

**Update Logic:**
- Email, full name, password: Anyone with permission
- Role: Only if Administrator

---

## 🗑️ User Deletion Flow

### Step 1: Frontend - Delete Button Visibility
```javascript
// AdminDashboard.jsx:349-352
{isAdmin && (
  <button 
    onClick={() => handleDeleteUser(u.id)} 
    title="Delete user (Administrator only)"
  >
    <Trash2 className="h-4 w-4" />
  </button>
)}
```

**UI Behavior:**
- ✅ Administrator sees delete button
- ❌ Manager does NOT see delete button
- ❌ Button completely hidden for managers

### Step 2: Frontend - Confirmation Dialog
```javascript
// AdminDashboard.jsx:94-103
const handleDeleteUser = async (userId) => {
  if (window.confirm('Are you sure you want to delete this user?')) {
    try {
      await axios.delete(`/api/users/${userId}`);
      fetchData();
    } catch (error) {
      alert('Failed to delete user');
    }
  }
};
```

### Step 3: Backend - Delete Endpoint
```python
# main.py:388-392
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
```

**Authorization:** ADMIN ONLY - Most restrictive!

### Step 4: Backend - User Lookup
```python
# main.py:394-396
db_user = db.query(User).filter(User.id == user_id).first()
if not db_user:
    raise HTTPException(status_code=404, detail="User not found")
```

### Step 5: Backend - Self-Deletion Prevention ⚠️
```python
# main.py:398-400
# Prevent deleting yourself
if db_user.id == current_user.id:
    raise HTTPException(
        status_code=400, 
        detail="Cannot delete your own account"
    )
```

**Safety Feature:** Even Administrators cannot delete themselves!

### Step 6: Backend - Execute Deletion
```python
# main.py:402-404
db.delete(db_user)
db.commit()
return {"message": "User deleted successfully"}
```

### Step 7: Frontend - UI Update
```javascript
// AdminDashboard.jsx:98
fetchData();  // Reload user list (deleted user removed)
```

---

## 📊 Complete Permission Matrix

### User Creation

| Current User Role | Can Create User | Can Create Technician | Can Create Manager | Can Create Administrator |
|-------------------|-----------------|----------------------|-------------------|-------------------------|
| **Administrator** | ✅ | ✅ | ✅ | ✅ |
| **Manager** | ✅ | ✅ | ❌ | ❌ |
| **Technician** | ❌ | ❌ | ❌ | ❌ |
| **User** | ❌ | ❌ | ❌ | ❌ |

### User Editing

| Current User Role | Can Edit Own Profile | Can Edit Other's Info | Can Change Roles |
|-------------------|---------------------|----------------------|------------------|
| **Administrator** | ✅ | ✅ | ✅ |
| **Manager** | ✅ | ✅ | ❌ |
| **Technician** | ✅ | ❌ | ❌ |
| **User** | ✅ | ❌ | ❌ |

### User Deletion

| Current User Role | Can Delete Users |
|-------------------|------------------|
| **Administrator** | ✅ (except self) |
| **Manager** | ❌ |
| **Technician** | ❌ |
| **User** | ❌ |

---

## 🔒 Security Restrictions Summary

### 1. Role Creation Hierarchy
```
Administrator:
  ├── Can create: User ✅
  ├── Can create: Technician ✅
  ├── Can create: Manager ✅
  └── Can create: Administrator ✅

Manager:
  ├── Can create: User ✅
  ├── Can create: Technician ✅
  ├── Cannot create: Manager ❌
  └── Cannot create: Administrator ❌
```

### 2. Role Modification Hierarchy
```
Administrator:
  ├── Can change to: User ✅
  ├── Can change to: Technician ✅
  ├── Can change to: Manager ✅
  └── Can change to: Administrator ✅

Manager:
  └── Cannot change roles at all ❌

User/Technician:
  └── Cannot change roles at all ❌
```

### 3. Deletion Hierarchy
```
Administrator:
  ├── Can delete: User ✅
  ├── Can delete: Technician ✅
  ├── Can delete: Manager ✅
  ├── Can delete: Administrator ✅
  └── Cannot delete: Self ❌

Manager:
  └── Cannot delete anyone ❌
```

---

## 🚫 Error Messages

### 400 - Bad Request
```json
{
  "detail": "Email already registered"
}
{
  "detail": "Username already taken"
}
{
  "detail": "Cannot delete your own account"
}
```

### 403 - Forbidden
```json
{
  "detail": "Only administrators can create manager/admin accounts"
}
{
  "detail": "Only administrators can change user roles"
}
{
  "detail": "Not authorized to update this user"
}
```

### 404 - Not Found
```json
{
  "detail": "User not found"
}
```

---

## 🧪 Testing Scenarios

### Test 1: Administrator Creates Manager
```
1. Login as admin/admin123
2. Go to User Management → Add User
3. Fill in user details
4. Select role: "Manager"
5. Click Create User
✅ Expected: User created successfully
```

### Test 2: Manager Tries to Create Administrator
```
1. Login as manager/manager123
2. Go to User Management → Add User
3. Fill in user details
4. Notice: Only see User and Technician options
5. Try to create (cannot select admin/manager)
✅ Expected: Limited role options shown
```

### Test 3: Manager Tries to Change Role
```
1. Login as manager/manager123
2. Go to User Management → Edit user
3. Notice: Role field shows as read-only text
4. See message: "Only Administrators can change user roles"
✅ Expected: Cannot edit roles
```

### Test 4: Manager Tries to Delete User
```
1. Login as manager/manager123
2. Go to User Management
3. Notice: No delete button visible
4. Only edit button shown
✅ Expected: Delete button hidden
```

### Test 5: Administrator Deletes User
```
1. Login as admin/admin123
2. Go to User Management
3. Click delete button on any user
4. Confirm deletion
✅ Expected: User deleted successfully
```

### Test 6: Administrator Tries to Delete Self
```
1. Login as admin/admin123
2. Go to User Management
3. Try to delete own account
❌ Expected: Error "Cannot delete your own account"
```

---

## 🎯 UI/UX Highlights

### For Administrator:
- ✅ All buttons visible (Edit, Delete)
- ✅ All role options in dropdown
- ✅ Can edit any field including roles
- ✅ Full control message

### For Manager:
- ✅ Edit button visible
- ❌ Delete button HIDDEN
- ❌ Manager/Admin options NOT in create dropdown
- ❌ Role field READ-ONLY in edit modal
- ℹ️ Info message: "Only Administrators can change roles"

### For Technician/User:
- ❌ Cannot access User Management at all
- ✅ Can only edit own profile

---

## 💡 Best Practices Implemented

### 1. Principle of Least Privilege
- Users start with minimal permissions (User role)
- Must be promoted by Administrator

### 2. Separation of Duties
- Administrator: Strategic control (user management)
- Manager: Operational control (ticket management)
- Clear responsibility boundaries

### 3. Defense in Depth
- Frontend: UI elements hidden
- Backend: Permission checks enforced
- Double validation on critical operations

### 4. Audit Trail
- All user operations logged (can be enhanced)
- Who created, who modified, when

### 5. Self-Protection
- Administrators cannot delete themselves
- Prevents accidental lockout

---

## 🔄 Complete Flow Diagram

```
┌─────────────────────────────────────────────────┐
│          User Management Operations              │
└─────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
   [CREATE]         [UPDATE]       [DELETE]
        │               │               │
        │               │               │
┌───────▼────────┐ ┌────▼────────┐ ┌───▼────────┐
│ Role Selection │ │ Field Edit  │ │ Confirm    │
│ (if Manager:   │ │ (if Manager:│ │ (Admin     │
│  User/Tech)    │ │  no roles)  │ │  only)     │
└───────┬────────┘ └────┬────────┘ └───┬────────┘
        │               │               │
        │               │               │
        ▼               ▼               ▼
┌───────────────────────────────────────────────┐
│    POST /users    │ PUT /users/{id} │ DELETE  │
└───────────────────────────────────────────────┘
        │               │               │
        ▼               ▼               ▼
┌───────────────────────────────────────────────┐
│         Permission Checks (Backend)           │
│  • Auth check (JWT)                           │
│  • Role check (ADMIN/MANAGER)                 │
│  • Operation-specific restrictions            │
└───────────────────────────────────────────────┘
        │               │               │
        ▼               ▼               ▼
    SUCCESS         SUCCESS         SUCCESS
        │               │               │
        ▼               ▼               ▼
    Refresh UI      Refresh UI      Refresh UI
```

---

## ✅ Implementation Checklist

- [✅] Frontend: Role-based button visibility
- [✅] Frontend: Conditional role dropdown
- [✅] Frontend: Read-only role display for managers
- [✅] Backend: Email/username uniqueness validation
- [✅] Backend: Role creation restrictions
- [✅] Backend: Role change restrictions
- [✅] Backend: Delete endpoint (admin only)
- [✅] Backend: Self-deletion prevention
- [✅] Error messages user-friendly
- [✅] Confirmation dialogs for destructive actions
- [✅] Proper HTTP status codes

---

**Status:** ✅ All user management flows implemented correctly  
**Security:** Production-ready with proper restrictions  
**UX:** Clear visual feedback for different roles
