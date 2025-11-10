USE DataWarehouse;
GO

SELECT id, cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2

--- Quality Checks
--- CHECK: For Unwanted Space
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--- CHECK: Data Stantardization & Consistency
SELECT DISTINCT
    cat
FROM bronze.erp_px_cat_g1v2
GO
SELECT DISTINCT
    subcat
FROM bronze.erp_px_cat_g1v2
go
SELECT DISTINCT
    maintenance
FROM bronze.erp_px_cat_g1v2
