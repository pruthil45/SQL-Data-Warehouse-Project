Create or Alter Procedure Bronze.load_bronze As
Begin
	Declare @start_time Datetime, @end_time Datetime, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	Begin Try
		SET @batch_start_time = GETDATE();
		Print'===========================================';
		Print'Loading The Bronze Layer';
		Print'===========================================';

		Print'-------------------------------------------';
		Print'Loading Crm Tables';
		Print'-------------------------------------------';
		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.crm_cust_info'
		Truncate table Bronze.crm_cust_info
		Print'Bulk Inserting Data into Table :- Bronze.crm_cust_info'
		Bulk Insert Bronze.crm_cust_info
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_crm\cust_info.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.crm_cust_info;

		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.crm_prd_info'
		Truncate table Bronze.crm_prd_info
		Print'Bulk Inserting Data into Table :- Bronze.crm_prd_info'
		Bulk Insert Bronze.crm_prd_info
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_crm\prd_info.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.crm_prd_info;

		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.crm_sales_details'
		Truncate table Bronze.crm_sales_details
		Print'Bulk Inserting Data into Table :- Bronze.crm_sales_details'
		Bulk Insert Bronze.crm_sales_details
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_crm\sales_details.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.crm_sales_details;

		Print'-------------------------------------------';
		Print'Loading Erp Tables';
		Print'-------------------------------------------';

		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.erp_LOC_A101'
		Truncate table Bronze.erp_LOC_A101
		Print'Bulk Inserting Data into Table :- erp_LOC_A101'
		Bulk Insert Bronze.erp_LOC_A101
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_erp\LOC_A101.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.erp_LOC_A101;

		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.erp_CUST_AZ12'
		Truncate table Bronze.erp_CUST_AZ12
		Print'Bulk Inserting Data into Table :- erp_CUST_AZ12'
		Bulk Insert Bronze.erp_CUST_AZ12
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_erp\CUST_AZ12.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.erp_CUST_AZ12;

		Set @start_time =GETDATE();
		Print'Trunacting Table :- Bronze.erp_PX_CAT_G1V2'
		Truncate table Bronze.erp_PX_CAT_G1V2
		Print'Bulk Inserting Data into Table :- erp_PX_CAT_G1V2'
		Bulk Insert Bronze.erp_PX_CAT_G1V2
		From 'C:\Users\ASUS\Desktop\sql\sql-data-warehouse-project-main\datasets\source_erp\PX_CAT_G1V2.csv'
			With(
			FirstRow =2,
			FieldTerminator =',',
			TabLock
			);
		Set @end_time =GETDATE();
		Print'Load Duration:- ' + Cast(DateDiff(second,@start_time,@end_time)AS Nvarchar)+ 'seconds.';
		Print'----------------';
			--select * from Bronze.erp_PX_CAT_G1V2;
		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

	End Try
	Begin Catch
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	End Catch
End;


Exec Bronze.load_bronze;
