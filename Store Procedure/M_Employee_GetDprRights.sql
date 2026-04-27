USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetDprRights]    Script Date: 27-04-2026 11:56:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[M_Employee_GetDprRights]          
    @Emp_Id int = 1
AS          

SET NOCOUNT ON        

SELECT 
   -- dbo.Release_Panel.Dpr_Id as DprId,   
    dbo.DPR_Project.Project_Id, 
    DPR_Project.Project_Name,
    KK.Id,
    KK.Emp_Id,  
    KK.ReleasePanel,
    KK.Fabrication,  
    KK.Panel_Dispatch,  
    KK.Assemble,  
    KK.Glazing,  
    KK.Installation
FROM 
    dbo.DPR_Project with(nolock)  
OUTER APPLY (
    SELECT 
        dbo.M_DPR_Rigths.Id,   
        dbo.M_DPR_Rigths.Emp_Id,  
        dbo.M_DPR_Rigths.ReleasePanel,
        dbo.M_DPR_Rigths.Fabrication,  
        dbo.M_DPR_Rigths.Panel_Dispatch,  
        dbo.M_DPR_Rigths.Assemble,  
        dbo.M_DPR_Rigths.Glazing,  
        dbo.M_DPR_Rigths.Installation  
    FROM 
        dbo.M_DPR_Rigths with(nolock)  
    WHERE  
        dbo.M_DPR_Rigths.Project_Id = dbo.DPR_Project.Project_Id
        AND
        dbo.M_DPR_Rigths.Emp_Id = @Emp_Id  
) AS KK 
GO


