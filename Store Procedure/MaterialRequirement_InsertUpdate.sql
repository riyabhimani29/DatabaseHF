USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MaterialRequirement_InsertUpdate]    Script Date: 27-04-2026 12:50:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[MaterialRequirement_InsertUpdate]
    @MR_Id INT,
    @Pd_Ref_No NVARCHAR(500) = '',
    @Coating_Colour INT,
    @MR_Type NVARCHAR(2) = '',
    @Project_Id INT,
    @Quotation_No NVARCHAR(500) = '',
    @Quotation_Attchment NVARCHAR(500) = '',
    @Mat_Delivery_At INT,
    @Department_Id INT,
    @Dept_ID INT,
    @MR_Department NVARCHAR(500) = '',
    @MR_Data_Type NVARCHAR(500) = '',
    @Delivery_Address NVARCHAR(500) = '',
    @MR_Reason NVARCHAR(500) = NULL,
    @Tentative_Mat_Expected DATETIME = NULL,
    @Prepared_By INT,
    @Project_Manager INT,
    @Site_Engineer INT,
    @Checked_By INT,
    @Authorised_By INT,
    @Authorised_Date DATETIME = NULL,
    @Checked_Date DATETIME = NULL,
    @Entry_User NVARCHAR(50),
    @Upd_User NVARCHAR(50),
   @DtlPara dbo.MR_Items_Typess READONLY, -- Table-valued parameter for MR_Items
    @RetVal INT = 0 OUT,
    @RetMsg NVARCHAR(MAX) = '' OUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Process_Type VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @Action_Details NVARCHAR(1000);
    DECLARE @Entry_User_Id INT;
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Code VARCHAR(50);
    DECLARE @TotalQty INT;
    DECLARE @DeptShortName NVARCHAR(20);
    DECLARE @NextSeq INT;
    DECLARE @MR_Code NVARCHAR(30);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Convert Entry_User to Entry_User_Id
      

        -- Get Project_Code and Department_Code
        SELECT @Project_Code = Project_Name 
        FROM M_Project 
        WHERE Project_Id = @Project_Id;

        SELECT @Department_Code = Dept_Name 
        FROM M_Department
        WHERE Dept_Id = @Dept_ID;

        -- Calculate total quantity
        SELECT @TotalQty = SUM(Qty) 
        FROM @DtlPara;

        -- Determine Status
        SET @Status = CASE 
                          WHEN @Authorised_Date IS NOT NULL THEN 'Authorized'
                          WHEN @Checked_Date IS NOT NULL THEN 'CheckedIn'
                          WHEN @MR_Type = 'S' THEN 'Saved'
                          ELSE 'Draft'
                      END;

        IF (@MR_Id = 0)
        BEGIN
            -- Insert into MaterialRequirement (new entry)
            INSERT INTO MaterialRequirement (
                Project_Id, Quotation_No,Coating_Colour, Mat_Delivery_At, Delivery_Address,MR_Reason, Pd_Ref_No,
                Department_Id, Tentative_Mat_Expected, Prepared_By, Project_Manager,
                Site_Engineer, Checked_By, Authorised_By, Authorised_Date, Checked_Date,
                Entry_User, Entry_Date, Upd_User, Upd_Date, MR_Type, Dept_ID,
                MR_Department, MR_Data_Type
            )
            VALUES (
                @Project_Id, @Quotation_No,@Coating_Colour, @Mat_Delivery_At, @Delivery_Address,@MR_Reason, @Pd_Ref_No,
                @Department_Id, @Tentative_Mat_Expected, @Prepared_By, @Project_Manager,
                @Site_Engineer, @Checked_By, @Authorised_By, CASE 
                    WHEN @Authorised_Date < '1753-01-01' THEN NULL 
                    ELSE @Authorised_Date 
                END,

                CASE 
                    WHEN @Checked_Date < '1753-01-01' THEN NULL 
                    ELSE @Checked_Date 
                END,
                @Entry_User, dbo.Get_sysdate(), @Upd_User, dbo.Get_sysdate(),
                @MR_Type, @Dept_ID, @MR_Department, @MR_Data_Type
            );

            SET @RetVal = SCOPE_IDENTITY();
            SET @RetMsg = 'Material Requirement inserted successfully.';

            -- Generate and update MR_Code
            IF (@MR_Type = 'S')
            BEGIN
                

                 -- Get Department Short Name
                 IF (@Dept_ID = 1)
                 BEGIN
                     SET @DeptShortName = 'PL'
                 END
                 ELSE
                 BEGIN
                     SELECT @DeptShortName = Dept_Short_Name
                     FROM M_Department
                     WHERE Dept_ID = @Dept_ID;
                 END

                 -- Get next sequence number for this department
                 SELECT @NextSeq =
                 ISNULL(
                   MAX(CAST(RIGHT(MR_Code, 6) AS INT)), 0
                 ) + 1
                 FROM MaterialRequirement
                 WHERE MR_Code LIKE 'MR-' + @DeptShortName + '-%';

                 -- Generate MR_Code
                 SET @MR_Code =
                 'MR-' +
                 @DeptShortName + '-' +
                 RIGHT('000000' + CAST(@NextSeq AS NVARCHAR(6)), 6);

                -- Update MR_Code
                UPDATE MaterialRequirement
                SET MR_Code = @MR_Code
                WHERE MR_Id = @RetVal;
            END;

            -- Log MR Creation
            SET @Process_Type = 'MR_Creation';
            SET @Action_Details = 'This is created with ' + ISNULL(CAST(@TotalQty AS NVARCHAR(10)), '0') + ' items.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, @TotalQty, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User_Id, dbo.Get_sysdate()
            );
        END
        ELSE
        BEGIN
            -- Update existing MaterialRequirement
            UPDATE MaterialRequirement
            SET
                Project_Id = @Project_Id,
                Quotation_No = @Quotation_No,
                Mat_Delivery_At = @Mat_Delivery_At,
                Pd_Ref_No = @Pd_Ref_No,
                Coating_Colour = @Coating_Colour,
                Department_Id = @Department_Id,
                Delivery_Address = @Delivery_Address,
                MR_Reason = @MR_Reason,
                Tentative_Mat_Expected = @Tentative_Mat_Expected,
                Prepared_By = @Prepared_By,
                Project_Manager = @Project_Manager,
                Site_Engineer = @Site_Engineer,
                Checked_By = @Checked_By,
                Dept_ID = @Dept_ID,
                MR_Department = @MR_Department,
                Authorised_By = @Authorised_By,
                Authorised_Date = CASE 
                    WHEN @Authorised_Date IS NULL OR @Authorised_Date < '1753-01-01' THEN NULL
                    ELSE @Authorised_Date
                END,

                Checked_Date = CASE 
                    WHEN @Checked_Date IS NULL OR @Checked_Date < '1753-01-01' THEN NULL
                    ELSE @Checked_Date
                END,

                MR_Data_Type = @MR_Data_Type,
                Upd_User = @Upd_User,
                Upd_Date = dbo.Get_sysdate()
            WHERE MR_Id = @MR_Id;

            SET @RetVal = @MR_Id;
            SET @RetMsg = 'Material Requirement updated successfully.';

            IF (@MR_Type = 'S')
            BEGIN
                 IF EXISTS (
    SELECT 1
    FROM MaterialRequirement
    WHERE MR_Id = @MR_Id
      AND MR_Type IN ('D', 'R')
)
                BEGIN
                    -- DECLARE @mr_code2 NVARCHAR(10) = 'MR-' + RIGHT('000000' + CAST(@RetVal AS NVARCHAR(6)), 6);
                    --UPDATE MaterialRequirement
                    --SET MR_Code = @mr_code2, MR_Type = @MR_Type
                    --WHERE MR_Id = @RetVal;
                     -- Get Department Short Name
                -- Get Department Short Name
                 IF (@Dept_ID = 1)
                 BEGIN
                     SET @DeptShortName = 'PL'
                 END
                 ELSE
                 BEGIN
                     SELECT @DeptShortName = Dept_Short_Name
                     FROM M_Department
                     WHERE Dept_ID = @Dept_ID;
                 END

                 -- Get next sequence number for this department
                 SELECT @NextSeq =
                 ISNULL(
                   MAX(CAST(RIGHT(MR_Code, 6) AS INT)), 0
                 ) + 1
                 FROM MaterialRequirement
                 WHERE MR_Code LIKE 'MR-' + @DeptShortName + '-%';

                 -- Generate MR_Code
                 SET @MR_Code =
                 'MR-' +
                 @DeptShortName + '-' +
                 RIGHT('000000' + CAST(@NextSeq AS NVARCHAR(6)), 6);

                -- Update MR_Code
                UPDATE MaterialRequirement
                SET MR_Code = @MR_Code,
                MR_Type = @MR_Type
                WHERE MR_Id = @RetVal;
                END;
            END;

            -- Log MR Update/Edit
            SET @Process_Type = CASE 
                                    WHEN @Status = 'CheckedIn' THEN 'MR_CheckedIn'
                                    WHEN @Status = 'Authorized' THEN 'MR_Authorize'
                                    ELSE 'MR_Edit'
                                END;
            SET @Action_Details = CASE 
                                      WHEN @Status = 'CheckedIn' THEN 'This is checked in.'
                                      WHEN @Status = 'Authorized' THEN 'This is authorized.'
                                      ELSE 'This is edited with ' + ISNULL(CAST(@TotalQty AS NVARCHAR(10)), '0') + ' items.'
                                  END;

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, @TotalQty, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User_Id, dbo.Get_sysdate()
            );

            -- Delete items not in @DtlPara
            DELETE FROM MR_Items
            WHERE MR_Items.MR_Id = @MR_Id
            AND MR_Items.MR_Items_Id NOT IN (
                SELECT MR_Items_Id FROM @DtlPara
            );

            -- Log deleted items
            IF @@ROWCOUNT > 0
            BEGIN
                INSERT INTO BOM_Logs (
                    Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                    Department_Code, Entry_User, Entry_Date
                )
                SELECT 
                    'MR_Edit', @Project_Id, Qty, 'Deleted',
                    'This is deleted, item quantity: ' + CAST(Qty AS NVARCHAR(10)) + '.',
                    @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
                FROM MR_Items
                WHERE MR_Id = @MR_Id
                AND MR_Items_Id NOT IN (
                    SELECT MR_Items_Id FROM @DtlPara
                );
            END;
        END;
