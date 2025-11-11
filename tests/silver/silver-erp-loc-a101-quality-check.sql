USE DataWarehouse;
GO

--- Quality Checks
--- CHECK: For Nuls or Dupicates in .cid
SELECT cid, COUNT(*)
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

--- CHECK: Rellations with table crm_sust_info (cst_key)
SELECT cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key
FROM silver.crm_cust_info
WHERE cst_key IS NOT NULL)

--- CHECK: Data Stantardization & Consistency
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
