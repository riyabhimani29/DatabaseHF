USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Department_Delete]    Script Date: 27-04-2026 11:53:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
ALTER PROCEDURE [dbo].[M_Department_Delete]  
@Dept_ID int ,
@RetVal INT = 0 OUT,        
@RetMsg varchar(max) = '' OUT      
  
AS  
  
SET NOCOUNT ON  
   
	IF NOT EXISTS(Select 1 from M_Department With (NOLOCK) WHERE Dept_ID=@Dept_ID)
	BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END
  
  IF EXISTS ( SELECT  1  FROM dbo.DC_Dtl WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'              
            RETURN        
        END      
  IF EXISTS ( SELECT  1  FROM dbo.GRN_Mst WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On GRN Table.'              
            RETURN        
        END  
  IF EXISTS ( SELECT  1  FROM dbo.M_Employee WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Employee Table.'              
            RETURN        
        END  
  IF EXISTS ( SELECT  1  FROM dbo.M_Item_Group WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Group Table.'              
            RETURN        
        END  
  IF EXISTS ( SELECT  1  FROM dbo.M_Supplier WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -105 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Supplier Table.'              
            RETURN        
        END  
  IF EXISTS ( SELECT  1  FROM dbo.PO_MST WITH ( NOLOCK ) WHERE   Dept_ID = @Dept_ID )     
        BEGIN        
            SET @RetVal = -106 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On PO Table.'              
            RETURN        
        END    
    
       DELETE FROM M_Department WHERE Dept_ID = @Dept_ID  
   
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


