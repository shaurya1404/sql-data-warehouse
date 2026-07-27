/*
=================================
DDL Scripts: Create Gold Views
=================================

Script Purpose:
  This script creates the Views for the Gold Layer in the Datawarehouse.
  The Gold Layer represents the final dimension and fact tables (Star Schema).

Each view performs transformations and combines data from the Silver Layer such that
it is ready to be consumed for Business Analytics and Reporting.
*/

-- ===========================================
-- Create Dimension View: gold.dim_customers
-- ===========================================

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Create PK for Dimensions' Tables
	cst_id AS customer_id,
	cu.cst_key AS customer_number,
	cst_firstname AS first_name,
	cst_lastname AS last_name,
	cntry AS country,
	CASE 
		WHEN cst_gndr != 'n/a' THEN cst_gndr -- Precedence to CRM Table
		ELSE COALESCE(gen, 'n/a')
	END AS gender,
	bdate AS birth_date,
	cst_marital_status AS marital_status,
	cst_create_date AS create_date
FROM silver.crm_cust_info cu 
	LEFT JOIN silver.erp_cust_az12 az ON cu.cst_key = az.cid
	LEFT JOIN silver.erp_loc_a101 lo ON cu.cst_key = lo.cid;

-- ===========================================
-- Create Dimension View: gold.dim_products
-- ===========================================

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY prd_start_dt, prd_key) AS product_key,
	prd_id AS product_id,
	prd_key AS product_number,
	prd_nm AS product_name,
	cat_id AS category_id,
	cat AS category,
	subcat AS subcategory,
	maintenance,
	prd_cost AS product_cost,
	prd_line AS product_line,
	prd_start_dt AS product_start_date
FROM silver.crm_prd_info crm LEFT JOIN
	silver.erp_px_cat_g1v2 erp ON crm.cat_id = erp.id
WHERE prd_end_dt IS NULL -- Filter Out Historical Data (No Historization)

-- ===========================================
-- Create Facts View: gold.facts_sales
-- ===========================================

CREATE VIEW gold.facts_sales AS
SELECT
	sls_order_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS shipping_date,
	sls_due_dt AS due_date,
	sls_sales AS sales,
	sls_quantity AS quantity,
	sls_price AS price
FROM silver.crm_sales_details sa
	LEFT JOIN gold.dim_customers cu ON sa.sls_cust_id = cu.customer_id
	LEFT JOIN gold.dim_products pr ON sa.sls_prd_key = pr.product_number
ORDER BY order_date
