/*
============================================================
Bronze Layer - CRM Data Bulk Insert
============================================================
Script Purpose:
    This script loads raw CRM data into the bronze schema tables within the 'DataWarehouse' database.
    The bronze layer represents the raw, unprocessed data as it arrives from source systems.

Prerequisites:
    1. The 'DataWarehouse' database must exist (created by init_database.sql)
    2. Bronze schema tables must be created and structured to match CSV data
    3. CSV files must be accessible from the Docker container

Required Setup Steps:
    Before running this script, ensure the CSV files are accessible to the container:
    
    Step 1: Create the directory structure on your host machine
    mkdir -p ~/docker-volumes/sql-data/source_crm
    
    Step 2: Copy your CSV files to the mounted volume
    cp path-to-your-file/cust_info.csv ~/docker-volumes/sql-data/source_crm/
    cp path-to-your-file/prd_info.csv ~/docker-volumes/sql-data/source_crm/
    cp path-to-your-file/sales_details.csv ~/docker-volumes/sql-data/source_crm/
    
    Step 3: Verify the files are accessible from the container
    docker exec -it azure-sql-edge ls -la /data/source_crm/

Data Flow:
    Source System → CSV Files → Bronze Tables (Raw Data)
    
Tables Updated:
    - bronze.crm_cust_info: Customer information from CRM system
    - bronze.crm_prd_info: Product information from CRM system  
    - bronze.crm_sales_details: Sales transaction details from CRM system

Note:
    - TRUNCATE operations clear existing data before each load
    - FIRSTROW = 2 skips the CSV header row
    - FIELDTERMINATOR = ',' handles comma-delimited format
    - TABLOCK improves bulk insert performance
*/

USE DataWarehouse;

-- Load Customer Information into Bronze Layer
-- Clear existing data and load fresh customer data from CRM system
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM '/data/source_crm/cust_info.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock for better performance
)

-- Load Product Information into Bronze Layer  
-- Clear existing data and load fresh product data from CRM system
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM '/data/source_crm/prd_info.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock for better performance
)

-- Load Sales Details into Bronze Layer
-- Clear existing data and load fresh sales transaction data from CRM system
TRUNCATE TABLE bronze.crm_sales_details;
BULK INSERT bronze.crm_sales_details
FROM '/data/source_crm/sales_details.csv'
WITH (
    FIRSTROW = 2,           -- Skip header row
    FIELDTERMINATOR = ',',  -- Comma-delimited CSV
    TABLOCK                 -- Table lock
)