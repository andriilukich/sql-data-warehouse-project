/*
============================================================
Bronze Layer - ERP Data Bulk Insert
============================================================
Script Purpose:
    This script loads raw ERP data into the bronze schema tables within the 'DataWarehouse' database.
    The bronze layer represents the raw, unprocessed data as it arrives from source systems.

Prerequisites:
    1. The 'DataWarehouse' database must exist (created by init_database.sql)
    2. Bronze schema tables must be created and structured to match CSV data
    3. CSV files must be accessible from the Docker container

Required Setup Steps:
    Before running this script, ensure the CSV files are accessible to the container:
    
    Step 1: Create the directory structure on your host machine
    mkdir -p ~/docker-volumes/sql-data/source_erp
    
    Step 2: Copy your CSV files to the mounted volume
    cp path-to-your-file/CUST_AZ12.csv ~/docker-volumes/sql-data/source_erp/
    cp path-to-your-file/LOC_A101.csv ~/docker-volumes/sql-data/source_erp/
    cp path-to-your-file/PX_CAT_G1V2.csv ~/docker-volumes/sql-data/source_erp/
    
    Step 3: Verify the files are accessible from the container
    docker exec -it azure-sql-edge ls -la /data/source_erp/

Data Flow:
    Source System → CSV Files → Bronze Tables (Raw Data)
    
Tables Updated:
    - bronze.erp_cust_az12: Customer information from ERP system
    - bronze.erp_loc_a101: Location information from ERP system  
    - bronze.erp_px_cat_g1v2: Product category details from ERP system

Note:
    - TRUNCATE operations clear existing data before each load
    - FIRSTROW = 2 skips the CSV header row
    - FIELDTERMINATOR = ',' handles comma-delimited format
    - TABLOCK improves bulk insert performance
*/

USE DataWarehouse;

-- Load Customer Information into Bronze Layer
-- Clear existing data and load fresh customer data from ERP system
TRUNCATE TABLE bronze.erp_cust_az12;
BULK INSERT bronze.erp_cust_az12
FROM '/data/source_erp/CUST_AZ12.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock for better performance
)

-- Load Location Information into Bronze Layer  
-- Clear existing data and load fresh location data from ERP system
TRUNCATE TABLE bronze.erp_loc_a101;
BULK INSERT bronze.erp_loc_a101
FROM '/data/source_erp/LOC_A101.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock for better performance
)

-- Load Product Category Information into Bronze Layer
-- Clear existing data and load fresh product category data from ERP system
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
BULK INSERT bronze.erp_px_cat_g1v2
FROM '/data/source_erp/PX_CAT_G1V2.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock for better performance
)