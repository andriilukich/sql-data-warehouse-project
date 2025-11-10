USE DataWarehouse;
GO

SELECT *
FROM silver.erp_px_cat_g1v2

--- Quality Checks
--- CHECK: For Unwanted Space
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--- CHECK: Data Stantardization & Consistency
SELECT DISTINCT
    cat
FROM silver.erp_px_cat_g1v2
GO
SELECT DISTINCT
    subcat
FROM silver.erp_px_cat_g1v2
go
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2
