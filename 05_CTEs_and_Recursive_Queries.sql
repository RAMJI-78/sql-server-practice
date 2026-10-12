/* SQL SERVER PRACTICE: CTES AND RECURSIVE QUERIES */
USE PracticeDB
GO

/* 05 | CTES AND RECURSIVE QUERIES */

    /* Using a CTE, show each department's name, employee count, and average salary, then keep only departments with an average above the overall average. */

WITH
    cte AS (
        SELECT
            D.DeptName,
            COUNT(E.empid) AS EmpCount,
            AVG(salary) AS AvgSal
        FROM
            Departments D
            INNER JOIN Employees E ON D.DeptID = E.DeptID
        GROUP BY
            D.DeptName
    )
SELECT
    DeptName,
    EmpCount,
    AvgSal
FROM
    cte
WHERE
    AvgSal > (
        SELECT
            AVG(salary)
        FROM
            Employees
    )

    /* Using a CTE, find the top-earning employee per city using a join to a grouped CTE (the Step 4 #6 pattern, but in a CTE). */
GO
WITH
    cte AS (
        SELECT
            City,
            MAX(Salary) AS MaxSal
        FROM
            Employees
        GROUP BY
            City
    )
SELECT
    E.City,
    E.EmpID,
    CONCAT(FirstName, ' ', LastName) AS FullName,
    E.Salary
FROM
    Employees E
    INNER JOIN cte C ON C.City = E.City
    AND C.MaxSal = E.Salary

    /* Recursive CTE: for each employee, show the level in the hierarchy (the CEO is level 0). How many employees are at each level? */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            ManagerID,
            0 AS Lvl
        FROM
            Employees
        WHERE
            ManagerID IS NULL
        UNION ALL
        SELECT
            E.EmpID,
            CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
            E.ManagerID,
            Lvl + 1 AS Lvl
        FROM
            Employees E
            INNER JOIN cte C ON E.ManagerID = C.EmpID
    )
SELECT
    Lvl,
    COUNT(*) AS EmpCount
FROM
    cte
GROUP BY
    Lvl
ORDER BY
    Lvl;
