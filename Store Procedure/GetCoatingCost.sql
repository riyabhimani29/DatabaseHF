USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetCoatingCost]    Script Date: 27-04-2026 11:30:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[GetCoatingCost]
    @Project_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        DM.Project_Id,

       
        SUM(ISNULL(DM.NetAmount, 0)) AS Total_Ordered_Cost,

        ISNULL(SUM(GM.NetAmount), 0) AS Total_Fulfilled_Cost,

        ISNULL(SUM(DD.Total_Qty), 0) AS Total_Qty,

        ISNULL(SUM(GD.Issued_Qty), 0) AS Issued_Qty

    FROM DC_MST DM

    LEFT JOIN (
        SELECT 
            DC_Id,
            SUM(DC_Qty) AS Total_Qty
        FROM DC_DTL
        GROUP BY DC_Id
    ) DD ON DD.DC_Id = DM.DC_Id

    LEFT JOIN GRN_MST GM 
        ON GM.PO_ID = DM.DC_Id
       AND GM.GRN_Type = 'DC-GRN'

    LEFT JOIN (
        SELECT 
            GRN_ID,
            SUM(ReceiveQty) AS Issued_Qty
        FROM GRN_DTL
        GROUP BY GRN_ID
    ) GD ON GD.GRN_ID = GM.GRN_ID

    WHERE DM.Project_Id = @Project_Id

    GROUP BY DM.Project_Id;

END

GO


