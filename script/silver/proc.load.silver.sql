/*
======================================================
 stored procedure -> silver layer -> bronze to silver
======================================================
script purpose - this stored procedure performs the ETL( extract , transform , load) process to
tranform the 'silver' schema tables from the 'bronze' schema
Actions performed
  . truncates silver table
  . inserts transformed and cleansed data from bronze to silver tables

Parameters
  . none
  . this stored procedure does not accept any parameter or returns any value 

Usage example
EXEC silver.load_silver
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time DATETIME , @end_time DATETIME , @batch_start_time DATETIME , @batch_end_time DATETIME;
BEGIN TRY 
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading crm tables';
		PRINT '----------------------------------------';

	--loading silver.crm_cust_info
	SET @start_time = GETDATE();
		PRINT '>> Truncating table : silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info                      -- important step to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.crm_cust_info';   -- printing what is to be seen while executing 
	INSERT INTO silver.crm_cust_info(cst_id , cst_key , cst_firstname , cst_lastname , cst_marital_status , cst_gender , cst_create_date)
	select
	 cst_id,
	 cst_key,
	 TRIM(cst_firstname) AS cst_firstname,
	 TRIM(cst_lastname) AS cst_lastname,
	 CASE WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'married'
		  WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'single'
		  ELSE 'n/a'
	 END as cst_marital_status,
	 CASE WHEN TRIM(UPPER(cst_gender)) = 'f' THEN 'female'
		  WHEN TRIM(UPPER(cst_gender)) = 'm' THEN 'male'
		  ELSE 'n/a'
	 END as cst_gender, 
	 cst_create_date
	from
	(select *,
	ROW_NUMBER () OVER(PARTITION BY cst_id order by cst_create_date DESC) as flag_last
	from bronze.crm_cust_info
	where cst_id IS NOT NULL
	) t where flag_last = 1  -- all the duplicates have been removed and only the latest ones persist
	SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';


	
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading prd tables';
		PRINT '----------------------------------------';

	--loading silver.crm_prd_info
	SET @start_time = GETDATE();
		PRINT '>> Truncating table : silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info                      -- important step to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.crm_prd_info';   -- printing what is to be seen while executing 
	INSERT INTO silver.crm_prd_info(
		   prd_id ,
		   prd_key        ,
		   cat_id         ,
		   prd_nm         ,
		   prd_cost       ,
		   prd_line       ,
		   prd_start_date ,
		   prd_end_date   
			)
	select
	prd_id,
	REPLACE(SUBSTRING(prd_key , 1 , 5), '-' , '_') as cat_id, -- we split the cat id in 2 parts to join it with the table having the same columns and replacing to match with the other column
	SUBSTRING(prd_key , 7 , LEN(prd_key)) as prd_key,         -- extract product key
	prd_nm,                                                   -- checked for unwanted spaces and there weren't any 
	ISNULL(prd_cost, 0) as prd_cost,                          -- to replace nulls with 0 we can use coalesce as well
	CASE UPPER(TRIM(prd_line))                                -- correcting names for standardization
		 WHEN 'R' THEN 'road'                                 -- another way of simple mapping 
		 WHEN 'M' THEN 'mountain'
		 WHEN 'S' THEN 'other sales'
		 WHEN 'T' THEN 'touring'
		 ELSE 'n/a'
	END as prd_line,
	CAST(prd_start_date AS DATE) AS prd_start_date,  -- cast to change the datatype
	CAST(LEAD(prd_start_date) OVER (PARTITION BY prd_key order by prd_start_date)-1 AS DATE) AS prd_end_date -- dates changed based on the next entry 
	from bronze.crm_prd_info
	SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';


	
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading sales_details tables';
		PRINT '----------------------------------------';

	--loading silver.crm_sales_details
	SET @start_time = GETDATE();
		PRINT '>> Truncating table : silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details                     -- important step to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.crm_sales_details';   -- printing what is to be seen while executing 
	 INSERT INTO silver.crm_sales_details(
	 sls_ord_no,
	 sls_prd_key,
	 sls_cust_id,
	 sls_order_date,
	 sls_ship_date,
	 sls_due_date,
	 sls_sales,
	 sls_quantity,
	 sls_price
	 )
	 select
	 sls_ord_no,
	 sls_prd_key,
	 sls_cust_id,
	 CASE WHEN sls_order_date = 0 OR LEN(sls_order_date) != 8 THEN NULL    -- correcting the dates and assigning correct data types
		  ELSE CAST(CAST( sls_order_date AS VARCHAR) AS DATE)
	 END AS sls_order_date,
	 CASE WHEN sls_ship_date = 0 OR LEN(sls_ship_date) != 8 THEN NULL      -- correcting the dates and assigning correct data types
		  ELSE CAST(CAST( sls_ship_date AS VARCHAR) AS DATE)
	 END AS sls_ship_date,
	 CASE WHEN sls_due_date = 0 OR LEN(sls_due_date) != 8 THEN NULL        -- correcting the dates and assigning correct data types
		  ELSE CAST(CAST( sls_due_date AS VARCHAR) AS DATE)
	 END AS sls_due_date,
	 /* the last three coulmns are sales , quantity , price and business rules say that sales = quantity*price\
	   negative , zeros and nulls are not allowed*/
	  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		   THEN sls_quantity * ABS(sls_price)
		   ELSE sls_sales
	  END AS sls_sales ,
	 sls_quantity,
	  CASE WHEN sls_price is NULL OR sls_price <= 0
		   THEN sls_sales / NULLIF (sls_quantity , 0)
		   ELSE sls_price
	  END AS sls_price
	 from bronze.crm_sales_details
	 SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';


	
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading erp_cust_az12 tables';
		PRINT '----------------------------------------';

	--loading silver.erp_cust_az12
	SET @start_time = GETDATE();
		PRINT '>> Truncating table : silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12                     -- important step to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.erp_cust_az12';   -- printing what is to be seen while executing 
	  INSERT INTO silver.erp_cust_az12 ( cst_id , cst_birthdate , cst_gender )
	  select 
	  CASE WHEN cst_id LIKE 'NAS%' THEN SUBSTRING( cst_id , 4 , LEN(cst_id)) -- final table
		   ELSE cst_id
	  END AS cst_id,
		CASE WHEN cst_birthdate > GETDATE() THEN NULL
			 ELSE cst_birthdate
	  END cst_birthdate ,
	  CASE WHEN UPPER(TRIM(cst_gender)) IN ('F' , 'FEMALE') THEN 'Female'
		   WHEN UPPER(TRIM(cst_gender)) IN ('M' , 'MALE') THEN 'Male'
		   ELSE 'n/a'
	  END cst_gender
	  from bronze.erp_cust_az12
	  SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';



	
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading erp_loc_a101 tables';
		PRINT '----------------------------------------';

	--loading silver.erp_loc_a101
	SET @start_time = GETDATE();
		PRINT '>> Truncating table silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101                      -- to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.erp_loc_a101';   -- printing what is to be seen while executing 
	INSERT INTO silver.erp_loc_a101(cst_id , cst_country)   -- data inserted into the silver layer
	select
	REPLACE(cst_id, '-' , '') as cst_id,     -- issue resolved
	CASE WHEN TRIM(cst_country) = 'DE' THEN 'GERMANY'
		 WHEN TRIM(cst_country) IN ('US' , 'USA') THEN 'UNITED STATES'
		 WHEN TRIM(cst_country) = '' OR cst_country IS NULL THEN 'n/a'
		 ELSE TRIM(cst_country)
	END as cst_country
	from bronze.erp_loc_a101  
	 SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';

	
    SET @batch_start_time = GETDATE();
		PRINT '========================================';
		PRINT 'loading silver layer';
		PRINT '========================================';

		PRINT '----------------------------------------';
		PRINT 'loading erp_px_cat_g1v2 tables';
		PRINT '----------------------------------------';

	--loading silver.erp_px_cat_g1v2
	SET @start_time = GETDATE();
		PRINT '>> Truncating table silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2                     -- to make sure we dont enter duplicate data 
		PRINT '>> Inserting data into : silver.erp_px_cat_g1v2';   -- printing what is to be seen while executing 
	INSERT INTO silver.erp_px_cat_g1v2(id , category , sub_category , maintenance)
	select
	id,
	category,
	sub_category,
	maintenance
	from bronze.erp_px_cat_g1v2
	 SET @end_time = GETDATE();
		PRINT '>> LOAD DURATION' + CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds';
		PRINT '>> -----------------';

	SET @batch_end_time = GETDATE();
		PRINT '===================================';
		PRINT 'loading silver layer is completed';
		PRINT ' - total load duration : ' +CAST(DATEDIFF(second , @start_time , @end_time) AS NVARCHAR) +'seconds'; 
		PRINT '===================================';

	END TRY 
	BEGIN CATCH
		PRINT '====================================';
		PRINT ' error occured while loading the bronze layer '
		PRINT ' error message ' + ERROR_MESSAGE();
		PRINT ' error message ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT ' error message ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================';
	END CATCH

END
