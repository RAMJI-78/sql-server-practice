/* SQL SERVER PRACTICE: DML AND CONSTRAINTS */
USE PracticeDB
GO

/* 07 | DML AND CONSTRAINTS */

/*
    Create a Projects table (as above, or design your own) with an identity primary key, a CHECK on budget, and a default start date.
    Insert 5 projects, using a multi-row INSERT.
    Create a backup of Employees using SELECT ... INTO, then verify the row counts match.
    Give a 5% raise to all employees in Chennai. First write the SELECT to preview the rows, then the UPDATE. Use OUTPUT inserted.EmpID, deleted.Salary, inserted.Salary to show before and after.
    Add a nullable Email column to Employees, then fill it with FirstName.LastName@company.com (lowercase) for everyone.
    Delete employees hired before 2017, but inside a transaction: run it, check @@ROWCOUNT, then ROLLBACK.
    Use MERGE to sync Projects from a small set of new values (one existing project updated, one new project inserted).
    Try to violate the CHECK constraint with a negative budget and read the error message.
    Add a foreign key from Projects.DeptID to Departments.DeptID, then try inserting a project with DeptID = 99.
    */

    IF NOT EXISTS (
        SELECT
            1
        FROM
            sys.objects
        WHERE
        TYPE = 'U'
        AND name = 'Projects'
    ) BEGIN
CREATE TABLE Projects (
    ProjectID INT IDENTITY(1, 1) PRIMARY KEY,
    ProjectName VARCHAR(150) NOT NULL,
    Budget DECIMAL(10, 2) CHECK (Budget >= 0),
    startdate DATE DEFAULT GETDATE(),
    DeptId INT NULL CONSTRAINT FK_Projects_deptid FOREIGN KEY (DeptId) REFERENCES Departments (DeptID)
) END
GO
INSERT INTO
    projects (ProjectName, Budget, DeptId)
VALUES
    ('Inventory Management', 120000, 1),
    ('Workflow configuration', 230000, 2),
    ('Production Support', 220000, 3),
    ('Requirement', 480000, 4),
    ('Mangagement', 650000, 5)
SELECT
    *
INTO
    Employees_backup
FROM
    Employees
UPDATE Employees
SET
    Salary = Salary + (Salary * 0.05) output inserted.EmpID,
    deleted.salary AS BeforeSal,
    inserted.salary AS Aftersal
WHERE
    city = 'chennai'
ALTER TABLE employees
ADD Email VARCHAR(50) NULL
GO
UPDATE Employees
SET
    email = CONCAT(
        LOWER(FirstName),
        '.',
        LOWER(LastName),
        '@company.com'
    ) BEGIN TRANSACTION
DELETE FROM Employees
WHERE
    YEAR(HireDate) < 2017 IF @@rowcount <= 0 BEGIN ROLLBACK TRANSACTION END ELSE BEGIN COMMIT TRANSACTION END
UPDATE Projects
SET
    Budget = -200

    /* The UPDATE statement conflicted with the CHECK constraint "CK__Projects__Budget__5CD6CB2B". The conflict occurred in database "PracticeDB", table "dbo.Projects", column 'Budget'. */

UPDATE projects
SET
    DeptId = 99

    /* The UPDATE statement conflicted with the FOREIGN KEY constraint "FK_Projects_deptid". The conflict occurred in database "PracticeDB", table "dbo.Departments", column 'deptid'. */

MERGE INTO
    projects AS Target using (
        VALUES
            (1, 'Website Design'),
            (NULL, 'Mobile App Development')
    ) AS source (ProjectId, Projectname) ON target.projectid = source.projectid
WHEN MATCHED THEN
UPDATE SET
    target.projectname = source.projectname
WHEN NOT MATCHED BY TARGET THEN
INSERT
    (projectname)
VALUES
    (source.projectname);


/* Add a UNIQUE constraint on Employees.Email */

ALTER TABLE employees
ADD CONSTRAINT uni_email UNIQUE (email)
GO

/*Add a CHECK that Salary > 0, and a foreign key from Employees.DeptID to Departments. Then add a self-referencing foreign key from ManagerID to Employees.EmpID.*/

ALTER TABLE employees
ADD CONSTRAINT chk_salary CHECK (salary > 0),
CONSTRAINT fk_deptid_01 FOREIGN KEY (deptid) REFERENCES departments (deptid),
CONSTRAINT selfFK_manId FOREIGN KEY (ManagerID) REFERENCES employees (empid)
GO

/* Create the Assignments table above (composite primary key, cascade delete from Projects). Insert 3 rows, delete one project, and confirm its assignments disappear. */

IF NOT EXISTS (
    SELECT
        1
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'Assignments'
) BEGIN
CREATE TABLE assignments (
    empid INT NOT NULL REFERENCES employees (empid),
    projectid INT NOT NULL REFERENCES projects (projectid) ON DELETE CASCADE,
    ROLE VARCHAR(50) NULL,
    PRIMARY KEY (empid, projectid)
) END
GO
INSERT INTO
    assignments (
        empid,
        projectid,
        ROLE
    )
VALUES
    (1, 1, 'Developer'),
    (2, 2, 'Tester'),
    (3, 4, 'Designer')
DELETE FROM Projects
WHERE
    ProjectID = 2
GO
