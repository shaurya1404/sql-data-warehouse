/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the Gold Layer. It includes checks for:
    - Uniqueness of Surrogate Keys.
    - Referential Integrity Across Dimension and Facts Tables.

Usage Notes:
    - Run these checks after data loading Gold Layer Views.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

/*
==================
gold.dim_customers
==================
*/
-- Checking for Duplicates in the Master Table due to JOINING
SELECT cu.cst_key, COUNT(*) AS row_num
FROM silver.crm_cust_info cu 
	LEFT JOIN silver.erp_cust_az12 az ON cu.cst_key = az.cid
	LEFT JOIN silver.erp_loc_a101 lo ON cu.cst_key = lo.cid
GROUP BY cu.cst_key
HAVING COUNT(*) > 1
/*
==================
gold.dim_products
==================
*/
-- Check for Duplicates Due to Join
SELECT prd_key, COUNT(*)
FROM silver.crm_prd_info crm LEFT JOIN
	silver.erp_px_cat_g1v2 erp ON crm.cat_id = erp.id
WHERE prd_end_dt IS NULL
GROUP BY prd_key
HAVING COUNT(*) > 1
/*
==================
gold.facts_sales
==================
*/
-- Foriegn Key Referntial Integrity Check
SELECT *
FROM gold.facts_sales sa
	LEFT JOIN gold.dim_customers cu ON sa.customer_key = cu.customer_key
	LEFT JOIN gold.dim_products pr ON sa.product_key = pr.product_key
WHERE cu.customer_key IS NULL OR pr.product_key IS NULL
