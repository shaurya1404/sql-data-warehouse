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
