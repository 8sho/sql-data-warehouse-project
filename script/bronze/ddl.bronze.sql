
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
