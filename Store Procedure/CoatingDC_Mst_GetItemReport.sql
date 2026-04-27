USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[CoatingDC_Mst_GetItemReport]    Script Date: 27-04-2026 11:11:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[CoatingDC_Mst_GetItemReport]                                       
                    
          @Dept_IDs  varchar(max) = '',                 
           @Supplier_Ids varchar(max) = '',                
         @fr_date date ='2022-04-22',              
         @Tr_date date ='2022-06-22',                   
           @Project_Ids varchar(max) = '',          
         @godown_ids varchar(max) = '' ,      
   @Status varchar(max) = '' ,      
  @ItemIds  varchar(max) = ''       
AS                                                          
    SET nocount ON                                                      
                                                         
  SELECT DC_Mst.DC_Id,                                                  
      DC_Mst.DC_Type,                                                  
      CODC_Type,                                                  
      DC_Mst.Invoice_No,                                                  
      DC_Mst.DC_No,                                                  
      DC_Mst.DC_Date,                                                  
      DC_Mst.project_id,                                                  
      DC_Mst.supplier_id,               
    M_Item.Item_Name,         
 DC_Dtl.ItemLength ,      
 M_Item.Item_Code ,      
 convert(numeric(18,0), DC_Dtl.Coating_Value) AS Coating_Value,      
  convert(numeric(18,0),DC_Dtl.Material_Value) AS Material_Value,      
      
    DATEDIFF(DAY,DC_Mst.DC_Date ,dbo.Get_Sysdate()) AS NoofDays,              
   Isnull(DC_Dtl.DC_Qty, 0) AS Qty_Pcs,              
 -- ((this._ObjDtl_Model.Weight * ( Isnull(DC_Dtl.ItemLength, 0) / 1000)) *  Isnull(DC_Dtl.DC_Qty, 0))  AS Qty_Kg,              
 DC_Dtl.Total_Weight AS Qty_Kg,      
   ISNULL(DC_Dtl.DC_Qty,0) - ISNULL(DC_Dtl.Pending_Qty,0) AS QtyReceive,              
   Tbl_GRNMS.GRNAmt AS AmtGRN,                                                
      M_Supplier.Supplier_Name,                                                  
      M_Supplier.contact_no                        AS Supplier_Contact_No,                                                  
      M_Supplier.contact_person                    AS Supplier_Contact_Person,                                                  
      M_Supplier.gst_no                            AS Supplier_GST_No,                                                  
      M_Supplier.address                           AS Supplier_Address,                                                  
      Tbl_SupState.master_vals                     AS Supplier_State,                                                  
      DC_Mst.siteenginner_id,                                                  
      Tbl_SiteEnginner.emp_name                    AS SiteEnginner,         
   M_Project.Project_Name,        
      DC_Mst.quotationno,                                                  
      DC_Mst.projectdocument,                                                  
      DC_Mst.transporttype,                                                  
      DC_Mst.vehicle_no,                                                  
      DC_Mst.driver_name,                                                  
      DC_Mst.contact_of_driver,                                                  
      DC_Mst.challantype,                                                  
      DC_Mst.Coating_ShadeId,                           
   Tbl_Shade.Master_Vals  coating_shade,                        
      DC_Mst.coating_rate,                                                  
      DC_Mst.aluminium_rate,                                                  
      CONVERT(NUMERIC(18, 0), DC_Mst.grossamount)  AS grossamount,                                                  
      DC_Mst.cgst,                                                  
      Tbl_CGST.Master_NumVals                         AS CGSTPer,                                                  
      DC_Mst.sgst,                                                  
      Tbl_SGST.Master_NumVals                         AS SGSTPer,                                                  
      DC_Mst.igst,                                                  
      Tbl_IGST.Master_NumVals                         AS IGSTPer,                                     
   Tbl_CGST.Master_Vals                         AS CGSTPer_Dis,                              
      Tbl_SGST.Master_Vals                         AS SGSTPer_Dis,                              
      Tbl_IGST.Master_Vals                         AS IGSTPer_Dis,                              
   Tbl_CGST_MV.Master_Vals                      AS CGSTPer_MV_Dis,                             
      Tbl_SGST_MV.Master_Vals                      AS SGSTPer_MV_Dis,                              
      Tbl_IGST_MV.Master_Vals   AS IGSTPer_MV_Dis,                            
      CONVERT(NUMERIC(18, 0), DC_Mst.CGSTTotal)    AS CGSTTotal,                                                  
      CONVERT(NUMERIC(18, 0), DC_Mst.SGSTTotal)    AS SGSTTotal,                                                  
      CONVERT(NUMERIC(18, 0), DC_Mst.IGSTTotal)    AS IGSTTotal,                                                  
      DC_Mst.cgst_mv,                                                  
      Tbl_CGST_MV.Master_NumVals                      AS CGST_MVPer,                            
      DC_Mst.sgst_mv,                                                  
      Tbl_SGST_MV.Master_NumVals                   AS SGST_MVPer,                                                  
      DC_Mst.igst_mv,                                
      Tbl_IGST_MV.Master_NumVals                      AS IGST_MVPer,                         
      CONVERT(NUMERIC(18, 0), DC_Mst.CGST_MVTotal) AS CGST_MVTotal,                                                  
      CONVERT(NUMERIC(18, 0), DC_Mst.SGST_MVTotal) AS SGST_MVTotal,                                    
      CONVERT(NUMERIC(18, 0), DC_Mst.IGST_MVTotal) AS IGST_MVTotal,                                                  
      CONVERT(NUMERIC(18, 0), DC_Mst.netamount)    AS netamount,                                                  
      DC_Mst.remark,                                                  
           CASE                           
             WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                  
    WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                  
    WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                  
             ELSE DC_Mst.CODC_Type                                  
    /*( CASE                                  
                      WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                  
                      ELSE 'Open'                                  
                    END )*/                                  
           END  AS DCStatus,                                          
      doc_img_name,                                                  
      DC_Mst.packing_charge,                                                  
      DC_Mst.godown_id,         
   '' AS FromGodown_Name,                                             
      M_Godown.Godown_Name,                                              
      m_godown.godown_address,                              
   case when DC_Mst.igst = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                                              
      DC_Mst.issue_byid,                                                  
      m_employee.emp_name                          AS IssueBy,                                                  
      Tbl_Ent.emp_name                             AS EntryBy                                                  
  FROM   DC_Dtl WITH (nolock)          
  LEFT JOIN DC_Mst WITH (nolock)  ON DC_Mst.DC_Id = DC_Dtl.DC_Id             
    LEFT JOIN M_Item WITH (nolock)  ON M_Item.Item_Id = DC_Dtl.Item_Id          
     outer Apply (              
   select SUM(ISNULL(GRN_Mst.NetAmount,0)) AS GRNAmt from GRN_Mst with(nolock) where GRN_Mst.PO_Id = DC_Mst.DC_Id              
                 
   ) AS Tbl_GRNMS           
          
      LEFT JOIN m_employee WITH (nolock)  ON DC_Mst.issue_byid = m_employee.emp_id                                                  
      LEFT JOIN m_employee AS Tbl_Ent WITH (nolock)  ON DC_Mst.entry_user = Tbl_Ent.emp_id                    
      LEFT JOIN m_godown WITH (nolock)  ON DC_Mst.godown_id = m_godown.godown_id    -- Return  Godown    (TO Godown_Name)    
      OUTER apply (SELECT Sum(Isnull(DC_Dtl.DC_Qty, 0))   AS OrderQty,                                     
      Sum( case when  Isnull(DC_Dtl.Pending_Qty, 0) > 0 then Isnull(DC_Dtl.Pending_Qty, 0) else 0 end  ) AS PendingQty          
      FROM   DC_Dtl WITH (nolock)                                            
                        WHERE  DC_Dtl.DC_Id = DC_Mst.DC_Id) AS Tbl1           
                
   OUTER apply (SELECT /*Sum(Isnull(DC_Dtl.Qty, 0))   AS OrderQty,        */                                        
                               Sum(Isnull(DC_Dtl.Pending_Qty, 0)) AS PendingQty                                                                  FROM   DC_Dtl WITH (nolock)                                                
                        WHERE  DC_Dtl.DC_Id = DC_Mst.DC_Id) AS Tbl                          
   LEFT JOIN m_master AS Tbl_Shade WITH (nolock)  ON DC_Mst.Coating_ShadeId = Tbl_Shade.master_id                               
      LEFT JOIN m_master AS Tbl_CGST WITH (nolock)  ON DC_Mst.cgst = Tbl_CGST.master_id                                                  
      LEFT JOIN m_master AS Tbl_SGST WITH (nolock)  ON DC_Mst.sgst = Tbl_SGST.master_id                                                  
      LEFT JOIN m_master AS Tbl_IGST WITH (nolock)  ON DC_Mst.igst = Tbl_IGST.master_id                                                  
      LEFT JOIN m_master AS Tbl_CGST_MV WITH (nolock)  ON DC_Mst.cgst_mv = Tbl_CGST_MV.master_id                                                  
      LEFT JOIN m_master AS Tbl_SGST_MV WITH (nolock)  ON DC_Mst.sgst_mv = Tbl_SGST_MV .master_id                                            
      LEFT JOIN m_master AS Tbl_IGST_MV WITH (nolock)  ON DC_Mst.igst_mv = Tbl_IGST_MV .master_id                                                  
      LEFT JOIN m_employee AS Tbl_SiteEnginner WITH (nolock)  ON DC_Mst.siteenginner_id = Tbl_SiteEnginner.emp_id                                                  
      LEFT JOIN m_project WITH (nolock)  ON DC_Mst.project_id = m_project.project_id                                                  
      LEFT JOIN M_Supplier WITH (nolock) ON DC_Mst.supplier_id = M_Supplier.supplier_id                                                  
      LEFT JOIN m_master AS Tbl_SupState WITH (nolock)  ON M_Supplier.state_id = Tbl_SupState.master_id                                                  
  WHERE  DC_Mst.dc_type =  'CO-DC'                                
   AND DC_Mst.CODC_Type <> 'Delete DC'            
     and CONVERT(DATE, dbo.DC_Mst.DC_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)          
    AND ( ( @Dept_IDs = '' )                          
                  OR ( @Dept_IDs <> ''                          
                       AND dbo.DC_Dtl.Dept_ID IN (SELECT items FROM dbo.STSplit(@Dept_IDs) )                          
                     )                          
                )             
        AND ( ( @Supplier_Ids = '' )                          
                  OR ( @Supplier_Ids <> ''                          
                       AND dbo.DC_Mst.Supplier_Id IN (SELECT items FROM dbo.STSplit(@Supplier_Ids) )                          
                     )                          
                )             
        AND ( ( @godown_ids = '' )                          
                  OR ( @godown_ids <> ''                          
                       AND dbo.DC_Mst.Godown_Id IN (SELECT items FROM dbo.STSplit(@godown_ids) )                          
 )                          
                )    
       AND ( ( @Project_Ids = '' )                          
                  OR ( @Project_Ids <> ''                          
                       AND dbo.DC_Mst.Project_Id IN (SELECT items FROM dbo.STSplit(@Project_Ids) )                          
                     )                          
                )        
  --AND (  CASE                           
  --  WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                  
  --  WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                  
  --  WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                  
  --  ELSE DC_Mst.CODC_Type                                    
  -- END ) = ( Case When @Status = 'All' then (  CASE                           
  --     WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                  
  --     WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                  
  --     WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                  
  --     ELSE DC_Mst.CODC_Type                                     
  --    END ) else @Status end   )      
      
   AND ( ( @ItemIds = '' )                          
                  OR ( @ItemIds <> ''                          
                       AND dbo.DC_Dtl.Item_Id IN (SELECT items FROM dbo.STSplit(@ItemIds) )                          
                     )                          
                )          
  ORDER  BY M_Item.Item_Name,DC_Mst.entry_date DESC 
GO


