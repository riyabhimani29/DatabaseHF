USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PR_MST_Delete]    Script Date: 07-05-2026 18:49:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PR_MST_Delete]
(
    @PO_Id      INT,
    @Upd_User   INT,

    @RetVal     INT = 0 OUT,
    @RetMsg     VARCHAR(500) = '' OUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

       
        IF NOT EXISTS
        (
            SELECT 1
            FROM PR_MST WITH (NOLOCK)
            WHERE PR_Id = @PO_Id
        )
        BEGIN
            SET @RetVal = -101
            SET @RetMsg = 'MR is already delete from other user.'
            ROLLBACK TRANSACTION
            RETURN
        END

        IF NOT EXISTS
        (
            SELECT 1
            FROM PR_MST WITH (NOLOCK)
            WHERE PR_Id = @PO_Id
                  AND PO_Type = 'D'
        )
        BEGIN
            SET @RetVal = -102
            SET @RetMsg = 'Only Draft MR Can Be Deleted.'
            ROLLBACK TRANSACTION
            RETURN
        END

         UPDATE BPR
        SET BPR.Is_PO = 0
        FROM BOM_PO_RequestDtl BPR
        INNER JOIN PR_DTL PRD
            ON BPR.BOM_PO_ReqDtl_Id = PRD.Req_Id
        WHERE PRD.PR_Id = @PO_Id
              AND ISNULL(PRD.Req_Id,0) <> 0


        DELETE FROM PR_MST
        WHERE PR_Id = @PO_Id

        DELETE FROM PR_DTL
        WHERE PR_Id = @PO_Id

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
GO


