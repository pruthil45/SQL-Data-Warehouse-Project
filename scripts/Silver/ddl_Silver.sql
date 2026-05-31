/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Silver' Tables
===============================================================================
*/

IF OBJECT_ID('Silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_cust_info;
GO
Create table Silver.crm_cust_info(
	 cst_id int,
	 cst_key nvarchar(50),
	 cst_firstname nvarchar(50),
	 cst_lastname nvarchar(50),
	 cst_marital_status nvarchar(10),
	 cst_gndr nvarchar(10),
	 cst_create_date date,
	 dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('Silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Silver.crm_prd_info;
GO

Create table Silver.crm_prd_info(
	 prd_id int,
	 cat_id nvarchar(50),
	 prd_key nvarchar(50),
	 prd_nm nvarchar(50),
	 prd_cost int,
	 prd_line nvarchar(50),
	 prd_start_dt date,
	 prd_end_dt date,
	 dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('Silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Silver.crm_sales_details;
GO

Create table Silver.crm_sales_details(
	 sls_ord_num nvarchar(50),
	 sls_prd_key nvarchar(50),
	 sls_cust_id int,
	 sls_order_dt Date,
	 sls_ship_dt Date,
	 sls_due_dt Date,
	 sls_sales int,
	 sls_quantity int,
	 sls_price int,
	 dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('Silver.erp_LOC_A101', 'U') IS NOT NULL
    DROP TABLE Silver.erp_LOC_A101;
GO

Create table Silver.erp_LOC_A101(
CID nvarchar(50),
CNTRY nvarchar(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('Silver.erp_CUST_AZ12', 'U') IS NOT NULL
    DROP TABLE Silver.erp_CUST_AZ12;
GO

Create table Silver.erp_CUST_AZ12(
CID nvarchar(50),
BDATE date,
GEN nvarchar(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('Silver.erp_PX_CAT_G1V2', 'U') IS NOT NULL
    DROP TABLE Silver.erp_PX_CAT_G1V2;
GO

Create table Silver.erp_PX_CAT_G1V2(
ID nvarchar(50),
CAT nvarchar(50),
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(50),
dwh_create_date DATETIME2 DEFAULT GETDATE()
);
Go
