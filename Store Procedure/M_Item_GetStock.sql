USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetStock]    Script Date: 27-04-2026 12:21:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[M_Item_GetStock] @Dept_ID       INT = 1,  
                                         @Item_Group_Id INT =0,  
                                         @Item_Cate_Id  INT =0,  
  
                                         --@Supplier_Id int =0,                                                                           
                                         @Godown_Id     INT =0,  
                                         @Type          INT = 0,  
                                         @SType         CHAR='N',
                                         @ViewType VARCHAR(10) = 'D',
                                         @FilterDate    DATE = '9999-12-31'

AS  
    SET nocount ON  
IF ( @ViewType = 'S' )
BEGIN

     if ( @Type = 1 )
BEGIN
 SELECT
    StockView.id,
    StockView.Godown_Id,
    m_godown.godown_name,
    m_item.item_group_id,
    m_item_group.item_group_name,
    m_item.item_cate_id,
    m_item_category.item_cate_name,
    StockView.item_id,
    m_item.item_name AS [Description],
    m_item.item_code,
    m_item.hsn_code,
    StockView.total_qty,
    StockView.sales_qty,
    StockView.Freeze_Qty,
    M_Item.Avg_Cost as AverageCost,
    /* Adjusted Pending Qty */
    CASE
        WHEN @FilterDate <> '9999-12-31'
        THEN
            CASE
                WHEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0) 
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0) < 0
                THEN 0
                ELSE    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0) 
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
            END
        ELSE StockView.pending_qty
    END AS pending_qty,

    StockView.[length],
    Tbl_Unit.master_vals AS UnitName,
    m_item.unit_id,

    CASE
        WHEN StockView.stype = 'C' THEN 'Coated'
        ELSE 'Non-Coated'
    END AS SType,

    m_item.total_parameter,
    m_item.coated_area,
    m_item.noncoated_area,
    m_item.calc_area,
    m_item.weight_mtr,
    m_item.ImageName,
    StockView.lastupdate,
    ISNULL(m_item.thickness,0) AS thickness,
    KK.field_id,

    /* Total Weight */
    CONVERT(NUMERIC(18,2),
    (
        CASE
            WHEN KK.field_id IS NOT NULL
            THEN
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                             WHEN @FilterDate <> '9999-12-31'
                            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) 
            + ISNULL(CoatdcOut.CoatdcOutQty,0) - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                    * ISNULL(m_item.thickness,0)
                ) / 1000
            ELSE
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                           WHEN @FilterDate <> '9999-12-31'
                            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) 
            + ISNULL(CoatdcOut.CoatdcOutQty,0) - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                ) / 1000
        END
    )) AS TotalWeight,

    m_item.item_group_id,
    StockView.Width,
    StockView.RackNo,
    StockView.Remark,
    M_Godown_Rack.Rack_Name,
    StockView.Rack_Id,

    /* Area */
    CASE
        WHEN @Dept_ID = 3
        THEN CONVERT(NUMERIC(18,2),
            (
                ISNULL(StockView.Width,0)
                * ISNULL(StockView.[length],0)
                * ISNULL(
                    CASE
                        WHEN @FilterDate <> '9999-12-31'
                        THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)
             - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0)
             - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                        ELSE StockView.pending_qty
                    END,0
                )
            ) / 1000000
        )
        ELSE 0
    END AS Area,

    '' AS Project_Name,
    M_Item.Alternate_Unit_Id,
    M_Item.AlternateUnitValue,
    unit.Master_Vals AS unit,
    alternate_unit.Master_Vals AS alternate_unit,
    Stk_Limit,
    CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate
    --M_Item.Item_Rate AS Rate

FROM StockView WITH (NOLOCK)

LEFT JOIN m_godown WITH (NOLOCK)
    ON StockView.godown_id = m_godown.godown_id

LEFT JOIN M_Godown_Rack WITH (NOLOCK)
    ON StockView.Rack_Id = M_Godown_Rack.Rack_Id

LEFT JOIN m_item WITH (NOLOCK)
    ON StockView.item_id = m_item.item_id

LEFT JOIN M_Master AS unit
    ON m_item.Unit_Id = unit.Master_Id

LEFT JOIN M_Master AS alternate_unit
    ON m_item.Alternate_Unit_Id = alternate_unit.Master_Id

LEFT JOIN m_item_group WITH (NOLOCK)
    ON m_item.item_group_id = m_item_group.item_group_id

OUTER APPLY
(
    SELECT m_group_field_setting.field_id
    FROM m_group_field_setting WITH (NOLOCK)
    WHERE m_group_field_setting.field_id = 1
      AND m_item.item_group_id = m_group_field_setting.item_group_id
) AS KK

LEFT JOIN m_item_category WITH (NOLOCK)
    ON m_item.item_cate_id = m_item_category.item_cate_id

LEFT JOIN m_master AS Tbl_Unit WITH (NOLOCK)
    ON m_item.unit_id = Tbl_Unit.master_id

