/*
============================================================
Gold Layer - Product Dimension View Quality Validation
============================================================
Script Purpose:
    Quick validation query to verify the gold.dim_products view
    returns expected data after it's been created.

Quality Checks Performed:
    1. View Accessibility: Verify view can be queried
    2. Data Completeness: Check active products are present
    3. SCD Type 2 Filter: Verify only current products are included

When to Run:
    - After creating/altering gold.dim_products view
    - After dimension data refresh
    - As part of automated data quality monitoring
    - Before releasing view to end users/reports
    - When product catalog is updated

Usage:
    This is a simple SELECT statement to quickly validate view behavior.
    For comprehensive quality checks, use products-quality-check.sql

Important Notes:
    - Only CURRENT/ACTIVE products appear (prd_end_dt IS NULL)
    - Historical product versions are intentionally excluded
    - Row count should match active products in silver.crm_prd_info
*/

USE DataWarehouse
GO

/*
============================================================
CHECK: View Data Completeness & Current Products Only
============================================================
Purpose:
    Verify the view returns data and contains only current/active products.

What to Check:
    - Row count matches active product count (prd_end_dt IS NULL in silver layer)
    - All columns are populated as expected
    - No unexpected duplicates (DISTINCT should equal total count)
    - Surrogate keys (product_key) are sequential and unique
    - Only products with NULL prd_end_dt are included (current versions)

Expected Behavior:
    - Row count < total silver.crm_prd_info (excludes historical versions)
    - DISTINCT row count should equal total row count (no duplicates)
    - All product_key values should be unique
    - No products with prd_end_dt NOT NULL should appear

Data Quality Checks:
    1. Compare row count to expected product catalog size
    2. Verify category/subcategory enrichment (check for NULLs)
    3. Check for reasonable start_date values
    4. Validate cost values are positive (if business rule applies)
    5. Ensure product_line values are standardized

Common Issues:
    - Row count too high: Duplicate products (check products-quality-check.sql)
    - Row count too low: Products incorrectly marked as inactive (prd_end_dt set)
    - NULL categories: Products not mapped to ERP categories (may be expected)
    - Historical products appearing: View filter logic broken (critical issue)
*/
--- Verify view returns only current/active products with all columns populated

SELECT DISTINCT *
FROM gold.dim_products
