USE DataWarehouse
GO

--- The first step: 
-- Clear historical information and stay only with the current information 

SELECT
    pi.prd_id,
    pi.cat_id,
    pi.prd_key,
    pi.prd_nm,
    pi.prd_cost,
    pi.prd_line,
    pi.prd_start_dt
FROM silver.crm_prd_info AS pi
WHERE pi.prd_end_dt IS NULL -- Filter out all historical data

--- The Second step: 
-- Check relations and prd_key unikness
SELECT prd_key, COUNT(*) FROM (
SELECT
    pi.prd_id,
    pi.cat_id,
    pi.prd_key,
    pi.prd_nm,
    pi.prd_cost,
    pi.prd_line,
    pi.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance

FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pc.id = pi.cat_id
WHERE pi.prd_end_dt IS NULL)AS t -- Filter out all historical data
GROUP BY prd_key
HAVING COUNT(*) > 1