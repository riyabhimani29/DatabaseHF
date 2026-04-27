USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[internalStocktrans_mst_insert]    Script Date: 27-04-2026 11:50:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[internalStocktrans_mst_insert]    
    @Trans_Type           VARCHAR(500),  
    @FrGodown_Id          INT,  
    @ToGodown_Id          INT,  
    @TransDate            DATETIME,  
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
    @DtlPara              TBL_STKTRANS_NEWS READONLY,  
    @RetVal               INT = 0 OUTPUT,  
    @RetMsg               VARCHAR(MAX) = '' OUTPUT  
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert Master Record
        INSERT INTO StockTrans_Mst WITH(ROWLOCK)
            (FrGodown_Id, TransDate, ToGodown_Id, IssueBy, ReceiveBy, ProjectDocument,
             ProductionDepartment, Remark, MAC_Add, Entry_User, Entry_Date,
             Year_Id, Branch_Id, Is_ProDept, Trans_Type)
        VALUES
            (@FrGodown_Id, @TransDate, @ToGodown_Id, @IssueBy, @ReceiveBy, @ProjectDocument,
             @ProductionDepartment, @Remark, @MAC_Add, @Entry_User, dbo.Get_SysDate(),
             @Year_Id, @Branch_ID, @Is_ProDept, @Trans_Type);

        SET @RetVal = SCOPE_IDENTITY();
        SET @RetMsg = 'Stock Transfer Successfully.';

        -- Cursor variables
        DECLARE @_Item_Id INT,@_Item_Code VARCHAR(500), @_Qty NUMERIC(18,3), @_Id INT,
                @_Length NUMERIC(18,3), @_Width NUMERIC(18,3),
                @_SplitLength NUMERIC(18,3), @_IsSplit BIT,
                @_Remark VARCHAR(500), @_SType VARCHAR(500),
                @_Rack_Id INT, @_FrRack_Id INT, @_ToRack_Id INT,
                @_FrGodown_Id2 INT, @_ToGodown_Id2 INT;

      DECLARE db_cursor CURSOR FOR
SELECT 
    MI.Item_Id, D.Item_Code, D.Qty,D.Id,D.[Length],D.Width, D.Remark, D.SType, D.SplitLength, D.IsSplit, D.Rack_Id, D.FrRack_Id, D.ToRack_Id, D.FrGodown_Id, D.ToGodown_Id
