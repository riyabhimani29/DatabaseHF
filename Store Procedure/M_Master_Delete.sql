USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Master_Delete]    Script Date: 27-04-2026 12:33:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Master_Delete]
@Master_Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON

	IF NOT EXISTS(Select 1 from M_Master With (NOLOCK) WHERE Master_Id=@Master_Id)
	BEGIN
	   SET @RetVal = -12 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.      
		   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END
	 
	IF EXISTS ( SELECT  1  FROM dbo.DC_Dtl WITH ( NOLOCK ) WHERE   Unit_Id = @Master_Id )     
        BEGIN        
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'              
            RETURN        
        END 

	IF EXISTS ( SELECT  1  FROM dbo.M_Employee WITH ( NOLOCK ) WHERE   Emp_RoleId = @Master_Id )     
        BEGIN        
            SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Employee Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Godown WITH ( NOLOCK ) WHERE   Godown_TypeId = @Master_Id )     
        BEGIN        
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Godown Table.'              
            RETURN        
        END 		
	IF EXISTS ( SELECT  1  FROM dbo.M_Item WITH ( NOLOCK ) WHERE   Unit_Id = @Master_Id )     
        BEGIN        
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Project WITH ( NOLOCK ) WHERE   Project_Type_Id = @Master_Id )     
        BEGIN        
            SET @RetVal = -105 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Project Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.PO_DTL WITH ( NOLOCK ) WHERE   Unit_Id = @Master_Id )     
        BEGIN        
            SET @RetVal = -106-- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On PO Table.'              
            RETURN        
        END 

       DELETE FROM M_Master
       WHERE Master_Id = @Master_Id


IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


