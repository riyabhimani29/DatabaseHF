USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetDepartmentCost]    Script Date: 27-04-2026 11:31:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[GetDepartmentCost]
    @Project_Id INT,
    @Dept_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF(@Dept_Id = 1012)
        BEGIN
             SELECT 
                SFTD.Project_Id,
                @Dept_Id AS Dept_id,
                SUM(ISNULL(SFTD.OutwardQty,0)) AS Total_Qty,
                SUM(ISNULL(SFTD.OutwardQty,0)) AS Issued_Qty,
                SUM(ISNULL(SFTD.OutwardQty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Ordered_Cost,

                SUM(ISNULL(SFTD.OutwardQty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Fulfilled_Cost

            FROM safetytools_outward_Dtl SFTD
            INNER JOIN M_Item MI 
            ON MI.Item_Id = SFTD.[ItemId ]

            WHERE SFTD.Project_Id = @Project_Id AND SFTD.issue_type = 1
            GROUP BY SFTD.Project_Id


        END

    ELSE
        BEGIN
             SELECT 
            MR.Project_Id,
            MR.Dept_id,
            SUM(ISNULL(MRI.Qty,0)) AS Total_Qty,
            SUM(ISNULL(MRI.Issue_Qty,0)) AS Issued_Qty,
            SUM(ISNULL(MRI.Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Ordered_Cost,

            SUM(ISNULL(MRI.Issue_Qty,0) * ISNULL(MI.Item_Rate,0)) AS Total_Fulfilled_Cost

            FROM MaterialRequirement MR

            INNER JOIN MR_Items MRI
                ON MR.MR_Id = MRI.MR_Id

             INNER JOIN M_Item MI
                ON MRI.Item_Id = MI.Item_Id

            WHERE MR.Project_Id = @Project_Id
              AND MR.Dept_Id = @Dept_Id
              AND MR_Type = 'A'

            GROUP BY MR.Project_Id, MR.Dept_id ;

        END

   END

GO