select * from @DtlPara;
        -- Insert or update MR_Items
        MERGE MR_Items AS target
USING @DtlPara AS source
ON target.MR_Items_Id = source.MR_Items_Id 
WHEN MATCHED THEN
    UPDATE SET
        MR_Id = @RetVal,
        Item_Id = source.Item_Id,
        Stock_Id = source.Stock_Id,
        OriginalStock_Id = source.Stock_Id,
        Godown_Id = source.Godown_Id,
        Godown_Rack_Id = source.Godown_Rack_Id,
        Qty = source.Qty,
        Release_Qty = source.Release_Qty,
        Length = source.Length,
        Weight = source.Weight,
        UnitCost = source.UnitCost,
        UnitBendingCost = source.UnitBendingCost,
        TotalBendingCost = source.TotalBendingCost,
        TotalCost = source.TotalCost,
        Width = source.Width,
        coatingJson = source.coatingJson,
        Is_Job_Work = source.Is_Job_Work,
        Remarks = source.Remarks,
        SupDetail_Id = source.SupDetail_Id,
        Stock_Length = CASE 
    WHEN source.IsCustom = 1 THEN source.Length
    ELSE (
        SELECT TOP 1 SV.Length
        FROM StockView SV
        WHERE SV.Id = source.Stock_Id
    )
