/* SQL SERVER PRACTICE: INDEXES AND QUERY PERFORMANCE */
USE PracticeDB
GO

/* 08 | INDEXES AND QUERY PERFORMANCE */

/* Run SELECT * FROM Employees WHERE City = 'Chennai' with SET STATISTICS IO ON and note the logical reads. Then create IX_Emp_City, rerun, and compare. */

SET
STATISTICS IO ON
SELECT
    *
FROM
    Employees
WHERE
    city = 'chennai'
SELECT
    *
FROM
    Employees
WITH
    (
        INDEX (IX_emp_city)
    )
WHERE
    City = 'Chennai';


GO
CREATE NONCLUSTERED
INDEX IX_emp_city ON employees (city)

/* Before indexing - Table 'Employees'. Scan count 1, logical reads 17, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
After indexing  - Table 'Employees'. Scan count 1, logical reads 17, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
*/
GO

/* Create a covering index for SELECT City, Salary FROM Employees WHERE City = 'Chennai'. Compare the reads again and look at the execution plan (Ctrl+M in SSMS) for Index Seek vs Scan vs Key Lookup. */

CREATE NONCLUSTERED
INDEX CVR_emp_city ON employees (city) include (salary)
SELECT
    city,
    Salary
FROM
    Employees
WHERE
    city = 'chennai'
GO

/* Compare the reads for WHERE YEAR(HireDate) = 2020 against the range version, with an index on HireDate. */

CREATE NONCLUSTERED
INDEX NIX_emp_hiredate ON Employees (HireDate) INCLUDE (City, Salary);


GO
SELECT
    City,
    Salary
FROM
    Employees
WHERE
    YEAR(HireDate) = 2020;


SELECT
    city,
    salary
FROM
    Employees
WHERE
    HireDate BETWEEN '2016-01-01' AND '2018-01-01'
GO

/* Create a filtered index on IT-department employees, and use sp_helpindex to list all indexes on Employees. */

CREATE NONCLUSTERED
INDEX FIX_emp_dep ON employees (salary)
WHERE
    deptid = 1
GO
sp_helpindex 'employees'

/* Try to insert a duplicate email, then drop one index and one constraint you created. */

UPDATE Employees
SET
    email = 'priya.kumar@company.com'
WHERE
    empid = 12

    /* Violation of UNIQUE KEY constraint 'uni_email'. Cannot insert duplicate key in object 'dbo.Employees'. The duplicate key value is (priya.kumar@company.com).*/
GO
DROP
INDEX NIX_emp_hiredate ON employees
GO
ALTER TABLE employees DROP CONSTRAINT selfFK_manId
