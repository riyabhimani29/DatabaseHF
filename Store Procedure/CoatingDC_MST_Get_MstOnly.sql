USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[CoatingDC_MST_Get_MstOnly]    Script Date: 27-04-2026 11:10:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER   PROCEDURE [dbo].[CoatingDC_MST_Get_MstOnly] 
    @Dept_Id INT = 0,
    @DC_Id INT = 0 ,                                                  
    @_dc_type varchar(10)           ='CO-DC' ,                          
    @_CODC_Type varchar(10)           ='All' ,                           
    @FDate date           ='2021-09-01' ,                          
    @TDate date           ='2021-09-29' ,                         
 @Supplier_Id int =0                            
AS                                                                      
    SET nocount ON                      
                     
                    
                    
 SELECT dc_mst.Dept_ID,
       D.Dept_Name,
       dc_mst.dc_id,                    
       dc_mst.dc_type,                    
       codc_type,                    
       dc_mst.invoice_no,                    
       dc_mst.dc_no,                    
       dc_mst.dc_date,                    
       dc_mst.project_id,                    
       dc_mst.supplier_id,                    
       m_project.project_name,                    
       m_supplier.supplier_name,                    
       m_supplier.contact_no                        AS Supplier_Contact_No,                    
       m_supplier.contact_person                    AS Supplier_Contact_Person,                    
       m_supplier.gst_no                            AS Supplier_GST_No,                    
       m_supplier.address                           AS Supplier_Address,                    
       Tbl_SupState.master_vals                     AS Supplier_State,                    
       dc_mst.siteenginner_id,                    
       Tbl_SiteEnginner.emp_name                    AS SiteEnginner,                    
       dc_mst.quotationno,                    
       dc_mst.projectdocument,                    
       dc_mst.transporttype,                    
       dc_mst.vehicle_no,                    
       dc_mst.driver_name,                    
       dc_mst.contact_of_driver,                    
       dc_mst.challantype,                    
       dc_mst.coating_shadeid,                    
       Tbl_Shade.master_vals                        coating_shade,                    
       dc_mst.coating_rate,                    
       dc_mst.aluminium_rate,                    
       CONVERT(NUMERIC(18, 3), dc_mst.grossamount)  AS grossamount,                    
       dc_mst.cgst,                    
       Tbl_CGST.master_numvals                      AS CGSTPer,                    
       dc_mst.sgst,                    
       Tbl_SGST.master_numvals                      AS SGSTPer,                    
       dc_mst.igst,                    
       Tbl_IGST.master_numvals                      AS IGSTPer,                    
       Tbl_CGST.master_vals                         AS CGSTPer_Dis,                    
       Tbl_SGST.master_vals                         AS SGSTPer_Dis,                    
       Tbl_IGST.master_vals                         AS IGSTPer_Dis,                    
       Tbl_CGST_MV.master_vals                      AS CGSTPer_MV_Dis,                    
       Tbl_SGST_MV.master_vals                      AS SGSTPer_MV_Dis,                    
       Tbl_IGST_MV.master_vals                      AS IGSTPer_MV_Dis,                    
       CONVERT(NUMERIC(18, 3), dc_mst.cgsttotal)    AS CGSTTotal,                    
       CONVERT(NUMERIC(18, 3), dc_mst.sgsttotal)    AS SGSTTotal,                    
       CONVERT(NUMERIC(18, 3), dc_mst.igsttotal)    AS IGSTTotal,                    
       dc_mst.cgst_mv,                    
       Tbl_CGST_MV.master_numvals                   AS CGST_MVPer,                    
       dc_mst.sgst_mv,                    
       Tbl_SGST_MV.master_numvals                   AS SGST_MVPer,                    
       dc_mst.igst_mv,                    
       Tbl_IGST_MV.master_numvals                   AS IGST_MVPer,                    
       CONVERT(NUMERIC(18, 3), dc_mst.cgst_mvtotal) AS CGST_MVTotal,                    
       CONVERT(NUMERIC(18, 3), dc_mst.sgst_mvtotal) AS SGST_MVTotal,                    
       CONVERT(NUMERIC(18, 3), dc_mst.igst_mvtotal) AS IGST_MVTotal,                    
       --CONVERT(NUMERIC(18, 0), dc_mst.netamount)    AS netamount,                                                          
       ( CASE WHEN dc_mst.codc_type = 'D' THEN                     
          CONVERT (NUMERIC(18, 0), ( CASE WHEN Isnull(dc_mst.igst, 0) = 0 THEN                    
                                            CONVERT ( NUMERIC(18, 0), ( Isnull(tbl.coating_value, 0) + ( Isnull(tbl.coating_value, 0) * Isnull(tbl_cgst.master_numvals, 0) ) + (                    
                   Isnull(tbl.coating_value, 0) * Isnull(tbl_sgst.master_numvals, 0) ) ))                    
         ELSE (                    
           Isnull(Tbl.coating_value, 0) + ( Isnull(Tbl.coating_value, 0) * Tbl_SGST.master_numvals ) )                    
         END ))                    
           ELSE CONVERT(NUMERIC(18, 0), dc_mst.netamount) END ) AS netamount,                    
       dc_mst.remark,                    
       --CASE                    
       --  WHEN dc_mst.codc_type = 'D' THEN 'Draft'                    
       --  WHEN dc_mst.codc_type = 'C' THEN 'Cancel'                    
       --  WHEN dc_mst.codc_type = 'F' THEN 'Open'                    
       --  ELSE dc_mst.codc_type                    
       --/*( CASE  WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel' ELSE 'Open' END )*/                    
       --END                                          AS DCStatus,                    
        CASE  WHEN Tbl.pendingqty <= 0 THEN 'Close'                                                          
                ELSE ( CASE   WHEN dc_mst.codc_type = 'D' THEN 'Draft'                                                          
                         ELSE ( CASE     WHEN dc_mst.codc_type = 'C' THEN 'Cancel'                                                          
         ELSE 'Open'                                                          
                                END )                                                          
                       END )                                                          
        END   AS DCStatus,                   
       doc_img_name,                    
       dc_mst.packing_charge,                    
       dc_mst.godown_id,                    
       m_godown.godown_name,                    
       m_godown.godown_address,                    
       CASE                    
         WHEN dc_mst.igst = 0 THEN CONVERT(BIT, 0)                    
         ELSE CONVERT(BIT, 1)                    
       END                                          AS Is_IGST,                    
       dc_mst.issue_byid,                    
       m_employee.emp_name                          AS IssueBy,                    
       Tbl_Ent.emp_name                             AS EntryBy                    
