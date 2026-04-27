USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_DCGRN_InvNo_Edit]    Script Date: 27-04-2026 11:36:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                           
ALTER PROCEDURE [dbo].[GRN_Mst_DCGRN_InvNo_Edit] @GRN_Id         INT,        
                                           @GRN_No         VARCHAR(500),                    
                                           @Inv_No     VARCHAR(500),        
                                           @Remark         VARCHAR(500),              
                                           @MAC_Add        VARCHAR(500),                
                                           @Entry_User     INT,              
                                           @Upd_User       INT,              
                                           @Year_Id        INT,              
                                           @Branch_ID      INT,                         
                                           @RetVal         INT = 0 out,              
                                           @RetMsg         VARCHAR(max) = '' out              
AS              
    SET nocount ON              
       
--BEGIN try              
--BEGIN TRANSACTION              
              
      /************************************* TRANSACTION *************************************/              
      DECLARE @_DeptShortNm AS VARCHAR(20)='GRN',    @_Old_Inv_No AS VARCHAR(50)='',          
              @_Invoice_No  AS INT = 0              
    
set @_Old_Inv_No = (	select isnull(Inv_No,'') from GRN_Mst where GRN_Id = @GRN_Id  )

	INSERT INTO [dbo].[GRN_Mst_Inv_History] WITH(rowlock)  
           ([GRN_Id]
           ,[O_Inv_No]
           ,[N_Inv_No]
           ,[Remark]
           ,[Upd_User]
           ,[Upd_Date])
     VALUES
           (@GRN_Id
           ,@_Old_Inv_No
           ,@Inv_No
           ,@Remark
           ,@Upd_User
           ,dbo.Get_sysdate() )

   update GRN_Mst  WITH(rowlock)    
   set   Inv_No = @Inv_No ,  
	   Remark =  Remark +' / ' + @Remark ,  
	   Upd_User = @Upd_User,  
	   Upd_Date = dbo.Get_sysdate()  
   where GRN_Id = @GRN_Id  
  
             
      SET @RetMsg ='GRN Edit Successfully No is : '  + @GRN_No + ' .'              
      SET @RetVal = 101            
              
      IF @@ERROR <> 0              
        BEGIN              
            SET @RetVal = -404 -- 0 IS FOR ERROR                                          
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'              
        END               
        
  --END try              
              
  --BEGIN catch              
  --    ROLLBACK              
              
  --    /************************************* ROLLBACK *************************************/              
  --    SET @RetVal = -405              
  --    -- 0 IS FOR ERROR                                                                
  --    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'              
  --END catch 
GO


