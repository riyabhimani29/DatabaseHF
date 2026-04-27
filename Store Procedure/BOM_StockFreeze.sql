USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_StockFreeze]    Script Date: 27-04-2026 11:01:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_StockFreeze]
    @MR_Items_Id INT,
    @Qty DECIMAL(18,3),
    @Stock_Id INT,
    @Entry_User INT,      
    @Upd_User INT,      
    @RetVal INT = 0 OUTPUT,      
    @RetMsg VARCHAR(MAX) = '' OUTPUT  
AS      
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsFreeze BIT;
    DECLARE @Pending_Qty DECIMAL(18, 3);
    DECLARE @Freeze_Qty DECIMAL(18, 3);
    DECLARE @Release_Qty DECIMAL(18, 3);
    DECLARE @Process_Type VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @Action_Details NVARCHAR(1000);
    DECLARE @Project_Id INT;
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Code VARCHAR(50);
    DECLARE @Item_Id INT;
    DECLARE @Item_Name VARCHAR(550);

    BEGIN TRY
        -- Input validation
        IF @MR_Items_Id IS NULL OR @Stock_Id IS NULL OR @Qty IS NULL OR @Qty <= 0
        BEGIN
            SET @RetVal = -400;
            SET @RetMsg = 'Invalid input: MR_Items_Id, Stock_Id, or Qty cannot be NULL or less than or equal to zero.';
            RETURN;
        END

        -- Get MR_Items details, Project_Id, and Item_Id
        SELECT 
            @IsFreeze = MRI.IsFreeze, 
            @Release_Qty = MRI.Release_Qty,
            @Project_Id = MR.Project_Id,
            @Department_Code = D.Dept_Name,
            @Item_Id = MRI.Item_Id
        FROM MR_Items MRI
        INNER JOIN MaterialRequirement MR ON MRI.MR_Id = MR.MR_Id
        INNER JOIN M_Department D ON MR.Dept_ID = D.Dept_Id
        WHERE MRI.MR_Items_Id = @MR_Items_Id;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @RetVal = -401;
            SET @RetMsg = 'MR_Items record or related Project not found for ID: ' + CAST(@MR_Items_Id AS VARCHAR);
            RETURN;
        END

        -- Get Project_Code
        SELECT @Project_Code = Project_Name 
        FROM M_Project
        WHERE Project_Id = @Project_Id;

        -- Get Item_Name (if Items table exists, else use Item_Id)
        SELECT @Item_Name = ISNULL(Item_Name, 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10)))
        FROM M_Item
        WHERE Item_Id = @Item_Id;

        IF @Item_Name IS NULL
        BEGIN
            SET @Item_Name = 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10));
        END

        -- Validate Qty against Release_Qty when freezing
        IF @IsFreeze = 0 AND @Qty > @Release_Qty
        BEGIN
            SET @RetVal = -404;
            SET @RetMsg = 'Requested freeze quantity exceeds Release_Qty. Requested Qty: ' + 
                          CAST(@Qty AS VARCHAR) + 
                          ', Release_Qty: ' + 
                          CAST(@Release_Qty AS VARCHAR) + '.';
            RETURN;
        END

        -- Get StockView details
        SELECT @Pending_Qty = Pending_Qty, @Freeze_Qty = Freeze_Qty
        FROM StockView
        WHERE Id = @Stock_Id;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @RetVal = -402;
            SET @RetMsg = 'StockView record not found for ID: ' + CAST(@Stock_Id AS VARCHAR);
            RETURN;
        END

        -- Check if Qty > (Pending_Qty - Freeze_Qty) when freezing
        IF @IsFreeze = 0 AND @Qty > (@Pending_Qty - @Freeze_Qty)
        BEGIN
            SET @RetVal = -403;
            SET @RetMsg = 'Insufficient stock to freeze. Requested Qty: ' + 
                          CAST(@Qty AS VARCHAR) + 
                          ', Available (Pending - Freeze): ' + 
                          CAST((@Pending_Qty - @Freeze_Qty) AS VARCHAR) + '.';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Update StockView based on IsFreeze state
        UPDATE sv 
        SET 
            Freeze_Qty = CASE 
                             WHEN @IsFreeze = 1 THEN Freeze_Qty - @Qty 
                             ELSE Freeze_Qty + @Qty 
                         END,
            LastUpdate = dbo.Get_sysdate()
        FROM StockView sv
        WHERE sv.Id = @Stock_Id;

        -- Toggle IsFreeze in MR_Items
        -- Toggle IsFreeze in MR_Items  
UPDATE MR_Items 
SET 
    IsFreeze = CASE WHEN @IsFreeze = 1 THEN 0 ELSE 1 END,
    Freeze_Qty = CASE 
                    WHEN @IsFreeze = 1 THEN ISNULL(Freeze_Qty,0) - @Qty   -- Unfreeze
                    ELSE ISNULL(Freeze_Qty,0) + @Qty                      -- Freeze
                 END
WHERE MR_Items_Id = @MR_Items_Id;

        -- Log Freeze/Unfreeze with Item Details
        SET @Process_Type = 'Stock_Freeze';
        SET @Status = CASE WHEN @IsFreeze = 1 THEN 'Unfrozen' ELSE 'Frozen' END;
        SET @Action_Details = 'This is ' + LOWER(@Status) + ' for stock with ' + 
                              CAST(@Qty AS NVARCHAR(10)) + ' items (' + @Item_Name + ').';

        INSERT INTO BOM_Logs (
            Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
            Department_Code, Entry_User, Entry_Date
        )
        VALUES (
            @Process_Type, @Project_Id, @Qty, @Status, @Action_Details,
            @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
        );

        COMMIT TRANSACTION;

        SET @RetVal = 1;
        SET @RetMsg = 'Item freeze state updated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred: ' + ERROR_MESSAGE() + 
                      ' (Line: ' + CAST(ERROR_LINE() AS VARCHAR) + ').';
    END CATCH
END
GO


