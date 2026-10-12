/* SQL SERVER PRACTICE: WINDOW FUNCTIONS */
USE PracticeDB
GO

/* 06 | WINDOW FUNCTIONS */

/* Assign a ROW_NUMBER to every employee ordered by salary descending. */

WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            City,
            Salary,
            ROW_NUMBER() OVER (
                ORDER BY
                    salary DESC
            ) AS RowNumBasedSal
        FROM
            Employees
    )
SELECT
    *
FROM
    cte
ORDER BY
    RowNumBasedSal

    /* Rank employees by salary within each department using RANK and DENSE_RANK side by side. */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            DeptID,
            Salary,
            RANK() OVER (
                PARTITION BY
                    DeptID
                ORDER BY
                    salary DESC
            ) AS RankBasedSal
        FROM
            Employees
        WHERE
            DeptID IS NOT NULL
    )
SELECT
    *
FROM
    cte
ORDER BY
    deptid,
    RankBasedSal

GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            DeptID,
            Salary,
            DENSE_RANK() OVER (
                PARTITION BY
                    DeptId
                ORDER BY
                    salary DESC
            ) AS DenRankBasSal
        FROM
            Employees
        WHERE
            DeptID IS NOT NULL
    )
SELECT
    *
FROM
    cte
ORDER BY
    deptid,
    DenRankBasSal

    /* Show the top 3 earners in each department (use a CTE). */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            DeptID,
            Salary,
            DENSE_RANK() OVER (
                PARTITION BY
                    deptid
                ORDER BY
                    salary DESC
            ) AS RankbasSal
        FROM
            Employees
        WHERE
            DeptID IS NOT NULL
    )
SELECT
    EmpID,
    FullName,
    DeptID,
    Salary,
    RankbasSal
FROM
    cte
WHERE
    RankbasSal <= 3
ORDER BY
    DeptID,
    RankbasSal

    /* Show exactly one top-earning employee per city (no ties), using ROW_NUMBER. */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            city,
            Salary,
            ROW_NUMBER() OVER (
                PARTITION BY
                    city
                ORDER BY
                    salary DESC
            ) AS RankBasSal
        FROM
            Employees
    )
SELECT
    EmpID,
    FullName,
    City,
    Salary
FROM
    cte
WHERE
    RankBasSal = 1

    /* For each employee, show salary, department average salary, and the difference between them. */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            deptid,
            Salary AS EmpSal,
            AVG(salary) OVER (
                PARTITION BY
                    deptid
            ) AS DepAvgSal
        FROM
            Employees
        WHERE
            DeptID IS NOT NULL
    )
SELECT
    *
FROM
    cte

    /* Show a running total of salary ordered by HireDate (break ties with EmpID) */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            deptid,
            Salary AS EmpSal,
            SUM(salary) OVER (
                ORDER BY
                    hiredate
            ) AS RunningTotal
        FROM
            employees
    )
SELECT
    *
FROM
    cte

    /* Use LAG to show each employee’s salary alongside the previous hired employee’s salary, and the difference between the two. */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            deptid,
            Salary AS EmpSal,
            LAG(salary) OVER (
                ORDER BY
                    hiredate
            ) AS PreviousSal
        FROM
            Employees
    )
SELECT
    EmpID,
    FullName,
    deptid,
    EmpSal,
    PreviousSal,
    empsal - PreviousSal AS DiffSal
FROM
    cte

    /* Find the second-highest salary in each department (handle ties with DENSE_RANK) */
GO
WITH
    cte AS (
        SELECT
            EmpID,
            CONCAT(FirstName, ' ', LastName) AS FullName,
            deptid,
            Salary AS EmpSal,
            DENSE_RANK() OVER (
                PARTITION BY
                    deptid
                ORDER BY
                    salary DESC
            ) AS RankBasedSal
        FROM
            Employees
    )
SELECT
    Empid,
    FullName,
    deptid,
    Empsal,
    Rankbasedsal
FROM
    cte
WHERE
    RANKBasedSal = 2
