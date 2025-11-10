USE DataWarehouse;
GO
PRINT '>> Truncating Table: silver.erp_cust_az12'
TRUNCATE TABLE silver.erp_cust_az12;

PRINT '>> Inserting Data Into: silver.erp_cust_az12'
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