USE DataWarehouse;
GO

--- Quality Checks

SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
--- Check the sls_ord_num for unwanted spaces
-- WHERE TRIM(sls_ord_num) != sls_ord_num
-- WHERE TRIM(sls_prd_key) != sls_prd_key

--- Check relations
-- WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)
-- WHERE sls_cust_id NOT IN (SELECT cst_id
-- FROM silver.crm_cust_info)

--- Check Invalid Dates
-- ORDER_DATE
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8
    OR sls_order_dt > 20300101
    OR sls_order_dt < 19000101

SELECT sls_order_dt,
    CASE 
    WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
END AS sls_order_dt_updated
FROM bronze.crm_sales_details

-- SHIPING_DATE
SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
    OR LEN(sls_ship_dt) != 8
    OR sls_ship_dt > 20300101
    OR sls_ship_dt < 19000101

-- DUE_DATE
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8
    OR sls_due_dt > 20300101
    OR sls_due_dt < 19000101

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--- Business Rules
-- Sales = Quantity * Price
-- Not Allowed: Negative, Zeros, Nulls
SELECT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price


SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_sales)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
