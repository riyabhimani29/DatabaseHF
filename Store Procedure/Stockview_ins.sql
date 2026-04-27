USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stockview_ins]    Script Date: 27-04-2026 15:03:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Stockview_ins] @Godown_Id     INT =10,          
                                       @Rack_Id Int =5,        
                                       @Item_Group_Id INT =  61,              
                                       @Item_Cate_Id  INT = 159,              
                                       @Item_Id       INT = 262,              
                                       @Length        NUMERIC(18, 3) = 5400,              
                                       @Total_Qty     NUMERIC(18, 3)=10,              
                                       @Width     NUMERIC(18, 3) = 2.65,              
                                       @SType         VARCHAR(500)='N',              
                                       @Remark        VARCHAR(500)='',    
                                       @IsZeroQty    BIT,
                                       @MAC_Add       VARCHAR(500)='',              
                                       @Entry_User    INT =1,              
                                       @Upd_User      INT =1,              
                                       @Year_Id       INT =1 ,              
                                       @Branch_ID     INT =1,              
                                       @RetVal        INT = 0 out,              
                                       @RetMsg        VARCHAR(max) = '' out              
AS              
    SET nocount ON              
      
      
              
  BEGIN try              
      BEGIN TRANSACTION              
      /************************************* TRANSACTION *************************************/              
      IF EXISTS (SELECT 1              
                 FROM   stockview WITH(nolock)              
                 WHERE  godown_id = @Godown_Id              
                        AND item_id = @Item_Id              
                        AND stype = @SType              
       AND [length] = @Length          
       AND Rack_Id = @Rack_Id            
       AND Width = @Width)              
        BEGIN  

        DECLARE @_StockView_Id INT = NULL;
        DECLARE @_OpeningStock_Id INT = NULL;

         SET @_StockView_Id = NULL;
         SET @_OpeningStock_Id = NULL;

                  SELECT @_StockView_Id = Id
                  FROM   stockview WITH(nolock)              
                 WHERE  godown_id = @Godown_Id              
                        AND item_id = @Item_Id              
                        AND stype = @SType              
                        AND [length] = @Length          
                        AND Rack_Id = @Rack_Id            
                        AND Width = @Width;    
                        
                   SELECT @_OpeningStock_Id = Id
                   FROM   OpeningStock_History WITH(nolock)
                   WHERE godown_id = @Godown_Id              
                        AND item_id = @Item_Id              
                        AND stype = @SType              
                        AND [length] = @Length          
                        AND Rack_Id = @Rack_Id            
                        AND Width = @Width;   
            INSERT INTO Stock_Transfer_History
            (
                Godown_Id,
                Item_Id,
                SType,
                Transfer_Qty,
                [Length],
                Width,
                Rack_Id,
                Transfer_Date,
                Remark,
                StockEntryPage,
                Tbl_Name,
                Transfer_Type,
                Transfer_TypeInBit,
                Stock_Id,
                Opening_Stock_Id
            )
            VALUES
            (
                @Godown_Id,
                @Item_Id,
                @SType,
                @Total_Qty,
                @Length,
                @Width,
                @Rack_Id,
                dbo.Get_Sysdate(),
                'Openingstock',
                'OpeningStockview_ins',
                'Openingstock',
                'IN',
                0,
                @_StockView_Id,
                @_OpeningStock_Id
            );

           
            UPDATE stockview WITH (rowlock)              
            SET    total_qty = Isnull(total_qty, 0) + @Total_Qty,              
                   pending_qty = Isnull(pending_qty, 0) + @Total_Qty ,              
    LastUpdate = dbo.Get_Sysdate()              
            WHERE  godown_id = @Godown_Id              
                   AND item_id = @Item_Id              
                   AND stype = @SType              
                   AND [length] = @Length              
       AND Width = @Width            
       AND Rack_Id = @Rack_Id            
        END 
        
      ELSE              
        BEGIN   
                DECLARE @_History_Id   INT = NULL;

                SET @_History_Id = NULL;
            INSERT INTO Stock_Transfer_History
            (
                Godown_Id,
                Item_Id,
                SType,
                Transfer_Qty,
                [Length],
                Width,
                Rack_Id,
                Transfer_Date,
                Remark,
                StockEntryPage,
                Tbl_Name,
                Transfer_Type,
                Transfer_TypeInBit,
                Stock_Id,
                Opening_Stock_Id
            )
            VALUES
            (
                @Godown_Id,
                @Item_Id,
                @SType,
                @Total_Qty,
                @Length,
                @Width,
                @Rack_Id,
                dbo.Get_Sysdate(),
                'Openingstock',
                'OpeningStockview_ins',
                'Openingstock',
                'IN',
                0,
                Null,
                Null
            );
            SET @_History_Id = SCOPE_IDENTITY();


            INSERT INTO stockview WITH(rowlock)              
                        (godown_id,              
                         item_id,              
                         stype,              
                         total_qty,              
                         sales_qty,              
                         pending_qty,              
                         [length],              
                         LastUpdate,            
                         Width,        
                         Rack_Id,Remark)              
            VALUES     ( @Godown_Id,              
                         @Item_Id,              
                         @SType,              
                         @Total_Qty,              
                         0,              
                         @Total_Qty,              
                         @Length ,              
                         dbo.Get_Sysdate(),            
                         @Width,        
                         @Rack_Id,@Remark)  
           --SET @_StockView_Id = SCOPE_IDENTITY();      
           update Stock_Transfer_History set Stock_Id = SCOPE_IDENTITY() where ID = @_History_Id;

         
      
        END              
              
                
              
      IF @@ERROR <> 0              
        BEGIN              
            SET @RetVal = @RetVal -- 0 IS FOR ERROR                                  
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'              
        END              
      ELSE              
        BEGIN              
            INSERT INTO openingstock_history WITH(rowlock)          
                        (godown_id,              
                         item_id,              
                         stype,              
                         total_qty,              
                         length,              
                         remark,              
                         mac_add,              
                         entry_user,              
                         entry_date,              
                         year_id,              
                         branch_id,            
                         Width,        
                         Rack_Id,
                         IsZeroQty)              
            VALUES     ( @Godown_Id,              
                         @Item_Id,              
                         @SType,              
                         @Total_Qty,              
                         @Length,              
                         @Remark,              
                         @MAC_Add,              
                         @Entry_User,              
                         dbo.Get_sysdate(),              
                         @Year_Id,              
                         @Branch_ID,            
                         @Width,        
                         @Rack_Id,
                         @IsZeroQty)              
              
     SET @RetMsg ='Stock Add Sucessfully .'              
      SET @RetVal = Scope_identity()   
      update Stock_Transfer_History set Opening_Stock_Id = SCOPE_IDENTITY() where ID = @_History_Id;

      
            COMMIT             
        /************************************* COMMIT *************************************/              
        END              
  END try              
              
  BEGIN catch              
      ROLLBACK              
      /************************************* ROLLBACK *************************************/              
              
      SET @RetVal = -405 -- 0 IS FOR ERROR                                  
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'              
  END catch
GO


