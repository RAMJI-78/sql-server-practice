/* SQL SERVER PRACTICE: TRANSACTIONS AND ERROR HANDLING */
USE PracticeDB
GO

/* 10 | TRANSACTIONS AND ERROR HANDLING */

/* Create and fill the Accounts table above */

IF NOT EXISTS (
    SELECT
        1
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'accounts'
) BEGIN
CREATE TABLE Accounts (
    AccID INT PRIMARY KEY,
    Holder VARCHAR(50),
    Balance DECIMAL(10, 2) CHECK (Balance >= 0)
) END
GO
INSERT INTO
    accounts (Accid, Holder, Balance)
VALUES
    (1, 'Arun', 2000),
    (2, 'Priya', 50000)
GO

/* Write a manual transfer of 20,000 from account 1 to account 2 inside BEGIN TRY ... BEGIN CATCH. It should violate the CHECK. Confirm in the CATCH that neither balance changed, and print the error message.*/

BEGIN try
UPDATE accounts
SET
    balance = balance - 20000
WHERE
    accid = 1
UPDATE accounts
SET
    balance = balance + 20000
WHERE
    accId = 2 END try BEGIN catch DECLARE @error VARCHAR(250) = ERROR_MESSAGE() PRINT @error;


throw END catch

/* Nest a BEGIN TRAN inside another one, print @@TRANCOUNT after each step, do an inner COMMIT, then an outer ROLLBACK. What happens to the data? */
GO
CREATE PROC usp_amounttransfer @from INT,
@to INT,
@amount DECIMAL(10, 2) AS BEGIN
SET
NOCOUNT ON BEGIN try BEGIN TRANSACTION
UPDATE accounts
SET
    balance = balance - @amount
WHERE
    accid = @from
UPDATE accounts
SET
    balance = balance + @amount
WHERE
    accid = @to COMMIT END try BEGIN catch IF @@TRANCOUNT > 0 ROLLBACK;


throw;


END catch
SET
NOCOUNT OFF END
GO
EXEC usp_amounttransfer 1,
2,
10000

/* Write usp_Transfer with validation: @Amt > 0, and both accounts exist (use THROW 50001, '...', 1). Test one success and two failures. */
GO
CREATE PROC usp_transfer @amt DECIMAL(10, 2),
@from INT,
@to INT AS BEGIN
SET
NOCOUNT ON IF @amt <= 0 throw 50001,
'Amount should be greater than 0',
1;


IF EXISTS (
    SELECT
        1
    FROM
        accounts
    WHERE
        accid = @from
) BEGIN
SELECT
    @from = @from END ELSE throw 50002,
    'Invalid From account code',
    1 IF EXISTS (
        SELECT
            1
        FROM
            accounts
        WHERE
            accid = @to
    ) BEGIN
SELECT
    @to = @to END ELSE throw 50002,
    'Invalid To account code',
    1
SET
NOCOUNT OFF END
GO
EXEC usp_transfer 1000,
1,
2
GO
EXEC usp_transfer 0,
1,
2
GO
EXEC usp_transfer 100,
23,
2

/* Create an ErrorLog table (ErrorNumber, ErrorMessage, ErrorLine, ErrorProcedure, LoggedAt). Add an INSERT to your CATCH block. Why must the insert come after the ROLLBACK? */
GO
IF NOT EXISTS (
    SELECT
        1
    FROM
        sys.objects
    WHERE
    TYPE = 'U'
    AND name = 'ErrorLog'
) BEGIN
CREATE TABLE ErrorLog (
    ErrorNumber INT,
    ErrorMessage VARCHAR(8000),
    ErrorLine INT,
    ErrorProcedure VARCHAR(250)
) END
GO
CREATE OR ALTER PROCEDURE usp_transferwitherrolog @amount DECIMAL(10, 2),
@from INT,
@to INT AS BEGIN
SET
NOCOUNT ON BEGIN Try BEGIN TRANSACTION
UPDATE accounts
SET
    balance = balance - @amount
WHERE
    accid = @from
UPDATE accounts
SET
    balance = balance + @amount
WHERE
    accid = @to COMMIT TRANSACTION END try BEGIN catch DECLARE @ErrorNumber INT = ERROR_NUMBER(),
    @ErrorMessage VARCHAR(8000) = ERROR_MESSAGE(),
    @ErrorLine INT = ERROR_LINE(),
    @ErrorProcedure VARCHAR(250) = ERROR_PROCEDURE() IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
INSERT INTO
    ErrorLog (
        ErrorNumber,
        ErrorMessage,
        ErrorLine,
        ErrorProcedure
    )
VALUES
    (
        @ErrorNumber,
        @ErrorMessage,
        @ErrorLine,
        @ErrorProcedure
    ) END catch
SET
NOCOUNT OFF END
GO
EXEC usp_transferwitherrolog 10000,
1,
2
SELECT
    *
FROM
    ErrorLog

    /* Reason - if we handle the errorlog insert before rollback the errorlog insertion will also get rollbacked */
