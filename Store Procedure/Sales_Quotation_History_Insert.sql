USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Quotation_History_Insert]    Script Date: 27-04-2026 14:47:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_Quotation_History_Insert] 
    @Id INT,
    @Inquiry_Id INT,
    @Prepared_Date DATE, -- Ensure the parameter type is DATE
    @Quotation_Version INT,
    @Prepared_By INT,
    @Requested_By INT,
    @Amount VARCHAR(MAX),
    @Revision_Detail VARCHAR(MAX),
    @No_Of_Attachments INT,
    @Entry_User INT,
    @Upd_User INT,
    @RetVal INT = 0 OUT,
    @RetMsg VARCHAR(MAX) = '' OUT
AS
BEGIN
    BEGIN TRY
        -- Logging start of procedure
        PRINT 'Starting stored procedure execution...';

        IF (@Id = 0)
        BEGIN
            -- Insert the main quotation record
            INSERT INTO Sales_Quotation_History (
                Inquiry_Id,
                Prepared_Date,
                Quotation_Version,
                Prepared_By,
                Amount,
                Revision_Detail,
                No_Of_Attachments,
                Requested_By,
                entry_user,
                entry_date
            )
            VALUES (
                @Inquiry_Id,
                @Prepared_Date, -- Ensure this is a valid DATE value
                @Quotation_Version,
                @Prepared_By,
                @Amount,
                @Revision_Detail,
                @Requested_By,
                @No_Of_Attachments,
                @Entry_User,
                dbo.Get_sysdate()
            );

            -- Get the ID of the newly inserted quotation
            SET @RetVal = SCOPE_IDENTITY();
            PRINT 'Record inserted with ID: ' + CAST(@RetVal AS VARCHAR);

            -- Set the success message
            SET @RetMsg = 'Create Successfully.';
        END
        ELSE
        BEGIN
            -- Update existing record
            UPDATE Sales_Quotation_History 
            SET
                Prepared_Date = @Prepared_Date, -- Ensure this is a valid DATE value
                Quotation_Version = @Quotation_Version,
                Prepared_By = @Prepared_By,
                Amount = @Amount,
                Requested_By = @Requested_By,
                Revision_Detail = @Revision_Detail,
                No_Of_Attachments = @No_Of_Attachments
            WHERE Id = @Id;
            
            -- Set the success message
            SET @RetVal = @Id;
            PRINT 'Record updated with ID: ' + CAST(@RetVal AS VARCHAR);

            SET @RetMsg = 'Updated Successfully.';
        END
    END TRY
    BEGIN CATCH
        -- Log the error message
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
        SET @RetVal = 0; -- 0 IS FOR ERROR
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
    END CATCH
END
GO


