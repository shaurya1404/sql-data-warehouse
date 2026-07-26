CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Create PK for Dimensions' Table
	cst_id AS customer_id,
	cu.cst_key AS customer_number,
	cst_firstname AS first_name,
	cst_lastname AS last_name,
	cntry AS country,
	CASE -- Data Integration of Two Columns Providing Same Info
		WHEN cst_gndr != 'n/a' THEN cst_gndr -- Precedence to CRM Table
		ELSE COALESCE(gen, 'n/a')
	END AS gender,
	bdate AS birth_date,
	cst_marital_status AS marital_status,
	cst_create_date AS create_date
FROM silver.crm_cust_info cu 
	LEFT JOIN silver.erp_cust_az12 az ON cu.cst_key = az.cid
	LEFT JOIN silver.erp_loc_a101 lo ON cu.cst_key = lo.cid;
