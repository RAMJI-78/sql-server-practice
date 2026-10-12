/*
SQL SERVER PRACTICE WORKBOOK

Topics
01. Database setup and sample data
02. Aggregate functions and filtering
03. Joins
04. Subqueries and EXISTS
05. CTEs and recursive queries
06. Window functions
07. DML and constraints
08. Indexes and query performance
09. Views, procedures, functions, and triggers
10. Transactions and error handling

Run from the top in a practice database. Later sections create objects and
change data, so this workbook is not intended to be rerun unchanged.
*/

/* 01 | DATABASE SETUP AND SAMPLE DATA */

IF NOT EXISTS (
    SELECT
        '1'
    FROM
        sys.databases
    WHERE
        name = 'PracticeDB'
) BEGIN
CREATE DATABASE PracticeDB END
GO
USE PracticeDB
GO
IF NOT EXISTS (
    SELECT
        '1'
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'Departments'
) BEGIN
CREATE TABLE Departments (
    deptid INT PRIMARY KEY,
    DeptName VARCHAR(50) NOT NULL
) END
GO
IF NOT EXISTS (
    SELECT
        '1'
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'Employees'
) BEGIN
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NULL,
    DeptID INT NULL,
    ManagerID INT NULL,
    Salary DECIMAL(10, 2),
    HireDate DATE NULL DEFAULT GETDATE(),
    City VARCHAR(50) NULL CONSTRAINT fk_deptid_employees FOREIGN KEY (DeptID) REFERENCES Departments (deptid)
) END
GO
-- Clear existing data
DELETE FROM Employees;


DELETE FROM Departments;


GO
-- Departments (5 rows is realistic; see note below)
INSERT INTO
    Departments (deptid, DeptName)
VALUES
    (1, 'IT'),
    (2, 'HR'),
    (3, 'Finance'),
    (4, 'Sales'),
    (5, 'Marketing');


GO
-- Name pools
CREATE TABLE #First (id INT, name VARCHAR(50));


INSERT INTO
    #First
VALUES
    (1, 'Arun'),
    (2, 'Priya'),
    (3, 'Rahul'),
    (4, 'Sneha'),
    (5, 'Vikram'),
    (6, 'Meena'),
    (7, 'Karthik'),
    (8, 'Divya'),
    (9, 'Ravi'),
    (10, 'Anita'),
    (11, 'Suresh'),
    (12, 'Lakshmi'),
    (13, 'Manoj'),
    (14, 'Kavya'),
    (15, 'Deepak'),
    (16, 'Ajay'),
    (17, 'Bhavna'),
    (18, 'Chitra'),
    (19, 'Dinesh'),
    (20, 'Eswari'),
    (21, 'Farhan'),
    (22, 'Gayathri'),
    (23, 'Harish'),
    (24, 'Indu'),
    (25, 'Jagan'),
    (26, 'Kiran'),
    (27, 'Lokesh'),
    (28, 'Madhavi'),
    (29, 'Naveen'),
    (30, 'Oviya'),
    (31, 'Pranav'),
    (32, 'Rekha'),
    (33, 'Sanjay'),
    (34, 'Tara'),
    (35, 'Uma'),
    (36, 'Varun'),
    (37, 'Yamini'),
    (38, 'Zoya'),
    (39, 'Aravind'),
    (40, 'Nisha');


CREATE TABLE #Last (id INT, name VARCHAR(50));


INSERT INTO
    #Last
VALUES
    (1, 'Kumar'),
    (2, 'Sharma'),
    (3, 'Verma'),
    (4, 'Iyer'),
    (5, 'Singh'),
    (6, 'Nair'),
    (7, 'Raj'),
    (8, 'Menon'),
    (9, 'Patel'),
    (10, 'Das'),
    (11, 'Reddy'),
    (12, 'Gupta'),
    (13, 'Pillai'),
    (14, 'Joshi'),
    (15, 'Rao'),
    (16, 'Naidu'),
    (17, 'Bose'),
    (18, 'Chopra'),
    (19, 'Desai'),
    (20, 'Gowda'),
    (21, 'Hegde'),
    (22, 'Khan'),
    (23, 'Mehta'),
    (24, 'Nambiar'),
    (25, 'Shetty');


-- Random values generated once per row; k is a shuffled 0..999 used to pick a unique name pair
SELECT
    TOP (1000) ROW_NUMBER() OVER (
        ORDER BY
            (
                SELECT
                    NULL
            )
    ) AS n,
    ROW_NUMBER() OVER (
        ORDER BY
            NEWID()
    ) - 1 AS k,
    ABS(CHECKSUM(NEWID())) % 5 + 1 AS dept,
    ABS(CHECKSUM(NEWID())) % 90001 AS sal,
    ABS(CHECKSUM(NEWID())) % 3000 AS days,
    ABS(CHECKSUM(NEWID())) % 8 + 1 AS city,
    ABS(CHECKSUM(NEWID())) AS mgr
INTO
    #Gen
FROM
    sys.all_objects a
    CROSS JOIN sys.all_objects b;


INSERT INTO
    Employees (
        EmpID,
        FirstName,
        LastName,
        DeptID,
        ManagerID,
        Salary,
        HireDate,
        City
    )
SELECT
    g.n,
    f.name,
    l.name,
    CASE
        WHEN g.n % 50 = 0 THEN NULL
        ELSE g.dept
    END,
    CASE
        WHEN g.n = 1 THEN NULL
        ELSE g.mgr % (g.n - 1) + 1
    END,
    CAST(30000 + g.sal AS DECIMAL(10, 2)),
    DATEADD(DAY, g.days, '2016-01-01'),
    CHOOSE(
        g.city,
        'Chennai',
        'Bangalore',
        'Mumbai',
        'Delhi',
        'Hyderabad',
        'Pune',
        'Kolkata',
        'Coimbatore'
    )
FROM
    #Gen g
    JOIN #First f ON f.id = g.k % 40 + 1
    JOIN #Last l ON l.id = g.k / 40 + 1;


DROP TABLE #Gen,
#First,
#Last;


GO
