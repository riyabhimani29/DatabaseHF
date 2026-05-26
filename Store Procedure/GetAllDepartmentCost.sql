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
        FinalData.Project_Id,

        SUM(FinalData.Total_Ordered_Cost) AS Total_Ordered_Cost,
        SUM(FinalData.Total_Fulfilled_Cost) AS Total_Fulfilled_Cost

    FROM
    (

        ----------------------------------------------------------------
        -- DEPARTMENT OTHER THAN 1
        ----------------------------------------------------------------
        SELECT 
            MR.Project_Id,

            SUM(ISNULL(MRI.Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Ordered_Cost,

            SUM(ISNULL(MRI.Issue_Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Fulfilled_Cost

        FROM MaterialRequirement MR

        INNER JOIN MR_Items MRI
            ON MR.MR_Id = MRI.MR_Id

        INNER JOIN M_Item MI
            ON MI.Item_Id = MRI.Item_Id

        WHERE MR.Project_Id = @Project_Id
              AND MR.Dept_ID <> 1
              AND MR.MR_Type = 'A'

        GROUP BY MR.Project_Id


        UNION ALL


        ----------------------------------------------------------------
        -- DEPARTMENT 1
        ----------------------------------------------------------------
        SELECT 
            MR.Project_Id,

            SUM(ISNULL(MRI.Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Ordered_Cost,

            SUM(ISNULL(MRI.Issue_Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Fulfilled_Cost

        FROM MaterialRequirement MR

        INNER JOIN MR_Items MRI
            ON MR.MR_Id = MRI.MR_Id

        INNER JOIN M_Item MI
            ON MI.Item_Id = MRI.Item_Id

        WHERE MR.Project_Id = @Project_Id
              AND MR.Dept_ID = 1
              AND MR.MR_Type = 'A'
              AND MR.Is_Job_Work = 'Mill-Finished'

        GROUP BY MR.Project_Id

    ) FinalData

    GROUP BY FinalData.Project_Id;

END