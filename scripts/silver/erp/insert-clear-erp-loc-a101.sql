USE DataWarehouse;
GO
PRINT '>> Truncating Table: silver.erp_loc_a101'
TRUNCATE TABLE silver.erp_loc_a101;

PRINT '>> Inserting Data Into: silver.erp_loc_a101'

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