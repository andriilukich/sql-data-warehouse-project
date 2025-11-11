--- Check For Nulls or Duplicates in Primary Key
--- Expectation: No Result
USE DataWarehouse;
GO

SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- 1st Clean Version
SELECT
    *
FROM (SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
    -- WHERE cst_id = 29466
    WHERE cst_id IS NOT NULL) AS t
WHERE flag_last = 1

-- Check for unwanted Spaces
--- Expectation: No Result
-- Firstname
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

-- Lastname
SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- 2ed Clean Version
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) as cst_firstname,
    TRIM(cst_lastname) as cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM (SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL) AS t
WHERE flag_last = 1

--- Data Sandartization & Consistancy
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info

-- 3ed and Final Clean Version
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) as cst_firstname,
    TRIM(cst_lastname) as cst_lastname,
    CASE
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marital_status,
    CASE
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date
FROM (SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL) AS t
WHERE flag_last = 1