/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
IF OBJECT_ID('gold.dim_customer', 'V') IS NOT NULL
    DROP VIEW gold.dim_customer;
GO

Create	View gold.dim_customer As
Select
Row_Number() Over(Order By cu.cst_id) AS customer_key,
	cu.cst_id AS customer_id,
	cu.cst_key AS customer_number,
	cu.cst_firstname AS first_name,
	cu.cst_lastname AS last_name,
	cu.cst_marital_status AS marital_status,
	Case 
		When cu.Cst_gndr !='n\a' Then cu.Cst_gndr
		Else Coalesce(az.GEN,'n\a')
	End gender,
	cu.cst_create_date AS create_date,
	az.BDATE AS birthdate,
	a1.CNTRY AS country
from Silver.crm_cust_info cu
Left Join Silver.erp_CUST_AZ12 az 
on  cu.cst_key =az.CID
Left Join Silver.erp_LOC_A101 a1
on  cu.cst_key =a1.CID;

Go

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO

Create	View gold.dim_product As

SELECT
Row_Number() Over(Order By prd_start_dt,prd_key) As product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    px.cat          AS category,
    px.subcat       AS subcategory,
    px.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
Left Join Silver.erp_PX_CAT_G1V2 px
On pn.cat_id=px.ID 
Where prd_end_dt is null;

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
	SELECT
	sd.sls_ord_num  AS order_number,
    vd.product_key  AS product_key,
    vc.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
		FROM silver.crm_sales_details sd
		Left Join Gold.dim_product vd 
		on sd.sls_prd_key=vd.product_number
		Left Join Gold.dim_customer vc
		on sd.sls_cust_id = vc.customer_id;