/* Opening Stock History Adjustment */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(OSH.Total_Qty,0)) AS OpeningQtyAfterDate
    FROM OpeningStock_History OSH WITH (NOLOCK)
    WHERE OSH.Item_Id   = StockView.item_id
      AND OSH.Godown_Id = StockView.godown_id
      AND OSH.SType     = StockView.stype
      AND ISNULL(OSH.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(OSH.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(OSH.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)
      AND CAST(OSH.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS OS
/* GRN Adjustment */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(GD.ReceiveQty,0)) AS GRNReceivedQtyAfterDate
    FROM GRN_DTL GD WITH (NOLOCK)
    INNER JOIN GRN_MST GM WITH (NOLOCK)
        ON GD.GRN_Id = GM.GRN_Id
    WHERE GD.Item_Id   = StockView.item_id
      AND GM.Godown_Id = StockView.godown_id
      AND GD.SType     = StockView.stype
      AND ISNULL(GD.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(GD.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(GD.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)
      AND CAST(GM.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS GRN
/* Transfer IN (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS TransferInQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.Stock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'G_TO_G'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS TR_IN
/* Transfer OUT (Destination NewStock_Id matches) */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(STD.Qty,0)) AS TransferOutQty
    FROM StockTrans_Dtl STD WITH (NOLOCK)
    INNER JOIN StockView SV WITH (NOLOCK)
        ON SV.id = STD.NewStock_Id
    INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
        ON STD.TransId = STM.TransId
    WHERE STM.Trans_Type = 'G_TO_G'
      AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
      AND STD.Item_Id = StockView.item_id
      AND STD.To_Godown_Id = StockView.godown_id
      AND STD.ToRack_Id = StockView.Rack_Id
      AND ISNULL(SV.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(SV.Width,0)  = ISNULL(StockView.Width,0)
) AS TR_OUT
/* Transfer IN (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS TransferPdQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.Stock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'TO_PROD'
AND CAST(STM.TransDate AS DATE) >  @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS PD_IN
/* InternalTransfer T_to_H (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS InternalTransferOutQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.NewStock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'T_To_H'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS Int_TR_Out
/* InternalTransfer H_to_T (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS InternalTransferInQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.NewStock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'H_To_T'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.To_Godown_Id = StockView.godown_id
AND STD.TORack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS Int_TR_In
/* coatdc sales qty(inc) pending qty dec */
OUTER APPLY
(
SELECT
SUM(ISNULL(DCD.Qty,0)) AS CoatdcOutQty
FROM DC_Dtl DCD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id = DCD.Stock_Id
INNER JOIN DC_Mst DCM WITH (NOLOCK)
ON DCD.DC_Id = DCM.DC_Id
WHERE DCM.CODC_Type = 'F'
AND CAST(DCM.DC_Date AS DATE) >   @FilterDate --'2025-12-22'
AND DCD.Item_Id = StockView.item_id
AND SV.godown_id = StockView.godown_id
AND SV.Rack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS CoatdcOut
/* coatdc scrap qty, pending qty (inc) */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(DCD.Scrap_Qty, 0)) AS ScrapPendingAddedQty
    FROM DC_Dtl DCD WITH (NOLOCK)
    INNER JOIN DC_Mst DCM WITH (NOLOCK)
        ON DCD.DC_Id = DCM.DC_Id
    INNER JOIN StockView SV WITH (NOLOCK)
        ON SV.Id = DCD.Stock_Id
    CROSS APPLY
    (
        SELECT ISNULL(master_numvals, 0) AS ScrapLimit
        FROM M_Master WITH (NOLOCK)
        WHERE Master_Type = 'SCRAP'
          AND Is_Active = 1
    ) SM
    WHERE DCM.CODC_Type = 'F'
      AND CAST(DCM.DC_Date AS DATE) > @FilterDate --'2025-12-15'-- @FilterDate

      -- same stock identity match
      AND DCD.Item_Id   = StockView.Item_Id
      AND SV.Godown_Id  = StockView.Godown_Id
      AND SV.Rack_Id    = StockView.Rack_Id
      AND ISNULL(DCD.Scrap_Length,0) = ISNULL(StockView.Length,0)
      AND ISNULL(SV.Width,0)  = ISNULL(StockView.Width,0)

      -- IMPORTANT: only when scrap goes into Pending_Qty
      AND NOT (SM.ScrapLimit > 0 AND SM.ScrapLimit > ISNULL(DCD.Scrap_Length,0))
) AS ScrapPendOut
/* Glass Outwards */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(GD.ReceiveQty,0)) AS GLSOutwardsqty
    FROM GRN_DTL GD WITH (NOLOCK)
    INNER JOIN GRN_MST GM WITH (NOLOCK)
        ON GD.GRN_Id = GM.GRN_Id
     INNER JOIN GlassQR_Dtl GQR WITH (NOLOCK)
        ON GQR.GrnDtl_Id = GD.GrnDtl_Id
    WHERE GQR.Item_Id   = StockView.item_id
      AND GM.Godown_Id = StockView.godown_id
      AND GD.SType     = StockView.stype
      AND GQR.Is_out = 1
      AND ISNULL(GD.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(GD.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(GD.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)

      AND CAST(GM.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS GLSOutwards
/* BOM item Issued */
OUTER APPLY
(
    SELECT
        SUM(
            TRY_CAST(
                LTRIM(RTRIM(
                    SUBSTRING(
                        BL.Action_Details,
                        CHARINDEX('with', BL.Action_Details) + LEN('with'),
                        CHARINDEX('items', BL.Action_Details) -
                        (CHARINDEX('with', BL.Action_Details) + LEN('with'))
                    )
                )) AS INT
            )
        ) AS BOMIssuedQty
    FROM BOM_Logs BL WITH (NOLOCK)

    INNER JOIN MaterialRequirement MR WITH (NOLOCK)
        ON MR.Project_Id = BL.Project_Id

    INNER JOIN MR_Items MRI WITH (NOLOCK)
        ON MRI.MR_Id = MR.MR_Id

    INNER JOIN M_Item MI WITH (NOLOCK)
        ON MI.Item_Id = MRI.Item_Id

    WHERE BL.Process_Type = 'Issue'
      AND CAST(BL.Entry_Date AS DATE) > @FilterDate --'2025-12-22' -- @FilterDate

      -- Stock identity match
      AND MRI.Item_Id = StockView.Item_Id
        AND MRI.Godown_Id  = StockView.Godown_Id
      AND MRI.Godown_Rack_Id    = StockView.Rack_Id
      AND ISNULL(MRI.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(MRI.Length,0) = ISNULL(StockView.Length,0)
) BOMIssued

WHERE
    StockView.item_id <> 0
    AND
    (
        CASE
             WHEN @FilterDate <> '9999-12-31'
            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)
            - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0)
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
            ELSE StockView.pending_qty
        END
    ) <= 0
    AND m_item_group.dept_id =
        CASE
            WHEN @Dept_ID = 0 THEN m_item_group.dept_id
            ELSE @Dept_ID
        END
    AND StockView.godown_id =
        CASE
            WHEN @Godown_Id = 0 THEN StockView.godown_id
            ELSE @Godown_Id
        END
    AND StockView.stype =
        CASE
            WHEN @SType = 'A' THEN StockView.stype
            ELSE @SType
        END;
END
ELSE
BEGIN
   SELECT
    StockView.id,
    StockView.Godown_Id,
    m_godown.godown_name,
    m_item.item_group_id,
    m_item_group.item_group_name,
    m_item.item_cate_id,
    m_item_category.item_cate_name,
    StockView.item_id,
    m_item.item_name AS [Description],
    m_item.item_code,
    m_item.hsn_code,
    StockView.total_qty,
    StockView.sales_qty,
    StockView.Freeze_Qty,
    M_Item.Avg_Cost as AverageCost,
    /* Adjusted Pending Qty */
    CASE
        WHEN @FilterDate <> '9999-12-31'
        THEN
            CASE
                WHEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0) 
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0) < 0
                THEN 0
                ELSE    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0) 
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
            END
        ELSE StockView.pending_qty
    END AS pending_qty,

    StockView.[length],
    Tbl_Unit.master_vals AS UnitName,
    m_item.unit_id,

    CASE
        WHEN StockView.stype = 'C' THEN 'Coated'
        ELSE 'Non-Coated'
    END AS SType,

    m_item.total_parameter,
    m_item.coated_area,
    m_item.noncoated_area,
    m_item.calc_area,
    m_item.weight_mtr,
    m_item.ImageName,
    StockView.lastupdate,
    ISNULL(m_item.thickness,0) AS thickness,
    KK.field_id,

    /* Total Weight */
    CONVERT(NUMERIC(18,2),
    (
        CASE
            WHEN KK.field_id IS NOT NULL
            THEN
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                             WHEN @FilterDate <> '9999-12-31'
                            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) 
            + ISNULL(CoatdcOut.CoatdcOutQty,0) - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                    * ISNULL(m_item.thickness,0)
                ) / 1000
            ELSE
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                           WHEN @FilterDate <> '9999-12-31'
                            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)  - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) 
            + ISNULL(CoatdcOut.CoatdcOutQty,0) - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                ) / 1000
        END
    )) AS TotalWeight,

    m_item.item_group_id,
    StockView.Width,
    StockView.RackNo,
    StockView.Remark,
    M_Godown_Rack.Rack_Name,
    StockView.Rack_Id,

    /* Area */
    CASE
        WHEN @Dept_ID = 3
        THEN CONVERT(NUMERIC(18,2),
            (
                ISNULL(StockView.Width,0)
                * ISNULL(StockView.[length],0)
                * ISNULL(
                    CASE
                        WHEN @FilterDate <> '9999-12-31'
                        THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)
             - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0)
             - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
                        ELSE StockView.pending_qty
                    END,0
                )
            ) / 1000000
        )
        ELSE 0
    END AS Area,

    '' AS Project_Name,
    M_Item.Alternate_Unit_Id,
    M_Item.AlternateUnitValue,
    unit.Master_Vals AS unit,
    alternate_unit.Master_Vals AS alternate_unit,
    Stk_Limit,
       CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate
    

