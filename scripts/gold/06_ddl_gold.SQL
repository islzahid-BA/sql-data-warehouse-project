/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    - This script creates views for the Gold layer in the data warehouse. 
    - The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,	-- Surrogate key
	cci.cst_id                          AS customer_id,
	cci.cst_key                         AS customer_number,
	cci.cst_firstname                   AS first_name,
	cci.cst_lastname                    AS last_name,
	ecl.cntry                           AS country,
	cci.cst_marital_status              AS marital_status,
	CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr		-- CRM is the primary source for gender
		ELSE COALESCE (ecb.gen, 'n/a')						-- Fallback to ERP data
	END AS gender,
	ecb.bdate                           AS birthdate,
	cci.cst_create_date                 AS create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 ecb
	ON cci.cst_key = ecb.cid
LEFT JOIN silver.erp_loc_a101 ecl
	ON cci.cst_key = ecl.cid;
GO



-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cpn.prd_start_dt, cpn.prd_key) AS product_key,  -- Surrogate key
	cpn.prd_id              AS product_id,
	cpn.prd_key             AS product_number,
	cpn.prd_nm              AS product_name,
	cpn.cat_id              AS category_id,
	epc.cat                 AS category,
	epc.subcat              AS subcategory,
	epc.maintenance,
	cpn.prd_cost            AS cost,
	cpn.prd_line            AS product_line,
	cpn.prd_start_dt        AS start_date
FROM silver.crm_prd_info cpn
LEFT JOIN silver.erp_px_cat_g1v2 epc
    ON cpn.cat_id = epc.id
WHERE prd_end_dt IS NULL; -- Filter out all historical data (keeping only the latest)
GO



-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	csd.sls_ord_num		AS order_number,
	pr.product_key		AS product_key,
	cu.customer_key		AS customer_key,
	csd.sls_order_dt	AS order_date,
	csd.sls_ship_dt		AS shipping_date,
	csd.sls_due_dt		AS due_date,
	csd.sls_sales		AS sales_amount,
	csd.sls_quantity	AS quantity,
	csd.sls_price		AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_products pr
	ON csd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
	ON csd.sls_cust_id = cu.customer_id;
GO
