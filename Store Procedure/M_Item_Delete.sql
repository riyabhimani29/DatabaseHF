USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Delete]    Script Date: 27-04-2026 12:19:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Item_Delete]
@Item_Id int ,
@RetVal	INT = 0	OUT,      
@RetMsg varchar(max) = '' OUT    

AS

SET NOCOUNT ON

		IF NOT EXISTS(Select 1 from M_Item With (NOLOCK) WHERE Item_Id=@Item_Id)
		BEGIN
			SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Record is Already been deleted by another user.'       
		   Return
		END

		IF EXISTS ( SELECT  1  FROM dbo.StockView WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On Stock Table.'            
            RETURN      
        END    
		IF EXISTS ( SELECT  1  FROM dbo.DC_Dtl WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'            
            RETURN      
        END
		IF EXISTS ( SELECT  1  FROM dbo.M_SupplierDtl WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On Supplier Item Table.'            
            RETURN      
        END
		IF EXISTS ( SELECT  1  FROM dbo.PO_DTL WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id and PO_ID NOT IN (select PO_ID from  PO_MST where PO_Type = 'X') )   
        BEGIN      
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On PO Table.'            
            RETURN      
        END
		IF EXISTS ( SELECT  1  FROM dbo.GRN_Dtl WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -105 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On GRN Table.'            
            RETURN      
        END
		IF EXISTS ( SELECT  1  FROM dbo.StockTrans_Dtl WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -106 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On Stock Transfer Table.'            
            RETURN      
        END		
		IF EXISTS ( SELECT  1  FROM dbo.GlassQR_Dtl WITH ( NOLOCK ) WHERE   Item_Id = @Item_Id )   
        BEGIN      
            SET @RetVal = -107 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
			SET @RetMsg ='Can Not delete because record Exist On Glass QR Table.'            
            RETURN      
        END		
		
       DELETE FROM M_Item WHERE Item_Id = @Item_Id
 
	IF @@ERROR =  0
	BEGIN
	   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED     
	   SET @RetMsg ='Record Deleted Successfully.'         
	End
	ELSE
	BEGIN
	   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED     
			SET @RetMsg ='Failed to Delete Data.'         
	End
GO


