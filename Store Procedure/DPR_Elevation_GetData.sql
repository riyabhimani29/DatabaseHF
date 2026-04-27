USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Elevation_GetData]    Script Date: 27-04-2026 11:23:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Elevation_GetData]              
 @Type Bit = 0    
AS        
    SET nocount ON        
        
         
SELECT DPR_Elevations.Elevation_Id,      
       DPR_Elevations.[Name],    
     DPR_Elevations.Is_Active,      
       DPR_Elevations.Remark 
FROM   DPR_Elevations WITH (nolock)       
where  DPR_Elevations.Is_Active  = (case when @Type = 0  then DPR_Elevations.Is_Active else 1 end )    
  ORDER BY DPR_Elevations.Elevation_Id DESC     

GO


