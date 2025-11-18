# 🔐 Role-Based Access Control System

## Overview
The IT Help Desk system now has a hierarchical role-based access control with four user levels:
1. **Super Admin** - Full system access
2. **Admin** - Limited administrative access
3. **Technician** - Ticket management
4. **User** - Basic ticket submission

---

## 🎭 User Roles & Permissions

### 1. Super Admin (super_admin)
**Full System Control** - Complete access to all features

#### Permissions:
- ✅ **User Management:**
  - Create users with ANY role (User, Technician, Admin, Super Admin)
  - Edit all user information including roles
  - Delete any user account
  - View all users

- ✅ **Ticket Management:**
  - View, edit, delete all tickets
  - Assign tickets to technicians
  - Change ticket status and priority
  - Full ticket history access

- ✅ **Role Management:**
  - Promote/demote users between all roles
  - Create admin accounts
  - Manage super admin accounts

**Default Account:**
- Username: `superadmin`
- Password: `super123`

---

### 2. Admin (admin)
**Limited Administrative Access** - Can manage tickets and users but with restrictions

#### Permissions:
- ✅ **User Management:**
  - Create users with User or Technician roles ONLY
  - Edit user information (name, email) but NOT roles
  - View all users
  - ❌ CANNOT delete users
  - ❌ CANNOT create Admin or Super Admin accounts

- ✅ **Ticket Management:**
  - View all tickets
  - Edit ticket details
  - Reassign tickets to technicians
  - Change ticket status and priority
  - Full ticket history access

- ❌ **Role Management:**
  - CANNOT change user roles
  - CANNOT delete user accounts
  - CANNOT create admin accounts

**Default Account:**
- Username: `admin`
- Password: `admin123`

---

### 3. Technician (technician)
**Ticket Management** - Focused on resolving support tickets

#### Permissions:
- ✅ **Ticket Management:**
  - View assigned tickets
  - View unassigned tickets
  - Self-assign tickets
  - Update ticket status
  - Change ticket priority
  - Add comments to tickets
  - Mark tickets as resolved

- ✅ **Profile:**
  - Edit own profile
  - Change own password

- ❌ **User Management:**
  - CANNOT create, edit, or delete users
  - Can only see list of other technicians

**Default Account:**
- Username: `technician`
- Password: `tech123`

---

### 4. User (user)
**Basic Access** - Can create and track support tickets

#### Permissions:
- ✅ **Ticket Creation:**
  - Submit new support tickets
  - Add ticket details (title, description, priority, category)

- ✅ **Ticket Tracking:**
  - View own tickets
  - Track ticket status
  - Add comments to own tickets
  - View ticket history

- ✅ **Profile:**
  - Edit own profile
  - Change own password

- ❌ **Limited Access:**
  - CANNOT view other users' tickets
  - CANNOT assign tickets
  - CANNOT edit ticket status
  - CANNOT access user management

**Default Account:**
- Username: `user`
- Password: `user123`

---

## 🚫 Registration Restrictions

### Registration Page Changes:
- ❌ **Role selection removed** from registration page
- ✅ All new registrations are automatically created as **User** role
- ✅ Only admins can assign roles after account creation
- ✅ Prevents unauthorized admin account creation

### How to Promote Users:
1. **Super Admin** can promote to any role:
   - Login as super admin
   - Go to User Management
   - Click Edit on user
   - Select new role from dropdown
   - Save changes

2. **Regular Admin** CANNOT change roles:
   - Can only edit name and email
   - Must contact Super Admin for role changes

---

## 📊 Permission Matrix

| Feature | Super Admin | Admin | Technician | User |
|---------|-------------|-------|------------|------|
| **View All Tickets** | ✅ | ✅ | ✅ | ❌ |
| **Edit Any Ticket** | ✅ | ✅ | ❌ | ❌ |
| **Assign Tickets** | ✅ | ✅ | Self-assign | ❌ |
| **Delete Tickets** | ✅ | ✅ | ❌ | ❌ |
| **View All Users** | ✅ | ✅ | Technicians only | ❌ |
| **Create User** | ✅ | User/Tech only | ❌ | ❌ |
| **Edit User Info** | ✅ | ✅ (no roles) | ❌ | Own only |
| **Change User Roles** | ✅ | ❌ | ❌ | ❌ |
| **Delete Users** | ✅ | ❌ | ❌ | ❌ |
| **Create Tickets** | ✅ | ✅ | ✅ | ✅ |
| **Edit Own Profile** | ✅ | ✅ | ✅ | ✅ |

---

## 🔄 Role Hierarchy

