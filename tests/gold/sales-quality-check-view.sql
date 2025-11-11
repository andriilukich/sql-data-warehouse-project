/*
============================================================
Gold Layer - Sales Fact View Quality Validation
============================================================
Script Purpose:
    Quick validation queries to verify the gold.fact_sales view
    has proper referential integrity with dimension tables.

Quality Checks Performed:
    1. Orphaned Customer Transactions: Sales with invalid customer references
    2. Orphaned Product Transactions: Sales with invalid product references

When to Run:
    - After creating/altering gold.fact_sales view
    - After dimension views are created/updated
    - After fact data refresh
    - As part of automated data quality monitoring
    - When investigating revenue reporting discrepancies

Usage:
    These queries identify referential integrity violations.
    For comprehensive quality checks, use sales-quality-check.sql

Expected Results:
    - Ideally ZERO rows for both checks (perfect referential integrity)
    - Any rows indicate orphaned transactions requiring investigation

Critical Note:
    Orphaned transactions are still in fact_sales (due to LEFT JOIN)
    but have NULL customer_key or product_key, making them hard to analyze.
*/

USE DataWarehouse
GO

/*
============================================================
CHECK 1: Orphaned Customer Transactions
============================================================
Purpose:
    Identify sales transactions that cannot be linked back to dim_customers.
    These transactions have valid data but customer_key is NULL.

Expected Result:
    ZERO ROWS - Any rows indicate data quality issues

What This Means:
    - Sales exist in fact_sales with customer_key value
    - But that customer_key doesn't exist in dim_customers
    - This should be impossible with proper LEFT JOIN logic
    - If rows appear, it indicates a serious data integrity issue

Possible Causes:
    - Dimension view changed after fact view created (customer removed)
    - Transaction timing: Fact loaded before dimension
    - Surrogate key generation mismatch
    - View definition error

Impact:
    - These sales cannot be filtered/grouped by customer attributes
    - Customer reports will exclude this revenue
    - Total sales (fact_sales) won't match customer-attributed sales

Action Required:
    1. Verify dim_customers contains all expected customer_key values
    2. Check if fact_sales customer_key values are within expected range
    3. Refresh dimension before fact, or reload fact table
    4. If persistent, investigate view join logic
*/
--- Check 1: Find sales with customer_key that doesn't exist in dim_customers

SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers as c
on c.customer_key = s.customer_key 
WHERE c.customer_key IS NULL        -- Sales with orphaned customer references

/*
============================================================
CHECK 2: Orphaned Product Transactions
============================================================
Purpose:
    Identify sales transactions that cannot be linked back to dim_products.
    These transactions have valid data but product_key is NULL.

Expected Result:
    ZERO ROWS ideally - Some rows may be expected for historical products

What This Means:
    - Sales exist in fact_sales with product_key value
    - But that product_key doesn't exist in dim_products
    - May be expected if dim_products only shows current products (SCD Type 2)
    - Could also indicate data quality issues

Possible Causes (Expected):
    1. SCD Type 2 Design (COMMON and ACCEPTABLE):
       - dim_products shows only CURRENT products (prd_end_dt IS NULL)
       - Historical sales reference old product versions
       - Those old versions excluded from dim_products
       - Result: Historical sales have NULL product_key when joined to current-state dimension

Possible Causes (Data Quality Issues):
    2. Dimension view changed after fact view created (product removed)
    3. Transaction timing: Fact loaded before dimension
    4. Surrogate key generation mismatch
    5. Product doesn't exist anywhere in product master

Impact:
    - These sales cannot be filtered/grouped by product attributes
    - Product reports will exclude this revenue
    - Total sales (fact_sales) won't match product-attributed sales
    - Category/product line analysis incomplete

Action Required:
    1. Determine if orphans are due to SCD Type 2 or data quality:
       - Query if sales product_number exists in silver.crm_prd_info (any version)
       - If YES: Expected due to historical product → Document or fix dimension design
       - If NO: Data quality issue → Investigate source data
    
    2. For SCD Type 2 orphans, consider:
       - Point-in-time product dimension (include historical versions)
       - Store product attributes directly in fact table
       - Create "Unknown/Historical Product" record in dimension
       - Accept limitation and document for end users
    
    3. For data quality orphans:
       - Fix product master data and reload
       - Create placeholder product records
       - Filter invalid transactions from fact table
*/
--- Check 2: Find sales with product_key that doesn't exist in dim_products

SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products as p
on p.product_key = s.product_key
WHERE p.product_key IS NULL         -- Sales with orphaned product references
