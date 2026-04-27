USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_MR_Qty_Update]    Script Date: 27-04-2026 10:55:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_MR_Qty_Update]
    @MR_Item_Id INT,
    @Qty DECIMAL(18,3),
    @Qty1 DECIMAL(18,3),
    @Entry_User INT,
    @Upd_User INT,
    @RetVal INT = 0 OUTPUT,
    @RetMsg VARCHAR(500) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Project_Id INT,
            @Project_Code VARCHAR(100),
            @Department_Code VARCHAR(100),
            @Item_Id INT,
            @Item_Name VARCHAR(500),
            @Length DECIMAL(18,3),
            @Dept_ID INT,
            @Action_Details NVARCHAR(1000),
            @Process_Type VARCHAR(50),
            @Status VARCHAR(50);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate existence
        IF NOT EXISTS (SELECT 1 FROM MR_Items WHERE MR_Items_Id = @MR_Item_Id)
        BEGIN
            SET @RetVal = -404;
            SET @RetMsg = 'MR Item not found.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update Release Qty

     
    IF EXISTS (SELECT 1 FROM MR_Items WHERE MR_Items_Id = @MR_Item_Id AND Release_Qty = 0)
BEGIN
    -- If Release_Qty = 0, update Release_Qty
  UPDATE MR_Items
SET 
    Qty         = CASE WHEN @Qty = 0 THEN Qty + @Qty1 ELSE Qty END,
    Release_Qty = CASE WHEN @Qty <> 0 THEN Release_Qty + @Qty ELSE Release_Qty END
WHERE MR_Items_Id = @MR_Item_Id;

END
ELSE
BEGIN
    -- Otherwise, update Qty
    UPDATE MR_Items
    SET Qty = Qty + @Qty1
    WHERE MR_Items_Id = @MR_Item_Id;
END


      -- Assign values to variables (corrected)
SELECT TOP 1
    @Item_Id = MI.Item_Id,
    @Length = MI.Length,
    @Project_Id = MR.Project_Id,
    @Dept_ID = MR.Department_Id,
    @Item_Name = I.Item_Name,
    @Project_Code = P.Project_Name,
    @Department_Code = D.Dept_Name
FROM MR_Items MI
INNER JOIN MaterialRequirement MR ON MI.MR_Id = MR.MR_Id
LEFT JOIN M_Item I ON MI.Item_Id = I.Item_Id
LEFT JOIN M_Project P ON MR.Project_Id = P.Project_Id
LEFT JOIN M_Department D ON MR.Dept_ID = D.Dept_ID
WHERE MI.MR_Items_Id = @MR_Item_Id;


        -- Fallback for Item Name
        IF @Item_Name IS NULL
            SET @Item_Name = 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10));

        -- Prepare log info
        SET @Process_Type = 'Release Qty Update';
        SET @Status = 'Released';
        SET @Action_Details = 'Released Qty updated by user. Qty: ' + CAST(@Qty AS NVARCHAR(10)) +
                              ', Item: ' + @Item_Name +
                              CASE WHEN @Dept_ID = 1 THEN ', Length: ' + ISNULL(CAST(@Length AS NVARCHAR(20)), 'Unknown') ELSE '' END;

        -- Insert into log
        INSERT INTO BOM_Logs (
            Process_Type, Project_Id, Quantity, Status, Action_Details, 
            Project_Code, Department_Code, Entry_User, Entry_Date
        )
        VALUES (
            @Process_Type, @Project_Id, @Qty, @Status, @Action_Details,
            @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
        );

        SET @RetVal = 1;
        SET @RetMsg = 'Release Qty updated and logged successfully.';
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @RetVal = -1;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH
END;
GO


