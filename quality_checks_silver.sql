/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

/*
==================
crm_cust_info
==================
*/
-- Check for NULLs or Duplicates in Primary Key
Expectation: No Result
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for White spaces in First Name or Last Name
-- Expectation: No Result
SELECT cst_firstname, cst_lastname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
  OR cst_lastname != TRIM(cst_lastname);

-- Data Standardization and Consistency for Low Cardinality Columns
SELECT DISTINCT cst_gndr, cst_marital_status
FROM silver.crm_cust_info;

/* 
===================
crm_prd_info Table
===================
*/

-- Check for NULLs or Duplicates in Primary Key
Expectation: No Result
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for White Spaces
-- Expectation: No Result
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Costs
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for all first 5 chars of prd_id NON-matching with cust_id (foreign key) in erp_cust_az12
-- Expectation: No Result
SELECT prd_id, REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') NOT IN (
  SELECT DISTINCT id
  FROM bronze.erp_px_cat_g1v2
);

-- Check for all remaining chars of prd_id NON-matching with sls_prd_key (foreign key) in crm_sales_details
-- Expectation: No Result
SELECT prd_id, REPLACE(SUBSTRING(prd_key, 7, LENGTH(prd_key)), '-', '_')
FROM bronze.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 7, LENGTH(prd_key)), '-', '_') NOT IN (
  SELECT DISTINCT sls_prd_key
  FROM bronze.crm_sales_details
);

-- Check for NULLs in prd_nm
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm IS NULL;

-- Data Standardization for Low Cardinality Column prd_line
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
SELECT prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

/* 
=====================
crm_sales_details
=====================
*/

-- Check for White Spaces in Columns
SELECT sls_order_num
FROM silver.crm_sales_details
WHERE sls_order_num != sls_order_num;

-- Check if all prd_key values match the PK in crm_prd_info
SELECT sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
  SELECT DISTINCT prd_key
  FROM silver.crm_prd_info
);

-- Check if all cust_id values match the PK in crm_cust_info
SELECT sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (
  SELECT DISTINCT cst_id
  FROM silver.crm_cust_info
);

-- Check for Invalid Dates for all 3 Date columns
SELECT NULLIF(sls_order_dt, 0) -- Many rows have value 0
FROM bronze.crm_sales_details
WHERE sls_order_dt > 20500101 
  OR sls_order_dt < 19700101 -- Outside Conventional Boundary for Dates
  OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8; -- Not Convertible to a Date if No. of Digits != 8

-- Check for Invalid Dates (Incorrect Chronological order between the 3 Dates)
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: For Columns sales, quantity, price 
-- Rule #1: Sales = Quantity x Price
-- Rule #2: No Zero, Negative, or NULL values
SELECT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
  OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;
Rule #1 To Fix: If Sales is -ve, zero, or null - derive using quantity and price
Rule #2 To Fix: If Price is -ve, zero, or null - derive using sales and quantity
Rule #3 To Fix: If Price is -ve, convert to +ve value

/*
=================
erp_cust_az12
=================
*/

-- Check for cid values (FK) that are NOT in the PK cst_key
SELECT *
FROM silver.erp_cust_az12
WHERE 
  CASE 
    WHEN LENGTH(cid) = 13 THEN SUBSTRING(cid, 4, LENGTH(cid))
    ELSE cid
  END
  NOT IN (
  SELECT DISTINCT cst_key
  FROM bronze.crm_cust_info
);

-- Check for Invalid Birthdate values
SELECT bdate
FROM silver.erp_cust_az12
WHERE bdate NOT BETWEEN '1926-01-01' AND CURRENT_DATE;

-- Check for Invalid Gender Values
SELECT DISTINCT 
  gen,
  CASE 
    WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
    WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
    ELSE 'n/a'
  END AS gen
FROM silver.erp_cust_az12;

/*
===============
erp_loc_a101
===============
*/

-- Check for cid (FK) values that do NOT match cst_key (PK) values
SELECT 
cid, 
REPLACE(cid, '-', '')
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (
 SELECT cst_key
 FROM silver.crm_cust_info
);

-- Check for Invalid values in the Low Cardinality Column Cntry
SELECT DISTINCT 
  cntry,
  CASE
    WHEN UPPER(TRIM(cntry)) IN ('DE') THEN 'Germany'
    WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
    WHEN TRIM(cntry)= '' OR cntry IS NULL THEN 'n/a'
    ELSE TRIM(cntry)
  END AS cntry_new
FROM bronze.erp_loc_a101
ORDER BY cntry;

/*
=================
erp_px_cat_g1v2
=================
*/

-- Check for id (FK) values NOT in cat_id (PK)
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (
  SELECT cat_id
  FROM silver.crm_prd_info
);

-- Check for Unwanted White Spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data Standardization for Low Cardinality Columns
SELECT DISTINCT cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2;

