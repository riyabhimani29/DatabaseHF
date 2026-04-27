USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_Insert]    Script Date: 27-04-2026 10:54:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_Insert]
    @BOM_Id INT,      
    @Project_Id INT, 
    @Dept_ID INT,
    @Quotation_Number VARCHAR(30),
    @Material_Deliver_to INT,
    @Ref_Document_No VARCHAR(30),
    @ReqRaisedBy_Id INT,
    @Date DATE,
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
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Code VARCHAR(50);

    BEGIN TRY      
        BEGIN TRANSACTION;

        -- Get Project_Code and Department_Code
        SELECT @Project_Code = Project_Name 
        FROM M_Project 
        WHERE Project_Id = @Project_Id;

        SELECT @Department_Code = Dept_Name 
        FROM M_Department 
        WHERE Dept_Id = @Dept_ID;

        IF (@BOM_Id = 0)
        BEGIN      
            IF EXISTS (
                SELECT 1
                FROM BOM_MST 
                WHERE Project_Id = @Project_Id AND Dept_ID = @Dept_ID
            )
            BEGIN  
                SET @RetMsg = 'For this Project and Department, BOM already exists.'  
                SET @RetVal = -101;  
                ROLLBACK TRANSACTION;
                RETURN;  
            END 
            
            DECLARE @_GenBom_No AS VARCHAR(500)='',      
                    @_Bom_No  AS INT = 0,
                    @_Financial_Year AS INT = 0 
            SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, @Date)) 
            SELECT @_Bom_No = Isnull(Max(BOM_MST.Bom_Id), 0) + 1  
            FROM   BOM_MST

            SET @_GenBom_No = 'HF/BOM/' + CONVERT(VARCHAR(20), Format(@_Bom_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year) 
             

            -- Insert new BOM
            INSERT BOM_MST WITH(ROWLOCK) (
                Project_Id,Bom_No, Quotation_Number, Material_Deliver_to, Ref_Document_No,
                ReqRaisedBy_Id, Dept_ID, Date, Entry_User, Entry_Date, Upd_User, Upd_Date
            )
            VALUES (
                @Project_Id,@_GenBom_No, @Quotation_Number, @Material_Deliver_to, @Ref_Document_No,
                @ReqRaisedBy_Id, @Dept_ID, @Date, @Entry_User, dbo.Get_sysdate(),
                @Upd_User, dbo.Get_sysdate()
            );

            SET @RetVal = SCOPE_IDENTITY();
            SET @RetMsg = 'Raise BOM generated successfully.';

            -- Log BOM Creation
            SET @Process_Type = 'BOM_Creation';
            SET @Status = 'Created';
            SET @Action_Details = 'This is created for project ' + ISNULL(@Project_Code, 'Unknown') + '.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, NULL, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
            );
        END      
        ELSE
        BEGIN      
            -- Update existing BOM
            UPDATE BOM_MST WITH(ROWLOCK)
            SET
                Quotation_Number = @Quotation_Number,
                Material_Deliver_to = @Material_Deliver_to,
                Ref_Document_No = @Ref_Document_No,
                ReqRaisedBy_Id = @ReqRaisedBy_Id,
                Upd_User = @Upd_User,
                Upd_Date = dbo.Get_sysdate()
            WHERE BOM_Id = @BOM_Id;

            IF @@ROWCOUNT = 0
            BEGIN
                SET @RetVal = -102;
                SET @RetMsg = 'BOM record not found for BOM_Id: ' + CAST(@BOM_Id AS VARCHAR(10)) + '.';
                ROLLBACK TRANSACTION;
                RETURN;
            END

            SET @RetVal = @BOM_Id;
            SET @RetMsg = 'Raise BOM updated successfully.';

            -- Log BOM Update
            SET @Process_Type = 'BOM_Update';
            SET @Status = 'Updated';
            SET @Action_Details = 'This is updated for project ' + ISNULL(@Project_Code, 'Unknown') + '.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, NULL, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
            );
        END

        COMMIT TRANSACTION;
    END TRY      
    BEGIN CATCH      
        ROLLBACK TRANSACTION;
        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
    END CATCH      
END
GO


