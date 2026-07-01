/*SCRIPT PURPOSE -
this script creates a new database named 'data warehouse' after checking ifit already exists , if the database exists , it is dropped and recreated.
additionally the script sets up three schemas within the datasbase , bronze , silver . gold */
/* warning -
running this script will drop the entire 'data warehouse' database if it exists / all data in the database will be permanently deleted ,
proceed with caution and ensure you have proper backups before running this script */



create database DataWarehouse;

use DataWarehouse 

-- create schemas

CREATE SCHEMA BRONZE;
GO  -- separate batches while working with multiple sql statements
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO

IF OBJECT_ID ('bronze.crm_cust_info' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.crm_cust_info

CREATE TABLE bronze.crm_cust_info (
	   cst_id              INT,
	   cst_key             NVARCHAR(20),
	   cst_firstname       NVARCHAR(50),
	   cst_lastname        NVARCHAR(50),
	   cst_marital_status  NVARCHAR(20),
	   cst_gender          NVARCHAR(20),
	   cst_create_date     DATE
)

IF OBJECT_ID ('bronze.crm_prd_info' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.crm_prd_info

CREATE TABLE bronze.crm_prd_info (
	   prd_id         INT,
	   prd_key        NVARCHAR(20),
	   prd_nm         NVARCHAR(50),
	   prd_cost       INT,
	   prd_line       NVARCHAR(20),
	   prd_start_date DATETIME,
	   prd_end_date   DATETIME
)

 IF OBJECT_ID ('bronze.crm_sales_details' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.crm_sales_details

CREATE TABLE bronze.crm_sales_details (
	 sls_ord_no     NVARCHAR(20),
	 sls_prd_key    NVARCHAR(20),
	 sls_cust_id    INT,
	 sls_order_date INT,
	 sls_ship_date  INT,
	 sls_due_date   INT,
	 sls_sales      INT,
	 sls_quantity   INT,
	 sls_price      INT
)

IF OBJECT_ID ('bronze.erp_cust_az12' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.erp_cust_az12

CREATE TABLE bronze.erp_cust_az12(
	  cst_id        NVARCHAR(20),
	  cst_birthdate DATE,
	  cst_gender    NVARCHAR(20)
)

IF OBJECT_ID ('bronze.erp_loc_a101' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.erp_loc_a101

CREATE TABLE bronze.erp_loc_a101(
	 cst_id      NVARCHAR(20),
	 cst_country NVARCHAR(20)
)

IF OBJECT_ID ('bronze.erp_px_cat_g1v2' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE bronze.erp_px_cat_g1v2

CREATE TABLE bronze.erp_px_cat_g1v2(
	  id            NVARCHAR(20),
	  category      NVARCHAR(20),
	  sub_category  NVARCHAR(20),
	  maintenance   NVARCHAR(20)
)

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
TRUNCATE TABLE bronze.crm_cust_info; -- emptying the table before loading the data into the database 

BULK INSERT bronze.crm_cust_info
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);

SELECT COUNT(*) FROM bronze.crm_cust_info -- checking if the data is equal or not 


TRUNCATE TABLE bronze.crm_prd_info;

BULK INSERT bronze.crm_prd_info
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);
SELECT COUNT(*) FROM bronze.crm_prd_info;


TRUNCATE TABLE bronze.crm_sales_details

BULK INSERT bronze.crm_sales_details
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);
SELECT COUNT(*) FROM bronze.crm_sales_details


TRUNCATE TABLE bronze.erp_cust_az12

BULK INSERT bronze.erp_cust_az12
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);

SELECT COUNT(*) FROM bronze.erp_cust_az12


TRUNCATE TABLE bronze.erp_loc_a101

BULK INSERT bronze.erp_loc_a101
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);
SELECT COUNT(*) FROM bronze.erp_loc_a101



TRUNCATE TABLE bronze.erp_px_cat_g1v2

BULK INSERT bronze.erp_px_cat_g1v2
FROM 'D:\SHOBHIT\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
      FIRSTROW = 2 ,
	  FIELDTERMINATOR = ',' ,
	  TABLOCK
);
SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2
END


-- now if we have scripts that we are going to use frequently then we'll create stored procedures for the scripts 
-- stored procedure is created at the start of bulk insert 
