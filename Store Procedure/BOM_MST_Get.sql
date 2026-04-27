USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_MST_Get]    Script Date: 27-04-2026 10:55:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_MST_Get]
    @BOM_Id INT = 0,
    @Type INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Internal declaration for SessionUser
    DECLARE @SessionUser INT = 0;  -- you can set the actual user ID here if needed

    SELECT (
        SELECT  
            B.Bom_Id,
            B.Bom_No,
            B.Quotation_Number,
            B.remark,
            B.[Date],
            P.Project_Id,
            P.Project_Name,
            mat.Emp_Name AS Material_Deliver_Name,
            B.Material_Deliver_to,
            B.Ref_Document_No,
            req.Emp_Name AS ReqRaisedBy_Name,
            B.ReqRaisedBy_Id,

            -- Total cost calculated with workflow/type filters only
            ISNULL((
                SELECT 
                    SUM(ISNULL(I.UnitCost, 0) * ISNULL(I.Qty, 0))
                FROM MaterialRequirement MR
                INNER JOIN MR_Items I 
                    ON MR.MR_Id = I.MR_Id
                WHERE MR.Project_Id = B.Project_Id
                  AND MR.MR_Type NOT IN ('S','D','C')
                  AND (
                        (@Type = 1 AND ((MR.Checked_By = @SessionUser AND MR.MR_Type = 'S') 
                                        OR (MR.Authorised_By = @SessionUser AND MR.MR_Type = 'C')))
                        OR (@Type = 0 AND MR.MR_Type NOT IN ('S','D','C'))
                        OR (@Type NOT IN (0,1))
                      )
            ),0) AS Total_Cost

        FROM BOM_MST B
        INNER JOIN M_Project P 
            ON B.Project_Id = P.Project_Id
        INNER JOIN M_Employee mat 
            ON B.Material_Deliver_to = mat.Emp_Id
        INNER JOIN M_Employee req 
            ON B.ReqRaisedBy_Id = req.Emp_Id

        WHERE B.Bom_Id = CASE 
                             WHEN @BOM_Id = 0 THEN B.Bom_Id
                             ELSE @BOM_Id
                         END

        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END;
GO


