/*
============================================================
Gold Layer - Sales Fact View
============================================================
View Name: gold.fact_sales

Purpose:
    Creates the central fact table for sales transactions by integrating:
    - Transactional data from CRM (silver.crm_sales_details)
    - Customer dimension (gold.dim_customers) for customer context
    - Product dimension (gold.dim_products) for product context

Business Logic:
    - Implements a star schema design pattern
    - Links transactional sales data to conformed dimensions
    - Replaces natural keys with surrogate dimension keys
    - Enables fast aggregation and filtering through dimensional model

Key Design Principles:
    1. Star Schema Pattern:
       - Fact table at center with measures (sales_amount, quantity, price)
       - References dimension tables via foreign keys (customer_key, product_key)
       - Denormalized for query performance

    2. Surrogate Key Propagation:
       - Joins to dimension views to get surrogate keys
       - customer_key: Links to dim_customers
       - product_key: Links to dim_products
       - These keys remain stable even when business keys change

    3. LEFT JOIN Strategy (Important):
       - Ensures ALL sales transactions are included in the fact table
       - If customer or product not found in dimension → key will be NULL
       - NULL keys indicate orphaned transactions (data quality issue)
       - Edge case: Allows reporting on sales even with missing dimensional context

Column Mapping:
    - order_number: Transaction identifier (sls_ord_num)
    - customer_key: Foreign key to dim_customers (surrogate key)
    - product_key: Foreign key to dim_products (surrogate key)
    - order_date: Date order was placed
    - shipping_date: Date order was shipped
    - due_date: Expected delivery date
    - sales_amount: Total sales value (revenue)
    - quantity: Number of units sold
    - price: Unit price

Measures (Aggregatable Facts):
    - sales_amount: Additive - can sum across all dimensions
    - quantity: Additive - can sum across all dimensions
    - price: Semi-additive - meaningful average, not meaningful sum

Dimensions (Foreign Keys):
    - customer_key: Who bought (links to dim_customers)
    - product_key: What was bought (links to dim_products)
    - order_date: When bought (time dimension - could link to date dimension)

Edge Cases Handled:
    1. Missing Customer Reference:
       - Transaction has sls_cust_id that doesn't exist in dim_customers
       - Result: customer_key will be NULL
       - Action: Flag for data quality investigation

    2. Missing Product Reference:
       - Transaction has sls_prd_key that doesn't exist in dim_products
       - Result: product_key will be NULL
       - Common cause: Product was active at transaction time but now inactive
       - Action: Consider historical product dimension or validate product lifecycle

    3. Date NULLs:
       - Source data may have NULL dates (validated in silver layer)
       - NULL dates preserved for transparency
       - Impact: Cannot filter/group by NULL dates in reports

    4. Order Line Items:
       - Each row represents one line item in a sales order
       - Same order_number may appear multiple times (different products)
       - Grain: One row per order line item

Quality Considerations:
    - Monitor NULL customer_key and product_key percentages (orphaned transactions)
    - Validate order_number uniqueness with product_key (or check for order line number)
    - Check for negative quantities or sales amounts (returns/refunds may be separate)
    - Verify date logic: order_date <= shipping_date <= due_date
    - Validate price * quantity ≈ sales_amount (business rule from silver layer)

Performance Tips:
    - Materialize this view as a table for large datasets
    - Index on customer_key, product_key, order_date for fast filtering
    - Pre-aggregate common metrics (daily sales, product sales) for dashboards
*/

USE DataWarehouse
GO

CREATE VIEW gold.fact_sales AS 
SELECT
    -- Transaction identifier
    cs.sls_ord_num AS order_number,
    
    -- Foreign keys to dimension tables (surrogate keys)
    cu.customer_key,                   -- Who: Links to dim_customers
    pr.product_key,                    -- What: Links to dim_products
    
    -- Time attributes (consider creating separate date dimension)
    cs.sls_order_dt AS order_date,     -- When: Order placed
    cs.sls_ship_dt AS shipping_date,   -- When: Order shipped
    cs.sls_due_dt AS due_date,         -- When: Expected delivery
    
    -- Measures (facts) - aggregatable numeric values
    cs.sls_sales AS sales_amount,      -- Additive measure: total revenue
    cs.sls_quantity AS quantity,       -- Additive measure: units sold
    cs.sls_price AS price              -- Semi-additive: unit price

FROM silver.crm_sales_details AS cs
    -- Join to customer dimension to get surrogate key
    -- LEFT JOIN ensures orphaned transactions are included (customer_key will be NULL)
    LEFT JOIN gold.dim_customers AS cu
        ON cu.customer_id = cs.sls_cust_id
    -- Join to product dimension to get surrogate key
    -- LEFT JOIN ensures orphaned transactions are included (product_key will be NULL)
    LEFT JOIN gold.dim_products AS pr
        ON pr.product_number = cs.sls_prd_key

