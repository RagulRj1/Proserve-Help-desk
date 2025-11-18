# 🔐 Authentication & Authorization Flow

## Overview
Complete JWT-based authentication with role-based access control for 4 user types: Administrator, Manager, Technician, and User.

---

## 🔑 Authentication Flow

### Step 1: Login Request
```
POST /token
Body: username, password (form data)
```

### Step 2: User Verification
```python
# main.py:256
authenticate_user(db, username, password)
→ Lookup user in database
→ Verify password with bcrypt
→ Return user or None
```

### Step 3: JWT Token Generation
```python
# main.py:263
create_access_token(data={"sub": user.username})
→ Create JWT with username
→ Set expiration (30 minutes)
→ Return access token
```

### Step 4: Token Storage
```javascript
// Frontend: AuthContext.jsx
localStorage.setItem('token', response.data.access_token)
localStorage.setItem('user', JSON.stringify(userData))
```

---

## 🛡️ Authorization Flow

### Step 1: Token Extraction
```python
# main.py:225
token: str = Depends(oauth2_scheme)
→ Extract from Authorization header
→ Format: "Bearer <token>"
```

### Step 2: Token Validation
```python
# main.py:225-242
async def get_current_user(token, db):
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    username = payload.get("sub")
    user = db.query(User).filter(User.username == username).first()
    
    if user is None:
        raise HTTPException(401, "Invalid credentials")
    
    return user
```

### Step 3: Role-Based Access Control
```python
# main.py:244-252
def require_role(allowed_roles: List[UserRole]):
    def role_checker(current_user: User = Depends(get_current_user)):
        if current_user.role not in allowed_roles:
            raise HTTPException(403, "Not enough permissions")
        return current_user
    return role_checker
```

---

## 📊 Endpoint Protection Matrix

### User Management Endpoints

| Endpoint | Method | Required Role(s) | Purpose |
|----------|--------|------------------|---------|
| `/users` | GET | ADMIN, MANAGER | List all users |
| `/users` | POST | ADMIN, MANAGER | Create new user |
| `/users/{id}` | PUT | Any (self) or ADMIN, MANAGER | Update user info |
| `/users/{id}` | DELETE | **ADMIN ONLY** | Delete user ⚠️ |
| `/users/me` | GET | Any authenticated | Get own profile |
| `/users/technicians` | GET | ADMIN, MANAGER, TECH | List technicians |

### Ticket Management Endpoints

| Endpoint | Method | Required Role(s) | Purpose |
|----------|--------|------------------|---------|
| `/tickets` | GET | Any authenticated | View tickets (role-filtered) |
| `/tickets` | POST | Any authenticated | Create ticket |
| `/tickets/{id}` | GET | Any authenticated | View ticket details |
| `/tickets/{id}` | PUT | Any authenticated | Update ticket |
| `/tickets/{id}` | DELETE | ADMIN, MANAGER | Delete ticket |

### Statistics Endpoints

| Endpoint | Method | Required Role(s) | Purpose |
|----------|--------|------------------|---------|
| `/stats/dashboard` | GET | Any authenticated | Get dashboard stats (role-filtered) |

---

## 🎯 Role-Based Data Filtering

### Administrator & Manager
```python
# main.py:430
if current_user.role in [UserRole.ADMIN, UserRole.MANAGER]:
    tickets = db.query(Ticket).all()  # See all tickets
    
# main.py:546
if current_user.role in [UserRole.ADMIN, UserRole.MANAGER]:
    # Get all statistics
    total_tickets = db.query(Ticket).count()
    total_users = db.query(User).count()
```

### Technician
```python
# main.py:432
elif current_user.role == UserRole.TECHNICIAN:
    tickets = db.query(Ticket).filter(
        (Ticket.assigned_to == current_user.id) | 
        (Ticket.assigned_to == None)
    ).all()  # See assigned + unassigned tickets
```

### User
```python
# main.py:436
else:  # UserRole.USER
    tickets = db.query(Ticket).filter(
        Ticket.created_by == current_user.id
    ).all()  # See only own tickets
```

---

## 🔒 Special Permission Rules

### 1. User Deletion (ADMIN ONLY)
```python
# main.py:391
current_user: User = Depends(require_role([UserRole.ADMIN]))

# Why? Critical operation that permanently removes data
# Manager cannot delete users - safety measure
```

### 2. Role Changes (ADMIN ONLY)
```python
# main.py:372
if user_update.role and current_user.role != UserRole.ADMIN:
    raise HTTPException(403, "Only administrators can change user roles")

# Why? Prevents privilege escalation
# Manager cannot promote themselves or others
```

### 3. Creating Admin/Manager Accounts (ADMIN ONLY)
```python
# main.py:340
if user.role in [UserRole.MANAGER, UserRole.ADMIN] and current_user.role != UserRole.ADMIN:
    raise HTTPException(403, "Only administrators can create manager/admin accounts")

# Why? Prevents unauthorized admin creation
# Manager can only create User and Technician accounts
```

### 4. Ticket Assignment (ADMIN, MANAGER, TECH)
```python
# main.py:483
if ticket_update.assigned_to is not None:
    if current_user.role in [UserRole.ADMIN, UserRole.MANAGER, UserRole.TECHNICIAN]:
        ticket.assigned_to = ticket_update.assigned_to

# Why? All support staff can assign tickets
# Users cannot assign tickets to others
```

---

## 🚫 Error Responses

### 401 Unauthorized
**Triggered when:**
- No token provided
- Invalid token
- Expired token
- User not found

```json
{
  "detail": "Could not validate credentials"
}
```

### 403 Forbidden
**Triggered when:**
- Valid token but insufficient role
- User trying to access another user's data
- Manager trying to delete users
- Manager trying to change roles

