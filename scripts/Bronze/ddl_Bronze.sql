/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_cust_info;
GO
Create table Bronze.crm_cust_info(
	 cst_id int,
	 cst_key nvarchar(50),
	 cst_firstname nvarchar(50),
	 cst_lastname nvarchar(50),
	 cst_marital_status nvarchar(10),
	 cst_gndr nvarchar(10),
	 cst_create_date date
);
GO

IF OBJECT_ID('Bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_prd_info;
GO

Create table Bronze.crm_prd_info(
	 prd_id int,
	 prd_key nvarchar(50),
	 prd_nm nvarchar(50),
	 prd_cost int,
	 prd_line nvarchar(50),
	 prd_start_dt datetime,
	 prd_end_dt datetime
);
GO

IF OBJECT_ID('Bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_sales_details;
GO

Create table Bronze.crm_sales_details(
	 sls_ord_num nvarchar(50),
	 sls_prd_key nvarchar(50),
	 sls_cust_id int,
	 sls_order_dt int,
	 sls_ship_dt int,
	 sls_due_dt int,
	 sls_sales int,
	 sls_quantity int,
	 sls_price int
);
GO

IF OBJECT_ID('Bronze.erp_LOC_A101', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_LOC_A101;
GO

Create table Bronze.erp_LOC_A101(
CID nvarchar(50),
CNTRY nvarchar(50)
);
GO

IF OBJECT_ID('Bronze.erp_CUST_AZ12', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_CUST_AZ12;
GO

Create table Bronze.erp_CUST_AZ12(
CID nvarchar(50),
BDATE date,
GEN nvarchar(50)
);
GO

IF OBJECT_ID('Bronze.erp_PX_CAT_G1V2', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_PX_CAT_G1V2;
GO

Create table Bronze.erp_PX_CAT_G1V2(
ID nvarchar(50),
BDATE date,
CAT nvarchar(50),
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(50)
);
Go
