USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_Request_Upsert]    Script Date: 27-04-2026 14:30:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_Request_Upsert]
    @PO_Req_Id              INT = 0,
    @Dept_ID                INT,
    @Supplier_Id            INT = 0,
    @Is_Approved            INT = 0,
    @Is_Draft               INT = 0,
    @Authorize_Person_Id    INT,
    @PO_Ref_No              VARCHAR(MAX) = '',
    @Entry_User             INT,
    @Upd_User               INT,
    @DtlPara                TBL_PO_REQ_DTLS READONLY,
    @RetVal                 INT = 0 OUTPUT,
    @RetMsg                 VARCHAR(MAX) = '' OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @_BOM_PO_ReqDtl_Id INT = 0,
            @_Godown_Id INT = 0,
            @_Godown_Rack_Id INT = 0,
            @_Item_Id INT = 0,
            @_UnitValue NUMERIC(18, 3) = 0,
            @_Project_Id INT = 0,
            @_Length NUMERIC(18, 3) = 0,
            @_Weight NUMERIC(18, 3) = 0,
            @_Width NUMERIC(18, 3) = 0,
            @_Qty NUMERIC(18, 3) = 0,
            @_Reject_Reason VARCHAR(MAX) = '',
            @_Is_Approved INT = 0,
            @_AllItemsRejected BIT = 0;

    BEGIN TRY
        -- Input validation
        IF @Dept_ID <= 0 OR @Authorize_Person_Id <= 0 OR @Entry_User <= 0 OR @Upd_User <= 0
        BEGIN
            SET @RetVal = -400;
            SET @RetMsg = 'Invalid input parameters: Department, Authorize Person, Entry User, or Update User ID is invalid.';
            RETURN;
        END

        IF @Is_Draft = 0 AND @Supplier_Id <= 0 AND @PO_Req_Id = 0
        BEGIN
            SET @RetVal = -401;
            SET @RetMsg = 'Supplier ID is required for non-draft requests.';
            RETURN;
        END

        -- Check if all items are rejected for non-draft requests
        IF @Is_Draft = 0
        BEGIN
            IF EXISTS (SELECT 1 FROM @DtlPara) -- Ensure details exist
            BEGIN
                SET @_AllItemsRejected = 1;
                IF EXISTS (SELECT 1 FROM @DtlPara WHERE Is_Approved <> 3)
                BEGIN
                    SET @_AllItemsRejected = 0; -- Not all items are rejected
                END
            END
        END

        BEGIN TRANSACTION;

        IF @PO_Req_Id > 0
        BEGIN
            -- Update existing PO request
            UPDATE PO_Request_MST WITH (ROWLOCK)
            SET --Supplier_Id = @Supplier_Id,
                Is_Approved = CASE WHEN @Is_Draft = 1 THEN 0 ELSE CASE WHEN @_AllItemsRejected = 1 THEN 3 ELSE 1 END END,
                Is_Draft = @Is_Draft,
               -- Authorize_Person_Id = @Authorize_Person_Id,
               -- PO_Ref_No = @PO_Ref_No,
                Upd_User = @Upd_User,
                Upd_Date = dbo.Get_sysdate(),
                Approve_Date = CASE WHEN @Is_Draft = 0 THEN dbo.Get_sysdate() ELSE NULL END
            WHERE PO_Req_Id = @PO_Req_Id;

            -- Delete existing details to replace with new ones
            DELETE FROM PO_Request_Dtl WHERE PO_Req_Id = @PO_Req_Id;

            SET @RetVal = @PO_Req_Id;
            SET @RetMsg = CASE 
                            WHEN @Is_Draft = 1 THEN 'Draft updated successfully.'
                            WHEN @_AllItemsRejected = 1 THEN 'Request rejected successfully.'
                            ELSE 'Request updated and approved successfully.'
                          END;
        END
        ELSE
        BEGIN
            -- Insert new PO request
            INSERT INTO PO_Request_MST WITH (ROWLOCK)
                (Dept_ID, Supplier_Id, Authorize_Person_Id, PO_Ref_No, Date, Entry_User, Entry_Date, Upd_User, Upd_Date, Is_Approved, Is_Draft)
            VALUES
                (@Dept_ID, @Supplier_Id, @Authorize_Person_Id, @PO_Ref_No, dbo.Get_sysdate(), @Entry_User, 
                 dbo.Get_sysdate(), @Upd_User, dbo.Get_sysdate(), 
                 CASE WHEN @Is_Draft = 1 THEN 0 ELSE CASE WHEN @_AllItemsRejected = 1 THEN 3 ELSE 1 END END, @Is_Draft);

            SET @RetVal = SCOPE_IDENTITY();
            SET @RetMsg = CASE 
                            WHEN @Is_Draft = 1 THEN 'Successfully saved as draft.'
                            WHEN @_AllItemsRejected = 1 THEN 'Request created and rejected successfully.'
                            ELSE 'Successfully created and approved request.'
                          END;
        END

        -- Process detail records
        DECLARE po_cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT BOM_PO_ReqDtl_Id,
               Godown_Id,
               Godown_Rack_Id,
               Item_Id,
               UnitValue,
               Project_Id,
               CONVERT(NUMERIC(18, 3), Length),
               CONVERT(NUMERIC(18, 3), Weight),
               Width,
               Qty,
               Reject_Reason,
               Is_Approved
        FROM @DtlPara;

        OPEN po_cur;
        
        FETCH NEXT FROM po_cur INTO @_BOM_PO_ReqDtl_Id, @_Godown_Id, @_Godown_Rack_Id, @_Item_Id, @_UnitValue, @_Project_Id,
                                   @_Length, @_Weight, @_Width, @_Qty, @_Reject_Reason, @_Is_Approved;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Validate detail parameters
            IF @_Item_Id <= 0 OR @_Qty <= 0
            BEGIN
                ROLLBACK;
                SET @RetVal = -402;
                SET @RetMsg = 'Invalid detail parameters: Item ID or Quantity is invalid.';
                CLOSE po_cur;
                DEALLOCATE po_cur;
                RETURN;
            END

            -- Validate rejection reason for rejected items
            IF @_Is_Approved = 3 AND ISNULL(@_Reject_Reason, '') = ''
            BEGIN
                ROLLBACK;
                SET @RetVal = -406;
                SET @RetMsg = 'Rejection reason is required for rejected items.';
                CLOSE po_cur;
                DEALLOCATE po_cur;
                RETURN;
            END

            INSERT INTO PO_Request_Dtl WITH (ROWLOCK)
                (PO_Req_Id, BOM_PO_ReqDtl_Id, Godown_Id, Godown_Rack_Id, Item_Id, Project_Id, 
                 [Length], [Weight], Width, Qty, Reject_Reason, Is_Approved)
            VALUES
                (@RetVal, @_BOM_PO_ReqDtl_Id, @_Godown_Id, @_Godown_Rack_Id, @_Item_Id, @_Project_Id,
                 CONVERT(NUMERIC(18, 3), @_Length), CONVERT(NUMERIC(18, 3), @_Weight),
                 @_Width, @_Qty, @_Reject_Reason, @_Is_Approved);

            IF @Is_Draft = 0
            BEGIN
                UPDATE BOM_PO_RequestDtl 
                SET Is_Requested = 1 
                WHERE BOM_PO_ReqDtl_Id = @_BOM_PO_ReqDtl_Id;

                UPDATE M_Item 
                SET UnitValue = @_UnitValue
                WHERE Item_Id = @_Item_Id;
            END

            FETCH NEXT FROM po_cur INTO @_BOM_PO_ReqDtl_Id, @_Godown_Id, @_Godown_Rack_Id, @_Item_Id, @_UnitValue, @_Project_Id,
                                       @_Length, @_Weight, @_Width, @_Qty, @_Reject_Reason, @_Is_Approved;
        END;

        CLOSE po_cur;
        DEALLOCATE po_cur;
        
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        IF CURSOR_STATUS('local', 'po_cur') >= 0
        BEGIN
            CLOSE po_cur;
            DEALLOCATE po_cur;
        END

        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + 
                     '. Line: ' + CAST(ERROR_LINE() AS VARCHAR(10)) + 
                     '. Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    END CATCH;
END;
GO


