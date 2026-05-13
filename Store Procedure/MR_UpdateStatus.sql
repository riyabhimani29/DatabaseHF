USE [db_a8637c_hifaberp]
GO
/****** Object:  StoredProcedure [dbo].[MR_UpdateStatus]    Script Date: 13-05-2026 11:11:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[MR_UpdateStatus]
(
    @MR_Id      INT,
    @MR_Type    VARCHAR(50),
    @Upd_User   INT,

    @RetVal     INT = 0 OUT,
    @RetMsg     VARCHAR(500) = '' OUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        /* Check MR Exists */
        IF NOT EXISTS
        (
            SELECT 1
            FROM MaterialRequirement WITH (NOLOCK)
            WHERE MR_Id = @MR_Id
        )
        BEGIN
            SET @RetVal = -101
            SET @RetMsg = 'MR is already delete from other user.'
            ROLLBACK TRANSACTION
            RETURN
        END

        /* Check MR Type */
        IF NOT EXISTS
        (
            SELECT 1
            FROM MaterialRequirement WITH (NOLOCK)
            WHERE MR_Id = @MR_Id
                  AND (MR_Type = 'D' OR MR_Type = 'R')
        )
        BEGIN
            SET @RetVal = -102
            SET @RetMsg = 'Only Draft OR Rejected MR Can Be Deleted.'
            ROLLBACK TRANSACTION
            RETURN
        END

        
        DELETE FROM MR_Items
        WHERE MR_Id = @MR_Id

        DELETE FROM MaterialRequirement
        WHERE MR_Id = @MR_Id

        SET @RetVal = 1
        SET @RetMsg = 'MR Deleted Successfully.'

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SET @RetVal = -500
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE()

    END CATCH

END