FROM   dc_mst WITH (nolock)   
       LEFT JOIN M_Department AS D WITH (nolock) ON D.Dept_ID = DC_Mst.Dept_ID
       LEFT JOIN m_employee WITH (nolock) ON dc_mst.issue_byid = m_employee.emp_id                    
       LEFT JOIN m_employee AS Tbl_Ent WITH (nolock) ON dc_mst.entry_user = Tbl_Ent.emp_id                    
       LEFT JOIN m_godown WITH (nolock) ON dc_mst.godown_id = m_godown.godown_id                    
       OUTER apply (SELECT Sum(Isnull(dc_dtl.pending_qty, 0)) AS PendingQty,                    
                           Sum(Isnull(coating_value, 0))      AS Coating_Value                    
                    FROM   DC_Dtl WITH (nolock)                    
                    WHERE  dc_dtl.dc_id = dc_mst.dc_id) AS Tbl                    
       LEFT JOIN m_master AS Tbl_Shade WITH (nolock) ON dc_mst.coating_shadeid = Tbl_Shade.master_id                    
       LEFT JOIN m_master AS Tbl_CGST WITH (nolock) ON dc_mst.cgst = Tbl_CGST.master_id                    
       LEFT JOIN m_master AS Tbl_SGST WITH (nolock) ON dc_mst.sgst = Tbl_SGST.master_id                    
       LEFT JOIN m_master AS Tbl_IGST WITH (nolock) ON dc_mst.igst = Tbl_IGST.master_id                    
       LEFT JOIN m_master AS Tbl_CGST_MV WITH (nolock) ON dc_mst.cgst_mv = Tbl_CGST_MV.master_id                    
       LEFT JOIN m_master AS Tbl_SGST_MV WITH (nolock) ON dc_mst.sgst_mv = Tbl_SGST_MV .master_id                    
       LEFT JOIN m_master AS Tbl_IGST_MV WITH (nolock) ON dc_mst.igst_mv = Tbl_IGST_MV .master_id                    
LEFT JOIN m_employee AS Tbl_SiteEnginner WITH (nolock) ON dc_mst.siteenginner_id = Tbl_SiteEnginner.emp_id                    
       LEFT JOIN m_project WITH (nolock) ON dc_mst.project_id = m_project.project_id                    
      LEFT JOIN m_supplier WITH (nolock) ON dc_mst.supplier_id = m_supplier.supplier_id                    
       LEFT JOIN m_master AS Tbl_SupState WITH (nolock) ON m_supplier.state_id = Tbl_SupState.master_id                
    WHERE  dc_mst.codc_type <> 'Delete DC'  
    AND dc_mst.Dept_ID = @Dept_Id
   AND dc_mst.dc_type = @_dc_type --'CO-DC'      
  and  DC_Mst.DC_Date between @FDate and @TDate               
    AND DC_Mst.CODC_Type  = (Case When @_CODC_Type = 'F' then  'F' else DC_Mst.CODC_Type end )                  
       AND dc_mst.dc_id = CASE                    
                            WHEN @DC_Id = 0 THEN dc_mst.dc_id                    
                            ELSE @DC_Id                    
                          END                    
       AND dc_mst.supplier_id = CASE                    
                                  WHEN @Supplier_Id = 0 THEN dc_mst.supplier_id                    
                                  ELSE @Supplier_Id                    
                                END                    
ORDER  BY dc_mst.entry_date DESC                        
/**********************************************************************/                    
/****************************** Details Query ****************************************/                    
  
  select * from   DC_Dtl WITH (nolock)  where DC_Dtl.DC_Id = -1
                    
 -- SELECT   ROW_NUMBER() OVER ( PARTITION BY dc_dtl.dc_id       ORDER BY DC_Dtl.DCDtl_Id ASC ) SrNo,              
 -- --Row_number()   OVER(  ORDER BY dc_dtl.dc_id)                AS SrNo,                                                               
 --     dc_mst.DC_No,                                    
 --     DC_Dtl.DCDtl_Id,                                                            
 --     dc_dtl.dc_id,                                                            
 --     dc_dtl.dept_id,                             
 --     m_department.dept_name,                                                            
 --     m_item.item_group_id,                                                            
 --     m_item.item_code,                                           
 --     m_item_group.item_group_name,                                                            
 --     m_item.item_cate_id,                                                            
 --     m_item_category.item_cate_name,                                                            
 --     dc_dtl.item_id,                                                            
 --     m_item.item_name,                                                            
 --     m_item.hsn_code,                                                            
 --     dc_dtl.calc_area,                                                            
 --     dc_dtl.weight_mtr AS [Weight],                                                            
 --     dc_dtl.qty,                                    
 --     DC_Dtl.Pending_Qty ,                            
 --     dc_dtl.unit_id,                                                            
 --     tbl_Unit.master_vals                           AS Unit,                                                            
 --     dc_dtl.itemlength,                                                            
 --     dc_dtl.rate,                                                            
 --     dc_dtl.totalvalue,                                                            
 --     dc_dtl.remark,                                                         
 --      CASE                    
 --        WHEN dc_mst.codc_type = 'D' THEN 'Draft'                    
 --        WHEN dc_mst.codc_type = 'C' THEN 'Cancel'                    
 --        WHEN dc_mst.codc_type = 'F' THEN 'Open'                    
 --        ELSE dc_mst.codc_type                   
 --      /*( CASE                                            
 --                        WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                            
 --                        ELSE 'Open'                                            
 --                      END )*/                    
 --      END                                          AS DCStatus,             
 --     dc_dtl.dc_qty,                                                            
 --     dc_dtl.running_feet,                                                            
 --     dc_dtl.rate_feet,                                                            
 --     CONVERT(NUMERIC(18, 0), dc_dtl.coating_value)  AS coating_value,                                        
 --     dc_dtl.total_weight,                                                            
 --     CONVERT(NUMERIC(18, 0), dc_dtl.material_value) AS material_value,                                                            
 --     dc_dtl.scrap_qty,                                                            
 --     dc_dtl.scrap_length  ,                              
 --     DC_Dtl.DC_Width   ,                                                          
 --     DC_Dtl.Scrap_Width ,                                                          
 --     DC_Dtl.Tray_Dimension,                                                          
 --      DC_Dtl.Img_Name ,                                                    
 --   m_item.ImageName ,                                 
 --   DC_Dtl.Godown_Id    ,                              
 --   dc_dtl.Stock_Id AS Id  ,                            
 --   StockView.Length ,                         
 --   StockView.Width    ,                        
 -- CONVERT(bit,0) IsRevision     ,               
 --DC_Dtl.Is_Revision      ,           
 -- CONVERT(bit,0) Is_Delete              
 -- FROM   DC_Dtl WITH (nolock)                                
 -- LEFT JOIN StockView WITH (nolock)  ON dc_dtl.Stock_Id = StockView.Id                              
 --     LEFT JOIN m_master AS tbl_Unit WITH (nolock)  ON dc_dtl.unit_id = tbl_Unit.master_id                                                            
 --     LEFT JOIN m_department WITH (nolock)  ON dc_dtl.dept_id = m_department.dept_id                                                            
 --     LEFT JOIN dc_mst WITH (nolock)  ON dc_dtl.dc_id = dc_mst.dc_id                                                            
 --     LEFT JOIN m_item WITH (nolock)  ON dc_dtl.item_id = m_item.item_id                                                            
 --     LEFT JOIN m_item_group WITH (nolock)  ON m_item.item_group_id = m_item_group.item_group_id                                                            
 --     LEFT JOIN m_item_category WITH (nolock)  ON m_item.item_cate_id = m_item_category.item_cate_id                                                            
 --WHERE DC_Mst.CODC_Type <> 'Delete DC'                                     
 -- AND    dc_mst.dc_type = @_dc_type --'CO-DC'       
 -- and  DC_Mst.DC_Date between @FDate and @TDate    
 --   AND DC_Mst.CODC_Type  = (Case When @_CODC_Type = 'F' then  'F' else DC_Mst.CODC_Type end )                  
 --     AND dc_dtl.dc_id = CASE  WHEN @DC_Id = 0 THEN dc_dtl.dc_id ELSE @DC_Id END                             
 --AND dc_mst.supplier_id = CASE WHEN @Supplier_Id = 0 THEN dc_mst.supplier_id ELSE @Supplier_Id END 
GO


