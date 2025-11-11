USE DataWarehouse
GO

--- The first step: 
-- Build relations

SELECT
    ci.cst_id,
    ci.cst_key,
    cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry

FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
    ON ca.cid = ci.cst_key
    LEFT JOIN silver.erp_loc_a101 AS la
    ON la.cid = ci.cst_key

--- Check unikness       

SELECT cst_id, COUNT(*)
FROM (
SELECT
        ci.cst_id,
        ci.cst_key,
        cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry

    FROM silver.crm_cust_info AS ci
        LEFT JOIN silver.erp_cust_az12 AS ca
        ON ca.cid = ci.cst_key
        LEFT JOIN silver.erp_loc_a101 AS la
        ON la.cid = ci.cst_key)t
GROUP BY cst_id
HAVING COUNT(*) > 1

--- Check distincts for ci.cst_gndr and ca.gen
-- CRM is the Master for gender Info
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
    ON ca.cid = ci.cst_key
    ORDER BY 1,2