USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stock_Daily_ins]    Script Date: 27-04-2026 14:52:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Stock_Daily_ins]         
                                       @RetVal        INT = 0 out,          
                                       @RetMsg        VARCHAR(max) = '' out          
AS          
    SET nocount ON          
  
  
          
  BEGIN try          
      BEGIN TRANSACTION          
      /************************************* TRANSACTION *************************************/          
      IF EXISTS (select 1 from  stock_daily where CONVERT(date,Entry_date)  =  CONVERT(date,dbo.Get_Sysdate()))          
        BEGIN          
            delete  from     stock_daily where CONVERT(date,Entry_date)  =  CONVERT(date,dbo.Get_Sysdate())
        END          
           
        BEGIN            
        
INSERT INTO [dbo].[Stock_Daily] with (rowlock)
           ([Stock_Id]
           ,[Godown_Id]
           ,[Item_Id]
           ,[SType]
           ,[Total_Qty]
           ,[Sales_Qty]
           ,[Pending_Qty]
           ,[Transfer_Qty]
           ,[Adjust_Qty]
           ,[Length]
           ,[Scrap_Qty]
           ,[Scrap_Settle]
           ,[LastUpdate]
           ,[Width]
           ,[Ref_Id]
           ,[ProDept_Qty]
           ,[RackNo]
           ,[Remark]
           ,[Rack_Id]
           ,[Entry_date])
		 SELECT [Id]
			  ,[Godown_Id]
			  ,[Item_Id]
			  ,[SType]
			  ,[Total_Qty]
			  ,[Sales_Qty]
			  ,[Pending_Qty]
			  ,[Transfer_Qty]
			  ,[Adjust_Qty]
			  ,[Length]
			  ,[Scrap_Qty]
			  ,[Scrap_Settle]
			  ,[LastUpdate]
			  ,[Width]
			  ,[Ref_Id]
			  ,[ProDept_Qty]
			  ,[RackNo]
			  ,[Remark]
			  ,[Rack_Id],
			  dbo.Get_Sysdate()
		  FROM [dbo].[StockView] with (nolock) where Godown_Id <> 0  and item_Id <> 0
  
     SET @RetMsg ='Stock Add Sucessfully .'          
      SET @RetVal = 1   
    /************************************* COMMIT *************************************/       
    COMMIT  
        END          
          
      IF @@ERROR <> 0          
        BEGIN          
            SET @RetVal = @RetVal -- 0 IS FOR ERROR                              
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
        END          
          
  END try          
          
  BEGIN catch          
      ROLLBACK          
      /************************************* ROLLBACK *************************************/          
          
      SET @RetVal = -405 -- 0 IS FOR ERROR                              
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
  END catch 
GO