```
┌─────────────────┐
│  Super Admin    │  ← Full access to everything
├─────────────────┤
│     Admin       │  ← Limited: No user deletion, no role changes
├─────────────────┤
│   Technician    │  ← Ticket management only
├─────────────────┤
│     User        │  ← Basic ticket submission
└─────────────────┘
```

---

## 🛡️ Security Features

### Role Protection:
- **Backend Validation:** All role changes are validated on the server
- **API Endpoints:** Protected with role-based middleware
- **Frontend Guards:** UI elements conditionally rendered based on role
- **Self-Protection:** Users cannot delete their own accounts

### API Endpoint Protection:

```python
# Super Admin Only
DELETE /users/{user_id}  # Delete user
PUT /users/{user_id}     # Change role (when role field included)

# Admin & Super Admin
GET /users               # View all users
POST /users              # Create user (with restrictions for admin)
GET /users/technicians   # View technicians
PUT /tickets/{id}        # Edit tickets

# All Authenticated
GET /users/me            # View own profile
PUT /users/{user_id}     # Edit own profile (without role changes)
```

---

## 💡 Usage Examples

### Example 1: Super Admin Creating Admin Account
```
1. Login as superadmin
2. Go to User Management → Add User
3. Fill in user details
4. Select "Admin" from role dropdown
5. Click Create User
```

### Example 2: Admin Creating Technician
```
1. Login as admin
2. Go to User Management → Add User
3. Fill in user details
4. Select "Technician" from role dropdown (Admin/Super Admin not visible)
5. Click Create User
```

### Example 3: Admin Trying to Delete User
```
1. Login as admin
2. Go to User Management
3. Notice: No delete button visible
4. Only Edit button available
5. Can edit name/email but not role
```

### Example 4: User Registration
```
1. Go to /register
2. Fill in: Email, Username, Full Name, Password
3. Role field: NOT VISIBLE
4. Submit → Account created as "User"
5. Contact admin to change role if needed
```

---

## 🔧 Implementation Details

### Backend Changes:
- Added `SUPER_ADMIN` to UserRole enum
- Updated `/register` endpoint to force USER role
- Created `/users` endpoint for admin user creation
- Modified `/users/{id}` endpoint with role-based checks
- Restricted `/users/{id}` DELETE to super_admin only

### Frontend Changes:
- Removed role dropdown from Register.jsx
- Added `isSuperAdmin` check in AdminDashboard
- Conditional rendering of delete buttons
- Conditional role editing in user modals
- Updated routing to support super_admin role
- Enhanced Profile.jsx with super_admin badge

### Database Changes:
- Added super_admin default user
- Updated init_db.py with new user account

---

## 📝 Migration Guide

### Updating Existing System:

1. **Backup Database:**
   ```bash
   cd backend
   copy helpdesk.db helpdesk.db.backup
   ```

2. **Delete Old Database:**
   ```bash
   del helpdesk.db
   ```

3. **Reinitialize with New Roles:**
   ```bash
   python init_db.py
   ```

4. **New Login Credentials:**
   - Super Admin: `superadmin` / `super123`
   - Admin: `admin` / `admin123`
   - Technician: `technician` / `tech123`
   - User: `user` / `user123`

---

## ⚠️ Important Notes

1. **Super Admin Account:**
   - Keep super admin credentials secure
   - Only one super admin recommended for small teams
   - Can create additional super admins if needed

2. **Regular Admin Limitations:**
   - Cannot escalate their own privileges
   - Cannot create admin accounts
   - Perfect for department managers

3. **Security Best Practices:**
   - Change default passwords immediately
   - Regular audit of user roles
   - Remove inactive admin accounts
   - Monitor role changes in logs

4. **Role Changes:**
   - Take effect immediately
   - User must logout/login to see new permissions
   - Previous sessions invalidated on role change

---

## 🆘 Troubleshooting

### "Only super admins can change user roles"
- Current user is regular admin
- Only super admin can change roles
- Contact super admin for role changes

### "Only super admins can create admin accounts"
- Regular admin trying to create admin user
- Use super admin account instead
- Or create as User/Technician and promote later

### Cannot see delete button
- Feature is working correctly
- Only super admin can delete users
- This is by design for safety

### Role not updating in UI
- Logout and login again
- Clear browser cache
- Check if backend updated successfully

---

## 📞 Support

For questions about the role system:
1. Check this documentation
2. Review permission matrix
3. Contact super administrator
4. Check backend logs for errors

---

**System Version:** 2.0  
**Last Updated:** [Current Date]  
**Role System:** Super Admin / Admin / Technician / User
