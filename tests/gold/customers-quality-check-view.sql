/*
============================================================
Gold Layer - Customer Dimension View Quality Validation
============================================================
Script Purpose:
    Quick validation queries to verify the gold.dim_customers view
    returns expected data after it's been created.

Quality Checks Performed:
    1. View Accessibility: Verify view can be queried
    2. Data Completeness: Check all customers are present
    3. Gender Standardization: Verify gender values are standardized

When to Run:
    - After creating/altering gold.dim_customers view
    - After dimension data refresh
    - As part of automated data quality monitoring
    - Before releasing view to end users/reports

Usage:
    These are simple SELECT statements to quickly validate view behavior.
    For comprehensive quality checks, use customers-quality-check.sql
*/

USE DataWarehouse
GO

/*
============================================================
CHECK 1: View Data Completeness
============================================================
Purpose:
    Verify the view returns data and contains all expected customers.

What to Check:
    - Row count matches expected customer count
    - All columns are populated as expected
    - No unexpected duplicates (DISTINCT should equal total count)
    - Surrogate keys (customer_key) are sequential and unique

Expected Behavior:
    - Row count should match silver.crm_cust_info (assuming no duplicates)
    - DISTINCT row count should equal total row count (no duplicates)
    - All customer_key values should be unique
*/
--- Check 1: Verify view returns data and contains all expected rows

SELECT DISTINCT *
FROM gold.dim_customers

/*
============================================================
CHECK 2: Gender Value Standardization
============================================================
Purpose:
    Verify gender values are properly standardized and limited to expected values.

Expected Values:
    - 'Female': From CRM or ERP
    - 'Male': From CRM or ERP
    - 'n/a': Default when both sources are missing/invalid

What to Check:
    - Only these 3 values should appear (no raw 'F', 'M', 'FEMALE', etc.)
    - Count distribution across values
    - No NULL values (should be 'n/a' instead due to COALESCE logic)
    - No unexpected/misspelled values

Data Quality Insight:
    - High percentage of 'n/a' → Poor data quality in source systems
    - Unexpected values → Standardization logic needs adjustment
    - NULL values → Logic error in view (should never happen with COALESCE)
*/
--- Check 2: Verify gender standardization and value distribution

SELECT DISTINCT gender
FROM gold.dim_customers
