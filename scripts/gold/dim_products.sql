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
