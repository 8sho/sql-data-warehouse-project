 -- QUALITY CHECK

 -- check for nulls or duplicates in the primary key
 -- EXPECTATION : no results
	 select
	 prd_id,
	 COUNT(*)
	 from silver.crm_prd_info
	 group by prd_id
	 having COUNT(*) > 1 OR prd_id IS NULL

 -- check for unwanted spaces
 -- EXPECTATION : no results
	 select
	 prd_nm
	 from silver.crm_prd_info
	 where prd_nm!= TRIM(prd_nm)

 -- check for nulls or negative numbers 
 -- EXPECTATION : no results
	 select
	 prd_cost
	 from silver.crm_prd_info
	 where prd_cost < 0 OR prd_cost IS NULL

 -- data standardization and consistency
	 select
	 DISTINCT prd_line
	 from silver.crm_prd_info

 -- check for invalid date orders
	 select*
	 from silver.crm_prd_info
	 where prd_end_date < prd_start_date

-- check for invalid dates

 select
 NULLIF(sls_order_date,0) AS sls_order_date
 from bronze.crm_sales_details
 where sls_ship_date <= 0
 OR LEN(sls_ship_date) != 8
 OR sls_ship_date > 20500101
 OR sls_ship_date < 19000101

---------------------------------------------------------------------------------------------------------------------------------------------------------------
     select *
from bronze.crm_cust_info

select
cst_id,
COUNT(*)
from bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id is NULL -- here we found duplicates in the primary key and have to fix it and keep the latest record

-- cleaning , removing duplicates and spaces from the strings 
-- satisfying the standardization and consistency and inseting into the silver layer

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

-- checking for unwanted spaces in string values
 select 
 cst_firstname,
 cst_lastname
 from bronze.crm_cust_info
 where cst_lastname != TRIM(cst_lastname)-- checking if there is any unwanted space available
 
-- checking if the standardization and consistency is maintained or not 

select
DISTINCT(cst_gender)
from bronze.crm_cust_info -- nothing is wrong here but it would be good if there was female instead of f and male instead of m
                          -- re run data quality check by just changing the tables name to silver and check for errors in the new query
						  

  -- check for invalid date orders
		 
------------------------------------------------------------------------------------------------------------------------------------------------------------

 -- now to check for duplicate primary key

select
prd_id,
COUNT(*)
from bronze.crm_prd_info
group by prd_id
having COUNT(*) > 1                                       -- no dupliactes found , means no need to do anything in id column 


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

select
*
from bronze.crm_prd_info
where prd_start_date > prd_end_date /* logic says that the end date should be higher than start date 
                                       but in here there are several dates that does not follow the rule and mismatched 
									   so we will use the start date of the next product as the end date of the previous one 
									   and will do this for all the mismatched dates */
									/* before transferring the data to silver table we have to keep in mind the changes that we made ,
									   that are not present in the normal table so we have to make the necessary changes */
----------------------------------------------------------------------------------------------------------------------------------------------------------------		 

  select *
  from bronze.crm_sales_details
  where sls_order_date > sls_ship_date OR sls_order_date > sls_due_date

  -- checking data consistency between sales , quantity and price 
  -- sales = qauntity*price
  -- values should not be negative , zero or null

  select DISTINCT
  sls_sales AS sls_old_sales,
  sls_quantity,
  sls_price AS sls_old_price,

  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
       THEN sls_quantity * ABS(sls_price)
	   ELSE sls_sales
  END AS sls_sales ,

  CASE WHEN sls_price is NULL OR sls_price <= 0
       THEN sls_sales / NULLIF (sls_quantity , 0)
	   ELSE sls_price
  END AS sls_price

  from silver.crm_sales_details
  where sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
  OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0

--------------------------------------------------------------------------------------------------------------------------------------------------------		 

 select
  cst_id,
  cst_birthdate,
  cst_gender
  from bronze.erp_cust_az12
   
   -- cst_id has a relation with silver.crm_cust_info and chcek whether the column  details matches or not 
 select
 *
 from silver.crm_cust_info  -- from here cst_key is cst_id of erp_cust_az12 and we have to remove the extra details to match the columns

  select
  CASE WHEN cst_id LIKE 'NAS%' THEN SUBSTRING( cst_id , 4 , LEN(cst_id))
       ELSE cst_id
  END AS cst_id,
    CASE WHEN cst_birthdate > GETDATE() THEN NULL
         ELSE cst_birthdate
  END cst_birthdate ,
  cst_gender
  from bronze.erp_cust_az12

  -- checking if cst_birthdate has any issue
  select DISTINCT
   CASE WHEN cst_birthdate > GETDATE() THEN NULL
        ELSE cst_birthdate
  END cst_birthdate
  from bronze.erp_cust_az12
  where cst_birthdate < '1920-01-01' OR cst_birthdate > GETDATE() -- issue found there are dates from the future , needs fixing

  --the last column
  
  select DISTINCT
  CASE WHEN UPPER(TRIM(cst_gender)) IN ('F' , 'FEMALE') THEN 'Female'
       WHEN UPPER(TRIM(cst_gender)) IN ('M' , 'MALE') THEN 'Male'
	   ELSE 'n/a'
  END cst_gender
  from bronze.erp_cust_az12  -- issue found , needs fixing 

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
  from bronze.erp_cust_az12   -- issue fixed
		 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
  select
  *
  from
  bronze.erp_loc_a101 -- checking with the relation table and it has a relaion with customer 
                      -- info so we have to check if the data matches or not 
select *
from silver.crm_cust_info

-- the cst_id of erp_loc_a101 is the cst_key of crm_cust_info and there is a - sign in the erp_loc_a101 and we have to remove it 

select
REPLACE(cst_id, '-' , '') as cst_id,     -- issue resolved
cst_country
from bronze.erp_loc_a101

-- next column cst_country
select
DISTINCT cst_country
from bronze.erp_loc_a101
order by cst_country  -- data is bad there are nulls , empty spaces , naming conventions are bad , needs fixing

select
REPLACE(cst_id, '-' , '') as cst_id,     -- issue resolved
CASE WHEN TRIM(cst_country) = 'DE' THEN 'GERMANY'
     WHEN TRIM(cst_country) IN ('US' , 'USA') THEN 'UNITED STATES'
	 WHEN TRIM(cst_country) = '' OR cst_country IS NULL THEN 'n/a'
	 ELSE TRIM(cst_country)
END as cst_country
from bronze.erp_loc_a101  -- resolved the issue 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------		 

select *
from bronze.erp_px_cat_g1v2 -- in this the first column has a relation with silver.crm_prd_info

select *
from silver.crm_prd_info

-- first column is ok no issue with that , now checking 2nd column for unwanted spaces

select *
from bronze.erp_px_cat_g1v2
where category ! = TRIM(category) -- no spaces found now 3rd column 

select *
from bronze.erp_px_cat_g1v2
where sub_category ! = TRIM(sub_category) -- no issue here also now last column

--checking data standardiation

SELECT DISTINCT
maintenance
from bronze.erp_px_cat_g1v2   -- no issue with column 2 , 3 , 4 so the data is clean now just load it into the silver layer









