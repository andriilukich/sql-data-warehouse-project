USE DataWarehouse;
GO

-- Execute the silver load procedure and print duration
DECLARE @start_time DATETIME, @end_time DATETIME;
PRINT '######################################################';
PRINT 'Executing Silver Load Procedure: silver.load_silver';
PRINT '######################################################';
SET @start_time = GETDATE();

EXEC silver.load_silver;

SET @end_time = GETDATE();
PRINT '######################################################';
PRINT 'Silver Load execution completed';
PRINT '  - Total Execution Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
PRINT '######################################################';
GO
