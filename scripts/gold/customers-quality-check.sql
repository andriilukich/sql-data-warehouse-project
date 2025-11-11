/*
============================================================
Gold Layer - Customer Dimension Quality Checks
============================================================
Script Purpose:
    Validates data quality and business rules for the customer dimension
    before finalizing the gold.dim_customers view definition.

Quality Checks Performed:
    1. Relationship Validation: Verify CRM-ERP joins work correctly
    2. Uniqueness Check: Ensure one row per customer (no duplicates)
    3. Gender Logic Validation: Verify gender fallback logic behaves correctly

When to Run:
    - During development/testing of dim_customers view
    - After silver layer data refreshes
    - When investigating data quality issues
    - Before promoting view changes to production

Expected Results:
    - Step 1: Should return data with proper LEFT JOIN relationships
    - Step 2: Should return ZERO rows (no duplicate cst_id values)
    - Step 3: Should show all gender combinations and verify fallback logic
*/

USE DataWarehouse
GO

/*
============================================================
STEP 1: Relationship Validation
============================================================
Purpose:
    Test the join logic between CRM and ERP tables to verify:
    - All CRM customers are included (LEFT JOIN behavior)
    - ERP data properly enriches CRM records
    - Join keys (cst_key = cid) match correctly

What to Check:
    - Rows with NULL bdate/gen/cntry: CRM customers without ERP data
    - Row count matches silver.crm_cust_info count (LEFT JOIN preserves all CRM rows)
    - No unexpected duplicates at this stage

Edge Cases to Verify:
    - Customers with CRM data only (no ERP match)
    - Customers with complete data from both systems
    - Customers with partial ERP data (e.g., has location but no demographics)
*/
--- Step 1: Build relationships and verify join logic

SELECT
    ci.cst_id,
    ci.cst_key,
    cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,           -- From ERP demographics (may be NULL)
    ca.gen,             -- From ERP demographics (may be NULL)
    la.cntry            -- From ERP location (may be NULL)

FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
    ON ca.cid = ci.cst_key
    LEFT JOIN silver.erp_loc_a101 AS la
    ON la.cid = ci.cst_key

/*
============================================================
STEP 2: Uniqueness Validation (CRITICAL)
============================================================
Purpose:
    Verify that each customer ID (cst_id) appears only once in the result set.
    Multiple rows per customer indicate:
    - One-to-many relationship in ERP data (data quality issue)
    - Incorrect join logic
    - Duplicate records in source tables

Expected Result:
    ZERO ROWS - If any rows returned, this is a CRITICAL data quality issue

What Duplicates Mean:
    - Same customer matched to multiple ERP records
    - dimension view will have duplicate customers with different keys
    - Fact table joins will be incorrect (one transaction → multiple dimension rows)

Action if Duplicates Found:
    1. Investigate ERP tables for duplicate cid values
    2. Determine which ERP record is correct (most recent, flagged as primary, etc.)
    3. Update silver layer logic to deduplicate before gold layer
    4. Consider adding DISTINCT or ROW_NUMBER() in dim_customers view as temporary fix
*/
--- Step 2: Check uniqueness - Should return ZERO rows

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

/*
============================================================
STEP 3: Gender Logic Validation
============================================================
Purpose:
    Verify the gender fallback logic works correctly:
    - CRM gender (cst_gndr) takes priority when not 'n/a'
    - ERP gender (ca.gen) used as fallback when CRM is 'n/a'
    - Default to 'n/a' when both are missing/invalid

What to Look For:
    - new_gen should NEVER be NULL (always has a value due to COALESCE)
    - When cst_gndr != 'n/a', new_gen should match cst_gndr (CRM priority)
    - When cst_gndr = 'n/a' and ca.gen exists, new_gen should match ca.gen (ERP fallback)
    - When both are 'n/a'/NULL, new_gen should be 'n/a' (default)

Edge Cases to Verify:
    1. CRM='Female', ERP='Male' → Result: 'Female' (CRM wins)
    2. CRM='n/a', ERP='Male' → Result: 'Male' (ERP fallback)
    3. CRM='n/a', ERP=NULL → Result: 'n/a' (default)
    4. CRM='Male', ERP=NULL → Result: 'Male' (CRM priority)

Data Quality Insights:
    - High count of 'n/a' → poor data quality in both systems
    - Conflicts (CRM != ERP when both have values) → investigate source system rules
    - NULL ERP gender → customers not in ERP or ERP missing demographic data
*/
--- Step 3: Validate gender fallback logic and check distinct combinations

SELECT DISTINCT
    ci.cst_gndr,        -- CRM gender value
    ca.gen,             -- ERP gender value
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr      -- CRM priority
        ELSE COALESCE(ca.gen, 'n/a')                     -- ERP fallback, default 'n/a'
    END AS new_gen      -- Final gender value used in dim_customers
FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_cust_az12 AS ca
    ON ca.cid = ci.cst_key
    ORDER BY 1,2
