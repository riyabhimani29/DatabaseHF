USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_bulk_Upld]    Script Date: 27-04-2026 12:16:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Item_bulk_Upld]
    @MAC_Add         VARCHAR(500),
    @Entry_User      INT,
    @Upd_User        INT,
    @RetVal          INT = 0 out,
    @DtlPara         dbo.ItemDetailsTableType readonly,
    @RetMsg          VARCHAR(max) = '' out
AS
BEGIN
    SET nocount ON;

    -- Declare all necessary variables
    DECLARE @_Item_No AS INT = 0;
    --DECLARE @_Item_Code AS VARCHAR(50);
    DECLARE @Item_Group_Id INT;
    DECLARE @Item_Cate_Id INT;
    DECLARE @Item_Id INT;
    DECLARE @Item_Name VARCHAR(500);
    DECLARE @HSN_Code VARCHAR(500);
    DECLARE @Item_Code VARCHAR(500);
    DECLARE @Total_Parameter NUMERIC(18, 3);
    DECLARE @Coated_Area NUMERIC(18, 3);
    DECLARE @NonCoated_Area NUMERIC(18, 3);
    DECLARE @Calc_Area NUMERIC(18, 3);
    DECLARE @Thickness NUMERIC(18, 3);
    DECLARE @Weight_Mtr NUMERIC(18, 3);
    DECLARE @Item_Rate NUMERIC(18, 3);
    DECLARE @Unit_Id INT;
    DECLARE @Alternate_Unit_Id INT;
    DECLARE @AlternateUnitValue NUMERIC(18, 3);
    DECLARE @AlternateUnitPrice NUMERIC(18, 3);
    DECLARE @UnitValue NUMERIC(18, 3);
    DECLARE @Is_Active BIT;
    DECLARE @Remark VARCHAR(500);

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Cursor for inserting or updating multiple items from the table type
        DECLARE item_cursor CURSOR FOR
        SELECT Item_Group_Id, Item_Cate_Id, Item_Id, Item_Name, HSN_Code, Item_Code, Total_Parameter, 
               Coated_Area, NonCoated_Area, Calc_Area, Thickness, Weight_Mtr, Item_Rate, 
               Unit_Id, Alternate_Unit_Id, AlternateUnitValue, AlternateUnitPrice, 
               UnitValue, Is_Active, Remark
        FROM @DtlPara;

        OPEN item_cursor;

        FETCH NEXT FROM item_cursor INTO @Item_Group_Id, @Item_Cate_Id, @Item_Id, @Item_Name, @HSN_Code, @Item_Code,
                                         @Total_Parameter, @Coated_Area, @NonCoated_Area, @Calc_Area, 
                                         @Thickness, @Weight_Mtr, @Item_Rate, @Unit_Id, 
                                         @Alternate_Unit_Id, @AlternateUnitValue, @AlternateUnitPrice, 
                                         @UnitValue, @Is_Active, @Remark;

        WHILE @@FETCH_STATUS = 0
        BEGIN
        	IF (@Item_Code = '' OR @Item_Code is null)
        	BEGIN
            -- Generate the item code using a function
            SET @Item_Code = dbo.Get_hifabcode(@Item_Group_Id, @Item_Cate_Id, @Item_Id);
                
			END
            -- Check if item already exists
            IF EXISTS (SELECT 1 
                       FROM m_item WITH (nolock)
                       WHERE item_code = @Item_Code
                         AND item_group_id = @Item_Group_Id
                         AND item_cate_id = @Item_Cate_Id)
            BEGIN
                SET @RetVal = -101;
                SET @RetMsg = 'Same HiFab_Code Exists In Selected Group & Category.';
               	CLOSE item_cursor;
                DEALLOCATE item_cursor;
                ROLLBACK TRANSACTION;
                RETURN;
            END

			-- Determine item number
            SELECT @_Item_No = ISNULL(MAX(item_no), 0) + 1
            FROM m_item WITH (nolock)
            WHERE item_group_id = @Item_Group_Id
              AND item_cate_id = @Item_Cate_Id;

            -- Insert the new item details into the m_item table
            INSERT INTO m_item WITH (rowlock)
                (item_group_id, item_cate_id, item_code, item_no, item_name, hsn_code, total_parameter, 
                 coated_area, noncoated_area, calc_area, weight_mtr, item_rate, unit_id, unitvalue, is_active, 
                 remark, mac_add, entry_user, entry_date, thickness, alternate_unit_id, alternateunitvalue, 
                 alternateunitprice)
            VALUES 
                (@Item_Group_Id, @Item_Cate_Id, @Item_Code, @_Item_No, @Item_Name, @HSN_Code, 
                 @Total_Parameter, @Coated_Area, @NonCoated_Area, @Calc_Area, @Weight_Mtr, 
                 @Item_Rate, @Unit_Id, @UnitValue, @Is_Active, @Remark, @MAC_Add, 
                 @Entry_User, dbo.Get_sysdate(), @Thickness, @Alternate_Unit_Id, 
                 @AlternateUnitValue, @AlternateUnitPrice);
                
            -- Get the identity value (Item_Id) of the inserted item
            SET @RetVal = SCOPE_IDENTITY();
            
            FETCH NEXT FROM item_cursor INTO @Item_Group_Id, @Item_Cate_Id, @Item_Id, @Item_Name, @HSN_Code, @Item_Code,
                                             @Total_Parameter, @Coated_Area, @NonCoated_Area, @Calc_Area, 
                                             @Thickness, @Weight_Mtr, @Item_Rate, @Unit_Id, 
                                             @Alternate_Unit_Id, @AlternateUnitValue, @AlternateUnitPrice, 
                                             @UnitValue, @Is_Active, @Remark;
        END

        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        SET @RetMsg = 'Items processed successfully.';

        COMMIT;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SET @RetVal = 0;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
    END CATCH
END;
GO


