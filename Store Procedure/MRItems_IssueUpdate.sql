USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MRItems_IssueUpdate]    Script Date: 27-04-2026 12:54:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MRItems_IssueUpdate]
    @DtlPara             dbo.MR_IssueItems_TableType READONLY,  -- Table-valued parameter for MR_Items
    @RetVal              INT = 0 OUT,      
    @RetMsg              NVARCHAR(MAX) = '' OUT  
AS      
BEGIN      
    SET NOCOUNT ON;

    DECLARE @_MR_Items_Id      AS INT = 0,    
            @_Issued    AS INT,  
            @_RecievedQty AS INT;

    BEGIN TRY      
        BEGIN TRANSACTION;  -- Begin Transaction
      
  DECLARE items_cursor CURSOR FOR      
        SELECT MR_Items_Id, Issued, RecievedQty
        FROM @DtlPara;      

        OPEN items_cursor;      

        FETCH NEXT FROM items_cursor INTO @_MR_Items_Id, @_Issued, @_RecievedQty;

        WHILE @@FETCH_STATUS = 0      
        BEGIN
           UPDATE MR_Items
                SET 
                RecievedQty = @_RecievedQty,
                Issued = @_Issued
                WHERE MR_Items_Id = @_MR_Items_Id;

        FETCH NEXT FROM items_cursor INTO @_MR_Items_Id, @_Issued, @_RecievedQty;
        END;

        CLOSE items_cursor;
        DEALLOCATE items_cursor;
               SET @RetVal = 200;
            SET @RetMsg = 'Material Requirement updated successfully.';  
        COMMIT TRANSACTION;  -- Commit the transaction
    END TRY      
      
    BEGIN CATCH      
        ROLLBACK TRANSACTION;  -- Rollback in case of error
      
        SET @RetVal = -1;  -- Error code
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();      
    END CATCH;      
END;
GO


