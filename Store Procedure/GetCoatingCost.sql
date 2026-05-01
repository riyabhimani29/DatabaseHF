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

        ISNULL(SUM(GD.Issued_Qty), 0) AS Issued_Qty,

       ISNULL(SUM(
            ISNULL(MV.Total_Material_Value, 0) +
            CASE 
                WHEN ISNULL(DM.IGST_MVTotal, 0) <> 0 
                    THEN ISNULL(DM.IGST_MVTotal, 0)
                ELSE ISNULL(DM.CGST_MVTotal, 0) + ISNULL(DM.SGST_MVTotal, 0)
            END
        ), 0) AS Total_Ordered_Material_Cost,

             ISNULL(SUM(
    ISNULL(GMV.Total_GRN_Material_Value, 0) +

    ISNULL(GMV.Total_GRN_Material_Value, 0) *
    (
        CASE 
            WHEN ISNULL(GM.IGST, 0) <> 0
                THEN ISNULL(TRY_CAST(IGST.Master_NumVals AS DECIMAL(18,2)), 0)
            ELSE 
                ISNULL(TRY_CAST(CGST.Master_NumVals AS DECIMAL(18,2)), 0) + 
                ISNULL(TRY_CAST(SGST.Master_NumVals AS DECIMAL(18,2)), 0)
        END
    ) 
), 0) AS Total_Fulfilled_Material_Cost

    FROM DC_MST DM

    LEFT JOIN (
        SELECT 
            DC_Id,
            SUM(DC_Qty) AS Total_Qty
        FROM DC_DTL
        GROUP BY DC_Id
    ) DD ON DD.DC_Id = DM.DC_Id

        LEFT JOIN (
        SELECT 
            DC_Id,
            SUM(ISNULL(Material_Value, 0)) AS Total_Material_Value
        FROM DC_DTL
        GROUP BY DC_Id
    ) MV ON MV.DC_Id = DM.DC_Id


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

    --GRN Material Value
    LEFT JOIN (
        SELECT 
            GRN_ID,
            SUM(ISNULL(Material_Value, 0)) AS Total_GRN_Material_Value
        FROM GRN_DTL
        GROUP BY GRN_ID
    ) GMV ON GMV.GRN_ID = GM.GRN_ID

    LEFT JOIN M_MASTER SGST 
        ON SGST.master_id = GM.SGST
    LEFT JOIN M_MASTER CGST 
        ON CGST.master_id = GM.CGST
    LEFT JOIN M_MASTER IGST 
        ON IGST.master_id = GM.IGST


    WHERE DM.Project_Id = @Project_Id
          AND DM.CODC_Type = 'F'

    GROUP BY DM.Project_Id;

END