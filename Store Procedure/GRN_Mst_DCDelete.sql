USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_DCDelete]    Script Date: 13-05-2026 11:13:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   PROCEDURE [dbo].[GRN_Mst_DCDelete]
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
            FROM GRN_Mst WITH(NOLOCK)
            WHERE GRN_Id = @GRN_Id
        )
        BEGIN
            SET @RetVal = -1;
            SET @RetMsg = 'Invalid GRN Id.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE
            @Godown_Id INT,
            @DC_Id INT;

        SELECT
            @Godown_Id = Godown_Id,
            @DC_Id = PO_Id
        FROM GRN_Mst WITH(NOLOCK)
        WHERE GRN_Id = @GRN_Id;

 

        DECLARE
            @_GRNDtl_Id       INT,
            @_PODtl_Id        INT,
            @_Item_Id         INT,
            @_ReceiveQty      NUMERIC(18,3),
            @_Length          NUMERIC(18,3),
            @_Width           NUMERIC(18,3),
            @_Rack_Id         INT,
            @_SType           VARCHAR(10),
            @_Stock_Id        INT;

        DECLARE db_cursor CURSOR FOR

        SELECT
            GRNDTL_ID,
            PODTL_ID,
            ITEM_ID,
            RECEIVEQTY,
            LENGTH,
            WIDTH,
            RACK_ID,
            STYPE,
            STOCK_ID
        FROM GRN_Dtl
        WHERE GRN_ID = @GRN_Id;

        OPEN db_cursor;

        FETCH NEXT FROM db_cursor
        INTO
            @_GRNDtl_Id,
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



            IF(ISNULL(@_PODtl_Id,0) > 0)
            BEGIN

                UPDATE DC_Dtl
                SET Pending_Qty = ISNULL(Pending_Qty,0) + @_ReceiveQty
                WHERE DCDtl_Id = @_PODtl_Id;

            END



            IF EXISTS
            (
                SELECT 1
                FROM StockView
                WHERE Id = @_Stock_Id
            )
            BEGIN

                UPDATE StockView
                SET
                    Total_Qty   = ISNULL(Total_Qty,0) - @_ReceiveQty,
                    Pending_Qty = ISNULL(Pending_Qty,0) - @_ReceiveQty,
                    LastUpdate  = dbo.Get_sysdate(),
                    StockEntryPage = 'DC-GRN-REVERT',
                    StockEntryQty = @_ReceiveQty,
                    Dtl_Id = @_GRNDtl_Id,
                    Tbl_Name = 'GRN_Dtl_Revert'
                WHERE Id = @_Stock_Id;

                /* DELETE EMPTY STOCK */
                DELETE FROM StockView
                WHERE Id = @_Stock_Id
                  AND ISNULL(Total_Qty,0) <= 0
                  AND ISNULL(Pending_Qty,0) <= 0;

            END

            IF EXISTS(
                SELECT 1 FROM DC_Dtl
                WHERE DCDtl_Id = @_PODtl_Id AND MR_Item_Id > 0
            )
            BEGIN
                UPDATE MRI
                SET
                    Issue_Qty = ISNULL(Issue_Qty,0) - @_ReceiveQty
                FROM DC_Dtl DD 
                INNER JOIN MR_Items MRI ON DD.MR_Item_Id = MRI.MR_Items_Id
                WHERE DD.DCDtl_Id = @_PODtl_Id;

                
            END

            

            FETCH NEXT FROM db_cursor
            INTO
                @_GRNDtl_Id,
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



        UPDATE CR
        SET CR.Is_Read = 2
        FROM DC_Mst DM
        INNER JOIN Coating_Request CR
            ON CR.Coating_Req_Id = DM.Coating_Req_Id
        WHERE DM.DC_Id = @DC_Id;

        UPDATE MI
        SET MI.Cmp_Job_Work = 1
        FROM MR_Items MI
        INNER JOIN Coating_RequestDtl CRD
            ON CRD.BOM_Dtl_Id = MI.MR_Items_Id
        INNER JOIN DC_Mst DM
            ON DM.Coating_Req_Id = CRD.Coating_Req_Id
        WHERE DM.DC_Id = @DC_Id;

        
        DELETE FROM GRN_Dtl
        WHERE GRN_ID = @GRN_Id;

       

        DELETE FROM GRN_Mst
        WHERE GRN_ID = @GRN_Id;

        COMMIT TRANSACTION;

        SET @RetVal = 1;
        SET @RetMsg = 'DC GRN reverted successfully.';

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @RetVal = -500;
        SET @RetMsg = ERROR_MESSAGE();

    END CATCH

END
GO


