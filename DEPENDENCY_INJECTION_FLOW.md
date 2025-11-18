# 🔗 FastAPI Dependency Injection & Authorization Flow

## Overview
Complete FastAPI dependency injection system for authentication and role-based authorization using JWT tokens.

---

## 🎯 Complete Request Flow

```
API Request with Bearer Token
         ↓
oauth2_scheme (extract token)
         ↓
get_current_user() (validate & get user)
         ↓
require_role() (check permissions)
         ↓
Protected Endpoint (execute business logic)
```

---

## 🔐 Step-by-Step Flow

### Step 1: Client Request with Token

#### Frontend Request
```javascript
// AuthContext.jsx:39
axios.defaults.headers.common['Authorization'] = `Bearer ${access_token}`;

// All subsequent requests include this header
const response = await axios.get('/api/users');
```

#### HTTP Request Format
```http
GET /api/users HTTP/1.1
Host: localhost:8000
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### Step 2: Token Extraction (oauth2_scheme)

#### Configuration
```python
# main.py:27
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
```

#### How It Works
```python
# FastAPI automatically:
# 1. Looks for Authorization header
# 2. Validates format: "Bearer <token>"
# 3. Extracts token string
# 4. Passes to next dependency
```

**Automatic Checks:**
- ✅ Header exists
- ✅ Starts with "Bearer "
- ✅ Token is present
- ❌ If any fail → 401 Unauthorized

---

### Step 3: Token Validation & User Retrieval (get_current_user)

#### Implementation
```python
# main.py:225-242
async def get_current_user(
    token: str = Depends(oauth2_scheme),  # ← Token from Step 2
    db: Session = Depends(get_db)         # ← Database session
):
    # Prepare exception for invalid credentials
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 1. Decode JWT token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        
        # 2. Extract username from payload
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        
        token_data = TokenData(username=username)
    
    except JWTError:
        # Token is invalid, expired, or tampered
        raise credentials_exception
    
    # 3. Retrieve user from database
    user = get_user_by_username(db, username=token_data.username)
    
    if user is None:
        # User doesn't exist (maybe deleted after token issued)
        raise credentials_exception
    
    # 4. Return authenticated user with role
    return user
```

#### Detailed Breakdown

##### 3a. JWT Token Decoding
```python
# main.py:232
payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
```

**What Happens:**
1. Verify signature (prevents tampering)
2. Check expiration (`exp` claim)
3. Extract payload data
4. Return decoded data or raise JWTError

**Token Payload Structure:**
```json
{
  "sub": "admin",           // Username
  "exp": 1731342000         // Expiration timestamp
}
```

**Possible Errors:**
- `ExpiredSignatureError` - Token expired (>30 minutes)
- `InvalidSignatureError` - Token tampered with
- `DecodeError` - Invalid token format

##### 3b. User Retrieval
```python
# main.py:239
user = get_user_by_username(db, username=token_data.username)
```

**Database Query:**
```python
def get_user_by_username(db: Session, username: str):
    return db.query(User).filter(User.username == username).first()
```

**Returns User Object:**
```python
User(
    id=1,
    username="admin",
    email="admin@helpdesk.com",
    full_name="Administrator",
    role="admin",  # ← This is crucial for authorization
    hashed_password="...",
    created_at="..."
)
```

---

### Step 4: Role Permission Check (require_role)

#### Implementation
```python
# main.py:244-252
def require_role(allowed_roles: List[UserRole]):
    """
    Factory function that returns a dependency checker
    
    Args:
        allowed_roles: List of roles allowed to access the endpoint
    
    Returns:
        role_checker function that validates user's role
    """
    def role_checker(current_user: User = Depends(get_current_user)):
        # Check if user's role is in the allowed list
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions"
            )
        return current_user
    return role_checker
```

#### How It Works

##### Dependency Factory Pattern
```python
# When you write:
Depends(require_role([UserRole.ADMIN]))

