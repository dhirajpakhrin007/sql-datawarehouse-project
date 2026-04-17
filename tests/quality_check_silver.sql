/*
=============================================================================
Quality Checks
=============================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization accross the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid data ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===========================================================================
*/


-- ========================================================================
-- Checking 'silver.crm_cust_info'
-- ========================================================================

----- Checking for null and duplicate values for Primary key
----- Expectation: No result 

SELECT cst_id, count(cst_id) FROM silver.crm_cust_info
GROUP BY cst_id
HAVING count(cst_id) > 1 OR cst_id IS NULL;


----- Check for unwanted Spaces
----- Expectation: No result

SELECT  cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


----- Data Standardization and Consistency For Gender
----- Expectation: M/F
SELECT 
	DISTINCT(cst_gndr)
FROM silver.crm_cust_info

----- Data Standardization and Consistency For Marital Status
----- Expectation: M/F
SELECT 
	DISTINCT(cst_marital_status)
FROM silver.crm_cust_info
  

-- ========================================================================
-- Checking 'silver.crm_prd_info'
-- ========================================================================
  
-- Checking for null or duplicateds on primary key 
-- Expectation: No Result
SELECT 
	prd_id,
	COUNT(prd_id)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(prd_id) > 1;

-- Checking for unwanted Spaces
-- Expectation: No Result
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Checking for nulls or negative numbers
-- Expectation: No Result
SELECT prd_cost 
FROM silver.crm_prd_info 
WHERE prd_cost IS NULL OR prd_cost < 1;

-- Checking for data Standardization or Consistency 
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Checking invalid date order 
SELECT 
	prd_start_dt,
	prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- ========================================================================
-- Checking 'silver.crm_sales_details'
-- ========================================================================

----- Checking for unwanted prd_key in sls_ord_num
----- Expectation: No result 
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
	SELECT prd_key FROM silver.crm_prd_info
);

----- Checking for unwanted cust_id in sls_ord_num
----- Expectation: No result 
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (
	SELECT sls_cust_id FROM silver.crm_prd_info
);

----- Check for invalid Dates
SELECT
	NULLIF(sls_due_dt, 0) sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt <=0
OR LEN(sls_due_dt) != 8
OR sls_due_dt > 20500101
OR sls_due_dt < 19000101;

----- Check for invalid Date order
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt


----- Check data consistency: Between Sales, Quantity, and Price 
---> Sales = Quantity * Price 
---> Values must not be NULL, Zero, or Negative 

SELECT 
	sls_sales,
	sls_quantity,
	sls_price 
FROM silver.crm_sales_details
WHERE sls_sales = sls_quantity * sls_price 
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ========================================================================
-- Checking 'silver.erp_cust_az12'
-- ========================================================================

-- Identify out of range bday 
SELECT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate >= GETDATE()

-- Identify data inconsistency and standardization 
SELECT
	DISTINCT gen
FROM silver.erp_cust_az12


-- ========================================================================
-- Checking 'silver.erp_loc_a101'
-- ========================================================================

--- Standardizing cid in erp_loc_a101 
SELECT cid FROM silver.erp_loc_a101;

-- standardizing cntry
SELECT
	DISTINCT cntry 
FROM silver.erp_loc_a101;


-- ========================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ========================================================================

--- Checking for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance);

-- Data Standardization and Consistency 
SELECT 
	DISTINCT cat 
FROM silver.erp_px_cat_g1v2;

SELECT 
	DISTINCT subcat 
FROM silver.erp_px_cat_g1v2;

SELECT 
	DISTINCT maintenance 
FROM silver.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2



