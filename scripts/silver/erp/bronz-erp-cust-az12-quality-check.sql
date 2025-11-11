USE DataWarehouse;
GO

--- Quality Checks
--- CHECK the realation between the tables erp_cust_az12 cid and crm_cust_info cst_key
SELECT cid, bdate, gen
FROM bronze.erp_cust_az12
where cid LIKE '%AW00011000%'

SELECT *
FROM silver.crm_cust_info

-- Based on the investigation, there are 3 redundant characters at the begining of every cid "NAS"

SELECT
    cid AS old_cid,
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
        ELSE cid
    END as cid,
    bdate,
    gen
FROM bronze.erp_cust_az12
WHERE  CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid)) 
        ELSE cid
    END NOT IN (SELECT DISTINCT cst_key
FROM silver.crm_cust_info)

-- CHECK the bdate for a range, older than a 100 years and future dates
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- With the to old bdate need to check with the menegement and the future dates need to replace with NULL
SELECT
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END as bdate
FROM bronze.erp_cust_az12

--- CHECK: Gender distincts
SELECT DISTINCT
    gen
FROM bronze.erp_cust_az12
-- After the investigation, we need to follow one pattern, use the full description 
-- This query attempts to standardize gender values to 'Female', 'Male', or 'n/a'.
-- However, it does not handle inconsistent casing, extra spaces, or special characters in the 'gen' column,
-- so values like 'female', ' MALE ', or 'FEMALE\r\n' will not be matched and will be set to 'n/a'.
SELECT DISTINCT
    CASE 
        WHEN gen IN ('F','FEMALE') THEN 'Female'
        WHEN gen IN ('M','MALE')   THEN 'Male'
        ELSE 'n/a'
    END AS gen_fixed,
    gen
FROM bronze.erp_cust_az12