# It actually does:
1. Call require_role([UserRole.ADMIN])
   → Returns role_checker function
2. Pass role_checker to Depends()
   → FastAPI will call role_checker on each request
3. role_checker gets current_user from get_current_user
4. Checks if current_user.role in [UserRole.ADMIN]
5. Returns user or raises 403
```

##### 3c. Role Permission Check
```python
# main.py:246
if current_user.role not in allowed_roles:
```

**Examples:**

**Case 1: Admin accessing admin-only endpoint**
```python
current_user.role = "admin"
allowed_roles = [UserRole.ADMIN]
"admin" in ["admin"] → True ✅
# Continue to endpoint
```

**Case 2: Manager accessing admin-only endpoint**
```python
current_user.role = "manager"
allowed_roles = [UserRole.ADMIN]
"manager" in ["admin"] → False ❌
# Raise 403 Forbidden
```

**Case 3: Manager accessing admin/manager endpoint**
```python
current_user.role = "manager"
allowed_roles = [UserRole.ADMIN, UserRole.MANAGER]
"manager" in ["admin", "manager"] → True ✅
# Continue to endpoint
```

##### 3d. Access Denied Response
```python
# main.py:247-250
raise HTTPException(
    status_code=status.HTTP_403_FORBIDDEN,
    detail="Not enough permissions"
)
```

**HTTP Response:**
```http
HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "detail": "Not enough permissions"
}
```

---

### Step 5: Protected Endpoint Execution

#### Example: Admin-Only Endpoint

##### 3e. Admin-Only Endpoint Protection
```python
# main.py:388-404
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN])),  # ← Protection here
    db: Session = Depends(get_db)
):
    """
    Only ADMIN role can access this endpoint
    
    Dependency chain:
    1. oauth2_scheme extracts token
    2. get_current_user validates token & gets user
    3. require_role checks if user.role == "admin"
    4. If all pass, this function executes
    """
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prevent self-deletion
    if db_user.id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot delete your own account")
    
    db.delete(db_user)
    db.commit()
    return {"message": "User deleted successfully"}
```

---

## 📊 Complete Dependency Chain Visualization

```
┌─────────────────────────────────────────────────────────────┐
│            API Request: DELETE /users/5                      │
│            Header: Authorization: Bearer <token>             │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 1: oauth2_scheme (FastAPI built-in)                   │
│  ──────────────────────────────────────────────────────────│
│  • Check Authorization header exists                         │
│  • Validate format: "Bearer <token>"                         │
│  • Extract token string                                      │
│                                                              │
│  Result: token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 2: get_current_user(token, db)                        │
│  ──────────────────────────────────────────────────────────│
│  A. JWT Decoding                                             │
│     • Verify signature                                       │
│     • Check expiration                                       │
│     • Extract payload: {"sub": "admin", "exp": ...}         │
│                                                              │
│  B. User Retrieval                                           │
│     • Query database: SELECT * FROM users WHERE username='admin'│
│     • Return User object with role                           │
│                                                              │
│  Result: User(id=1, username="admin", role="admin", ...)    │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 3: require_role([UserRole.ADMIN])                     │
│  ──────────────────────────────────────────────────────────│
│  • Check: current_user.role in [UserRole.ADMIN]             │
│  • "admin" in ["admin"] → True                              │
│                                                              │
│  Result: ✅ Authorization passed                            │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Step 4: delete_user() Endpoint                              │
│  ──────────────────────────────────────────────────────────│
│  • All dependencies passed                                   │
│  • Execute business logic                                    │
│  • Delete user from database                                 │
│                                                              │
│  Result: {"message": "User deleted successfully"}           │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Dependency Examples by Endpoint

### Example 1: User Deletion (Admin Only)
```python
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
    # Only administrators can reach this code
```

**Dependency Chain:**
```
token → get_current_user → require_role([ADMIN]) → endpoint
```

