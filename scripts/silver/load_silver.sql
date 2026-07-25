/*
==================
crm_cust_info
==================
*/

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Result
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for White spaces in First Name or Last Name
-- Expectation: No Result
SELECT cst_firstname, cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
	OR cst_lastname != TRIM(cst_lastname);

-- Data Standardization and Consistency for Low Cardinality Columns
SELECT DISTINCT cst_gndr, cst_marital_status
FROM silver.crm_cust_info

INSERT INTO silver.crm_cust_info (
	cst_id, cst_key, cst_firstname, cst_lastname, cst_gndr, cst_marital_status, cst_create_date
)
SELECT cst_id, cst_key, 
TRIM(cst_firstname), 
TRIM(cst_lastname), 
CASE UPPER(TRIM(cst_gndr))
	WHEN 'F' THEN 'Female'
	WHEN 'M' THEN 'Male'
	ELSE 'n/a'
END AS cst_gndr,
CASE UPPER(TRIM(cst_martial_status))
	WHEN 'S' THEN 'Single'
	WHEN 'M' THEN 'Married'
	ELSE 'n/a'
END AS cst_marital_status,
cst_create_date
FROM (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
	FROM bronze.crm_cust_info
	WHERE cst_id IS NOT NULL
) sq
WHERE rnk = 1;
