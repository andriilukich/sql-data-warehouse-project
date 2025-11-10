USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @section_start DATETIME, @section_end DATETIME;
    PRINT '######################################################';
    PRINT 'Insert Silver Layer (CRM & ERP)';
    PRINT '######################################################';

    SET @start_time = GETDATE();

    -- Load CRM section with timing and error handling
    BEGIN TRY
        PRINT '>> Starting section: silver.load_silver_crm';
        SET @section_start = GETDATE();
        EXEC silver.load_silver_crm;
        SET @section_end = GETDATE();
        PRINT '>> Completed section: silver.load_silver_crm - Duration: ' + CAST(DATEDIFF(SECOND, @section_start, @section_end) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> ---------------------------------------------------';
    END TRY
    BEGIN CATCH
        PRINT '*****************************************************';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER (CRM)';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        PRINT '*****************************************************';
        RETURN; -- stop further processing
    END CATCH

    -- Load ERP section with timing and error handling
    BEGIN TRY
        PRINT '>> Starting section: silver.load_silver_erp';
        SET @section_start = GETDATE();
        EXEC silver.load_silver_erp;
        SET @section_end = GETDATE();
        PRINT '>> Completed section: silver.load_silver_erp - Duration: ' + CAST(DATEDIFF(SECOND, @section_start, @section_end) AS NVARCHAR(50)) + ' seconds';
        PRINT '>> ---------------------------------------------------';
    END TRY
    BEGIN CATCH
        PRINT '*****************************************************';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER (ERP)';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        PRINT '*****************************************************';
        RETURN; -- stop further processing
    END CATCH

    SET @end_time = GETDATE();

    PRINT '######################################################';
    PRINT 'Insert Silver Layer (CRM & ERP) is Completed';
    PRINT '  - Total Insert Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' seconds';
    PRINT '######################################################';
END;