**Test Results:**
- Admin: ✅ Access granted
- Manager: ❌ 403 Forbidden
- Technician: ❌ 403 Forbidden
- User: ❌ 403 Forbidden

---

### Example 2: View Users (Admin + Manager)
```python
@app.get("/users", response_model=List[UserResponse])
async def get_users(
    current_user: User = Depends(require_role([UserRole.MANAGER, UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
    users = db.query(User).all()
    return users
```

**Dependency Chain:**
```
token → get_current_user → require_role([MANAGER, ADMIN]) → endpoint
```

**Test Results:**
- Admin: ✅ Access granted
- Manager: ✅ Access granted
- Technician: ❌ 403 Forbidden
- User: ❌ 403 Forbidden

---

### Example 3: Get Own Profile (Any Authenticated)
```python
@app.get("/users/me", response_model=UserResponse)
async def read_users_me(
    current_user: User = Depends(get_current_user)
):
    return current_user
```

**Dependency Chain:**
```
token → get_current_user → endpoint
```

**Note:** No `require_role` - any authenticated user allowed!

**Test Results:**
- Admin: ✅ Access granted
- Manager: ✅ Access granted
- Technician: ✅ Access granted
- User: ✅ Access granted
- Not logged in: ❌ 401 Unauthorized

---

### Example 4: Public Endpoint (No Protection)
```python
@app.post("/token", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_db)
):
    # No authentication required
    # This is the login endpoint itself!
```

**Dependency Chain:**
```
form_data → endpoint
```

**Test Results:**
- Anyone: ✅ Can attempt login

---

## 🚨 Error Responses

### 401 Unauthorized (Invalid/Missing Token)

**Triggered By:**
- No Authorization header
- Invalid token format
- Token expired
- Token signature invalid
- User doesn't exist

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer

{
  "detail": "Could not validate credentials"
}
```

---

### 403 Forbidden (Insufficient Permissions)

**Triggered By:**
- Valid token
- User authenticated
- But wrong role for endpoint

```http
HTTP/1.1 403 Forbidden

{
  "detail": "Not enough permissions"
}
```

---

## 🔒 Security Features

### 1. Layered Security
```
Layer 1: Token Extraction (oauth2_scheme)
    ↓ Validates format
Layer 2: Token Validation (get_current_user)
    ↓ Verifies signature & expiration
Layer 3: User Verification (get_current_user)
    ↓ Checks user exists
Layer 4: Role Authorization (require_role)
    ↓ Validates permissions
Layer 5: Business Logic (endpoint)
    ↓ Additional checks (e.g., self-deletion prevention)
```

### 2. Token Security
- **Signature Verification:** Prevents tampering
- **Expiration Check:** 30-minute lifetime
- **User Lookup:** Validates user still exists
- **No Plaintext Secrets:** SECRET_KEY never exposed

### 3. Role-Based Access
- **Declarative:** Clear in endpoint definition
- **Reusable:** `require_role()` used everywhere
- **Flexible:** Support multiple roles per endpoint

### 4. Automatic Documentation
FastAPI automatically documents security requirements:
```
Swagger UI shows 🔒 lock icon on protected endpoints
Shows required authentication scheme
Shows response codes (401, 403)
```

---

## 💡 Best Practices Implemented

### 1. Dependency Injection
```python
# Good: Using dependencies
current_user: User = Depends(get_current_user)

# Bad: Manual token handling
token = request.headers.get('Authorization')
# ... manual parsing, validation, etc.
```

**Benefits:**
- ✅ Automatic error handling
- ✅ Reusable across endpoints
- ✅ Testable in isolation
- ✅ Clear in code

### 2. Factory Pattern for Roles
```python
def require_role(allowed_roles: List[UserRole]):
    def role_checker(current_user: User = Depends(get_current_user)):
        # Check logic
    return role_checker
