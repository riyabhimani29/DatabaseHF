USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[CoatingDC_Mst_GetReport]    Script Date: 27-04-2026 11:12:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[CoatingDC_Mst_GetReport]                                                         
          @Dept_IDs  varchar(max) = '',                     
           @Supplier_Ids varchar(max) = '',                  
           @Project_Ids varchar(max) = '',                   
         @fr_date date ='2021-04-22',                  
         @Tr_date date ='2022-06-22',                  
         @godown_ids varchar(max) = ''  ,          
   @Status varchar(max) = ''                    
AS                                                                
    SET nocount ON                                                            
                                                       
  SELECT
      DC_Mst.DC_Id,                                                      
      DC_Mst.DC_Type,                                                      
      CODC_Type,                                                      
      DC_Mst.Invoice_No,                                                      
      DC_Mst.DC_No,                                                      
      DC_Mst.DC_Date,                                                      
      DC_Mst.project_id,                                                      
      DC_Mst.supplier_id,                   
                  
     DATEDIFF(DAY,DC_Mst.DC_Date ,dbo.Get_Sysdate()) AS NoofDays,                  
   ISNULL(Tbl1.OrderQty,0) AS Qty_Pcs,                  
  -- 0 AS Qty_Kg,             
    ISNULL(Tbl1.Qtykg,0)  AS Qty_Kg,            
   ISNULL(Tbl1.OrderQty,0) - ISNULL(Tbl.PendingQty,0) AS QtyReceive,
   ISNULL(Tbl1.TotalCoatingValue, 0) AS TotalCoatingValue,
   Tbl_GRNMS.GRNAmt AS AmtGRN,                
              
              
      M_Project.Project_Name,                                                      
      M_Supplier.Supplier_Name,                                                      
      M_Supplier.Contact_No                        AS Supplier_Contact_No,                                                      
      M_Supplier.Contact_Person                    AS Supplier_Contact_Person,                                                      
      M_Supplier.GST_No                            AS Supplier_GST_No,                                                      
      M_Supplier.Address                           AS Supplier_Address,                                                      
      Tbl_SupState.Master_Vals                     AS Supplier_State,                                                      
      DC_Mst.siteenginner_id,                                                      
      Tbl_SiteEnginner.Emp_Name                    AS SiteEnginner,                                                      
      DC_Mst.QuotationNo,                                                      
      DC_Mst.ProjectDocument,                                                      
      DC_Mst.TransportType,                                                      
      DC_Mst.Vehicle_No,                                                      
      DC_Mst.Driver_Name,                                                      
      DC_Mst.Contact_of_Driver,                                                      
      DC_Mst.ChallanType,                                                      
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
      Tbl_IGST_MV.Master_Vals                      AS IGSTPer_MV_Dis,                                
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
    --       CASE                               
    --WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                      
    --WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                      
    --WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                      
    --         ELSE DC_Mst.CODC_Type                                        
    --       END  AS DCStatus,    
        CASE  WHEN Tbl.pendingqty <= 0 THEN 'Close'                                                          
                ELSE ( CASE   WHEN dc_mst.codc_type = 'D' THEN 'Draft'                                                          
                         ELSE ( CASE     WHEN dc_mst.codc_type = 'C' THEN 'Cancel'                                                          
      ELSE 'Open'                                                          
                                END )                                                          
                       END )                                                          
        END   AS DCStatus,        
  
      doc_img_name,                                                      
      DC_Mst.packing_charge,                                                      
      DC_Mst.godown_id,            
   '' AS FromGodown_Name,        
      M_Godown.Godown_Name,                                                  
      m_godown.godown_address,                                  
   case when DC_Mst.igst = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                                                  
      DC_Mst.issue_byid,                                                      
      m_employee.emp_name                          AS IssueBy,                                                      
      Tbl_Ent.emp_name               AS EntryBy                                                      
  FROM   DC_Mst WITH (nolock)              
     outer Apply (                  
   select SUM(ISNULL(GRN_Mst.NetAmount,0)) AS GRNAmt from GRN_Mst with(nolock) where GRN_Mst.PO_Id = DC_Mst.DC_Id                  
    And GRN_Type = 'DC-GRN'                 
   ) AS Tbl_GRNMS               
              
      LEFT JOIN m_employee WITH (nolock)  ON DC_Mst.issue_byid = m_employee.emp_id                                                      
      LEFT JOIN m_employee AS Tbl_Ent WITH (nolock)  ON DC_Mst.entry_user = Tbl_Ent.emp_id                                                      
      LEFT JOIN m_godown WITH (nolock)  ON DC_Mst.godown_id = m_godown.godown_id    -- Return  Godown    (TO Godown_Name)        
      OUTER apply (SELECT Sum(Isnull(DC_Dtl.DC_Qty, 0))   AS OrderQty,                                         
      Sum( case when  Isnull(DC_Dtl.Pending_Qty, 0) > 0 then Isnull(DC_Dtl.Pending_Qty, 0) else 0 end  ) AS PendingQty  ,          
  Sum(Isnull(DC_Dtl.Total_Weight, 0)) AS Qtykg,         
  --Sum ((this._ObjDtl_Model.Weight * ( Isnull(DC_Dtl.ItemLength, 0) / 1000)) *  Isnull(DC_Dtl.DC_Qty, 0)) Qtykg          
      SUM(ISNULL(DC_Dtl.Coating_Value, 0)) AS TotalCoatingValue        
      FROM   DC_Dtl WITH (nolock)                                                
                        WHERE  DC_Dtl.DC_Id = DC_Mst.DC_Id) AS Tbl1               
                    
      OUTER apply (SELECT   Sum(Isnull(DC_Dtl.Pending_Qty, 0)) AS PendingQty                                                    
                        FROM   DC_Dtl WITH (nolock)                                      
                        WHERE  DC_Dtl.DC_Id = DC_Mst.DC_Id             
      and ( ( @Dept_IDs = '' )                              
         OR ( @Dept_IDs <> ''             
           AND dbo.DC_Dtl.Dept_ID IN (SELECT items FROM dbo.STSplit(@Dept_IDs) )                              
         )                              
       )             
    ) AS Tbl                              
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
  WHERE  DC_Mst.dc_type = 'CO-DC'                                    
   AND DC_Mst.CODC_Type <> 'Delete DC'                  
   and CONVERT(DATE, dbo.DC_Mst.DC_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)                           
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
      AND (
    @Dept_IDs = ''
    OR EXISTS (
        SELECT 1
        FROM DC_Dtl
        WHERE DC_Dtl.DC_Id = DC_Mst.DC_Id
          AND DC_Dtl.Dept_ID IN (SELECT items FROM dbo.STSplit(@Dept_IDs))
    )
)
      AND (case when @Status = 'All' then '1' else @Status end ) =(case when @Status = 'All' then '1' else (  CASE  WHEN Tbl.pendingqty <= 0 THEN 'Close'                                                          
                ELSE ( CASE   WHEN dc_mst.codc_type = 'D' THEN 'Draft'                                                          
                         ELSE ( CASE     WHEN dc_mst.codc_type = 'C' THEN 'Cancel' ELSE 'Open'     END )                                                          
                       END )                                                          
        END  )END ) --= @Status
   --AND (  CASE                               
   -- WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                      
   -- WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                      
   -- WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                      
   -- ELSE DC_Mst.CODC_Type                                         
   --END ) = ( Case When @Status = 'All' then (  CASE                               
   --    WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                                      
   --    WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                                      
   --    WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                                      
   --    ELSE DC_Mst.CODC_Type                                         
   --   END ) else @Status end   )          
  ORDER  BY DC_Mst.entry_date DESC
GO


