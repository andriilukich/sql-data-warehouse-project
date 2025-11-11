--- CHECK: The silver crm_sales_details

USE DataWarehouse;
GO

SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
-- WHERE TRIM(sls_ord_num) != sls_ord_num
-- WHERE TRIM(sls_prd_key) != sls_prd_key

--- Check relations
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
-- WHERE sls_cust_id NOT IN (SELECT cst_id
-- FROM silver.crm_cust_info)

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price