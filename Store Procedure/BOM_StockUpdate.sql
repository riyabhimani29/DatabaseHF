USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_StockUpdate]    Script Date: 27-04-2026 11:05:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_StockUpdate] 
    @BOM_Id              INT,
    @Entry_User         INT,      
    @Upd_User           INT,      
    @RetVal             INT = 0 out,      
    @RetMsg             VARCHAR(max) = '' out  
AS      
BEGIN
    SET nocount ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE BOM_MST 
        SET IsPublish = 1 
        WHERE Bom_Id = @BOM_Id;

        UPDATE sv 
        SET sv.Pending_Qty = sv.Pending_Qty - bd.Qty,
        sv.Tbl_Name = 'BOM_Dtl',
        sv.Dtl_Id = bd.BOM_Dtl_Id,
        sv.LastUpdate = dbo.Get_sysdate()
        FROM StockView sv
        INNER JOIN BOM_Dtl bd ON sv.Item_Id = bd.Item_Id AND sv.[Length] = bd.Length
        WHERE bd.BOM_Id = @BOM_Id AND (bd.Stock_Id = 0 OR sv.Id = bd.Stock_Id);

        COMMIT;

        SET @RetVal = 1; -- 1 for success
        SET @RetMsg = 'Update successful.';
    END TRY
    BEGIN CATCH
        ROLLBACK;

        SET @RetVal = -405; -- 0 IS FOR ERROR                       
        SET @RetMsg ='Error Occurred - ' + Error_message() + '.';
    END CATCH
END
GO


