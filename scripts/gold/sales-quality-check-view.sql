USE DataWarehouse
GO

--- Checl: relation with gold.dim_customers and gold.dim_products
SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers as c
on c.customer_key = s.customer_key 
WHERE c.customer_key IS NULL

SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products as p
on p.product_key = s.product_key
WHERE p.product_key IS NULL