/*
============================================================
Initialize CRM Tables in Bronze Schema
============================================================
Script Purpose:
    This script creates the bronze layer tables for CRM data in the DataWarehouse.
    It sets up three main tables: customer information, product information, 
    and sales details. Each table is dropped and recreated to ensure a clean state.

Tables Created:
    - bronze.crm_cust_info: Customer demographic and profile information
    - bronze.crm_prd_info: Product catalog and lifecycle data
    - bronze.crm_sales_details: Sales transaction records

WARNING:
    Running this script will drop existing CRM tables in the bronze schema if they exist.
    All data in these tables will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE DataWarehouse;
GO

-- ============================================================
-- Customer Information Table
-- ============================================================
-- Drop and recreate customer information table
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info
(
    cst_id INT,                     -- Customer ID (primary identifier)
    cst_key NVARCHAR(50),          -- Customer business key
    cst_firstname NVARCHAR(50),    -- Customer first name
    cst_lastname NVARCHAR(50),     -- Customer last name
    cst_marital_status NVARCHAR(50), -- Marital status
    cst_gndr NVARCHAR(50),         -- Gender
    cst_create_date DATE           -- Customer creation date
);
GO

-- ============================================================
-- Product Information Table
-- ============================================================
-- Drop and recreate product information table
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info
(
    prd_id INT,                    -- Product ID (primary identifier)
    prd_key NVARCHAR(50),         -- Product business key
    prd_nm NVARCHAR(50),          -- Product name
    prd_cost INT,                 -- Product cost
    prd_line NVARCHAR(50),        -- Product line/category
    prd_start_dt DATE,            -- Product availability start date
    prd_end_dt DATE               -- Product availability end date
);
GO

-- ============================================================
-- Sales Details Table
-- ============================================================
-- Drop and recreate sales details table
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num NVARCHAR(50),     -- Sales order number
    sls_prd_key NVARCHAR(50),     -- Product key (foreign key reference)
    sls_cust_id INT,              -- Customer ID (foreign key reference)
    sls_order_dt INT,             -- Order date (integer format)
    sls_ship_dt INT,              -- Ship date (integer format)
    sls_due_dt INT,               -- Due date (integer format)
    sls_sales INT,                -- Sales amount
    sls_quantity INT,             -- Quantity sold
    sls_price INT                 -- Unit price
);
GO