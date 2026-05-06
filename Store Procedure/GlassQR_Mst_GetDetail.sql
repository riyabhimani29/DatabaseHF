USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GlassQR_Mst_GetDetail]    Script Date: 27-04-2026 11:34:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GlassQR_Mst_GetDetail] @Glass_QR_Id INT = 6028,          
                                              @Typ         VARCHAR(10) = 'OUT'          
AS          
    SET nocount ON          
          
    if ( @Typ = 'GRN' )          
      begin          
          SELECT PO_MST.PO_Id,          
                 PO_MST.PO_Id                                AS Glass_QR_Id,          
                 PO_MST.PO_Type,          
                 Order_Type,          
                 CASE          
                   WHEN Order_Type = 'PO-GL' THEN 'Glass PO'          
                   WHEN Order_Type = 'PO-HW' THEN 'Hardware PO'          
                   ELSE Order_Type          
                 END                                         AS Order_Type2,          
                 PO_MST.Dept_ID,          
                 M_Department.Dept_Name,          
                 PO_MST.Invoice_No,          
                 PO_MST.OrderNo,          
                 PO_MST.PO_Date,          
                 PO_MST.ReqRaisedBy_Id,          
                 Tbl_ReqRaisedBy.Emp_Name                    AS ReqRaisedBy,          
                 PO_MST.BillingAddress,          
                 PO_MST.Supplier_Id,          
                 M_Supplier.Supplier_Name,          
                 M_Supplier.Address                          AS SupplierAddress,          
                 M_Supplier.GST_No                           AS SupplierGSTNO,          
                 Tbl_State.Master_Vals                       AS SupplierState,          
                 PO_MST.Godown_Id,          
                 M_Godown.Godown_Name,          
                 M_Godown.Godown_Address                     AS ShippingAddress,          
                 CONVERT(NUMERIC(18, 0), PO_MST.GrossAmount) AS grossamount,          
                 PO_MST.AdvanceAmount,          
                 PO_MST.NetAmount,          
                 PO_MST.PaymentTerms,          
                 PO_MST.DeliveryTerms,          
                 PO_MST.AdditionalTerms,          
                 PO_MST.AuthorisePerson_Id,          
                 Tbl_AuthorisePerson.Emp_Name                AS AuthorisePerson,          
                 PO_MST.ApproveDate,          
                 PO_MST.Remark,          
                 CASE          
                   WHEN Tbl.PendingQty <= 0 THEN 'Close'          
                   ELSE ( CASE          
                            WHEN PO_MST.PO_Type = 'D' THEN 'Draft'          
                            ELSE ( CASE          
                                     WHEN PO_MST.PO_Type = 'C' THEN 'Cancel'          
                                     WHEN PO_MST.PO_Type = 'Q' THEN          
                                     'Force Close'          
                                     WHEN PO_MST.PO_Type = 'X' THEN 'Delete'          
                                     ELSE 'Open'          
                                   END )          
                          END )          
                 END                                         AS POStatus,          
                 Tbl.OrderQty,          
                 Tbl.PendingQty,          
                 CASE          
                   WHEN Tbl.PendingQty = Tbl.OrderQty          
                        AND PO_MST.PO_Type != 'C' THEN 'Cancel'          
                   ELSE ''          
                 END                                         AS IsCancel,          
                 Tbl_CGST.Master_NumVals                     AS CGSTPer,          
                 Tbl_SGST.Master_NumVals                     AS SGSTPer,          
                 Tbl_IGST.Master_NumVals                     AS IGSTPer,          
                 PO_MST.CGST,          
                 PO_MST.SGST,          
                 PO_MST.IGST,          
                 CONVERT(NUMERIC(18, 0), PO_MST.CGSTTotal)   AS cgsttotal,          
                 CONVERT(NUMERIC(18, 0), PO_MST.SGSTTotal)   AS sgsttotal,          
      CONVERT(NUMERIC(18, 0), PO_MST.IGSTTotal)   AS igsttotal,          
                 CASE          
                   WHEN PO_MST.IGST = 0 THEN CONVERT(BIT, 0)          
                   ELSE CONVERT(BIT, 1)          
                 END                                         AS Is_IGST,          
                 Tbl_User.Emp_Name                           AS EntryUserName,          
                 Tbl_User.Personal_No                        AS EntryUserNo,          
                 Doc_Img_Name,          
                 PO_MST.Revision,          
                 PO_MST.Admin_Charges,          
                 PO_MST.Insurance,          
                 PO_MST.Other_Charges,          
                 PO_MST.Freight_Charges          
          --row("Item_Name") + "," + row("Item_Code") + "," + row("OrderQty").ToString() + "," + _ArrVar.ToString() + "," + row("OrderNo") + "," +                         
          --row("SupItem_Code") + "," + row("PODtl_Id").ToString() + "," + row("Item_Id").ToString() + "," + row("PO_Id").ToString()                          
          FROM   PO_MST WITH (nolock)          
                 LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)          
                        ON PO_MST.CGST = Tbl_CGST.Master_Id          
                 LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)          
                        ON PO_MST.SGST = Tbl_SGST.Master_Id          
                 LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)          
                        ON PO_MST.IGST = Tbl_IGST.Master_Id          
                 LEFT JOIN M_Employee AS Tbl_User WITH(nolock)          
                        ON PO_MST.entry_user = Tbl_User.Emp_Id          
                 OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0)) AS OrderQty          
                                     ,          
                                     Sum(          
                             CASE          
                               WHEN Isnull(PO_DTL.PendingQty, 0) > 0          
                             THEN          
                               Isnull(PO_DTL.PendingQty, 0)          
                               ELSE 0          
                             END)                        AS PendingQty          
                              /*Sum(Isnull(PO_DTL.PendingQty, 0)) AS PendingQty        */          
                              FROM   PO_DTL WITH (nolock)          
                              WHERE  PO_DTL.PO_Id = PO_MST.PO_Id) AS Tbl          
                 LEFT JOIN M_Godown WITH (nolock)          
                        ON PO_MST.Godown_Id = M_Godown.Godown_Id          
                 LEFT JOIN M_Department WITH (nolock)          
                        ON PO_MST.Dept_ID = M_Department.Dept_ID          
                 LEFT JOIN M_Employee AS Tbl_ReqRaisedBy WITH (nolock)          
                        ON PO_MST.ReqRaisedBy_Id = Tbl_ReqRaisedBy.Emp_Id          
                 LEFT JOIN M_Employee AS Tbl_AuthorisePerson WITH (nolock)          
                        ON PO_MST.authoriseperson_id =          
                           Tbl_AuthorisePerson.Emp_Id          
                 LEFT JOIN M_Supplier WITH (nolock)          
                        ON PO_MST.Supplier_Id = M_Supplier.Supplier_Id          
                 LEFT JOIN M_Master AS Tbl_State WITH (nolock)          
                        ON M_Supplier.state_id = Tbl_State.Master_Id          
          WHERE  PO_MST.PO_Id IN (SELECT TOP 1 PO_Id          
                                  FROM   GlassQR_Dtl WITH (nolock)          
                                  WHERE  GlassQR_Dtl.PO_Id = @Glass_QR_Id          
                                  GROUP  BY PO_Id          
                                  HAVING Count(*) >= 1          
                                  ORDER  BY PO_Id DESC)          
          ORDER  BY PO_MST.PO_Id DESC          
          
          /* ------------------------------------------------------------ */          
          SELECT Row_number()          
                   OVER(          
                     ORDER BY PODtl_Id )                             AS SrNo,          
                 PO_MST.OrderNo,          
                 PO_DTL.podtl_id,          
                 PO_DTL.PO_Id,          
         PO_MST.PO_Date,          
                 m_supplier.Supplier_Name                            AS          
                 Supplier_Name,          
                 M_Item.item_group_id,          
                 M_Item_group.item_group_name,          
                 M_Item.item_cate_id,          
                 M_Item_category.item_cate_name,          
                 PO_DTL.item_id,          
                 M_Item.item_name,          
                 M_Item.item_code,          
                 M_Item.hsn_code,          
                 PO_DTL.supdetail_id,          
                 m_supplierdtl.supitem_code,          
                 PO_DTL.orderqty,          
                 /*ISNULL(PO_DTL.PendingQty,0)*/ CASE 
    WHEN ISNULL(Tot.reccnt, 0) > PO_DTL.OrderQty 
        THEN PO_DTL.OrderQty
    ELSE ISNULL(Tot.reccnt, 0)
