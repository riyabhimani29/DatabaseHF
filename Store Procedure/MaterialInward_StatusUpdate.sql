USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MaterialInward_StatusUpdate]    Script Date: 27-04-2026 12:50:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MaterialInward_StatusUpdate]
    @Id INT,   
    @Status NVARCHAR(1) = '',
    @Entry_User INT,      
    @RetVal INT = 0 OUT,      
    @RetMsg NVARCHAR(MAX) = '' OUT  
AS      
BEGIN      
    SET NOCOUNT ON;

    BEGIN TRY      
        BEGIN TRANSACTION;

        DECLARE 
            @Godown_Id INT,
            @Item_Id INT,
            @SType NVARCHAR(50),
            @Qty DECIMAL(18,2),
            @Length DECIMAL(18,2),
            @Width DECIMAL(18,2),
            @Rack_Id INT,
            @Stock_Id INT;

        -- Check if record exists
        IF NOT EXISTS (SELECT 1 FROM material_inward WHERE Id = @Id)
        BEGIN
            SET @RetVal = 2;
            SET @RetMsg = 'Record already deleted.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if already updated
        IF EXISTS (SELECT 1 FROM material_inward WHERE Id = @Id AND Status = @Status)
        BEGIN
            SET @RetVal = -124;
            SET @RetMsg = 'Already Updated.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Update Status
        UPDATE material_inward
        SET Status = @Status,
            Upd_User = @Entry_User,
            Upd_Date = GETDATE()
        WHERE Id = @Id;

        -- If Final Status = 'F'
        IF (@Status = 'F')
        BEGIN
            -- Fetch data
            SELECT 
                @Godown_Id = Godown_Id,
                @Item_Id = Item_Id,
                @SType = SType,
                @Qty = Total_Qty,
                @Length = Length,
                @Width = Width,
                @Rack_Id = Rack_Id
            FROM material_inward
            WHERE Id = @Id;

            -- Check if stock exists
            IF EXISTS (
                SELECT 1 
                FROM StockView 
                WHERE Godown_Id = @Godown_Id 
                  AND Item_Id = @Item_Id 
                  AND SType = @SType
                  AND Length = @Length
                  AND Width = @Width
                  AND Rack_Id = @Rack_Id
            )
            BEGIN
                -- Update existing stock
                UPDATE StockView
                SET 
                    Total_Qty = ISNULL(Total_Qty,0) + ISNULL(@Qty,0),
                    Pending_Qty = ISNULL(Pending_Qty,0) + ISNULL(@Qty,0),
                    LastUpdate = GETDATE()
                WHERE Godown_Id = @Godown_Id 
                  AND Item_Id = @Item_Id 
                  AND SType = @SType
                  AND Rack_Id = @Rack_Id
                  AND Length = @Length
                  AND Width = @Width;


                -- Get existing Stock_Id
                SELECT TOP 1 @Stock_Id = Id
                FROM StockView
                WHERE Godown_Id = @Godown_Id 
                  AND Item_Id = @Item_Id 
                  AND SType = @SType
                  AND Length = @Length
                  AND Width = @Width
                  AND Rack_Id = @Rack_Id;



                  INSERT INTO Stock_Transfer_History
                                (
                                    Godown_Id,
                                    Item_Id,
                                    SType,
                                    Transfer_Qty,
                                    [Length],
                                    Width,
                                    Rack_Id,
                                    Transfer_Date,
                                    Remark,
                                    StockEntryPage,
                                    Tbl_Name,
                                    Transfer_Type,
                                    Transfer_TypeInBit,
                                    Stock_Id
                                )
                                VALUES
                                (
                                    @Godown_Id,
                                    @Item_Id,
                                    @SType,
                                    @Qty,
                                    @Length,
                                    @Width,
                                    @Rack_Id,
                                    dbo.Get_sysdate(),
                                    'Material Inward',
                                    'Material Inward',
                                    'Material Inward',
                                    'IN',
                                    0,
                                    @Stock_Id
                                );


            END
            ELSE
            BEGIN
                -- Insert new stock
                INSERT INTO StockView
                (
                    Godown_Id,
                    Item_Id,
                    SType,
                    Total_Qty,
                    Pending_Qty,
                    Length,
                    Width,
                    Rack_Id,
                    LastUpdate,
                    StockEntryPage,
                    StockEntryQty,
                    Dtl_Id,
                    Tbl_Name
                )
                VALUES
                (
                    @Godown_Id,
                    @Item_Id,
                    @SType,
                    @Qty,
                    @Qty,
                    @Length,
                    @Width,
                    @Rack_Id,
                    GETDATE(),
                    'Material Inward',
                    @Qty,
                    @Id,
                    'material_inward'
                );

                
                -- Capture new Stock_Id
                SET @Stock_Id = SCOPE_IDENTITY();

                INSERT INTO Stock_Transfer_History
              (
                  Godown_Id,
                  Item_Id,
                  SType,
                  Transfer_Qty,
                  [Length],
                  Width,
                  Rack_Id,
                  Transfer_Date,
                  Remark,
                  StockEntryPage,
                  Tbl_Name,
                  Transfer_Type,
                  Transfer_TypeInBit,
                  Stock_Id
              )
              VALUES
              (
                  @Godown_Id,
                  @Item_Id,
                  @SType,
                  @Qty,
                  @Length,
                  @Width,
                  @Rack_Id,
                  dbo.Get_sysdate(),
                  'Material Inward',
                  'Material Inward',
                  'Material Inward',
                  'IN',
                  0,
                  @Stock_Id
              );



            END

            -- Update material_inward with Stock_Id
            UPDATE material_inward
            SET Stock_Id = @Stock_Id
            WHERE Id = @Id;
        END

        -- Success
        SET @RetVal = @Id;
        SET @RetMsg = 'Material Inward Status updated successfully.';

        COMMIT TRANSACTION;
    END TRY      
    BEGIN CATCH      
        ROLLBACK TRANSACTION;
        SET @RetVal = -1;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH;      
END
GO


