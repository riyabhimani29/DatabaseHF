USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[UpdatePRProject]    Script Date: 13-05-2026 11:14:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[UpdatePRProject]
(
    @Project_Id INT,
    @PRDtl_Id INT,

    @RetVal INT = 0 OUT,
    @RetMsg VARCHAR(500) = '' OUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- CHECK DC EXISTS
        IF NOT EXISTS
        (
            SELECT 1
            FROM PR_DTL
            WHERE PRDtl_Id = @PRDtl_Id
        )
        BEGIN

            SET @RetVal = -1;
            SET @RetMsg = 'PR Record Not Found.';

            ROLLBACK TRANSACTION;
            RETURN;

        END


        -- CHECK PROJECT EXISTS
        IF NOT EXISTS
        (
            SELECT 1
            FROM M_Project
            WHERE Project_Id = @Project_Id
        )
        BEGIN

            SET @RetVal = -2;
            SET @RetMsg = 'Project Not Found.';

            ROLLBACK TRANSACTION;
            RETURN;

        END


        -- CHECK SAME PROJECT ALREADY ASSIGNED
        IF EXISTS
        (
            SELECT 1
            FROM PR_DTL
            WHERE PRDtl_Id = @PRDtl_Id
            AND Project_Id = @Project_Id
        )
        BEGIN

            SET @RetVal = -3;
            SET @RetMsg = 'Same Project Already Assigned.';

            ROLLBACK TRANSACTION;
            RETURN;

        END


        -- UPDATE PROJECT
        UPDATE PR_DTL
        SET
            Project_Id = @Project_Id
        WHERE PRDtl_Id = @PRDtl_Id;


        SET @RetVal = @PRDtl_Id;
        SET @RetMsg = 'Project Updated Successfully.';

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @RetVal = -99;

        SET @RetMsg =
        'Line : '
        + CAST(ERROR_LINE() AS VARCHAR)
        + ' Message : '
        + ERROR_MESSAGE();

    END CATCH

END
GO


