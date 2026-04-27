USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Menu_Rigths_Ins]    Script Date: 27-04-2026 12:38:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure              
              
 ALTER PROCEDURE [dbo].[M_Menu_Rigths_Ins]                                         
@DT Tbl_MenuRightmDetail READONLY ,                                                 
@Emp_Id int ,               
@RetVal INT = 0 OUT   ,                
@RetMsg varchar(max) = '' OUT                 
              
AS                
              
SET NOCOUNT ON                
              
     DELETE FROM [dbo].[M_Menu_Rigths]  
      WHERE[dbo].[M_Menu_Rigths].Emp_Id= @Emp_Id  
      
 DECLARE @_MenuId AS INT= 0 ,@_Id AS INT= 0 ,  @_IsListView AS BIT= 0  ,  @_IsView AS BIT= 0  ,  @_IsAdd AS BIT= 0  ,  @_IsDelete AS BIT= 0  ,  @_IsEdit AS BIT= 0   
           
   DECLARE Purchase_CUR CURSOR FOR                               
            SELECT  MenuId,Id,IsListView,IsView,IsAdd,IsDelete,IsEdit FROM @DT ;                                                 
              
            OPEN Purchase_CUR                                          
            FETCH NEXT FROM Purchase_CUR INTO @_MenuId ,@_Id, @_IsListView , @_IsView ,  @_IsAdd ,  @_IsDelete,  @_IsEdit   
              
            WHILE @@FETCH_STATUS = 0                                               
                BEGIN                                       
              
					INSERT INTO [dbo].[M_Menu_Rigths]  
						 ([MenuId]  
						 ,[Emp_Id]  
						 ,[IsListView]  
						 ,[IsView]  
						 ,[IsAdd]  
						 ,[IsDelete]  
						 ,[IsEdit])  
					  VALUES  
						 (@_MenuId  
						 ,@Emp_Id  
						 ,@_IsListView  
						 ,@_IsView  
						 ,@_IsAdd  
						 ,@_IsDelete  
						 ,@_IsEdit)  
              
                    FETCH NEXT FROM Purchase_CUR INTO  @_MenuId ,@_Id, @_IsListView , @_IsView ,  @_IsAdd ,  @_IsDelete,  @_IsEdit   
              
                END                                   
            CLOSE Purchase_CUR ;                                                  
            DEALLOCATE Purchase_CUR ;   
      
  SET @RetMsg ='Menu Rights Assigned Successfully.'               
  SET @RetVal = SCOPE_IDENTITY()               
GO


