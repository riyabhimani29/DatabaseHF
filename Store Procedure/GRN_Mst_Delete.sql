USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_Delete]    Script Date: 13-05-2026 11:12:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[GRN_Mst_Delete]
(
      @GRN_Id        INT,
      @Upd_User      INT,

      @RetVal        INT = 0 OUT,
      @RetMsg        VARCHAR(MAX) = '' OUT
)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;


        IF NOT EXISTS
        (
            SELECT 1
            FROM GRN_Mst WITH (NOLOCK)
            WHERE GRN_Id = @GRN_Id
        )
        BEGIN
            SET @RetVal = -1;
            SET @RetMsg = 'GRN Not Found.';
            ROLLBACK TRANSACTION;
            RETURN;
        END


        DECLARE
            @_GrnDtl_Id            INT,
            @_Req_Id               INT,
            @_PODtl_Id             INT,
            @_Item_Id              INT,
            @_ReceiveQty           NUMERIC(18,3),
            @_Length               NUMERIC(18,3),
            @_Width                NUMERIC(18,3),
            @_Rack_Id              INT,
            @_SType                VARCHAR(10),
            @_Godown_Id            INT,
            @_Stock_Id             INT;

        SELECT @_Godown_Id = Godown_Id
        FROM GRN_Mst WITH (NOLOCK)
        WHERE GRN_Id = @GRN_Id;



        DECLARE db_cursor CURSOR FOR

        SELECT
              GD.GrnDtl_Id,
              GD.Req_Id,
              GD.PODtl_Id,
              GD.Item_Id,
              GD.ReceiveQty,
              GD.Length,
              GD.Width,
              GD.Rack_Id,
              GD.SType,
              GD.Stock_Id
        FROM GRN_Dtl GD WITH (NOLOCK)
        WHERE GD.GRN_Id = @GRN_Id;

        OPEN db_cursor;

        FETCH NEXT FROM db_cursor INTO
            @_GrnDtl_Id,
            @_Req_Id,
            @_PODtl_Id,
            @_Item_Id,
            @_ReceiveQty,
            @_Length,
            @_Width,
            @_Rack_Id,
            @_SType,
            @_Stock_Id;

        WHILE @@FETCH_STATUS = 0
        BEGIN

            /* REVERT PO PENDING QTY */

            IF (@_PODtl_Id > 0)
            BEGIN
                UPDATE PO_DTL WITH (ROWLOCK)
                SET PendingQty = ISNULL(PendingQty,0) + @_ReceiveQty
                WHERE PODtl_Id = @_PODtl_Id;
            END


            /* REVERT PR_DTL */

            IF (@_PODtl_Id > 0 AND @_Req_Id > 0)
            BEGIN
                UPDATE D
                SET D.Is_Read = 5
                FROM PO_DTL PO
                INNER JOIN PR_DTL D
                    ON D.PrDtl_Id = PO.Req_Id
                WHERE PO.PODtl_Id = @_PODtl_Id;
            END

            /* REVERT BOM_PO_RequestDtl */

            IF (@_PODtl_Id > 0 AND @_Req_Id > 0)
            BEGIN
                UPDATE R
                SET R.IS_PO = 5
                FROM PO_DTL PO
                INNER JOIN PR_DTL D
                    ON D.PrDtl_Id = PO.Req_Id
                INNER JOIN BOM_PO_RequestDtl R
                    ON R.BOM_PO_ReqDtl_Id = D.Req_Id
                WHERE PO.PODtl_Id = @_PODtl_Id;
            END

            /* REVERT STOCKVIEW */

            IF EXISTS
            (
                SELECT 1
                FROM StockView WITH (NOLOCK)
                WHERE Id = @_Stock_Id
            )
            BEGIN

                UPDATE StockView WITH (ROWLOCK)
                SET
                    Total_Qty   = ISNULL(Total_Qty,0) - @_ReceiveQty,
                    Pending_Qty = ISNULL(Pending_Qty,0) - @_ReceiveQty,
                    LastUpdate  = dbo.Get_sysdate(),
                    StockEntryPage = 'GRN-DELETE',
                    StockEntryQty = @_ReceiveQty,
                    Dtl_Id = @_GrnDtl_Id,
                    Tbl_Name = 'GRN_Dtl_Delete'
                WHERE Id = @_Stock_Id;



                DELETE FROM StockView
                WHERE Id = @_Stock_Id
                  AND ISNULL(Total_Qty,0) <= 0
                  AND ISNULL(Pending_Qty,0) <= 0;
            END


            FETCH NEXT FROM db_cursor INTO
                @_GrnDtl_Id,
                @_Req_Id,
                @_PODtl_Id,
                @_Item_Id,
                @_ReceiveQty,
                @_Length,
                @_Width,
                @_Rack_Id,
                @_SType,
                @_Stock_Id;

        END

        CLOSE db_cursor;
        DEALLOCATE db_cursor;



        DELETE FROM GRN_Dtl
        WHERE GRN_Id = @GRN_Id;



        DELETE FROM GRN_Mst
        WHERE GRN_Id = @GRN_Id;



        COMMIT TRANSACTION;

        SET @RetVal = 1;
        SET @RetMsg = 'GRN Deleted Successfully.';

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @RetVal = -500;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();

    END CATCH

END
GO


