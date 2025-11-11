/*
============================================================
Gold Layer - Product Dimension Quality Checks
============================================================
Script Purpose:
    Validates data quality and business rules for the product dimension
    before finalizing the gold.dim_products view definition.

Quality Checks Performed:
    1. SCD Type 2 Filter Validation: Verify only current products are selected
    2. Relationship Validation: Verify CRM-ERP category joins work correctly
    3. Uniqueness Check: Ensure one row per active product (no duplicates)

When to Run:
    - During development/testing of dim_products view
    - After silver layer data refreshes
    - When investigating product data quality issues
    - Before promoting view changes to production

Expected Results:
    - Step 1: Should return only products with prd_end_dt IS NULL (current versions)
    - Step 2: Should return ZERO rows (no duplicate prd_key among active products)

Important Notes:
    - Historical product versions (prd_end_dt NOT NULL) are intentionally excluded
    - This impacts historical sales analysis - fact tables must store product attributes at transaction time
*/

USE DataWarehouse
GO

/*
============================================================
STEP 1: SCD Type 2 Filter Validation
============================================================
Purpose:
    Verify the Slowly Changing Dimension Type 2 logic works correctly:
    - Only CURRENT/ACTIVE product versions are included (prd_end_dt IS NULL)
    - Historical versions are properly excluded
    - Products are correctly closed when attributes change

What to Check:
    - All returned products have prd_end_dt = NULL
    - Row count represents current product catalog size
    - No historical versions included (they should have prd_end_dt populated)

Business Impact:
    - Reports using dim_products show current product state only
    - Historical sales may reference products not in this view (if product changed)
    - Consider point-in-time dimension for accurate historical analysis

Edge Cases to Consider:
    1. Product created today: prd_start_dt = today, prd_end_dt = NULL → INCLUDED
    2. Product updated yesterday: old version has prd_end_dt = yesterday, new version has prd_end_dt = NULL → Only new version INCLUDED
    3. Discontinued product: prd_end_dt set to discontinuation date → EXCLUDED
    4. Product with no changes: original version still has prd_end_dt = NULL → INCLUDED
*/
--- Step 1: Filter to current products only (SCD Type 2 implementation)

SELECT
    pi.prd_id,
    pi.cat_id,
    pi.prd_key,
    pi.prd_nm,
    pi.prd_cost,
    pi.prd_line,
    pi.prd_start_dt
FROM silver.crm_prd_info AS pi
WHERE pi.prd_end_dt IS NULL -- CRITICAL: Only current/active products

/*
============================================================
STEP 2: Relationship & Uniqueness Validation (CRITICAL)
============================================================
Purpose:
    Verify data quality after joining to ERP category table:
    - Product-to-category relationship is one-to-one
    - No duplicate prd_key values among active products
    - Category enrichment doesn't create duplicates

Expected Result:
    ZERO ROWS - If any rows returned, this is a CRITICAL data quality issue

What Duplicates Mean:
    1. Multiple active versions of same product (prd_key):
       - Silver layer SCD Type 2 logic failed to close previous version
       - Multiple products incorrectly share same prd_key
       
    2. One-to-many relationship with category table:
       - Same cat_id maps to multiple category records (data quality issue in ERP)
       - JOIN creates cartesian product

Impact of Duplicates:
    - Dimension will have duplicate products with different product_key values
    - Fact table joins become ambiguous (one transaction → multiple dimension rows)
    - Metrics will be inflated (same sale counted multiple times)
    - ROW_NUMBER() for product_key becomes unreliable

Action if Duplicates Found:
    1. Check silver.crm_prd_info for duplicate prd_key where prd_end_dt IS NULL
       - Should only have ONE active version per prd_key
       - Previous versions should have prd_end_dt populated
    
    2. Check silver.erp_px_cat_g1v2 for duplicate category IDs
       - Each cat_id should have only one row
    
    3. Investigate silver layer SCD Type 2 logic:
       - Verify prd_end_dt calculation (LEAD function in silver layer)
       - Ensure product updates properly close previous version
    
    4. Temporary fixes (not recommended for production):
       - Add DISTINCT to view
       - Use ROW_NUMBER() to pick one version
       - Better: Fix root cause in silver layer

Quality Insights:
    - Products with NULL category fields: Not mapped to ERP categories (acceptable if intentional)
    - Products with category data: Successfully enriched from ERP
    - Compare row count before/after JOIN: Should be same (LEFT JOIN preserves all products)
*/
--- Step 2: Validate uniqueness and relationships - Should return ZERO rows

SELECT prd_key, COUNT(*) FROM (
SELECT
    pi.prd_id,
    pi.cat_id,
    pi.prd_key,
    pi.prd_nm,
    pi.prd_cost,
    pi.prd_line,
    pi.prd_start_dt,
    pc.cat,             -- From ERP category (may be NULL)
    pc.subcat,          -- From ERP category (may be NULL)
    pc.maintenance      -- From ERP category (may be NULL)

FROM silver.crm_prd_info AS pi
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pc.id = pi.cat_id
WHERE pi.prd_end_dt IS NULL)AS t -- Only active products
GROUP BY prd_key
HAVING COUNT(*) > 1              -- Find duplicates
