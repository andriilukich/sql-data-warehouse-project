USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME
    PRINT '######################################################';
    PRINT 'Loading Bronze Layer (CRM & ERP)';
    PRINT '######################################################';

    SET @start_time = GETDATE()
    
    -- Load CRM data into bronze layer
    EXEC bronze.load_bronze_crm;
    
    -- Load ERP data into bronze layer
    EXEC bronze.load_bronze_erp;
    
    SET @end_time = GETDATE()

    PRINT '######################################################';
    PRINT 'Loading Bronze Layer (CRM & ERP) is Completed';
    PRINT '  - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
    PRINT '######################################################';
END;
