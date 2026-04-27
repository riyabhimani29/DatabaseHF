USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetDepartmentItemCost]    Script Date: 27-04-2026 11:31:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetDepartmentItemCost]
    @Project_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- ? CTE must be declared once at top
    WITH LatestGRN AS
    (
        SELECT 
            GD.*,
            ROW_NUMBER() OVER (
                PARTITION BY GD.Item_Id 
                ORDER BY GD.GRN_Id DESC
            ) AS RN
        FROM GRN_Dtl GD
    )

    ---------------------------------------
    -- 1. MATERIAL REQUIREMENT
    ---------------------------------------
    SELECT 
        M.Project_Id,
        MP.Project_Name,
        M.Dept_ID,
        MD.Dept_Name,
        MRI.Item_Id,
        ISNULL(MI.Item_Rate, 0) AS UnitCost,
        MRI.Qty,
        MRI.Qty AS Quantity_Consumed,
        MI.Item_Name,
        MI.Item_Code,
        MM.Master_Vals

    FROM MaterialRequirement M
    INNER JOIN MR_Items MRI ON M.MR_Id = MRI.MR_Id
    INNER JOIN M_Project MP ON MP.Project_Id = M.Project_Id
    INNER JOIN M_Item MI ON MRI.Item_Id = MI.Item_Id
    INNER JOIN M_Master MM ON MI.Unit_Id = MM.Master_Id
    INNER JOIN M_Department MD ON MD.Dept_ID = M.Dept_ID

    WHERE M.Project_Id = @Project_Id 
      AND MR_Type = 'A'

    ---------------------------------------
    UNION ALL
    -- 2. DC + GRN
    ---------------------------------------
    SELECT 
        DM.Project_Id,
        MP.Project_Name,
        MD.Dept_ID,
        MD.Dept_Name,
        DCD.Item_Id,
        ISNULL(MI.Item_Rate, 0) AS UnitCost,
        ISNULL(DCD.DC_Qty, 0) AS Qty,
        ISNULL(LG.TotalWeight, 0) AS Quantity_Consumed,
        MI.Item_Name,
        MI.Item_Code,
        MM.Master_Vals

    FROM DC_MST DM
    INNER JOIN DC_DTL DCD ON DM.DC_Id = DCD.DC_Id
    INNER JOIN GRN_Mst GM ON GM.PO_Id = DCD.DC_Id AND GM.GRN_Type = 'DC-GRN'
    INNER JOIN LatestGRN LG 
        ON LG.GRN_Id = GM.GRN_Id 
       AND LG.Item_Id = DCD.Item_Id
       AND LG.RN = 1
    INNER JOIN M_Project MP ON MP.Project_Id = DM.Project_Id
    INNER JOIN M_Item MI ON DCD.Item_Id = MI.Item_Id
    INNER JOIN M_Master MM ON MI.Unit_Id = MM.Master_Id
    INNER JOIN M_Department MD ON MD.Dept_ID = DM.Dept_ID

    WHERE DM.Project_Id = @Project_Id
      AND CODC_Type = 'F'

    ---------------------------------------
    UNION ALL
    -- 3. GLASS OUTWARD (PO)
    ---------------------------------------
    SELECT 
        PD.Project_Id,
        MP.Project_Name,
        PM.Dept_Id,
        MD.Dept_Name,
        PD.Item_Id,
        ISNULL(MI.Item_Rate, 0) AS UnitCost,
        ISNULL(PD.OrderQty, 0) AS Qty,
        ISNULL(GD.TotalWeight, 0) AS Quantity_Consumed,  -- ? FIXED
        MI.Item_Name,
        MI.Item_Code,
        MM.Master_Vals

    FROM PO_MST PM
    INNER JOIN PO_DTL PD ON PM.PO_ID = PD.PO_ID
    INNER JOIN M_Project MP ON MP.Project_Id = PD.Project_Id
    INNER JOIN M_Item MI ON PD.Item_Id = MI.Item_Id
    INNER JOIN M_Master MM ON MI.Unit_Id = MM.Master_Id
    INNER JOIN M_Department MD ON MD.Dept_ID = PM.Dept_Id

    LEFT JOIN GRN_MST GM ON GM.PO_ID = PM.PO_ID AND GM.GRN_Type = 'GRN-OUT'
    LEFT JOIN GRN_DTL GD ON GD.GRN_ID = GM.GRN_ID AND GD.Item_Id = PD.Item_Id

    WHERE PD.Project_Id = @Project_Id
      AND PM.Dept_Id = 3

    ---------------------------------------
    UNION ALL
    -- 4. SAFETY TOOLS
    ---------------------------------------
    SELECT 
        SFTD.Project_Id,
        MP.Project_Name,
        1012 AS Dept_Id,   -- ? explicit instead of fake join
        MD.Dept_Name,
        SFTD.[ItemId ],
        ISNULL(MI.Item_Rate, 0) AS UnitCost,
        ISNULL(SFTD.OutwardQty, 0) AS Qty,
        ISNULL(SFTD.OutwardQty, 0) AS Quantity_Consumed,  -- ? FIXED
        MI.Item_Name,
        MI.Item_Code,
        MM.Master_Vals

    FROM safetytools_outward_Dtl SFTD
    INNER JOIN M_Project MP ON MP.Project_Id = SFTD.Project_Id
    INNER JOIN M_Item MI ON SFTD.[ItemId ]= MI.Item_Id
    INNER JOIN M_Master MM ON MI.Unit_Id = MM.Master_Id
    INNER JOIN M_Department MD ON MD.Dept_ID = 1012

    WHERE SFTD.Project_Id = @Project_Id
      AND SFTD.issue_type = 1

    ---------------------------------------
    ORDER BY Dept_ID
END

GO


