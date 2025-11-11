USE DataWarehouse;
GO

--- Quality Checks
--- CHECK: For Nuls or Dupicates in .cid
SELECT cid, COUNT(*)
FROM bronze.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

--- CHECK: Remove the cid dash "AW-00011000" => "AW00011000"
SELECT REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101;
SELECT cst_key
FROM bronze.crm_cust_info;


--- CHECK: Rellations with table crm_sust_info (cst_key)
SELECT REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key
FROM silver.crm_cust_info)

--- CHECK: Data Stantardization & Consistency
SELECT DISTINCT
    cntry AS old_cntry,
    CASE 
        WHEN UPPER(TRIM(cntry)) ='DE' THEN 'Germany'
        WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
        WHEN UPPER(TRIM(cntry)) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
        END as cntry
FROM bronze.erp_loc_a101
