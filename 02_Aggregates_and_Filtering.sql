/* SQL SERVER PRACTICE: AGGREGATE FUNCTIONS AND FILTERING */
USE PracticeDB
GO

/* 02 | AGGREGATE FUNCTIONS AND FILTERING */

/* Find the total number of employees and the average salary. */

SELECT
    COUNT(EmpId) AS empcount,
    AVG(salary) AS avgsalary
FROM
    Employees

    /* Show the number of employees in each department. What do you see for the NULL department? */

SELECT
    deptid,
    COUNT(empid) AS empcount
FROM
    Employees
GROUP BY
    DeptID
ORDER BY
    DeptID

    /* Show the highest and lowest salary in each city. */

SELECT
    city,
    MAX(salary) AS MaxSalary,
    MIN(salary) AS MinSalary
FROM
    Employees
GROUP BY
    City

    /* List departments whose average salary is above 75,000. */

SELECT
    deptid,
    AVG(Salary)
FROM
    Employees
GROUP BY
    deptid
HAVING
    AVG(salary) > 75000

    /* Count how many employees were hired in each year, only for years with more than 100 hires. */

SELECT
    DATEPART(year, hiredate) AS HireYear,
    COUNT(empid) AS Hirecount
FROM
    Employees
GROUP BY
    DATEPART(year, hiredate)
HAVING
    COUNT(empid) > 100
ORDER BY
    HireYear

    /* For employees hired after 2019-12-31, show total salary expense per city, but only cities where the total exceeds 5,000,000, sorted from highest to lowest. */

SELECT
    city,
    SUM(salary) AS total
FROM
    Employees
WHERE
    hiredate > '2019-12-31'
GROUP BY
    city
HAVING
    SUM(salary) > 5000000
ORDER BY
    total DESC

    /* Find how many employees have no department, using COUNT(*) and then COUNT(DeptID). Why do the two differ? */

SELECT
    COUNT(*) AS count
FROM
    Employees
SELECT
    COUNT(DeptID) AS count
FROM
    Employees

    /* Reason COUNT(*) counts rows, regardless of what the columns contain.
    COUNT(column) counts only rows where that column is NOT NULL.NULL isn't "false". It means "unknown/missing". 
    Aggregate functions (except COUNT(*)) simply ignore NULLs. This is the same reason AVG(column) divides 
    by the number of non-NULL values, not the number of rows.*/
