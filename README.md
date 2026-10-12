# SQL Server Practice

A topic-by-topic SQL Server practice workbook. Start with the setup script, then work through the remaining topics in order.

## Topics

1. [Database setup and sample data](01_Database_Setup_and_Sample_Data.sql)
2. [Aggregates and filtering](02_Aggregates_and_Filtering.sql)
3. [Joins](03_Joins.sql)
4. [Subqueries and EXISTS](04_Subqueries_and_Exists.sql)
5. [CTEs and recursive queries](05_CTEs_and_Recursive_Queries.sql)
6. [Window functions](06_Window_Functions.sql)
7. [DML and constraints](07_DML_and_Constraints.sql)
8. [Indexes and query performance](08_Indexes_and_Query_Performance.sql)
9. [Views, procedures, functions, and triggers](09_Views_Procedures_Functions_and_Triggers.sql)
10. [Transactions and error handling](10_Transactions_and_Error_Handling.sql)

## How to Run

1. Open the scripts in SQL Server Management Studio (SSMS) or Azure Data Studio and connect to your SQL Server instance.
2. Run `01_Database_Setup_and_Sample_Data.sql` first. It creates or selects `PracticeDB`, creates the core tables if needed, and seeds practice data.
3. Run topics 02 through 10 in order, on the same SQL Server instance. Each later script selects `PracticeDB`.

## Notes

These scripts are for practice, not production use.

- Several exercises intentionally cause errors to demonstrate constraints and error handling.
- Later topics create objects and modify data, so the scripts are stateful and may not work unchanged if rerun.
- Review each exercise before executing it.