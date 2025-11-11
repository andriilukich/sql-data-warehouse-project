USE DataWarehouse
GO

CREATE VIEW gold.fact_sales AS 
SELECT
    cs.sls_ord_num AS order_number,
    pr.product_key,
    cu.customer_key,
    cs.sls_order_dt AS order_date,
    cs.sls_ship_dt AS shipping_date,
    cs.sls_due_dt AS due_date,
    cs.sls_sales AS sales_amount,
    cs.sls_quantity AS quantity,
    cs.sls_price AS price
FROM silver.crm_sales_details AS cs
    LEFT JOIN gold.dim_customers AS cu
    ON cu.customer_id = cs.sls_cust_id
    LEFT JOIN gold.dim_products AS pr
    ON pr.product_number = cs.sls_prd_key
