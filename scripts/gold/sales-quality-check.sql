/*
============================================================
Gold Layer - Sales Fact Quality Checks
============================================================
Script Purpose:
    Validates data quality and referential integrity for the sales fact table
    before finalizing the gold.fact_sales view definition.

Quality Checks Performed:
    1. Dimension Key Propagation: Verify customer_key and product_key are correctly joined
    2. Referential Integrity: Identify orphaned transactions (missing dimension references)

When to Run:
    - During development/testing of fact_sales view
    - After dimension views are created/updated
    - After silver layer sales data refreshes
    - When investigating sales reporting discrepancies

Expected Results:
    - Ideally ZERO orphaned transactions
    - Any orphaned records indicate data quality issues requiring investigation

Critical Business Impact:
    - Orphaned transactions cannot be properly analyzed by customer or product
    - Revenue metrics may be incomplete if orphaned records are filtered
    - Dimension filters will exclude orphaned sales (customer/product reports understated)
*/

USE DataWarehouse
GO

/*
============================================================
STEP 1: Relationship Validation & Key Propagation
============================================================
Purpose:
    Verify that sales transactions successfully join to dimension tables
    and surrogate keys (customer_key, product_key) are properly propagated.

What to Check:
    - customer_key: Should match customers in dim_customers
    - product_key: Should match products in dim_products
    - NULL keys: Indicate missing dimension records (orphaned transactions)

Data Quality Metrics:
    - % of transactions with valid customer_key (should be ~100%)
    - % of transactions with valid product_key (should be ~100%)
    - Null key patterns: Random or clustered (specific time period/source)?

Edge Cases:
    - Transactions for deleted/inactive products: product_key will be NULL if product prd_end_dt IS NOT NULL
    - Transactions for customers not in CRM: customer_key will be NULL
    - New transactions before dimension load: May temporarily have NULL keys
*/
--- Step 1: Verify dimension key propagation and basic relationships

SELECT
    cs.sls_ord_num,
    pr.product_key,      -- Should have value if product exists in dim_products
    cu.customer_key,     -- Should have value if customer exists in dim_customers
    cs.sls_order_dt,
    cs.sls_ship_dt,
    cs.sls_due_dt,
    cs.sls_sales,
    cs.sls_quantity,
    cs.sls_price
FROM silver.crm_sales_details AS cs
    LEFT JOIN gold.dim_customers AS cu
    ON cu.customer_id = cs.sls_cust_id
    LEFT JOIN gold.dim_products AS pr
    ON pr.product_number = cs.sls_prd_key

/*
============================================================
STEP 2: Orphaned Customer Transactions (CRITICAL)
============================================================
Purpose:
    Identify sales transactions with invalid customer references.
    These are transactions where sls_cust_id doesn't match any customer in dim_customers.

Expected Result:
    ZERO ROWS - Any rows indicate data quality issues

Root Causes of Orphaned Customers:
    1. Customer data quality:
       - sls_cust_id in sales doesn't exist in silver.crm_cust_info
       - Customer was deleted/purged from CRM but sales history retained
       - Data type mismatch between sls_cust_id and cst_id
    
    2. Timing issues:
       - Sale occurred before customer record created (temporal data issue)
       - Customer record not yet loaded to data warehouse
    
    3. Source system issues:
       - Different customer ID namespaces between sales and customer systems
       - Test/dummy transactions with fake customer IDs

Business Impact:
    - Revenue from orphaned transactions is accurate but cannot be attributed to customers
    - Customer analytics will understate revenue (missing these transactions)
    - Customer segmentation/filtering excludes these sales
    - Geographic/demographic analysis incomplete

Actions to Take:
    1. Identify patterns:
       - Count by date: Are these old transactions or recent?
       - Sum sales_amount: What $ volume is affected?
       - List unique sls_cust_id values: Can they be researched?
    
    2. Investigation:
       - Check if sls_cust_id exists in bronze.crm_cust_info (bypassed by silver logic?)
       - Verify customer ID format/encoding is consistent
       - Contact business users about legitimate customer IDs
    
    3. Resolution options:
       - Create "Unknown Customer" record in dimension (surrogate for orphans)
       - Fix customer data and reload
       - If test data, filter from fact table
       - Document as known limitation if unavoidable
*/
--- Step 2: Check for orphaned customer transactions (WHERE customer_key IS NULL)

SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers as c
on c.customer_key = s.customer_key 
WHERE c.customer_key IS NULL        -- Transactions with no matching customer

/*
============================================================
STEP 3: Orphaned Product Transactions (CRITICAL)
============================================================
Purpose:
    Identify sales transactions with invalid product references.
    These are transactions where sls_prd_key doesn't match any product in dim_products.

Expected Result:
    ZERO ROWS ideally - But some orphans may be expected for historical sales

Root Causes of Orphaned Products:
    1. SCD Type 2 limitation (COMMON and EXPECTED):
       - dim_products only shows CURRENT products (prd_end_dt IS NULL)
       - Historical sales reference old product versions (prd_end_dt NOT NULL)
       - These products exist in silver.crm_prd_info but excluded from dim_products
       - This is a known trade-off of current-state dimension design
    
    2. Product data quality:
       - sls_prd_key in sales doesn't exist anywhere in silver.crm_prd_info
       - Product was deleted/archived from product master
       - Data type or format mismatch between sales and product keys
    
    3. Timing issues:
       - Sale occurred before product record created
       - Product record not yet loaded to data warehouse
    
    4. Source system issues:
       - Different product key formats between sales and product systems
       - Test/dummy transactions with fake product keys

Business Impact:
    - Revenue from orphaned transactions is accurate but cannot be attributed to products
    - Product analytics will understate revenue (missing these transactions)
    - Product filtering/segmentation excludes these sales
    - Category/product line analysis incomplete

Actions to Take:
    1. Distinguish between SCD Type 2 orphans vs. true orphans:
       - Query: Check if sls_prd_key exists in silver.crm_prd_info (any prd_end_dt value)
       - If EXISTS: Expected orphan due to historical product version → Consider point-in-time dimension
       - If NOT EXISTS: True data quality issue → Investigate further
    
    2. Investigation for true orphans:
       - Count by date: Old transactions or recent?
       - Sum sales_amount: What $ volume is affected?
       - List unique sls_prd_key values: Can they be researched?
       - Check bronze layer for these product keys
    
    3. Resolution options:
       - For SCD Type 2 orphans: 
         * Create point-in-time product dimension (includes historical versions)
         * Store product attributes in fact table (denormalize)
         * Accept limitation and document for users
       
       - For true orphans:
         * Create "Unknown Product" record in dimension (surrogate for orphans)
         * Fix product data and reload
         * If test data, filter from fact table
         * Document as known limitation if unavoidable

Note on Historical Analysis:
    If many orphans are due to SCD Type 2, consider implementing:
    - Point-in-time dimension: Join fact to product version valid at transaction date
    - Type 1 dimension: Only track current state, lose history
    - Hybrid: Store critical attributes (category, product line) in fact table
*/
--- Step 3: Check for orphaned product transactions (WHERE product_key IS NULL)

SELECT
  *
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products as p
on p.product_key = s.product_key
WHERE p.product_key IS NULL         -- Transactions with no matching product