FROM StockView WITH (NOLOCK)

LEFT JOIN m_godown WITH (NOLOCK)
    ON StockView.godown_id = m_godown.godown_id

LEFT JOIN M_Godown_Rack WITH (NOLOCK)
    ON StockView.Rack_Id = M_Godown_Rack.Rack_Id

LEFT JOIN m_item WITH (NOLOCK)
    ON StockView.item_id = m_item.item_id

LEFT JOIN M_Master AS unit
    ON m_item.Unit_Id = unit.Master_Id

LEFT JOIN M_Master AS alternate_unit
    ON m_item.Alternate_Unit_Id = alternate_unit.Master_Id

LEFT JOIN m_item_group WITH (NOLOCK)
    ON m_item.item_group_id = m_item_group.item_group_id

OUTER APPLY
(
    SELECT m_group_field_setting.field_id
    FROM m_group_field_setting WITH (NOLOCK)
    WHERE m_group_field_setting.field_id = 1
      AND m_item.item_group_id = m_group_field_setting.item_group_id
) AS KK

LEFT JOIN m_item_category WITH (NOLOCK)
    ON m_item.item_cate_id = m_item_category.item_cate_id

LEFT JOIN m_master AS Tbl_Unit WITH (NOLOCK)
    ON m_item.unit_id = Tbl_Unit.master_id

