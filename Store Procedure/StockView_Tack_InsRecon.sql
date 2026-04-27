USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[StockView_Tack_InsRecon]    Script Date: 27-04-2026 15:05:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StockView_Tack_InsRecon]
					  @DtlPara TBL_STCOKRECONCILIATION readonly,
					  @Remark     VARCHAR(500),
					  @MAC_Add    VARCHAR(500),
					  @Entry_User INT,
					  @Upd_User   INT,
					  @Year_Id    INT,
					  @Branch_ID  INT,
					  @RetVal     INT = 0 out,
					  @RetMsg     VARCHAR(max) = '' out
AS
  SET nocount ON
  BEGIN try
    BEGIN TRANSACTION
    /************************************* TRANSACTION *************************************/
    IF @@ERROR <> 0
    BEGIN
      SET @RetVal = -404 -- 0 IS FOR ERROR
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
    END
    ELSE -- Tbl_StcokReconciliation
    BEGIN
      DECLARE @_StockId AS INT= 0,
        @_Item_Id AS       INT= 0,
        @_Rack_Id AS       INT= 0,
        @_Minus AS         NUMERIC(18, 3) = 0,
        @_Plus AS          NUMERIC(18, 3) = 0

      DECLARE db_cursor CURSOR FOR

      SELECT id,
             item_id,
             rack_id,
			 minus ,
             plus
      FROM  @DtlPara;
      
      OPEN db_cursor
      FETCH next
      FROM  db_cursor
      INTO  @_StockId, @_Item_Id, @_Rack_Id, @_Minus, @_Plus

      WHILE @@FETCH_STATUS = 0
      BEGIN
        IF (@_Plus > 0)
        BEGIN
          UPDATE stockview WITH (rowlock)
          SET    total_qty = Isnull(total_qty, 0)     + @_Plus,
                 pending_qty = Isnull(pending_qty, 0) + @_Plus ,
                 adjust_qty = Isnull(adjust_qty, 0)   + @_Plus ,
                 lastupdate = dbo.Get_sysdate() ,
                 stockentryqty = @_Plus ,
                 stockentrypage ='Reconciliation +' ,
                 rackno='MANAGE' ,
                 dtl_id = 0 ,
                 tbl_name =''
          WHERE  id = @_StockId
        END
        IF (@_Minus > 0)
        BEGIN
          UPDATE stockview WITH (rowlock)
          SET --Total_Qty = Isnull(total_qty, 0) + @_Plus,
                 pending_qty = Isnull(pending_qty, 0) - @_Minus ,
                 adjust_qty = Isnull(adjust_qty, 0)   + @_Minus ,
                 lastupdate = dbo.Get_sysdate() ,
                 stockentryqty = @_Minus ,
                 stockentrypage ='Reconciliation -' ,
                 rackno='MANAGE' ,
                 dtl_id = 0 ,
                 tbl_name =''
          WHERE  id = @_StockId
        END
        FETCH next
        FROM  db_cursor
        INTO  @_StockId, @_Item_Id, @_Rack_Id, @_Minus, @_Plus
      END
      CLOSE db_cursor
      DEALLOCATE db_cursor
      SET @RetMsg ='Stock Reconciliation Successfully.'
      SET @RetVal = 1
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


