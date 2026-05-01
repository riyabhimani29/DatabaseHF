USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetGlassOutwardCost]    Script Date: 27-04-2026 11:32:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[GetGlassOutwardCost]
    @Project_Id INT,
    @Dept_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH POList AS (
        SELECT DISTINCT 
            PM.PO_ID, 
            PM.Dept_Id, 
            PM.NetAmount, 
            PD.Project_Id
        FROM PO_MST PM
        INNER JOIN PO_DTL PD 
            ON PD.PO_ID = PM.PO_ID
        WHERE PD.Project_Id = @Project_Id
          AND PM.Dept_Id = @Dept_Id
         -- AND PM.Order_Type = 'GL-PO'
    ),

    OrderedCost AS (
        SELECT 
            Project_Id,
            Dept_Id,
            SUM(ISNULL(NetAmount,0)) AS Total_Ordered_Cost
        FROM POList
        GROUP BY Project_Id, Dept_Id
    ),

    FulfilledCost AS (
        SELECT 
            P.Project_Id,
            P.Dept_Id,
            SUM(ISNULL(GM.NetAmount,0)) AS Total_Fulfilled_Cost
        FROM POList P
        INNER JOIN GRN_MST GM 
            ON GM.PO_ID = P.PO_ID
        WHERE GM.GRN_Type = 'GRN-OUT'
        GROUP BY P.Project_Id, P.Dept_Id
    ),

    TotalQty AS (
        SELECT 
            PD.Project_Id,
            PM.Dept_Id,
            SUM(ISNULL(PD.OrderQty,0)) AS Total_Quantity
        FROM PO_DTL PD
        INNER JOIN PO_MST PM 
            ON PM.PO_ID = PD.PO_ID
        WHERE PD.Project_Id = @Project_Id
          AND PM.Dept_Id = @Dept_Id
        GROUP BY PD.Project_Id, PM.Dept_Id
    ),

    IssuedQty AS (
        SELECT 
            P.Project_Id,
            P.Dept_Id,
            SUM(ISNULL(GD.ReceiveQty,0)) AS Issued_Quantity
        FROM POList P
        INNER JOIN GRN_MST GM 
            ON GM.PO_ID = P.PO_ID
        INNER JOIN GRN_DTL GD 
            ON GD.GRN_ID = GM.GRN_ID
        WHERE GM.GRN_Type = 'GRN-OUT'
        GROUP BY P.Project_Id, P.Dept_Id
    )

    SELECT 
        OC.Project_Id,
        OC.Dept_Id,

        OC.Total_Ordered_Cost,
        ISNULL(FC.Total_Fulfilled_Cost, 0) AS Total_Fulfilled_Cost,

        ISNULL(TQ.Total_Quantity, 0) AS Total_Qty,
        ISNULL(IQ.Issued_Quantity, 0) AS Issued_Qty

    FROM OrderedCost OC
    LEFT JOIN FulfilledCost FC
        ON OC.Project_Id = FC.Project_Id
       AND OC.Dept_Id = FC.Dept_Id

    LEFT JOIN TotalQty TQ
        ON OC.Project_Id = TQ.Project_Id
       AND OC.Dept_Id = TQ.Dept_Id

    LEFT JOIN IssuedQty IQ
        ON OC.Project_Id = IQ.Project_Id
       AND OC.Dept_Id = IQ.Dept_Id;

END


GO