```

**Benefits:**
- ✅ Flexible role combinations
- ✅ Single source of truth
- ✅ Easy to modify

### 3. Separation of Concerns
```
Authentication (get_current_user):
  → Who are you?

Authorization (require_role):
  → What can you do?

Business Logic (endpoint):
  → Do the thing
```

### 4. Explicit Dependencies
```python
async def delete_user(
    user_id: int,  # Path parameter
    current_user: User = Depends(require_role([UserRole.ADMIN])),  # Auth
    db: Session = Depends(get_db)  # Database
):
```

**Benefits:**
- ✅ Clear what endpoint needs
- ✅ Easy to test
- ✅ Self-documenting

---

## 🧪 Testing Dependency Chain

### Test 1: Valid Admin Token
```python
# Setup
token = create_access_token({"sub": "admin"})
headers = {"Authorization": f"Bearer {token}"}

# Request
response = client.delete("/users/5", headers=headers)

# Expected Flow:
# oauth2_scheme ✅ → get_current_user ✅ → require_role ✅ → endpoint ✅

# Result
assert response.status_code == 200
```

### Test 2: Valid Manager Token on Admin Endpoint
```python
# Setup
token = create_access_token({"sub": "manager"})
headers = {"Authorization": f"Bearer {token}"}

# Request
response = client.delete("/users/5", headers=headers)

# Expected Flow:
# oauth2_scheme ✅ → get_current_user ✅ → require_role ❌ (403)

# Result
assert response.status_code == 403
assert response.json()["detail"] == "Not enough permissions"
```

### Test 3: Expired Token
```python
# Setup
expired_token = create_access_token(
    {"sub": "admin"},
    expires_delta=timedelta(minutes=-1)  # Already expired
)
headers = {"Authorization": f"Bearer {expired_token}"}

# Request
response = client.delete("/users/5", headers=headers)

# Expected Flow:
# oauth2_scheme ✅ → get_current_user ❌ (401 - expired)

# Result
assert response.status_code == 401
```

### Test 4: No Token
```python
# No Authorization header
response = client.delete("/users/5")

# Expected Flow:
# oauth2_scheme ❌ (401 - no header)

# Result
assert response.status_code == 401
```

---

## 🔄 Complete Flow with All Checks

```python
@app.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    current_user: User = Depends(require_role([UserRole.ADMIN])),
    db: Session = Depends(get_db)
):
    """
    Complete Validation Flow:
    
    1. ✅ Has Authorization header? (oauth2_scheme)
    2. ✅ Token format valid? (oauth2_scheme)
    3. ✅ Token signature valid? (get_current_user → jwt.decode)
    4. ✅ Token not expired? (get_current_user → jwt.decode)
    5. ✅ User exists in database? (get_current_user → db query)
    6. ✅ User has admin role? (require_role)
    7. ✅ Target user exists? (endpoint logic)
    8. ✅ Not self-deletion? (endpoint logic)
    9. ✅ Delete user
    
    All checks pass → 200 OK
    Any check fails → 401/403/404/400
    """
```

---

## ✅ Summary

### Dependency Injection Benefits:
- ✅ **Automatic validation** - No manual token parsing
- ✅ **Reusable components** - Same code across endpoints
- ✅ **Clear requirements** - Easy to see what's needed
- ✅ **Better testing** - Mock dependencies easily
- ✅ **Self-documenting** - OpenAPI schema generated
- ✅ **Type safety** - FastAPI validates types

### Security Guarantees:
- ✅ **Token required** - No bypassing authentication
- ✅ **Signature verified** - No token tampering
- ✅ **Expiration checked** - Old tokens rejected
- ✅ **User validated** - Deleted users can't access
- ✅ **Role enforced** - Wrong role → 403
- ✅ **Layered protection** - Multiple security checks

---

**Status:** ✅ Complete dependency injection system  
**Security:** Production-ready with multiple validation layers  
**Architecture:** Clean, reusable, testable  
**Documentation:** Automatically generated by FastAPI
