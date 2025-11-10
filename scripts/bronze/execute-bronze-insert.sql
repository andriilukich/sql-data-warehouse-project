/*
    This script switches the context to the 'DataWarehouse' database and executes the 'load_bronze' stored procedure 
    from the 'bronze' schema. The procedure is responsible for loading data into the Bronze layer of the data warehouse.
    Ensure that all required permissions and prerequisites are met before running this script.
*/
USE DataWarehouse;
GO

EXEC bronze.load_bronze
