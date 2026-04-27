USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_OtherSettings_Ins]    Script Date: 27-04-2026 12:39:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_OtherSettings_Ins]
    @Lockindate DateTime,  
    @RetVal INT = 0 OUT,    
    @RetMsg VARCHAR(MAX) = '' OUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if a row with master_id = 99 exists
    IF EXISTS (SELECT 1 FROM [dbo].[M_Setting] WHERE Master_Id = 99)
    BEGIN
        -- Update the existing row
        UPDATE [dbo].[M_Setting]
        SET 
            [Lockindate] = @Lockindate
        WHERE Master_Id = 99;

        SET @RetMsg = 'Other Setting updated successfully.';
        SET @RetVal = 1;  -- Indicating update was successful
    END
    ELSE
    BEGIN
        -- Insert a new row
        INSERT INTO [dbo].[M_Setting] (Lockindate, Master_Id)
        VALUES (@Lockindate, 99);

        SET @RetMsg = 'Other Setting saved successfully.';
        SET @RetVal = SCOPE_IDENTITY();  -- Return the ID of the inserted row
    END

    -- Check for any errors and set error message if occurred
    IF @@ERROR <> 0
    BEGIN
        SET @RetVal = 0;  -- 0 indicates an error
        SET @RetMsg = 'Error occurred - ' + ERROR_MESSAGE() + '.';
    END
END
GO