END
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        MR_Id,
        Item_Id,
        Stock_Id,
        OriginalStock_Id,
        Godown_Id,
        Godown_Rack_Id,
        Qty,
        Release_Qty,
        Length, 
        Weight,
        UnitCost,
        UnitBendingCost,
        TotalBendingCost,
        TotalCost,
        Width,
        coatingJson,
        Is_Job_Work,
        Remarks,
        SupDetail_Id,
        IsChecked,
        IsCustom,
        Stock_Length
    )
    VALUES (
        @RetVal,
        source.Item_Id,
        source.Stock_Id, 
        source.Stock_Id,
        source.Godown_Id,
        source.Godown_Rack_Id,
        source.Qty, 
        source.Release_Qty,
        source.Length,  
        source.Weight,
        source.UnitCost,
        source.UnitBendingCost,
        source.TotalBendingCost,
        source.TotalCost,
        source.Width,
        source.coatingJson,
        source.Is_Job_Work,
        source.Remarks,
        source.SupDetail_Id,
        source.IsSplit,
        source.IsCustom,
        (
         CASE 
    WHEN source.IsCustom = 1 THEN source.Length
    ELSE (
        SELECT TOP 1 SV.Length
        FROM StockView SV
        WHERE SV.Id = source.Stock_Id
    )
END
        )
    );

 
        -- Finalize transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @RetVal = -1;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH;
END;
GO


