USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Elevation_Delete]    Script Date: 27-04-2026 11:23:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Elevation_Delete]    
    @Elevation_Id INT,    
    @RetVal INT = 0 OUT,            
    @RetMsg VARCHAR(MAX) = '' OUT     
AS    
BEGIN    
    SET NOCOUNT ON;    

    -- Check if the PanelType_Id is referenced in DPR_Project_PanelTypes
    IF EXISTS (SELECT 1 FROM DPR_Project_PanelTypes WITH (NOLOCK) WHERE Elevations LIKE '%' + CAST(@Elevation_Id AS VARCHAR) + '%')    
    BEGIN    
        SET @RetVal = -12; -- Indicates the record is already in use in DPR projects.         
        SET @RetMsg = 'Record already used in DPR projects.';             
        RETURN;    
    END    

    -- Check if the PanelType_Id exists in DPR_PanelTypes
    IF NOT EXISTS (SELECT 1 FROM DPR_Elevations WITH (NOLOCK) WHERE Elevation_Id = @Elevation_Id)    
    BEGIN    
        SET @RetVal = -12; -- Indicates the record has already been deleted by another user.         
        SET @RetMsg = 'Record already deleted by another user.';             
        RETURN;    
    END     

    -- Delete the record from DPR_PanelTypes
    DELETE FROM DPR_Elevations WHERE Elevation_Id = @Elevation_Id;    

    -- Check for errors after deletion
    IF @@ERROR = 0    
    BEGIN    
        SET @RetVal = 1; -- Success    
        SET @RetMsg = 'Deleted successfully.';  
    END    
    ELSE    
    BEGIN    
        SET @RetVal = 0; -- Error occurred   
        SET @RetMsg = 'Error occurred - ' + ERROR_MESSAGE() + '.';    
    END    
END
GO