END AS ReceiveQty,

                 Isnull(PO_DTL.pendingqty, 0)                        AS          
                 PendingQty,          
                 PO_DTL.unit_id,          
                 Tbl_Unit.master_vals                                AS Unit,          
                 PO_DTL.length,          
                 PO_DTL.weight,          
                 PO_DTL.totalweight,          
                 PO_DTL.unitcost,          
                 PO_DTL.unitcost                                     AS          
                 RUnitCost,          
                 --   let _a = ((_Charg_Weight / 1000) * (_Charg_Height / 1000) * _rows['ReceiveQty']).toFixed(3);                        
                 --   let _b = (parseFloat(_a) * _rows['RUnitCost']).toFixed(3);                        
                 --   _rows['TotalWeight'] = parseFloat(_a);                        
                 --   _rows['TotalCost'] = parseFloat(_b);                        
                 CONVERT(NUMERIC(18, 2), ( ( Isnull(PO_DTL.charg_weight, 0) /          
                                             1000 )          
                                           *          
                                           (          
          Isnull(PO_DTL.charg_height,          
          0) / 1000 ) *          
          Isnull(Tot.reccnt, 0) ) *          
          Isnull(PO_DTL.unitcost, 0)) AS totalcost,          
          --CONVERT( numeric(18,0), PO_DTL.TotalCost) AS totalcost,                            
          PO_DTL.remark,          
          CASE          
          WHEN ( CASE          
          WHEN Isnull(PO_DTL.pendingqty, 0) > 0 THEN          
          Isnull(PO_DTL.pendingqty, 0)          
          ELSE 0          
          END ) <= 0 THEN 'Close'          
          ELSE 'Open'          
          END                                                 AS POStatus,          
          CONVERT(BIT, 0)                                     AS IsSeletd,          
          0                                                   AS GrnDtl_Id,          
          0                                                   AS GRN_Id,          
          PO_DTL.project_id,          
          M_Item.imagename,          
          m_project.project_name,          
          PO_DTL.width,          
          Tot.Rack_Id                                         AS Rack_Id,          
          PO_DTL.Charg_Height,          
          PO_DTL.Charg_Weight,          
          PO_DTL.ref_code,          
          item_name + ',' + item_code + ',' + CONVERT(VARCHAR, orderqty) + ',1,' + orderno + ',' + supitem_code + ',' + CONVERT(VARCHAR, podtl_id) + ',' +           
    CONVERT(VARCHAR, PO_DTL.item_id) + ',' + CONVERT(VARCHAR, PO_DTL.po_id)--,                          
          FROM   PO_DTL WITH (nolock)          
                 OUTER apply (SELECT Sum(GlassQR_Dtl.scan_qty) AS RecCnt,          
                                     GlassQR_Dtl.rack_id          
                      FROM   GlassQR_Dtl WITH (nolock)          
                              WHERE  GlassQR_Dtl.PO_Id = @Glass_QR_Id          
                                     AND GlassQR_Dtl.PO_Id = PO_DTL.PO_Id          
                                     AND GlassQR_Dtl.PODtl_Id = PO_DTL.PODtl_Id          
                                     AND GlassQR_Dtl.Item_Id = PO_DTL.Item_Id       
                                     AND GlassQR_Dtl.is_Grn = 0          
                              GROUP  BY GlassQR_Dtl.Rack_Id) AS Tot          
                 LEFT JOIN m_project WITH (nolock)          
                        ON PO_DTL.project_id = m_project.project_id          
                 LEFT JOIN PO_MST WITH (nolock)          
                        ON PO_DTL.po_id = PO_MST.po_id          
                 LEFT JOIN m_supplier WITH (nolock)          
                        ON PO_MST.supplier_id = m_supplier.supplier_id          
                 LEFT JOIN m_master AS Tbl_Unit WITH (nolock)          
                        ON PO_DTL.unit_id = Tbl_Unit.master_id          
                 LEFT JOIN m_supplierdtl WITH (nolock)          
                        ON PO_DTL.supdetail_id = m_supplierdtl.supdetail_id          
                 LEFT JOIN M_Item WITH (nolock)          
                        ON PO_DTL.item_id = M_Item.item_id          
                 LEFT JOIN M_Item_group WITH (nolock)          
                        ON M_Item.item_group_id = M_Item_group.item_group_id          
                 LEFT JOIN M_Item_category WITH (nolock)          
                        ON M_Item.item_cate_id = M_Item_category.item_cate_id          
          WHERE  PO_DTL.PendingQty > 0          
                 and PO_DTL.PO_Id IN (SELECT TOP 1 po_id          
                                      FROM   GlassQR_Dtl WITH (nolock)          
                                      WHERE  GlassQR_Dtl.po_id = @Glass_QR_Id          
                                      GROUP  BY po_id          
                                      HAVING Count(*) >= 1          
                                      ORDER  BY po_id DESC)          
                 AND PO_DTL.podtl_id IN (SELECT DISTINCT podtl_id          
                                         FROM   GlassQR_Dtl WITH (nolock)          
                                         WHERE  GlassQR_Dtl.po_id = @Glass_QR_Id          
                                        )          
          ORDER  BY PO_MST.po_id DESC          
      end          
    else /************************** Glass Outward **************************/          
      begin          
          SELECT PO_MST.PO_Id,          
                 PO_MST.PO_Id                                AS Glass_QR_Id,          
                 PO_MST.PO_Type,          
                 Order_Type,          
                 CASE          
                   WHEN Order_Type = 'PO-GL' THEN 'Glass PO'          
                   WHEN Order_Type = 'PO-HW' THEN 'Hardware PO'          
                   ELSE Order_Type          
                 END                                         AS Order_Type2,          
                 PO_MST.Dept_ID,          
                 M_Department.Dept_Name,          
                 PO_MST.Invoice_No,          
                 PO_MST.OrderNo,          
                 PO_MST.PO_Date,          
                 PO_MST.ReqRaisedBy_Id,          
                 Tbl_ReqRaisedBy.Emp_Name                    AS ReqRaisedBy,          
                 PO_MST.BillingAddress,          
                 PO_MST.Supplier_Id,          
                 M_Supplier.Supplier_Name,          
                 M_Supplier.Address                          AS SupplierAddress,          
                 M_Supplier.GST_No                           AS SupplierGSTNO,          
                 Tbl_State.Master_Vals                       AS SupplierState,          
                 PO_MST.Godown_Id,          
                 M_Godown.Godown_Name,          
          M_Godown.Godown_Address                     AS ShippingAddress,          
                 CONVERT(NUMERIC(18, 0), PO_MST.GrossAmount) AS grossamount,          
                 PO_MST.AdvanceAmount,          
                 PO_MST.NetAmount,          
                 PO_MST.PaymentTerms,          
                 PO_MST.DeliveryTerms,          
                 PO_MST.AdditionalTerms,          
                 PO_MST.AuthorisePerson_Id,          
                 Tbl_AuthorisePerson.Emp_Name                AS AuthorisePerson,          
                 PO_MST.ApproveDate,          
                 PO_MST.Remark,          
                 CASE          
                   WHEN Tbl.PendingQty <= 0 THEN 'Close'          
                   ELSE ( CASE          
                            WHEN PO_MST.PO_Type = 'D' THEN 'Draft'          
                            ELSE ( CASE          
                                     WHEN PO_MST.PO_Type = 'C' THEN 'Cancel'          
                                     WHEN PO_MST.PO_Type = 'Q' THEN          
                                     'Force Close'          
                                     WHEN PO_MST.PO_Type = 'X' THEN 'Delete'          
                                     ELSE 'Open'          
                                   END )          
                          END )          
                 END                                         AS POStatus,          
                 Tbl.OrderQty,          
                 Tbl.PendingQty,          
                 CASE          
                   WHEN Tbl.PendingQty = Tbl.OrderQty          
                        AND PO_MST.PO_Type != 'C' THEN 'Cancel'          
                   ELSE ''          
            END                                         AS IsCancel,          
                 Tbl_CGST.Master_NumVals                     AS CGSTPer,          
                 Tbl_SGST.Master_NumVals                     AS SGSTPer,          
                 Tbl_IGST.Master_NumVals                     AS IGSTPer,          
                 PO_MST.CGST,          
                 PO_MST.SGST,          
                 PO_MST.IGST,          
                 CONVERT(NUMERIC(18, 0), PO_MST.CGSTTotal)   AS cgsttotal,          
                 CONVERT(NUMERIC(18, 0), PO_MST.SGSTTotal)   AS sgsttotal,          
                 CONVERT(NUMERIC(18, 0), PO_MST.IGSTTotal)   AS igsttotal,          
                 CASE          
                   WHEN PO_MST.IGST = 0 THEN CONVERT(BIT, 0)          
                   ELSE CONVERT(BIT, 1)          
                 END                                         AS Is_IGST,          
                 Tbl_User.Emp_Name                           AS EntryUserName,          
                 Tbl_User.Personal_No                        AS EntryUserNo,          
                 Doc_Img_Name,          
                 PO_MST.Revision,          
                 PO_MST.Admin_Charges,          
                 PO_MST.Insurance,          
                 PO_MST.Other_Charges,          
                 PO_MST.Freight_Charges          
          --row("Item_Name") + "," + row("Item_Code") + "," + row("OrderQty").ToString() + "," + _ArrVar.ToString() + "," + row("OrderNo") + "," +                         
          --row("SupItem_Code") + "," + row("PODtl_Id").ToString() + "," + row("Item_Id").ToString() + "," + row("PO_Id").ToString()                          
          FROM   PO_MST WITH (nolock)          
                 LEFT JOIN M_Master AS Tbl_CGST WITH (nolock) ON PO_MST.CGST = Tbl_CGST.Master_Id          
                 LEFT JOIN M_Master AS Tbl_SGST WITH (nolock) ON PO_MST.SGST = Tbl_SGST.Master_Id          
                 LEFT JOIN M_Master AS Tbl_IGST WITH (nolock) ON PO_MST.IGST = Tbl_IGST.Master_Id          
                 LEFT JOIN M_Employee AS Tbl_User WITH(nolock) ON PO_MST.entry_user = Tbl_User.Emp_Id          
                 OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0)) AS OrderQty , Sum( CASE WHEN Isnull(PO_DTL.PendingQty, 0) > 0 THEN           
         Isnull(PO_DTL.PendingQty, 0) ELSE 0 END) AS PendingQty          
                              FROM   PO_DTL WITH (nolock) WHERE  PO_DTL.PO_Id = PO_MST.PO_Id) AS Tbl          
                 LEFT JOIN M_Godown WITH (nolock) ON PO_MST.Godown_Id = M_Godown.Godown_Id          
                 LEFT JOIN M_Department WITH (nolock) ON PO_MST.Dept_ID = M_Department.Dept_ID          
                 LEFT JOIN M_Employee AS Tbl_ReqRaisedBy WITH (nolock) ON PO_MST.ReqRaisedBy_Id = Tbl_ReqRaisedBy.Emp_Id          
                 LEFT JOIN M_Employee AS Tbl_AuthorisePerson WITH (nolock) ON PO_MST.authoriseperson_id = Tbl_AuthorisePerson.Emp_Id          
                 LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.Supplier_Id = M_Supplier.Supplier_Id          
                 LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.Master_Id          
          WHERE  PO_MST.PO_Id IN (SELECT TOP 1 PO_Id          
                                  FROM   GlassQR_Dtl WITH (nolock)          
                                  WHERE  GlassQR_Dtl.PO_Id = @Glass_QR_Id -- and GlassQR_Dtl.QR_Typedtl ='OUT'        
                                  GROUP  BY PO_Id          
                                  HAVING Count(*) >= 1          
                                  ORDER  BY PO_Id DESC)          
          ORDER  BY PO_MST.PO_Id DESC          
          
          /* ------------------------------------------------------------ */          
   SELECT Row_number()  OVER( ORDER BY PODtl_Id ) AS SrNo,          
       PO_MST.OrderNo,          
       PO_DTL.podtl_id,          
       PO_DTL.PO_Id,          
       PO_MST.PO_Date,          
       m_supplier.Supplier_Name AS Supplier_Name,          
       M_Item.item_group_id,          
       M_Item_group.item_group_name,          
       M_Item.item_cate_id,          
       M_Item_category.item_cate_name,          
       PO_DTL.item_id,          
       M_Item.item_name,          
       M_Item.item_code,          
       M_Item.hsn_code,          
       PO_DTL.supdetail_id,          
       m_supplierdtl.supitem_code,          
       PO_DTL.orderqty,          
       /*ISNULL(PO_DTL.PendingQty,0)*/ Tot.reccnt AS ReceiveQty,          
       -- Isnull(PO_DTL.pendingqty, 0) - ISNULL(tbl_RecQty.GrnRecQty,0) AS PendingQty,          
    Isnull(PO_DTL.OrderQty, 0) - ISNULL(tbl_RecQty.GrnRecQty,0) AS PendingQty,          
       PO_DTL.unit_id,          
       Tbl_Unit.master_vals                                AS Unit,          
       PO_DTL.length,          
       PO_DTL.weight,          
       PO_DTL.totalweight,          
       PO_DTL.unitcost,          
       PO_DTL.unitcost                                     AS RUnitCost,          
       --   let _a = ((_Charg_Weight / 1000) * (_Charg_Height / 1000) * _rows['ReceiveQty']).toFixed(3);                        
       --   let _b = (parseFloat(_a) * _rows['RUnitCost']).toFixed(3);                        
       --   _rows['TotalWeight'] = parseFloat(_a);                        
       --   _rows['TotalCost'] = parseFloat(_b);                        
       CONVERT(NUMERIC(18, 2), ( ( Isnull(PO_DTL.charg_weight, 0) / 1000 ) * ( Isnull(PO_DTL.charg_height, 0) / 1000 ) * Isnull(Tot.reccnt, 0) ) *           
       Isnull(PO_DTL.unitcost, 0)) AS totalcost,          
     --CONVERT( numeric(18,0), PO_DTL.TotalCost) AS totalcost,                            
     PO_DTL.remark,          
     CASE WHEN ( CASE WHEN Isnull(PO_DTL.pendingqty, 0) > 0 THEN Isnull(PO_DTL.pendingqty, 0) ELSE 0 END ) <= 0 THEN 'Close' ELSE 'Open' END           
      AS POStatus,          
     CONVERT(BIT, 0)                                     AS IsSeletd,          
     0                                                   AS GrnDtl_Id,          
     0                                                   AS GRN_Id,          
     PO_DTL.project_id,          
     M_Item.imagename,          
     m_project.project_name,          
     PO_DTL.width,          
     Tot.Rack_Id                                         AS Rack_Id,          
     PO_DTL.Charg_Height,          
     PO_DTL.Charg_Weight,          
     PO_DTL.ref_code,          
     item_name + ',' + item_code + ',' + CONVERT(VARCHAR, orderqty) + ',1,' + orderno + ',' + supitem_code + ',' + CONVERT(VARCHAR, podtl_id) + ',' +           
     CONVERT(VARCHAR, PO_DTL.item_id) + ',' + CONVERT(VARCHAR, PO_DTL.po_id)--,                          
    FROM   PO_DTL WITH (nolock)          
    OUTER apply (select isnull(sum(GRN_Dtl.ReceiveQty),0) AS GrnRecQty from GRN_Dtl        
       left join GRN_Mst on GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id and  GRN_Mst.GRN_Type = 'GRN-OUT'        
       where GRN_Mst.PO_Id = @Glass_QR_Id          
       and  PO_DTL.PODtl_Id = GRN_Dtl.PODtl_Id        
       and  GRN_Mst.GRN_Type = 'GRN-OUT') AS tbl_RecQty          
    OUTER apply (SELECT Sum(GlassQR_Dtl.scan_qty) AS RecCnt,          
           GlassQR_Dtl.rack_id          
          FROM   GlassQR_Dtl WITH (nolock)          
          WHERE  GlassQR_Dtl.PO_Id = @Glass_QR_Id          
           AND GlassQR_Dtl.PO_Id = PO_DTL.PO_Id          
           AND GlassQR_Dtl.PODtl_Id = PO_DTL.PODtl_Id          
           AND GlassQR_Dtl.Item_Id = PO_DTL.Item_Id          
           AND GlassQR_Dtl.is_out = 0       
     --and GlassQR_Dtl.QR_Typedtl ='OUT'    
        GROUP  BY GlassQR_Dtl.Rack_Id) AS Tot          
     LEFT JOIN M_Project WITH (nolock)   ON PO_DTL.project_id = m_project.project_id          
     LEFT JOIN PO_MST WITH (nolock)   ON PO_DTL.po_id = PO_MST.po_id          
     LEFT JOIN M_Supplier WITH (nolock)   ON PO_MST.supplier_id = m_supplier.supplier_id          
     LEFT JOIN M_Master AS Tbl_Unit WITH (nolock)   ON PO_DTL.unit_id = Tbl_Unit.master_id          
     LEFT JOIN M_SupplierDtl WITH (nolock)   ON PO_DTL.supdetail_id = m_supplierdtl.supdetail_id          
     LEFT JOIN M_Item WITH (nolock)   ON PO_DTL.item_id = M_Item.item_id          
     LEFT JOIN M_Item_group WITH (nolock)   ON M_Item.item_group_id = M_Item_group.item_group_id          
     LEFT JOIN M_Item_category WITH (nolock) ON M_Item.item_cate_id = M_Item_category.item_cate_id          
    WHERE  /*PO_DTL.PendingQty > 0 and*/          
    PO_DTL.PO_Id IN (SELECT TOP 1 po_id          
      FROM   GlassQR_Dtl WITH (nolock)          
      WHERE  GlassQR_Dtl.po_id = @Glass_QR_Id       
   --and GlassQR_Dtl.QR_Typedtl ='OUT'    
      GROUP  BY po_id          
      HAVING Count(*) >= 1          
      ORDER  BY po_id DESC)          
    AND PO_DTL.podtl_id IN (SELECT DISTINCT podtl_id          
       FROM   GlassQR_Dtl WITH (nolock)          
       WHERE  GlassQR_Dtl.po_id = @Glass_QR_Id  
    --and GlassQR_Dtl.QR_Typedtl ='OUT'  
    )          
    ORDER  BY PO_MST.po_id DESC           
      end
GO


