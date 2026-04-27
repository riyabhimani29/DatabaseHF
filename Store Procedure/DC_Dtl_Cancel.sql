USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DC_Dtl_Cancel]    Script Date: 27-04-2026 11:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

               
ALTER  PROCEDURE [dbo].[DC_Dtl_Cancel]    @DC_Id             INT,        
            @DCDtl_Id int,      
                                          @Remark            VARCHAR(500),                          
                                          @MAC_Add           VARCHAR(500),                          
                                          @Entry_User        INT,                          
                                          @Upd_User          INT,                          
                                          @Year_Id           INT,                          
                                          @Branch_ID         INT,                                
                                          @RetVal            INT = 0 out,                          
                                          @RetMsg            VARCHAR(max) = ''out                             
AS                          
    SET nocount ON                          
                
   declare @DC_No varchar(10)=''          
          
  BEGIN            
        
      
  if exists  (select 1 from DC_Dtl with (nolock) where   DC_Dtl.DC_Id = @DC_Id   And  DC_Dtl.Is_Revision   = 1  )        
  begin      
   SET @RetMsg = 'Selected Item Already Revision of DC  .'                    
          SET @RetVal = -101          
  return      
  end       
      
    if (select COUNT(1) from DC_Dtl with (nolock) where   DC_Dtl.DC_Id = @DC_Id   And  DC_Dtl.Is_Revision   = 0  ) = 1       
  begin      
   SET @RetMsg = 'Item Revision of DC will not be done, as there is only one item in this DC .'                    
          SET @RetVal = -100          
  return      
  end        
      BEGIN try                    
          BEGIN TRANSACTION                    
                    
          /************************************* TRANSACTION *************************************/                    
   -- ????? ?? ?? ???? ????? ??? ?? ?????? ??? ?? , ?? ?? ???? ?? ?? ????? ??? ???? ??? ?? ?????? ??? .          
            
   UPDATE stockview          
   SET    stockview.Sales_Qty = Isnull(stockview.sales_qty, 0) - DC_Dtl.DC_Qty,          
     stockview.Pending_Qty = Isnull(stockview.pending_qty, 0) + DC_Dtl.DC_Qty,          
     stockview.lastupdate = dbo.Get_sysdate()  ,    
  stockview.StockEntryPage = 'CO-DC-CANCEL' ,  
  StockEntryQty =  DC_Dtl.DC_Qty  ,
  Dtl_Id = @DCDtl_Id , 
Tbl_Name = 'DC_Dtl'
   FROM   stockview          
       LEFT JOIN DC_Dtl with (nolock) ON DC_Dtl.stock_id = stockview .id          
   WHERE  DC_Dtl.DC_Id = @DC_Id   and  DC_Dtl.DCDtl_Id = @DCDtl_Id And  DC_Dtl.Is_Revision   = 0       
          
      
 update DC_Dtl with (rowlock) set Pending_Qty = 0  , Is_Revision = 1   WHERE  DC_Dtl.DC_Id = @DC_Id   and  DC_Dtl.DCDtl_Id = @DCDtl_Id And  DC_Dtl.Is_Revision   = 0       
          
   --update DC_Mst with (rowlock)  set CODC_Type='C' where dc_id = @DC_Id           
          
          SET @RetMsg = 'DC Item Revision Successfully .'                    
          SET @RetVal = @DC_Id                  
                      
          COMMIT                    
          /************************************* COMMIT *************************************/              
          
          IF @@ERROR <> 0                    
            BEGIN                    
                SET @RetVal = 0 -- 0 IS FOR ERROR                                                                   
                SET @RetMsg ='Error Occurred - ' + Error_message() + ' .'                    
            END               
      END try                    
                    
      BEGIN catch                    
          ROLLBACK                             
          /************************************* ROLLBACK *************************************/                    
          SET @RetVal = -405                    
          -- 0 IS FOR ERROR                                                                    
          SET @RetMsg ='Error Occurred ' + Error_message() + '.'                    
      END catch          
           
  END 
GO


