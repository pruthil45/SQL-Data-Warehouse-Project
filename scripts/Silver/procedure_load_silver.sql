/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		Insert Into Silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			Cst_gndr,
			cst_create_date
		)
		Select
			cst_id,
			cst_key,
			Trim(cst_firstname)AS cst_firstname,
			Trim(cst_lastname)AS cst_lastname,
			Case When Upper(cst_marital_status)='M' then 'Married'
				 When Upper(cst_marital_status)='s' then 'Single'
				 Else 'n\a'
			End cst_marital_status,
			Case When Upper(cst_gndr)='M' then 'Male'
				 When Upper(cst_gndr)='F' then 'FeMale'
				 Else 'n\a'
			End Cst_gndr,
			cst_create_date 
		from (
			select * , Row_Number()Over(Partition By cst_id order by cst_create_date) as flag_last 
			from Bronze.crm_cust_info 
			where cst_id is not null
			) t 
		where flag_last =1; -- Select the most recent record per customer
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.crm_prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO Silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		Select 
			prd_id,
			Replace(Substring(prd_key,1,5),'-','_') as cat_id,
			Substring(prd_key,7,Len(prd_key)) as prd_key,
			prd_nm,
			Isnull(prd_cost,0)as prd_cost,
			Case
				When prd_line='M' Then 'Mountain'
				When prd_line='R' Then 'Road'
				When prd_line='S' Then 'Other Sales'
				When prd_line='T' Then 'Tourist'
				Else 'n\a'
			End prd_line,
			Cast(prd_start_dt As Date) as prd_start_dt,
			Cast(Lead(prd_start_dt)Over(Partition By prd_key Order By prd_start_dt)-1 As Date) as prd_end_date
		from Bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting Data Into: silver.crm_sales_details';
		INSERT INTO Silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		Select
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			Case
				When sls_order_dt=0 or len(sls_order_dt)!=8 Then Null
				Else Cast(Cast(sls_order_dt As varchar)As Date)
			End sls_order_dt,
			Case
				When sls_ship_dt=0 or len(sls_ship_dt)!=8 Then Null
				Else Cast(Cast(sls_ship_dt As varchar)As Date)
			End sls_ship_dt,
			Case
				When sls_due_dt=0 or len(sls_due_dt)!=8 Then Null
				Else Cast(Cast(sls_due_dt As varchar)As Date)
			End sls_due_dt,
			Case 
				When sls_sales Is Null or sls_sales>=0 or sls_sales!= sls_quantity * Abs(sls_price)
					Then  sls_quantity * Abs(sls_price)
				Else sls_sales
			End sls_sales,
			sls_quantity,
			Case 
				When sls_price Is Null or sls_price=0 Then  sls_sales/Nullif(sls_quantity,0)
				When sls_price >0 Then Abs(sls_price)
				Else sls_price
			End sls_price 
		from Bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

        -- Loading erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO Silver.erp_CUST_AZ12 (
			cid,
			bdate,
			gen
		)
		Select
			Case 
				When CID like 'NAS%' Then SUBSTRING(CID,4,len(CID))
				Else CID
			End CID,
			Case
				When BDATE <'1924-01-01' Or BDATE > Getdate() Then Null
				Else BDATE
			End BDATE,
			Case
				When Upper(Trim(GEN)) ='MALE' or Upper(Trim(GEN)) ='M' Then 'Male'
				When Upper(Trim(GEN)) ='FEMALE' or Upper(Trim(GEN)) ='F' Then 'Female'
				Else 'n\a'
			End GEN
		from Bronze.erp_CUST_AZ12;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO Silver.erp_LOC_A101 (
			CID,
			CNTRY
		)
		Select
			Replace(CID,'-','') as CID,
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				ELSE TRIM(cntry)
			END AS cntry
		from Bronze.erp_LOC_A101;
	    SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';
		
		-- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO Silver.erp_PX_CAT_G1V2 (
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		)
		Select
			ID,
			CAT,
			SUBCAT,
			MAINTENANCE
		from Bronze.erp_PX_CAT_G1V2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END
