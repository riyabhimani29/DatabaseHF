USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Customer_Delete]    Script Date: 27-04-2026 11:51:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
ALTER  PROCEDURE [dbo].[M_Customer_Delete]    
@Cust_Id int ,    
@RetVal INT = 0 OUT,            
@RetMsg varchar(max) = '' OUT     
    
AS    
    
SET NOCOUNT ON    
    
 IF NOT EXISTS(Select 1 from M_Customer With (NOLOCK) WHERE Cust_Id = @Cust_Id)    
 BEGIN    
    SET @RetVal = -12 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
     SET @RetMsg ='Record is Already been deleted by another user.'             
    Return    
 END     
    
-- IF EXISTS ( SELECT  1  FROM dbo.Enquiry WITH ( NOLOCK ) WHERE   Cust_Id = @Cust_Id )         
--BEGIN            
-- SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.             
-- SET @RetMsg ='Can Not delete because record Exist On Enquiry Table.'                  
-- RETURN            
--END     
  
       DELETE FROM M_Customer    
       WHERE Cust_Id = @Cust_Id    
    
    
IF @@ERROR =  0    
BEGIN    
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED    
    SET @RetMsg ='Customer Details Delete Successfully.'  
End    
ELSE    
BEGIN    
   SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED   
   SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
End
GO


