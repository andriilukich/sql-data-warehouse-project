USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver_erp
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '======================================================';
        PRINT 'Loading silver Layer (ERP)';
        PRINT '======================================================';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2
            (
            id, cat, subcat, maintenance
            )
        SELECT
            id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101
            (
            cid,
            cntry
            )
        SELECT
        REPLACE(cid, '-', '') as cid,
        CASE 
            WHEN UPPER(TRIM(cntry)) ='DE' THEN 'Germany'
            WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
            WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
            END as cntry
        FROM bronze.erp_loc_a101

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12
            (
            cid,
            bdate,
            gen
            )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
                ELSE cid
            END as cid,
            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END as bdate,
            CASE 
                WHEN gen IN ('F','FEMALE') THEN 'Female'
                WHEN gen IN ('M','MALE')   THEN 'Male'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_cust_az12

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '*****************************************************'
    PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER (ERP)'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        PRINT '*****************************************************'
    END CATCH
END;