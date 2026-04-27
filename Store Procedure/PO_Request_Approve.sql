USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_Request_Approve]    Script Date: 27-04-2026 14:30:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_Request_Approve]
    @PO_Req_Id INT,
    @SessionUser INT,
    @Approval_Status INT,
    @Reject_Reason VARCHAR(MAX) = NULL,
    @RetVal INT = 0 OUTPUT,
    @RetMsg VARCHAR(MAX) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Update PO_Request_MST
        UPDATE PO_Request_MST WITH (ROWLOCK)
        SET Is_Approved = @Approval_Status,
            Upd_User = @SessionUser,
            Approve_Date = dbo.Get_sysdate(),
            Upd_Date = dbo.Get_sysdate()
        WHERE PO_Req_Id = @PO_Req_Id;

        -- If rejecting (Approval_Status = 3), update mr_items
        IF @Approval_Status = 3
        BEGIN
            IF @Reject_Reason IS NULL
            BEGIN
                ROLLBACK;
                SET @RetVal = -406;
                SET @RetMsg = 'Rejection reason is required for reject status.';
                RETURN;
            END

            UPDATE mr_items
            SET IsRejected = 1,
                Reject_Reason = @Reject_Reason
            FROM MR_Items mi
            INNER JOIN BOM_PO_RequestDtl ON mi.MR_Items_Id = BOM_PO_RequestDtl.BOM_Dtl_Id
            INNER JOIN PO_Request_Dtl prd ON BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id = prd.BOM_PO_ReqDtl_Id            
            WHERE prd.PO_Req_Id = @PO_Req_Id;
        END

        SET @RetVal = 1;
        SET @RetMsg = CASE 
                         WHEN @Approval_Status = 1 THEN 'Request approved successfully.'
                         ELSE 'Request rejected successfully.'
                      END;
        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH;
END;
GO


