-- ============================================================
--  Online Health System - Database Script
--  SQL Server
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'OnlineHealthDB')
    DROP DATABASE OnlineHealthDB;
GO

CREATE DATABASE OnlineHealthDB;
GO

USE OnlineHealthDB;
GO

-- ============================================================
-- TABLE: Users
-- ============================================================
CREATE TABLE Users (
    U_ID         INT           IDENTITY(1,1) PRIMARY KEY,
    Full_Name    NVARCHAR(100) NOT NULL,
    Email        NVARCHAR(150) NOT NULL UNIQUE,
    Password     NVARCHAR(255) NOT NULL,   -- stored as hashed value
    Phone_Number NVARCHAR(20)  NOT NULL,
    Role         NVARCHAR(10)  NOT NULL DEFAULT 'Patient'
        CONSTRAINT CHK_Role CHECK (Role IN ('Patient', 'Admin')),
    Created_At   DATETIME      NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- TABLE: Doctors
-- ============================================================
CREATE TABLE Doctors (
    D_ID      INT           IDENTITY(1,1) PRIMARY KEY,
    D_Name    NVARCHAR(100) NOT NULL,
    Specialty NVARCHAR(100) NOT NULL,
    Phone     NVARCHAR(20)  NOT NULL,
    Email     NVARCHAR(150) NOT NULL UNIQUE,
    Available BIT           NOT NULL DEFAULT 1   -- 1 = available, 0 = not
);
GO

-- ============================================================
-- TABLE: Appointments
-- ============================================================
CREATE TABLE Appointments (
    A_ID     INT          IDENTITY(1,1) PRIMARY KEY,
    U_ID     INT          NOT NULL,
    D_ID     INT          NOT NULL,
    App_Date DATE         NOT NULL,
    App_Time TIME         NOT NULL,
    Status   NVARCHAR(20) NOT NULL DEFAULT 'Pending'
        CONSTRAINT CHK_Status CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    Notes    NVARCHAR(500) NULL,
    Created_At DATETIME   NOT NULL DEFAULT GETDATE(),

    -- Foreign Keys
    CONSTRAINT FK_Appointments_Users
        FOREIGN KEY (U_ID) REFERENCES Users(U_ID) ON DELETE CASCADE,
    CONSTRAINT FK_Appointments_Doctors
        FOREIGN KEY (D_ID) REFERENCES Doctors(D_ID) ON DELETE CASCADE,

    -- Prevent double-booking: same doctor, same date, same time
    CONSTRAINT UQ_Doctor_DateTime
        UNIQUE (D_ID, App_Date, App_Time)
);
GO

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX IX_Appointments_User   ON Appointments(U_ID);
CREATE INDEX IX_Appointments_Doctor ON Appointments(D_ID);
CREATE INDEX IX_Appointments_Date   ON Appointments(App_Date);
GO

-- ============================================================
-- SAMPLE DATA: Users
-- Password for all sample users = "Password123"
-- In real app these would be BCrypt hashes; using placeholder here.
-- ============================================================
INSERT INTO Users (Full_Name, Email, Password, Phone_Number, Role) VALUES
('Admin User',          'admin@health.com',    'hashed_Password123', '0791000000', 'Admin'),
('Ahmad Amin Mallouh',  'ahmad@email.com',     'hashed_Password123', '0791111111', 'Patient'),
('Mohammad Al-Wahidi',  'mohammad@email.com',  'hashed_Password123', '0792222222', 'Patient'),
('Sara Khalid',         'sara@email.com',      'hashed_Password123', '0793333333', 'Patient'),
('Lina Hassan',         'lina@email.com',      'hashed_Password123', '0794444444', 'Patient');
GO

-- ============================================================
-- SAMPLE DATA: Doctors
-- ============================================================
INSERT INTO Doctors (D_Name, Specialty, Phone, Email, Available) VALUES
('Dr. Khalid Mansour',   'General',     '0795000001', 'khalid@clinic.com',   1),
('Dr. Rania Qasem',      'Dental',      '0795000002', 'rania@clinic.com',    1),
('Dr. Omar Nasser',      'Cardiology',  '0795000003', 'omar@clinic.com',     1),
('Dr. Hana Yousef',      'Pediatrics',  '0795000004', 'hana@clinic.com',     1),
('Dr. Samir Haddad',     'Neurology',   '0795000005', 'samir@clinic.com',    1),
('Dr. Nour Albanna',     'Orthopedics', '0795000006', 'nour@clinic.com',     0);
GO

-- ============================================================
-- SAMPLE DATA: Appointments
-- ============================================================
INSERT INTO Appointments (U_ID, D_ID, App_Date, App_Time, Status, Notes) VALUES
(2, 1, '2026-06-01', '09:00', 'Confirmed', 'Regular check-up'),
(2, 3, '2026-06-05', '11:00', 'Pending',   'Heart palpitations'),
(3, 2, '2026-06-02', '10:00', 'Confirmed', 'Tooth cleaning'),
(4, 4, '2026-06-03', '14:00', 'Pending',   'Child vaccination'),
(5, 1, '2026-06-01', '10:00', 'Cancelled', 'Headache - cancelled'),
(3, 5, '2026-06-10', '09:30', 'Pending',   'Migraine follow-up');
GO

-- ============================================================
-- USEFUL VIEWS
-- ============================================================

-- View: Appointment details with patient and doctor names
CREATE VIEW vw_AppointmentDetails AS
SELECT
    a.A_ID,
    u.Full_Name  AS PatientName,
    u.Phone_Number AS PatientPhone,
    d.D_Name     AS DoctorName,
    d.Specialty,
    a.App_Date,
    a.App_Time,
    a.Status,
    a.Notes,
    a.Created_At
FROM Appointments a
JOIN Users    u ON a.U_ID = u.U_ID
JOIN Doctors  d ON a.D_ID = d.D_ID;
GO

-- ============================================================
-- STORED PROCEDURE: Check for double-booking before inserting
-- ============================================================
CREATE PROCEDURE sp_BookAppointment
    @U_ID     INT,
    @D_ID     INT,
    @App_Date DATE,
    @App_Time TIME,
    @Notes    NVARCHAR(500),
    @Result   NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if slot is already taken
    IF EXISTS (
        SELECT 1 FROM Appointments
        WHERE D_ID = @D_ID AND App_Date = @App_Date AND App_Time = @App_Time
          AND Status <> 'Cancelled'
    )
    BEGIN
        SET @Result = 'SLOT_TAKEN';
        RETURN;
    END

    -- Insert the appointment
    INSERT INTO Appointments (U_ID, D_ID, App_Date, App_Time, Status, Notes)
    VALUES (@U_ID, @D_ID, @App_Date, @App_Time, 'Pending', @Notes);

    SET @Result = 'SUCCESS';
END;
GO

PRINT 'OnlineHealthDB created successfully!';
GO
