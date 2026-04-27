USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_Delete]    Script Date: 27-04-2026 12:03:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Godown_Delete]
@Godown_Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON

	IF NOT EXISTS(Select 1 from M_Godown With (NOLOCK) WHERE Godown_Id = @Godown_Id)
	BEGIN
	   SET @RetVal = -12 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.      
		   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END	

	IF EXISTS ( SELECT  1  FROM dbo.DC_Mst WITH ( NOLOCK ) WHERE   Godown_Id = @Godown_Id )     
        BEGIN        
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.DC_Mst WITH ( NOLOCK ) WHERE   FrGodown_Id = @Godown_Id )     
        BEGIN        
            SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.GRN_Mst WITH ( NOLOCK ) WHERE   Godown_Id = @Godown_Id )     
        BEGIN        
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On GRN Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.StockView WITH ( NOLOCK ) WHERE   Godown_Id = @Godown_Id )     
        BEGIN        
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Stock Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.PO_MST WITH ( NOLOCK ) WHERE   Godown_Id = @Godown_Id )     
        BEGIN        
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Raise Direct PO Table.'              
            RETURN        
        END 
       DELETE FROM M_Godown
       WHERE Godown_Id = @Godown_Id


IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


