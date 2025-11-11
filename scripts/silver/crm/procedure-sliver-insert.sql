USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver_crm
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT '======================================================';
        PRINT 'Loading silver Layer (CRM)';
        PRINT '======================================================';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info
        (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date)
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) as cst_firstname,
        TRIM(cst_lastname) as cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END cst_marital_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END cst_gndr,
        cst_create_date
    FROM (SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL) AS t
    WHERE flag_last = 1

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        INSERT INTO silver.crm_prd_info
            (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
            )
        SELECT prd_id,
            REPLACE(SUBSTRING(prd_key, 1,5 ), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE  UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a' END AS prd_line,
            CAST(prd_start_dt AS DATE) as prd_start_dt,
            CAST(DATEADD(day, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details
            (sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
            )
        SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE 
            WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
        END AS sls_order_dt,
        CASE 
            WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
        END AS sls_ship_dt,
        CASE 
            WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
        END AS sls_due_dt,
        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price
        FROM bronze.crm_sales_details

        SET @end_time = GETDATE()
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '*****************************************************'
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER (CRM)'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(50));
        PRINT '*****************************************************'
    END CATCH
END;