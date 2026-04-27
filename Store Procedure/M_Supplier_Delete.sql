USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Supplier_Delete]    Script Date: 27-04-2026 12:46:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
ALTER PROCEDURE [dbo].[M_Supplier_Delete]    
@Supplier_Id int ,    
@RetVal INT = 0 OUT,          
@RetMsg varchar(max) = '' OUT        
    
AS    
    
SET NOCOUNT ON    
    
  IF NOT EXISTS(Select 1 from M_Supplier With (NOLOCK) WHERE Supplier_Id=@Supplier_Id)    
  BEGIN    
   SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
   SET @RetMsg ='Record is Already been deleted by another user.'           
     Return    
  END    
    
  IF EXISTS ( SELECT  1  FROM dbo.GRN_Mst WITH ( NOLOCK ) WHERE   Supplier_Id = @Supplier_Id )       
        BEGIN          
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
   SET @RetMsg ='Can Not delete because record Exist On GRN Table.'                
            RETURN          
        END        
  --IF EXISTS ( SELECT  1  FROM dbo.M_SupplierDtl WITH ( NOLOCK ) WHERE   Supplier_Id = @Supplier_Id )       
  --      BEGIN          
  --          SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
  -- SET @RetMsg ='Can Not delete because record Exist On Supplie Details Table.'                
  --          RETURN          
  --      END    
  IF EXISTS ( SELECT  1  FROM dbo.PO_MST WITH ( NOLOCK ) WHERE   Supplier_Id = @Supplier_Id  AND po_mst.po_type <> 'X'    )       
        BEGIN          
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
   SET @RetMsg ='Can Not delete because record Exist On PO Table.'                
            RETURN          
        END    
  IF EXISTS ( SELECT  1  FROM dbo.PO_DTL WITH ( NOLOCK ) WHERE   SupDetail_Id IN (select SupDetail_Id from M_SupplierDtl where Supplier_Id = @Supplier_Id ) )       
        BEGIN          
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
   SET @RetMsg ='Can Not delete because record Exist On PO Detail Table.'                
            RETURN          
        END    
  IF EXISTS ( SELECT  1  FROM dbo.GRN_Dtl WITH ( NOLOCK ) WHERE  SupDetail_Id IN (select SupDetail_Id from M_SupplierDtl where Supplier_Id = @Supplier_Id )  )       
        BEGIN          
            SET @RetVal = -105 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
   SET @RetMsg ='Can Not delete because record Exist On GRN Detail Table.'                
            RETURN          
        END    
   
    delete from M_SupplierDtl  WHERE Supplier_Id = @Supplier_Id    
       DELETE FROM M_Supplier WHERE Supplier_Id = @Supplier_Id    
     
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