/* Opening Stock History Adjustment */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(OSH.Total_Qty,0)) AS OpeningQtyAfterDate
    FROM OpeningStock_History OSH WITH (NOLOCK)
    WHERE OSH.Item_Id   = StockView.item_id
      AND OSH.Godown_Id = StockView.godown_id
      AND OSH.SType     = StockView.stype
      AND ISNULL(OSH.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(OSH.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(OSH.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)
      AND CAST(OSH.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS OS
/* GRN Adjustment */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(GD.ReceiveQty,0)) AS GRNReceivedQtyAfterDate
    FROM GRN_DTL GD WITH (NOLOCK)
    INNER JOIN GRN_MST GM WITH (NOLOCK)
        ON GD.GRN_Id = GM.GRN_Id
    WHERE GD.Item_Id   = StockView.item_id
      AND GM.Godown_Id = StockView.godown_id
      AND GD.SType     = StockView.stype
      AND ISNULL(GD.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(GD.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(GD.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)
      AND CAST(GM.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS GRN
/* Transfer IN (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS TransferInQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.Stock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'G_TO_G'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS TR_IN
/* Transfer OUT (Destination NewStock_Id matches) */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(STD.Qty,0)) AS TransferOutQty
    FROM StockTrans_Dtl STD WITH (NOLOCK)
    INNER JOIN StockView SV WITH (NOLOCK)
        ON SV.id = STD.NewStock_Id
    INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
        ON STD.TransId = STM.TransId
    WHERE STM.Trans_Type = 'G_TO_G'
      AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
      AND STD.Item_Id = StockView.item_id
      AND STD.To_Godown_Id = StockView.godown_id
      AND STD.ToRack_Id = StockView.Rack_Id
      AND ISNULL(SV.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(SV.Width,0)  = ISNULL(StockView.Width,0)
) AS TR_OUT
/* Transfer IN (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS TransferPdQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.Stock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'TO_PROD'
AND CAST(STM.TransDate AS DATE) >  @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS PD_IN
/* InternalTransfer T_to_H (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS InternalTransferOutQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.NewStock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'T_To_H'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.Fr_Godown_Id = StockView.godown_id
AND STD.FrRack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS Int_TR_Out
/* InternalTransfer H_to_T (Source Stock_Id matches) */
OUTER APPLY
(
SELECT
SUM(ISNULL(STD.Qty,0)) AS InternalTransferInQty
FROM StockTrans_Dtl STD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id =STD.NewStock_Id
INNER JOIN StockTrans_Mst STM WITH (NOLOCK)
ON STD.TransId = STM.TransId
WHERE STM.Trans_Type = 'H_To_T'
AND CAST(STM.TransDate AS DATE) > @FilterDate --'2025-12-22'
AND STD.Item_Id = StockView.item_id
AND STD.To_Godown_Id = StockView.godown_id
AND STD.TORack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS Int_TR_In
/* coatdc sales qty(inc) pending qty dec */
OUTER APPLY
(
SELECT
SUM(ISNULL(DCD.Qty,0)) AS CoatdcOutQty
FROM DC_Dtl DCD WITH (NOLOCK)
INNER JOIN StockView SV WITH (NOLOCK)
ON SV.id = DCD.Stock_Id
INNER JOIN DC_Mst DCM WITH (NOLOCK)
ON DCD.DC_Id = DCM.DC_Id
WHERE DCM.CODC_Type = 'F'
AND CAST(DCM.DC_Date AS DATE) >   @FilterDate --'2025-12-22'
AND DCD.Item_Id = StockView.item_id
AND SV.godown_id = StockView.godown_id
AND SV.Rack_Id = StockView.Rack_Id
AND ISNULL( SV.Length,0) = ISNULL(StockView.[length],0)
AND ISNULL( SV.Width,0) = ISNULL(StockView.Width,0)
) AS CoatdcOut
/* coatdc scrap qty, pending qty (inc) */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(DCD.Scrap_Qty, 0)) AS ScrapPendingAddedQty
    FROM DC_Dtl DCD WITH (NOLOCK)
    INNER JOIN DC_Mst DCM WITH (NOLOCK)
        ON DCD.DC_Id = DCM.DC_Id
    INNER JOIN StockView SV WITH (NOLOCK)
        ON SV.Id = DCD.Stock_Id
    CROSS APPLY
    (
        SELECT ISNULL(master_numvals, 0) AS ScrapLimit
        FROM M_Master WITH (NOLOCK)
        WHERE Master_Type = 'SCRAP'
          AND Is_Active = 1
    ) SM
    WHERE DCM.CODC_Type = 'F'
      AND CAST(DCM.DC_Date AS DATE) > @FilterDate --'2025-12-15'-- @FilterDate

      -- same stock identity match
      AND DCD.Item_Id   = StockView.Item_Id
      AND SV.Godown_Id  = StockView.Godown_Id
      AND SV.Rack_Id    = StockView.Rack_Id
      AND ISNULL(DCD.Scrap_Length,0) = ISNULL(StockView.Length,0)
      AND ISNULL(SV.Width,0)  = ISNULL(StockView.Width,0)

      -- IMPORTANT: only when scrap goes into Pending_Qty
      AND NOT (SM.ScrapLimit > 0 AND SM.ScrapLimit > ISNULL(DCD.Scrap_Length,0))
) AS ScrapPendOut
/* Glass Outwards */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(GD.ReceiveQty,0)) AS GLSOutwardsqty
    FROM GRN_DTL GD WITH (NOLOCK)
    INNER JOIN GRN_MST GM WITH (NOLOCK)
        ON GD.GRN_Id = GM.GRN_Id
     INNER JOIN GlassQR_Dtl GQR WITH (NOLOCK)
        ON GQR.GrnDtl_Id = GD.GrnDtl_Id
    WHERE GQR.Item_Id   = StockView.item_id
      AND GM.Godown_Id = StockView.godown_id
      AND GD.SType     = StockView.stype
      AND GQR.Is_out = 1
      AND ISNULL(GD.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(GD.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(GD.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)

      AND CAST(GM.Entry_Date AS DATE) > @FilterDate --'2025-12-22'
) AS GLSOutwards
/* BOM item Issued */
OUTER APPLY
(
    SELECT
        SUM(
            TRY_CAST(
                LTRIM(RTRIM(
                    SUBSTRING(
                        BL.Action_Details,
                        CHARINDEX('with', BL.Action_Details) + LEN('with'),
                        CHARINDEX('items', BL.Action_Details) -
                        (CHARINDEX('with', BL.Action_Details) + LEN('with'))
                    )
                )) AS INT
            )
        ) AS BOMIssuedQty
    FROM BOM_Logs BL WITH (NOLOCK)

    INNER JOIN MaterialRequirement MR WITH (NOLOCK)
        ON MR.Project_Id = BL.Project_Id

    INNER JOIN MR_Items MRI WITH (NOLOCK)
        ON MRI.MR_Id = MR.MR_Id

    INNER JOIN M_Item MI WITH (NOLOCK)
        ON MI.Item_Id = MRI.Item_Id

    WHERE BL.Process_Type = 'Issue'
      AND CAST(BL.Entry_Date AS DATE) > @FilterDate --'2025-12-22' -- @FilterDate

      -- Stock identity match
      AND MRI.Item_Id = StockView.Item_Id
        AND MRI.Godown_Id  = StockView.Godown_Id
      AND MRI.Godown_Rack_Id    = StockView.Rack_Id
      AND ISNULL(MRI.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(MRI.Length,0) = ISNULL(StockView.Length,0)
) BOMIssued

WHERE
    StockView.item_id <> 0
    AND
    (
        CASE
             WHEN @FilterDate <> '9999-12-31'
            THEN    ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) - ISNULL(GRN.GRNReceivedQtyAfterDate,0)
            + ISNULL(TR_IN.TransferInQty,0) - ISNULL(TR_OUT.TransferOutQty,0) + ISNULL(PD_IN.TransferPdQty,0)
            - ISNULL(Int_TR_In.InternalTransferInQty,0) + ISNULL(Int_TR_Out.InternalTransferOutQty,0) + ISNULL(CoatdcOut.CoatdcOutQty,0)
            - ISNULL(ScrapPendOut.ScrapPendingAddedQty,0)  + ISNULL(GLSOutwards.GLSOutwardsqty,0)  + ISNULL(BOMIssued.BOMIssuedQty,0)
            ELSE StockView.pending_qty
        END
    ) > 0
    AND m_item_group.dept_id =
        CASE
            WHEN @Dept_ID = 0 THEN m_item_group.dept_id
            ELSE @Dept_ID
        END
    AND StockView.godown_id =
        CASE
            WHEN @Godown_Id = 0 THEN StockView.godown_id
            ELSE @Godown_Id
        END
    AND StockView.stype =
        CASE
            WHEN @SType = 'A' THEN StockView.stype
            ELSE @SType
        END;
    END
END




    if ( @Type = 1 ) /* Zero Stock SHow*/  
      begin   
    SELECT StockView.id,  
        StockView.Godown_Id,  
        m_godown.godown_name,  
        m_item.item_group_id,  
        m_item_group.item_group_name,  
        m_item.item_cate_id,  
        m_item_category.item_cate_name,  
        StockView.item_id,  
        m_item.item_name                    AS [Description],  
        m_item.item_code,  
        m_item.hsn_code,  
        StockView.total_qty,  
        StockView.sales_qty,  
        StockView.pending_qty,  
        StockView.[length],  
        Tbl_Unit.master_vals                AS UnitName,  
        m_item.unit_id,  
        CASE  
       WHEN StockView.stype = 'C' THEN 'Coated'  
       ELSE 'Non-Coated'  
        END                                 SType,  
        m_item.[total_parameter],  
        m_item.[coated_area],  
        m_item.[noncoated_area],  
        m_item.[calc_area],  
        m_item.[weight_mtr],  
         m_item.ImageName,
        lastupdate,  
        --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *                                     
        --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                                    
        Isnull(m_item.thickness, 0)         thickness,  
        KK.field_id,  
        convert (NUMERIC(18, 2), (( CASE  
              WHEN KK.field_id IS NOT NULL THEN ( (  
              Isnull(m_item.[weight_mtr], 0) * Isnull (StockView.[length], 0) * Isnull( StockView.pending_qty, 0) *  
              Isnull(m_item.thickness, 0) ) / 1000 )  
              /* Is Width */  
              ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
                 Isnull( StockView.[length], 0) *  
                 Isnull( StockView.pending_qty, 0)  
               ) / 1000 )  
               END ))) AS TotalWeight,  
        m_item.item_group_id,  
        StockView.Width,  
        StockView.RackNo,  
        StockView.Remark,  
        M_Godown_Rack.Rack_Name,  
        StockView.Rack_Id,  
        case  
       when @Dept_ID = 3 then convert (NUMERIC(18, 2),  
            ( Isnull(StockView.Width, 0) * Isnull(StockView.[length], 0) *  
            Isnull( StockView.pending_qty, 0) ) / 1000000)  
       /* --width * heigth * quantity  */  
       else 0  
        end                                 Area,  
        Tbl_Stk.Project_Name  ,
        M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        StockView.Freeze_Qty,
           CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate,
        M_Item.Avg_Cost as AverageCost
    FROM   StockView WITH (nolock)  
        outer apply (select distinct GRN_Dtl.Stock_Id,  
             M_Project.Project_Name  
         from   GRN_Dtl  
             left join PO_DTL WITH (nolock) On GRN_Dtl.PODtl_Id = PO_DTL.PODtl_Id  
             left join PO_MST WITH (nolock) On PO_DTL.PO_Id = PO_MST.PO_Id  
             left join M_Project WITH (nolock) On PO_DTL.Project_Id = M_Project.Project_Id  
         where  GRN_Dtl.Stock_Id = StockView.Id  
             and PO_MST.Dept_ID = 3  
           /* Only glass  Dept */  
           )as Tbl_Stk  
        LEFT JOIN m_godown WITH (nolock) ON StockView.godown_id = m_godown.godown_id  
        LEFT JOIN M_Godown_Rack WITH (nolock) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id  
        LEFT JOIN m_item WITH (nolock) ON StockView.item_id = m_item.item_id 
             LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
        LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
        OUTER apply (SELECT m_group_field_setting.field_id  
         FROM   m_group_field_setting WITH (nolock)  
         WHERE  m_group_field_setting.field_id = 1  
             --  Only 'Width' Entry                       
             AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK  
        LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
        LEFT JOIN m_master AS Tbl_Unit WITH (nolock) ON m_item.unit_id = Tbl_Unit.master_id  
    WHERE  StockView.pending_qty <= 0  
        AND StockView.item_id <> 0  
        --  StockView.pending_qty <> 0                             
        and m_item_group.dept_id = ( CASE  
               WHEN @Dept_ID = 0 THEN  m_item_group.dept_id  
               ELSE @Dept_ID  
             END )  
        AND StockView.godown_id = ( CASE  
              WHEN @Godown_Id = 0 THEN StockView.godown_id  
              ELSE @Godown_Id  
               END )  
        AND StockView.stype = ( CASE  
             WHEN @SType = 'A' THEN StockView.stype  
             ELSE @SType  
              END )   
      --  ORDER  BY LastUpdate DESC--m_item.item_code           
      end  
    else if ( @Type = -1 ) /* All Stock SHow*/  
      begin   
   SELECT StockView.id,  
     StockView.Godown_Id,  
     m_godown.godown_name,  
     m_item.item_group_id,  
     m_item_group.item_group_name,  
     m_item.item_cate_id,  
     m_item_category.item_cate_name,  
     StockView.item_id,  
     m_item.item_name                    AS [Description],  
     m_item.item_code,  
     m_item.hsn_code,  
     StockView.total_qty,  
     StockView.sales_qty,  
     CASE 
            WHEN (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0)) < 0 
                THEN 0
            ELSE (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0))
        END AS pending_qty,  
     StockView.[length],  
     Tbl_Unit.master_vals                AS UnitName,  
     m_item.unit_id,  
     CASE  
      WHEN StockView.stype = 'C' THEN 'Coated'  
      ELSE 'Non-Coated'  
     END                                 SType,  
     m_item.[total_parameter],  
     m_item.[coated_area],  
     m_item.[noncoated_area],  
     m_item.[calc_area],  
     m_item.[weight_mtr],
     m_item.ImageName,
     lastupdate,  
     --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *                                     
     --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                                    
     Isnull(m_item.thickness, 0)         thickness,  
     KK.field_id,  
     convert (NUMERIC(18, 2), (( CASE  
             WHEN KK.field_id IS NOT NULL THEN ( (  
             Isnull(m_item.[weight_mtr], 0) * Isnull  
             (StockView.[length], 0) * Isnull (  
             StockView.pending_qty, 0) *  
             Isnull(m_item.thickness, 0) ) / 1000 )  
             /* Is Width */  
             ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
               Isnull( StockView.[length], 0) *  
               Isnull( StockView.pending_qty, 0)  
              ) /  
              1000 )  
            END ))) AS TotalWeight,  
     m_item.item_group_id,  
     StockView.Width,  
     StockView.RackNo,  
     StockView.Remark,  
     M_Godown_Rack.Rack_Name,  
     StockView.Rack_Id,  
     case  
      when @Dept_ID = 3 then convert (NUMERIC(18, 2),  
           ( Isnull(StockView.Width, 0) * Isnull(StockView.[length], 0) *  
            Isnull( StockView.pending_qty, 0) ) / 1000000)  
      /* --width * heigth * quantity */  
      else 0  
     end                                 AS Area,  
     ''                                  AS Project_Name  ,
     M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        StockView.Freeze_Qty,
           CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate,
        M_Item.Avg_Cost as AverageCost
   --Tbl_Stk.Project_Name    
   FROM   StockView WITH (nolock)   
     LEFT JOIN m_godown WITH (nolock) ON StockView.godown_id = m_godown.godown_id  
     LEFT JOIN M_Godown_Rack WITH (nolock) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id  
     LEFT JOIN m_item WITH (nolock) ON StockView.item_id = m_item.item_id  
          LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
     LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
     OUTER apply (SELECT m_group_field_setting.field_id  
        FROM   m_group_field_setting WITH (nolock)  
        WHERE  m_group_field_setting.field_id = 1  
          /*--  Only 'Width' Entry */  
          AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK  
     LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
     LEFT JOIN m_master AS Tbl_Unit WITH (nolock) ON m_item.unit_id = Tbl_Unit.master_id  
   WHERE   StockView.item_id <> 0  
     AND StockView.pending_qty >= 0                             
     and m_item_group.dept_id = ( CASE  
             WHEN @Dept_ID = 0 THEN m_item_group.dept_id  
             ELSE @Dept_ID  
            END )  
     AND StockView.godown_id = ( CASE  
             WHEN @Godown_Id = 0 THEN StockView.godown_id  
             ELSE @Godown_Id  
            END )  
     AND StockView.stype = ( CASE  
            WHEN @SType = 'A' THEN StockView.stype  
            ELSE @SType  
           END )         
      end  
    else  
      begin  
          if ( @Dept_ID = 3 ) /* Glass Department */  
            begin  
    SELECT stockview.id,  
        stockview.godown_id,  
        m_godown.godown_name,  
        m_item.item_group_id,  
        m_item_group.item_group_name,  
        m_item.item_cate_id,  
        m_item_category.item_cate_name,  
        stockview.item_id,  
        m_item.item_name                    AS [Description],  
        m_item.item_code,  
        m_item.hsn_code,  
        stockview.total_qty,  
        stockview.sales_qty,  
        CASE 
            WHEN (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0)) < 0 
                THEN 0
            ELSE (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0))
        END AS pending_qty,  
        stockview.[length],  
        tbl_unit.master_vals                AS unitname,  
        m_item.unit_id,  
        CASE  
       WHEN stockview.stype = 'C' THEN 'Coated'  
       ELSE 'Non-Coated'  
        END                                 stype,  
        m_item.[total_parameter],  
        m_item.[coated_area],  
        m_item.[noncoated_area],  
        m_item.[calc_area],  
        m_item.[weight_mtr], 
        m_item.ImageName,
        lastupdate,  
        --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *  
        --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,  
        Isnull(m_item.thickness, 0)         thickness,  
        kk.field_id,  
        CONVERT (NUMERIC(18, 2), (( CASE  
              WHEN kk.field_id IS NOT NULL THEN ( (  
              Isnull(m_item.[weight_mtr], 0) * Isnull  
              (stockview.[length], 0) * Isnull (  
                stockview.pending_qty, 0) *  
              Isnull(m_item.thickness, 0) ) / 1000 )  
              /* Is Width */  
              ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
                 Isnull(  
                 stockview.[length], 0) *  
                 Isnull(  
                    stockview.pending_qty, 0)  
               ) /  
               1000 )  
               END ))) AS totalweight,  
        m_item.item_group_id,  
        stockview.width,  
        stockview.rackno,  
        stockview.remark,  
        m_godown_rack.rack_name,  
        stockview.rack_id,  
        CASE  
       WHEN @Dept_ID = 3 THEN CONVERT (NUMERIC(18, 2),  
            (  
            Isnull(stockview.width, 0) *  
            Isnull(stockview.[length], 0)  
            *  
            Isnull(  
                    stockview.pending_qty, 0)  
            )  
            /  
                    1000000)  
       /*--width * heigth * quantity           */  
       ELSE 0  
        END                                 AS area,  
        tbl_stk.project_name  ,
        M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        StockView.Freeze_Qty,
           CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate,
        M_Item.Avg_Cost as AverageCost
    FROM   stockview WITH (nolock)  
        OUTER apply (SELECT DISTINCT grn_dtl.stock_id,  
             m_project.project_name  
         FROM   grn_dtl WITH (nolock)  
             LEFT JOIN po_dtl WITH (nolock)  ON grn_dtl.podtl_id = po_dtl.podtl_id  
             LEFT JOIN po_mst WITH (nolock) ON po_dtl.po_id = po_mst.po_id  
             LEFT JOIN m_project WITH (nolock) ON po_dtl.project_id = m_project.project_id  
         WHERE  grn_dtl.stock_id = stockview.id  
             AND po_mst.dept_id = 3  
           /* Only glass  Dept */  
           )AS tbl_stk  
        LEFT JOIN m_godown WITH (nolock) ON stockview.godown_id = m_godown.godown_id  
        LEFT JOIN m_godown_rack WITH (nolock) ON stockview.rack_id = m_godown_rack.rack_id  
        LEFT JOIN m_item WITH (nolock)  ON stockview.item_id = m_item.item_id  
             LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
        LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
        OUTER apply (SELECT m_group_field_setting.field_id  
         FROM   m_group_field_setting WITH (nolock)  
         WHERE  m_group_field_setting.field_id = 1  
             /*--  Only 'Width' Entry */  
             AND m_item.item_group_id = m_group_field_setting.item_group_id) AS kk  
        LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
        LEFT JOIN m_master AS tbl_unit WITH (nolock) ON m_item.unit_id = tbl_unit.master_id  
    WHERE  stockview.pending_qty > 0  
        AND stockview.item_id <> 0  
        --  StockView.pending_qty <> 0  
        AND m_item_group.dept_id = ( CASE  
               WHEN @Dept_ID = 0 THEN m_item_group.dept_id  
               ELSE @Dept_ID  
             END )  
        AND stockview.godown_id = ( CASE  
              WHEN @Godown_Id = 0 THEN stockview.godown_id  
              ELSE @Godown_Id  
               END )  
        AND stockview.stype = ( CASE  
             WHEN @SType = 'A' THEN stockview.stype  
             ELSE @SType  
              END )   
            end  
          else /*************/  
            begin  
    SELECT StockView.id,  
        StockView.Godown_Id,  
        m_godown.godown_name,  
        m_item.item_group_id,  
        m_item_group.item_group_name,  
        m_item.item_cate_id,  
        m_item_category.item_cate_name,  
        StockView.item_id,  
        m_item.item_name                    AS [Description],  
        m_item.item_code,  
        m_item.hsn_code,  
        StockView.total_qty,  
        StockView.sales_qty,  
        CASE 
            WHEN (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0)) < 0 
                THEN 0
            ELSE (ISNULL(StockView.Pending_Qty, 0) - ISNULL(StockView.Freeze_Qty, 0))
        END AS pending_qty,  
        StockView.[length],  
        Tbl_Unit.master_vals                AS UnitName,  
        m_item.unit_id,  
        CASE  
       WHEN StockView.stype = 'C' THEN 'Coated'  
       ELSE 'Non-Coated'  
        END                                 SType,  
        m_item.[total_parameter],  
        m_item.[coated_area],  
        m_item.[noncoated_area],  
        m_item.[calc_area],  
        m_item.[weight_mtr],  
         m_item.ImageName,
        lastupdate,  
        --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *                                     
        --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                                    
        Isnull(m_item.thickness, 0)         thickness,  
        KK.field_id,  
        convert (NUMERIC(18, 2), (( CASE  
              WHEN KK.field_id IS NOT NULL THEN ( (  
              Isnull(m_item.[weight_mtr], 0) * Isnull  
              (StockView.[length], 0) * Isnull (  
                StockView.pending_qty, 0) *  
              Isnull(m_item.thickness, 0) ) / 1000 )  
              /* Is Width */  
              ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
                 Isnull( StockView.[length], 0) *  
                 Isnull( StockView.pending_qty, 0)  
               ) / 1000 )  
               END ))) AS TotalWeight,  
        m_item.item_group_id,  
        StockView.Width,  
        StockView.RackNo,  
        StockView.Remark,  
        M_Godown_Rack.Rack_Name,  
        StockView.Rack_Id,  
        case  
       when @Dept_ID = 3 then convert (NUMERIC(18, 2),  
            ( Isnull(StockView.Width, 0) * Isnull(StockView.[length], 0) *  
             Isnull( StockView.pending_qty, 0) )  
            / 1000000)  
       /* --width * heigth * quantity */  
       else 0  
        end                                 AS Area,  
        ''                                  AS Project_Name ,
        M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        StockView.Freeze_Qty,
           CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Rate,
        M_Item.Avg_Cost as AverageCost
    --Tbl_Stk.Project_Name    
    FROM   StockView WITH (nolock)  
        /* outer apply (select distinct GRN_Dtl.Stock_Id, M_Project.Project_Name    
      from   GRN_Dtl WITH (nolock)    
        left join PO_DTL WITH (nolock) On GRN_Dtl.PODtl_Id = PO_DTL.PODtl_Id    
        left join PO_MST WITH (nolock) On PO_DTL.PO_Id = PO_MST.PO_Id    
        left join M_Project WITH (nolock) On PO_DTL.Project_Id = M_Project.Project_Id    
      where  GRN_Dtl.Stock_Id = StockView.Id  and PO_MST.Dept_ID = 3 /* Only glass  Dept */    
        )as Tbl_Stk */  
        LEFT JOIN m_godown WITH (nolock) ON StockView.godown_id = m_godown.godown_id  
        LEFT JOIN M_Godown_Rack WITH (nolock) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id  
        LEFT JOIN m_item WITH (nolock)  ON StockView.item_id = m_item.item_id 
             LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
        LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
        OUTER apply (SELECT m_group_field_setting.field_id  
         FROM   m_group_field_setting WITH (nolock)  
         WHERE  m_group_field_setting.field_id = 1  
             /*--  Only 'Width' Entry */  
             AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK  
        LEFT JOIN m_item_category WITH (nolock)  
         ON m_item.item_cate_id = m_item_category.item_cate_id  
        LEFT JOIN m_master AS Tbl_Unit WITH (nolock)  
         ON m_item.unit_id = Tbl_Unit.master_id  
    WHERE  StockView.pending_qty > 0  
        AND StockView.item_id <> 0  
        --  StockView.pending_qty <> 0                             
        and m_item_group.dept_id = ( CASE  
               WHEN @Dept_ID = 0 THEN  
               m_item_group.dept_id  
               ELSE @Dept_ID  
             END )  
        AND StockView.godown_id = ( CASE  
              WHEN @Godown_Id = 0 THEN  
              StockView.godown_id  
              ELSE @Godown_Id  
               END )  
        AND StockView.stype = ( CASE  
             WHEN @SType = 'A' THEN StockView.stype  
             ELSE @SType  
              END )   
            end  
      -- ORDER  BY LastUpdate DESC--m_item.item_code           
      end
