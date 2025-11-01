/*
============================================================
Initialize ERP Tables in Bronze Schema
============================================================
Script Purpose:
    This script creates the bronze layer tables for ERP data in the DataWarehouse.
    It sets up three main tables: customer information, location data, 
    and product category details. Each table is dropped and recreated to ensure a clean state.

Tables Created:
    - bronze.erp_cust_az12: Customer demographic information from ERP system
    - bronze.erp_loc_a101: Customer location and country data
    - bronze.erp_px_cat_g1v2: Product category and subcategory classification

WARNING:
    Running this script will drop existing ERP tables in the bronze schema if they exist.
    All data in these tables will be permanently deleted. Proceed with caution
    and ensure you have proper backups before running this script.
*/

USE DataWarehouse;
GO

-- ============================================================
-- ERP Customer Information Table
-- ============================================================
-- Drop and recreate ERP customer information table
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12
(
    cid NVARCHAR(50),              -- Customer identifier
    bdate DATE,                    -- Birth date
    gen NVARCHAR(50),              -- Gender
);
GO

-- ============================================================
-- ERP Location Information Table
-- ============================================================
-- Drop and recreate ERP location information table
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101
(
    cid NVARCHAR(50),              -- Customer identifier
    cntry NVARCHAR(50),            -- Country
);
GO

-- ============================================================
-- ERP Product Category Table
-- ============================================================
-- Drop and recreate ERP product category table
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2
(
    id NVARCHAR(50),               -- Product identifier
    cat NVARCHAR(50),              -- Product category
    subcat NVARCHAR(50),           -- Product subcategory
    maintenance NVARCHAR(50),      -- Maintenance
);
GO