/*
==================================================================
Stored Procedure: Load Data Into Bronze Layer (Source -> Bronze)
=================================================================='
Script Purpose:
  This scripts defines a Stored Procedure that loads data from the two source systems (ERP and CRM) into the Bronze tables
  It performs the following operations:
    - Truncates the data from the Bronze tables
    - Uses 'COPY' command to load data from CSV files into Bronze tables

Parameters and Returned Values: None, This Stored Procedure doesn't take any parameters nor return any values.

To Execute: CALL bronze.load_bronze()

*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
	v_start_time TIMESTAMP;
	v_end_time TIMESTAMP;
BEGIN
	RAISE NOTICE '================================';
	RAISE NOTICE 'Loading Bronze Layer data';
	RAISE NOTICE '================================';
	
	RAISE NOTICE '--------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '--------------------';
	
	v_start_time := clock_timestamp();
	RAISE NOTICE 'Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;
	RAISE NOTICE 'Copying Data Into: bronze.crm_cust_info';
	COPY bronze.crm_cust_info
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_crm/cust_info.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time := clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);

	v_start_time := clock_timestamp();
	RAISE NOTICE 'Truncating Table: bronze.crm_prd_info';
	TRUNCATE TABLE bronze.crm_prd_info;
	RAISE NOTICE 'Copying Data Into: bronze.crm_prd_info';
	COPY bronze.crm_prd_info
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_crm/prd_info.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time := clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);

	v_start_time := clock_timestamp();
	RAISE NOTICE 'Truncating Table: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	RAISE NOTICE 'Copying Data Into: bronze.crm_sales_details';
	COPY bronze.crm_sales_details
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_crm/sales_details.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time := clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);

	v_start_time := clock_timestamp();
	RAISE NOTICE '--------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '--------------------';
	RAISE NOTICE 'Truncating Table: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;
	RAISE NOTICE 'Copying Data Into: bronze.erp_cust_az12';
	COPY bronze.erp_cust_az12
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_erp/cust_az12.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time = clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);
	
	v_start_time := clock_timestamp();
	RAISE NOTICE 'Truncating Table: bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101;
	RAISE NOTICE 'Copying Data Into: bronze.erp_loc_a101';
	COPY bronze.erp_loc_a101
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_erp/loc_a101.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time := clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);

	v_start_time := clock_timestamp();
	RAISE NOTICE 'Truncating Table: bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	RAISE NOTICE 'Copying Data Into: bronze.erp_px_cat_g1v2';
	COPY bronze.erp_px_cat_g1v2
	FROM '/Users/shaurya1404/Downloads/Important/DatawareHouse/sql-data-warehouse-project-main/datasets/source_erp/px_cat_g1v2.csv'
	WITH (
		FORMAT csv,
		FREEZE true,
		HEADER true
	);
	v_end_time = clock_timestamp();
	RAISE NOTICE 'Duration: %', (v_end_time - v_start_time);
	
EXCEPTION 
	WHEN OTHERS THEN
		RAISE NOTICE 'Error Loading Bronze Layer: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
END;
$$;
