--- CHECK: The silver crm_prd_info

USE DataWarehouse;
GO

SELECT prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
FROM silver.crm_prd_info

SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

SELECT prd_nm
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL

SELECT DISTINCT prd_line
FROM silver.crm_prd_info

SELECT prd_start_dt, prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt