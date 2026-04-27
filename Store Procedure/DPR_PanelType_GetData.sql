USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_PanelType_GetData]    Script Date: 27-04-2026 11:25:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[DPR_PanelType_GetData]              
 @Type Bit = 0    
AS        
    SET nocount ON        
        
         
SELECT DPR_PanelTypes.PanelType_Id,      
       DPR_PanelTypes.[Name],    
     DPR_PanelTypes.Is_Active,      
       DPR_PanelTypes.Remark 
FROM   DPR_PanelTypes WITH (nolock)       
where  DPR_PanelTypes.Is_Active  = (case when @Type = 0  then DPR_PanelTypes.Is_Active else 1 end )    
  ORDER BY DPR_PanelTypes.PanelType_Id DESC     
GO


