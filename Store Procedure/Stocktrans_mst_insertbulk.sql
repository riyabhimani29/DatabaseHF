USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stocktrans_mst_insertbulk]    Script Date: 27-04-2026 15:02:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

             
   
ALTER PROCEDURE [dbo].[Stocktrans_mst_insertbulk]                
@FrGodown_Id          INT,                
@ToGodown_Id          INT,                
@TransDate            DATE,                
@IssueBy              INT,                
@ReceiveBy            INT,                
@ProjectDocument      VARCHAR(500),                
@ProductionDepartment VARCHAR(500),                
@Remark               VARCHAR(500),                
@MAC_Add              VARCHAR(500),                
@Entry_User           INT,                
@Upd_User             INT,                
@Year_Id              INT,                
@Branch_ID            INT,                
                                              @Is_ProDept           BIT,            
@DtlPara TBL_STKTRANSDETAIL readonly,                
@RetVal               INT = 0 out,                
@RetMsg               VARCHAR(max) = '' out                
AS                
    SET nocount ON                
                
  BEGIN TRY                
      BEGIN TRANSACTION                
      /************************************* TRANSACTION *************************************/                
      INSERT INTO StockTrans_Mst WITH(rowlock)                
                  (frgodown_id,                
                   transdate,                
                   togodown_id,                
                   issueby,                
                   receiveby,                
                   projectdocument,                
                   productiondepartment,                
                   remark,                
                   mac_add,                
                   entry_user,                
                   entry_date,                
                   year_id,                
                   branch_id,            
                   is_prodept)                
      VALUES     ( @FrGodown_Id,                
                   @TransDate,                
                   @ToGodown_Id,                
                   @IssueBy,                
                   @ReceiveBy,                
                   @ProjectDocument,                
                   @ProductionDepartment,                
                   @Remark + ' BULK',                
                   @MAC_Add,                
                   @Entry_User,                
                   dbo.Get_sysdate(),                
                   @Year_Id,                
                   @Branch_ID,            
                                              @Is_ProDept               
        )                
                
      SET @RetMsg ='Stock Transfer Successfully.'                
      SET @RetVal = Scope_identity()                
                
      IF @@ERROR <> 0                
        BEGIN                
            SET @RetVal = 0                
            -- 0 IS FOR ERROR                                                           
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'                
        END                
      ELSE                
        BEGIN                
            DECLARE @_Id          AS INT= 0,                
                    @_Description AS VARCHAR(500)= '',                
                    @_Item_Id     AS INT= 0,                
                    @_Qty         AS NUMERIC(18, 3) = 0,                
                    @_Length      AS NUMERIC(18, 3) = 0,                
                    @_Remark      AS VARCHAR(500)= '',                
                    @_SType       AS VARCHAR(500)= ''                
                     
            DECLARE db_cursor CURSOR FOR                
              SELECT [description],                
                     qty,                
                     [length],                
                     remark,                
                     stype                
              FROM   @DtlPara;                
                
            OPEN db_cursor                
                
    FETCH next FROM db_cursor INTO @_Description, @_Qty, @_Length, @_Remark, @_SType                
                
            WHILE @@FETCH_STATUS = 0                
             BEGIN                
                  DECLARE @_S AS CHAR(1)=''                
                
                  SET @_S = CASE                
                              WHEN @_SType = 'Non-Coated' THEN 'N'                
                              ELSE 'C'                
                            END                
                  /**************      Fetch item ID   ***********/                
                  SET @_Item_Id = (SELECT TOP 1 item_id                
                                   FROM   m_item WITH (nolock)                
                                   WHERE  item_name = @_Description)                
                
                  IF ( @_Item_Id <> 0 ) -- Item Id Check                     
                    BEGIN                
                        /***** From Godown Stock Check  *****/                
                        IF EXISTS (SELECT 1                
                                   FROM   stockview WITH (nolock)                
                                   WHERE  item_id = @_Item_Id                
                                          AND godown_id = @FrGodown_Id                
                                          AND [length] = @_Length                
                                          AND stype = @_S                
                                          AND ( Isnull(pending_qty, 0) - @_Qty ) > 0)                
                          BEGIN                
                              SET @_Id = (SELECT TOP 1 id 
								          FROM   stockview WITH (nolock)                
                                          WHERE  item_id = @_Item_Id                
                                                 AND godown_id = @FrGodown_Id                
                                                 AND [length] = @_Length                
                                                 AND stype = @_S)                
                
                              IF ( @_Id <> 0 )                
        BEGIN                
         /*************************************************************************/                
                                    /***** From Godown Stock Check  *****/                
                                    INSERT INTO StockTrans_Dtl WITH(rowlock)                
                                                (transid,                
                                                 item_id,                
                                                 qty,                
                                                 stock_id,                
                                                 remark)                
                                    VALUES     (@RetVal,                
                                                @_Item_Id,                
                                                @_Qty,                
                                                @_Id,                
                                                @_Remark + ' BULK' )      
												

                                    Declare @_V as Int = Scope_identity() 
									
                                    /***** From Godown Stock Minus  *****/                
                                    UPDATE StockView WITH (rowlock)                
                                    SET    pending_qty = Isnull (pending_qty, 0) - @_Qty ,                
                                           transfer_qty = Isnull(transfer_qty, 0 ) + @_Qty ,            
										   LastUpdate = dbo.Get_Sysdate()  ,        
										   prodept_qty = ( CASE WHEN @Is_ProDept = 1 THEN Isnull(prodept_qty, 0) + @_Qty ELSE prodept_qty END )  ,      
										   StockEntryPage = 'STK TRANS'      ,    
										   StockEntryQty = @_Qty   ,
										   Dtl_Id = @_V ,
										   Tbl_Name ='StockTrans_Dtl'
                                    WHERE  id = @_Id -- Item_Id = @_Item_Id and Godown_Id = @FrGodown_Id and [Length] = @_Length and SType = @_S                        
                
				IF ( @Is_ProDept = 0 )            
                    BEGIN            
                             /***** From Godown Stock Minus  *****/                
                                    IF EXISTS (SELECT 1 FROM   stockview WITH (nolock) WHERE  item_id = @_Item_Id                
                                                      AND godown_id = @ToGodown_Id                
                                                      AND [length] = @_Length                
                                                      AND stype = @_S)                
                                      BEGIN                
                                          UPDATE stockview WITH (rowlock)                
                                          SET    total_qty = Isnull (total_qty, 0) + @_Qty,                
                                                 pending_qty = Isnull ( pending_qty , 0) + @_Qty  ,             
												 LastUpdate = dbo.Get_Sysdate() ,               
												 StockEntryPage = 'STK TRANS'  ,              
												 StockEntryQty = @_Qty,
												 Dtl_Id = @_V ,
												 Tbl_Name ='StockTrans_Dtl'
                                          WHERE  item_id = @_Item_Id                
                                                 AND godown_id = @ToGodown_Id                
                                                 AND [length] = @_Length               
												 AND stype = @_S                
                                      END                
                                    ELSE                
                                      BEGIN                
                                          INSERT INTO [dbo].[stockview]   WITH (rowlock)               
                                                      ([godown_id],                
                                                       [item_id],                
                                                       [stype],                
                                                       [total_qty],                
                                                       [sales_qty],                
                                                       [pending_qty],                
                                                       [length] ,             
													   LastUpdate ,  
													   StockEntryPage,    
													   StockEntryQty,
													   Dtl_Id ,
													   Tbl_Name)                
											VALUES      (@ToGodown_Id,                
                                                       @_Item_Id,                
                                                       @_S,                
                                                       @_Qty,                
                                                       0,                
                                                       @_Qty,                
                                                       @_Length ,              
													   dbo.Get_Sysdate(),      
													   'STK TRANS',    
													   @_Qty ,
													   @_V ,
													   'StockTrans_Dtl')                
                      END                
                                      
					END            
			END                
                    END                
               END                
                
            FETCH next FROM db_cursor INTO @_Description, @_Qty, @_Length, @_Remark, @_SType                
        END                
                
      CLOSE db_cursor                
      DEALLOCATE db_cursor                
                
      COMMIT                
 end                 
  /************************************* COMMIT *************************************/                
    END TRY                                                  
   BEGIN CATCH                 
      ROLLBACK                
      /************************************* ROLLBACK *************************************/                
                
      SET @RetVal = -405                
      -- 0 IS FOR ERROR                                                            
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'                
  END CATCH 
GO


