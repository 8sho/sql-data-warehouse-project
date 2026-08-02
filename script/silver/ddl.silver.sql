/*
===================================
  DDL scripts : create silver tables
===================================
script prpose :
     this script creates tables in the silver schema dropping existing tables
     if they already exists
     run this script to redefine the 'bronze' structure
*/


IF OBJECT_ID ('silver.crm_cust_info' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.crm_cust_info

CREATE TABLE silver.crm_cust_info (
	   cst_id              INT,
	   cst_key             NVARCHAR(20),
	   cst_firstname       NVARCHAR(50),
	   cst_lastname        NVARCHAR(50),
	   cst_marital_status  NVARCHAR(20),
	   cst_gender          NVARCHAR(20),
	   cst_create_date     DATE,
	   dwh_create_date DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID ('silver.crm_prd_info' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.crm_prd_info

CREATE TABLE silver.crm_prd_info (   -- this table has been changed a little to enter the correct data 
	   prd_id         INT,
	   prd_key        NVARCHAR(20),
	   cat_id         NVARCHAR(50),
	   prd_nm         NVARCHAR(50),
	   prd_cost       INT,
	   prd_line       NVARCHAR(20),
	   prd_start_date DATE,
	   prd_end_date   DATE,
	   dwh_create_date DATETIME2 DEFAULT GETDATE()
)

 IF OBJECT_ID ('silver.crm_sales_details' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.crm_sales_details

CREATE TABLE silver.crm_sales_details (  -- table has been changed to match the data types
	 sls_ord_no     NVARCHAR(20),
	 sls_prd_key    NVARCHAR(20),
	 sls_cust_id    INT,
	 sls_order_date DATE,
	 sls_ship_date  DATE,
	 sls_due_date   DATE,
	 sls_sales      INT,
	 sls_quantity   INT,
	 sls_price      INT,
	 dwh_create_date DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID ('silver.erp_cust_az12' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.erp_cust_az12

CREATE TABLE silver.erp_cust_az12(
	  cst_id        NVARCHAR(20),
	  cst_birthdate DATE,
	  cst_gender    NVARCHAR(20),
	  dwh_create_date DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID ('silver.erp_loc_a101' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.erp_loc_a101

CREATE TABLE silver.erp_loc_a101(
	 cst_id      NVARCHAR(20),
	 cst_country NVARCHAR(20),
     dwh_create_date DATETIME2 DEFAULT GETDATE()
)

IF OBJECT_ID ('silver.erp_px_cat_g1v2' , 'U') IS NOT NULL -- to check if the table exists and if it does drop it and create a new table
DROP TABLE silver.erp_px_cat_g1v2

CREATE TABLE silver.erp_px_cat_g1v2(
	  id            NVARCHAR(20),
	  category      NVARCHAR(20),
	  sub_category  NVARCHAR(20),
	  maintenance   NVARCHAR(20),
	  dwh_create_date DATETIME2 DEFAULT GETDATE()
)
