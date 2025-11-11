/*
============================================================
Gold Layer - Customer Dimension View
============================================================
View Name: gold.dim_customers

Purpose:
    Creates a unified customer dimension by integrating data from multiple source systems:
    - CRM system (silver.crm_cust_info): Master source for customer profile
    - ERP system (silver.erp_cust_az12): Additional demographic data (birthdate, gender)
    - ERP system (silver.erp_loc_a101): Geographic/location data (country)

Business Logic:
    - Uses CRM as the primary/master data source for customer information
    - Enriches CRM data with ERP demographic and location attributes
    - Generates surrogate keys (customer_key) for dimensional modeling
    - Implements fallback logic for missing/inconsistent gender data

Key Transformations:
    1. Surrogate Key Generation:
       - ROW_NUMBER() creates a unique customer_key for each customer
       - Ordered by cst_id to ensure consistent key assignment

    2. Gender Field Logic (Handles Data Quality Issues):
       - Primary source: CRM gender (cst_gndr)
       - If CRM gender is 'n/a' → fallback to ERP gender (ca.gen)
       - If both are missing → default to 'n/a'
       - Edge case: Resolves conflicts between source systems by prioritizing CRM

    3. Data Integration Pattern:
       - LEFT JOIN ensures all CRM customers are included
       - Missing ERP data results in NULL values (acceptable for optional attributes)

Data Relationships:
    - Join Key: cst_key (CRM) = cid (ERP)
    - One-to-one expected relationship between CRM and ERP customer records
    - Multiple ERP records for same customer would create duplicates (validate with quality checks)

Column Mapping:
    - customer_key: Generated surrogate key (for fact table joins)
    - customer_id: Natural key from CRM (cst_id)
    - customer_number: Business key from CRM (cst_key), used for ERP joins
    - first_name, last_name: From CRM
    - country: From ERP location table
    - marital_status: From CRM
    - gender: Merged from CRM (priority) and ERP (fallback)
    - birthdate: From ERP demographic table
    - create_date: Customer record creation timestamp from CRM

Edge Cases Handled:
    1. Missing ERP data: LEFT JOIN allows CRM-only customers (ERP fields will be NULL)
    2. Gender conflicts: CRM data takes precedence over ERP
    3. Missing gender in both systems: Defaults to 'n/a'
    4. Customer exists in ERP but not CRM: Will NOT appear (CRM is master)

Quality Considerations:
    - Verify no duplicate customer_id values in source
    - Check for orphaned ERP records (exist in ERP but not CRM)
    - Validate gender values are standardized
    - Monitor NULL percentages for ERP-sourced fields
*/

USE DataWarehouse
GO

CREATE VIEW gold.dim_customers AS 
SELECT
    -- Surrogate key for dimensional modeling (ensures uniqueness and stability)
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    
    -- Natural and business keys
    ci.cst_id AS customer_id,          -- CRM customer ID (natural key)
    ci.cst_key AS customer_number,     -- Business key used across systems
    
    -- Customer profile attributes from CRM (master source)
    cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    ci.cst_marital_status AS marital_status,
    ci.cst_create_date AS create_date,
    
    -- Geographic attributes from ERP location data
    la.cntry AS country,
    
    -- Gender with fallback logic: CRM takes priority, ERP as fallback, 'n/a' if both missing
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,
    
    -- Demographic attributes from ERP
    ca.bdate AS birthdate

FROM silver.crm_cust_info AS ci
    -- Enrich with ERP demographic data (birthdate, gender)
    LEFT JOIN silver.erp_cust_az12 AS ca
        ON ca.cid = ci.cst_key
    -- Enrich with ERP location data (country)
    LEFT JOIN silver.erp_loc_a101 AS la
        ON la.cid = ci.cst_key
