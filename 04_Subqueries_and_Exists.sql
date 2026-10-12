/* SQL SERVER PRACTICE: SUBQUERIES AND EXISTS */
USE PracticeDB
GO

/* 04 | SUBQUERIES AND EXISTS */

    /* Find employees who earn more than the company's average salary. */

SELECT
    EmpID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    Employees
WHERE
    salary > (
        SELECT
            AVG(salary)
        FROM
            Employees
    )

    /* Find employees who earn the maximum salary in the company (use a subquery, not TOP). */

SELECT
    EmpID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    Employees
WHERE
    salary = (
        SELECT
            MAX(salary)
        FROM
            Employees
    )

    /* Find employees who earn more than the average salary of their own department (correlated subquery) */

SELECT
    EmpID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    Employees E
WHERE
    Salary > (
        SELECT
            AVG(salary)
        FROM
            Employees B
        WHERE
            E.DeptID = B.DeptID
    )

    /* Find departments that have at least one employee earning above 100,000, using EXISTS */

SELECT
    DeptName
FROM
    Departments D
WHERE
    EXISTS (
        SELECT
            '1'
        FROM
            Employees E
        WHERE
            E.DeptID = D.DeptID
            AND salary > 100000
    )

    /* Find employees who are not managers of anyone, using NOT EXISTS */

SELECT
    EmpID,
    CONCAT(FirstName, ' ', LastName) AS FullName
FROM
    Employees E
WHERE
    NOT EXISTS (
        SELECT
            '1'
        FROM
            Employees B
        WHERE
            B.ManagerID = E.EmpID
    )