FROM @DtlPara D
JOIN M_Item MI ON MI.Item_Code = D.Item_Code;
        OPEN db_cursor;

       FETCH NEXT FROM db_cursor INTO @_Item_Id, @_Item_Code, @_Qty, @_Id, @_Length, @_Width, @_Remark, @_SType, @_SplitLength, @_IsSplit, @_Rack_Id, @_FrRack_Id, @_ToRack_Id, @_FrGodown_Id2, @_ToGodown_Id2;  
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Check for freeze stock
            IF EXISTS (SELECT 1 FROM StockView WHERE Id = @_Id AND (Pending_Qty - Freeze_Qty) < @_Qty)
            BEGIN
                DECLARE @Freeze_Qty NUMERIC(18,3) = (SELECT Freeze_Qty FROM StockView WHERE Id = @_Id);
                DECLARE @Pending_Qty NUMERIC(18,3) = (SELECT Pending_Qty FROM StockView WHERE Id = @_Id);

                SET @RetMsg = 'Stock is available but on freeze mode. Freeze Qty: ' + CAST(@Freeze_Qty AS VARCHAR(20)) +
                              ' and available Qty: ' + CAST(@Pending_Qty AS VARCHAR(20)) + '.';
                SET @RetVal = -405;

                CLOSE db_cursor;
                DEALLOCATE db_cursor;

                ROLLBACK TRANSACTION;
                RETURN;
            END

            -- Insert Detail Record
            INSERT INTO StockTrans_Dtl WITH(ROWLOCK)
                (TransId, Item_Id, Qty, Stock_Id, Remark, IsSplit, SplitLength,
                 Rack_Id, FrRack_Id, ToRack_Id, Fr_Godown_Id, To_Godown_Id)
            VALUES
                (@RetVal, @_Item_Id, @_Qty, @_Id, @_Remark, @_IsSplit, @_SplitLength,
                 @_Rack_Id, @_FrRack_Id, @_ToRack_Id, @_FrGodown_Id2, @_ToGodown_Id2);

            DECLARE @_V INT = SCOPE_IDENTITY();
            DECLARE @_S CHAR(1) = CASE WHEN @_SType = 'Non-Coated' THEN 'N' ELSE 'C' END;

            DECLARE @NewStockId INT;
            Declare @_History_Id INT = NULL;
            -- H_To_T Transaction Handling
            IF @Trans_Type = 'T_To_H'
            BEGIN
                SET @NewStockId = NULL;

                SELECT @NewStockId = Id
                FROM StockView WITH (UPDLOCK, HOLDLOCK)
                WHERE Item_Id = @_Item_Id
                  AND Godown_Id = @_ToGodown_Id2
                  AND [Length] = @_Length
                  AND Width = @_Width
                  AND Rack_Id = @_ToRack_Id
                  AND SType = @_S;

                IF @NewStockId IS NOT NULL
                BEGIN

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
                            StockTrans_Dtl_Id
                        )
                        VALUES
                        (
                            @_ToGodown_Id2,
                            @_Item_Id,
                            @_S,
                            @_Qty,
                            @_Length,       
                            @_Width,
                            @_ToRack_Id,
                            dbo.Get_sysdate(),
                            'Internal Stock T_TO_H',
                            'Internal-STK-TRANS',
                            'StockTrans_Dtl',
                            'IN',
                            0,
                            @NewStockId,               
                            @_V
                        );

                    UPDATE StockView
                    SET total_qty = ISNULL(total_qty,0) + @_Qty,
                        pending_qty = ISNULL(pending_qty,0) + @_Qty,
                        lastupdate = dbo.Get_SysDate(),
                        stockentrypage = 'Internal-STK-TRANS',
                        stockentryqty = @_Qty,
                        dtl_id = @_V,
                        tbl_name = 'StockTrans_Dtl'
                    WHERE Id = @NewStockId;
                END
                ELSE
                BEGIN
                    INSERT INTO StockView
                    (
                        Godown_Id, Item_Id, SType,
                        total_qty, sales_qty, pending_qty,
                        [Length], Width, Rack_Id,
                        lastupdate, stockentrypage,
                        stockentryqty, dtl_id, tbl_name
                    )
                    VALUES
                    (
                        @_ToGodown_Id2, @_Item_Id, @_S,
                        @_Qty, 0, @_Qty,
                        @_Length, @_Width, @_ToRack_Id,
                        dbo.Get_SysDate(), 'STK-TRANS',
                        @_Qty, @_V, 'StockTrans_Dtl'
                    );

                    SET @NewStockId = SCOPE_IDENTITY();

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
                            StockTrans_Dtl_Id
                        )
                        VALUES
                        (
                            @_ToGodown_Id2,
                            @_Item_Id,
                            @_S,
                            @_Qty,
                            @_Length,       
                            @_Width,
                            @_ToRack_Id,
                            dbo.Get_sysdate(),
                            'Internal Stock T_TO_H',
                            'Internal-STK-TRANS',
                            'StockTrans_Dtl',
                            'IN',
                            0,
                            @NewStockId,               
                            @_V
                        );

                END

                UPDATE StockTrans_Dtl
                SET newstock_id = @NewStockId
                WHERE dtl_id = @_V;
                 --update Stock_Transfer_History SET Stock_Id = @NewStockId WHERE ID = @_History_Id;
            END
             IF @Trans_Type = 'H_To_T'
            BEGIN
                SET @NewStockId = NULL; 

                SELECT @NewStockId = Id
                FROM StockView WITH (UPDLOCK, HOLDLOCK)
                WHERE Item_Id = @_Item_Id
                  AND Godown_Id = @_FrGodown_Id2
                  AND [Length] = @_Length
                  AND Width = @_Width
                  AND Rack_Id = @_FrRack_Id
                  AND SType = @_S;

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
                        StockTrans_Dtl_Id
                    )
                    VALUES
                    (
                        @_FrGodown_Id2,
                        @_Item_Id,
                        @_S,
                        @_Qty,
                        @_Length,       
                        @_Width,
                        @_FrRack_Id,
                        dbo.Get_sysdate(),
                        'Internal Stock H_To_T',
                        'Internal-STK-TRANS',
                        'StockTrans_Dtl',
                        'OUT',
                        1,
                        @NewStockId,               
                        @_V
                    );


                UPDATE StockView
                SET pending_qty = ISNULL(pending_qty,0) - @_Qty,
                    transfer_qty = ISNULL(transfer_qty,0) + @_Qty,
                    lastupdate = dbo.Get_SysDate(),
                    stockentrypage = 'Internal-STK-TRANS',
                    stockentryqty = @_Qty,
                    dtl_id = @_V,
                    tbl_name = 'StockTrans_Dtl'
                WHERE Id = @NewStockId;

                UPDATE StockTrans_Dtl
                SET newstock_id = @NewStockId
                WHERE dtl_id = @_V;
            END

            FETCH NEXT FROM db_cursor INTO
                @_Item_Id, @_Item_Code, @_Qty, @_Id, @_Length, @_Width,
                @_Remark, @_SType, @_SplitLength, @_IsSplit,
                @_Rack_Id, @_FrRack_Id, @_ToRack_Id,
                @_FrGodown_Id2, @_ToGodown_Id2;
        END

        CLOSE db_cursor;
        DEALLOCATE db_cursor;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
    END CATCH
END
GO