```json
{
  "detail": "Not enough permissions"
}
```

### 404 Not Found
**Triggered when:**
- Resource doesn't exist
- Ticket not found
- User not found

```json
{
  "detail": "Ticket not found"
}
```

---

## 🔐 Security Features

### 1. Password Hashing
```python
# main.py:26
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Passwords are NEVER stored in plain text
# Uses bcrypt with automatic salt generation
```

### 2. JWT Tokens
```python
# main.py:18-19
SECRET_KEY = "your-secret-key-here"  # Change in production!
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Tokens expire after 30 minutes
# Must re-authenticate after expiration
```

### 3. Self-Protection
```python
# main.py:399
if db_user.id == current_user.id:
    raise HTTPException(400, "Cannot delete your own account")

# Prevents accidental self-deletion
# Administrators cannot delete themselves
```

### 4. Role Validation on Updates
```python
# main.py:368
if current_user.id != user_id and current_user.role not in [UserRole.MANAGER, UserRole.ADMIN]:
    raise HTTPException(403, "Not authorized to update this user")

# Users can update own profile
# Only admins/managers can update others
```

---

## 📝 Code Examples

### Protecting an Endpoint (Admin Only)
```python
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
    # Only administrators can access this endpoint
    # Returns 403 for any other role
```

### Protecting an Endpoint (Admin + Manager)
```python
@app.get("/users")
async def get_users(
    current_user: User = Depends(require_role([UserRole.ADMIN, UserRole.MANAGER])),
    db: Session = Depends(get_db)
):
    # Both administrators and managers can access
    # Returns 403 for technicians and users
```

### No Role Restriction (Any Authenticated User)
```python
@app.get("/tickets")
async def get_tickets(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Any authenticated user can access
    # Data is filtered based on role inside the function
```

---

## 🧪 Testing Authentication

### Test 1: Login Flow
```bash
# Request
POST http://localhost:8000/token
Content-Type: application/x-www-form-urlencoded

username=admin&password=admin123

# Response
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Test 2: Protected Endpoint
```bash
# Request
GET http://localhost:8000/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Response (if admin/manager)
[
  {
    "id": 1,
    "username": "admin",
    "email": "admin@helpdesk.com",
    "role": "admin",
    ...
  }
]

# Response (if technician/user)
{
  "detail": "Not enough permissions"
}
```

### Test 3: Role Violation
```bash
# Login as manager
POST /token
username=manager&password=manager123

# Try to delete user (should fail)
DELETE /users/5
Authorization: Bearer <manager_token>

# Response
{
  "detail": "Not enough permissions"  # 403 Forbidden
}
```

---

## 🎯 Key Differences: Administrator vs Manager

| Operation | Administrator | Manager | Why Different? |
|-----------|---------------|---------|----------------|
| **Delete Users** | ✅ | ❌ | Critical - prevents accidental data loss |
| **Change Roles** | ✅ | ❌ | Security - prevents privilege escalation |
| **Create Admins** | ✅ | ❌ | Security - prevents unauthorized admin creation |
| **View All Tickets** | ✅ | ✅ | Both need ticket visibility |
| **Edit Tickets** | ✅ | ✅ | Both manage support operations |
| **Delete Tickets** | ✅ | ✅ | Both can clean up tickets |
| **Assign Tickets** | ✅ | ✅ | Both distribute workload |
| **View Statistics** | ✅ | ✅ | Both need metrics |
| **Create Users** | ✅ | ✅ (User/Tech only) | Manager has limited creation |

---

## 🔧 Frontend Implementation

### Storing Token
```javascript
// AuthContext.jsx
const login = async (credentials) => {
  const response = await axios.post('/api/token', credentials);
  localStorage.setItem('token', response.data.access_token);
  
  // Add token to all future requests
  axios.defaults.headers.common['Authorization'] = 
    `Bearer ${response.data.access_token}`;
};
```

### Role-Based UI
```javascript
// AdminDashboard.jsx
const isAdmin = user?.role === 'admin';

{isAdmin && (
  <button onClick={deleteUser}>Delete</button>
)}
{!isAdmin && (
  <p>Only administrators can delete users</p>
)}
```

### Protected Routes
```javascript
// App.jsx
<Route path="/admin" element={
  <PrivateRoute allowedRoles={['admin', 'manager']}>
    <AdminDashboard />
  </PrivateRoute>
} />
```

---

## ✅ Security Best Practices

1. **Change SECRET_KEY in production**
   ```python
   SECRET_KEY = os.getenv("SECRET_KEY")  # Use environment variable
   ```

2. **Use HTTPS in production**
   - JWT tokens should never be sent over HTTP
   - Use SSL/TLS certificates

3. **Implement token refresh**
   - Current: 30-minute expiration
   - Consider: Refresh token mechanism

4. **Rate limiting**
   - Prevent brute force attacks on /token endpoint
   - Use tools like slowapi

5. **Audit logging**
   - Log all administrative actions
   - Track user deletions and role changes

6. **Strong passwords**
   - Enforce password complexity
   - Implement password strength checker

---

## 📞 Troubleshooting

### "Could not validate credentials"
- Token expired (30 minutes)
- Token malformed
- User deleted after token issued
- **Fix:** Re-login to get new token

### "Not enough permissions"
- Valid token but wrong role
- Trying to access admin-only endpoint as manager
- **Fix:** Use correct account or contact administrator

### "Cannot delete your own account"
- Safety feature working correctly
- Administrators cannot self-delete
- **Fix:** Use another admin account

---

**Status:** ✅ All authentication and authorization working correctly  
**Security Level:** Production-ready with recommended improvements  
**Role System:** 4-tier (Admin > Manager > Technician > User)
