USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_MR_Issue]    Script Date: 27-04-2026 10:54:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[BOM_MR_Issue]  
    @MRItemIds TBL_MRItemID READONLY,
    @CloseStatus INT,
    @Entry_User INT,      
    @Upd_User INT,          
    @RetVal INT = 0 OUT,      
    @RetMsg VARCHAR(MAX) = '' OUT  
AS      
BEGIN
    SET NOCOUNT ON;

    DECLARE @Process_Type VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @Action_Details NVARCHAR(1000);
    DECLARE @TotalQty INT;
    DECLARE @Project_Id INT;
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Code VARCHAR(50);
    DECLARE @Dept_ID INT;
    DECLARE @MR_Items_Id INT;
    DECLARE @Qty INT;
    DECLARE @Item_Id INT;
    DECLARE @Item_Name VARCHAR(550);
    DECLARE @Length DECIMAL(18,3);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Calculate total quantity
        SELECT @TotalQty = SUM(Qty)
        FROM @MRItemIds;

        -- Get Project_Id, Department_Code, and Dept_ID
        SELECT TOP 1 
            @Project_Id = MR.Project_Id,
            @Department_Code = D.Dept_Name,
            @Dept_ID = MR.Department_Id
        FROM MR_Items MRI
        INNER JOIN @MRItemIds ids ON MRI.MR_Items_Id = ids.MRItemId
        INNER JOIN MaterialRequirement MR ON MRI.MR_Id = MR.MR_Id
        INNER JOIN M_Department D ON MR.Dept_ID = D.Dept_ID;

        IF @Project_Id IS NULL
        BEGIN
            SET @RetVal = -400;
            SET @RetMsg = 'Project not found for the provided MR item IDs.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Get Project_Code
        SELECT @Project_Code = Project_Name 
        FROM M_Project 
        WHERE Project_Id = @Project_Id;

        -- Update StockView

        Declare @_Stock_Id AS INT =0,
                @_Godown_Id AS INT = 0,
                @_Item_Id AS INT =0,
                @_SType AS VARCHAR(5) ='',
                @_Qty   AS NUMERIC(18, 3) = 0,
                @_Width  AS NUMERIC(18, 3) = 0 ,    
                @_Rack_Id AS INT =0      ,
                @_Length AS NUMERIC(18,3) =0,
                @_MR_Item_Id AS INT =0

        SELECT @_Godown_Id=SV.Godown_Id,@_Item_Id=SV.Item_Id,@_SType=SV.SType,
               @_Qty=SV.Pending_Qty,@_Width=SV.Width,@_Rack_Id=SV.Rack_Id,
               @_Length=SV.Length,@_MR_Item_Id=MRI.MR_Items_Id,@_Stock_Id=SV.Id
        FROM StockView SV
        INNER JOIN MR_Items MRI ON SV.Item_Id = MRI.Item_Id
        AND (SV.[Length] = MRI.[Length] OR (SV.[Length] IS NULL AND MRI.[Length] IS NULL))
        AND SV.Godown_Id = MRI.Godown_Id AND SV.Rack_Id = MRI.Godown_Rack_Id
        AND  SV.Id = MRI.Stock_Id

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
                MR_Item_Id
				
            )
            VALUES
            (
                @_Godown_Id,
                @_Item_Id,
                @_SType,
                @_Qty,
                @_Length,       
                @_Width,
                @_Rack_Id,
                dbo.Get_sysdate(),
                'MR-BOM',
                'BOM',
                'MR_Item',
                'OUT',
                1,
                @_Stock_Id,
                @_MR_Item_Id
            );

         UPDATE SV
        SET 
        pending_qty = pending_qty - ids.Qty,
        SV.Freeze_Qty = SV.freeze_qty - ids.Qty,
        lastupdate = dbo.Get_sysdate(),
        StockEntryPage = 'MR-Item-Issue',
        StockEntryQty = ids.Qty,
        Dtl_Id = MRI.MR_Items_Id,
        Tbl_Name = 'MR_Items',
        ProDept_Qty = CASE WHEN @CloseStatus <> 1 THEN ProDept_Qty ELSE ProDept_Qty + ids.Qty END
        FROM StockView SV
        INNER JOIN MR_Items MRI ON SV.Item_Id = MRI.Item_Id
        AND (SV.[Length] = MRI.[Length] OR (SV.[Length] IS NULL AND MRI.[Length] IS NULL))
        AND SV.Godown_Id = MRI.Godown_Id AND SV.Rack_Id = MRI.Godown_Rack_Id
        AND  SV.Id = MRI.Stock_Id
        left JOIN GRN_Dtl GD
        ON MRI.SupDetail_Id = GD.SupDetail_Id
        AND GD.GRN_Id = SV.GRN_Id
        INNER JOIN @MRItemIds ids ON MRI.MR_Items_Id = ids.MRItemId
        WHERE MRI.IsFreeze = 1;


        IF @@ROWCOUNT = 0
        BEGIN
            SET @RetVal = -401;
            SET @RetMsg = 'No frozen MR items found to issue.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Update MR_Items
        UPDATE MRI
        SET 
            Issue_Qty = ISNULL(Issue_Qty, 0) + ids.Qty,
            MRI.IsFreeze = 0,
            MRI.Freeze_Qty = MRI.Freeze_Qty - ids.Qty,
            MRI.Release_Qty = MRI.Release_Qty - ids.Qty
        FROM MR_Items MRI
        INNER JOIN @MRItemIds ids ON MRI.MR_Items_Id = ids.MRItemId
        WHERE MRI.IsFreeze = 1;

        -- Log Issuance for each item
        DECLARE item_cursor CURSOR FOR
        SELECT ids.MRItemId, ids.Qty, MRI.Item_Id, MRI.[Length]
        FROM @MRItemIds ids
        INNER JOIN MR_Items MRI ON ids.MRItemId = MRI.MR_Items_Id;

        OPEN item_cursor;
        FETCH NEXT FROM item_cursor INTO @MR_Items_Id, @Qty, @Item_Id, @Length;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Get Item_Name
            SELECT @Item_Name = ISNULL(Item_Name, 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10)))
            FROM M_Item
            WHERE Item_Id = @Item_Id;

            IF @Item_Name IS NULL
            BEGIN
                SET @Item_Name = 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10));
            END

            SET @Process_Type = 'Issue';
            SET @Status = 'Issued';
            SET @Action_Details = 'This is issued to ' + 
                                  CASE WHEN @CloseStatus = 1 THEN 'Production' ELSE 'Warehouse' END + 
                                  ' with ' + CAST(@Qty AS NVARCHAR(10)) + ' items (' + @Item_Name + ')' +
                                  CASE WHEN @Dept_ID = 1 THEN ', Length: ' + ISNULL(CAST(@Length AS NVARCHAR(20)), 'Unknown') ELSE '' END + '.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, @Qty, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
            );

            FETCH NEXT FROM item_cursor INTO @MR_Items_Id, @Qty, @Item_Id, @Length;
        END;

        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        SET @RetVal = 1;
        SET @RetMsg = 'MR Items issued successfully.';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @RetVal = -1;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH
END;
GO


