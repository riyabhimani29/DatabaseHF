USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DC_Mst_Cancel]    Script Date: 27-04-2026 11:20:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                 
ALTER PROCEDURE [dbo].[DC_Mst_Cancel]    @DC_Id             INT,                             
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
        
    DECLARE @DC_No VARCHAR(10)=''        
        
  BEGIN        
      BEGIN try        
          BEGIN TRANSACTION        
        
      /************************************* TRANSACTION *************************************/        
          -- ????? ?? ?? ???? ????? ??? ?? ?????? ??? ?? , ?? ?? ???? ?? ?? ????? ??? ???? ??? ?? ?????? ??? .            
          UPDATE stockview        
          SET    stockview.sales_qty = Isnull(stockview.sales_qty, 0) - dc_dtl.Qty,        
                 stockview.pending_qty = Isnull(stockview.pending_qty, 0) + dc_dtl.Qty,        
                 stockview.lastupdate = dbo.Get_sysdate() ,      
				 StockEntryPage = 'DC-GRN-CAN' ,  
				 StockEntryQty = dc_dtl.Qty ,
				 Dtl_Id  = DC_Dtl.DCDtl_Id ,
				 Tbl_Name ='DC_Dtl'
          FROM   StockView        
                 LEFT JOIN DC_Dtl WITH (nolock)        
                        ON DC_Dtl.Stock_Id = stockview .Id        
          WHERE  DC_Dtl.DC_Id = @DC_Id        
        
          --DECLARE @_Godown_Id AS INT = 0,        
          --                                     @_SType     AS VARCHAR(5) = '',        
          --                                     @_Scarpval  AS NUMERIC(18, 2) = 0,        
          --                                     @_Width     AS NUMERIC(18, 3) = 0        
          --                             SELECT @_Godown_Id = Isnull(Godown_Id, 0),        
          --                                    @_SType = SType,        
          --                                    @_Width = Isnull(Width, 0)        
          --                             FROM   StockView WITH (nolock)        
          --                             WHERE  id = (select top 1 dc_dtl.stock_id from dc_dtl  with (nolock) where   dc_dtl.dc_id = @DC_Id )        
          --UPDATE StockView WITH (rowlock)        
          --                                            SET    Scrap_Settle = Isnull( Scrap_Settle , 0) + @_Scrap_Qty,        
          --                                                   Scrap_Qty = Isnull( Scrap_Qty , 0) + @_Scrap_Qty,        
          --                                                   LastUpdate = dbo.Get_sysdate()        
          --                                            WHERE  StockView.Godown_Id = @_Godown_Id        
          --                                                   AND StockView.Item_Id = @_Item_Id        
          --                                                   AND StockView.SType = @_SType        
          --                                                   AND StockView.Length = @_Scrap_Length        
          --                                                   AND StockView.Width = @_Width        
        /*******************************************************************************************************************************/        
        /*******************************************************************************************************************************/        
          BEGIN        
              --DECLARE @_Godown_Id AS INT = 0,        
              --                           @_SType     AS VARCHAR(5) = '',        
              --                                     @_Scarpval  AS NUMERIC(18, 2) = 0,        
              --                                     @_Width     AS NUMERIC(18, 3) = 0        
              --     SELECT @_Godown_Id = Isnull(Godown_Id, 0),        
              --                                    @_SType = SType,        
              --                                    @_Width = Isnull(Width, 0)        
              --                             FROM   StockView WITH (nolock)        
              --                             WHERE  id = (select top 1 dc_dtl.stock_id from dc_dtl  with (nolock) where   dc_dtl.dc_id = @DC_Id )        
                      
     DECLARE @_stock_id     AS INT = 0,        
                      @_DCDtl_Id     AS INT = 0,        
                      @_Item_Id      AS INT = 0,        
                      @_Scrap_Length AS NUMERIC(18, 3) = 0,        
                      @_Scrap_Qty AS NUMERIC(18, 3) = 0        
                
              DECLARE db_cursor CURSOR FOR        
                SELECT dc_dtl.stock_id,        
                       dc_dtl.dcdtl_id,        
                       scrap_length,        
                       item_id,        
						Scrap_Qty        
                FROM   dc_dtl WITH (nolock)        
                WHERE  dc_dtl.dc_id = @DC_Id;        
        
              OPEN db_cursor        
        
              FETCH next FROM db_cursor INTO @_stock_id, @_DCDtl_Id, @_Scrap_Length, @_Item_Id , @_Scrap_Qty        
        
              WHILE @@FETCH_STATUS = 0        
                BEGIN        
                    BEGIN        
                        DECLARE @_Godown_Id AS INT = 0,        
                                @_SType     AS VARCHAR(5) = '',        
                                @_Scarpval  AS NUMERIC(18, 2) = 0,        
                                @_Width     AS NUMERIC(18, 3) = 0 ,    
								@_Rack_Id AS INT = 0    
        
                        SELECT @_Godown_Id = Isnull(godown_id, 0),        
                               @_SType = stype,        
                               @_Width = Isnull(width, 0)  ,        
                               @_Rack_Id = Isnull(Rack_Id, 0)        
                        FROM   stockview WITH (nolock)        
                        WHERE  id = @_stock_id        
        
                        SELECT @_Scarpval = Isnull(master_numvals, 0)        
                        FROM   m_master WITH (nolock)        
                        WHERE  m_master.master_type = 'SCRAP'        
                               AND m_master.is_active = 1        
        
                        IF EXISTS (SELECT 1        
                                   FROM   stockview WITH (nolock)        
                                   WHERE  stockview.godown_id = @_Godown_Id        
                                          AND stockview.item_id = @_Item_Id        
                                          AND stockview.stype = @_SType        
                                          AND stockview.length = @_Scrap_Length        
                                          AND stockview.width = @_Width    
										  AND Rack_Id = @_Rack_Id )        
                          BEGIN        
                              IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Length )        
                                BEGIN        
                                    -- Scrap_Settle                                      
                                    UPDATE stockview WITH (rowlock)        
                                    SET    scrap_settle = Isnull(scrap_settle, 0 ) - @_Scrap_Qty,        
                                           scrap_qty = Isnull(scrap_qty, 0) - @_Scrap_Qty,        
                                           lastupdate = dbo.Get_sysdate() /*,    
										   StockEntryPage = 'DC-GRN' */    
                                    WHERE  stockview.godown_id = @_Godown_Id      
                                           AND stockview.item_id = @_Item_Id        
                                           AND stockview.stype = @_SType        
                                           AND stockview.length = @_Scrap_Length        
											AND stockview.width = @_Width    
											AND Rack_Id = @_Rack_Id         
                                END        
                              ELSE        
                                BEGIN        
                                    UPDATE stockview WITH (rowlock)        
                                    SET    pending_qty = Isnull(pending_qty, 0) - @_Scrap_Qty,        
                                           scrap_qty = Isnull(scrap_qty, 0) - @_Scrap_Qty,        
                                           lastupdate = dbo.Get_sysdate()  ,    
										   StockEntryPage = 'DC-GRN' ,  
										   StockEntryQty  = @_Scrap_Qty ,
										   Dtl_Id = @_DCDtl_Id ,
										   Tbl_Name = 'DC_Dtl'
                                    WHERE  stockview.godown_id = @_Godown_Id        
                                           AND stockview.item_id = @_Item_Id        
                                           AND stockview.stype = @_SType        
                                           AND stockview.length = @_Scrap_Length        
                                           AND stockview.width = @_Width    
										   AND Rack_Id = @_Rack_Id         
                                END        
                          END        
                    END        
        
                    FETCH next FROM db_cursor INTO @_stock_id, @_DCDtl_Id, @_Scrap_Length, @_Item_Id , @_Scrap_Qty        
                END        
        
              CLOSE db_cursor        
        
              DEALLOCATE db_cursor        
          END        
        
      /*******************************************************************************************************************************/        
      /*******************************************************************************************************************************/        
          --UPDATE stockview WITH (rowlock)        
          --SET    pending_qty = Isnull(pending_qty, 0) - Sdc_dtl.crap_Qty,        
          --     scrap_qty = Isnull(scrap_qty, 0) - dc_dtl.Scrap_Qty,        
          --     lastupdate = dbo.Get_sysdate()        
          --FROM   stockview        
          --     LEFT JOIN dc_dtl WITH (nolock)        
          --        ON dc_dtl.stock_id = stockview .id        
          --WHERE  dc_dtl.dc_id = @DC_Id          
            
          UPDATE dc_mst WITH (rowlock)        
          SET    codc_type = 'C'        
          WHERE  dc_id = @DC_Id        
        
          SET @RetMsg = 'Coating DC Delete Successfully .'        
          SET @RetVal = @DC_Id        
        
          COMMIT        
        
          /************************************* COMMIT *************************************/        
          IF @@ERROR <> 0        
            BEGIN        
                SET @RetVal = 0        
                -- 0 IS FOR ERROR                                                                     
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


