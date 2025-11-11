USE DataWarehouse
GO

--- The first step: 
-- Check relations and propagete primary keys 

SELECT
    cs.sls_ord_num,
    pr.product_key,
    cu.customer_key,
    cs.sls_order_dt,
    cs.sls_ship_dt,
    cs.sls_due_dt,
    cs.sls_sales,
    cs.sls_quantity,
    cs.sls_price
FROM silver.crm_sales_details AS cs
    LEFT JOIN gold.dim_customers AS cu
    ON cu.customer_id = cs.sls_cust_id
    LEFT JOIN gold.dim_products AS pr
    ON pr.product_number = cs.sls_prd_key
