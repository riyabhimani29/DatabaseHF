USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_InvoiceNo_Chk]    Script Date: 27-04-2026 14:27:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                     
ALTER PROCEDURE [dbo].[PO_MST_InvoiceNo_Chk] @Invoice_No    INT,    
											@Dept_ID    INT,  
                                            @RetVal   INT = 0 out,    
                                            @RetMsg   VARCHAR(max) = '' out    
AS    
    SET nocount ON    
    
     
    IF EXISTS(select 1 from  PO_MST with(nolock) where Invoice_No = @Invoice_No and  Dept_ID = @Dept_ID)  
            BEGIN  
                SET @RetVal = -101  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg =  'The invoice number of ' + CONVERT(varchar,@Invoice_No)+' is Already Generated, Please Enter a new invoice Number.'  
  
  
      
                RETURN  
            END  
  
  
     
    
    IF @@ERROR = 0    
      BEGIN    
          SET @RetMsg ='Raise PO Status Update Successfully.'    
          SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED      
      END    
    ELSE    
      BEGIN    
          SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
          SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED      
      END 
GO


