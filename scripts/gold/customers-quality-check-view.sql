USE DataWarehouse
GO

SELECT DISTINCT *
FROM gold.dim_customers

SELECT DISTINCT gender
FROM gold.dim_customers