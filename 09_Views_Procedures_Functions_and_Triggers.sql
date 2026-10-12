/* SQL SERVER PRACTICE: VIEWS, PROCEDURES, FUNCTIONS, AND TRIGGERS */
USE PracticeDB
GO

/* 09 | VIEWS, PROCEDURES, FUNCTIONS, AND TRIGGERS */

/* Create a view vw_EmpDetails (as above) and query it with a filter. Then try adding ORDER BY inside the view and read the error. */
GO
CREATE VIEW vw_empdetails AS
SELECT
    *
FROM
    Employees
GO
SELECT
    *
FROM
    vw_empdetails
WHERE
    DeptID = 1
GO
ALTER VIEW vw_empdetails AS
SELECT
    *
FROM
    Employees
ORDER BY
    DeptID

    /* The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified. */
GO
CREATE VIEW vw_Highearners AS
SELECT
    *
FROM
    Employees
WHERE
    salary > 100000
WITH
    CHECK
OPTION;


GO
UPDATE vw_Highearners
SET
    Salary = 100
WHERE
    EmpID = 5

    /* The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint. */
GO
CREATE PROC usp_GetEmpByCity @city VARCHAR(50),
@Minsalary DECIMAL(10, 2) = 0 AS BEGIN
SELECT
    EmpID,
    FirstName,
    LastName,
    Salary
FROM
    Employees
WHERE
    city = @city
    AND Salary >= @Minsalary END
GO
EXEC usp_GetEmpByCity @city = 'chennai'
GO
EXEC usp_GetEmpByCity @city = 'chennai',
@minsalary = 100000

/* Write a procedure with an OUTPUT parameter that returns the average salary of a department. Call it and print the result. */
GO
CREATE PROC usp_avgsaldep @deptid INT,
@avgsal DECIMAL(10, 2) output AS BEGIN
SELECT
    @avgsal = AVG(salary)
FROM
    Employees
WHERE
    deptid = @deptid END
GO
DECLARE @resultavgsal DECIMAL(10, 2) EXEC usp_avgsaldep @deptid = 1,
@avgsal = @resultavgsal output
SELECT
    @resultavgsal 'resultavgsal'
GO

/* Write usp_GiveRaise @DeptID, @Pct that updates the department’s salaries and returns the changed rows with OUTPUT. Reject a @Pct outside 0 to 20 using IF (we’ll do proper error handling in Step 10). Test it inside a transaction and roll back.*/

CREATE PROC usp_GiveRaise @deptid INT,
@pct DECIMAL(10, 2) AS BEGIN IF @pct BETWEEN 0 AND 20 BEGIN
UPDATE Employees
SET
    Salary = Salary + (Salary / 100 * @pct) output inserted.EmpID,
    deleted.Salary AS BeforeSal,
    inserted.Salary AS AfterSal
WHERE
    DeptID = @deptid END ELSE BEGIN RAISERROR ('Nothing is updated', 16, 1) RETURN END END
GO
BEGIN TRAN EXEC usp_GiveRaise @deptid = 1,
@pct = 3 ROLLBACK TRAN

/* Write a scalar function that returns an employee’s tenure in years from HireDate (DATEDIFF), and use it in a SELECT. */
GO
CREATE OR ALTER FUNCTION dbo.fn_EmpTenure (@HireDate DATE) RETURNS INT AS BEGIN RETURN DATEDIFF(YEAR, @HireDate, GETDATE()) - CASE
    WHEN DATEADD(
        YEAR,
        DATEDIFF(YEAR, @HireDate, GETDATE()),
        @HireDate
    ) > CAST(GETDATE() AS DATE) THEN 1
    ELSE 0
END;


END;


GO
SELECT
    TOP 10 EmpID,
    HireDate,
    dbo.fn_EmpTenure (HireDate) AS TenureYears
FROM
    Employees;


/* Write an inline TVF fn_TopEarners (@DeptID, @N) that returns the top N earners of a department (TOP (@N)), and join it to Departments with CROSS APPLY */
GO
CREATE FUNCTION fn_topearners (@deptid INT, @n INT) returns
TABLE AS RETURN (
    SELECT
        TOP (@n) empid,
        firstname,
        deptid,
        salary
    FROM
        Employees
    WHERE
        DeptID = @deptid
    ORDER BY
        Salary DESC
)
GO
SELECT
    D.DeptName,
    T.EmpID,
    T.FirstName,
    T.Salary
FROM
    Departments D
    CROSS APPLY dbo.fn_TopEarners (D.DeptID, 3) AS T
ORDER BY
    D.DeptName,
    T.Salary DESC;


/* Create the SalaryAudit table and trigger. Update one employee, then update a whole department in one statement, and confirm one audit row per changed employee. */
GO
IF NOT EXISTS (
    SELECT
        1
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'salaryaudit'
) BEGIN
CREATE TABLE salaryaudit (
    AuditID INT IDENTITY(1, 1),
    empid INT,
    oldsalary DECIMAL(10, 2),
    newsalary DECIMAL(10, 2),
    changed_at DATE DEFAULT GETDATE()
) END
GO
CREATE
TRIGGER tr_gsalaryaudit ON employees after
UPDATE AS BEGIN
SET
NOCOUNT ON
INSERT INTO
    salaryaudit (empid, oldsalary, newsalary)
SELECT
    i.empid,
    d.Salary,
    i.Salary
FROM
    inserted i
    INNER JOIN deleted d ON i.EmpID = d.EmpID
WHERE
    i.Salary <> d.Salary
SET
NOCOUNT OFF END
GO
BEGIN TRAN
UPDATE Employees
SET
    Salary = 230000
WHERE
    empid = 13
SELECT
    *
FROM
    salaryaudit ROLLBACK TRAN

    /* Create an AFTER DELETE trigger that copies deleted employees into an EmployeesDeleted table. Test it in a transaction with a multi-row delete, check both tables, then roll back. */

    IF NOT EXISTS (
        SELECT
            1
        FROM
            sys.objects
        WHERE
        TYPE = 'U'
        AND name = 'EmployeesDeleted'
    ) BEGIN
SELECT
    *
INTO
    employeesdeleted
FROM
    Employees
WHERE
    1 = 2 END
GO
CREATE
TRIGGER trg_EmployeesDeleted ON employees after
DELETE AS BEGIN
INSERT INTO
    EmployeesDeleted
SELECT
    *
FROM
    deleted END BEGIN TRAN
DELETE FROM Employees
WHERE
    empid = 13
SELECT
    *
FROM
    Employeesdeleted ROLLBACK TRAN

    /* Clean up: drop the views, procedures, functions, triggers, and audit tables you created. */

    DROP
TRIGGER IF EXISTS dbo.trg_EmployeesDeleted;


DROP
TRIGGER IF EXISTS dbo.tr_gsalaryaudit;


DROP VIEW IF EXISTS dbo.vw_empdetials;


DROP VIEW IF EXISTS dbo.vw_Highearners;


DROP PROCEDURE IF EXISTS dbo.usp_GetEmpByCity;


DROP PROCEDURE IF EXISTS dbo.usp_avgsaldep;


DROP PROCEDURE IF EXISTS dbo.usp_GiveRaise;


DROP FUNCTION IF EXISTS dbo.fn_EmpTenure;


DROP FUNCTION IF EXISTS dbo.fn_TopEarners;


DROP TABLE IF EXISTS dbo.SalaryAudit;


DROP TABLE IF EXISTS dbo.EmployeesDeleted;
