# IT Help Desk System

A comprehensive IT Help Desk management system built with **Python FastAPI** backend and **React** frontend. The system supports three types of users: Regular Users, Technicians, and Admins, each with their own dedicated dashboards and functionalities.

## Features

### 🔐 Authentication & Authorization
- Secure JWT-based authentication
- Role-based access control (User, Technician, Admin)
- Separate login portals for different user types

### 👤 User Dashboard
- Submit support tickets
- View all submitted tickets
- Track ticket status in real-time
- Filter and search tickets
- View ticket statistics (Open, In Progress, Resolved)

### 🛠️ Technician Dashboard
- View assigned and unassigned tickets
- Assign tickets to self
- Update ticket status and priority
- Filter tickets by status
- View technician-specific statistics

### 👨‍💼 Admin Dashboard (Two Tiers)

**Administrator (Full Access):**
- Complete system overview
- **User management (Create, Edit, Delete users)**
- **Role management - Change any user role**
- **Create manager/admin accounts**
- Ticket management (View, Update, Delete, Reassign)
- System-wide statistics
- Full administrative control

**Manager (Limited Access):**
- User management (Create User/Technician, Edit info only)
- **Cannot delete users or change roles**
- Ticket management (View, Update, Reassign)
- System-wide statistics
- Limited administrative control

### 👤 User Profiles (All Users)
- **Personal profile page for every account**
- View and edit account information
- Change password securely
- View account creation date and role
- Update email and full name
- Accessible from all dashboards

## Tech Stack

### Backend
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **SQLite** - Database (can be easily switched to PostgreSQL/MySQL)
- **JWT** - Token-based authentication
- **Bcrypt** - Password hashing
- **Pydantic** - Data validation

### Frontend
- **React** - UI library
- **Vite** - Build tool
- **TailwindCSS** - Styling framework
- **Axios** - HTTP client
- **React Router** - Navigation
- **Lucide React** - Icon library

## Installation & Setup

### Prerequisites
- Python 3.8 or higher
- Node.js 16 or higher
- npm or yarn

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Create a virtual environment:
```bash
python -m venv venv
```

3. Activate the virtual environment:
```bash
# Windows
venv\Scripts\activate

# Linux/Mac
source venv/bin/activate
```

4. Install dependencies:
```bash
pip install -r requirements.txt
```

5. Initialize the database:
```bash
python init_db.py
```

6. Run the backend server:
```bash
python main.py
```

The backend API will be available at `http://localhost:8000`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Run the development server:
```bash
npm run dev
```

The frontend will be available at `http://localhost:3000`

## Default Login Credentials

After initializing the database, you can use these credentials:

### Administrator (Full Access)
- **Username**: `admin`
- **Password**: `admin123`
- **Access**: Full system control, can delete users and change all roles

### Manager (Limited Access)
- **Username**: `manager`
- **Password**: `manager123`
- **Access**: Can manage tickets and edit users, but cannot delete users or change roles

### Technician
- **Username**: `technician`
- **Password**: `tech123`
- **Access**: Can manage and resolve tickets

### User
- **Username**: `user`
- **Password**: `user123`
- **Access**: Can create and track support tickets

> **⚠️ Important:** Change these default passwords immediately after first login for security!

## API Documentation

Once the backend is running, visit `http://localhost:8000/docs` for interactive API documentation (Swagger UI).

## Project Structure

```
IT Help Desk/
├── backend/
│   ├── main.py              # FastAPI application
│   ├── init_db.py           # Database initialization
│   ├── requirements.txt     # Python dependencies
│   └── helpdesk.db          # SQLite database (created after init)
│
└── frontend/
    ├── src/
    │   ├── pages/
    │   │   ├── Login.jsx           # Login page
    │   │   ├── Register.jsx        # Registration page
    │   │   ├── UserDashboard.jsx   # User dashboard
    │   │   ├── TechnicianDashboard.jsx  # Technician dashboard
    │   │   └── AdminDashboard.jsx  # Admin dashboard
    │   ├── context/
    │   │   └── AuthContext.jsx     # Authentication context
    │   ├── App.jsx                 # Main app component
    │   ├── main.jsx                # Entry point
    │   └── index.css               # Global styles
    ├── package.json
    ├── vite.config.js
    └── tailwind.config.js
```

## Key Functionalities

### Ticket Management
- **Create**: Users can create support tickets with title, description, priority, and category
- **Update**: Technicians and Admins can update ticket status and priority
- **Assign**: Admins and Technicians can assign tickets
- **Track**: All users can track their tickets in real-time
- **Priority Levels**: Low, Medium, High, Urgent
- **Status Tracking**: Open → In Progress → Resolved → Closed

### User Management (Admin Only)
- **Create new users** with specific roles
- **Edit users** - Update name, email, and role
- **Role Management** - Promote/demote users between User, Technician, and Admin
- **View all system users** with complete information
- **Delete users** with confirmation
- **Permission control** - Manage access levels

### Profile Management (All Users)
- **Personal profile page** accessible from all dashboards
- **Edit profile** - Update full name and email
- **Change password** securely with confirmation
- **View account details** - Username, role, creation date
- **Self-service account management**

### Dashboard Statistics
- Real-time ticket counts by status
- User statistics
- Technician workload overview
- System-wide metrics

## Security Features

- JWT token-based authentication
- Password hashing with bcrypt
- Role-based access control
- Protected API endpoints
- CORS configuration for frontend-backend communication

## Customization

### Changing Secret Key
In `backend/main.py`, update:
```python
SECRET_KEY = "your-secret-key-change-this-in-production"
```

### Database Configuration
To use PostgreSQL or MySQL instead of SQLite, update in `backend/main.py`:
```python
SQLALCHEMY_DATABASE_URL = "postgresql://user:password@localhost/dbname"
# or
SQLALCHEMY_DATABASE_URL = "mysql://user:password@localhost/dbname"
```

### Ticket Categories
Add or modify categories in the frontend ticket creation forms and backend validation.

## Future Enhancements

- Email notifications for ticket updates
- File attachments for tickets
- Live chat support
- Ticket commenting system (already implemented in backend)
- Advanced reporting and analytics
- SLA management
- Knowledge base integration

## Troubleshooting

### Backend won't start
- Ensure all dependencies are installed: `pip install -r requirements.txt`
- Check if port 8000 is available
- Verify Python version is 3.8+

### Frontend won't start
- Delete `node_modules` and run `npm install` again
- Check if port 3000 is available
- Clear npm cache: `npm cache clean --force`

### Database errors
- Delete `helpdesk.db` and run `python init_db.py` again
- Check file permissions

## License

This project is open-source and available for educational and commercial use.

## Support

For issues and questions, please create an issue in the repository or contact the development team.

---

**Built with ❤️ using FastAPI and React**
