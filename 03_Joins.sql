/* SQL SERVER PRACTICE: JOINS */
USE PracticeDB
GO

/* 03 | JOINS */

    /* Show each employee's full name with their department name (employees without a department should not appear). */

SELECT
    CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
    D.DeptName
FROM
    Employees E
    INNER JOIN Departments D ON E.deptid = D.deptid

    /* Show all employees with their department name, including those with no department (display "No Dept" instead of NULL; hint: ISNULL or COALESCE). */

SELECT
    CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
    ISNULL(D.DeptName, 'No Dept') AS DeptName
FROM
    Employees E
    LEFT JOIN Departments D ON E.deptid = D.deptid

    /* Show each employee's full name and their manager's full name. Employees with no manager should still appear. */

SELECT
    CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
    CONCAT(M.FirstName, ' ', M.LastName) AS ManagerName
FROM
    Employees E
    LEFT JOIN Employees M ON E.ManagerID = M.EmpID

    /* Show each department name with its employee count, including departments with 0 employees. (Run INSERT INTO Departments VALUES (6,'Legal'); first to test this.) */

SELECT
    D.DeptName,
    COUNT(EmpID) AS empcount
FROM
    Departments D
    LEFT JOIN Employees E ON D.deptid = E.DeptID
GROUP BY
    D.DeptName

    /* Find departments that have no employees. */

SELECT
    D.DeptName,
    COUNT(E.EmpID) AS empcount
FROM
    Departments D
    LEFT JOIN Employees E ON D.deptid = E.DeptID
GROUP BY
    D.DeptName
HAVING
    COUNT(E.EmpID) = 0
SELECT
    D.deptname
FROM
    Employees E
    RIGHT JOIN Departments D ON E.DeptID = D.DeptID
WHERE
    E.DeptID IS NULL
SELECT
    DeptName
FROM
    Departments D
WHERE
    NOT EXISTS (
        SELECT
            '1'
        FROM
            Employees E
        WHERE
            E.DeptID = D.deptid
    )

    /* Show the highest-paid employee in each department, with the department name. (Hint: try a join to a grouped result, or wait for Step 5 if it feels hard.) */

SELECT
    E.EmpID,
    CONCAT(E.FirstName, ' ', E.LastName) AS FullName,
    E.Salary,
    D.DeptName
FROM
    Employees E
    INNER JOIN (
        SELECT
            deptid,
            MAX(salary) AS MaxSal
        FROM
            Employees
        GROUP BY
            deptid
    ) AS M ON E.DeptID = M.DeptID
    AND E.Salary = M.MaxSal
    INNER JOIN Departments D ON E.DeptID = D.deptid

    /* Show each city with the number of employees and average salary, only for employees who belong to the IT department. */

SELECT
    City,
    COUNT(EmpID) AS EmpCount,
    AVG(salary) AS AvgSal
FROM
    Employees E
    INNER JOIN Departments D ON E.DeptID = D.deptid
    AND D.DeptName = 'IT'
GROUP BY
    city
