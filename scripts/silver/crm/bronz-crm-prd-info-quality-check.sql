USE DataWarehouse;
GO

--- Check For Nulls or Duplicates in Primary Key
--- Expectation: No Result

SELECT prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info

SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Extract the category id from prd_key
-- The First 5 characters are responsible for the category id
-- Base on the bronze.erp_px_cat_g1v2 need to transform the id from "CO-RF" to "CO_RF"

SELECT
    prd_key,
    -- SUBSTRING(prd_key, 1, 5) AS cat_id,
    REPLACE(SUBSTRING(prd_key, 1,5 ), '-', '_') AS tranformed_cat_id,
    -- Clear the product key from the category id
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS clear_product_key
FROM bronze.crm_prd_info

-- Check the Category id relation that not exist in bronze.erp_px_cat_g1v2
-- WHERE REPLACE(SUBSTRING(prd_key, 1,5 ), '-', '_') NOT IN 
-- (SELECT distinct id
-- FROM bronze.erp_px_cat_g1v2)

-- Check the product key relation that exist in bronze.crm_sales_details
-- WHERE SUBSTRING(prd_key, 7, LEN(prd_key))  IN (
--     SELECT sls_prd_key FROM bronze.crm_sales_details
-- )

--- Check prd_nm for unwanted spaces
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE TRIM(prd_nm) != prd_nm

--- Check prd_cost for NULLs or Negative Numbers
--  Replace cases with "0" if buizznes allows it
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL

SELECT prd_cost,
    ISNULL(prd_cost, 0)
FROM bronze.crm_prd_info

--- Check the prd_line distinct, replace the abbreviations
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

SELECT DISTINCT prd_line,
    CASE  UPPER(TRIM(prd_line))
    WHEN 'M' THEN 'Mountain'
    WHEN 'R' THEN 'Road'
    WHEN 'S' THEN 'Other Sales'
    WHEN 'T' THEN 'Touring'
    ELSE 'n/a' END AS prd_line_full
FROM bronze.crm_prd_info

--- Check for Invalid Date Orders

SELECT prd_start_dt, prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- The mismatched data needs to be investigated in Exel and get confirmation from the management

SELECT
    prd_key,
        CAST(prd_start_dt AS DATE) as prd_start_dt,
        CAST(DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509')