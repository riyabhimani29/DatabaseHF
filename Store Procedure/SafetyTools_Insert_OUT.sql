USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[SafetyTools_Insert_OUT]    Script Date: 27-04-2026 14:38:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SafetyTools_Insert_OUT] 
    @Year_Id INT,
    @Entry_User INT,                       
    @DtlPara TBL_SafetyToolsDtl READONLY,                          
    @RetVal INT = 0 OUT,                          
    @RetMsg VARCHAR(MAX) = '' OUT                          
AS                          
BEGIN
    SET NOCOUNT ON;

    SET @Year_Id = dbo.Get_Financial_YearId(dbo.Get_sysdate());

    DECLARE @_Financial_Year INT = dbo.Get_Financial_Year(dbo.Get_sysdate());

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @_DeptShortNm VARCHAR(20) = 'OUT',
                @_Invoice_No INT = 0,
                @OUT_No VARCHAR(50);

        SELECT @_Invoice_No = ISNULL(MAX(Invoice_No), 0) + 1
        FROM safetytools_outward
        WHERE Year_Id = @Year_Id;

        SET @OUT_No = 'HF/' + @_DeptShortNm + '/'
                    + FORMAT(@_Invoice_No, '0000')
                    + '/' + CAST(@_Financial_Year AS VARCHAR);

        INSERT INTO safetytools_outward
        (
            entry_date,
            entry_user,
            Invoice_No,
            Year_Id,
            Outward_No
        )
        VALUES
        (
            dbo.Get_sysdate(),
            @Entry_User,
            @_Invoice_No,
            @Year_Id,
            @OUT_No
        );

        SET @RetVal = SCOPE_IDENTITY();

        DECLARE 
            @_Item_Id INT,
            @_Stock_Id INT,
            @_Item_Code VARCHAR(100),
            @_Item_Name VARCHAR(500),
            @_Rack_Name VARCHAR(500),
            @_Unit_Name VARCHAR(100),
            @_OutwardQty NUMERIC(18,3),
            @_Project_Id INT,
            @_GRN_date DATETIME,
            @_IsProject INT,
            @_IssueTo VARCHAR(500),
            @_Remark VARCHAR(500);

        DECLARE db_cursor CURSOR FOR
        SELECT ItemId, Stock_Id, Item_Code, Item_Name, Rack_Name, Unit_Name, OutwardQty,Project_Id,GRN_date,IsProject,IssueTo,Remark
        FROM @DtlPara;

        OPEN db_cursor;

        FETCH NEXT FROM db_cursor INTO 
            @_Item_Id, @_Stock_Id, @_Item_Code, @_Item_Name, @_Rack_Name, @_Unit_Name, @_OutwardQty,@_Project_Id,@_GRN_date,@_IsProject,@_IssueTo,@_Remark;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@_OutwardQty > 0)
            BEGIN
                DECLARE @_DtlIId INT;

                INSERT INTO safetytools_outward_Dtl
                (
                    StOutward_Id,
                    ItemId,
                    Stock_Id,
                    Item_Code,
                    Item_Name,
                    Rack_Name,
                    Unit_Name,
                    OutwardQty,
                    Project_Id,
                    Issue_date,
                    issue_type,
                    Issue_to,
                    Remark
                )
                VALUES
                (
                    @RetVal,
                    @_Item_Id,
                    @_Stock_Id,
                    @_Item_Code,
                    @_Item_Name,
                    @_Rack_Name,
                    @_Unit_Name,
                    @_OutwardQty,
                    @_Project_Id,
                    @_GRN_date,
                    @_IsProject,
                    @_IssueTo,
                    @_Remark
                );

                SET @_DtlIId = SCOPE_IDENTITY();


                -- UPDATE STOCK
                UPDATE stockview
                SET 
                    total_qty = ISNULL(total_qty, 0) - @_OutwardQty,
                    pending_qty = ISNULL(pending_qty, 0) - @_OutwardQty,
                    lastupdate = dbo.Get_sysdate(),
                    StockEntryPage = 'Safetytools-Outward',
                    StockEntryQty = @_OutwardQty,
                    Dtl_Id = @_DtlIId,
                    Tbl_Name = 'safetytools_outward_Dtl'
                WHERE Id = @_Stock_Id;

                /* ? STOCK TRANSFER HISTORY FROM stockview */
                INSERT INTO Stock_Transfer_History
                (
                    Godown_Id,
                    Item_Id,
                    SType,
                    Transfer_Qty,
                    Length,
                    Width,
                    Rack_Id,
                    Transfer_Date,
                    Remark,
                    StockEntryPage,
                    Tbl_Name,
                    Transfer_Type,
                    Transfer_TypeInBit,
                    GRN_Dtl_Id,
                    Stock_Id
                )
                SELECT
                    sv.Godown_Id,
                    @_Item_Id,
                    sv.SType, -- default
                    @_OutwardQty,
                    sv.Length,
                    sv.Width,
                    sv.Rack_Id,
                    dbo.Get_sysdate(),
                    'SafetyTools Outward',
                    'Safetytools-Outward',
                    'safetytools_outward_Dtl',
                    'OUT',
                    1,
                    @_DtlIId,
                    @_Stock_Id
                FROM stockview sv
                WHERE sv.Id = @_Stock_Id;
            END

            FETCH NEXT FROM db_cursor INTO 
                @_Item_Id, @_Stock_Id, @_Item_Code, @_Item_Name, @_Rack_Name, @_Unit_Name, @_OutwardQty,@_Project_Id,@_GRN_date,@_IsProject,@_IssueTo,@_Remark;
        END

        CLOSE db_cursor;
        DEALLOCATE db_cursor;

        SET @RetMsg = 'Outward Generated Successfully. No: ' + @OUT_No;

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        SET @RetVal = -1;
        SET @RetMsg = ERROR_MESSAGE();
    END CATCH
END
GO


