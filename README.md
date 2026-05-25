# Online Health System
**Amman Arab University — Database Programming Project**
Supervisor: Dr. Ala Abuthawabeh | 2025/2026

---

## Project Structure

```
OnlineHealthSystem/
├── Database/
│   └── OnlineHealthDB.sql        ← Run this first in SQL Server
└── OnlineHealth/                 ← ASP.NET MVC project
    ├── Controllers/
    │   ├── HomeController.cs
    │   ├── AccountController.cs   ← Register / Login / Logout
    │   ├── DoctorsController.cs   ← Doctor listing + filter
    │   ├── AppointmentsController.cs ← Book / My Appointments / Cancel
    │   └── AdminController.cs     ← Admin dashboard, doctors, appointments
    ├── Models/
    │   ├── Models.cs              ← All data models & view models
    │   └── DbHelper.cs            ← All database queries
    ├── Views/
    │   ├── Home/Index.cshtml      ← Landing page
    │   ├── Account/               ← Login + Register
    │   ├── Doctors/               ← Doctor listing
    │   ├── Appointments/          ← Book + My Appointments
    │   └── Admin/                 ← Dashboard, Doctors, Appointments
    ├── wwwroot/
    │   ├── css/site.css           ← Full styling
    │   └── js/site.js
    ├── Program.cs
    └── appsettings.json           ← Connection string here
```

---

## Setup Instructions

### Step 1 — Database

1. Open **SQL Server Management Studio (SSMS)**
2. Connect to your SQL Server instance
3. Open `Database/OnlineHealthDB.sql`
4. Press **F5** (Execute)
5. This creates the `OnlineHealthDB` database with tables, constraints, and sample data

### Step 2 — Connection String

Open `OnlineHealth/appsettings.json` and update if needed:

```json
"DefaultConnection": "Server=localhost;Database=OnlineHealthDB;Trusted_Connection=True;TrustServerCertificate=True;"
```

If using SQL Server authentication:
```json
"DefaultConnection": "Server=localhost;Database=OnlineHealthDB;User Id=sa;Password=YourPassword;TrustServerCertificate=True;"
```

### Step 3 — Run the App

```bash
cd OnlineHealth
dotnet run
```

Open your browser at `https://localhost:5001`

---

## Demo Accounts

| Role    | Email                 | Password    |
|---------|-----------------------|-------------|
| Admin   | admin@health.com      | Password123 |
| Patient | ahmad@email.com       | Password123 |
| Patient | mohammad@email.com    | Password123 |

---

## Features

### Patient
- Register & Login securely (BCrypt password hashing)
- Browse doctors filtered by specialty
- Book appointments (double-booking prevented)
- View all personal appointments
- Cancel pending appointments

### Admin
- Dashboard with stats (total, pending, confirmed, cancelled)
- View all appointments, filter by status
- Confirm or cancel any appointment
- Add / Edit / Delete doctors
- Toggle doctor availability

---

## Database Tables

| Table        | Key Columns                                           |
|--------------|-------------------------------------------------------|
| Users        | U_ID (PK), Full_Name, Email, Password, Phone, Role    |
| Doctors      | D_ID (PK), D_Name, Specialty, Phone, Email, Available |
| Appointments | A_ID (PK), U_ID (FK), D_ID (FK), Date, Time, Status  |

**Double-booking prevention:** `UNIQUE (D_ID, App_Date, App_Time)` constraint on Appointments table.

---

## Technologies Used

- **Database:** SQL Server (T-SQL)
- **Backend:** ASP.NET Core MVC (.NET 8)
- **Frontend:** HTML5, CSS3, JavaScript (Razor Views)
- **Security:** BCrypt password hashing, ASP.NET Session
