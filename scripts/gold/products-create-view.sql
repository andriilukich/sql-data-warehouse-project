/*
============================================================
Gold Layer - Product Dimension View
============================================================
View Name: gold.dim_products

Purpose:
    Creates a unified product dimension by integrating data from multiple source systems:
    - CRM system (silver.crm_prd_info): Master source for product catalog
    - ERP system (silver.erp_px_cat_g1v2): Product category and maintenance information

Business Logic:
    - Uses CRM as the primary/master data source for product information
    - Enriches CRM data with ERP category hierarchy and maintenance details
    - Implements Type 2 Slowly Changing Dimension (SCD Type 2) filtering
    - Generates surrogate keys (product_key) for dimensional modeling

Key Transformations:
    1. Surrogate Key Generation:
       - ROW_NUMBER() creates a unique product_key for each active product
       - Ordered by prd_start_dt, prd_key to ensure consistent key assignment
       - Keys change when product attributes change (SCD Type 2 pattern)

    2. SCD Type 2 Filtering (Critical for Historical Accuracy):
       - WHERE prd_end_dt IS NULL: Returns only CURRENT/ACTIVE product versions
       - Products with prd_end_dt NOT NULL are historical versions
       - This ensures fact tables join to the correct product version based on transaction date
       - Edge case: New product versions get new product_key values

    3. Category Integration:
       - Joins to ERP category table using cat_id
       - Provides hierarchical product classification (category → subcategory)
       - LEFT JOIN allows products without ERP category mapping

Data Relationships:
    - Join Key: cat_id (CRM) = id (ERP category table)
    - One-to-one relationship expected (one product → one category)
    - Multiple category matches would indicate data quality issue

Column Mapping:
    - product_key: Generated surrogate key (for fact table joins)
    - product_id: Natural key from CRM (prd_id)
    - product_number: Business key from CRM (prd_key)
    - product_name: Descriptive name (prd_nm)
    - category_id: Category identifier (cat_id)
    - category: Category name from ERP
    - subcategory: Subcategory name from ERP
    - maintenance: Maintenance flag/code from ERP
    - cost: Product cost (prd_cost)
    - product_line: Product line classification (prd_line)
    - start_date: Effective start date for this product version (SCD Type 2)

Edge Cases Handled:
    1. Historical Product Versions: Filtered out by prd_end_dt IS NULL condition
    2. Missing ERP Category: LEFT JOIN allows products without category mapping (NULLs acceptable)
    3. Product Attribute Changes: Create new version in source, this view shows latest only
    4. Newly Added Products: Included as long as prd_end_dt is NULL

Quality Considerations:
    - Verify prd_end_dt is properly maintained in silver layer (previous version should be closed)
    - Check for products without category mapping (category, subcategory will be NULL)
    - Validate product_number uniqueness among active products
    - Monitor orphaned category records (exist in ERP but no active products reference them)
    - Ensure fact tables use product_key (not product_number) for accurate historical reporting

Important Note on Time Travel:
    For historical analysis, fact tables should store product_key at transaction time.
    This view only shows CURRENT state. Historical product attributes require
    joining fact tables to the product dimension using point-in-time logic.
*/

USE DataWarehouse
GO

CREATE VIEW gold.dim_products
AS
    SELECT
        -- Surrogate key for dimensional modeling (unique identifier for each active product)
        ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
        
        -- Natural and business keys
        pi.prd_id AS product_id,           -- CRM product ID (natural key)
        pi.prd_key AS product_number,      -- Business key used across systems
        
        -- Product attributes from CRM (master source)
        pi.prd_nm AS product_name,
        pi.prd_cost AS cost,
        pi.prd_line AS product_line,
        pi.prd_start_dt AS start_date,     -- Effective date for this product version (SCD Type 2)
        
        -- Category hierarchy from ERP
        pi.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pc.maintenance

    FROM silver.crm_prd_info AS pi
        -- Enrich with ERP category hierarchy
        LEFT JOIN silver.erp_px_cat_g1v2 AS pc
            ON pc.id = pi.cat_id
    -- SCD Type 2 Filter: Only include CURRENT/ACTIVE product versions
    -- Products with prd_end_dt NOT NULL are historical and excluded
    WHERE pi.prd_end_dt IS NULL
