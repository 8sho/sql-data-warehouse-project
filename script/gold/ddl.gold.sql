/*
====================================================================
DDL SCRIPT : create gold views
====================================================================

script purpose : 
                 this script creates views for the gold layer in the data warehouse
                 the gold layer shows the final dimension and the fact tables (star schema)
each view performs transformations and combines data from the silver layer
tomproduce a clean , enriched and a business-ready dataset

usage:- 
       thses views can be queried directly for analytics and reporting 
=============================================================================
*/


-- =========================================================
     create dimension : gold.dim_customers
-- =========================================================

CREATE VIEW gold.dim_customers AS
select
    ROW_NUMBER() OVER ( ORDER BY ci.cst_id) AS customer_key, -- surrogate key
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as customer_firstname,
	ci.cst_lastname as customer_lastname,
	la.cst_country as country,
	ci.cst_marital_status as marital_status,
		CASE WHEN ci.cst_gender != 'n/a' THEN ci.cst_gender -- crm is the master 
			 ELSE COALESCE(ca.cst_gen , 'n/a')
		END  as gender ,
	ca.cst_birthdate as birth_date,
	ci.cst_create_date as create_date	
from silver.crm_cust_info ci 
LEFT JOIN silver.erp_cust_az12 ca 
ON      ci.cst_key = ca.cst_id
LEFT JOIN silver.erp_loc_a101  la  
ON      ci.cst_key = la.cst_id


-- ========================================================
     create dimension : gold.dim_products
-- ========================================================

CREATE VIEW gold.dim_products AS
select
ROW_NUMBER() OVER (ORDER BY prd.prd_start_date , prd.cat_id ) as product_key, -- surrogate key
prd.prd_id as product_id,
prd.prd_key as category_id,
prd.cat_id as product_number,
prd.prd_nm as product_name,
prd.prd_cost as product_cost,
pxc.category as product_cat,
pxc.sub_category as product_sub_cat,
prd.prd_line as line,
prd.prd_start_date as start_date,
pxc.maintenance 
from silver.crm_prd_info prd -- alias for joining
LEFT JOIN silver.erp_px_cat_g1v2 pxc
ON        prd.prd_key = pxc.id
WHERE prd.prd_end_date IS NULL -- filter out all historical data 


-- ==============================================================
     create dimension : gold.facts_sales
-- ==============================================================


CREATE VIEW gold.facts_sales AS
select 
sd.sls_ord_no as order_number,
pr.product_key as product_key,
cu.customer_key as customer_key,
sd.sls_order_date as order_date,
sd.sls_ship_date as order_ship_date,
sd.sls_due_date as order_due_date,
sd.sls_sales as sales,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON        sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON        sd.sls_cust_id = cu.customer_id





