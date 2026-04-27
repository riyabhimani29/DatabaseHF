USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coatingdc_mst_getJOB]    Script Date: 27-04-2026 11:11:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Coatingdc_mst_getJOB]   
@DC_Id INT = 1008  ,  
@_dc_type varchar(10)           ='JB-DC'        
AS                    
    SET nocount ON                
           
  SELECT DC_Mst.dc_id AS po_id,          
      DC_Mst.dc_type AS po_type,          
      codc_type AS order_type,          
      DC_Mst.invoice_no,          
      DC_Mst.dc_no AS orderno,          
      DC_Mst.dc_date AS po_date,        
   0 AS reqraisedby_id,       
   0 AS dept_id,  
   '' AS  dept_name ,  
   '' AS ReqRaisedBy ,   
   'Block No : 787, Survey No : 190, Sanand - Viramgam Road, Jakhwada,Ahmedabad,Udyam Reg No. - UDYAM-GJ-01-0027208' AS billingaddress ,   
      DC_Mst.project_id,          
      DC_Mst.supplier_id,          
      m_project.project_name,          
      m_supplier.supplier_name,          
      m_supplier.contact_no                        AS Supplier_Contact_No,          
      m_supplier.contact_person                    AS Supplier_Contact_Person,          
      m_supplier.gst_no                            AS SupplierGSTNO,          
      m_supplier.address                           AS SupplierAddress,          
      Tbl_SupState.master_vals                     AS SupplierState,          
      DC_Mst.siteenginner_id,          
      Tbl_SiteEnginner.emp_name                    AS SiteEnginner,          
         
      DC_Mst.godown_id,          
      m_godown.godown_name,          
      m_godown.godown_address AS ShippingAddress,          
  
      DC_Mst.quotationno,          
      DC_Mst.projectdocument,          
      DC_Mst.transporttype,          
      DC_Mst.vehicle_no,          
      DC_Mst.driver_name,          
      DC_Mst.contact_of_driver,          
      DC_Mst.challantype,          
      DC_Mst.coating_shade,          
      DC_Mst.coating_rate,          
      DC_Mst.aluminium_rate,          
      CONVERT(NUMERIC(18, 0), DC_Mst.grossamount)  AS grossamount,   
   0 AS advanceamount,  
      DC_Mst.cgst,          
      Tbl_CGST.master_vals                         AS CGSTPer,          
      DC_Mst.sgst,          
      Tbl_SGST.master_vals                         AS SGSTPer,          
      DC_Mst.igst,          
      Tbl_IGST.master_vals                         AS IGSTPer,          
      CONVERT(NUMERIC(18, 0), DC_Mst.cgsttotal)    AS cgsttotal,          
      CONVERT(NUMERIC(18, 0), DC_Mst.sgsttotal)    AS sgsttotal,          
      CONVERT(NUMERIC(18, 0), DC_Mst.igsttotal)    AS igsttotal,          
      DC_Mst.cgst_mv,          
      Tbl_CGST_MV.master_vals                      AS CGSTPer_MV,          
      DC_Mst.sgst_mv,          
      Tbl_SGST_MV.master_vals                      AS SGSTPer_MV,          
      DC_Mst.igst_mv,          
      Tbl_IGST_MV.master_vals                      AS IGSTPer_MV,          
      CONVERT(NUMERIC(18, 0), DC_Mst.cgst_mvtotal) AS cgst_mvtotal,          
      CONVERT(NUMERIC(18, 0), DC_Mst.sgst_mvtotal) AS sgst_mvtotal,          
      CONVERT(NUMERIC(18, 0), DC_Mst.igst_mvtotal) AS igst_mvtotal,          
      CONVERT(NUMERIC(18, 0), DC_Mst.netamount)    AS netamount,   
   '' AS paymentterms,         
   '' AS deliveryterms,         
   '' AS additionalterms,         
   '' AS AuthorisePerson ,  
   0 AS authoriseperson_id,  
   DC_Mst.DC_Date AS  ApproveDate ,  
      DC_Mst.remark,          
      CASE          
     WHEN DC_Mst.codc_type = 'D' THEN 'Draft'          
     ELSE ( CASE          
        WHEN DC_Mst.codc_type = 'C' THEN 'Cancel'          
        ELSE 'Open'          
      END )          
      END                                          AS POStatus,         
           Tbl.orderqty,          
           Tbl.pendingqty,   
   '' AS IsCancel,  
      doc_img_name,          
      DC_Mst.packing_charge,      
      DC_Mst.issue_byid,          
      m_employee.emp_name                          AS IssueBy,          
      Tbl_Ent.emp_name                             AS EntryUserName    ,          
      Tbl_Ent.personal_no                             AS EntryUserNo        
  FROM   DC_Mst WITH (nolock)          
      LEFT JOIN m_employee WITH (nolock)  ON DC_Mst.issue_byid = m_employee.emp_id          
      LEFT JOIN m_employee AS Tbl_Ent WITH (nolock)  ON DC_Mst.entry_user = Tbl_Ent.emp_id          
      LEFT JOIN m_godown WITH (nolock)  ON DC_Mst.godown_id = m_godown.godown_id          
      LEFT JOIN m_master AS Tbl_CGST WITH (nolock)  ON DC_Mst.cgst = Tbl_CGST.master_id          
      LEFT JOIN m_master AS Tbl_SGST WITH (nolock)  ON DC_Mst.sgst = Tbl_SGST.master_id          
      LEFT JOIN m_master AS Tbl_IGST WITH (nolock)  ON DC_Mst.igst = Tbl_IGST.master_id          
      LEFT JOIN m_master AS Tbl_CGST_MV WITH (nolock)  ON DC_Mst.cgst_mv = Tbl_CGST_MV.master_id          
      LEFT JOIN m_master AS Tbl_SGST_MV WITH (nolock)  ON DC_Mst.sgst_mv = Tbl_SGST_MV .master_id          
      LEFT JOIN m_master AS Tbl_IGST_MV WITH (nolock)  ON DC_Mst.igst_mv = Tbl_IGST_MV .master_id          
      LEFT JOIN m_employee AS Tbl_SiteEnginner WITH (nolock)  ON DC_Mst.siteenginner_id = Tbl_SiteEnginner.emp_id          
      LEFT JOIN m_project WITH (nolock)  ON DC_Mst.project_id = m_project.project_id          
      LEFT JOIN m_supplier WITH (nolock) ON DC_Mst.supplier_id = m_supplier.supplier_id      
    OUTER apply (SELECT Sum(Isnull(DC_Dtl.DC_Qty, 0))   AS OrderQty,          
                               Sum(Isnull(DC_Dtl.Qty, 0)) AS PendingQty          
                        FROM   DC_Dtl WITH (nolock)          
                        WHERE  DC_Dtl.DC_Id = DC_Mst.DC_Id) AS Tbl     
  
      LEFT JOIN m_master AS Tbl_SupState WITH (nolock)  ON m_supplier.state_id = Tbl_SupState.master_id          
  WHERE  DC_Mst.dc_type = @_dc_type --'CO-DC'          
      AND DC_Mst.dc_id = CASE          
         WHEN @DC_Id = 0 THEN DC_Mst.dc_id          
         ELSE @DC_Id          
          END          
  ORDER  BY DC_Mst.entry_date DESC          
          
  SELECT Row_number()   OVER(  ORDER BY DC_Dtl.dcdtl_id) AS SrNo,          
  DC_Mst.dc_no AS orderno,  
      DC_Dtl.dcdtl_id AS  PODtl_Id,          
      DC_Dtl.dc_id AS po_id,          
      DC_Dtl.dept_id,          
      m_department.dept_name,          
      m_item.item_group_id,          
      m_item.item_code,          
      m_item_group.item_group_name,          
      m_item.item_cate_id,          
      m_item_category.item_cate_name,          
      DC_Dtl.item_id,          
      m_item.item_name,          
      m_item.hsn_code,          
      DC_Dtl.calc_area,          
      DC_Dtl.weight_mtr,          
      DC_Dtl.qty,          
      DC_Dtl.unit_id,          
      tbl_Unit.master_vals                           AS Unit,          
      DC_Dtl.itemlength AS length,         
   m_item.Weight_Mtr AS weight,  
   DC_Dtl.Total_Weight AS totalweight,  
      DC_Dtl.rate AS unitcost,        
      DC_Dtl.rate                  AS RUnitCost,     
      DC_Dtl.totalvalue AS totalcost,          
      DC_Dtl.remark,          
      ''                                             AS POStatus,          
      DC_Dtl.dc_qty AS OrderQty,       
   0 AS ReceiveQty ,  
   0      AS PendingQty,     
      DC_Dtl.running_feet,          
      DC_Dtl.rate_feet,          
      CONVERT(NUMERIC(18, 0), DC_Dtl.coating_value)  AS coating_value,          
      DC_Dtl.total_weight,          
      CONVERT(NUMERIC(18, 0), DC_Dtl.material_value) AS material_value,          
      DC_Dtl.scrap_qty,          
      DC_Dtl.scrap_length  ,        
      DC_Dtl.DC_Width   ,        
      DC_Dtl.Scrap_Width ,        
      DC_Dtl.Tray_Dimension,        
      DC_Dtl.Img_Name   AS imagename   ,  
		DC_Dtl.DC_Width AS Width,  
		''  AS POStatus,          
           CONVERT(BIT, 0)                   AS IsSeletd,          
           0                                 AS GrnDtl_Id,          
           0                                 AS GRN_Id ,         
           0                                 AS project_id ,  
     0 AS supdetail_id ,  
'' AS supitem_code,  
'' AS project_name  
  FROM   DC_Dtl WITH (nolock)          
      LEFT JOIN m_master AS tbl_Unit WITH (nolock)  ON DC_Dtl.unit_id = tbl_Unit.master_id          
      LEFT JOIN m_department WITH (nolock)  ON DC_Dtl.dept_id = m_department.dept_id          
      LEFT JOIN dc_mst WITH (nolock)  ON DC_Dtl.dc_id = DC_Mst.dc_id          
      LEFT JOIN m_item WITH (nolock)  ON DC_Dtl.item_id = m_item.item_id          
      LEFT JOIN m_item_group WITH (nolock)  ON m_item.item_group_id = m_item_group.item_group_id          
      LEFT JOIN m_item_category WITH (nolock)  ON m_item.item_cate_id = m_item_category.item_cate_id          
  WHERE  DC_Mst.dc_type = @_dc_type --'CO-DC'          
      AND DC_Dtl.dc_id = CASE          
         WHEN @DC_Id = 0 THEN DC_Dtl.dc_id          
         ELSE @DC_Id          
          END 
GO


