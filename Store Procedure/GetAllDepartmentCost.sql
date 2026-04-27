USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetAllDepartmentCost]    Script Date: 27-04-2026 11:29:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GetAllDepartmentCost]
    @Project_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        MR.Project_Id,

           SUM(ISNULL(MRI.Qty,0) * ISNULL(MRI.UnitCost,0)) AS Total_Ordered_Cost,
    SUM(ISNULL(MRI.Issue_Qty,0) * ISNULL(MRI.UnitCost,0)) AS Total_Fulfilled_Cost

    FROM MaterialRequirement MR

    INNER JOIN MR_Items MRI
        ON MR.MR_Id = MRI.MR_Id

    WHERE MR.Project_Id = @Project_Id

    GROUP BY MR.Project_Id;

END
GO


