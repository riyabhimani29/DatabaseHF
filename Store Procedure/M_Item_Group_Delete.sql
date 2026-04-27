USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Group_Delete]    Script Date: 27-04-2026 12:23:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
ALTER PROCEDURE [dbo].[M_Item_Group_Delete]  
@Item_Group_Id int ,  
@RetVal INT = 0 OUT,        
@RetMsg varchar(max) = '' OUT      
  
AS  
  
SET NOCOUNT ON  
  
  IF NOT EXISTS(Select 1 from M_Item_Group With (NOLOCK) WHERE Item_Group_Id=Item_Group_Id)  
  BEGIN  
   SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
   SET @RetMsg ='Record is Already been deleted by another user.'         
     Return  
  END  
  
  declare @_Item_Group_Name as varchar(100)=''
  select @_Item_Group_Name = isnull(Item_Group_Name,'') from M_Item_Group with (nolock) where Item_Group_Id = @Item_Group_Id

	IF EXISTS ( SELECT  1  FROM dbo.M_Item WITH ( NOLOCK ) WHERE   Item_Group_Id = @Item_Group_Id )     
    BEGIN        
        SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
		SET @RetMsg ='Please Delete related Category for this '+@_Item_Group_Name+'.'              
        RETURN        
    END       

    DELETE FROM M_Item_Group WHERE Item_Group_Id = @Item_Group_Id
   
 IF @@ERROR =  0  
 BEGIN  
    SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED       
    SET @RetMsg ='Record Deleted Successfully.'           
 End  
 ELSE  
 BEGIN  
    SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED       
   SET @RetMsg ='Failed to Delete Data.'           
 End
GO


