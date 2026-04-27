USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MaterialInward_InsertUpdate]    Script Date: 27-04-2026 12:49:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MaterialInward_InsertUpdate] 
@Id INT = 0,
@Godown_Id INT = 10,          
@Rack_Id INT = 5,        
@Item_Group_Id INT = 61,              
@Item_Cate_Id INT = 159,              
@Item_Id INT = 262,              
@Length NUMERIC(18, 3) = 5400,              
@Total_Qty NUMERIC(18, 3) = 10,              
@Width NUMERIC(18, 3) = 2.65,              
@SType VARCHAR(500) = 'N',              
@Remark VARCHAR(500) = '',              
@MAC_Add VARCHAR(500) = '',              
@Entry_User INT = 1,              
@Upd_User INT = 1,              
@Year_Id INT = 1,              
@Branch_ID INT = 1, 
@Checked_By INT = 0,
@Authorised_By INT = 0,
@Inward_Reason VARCHAR(500) ='',
@RetVal INT = 0 OUT,              
@RetMsg VARCHAR(MAX) = '' OUT              
AS              
BEGIN              
    SET NOCOUNT ON;              

    BEGIN TRY              
        BEGIN TRANSACTION;              

        -- INSERT
        IF (@Id = 0)
        BEGIN              
            INSERT INTO material_inward WITH (ROWLOCK)
            (
                godown_id,
                item_id,
                stype,
                total_qty,
                length,
                remark,
                mac_add,
                entry_user,
                entry_date,
                year_id,
                branch_id,
                width,
                rack_id,
                checked_by,
                approved_by,
                status,
                Inward_Reason
            )
            VALUES     
            (
                @Godown_Id,
                @Item_Id,
                @SType,
                @Total_Qty,
                @Length,
                @Remark,
                @MAC_Add,
                @Entry_User,
                dbo.Get_sysdate(),
                @Year_Id,
                @Branch_ID,
                @Width,
                @Rack_Id,
                @Checked_By,
                @Authorised_By,
                'S',
                @Inward_Reason
            );

            SET @RetMsg = 'Stock Added Successfully.';
            SET @RetVal = SCOPE_IDENTITY();
        END              

        -- UPDATE
        ELSE
        BEGIN              
            IF EXISTS (SELECT 1 FROM material_inward WHERE Id = @Id)
            BEGIN
                UPDATE material_inward
                SET
                    godown_id = @Godown_Id,
                    item_id = @Item_Id,
                    stype = @SType,
                    total_qty = @Total_Qty,
                    length = @Length,
                    remark = @Remark,
                    mac_add = @MAC_Add,
                    year_id = @Year_Id,
                    branch_id = @Branch_ID,
                    width = @Width,
                    rack_id = @Rack_Id,
                    checked_by = @Checked_By,
                    approved_by = @Authorised_By,
                    status = 'S',
                    Inward_Reason = @Inward_Reason
                WHERE Id = @Id;

                SET @RetMsg = 'Stock Updated Successfully.';
                SET @RetVal = @Id;
            END
            ELSE
            BEGIN
                SET @RetVal = -1;
                SET @RetMsg = 'Record not found.';
            END
        END              

        COMMIT TRANSACTION;              
    END TRY              

    BEGIN CATCH              
        ROLLBACK TRANSACTION;              

        SET @RetVal = -405;              
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();              
    END CATCH              
END
GO


