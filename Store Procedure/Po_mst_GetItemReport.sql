USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Po_mst_GetItemReport]    Script Date: 27-04-2026 13:14:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER  PROCEDURE [dbo].[Po_mst_GetItemReport]                  
          @Dept_IDs  varchar(max) = '',               
           @Supplier_Ids varchar(max) = '',              
         @fr_date date ='2022-04-22',            
         @Tr_date date ='2022-06-22',            
         @godown_ids varchar(max) = '',            
         @Project_Ids varchar(max) = '',            
         @Item_Ids varchar(max) = ''             
            
AS                                      
    SET nocount ON                                      
                                      
    SELECT PO_MST.po_id,                                      
           PO_MST.po_type,         
   M_Item.Item_Name,  
   M_Item.Item_Code ,  
           order_type,                                      
           PO_MST.dept_id,                                      
           M_Department.dept_name,                                      
           PO_MST.invoice_no,                                      
           PO_MST.orderno,                                      
           PO_MST.po_date,                                        
           PO_MST.po_date AS GRN_Date,                                    
     DATEDIFF(DAY,PO_MST.po_date,dbo.Get_Sysdate()) AS NoofDays,        
   ISNULL(PO_DTL.OrderQty,0) AS Qty_Pcs,        
  ((Isnull(PO_DTL.Weight, 0) * Isnull(PO_DTL.Length, 0) * Isnull(PO_DTL.OrderQty, 0)) / 1000)  AS Qty_Kg,        
   ISNULL(PO_DTL.OrderQty,0) - ISNULL(PO_DTL.PendingQty,0) AS QtyReceive,        
   0 AS AmtGRN,        
           PO_MST.reqraisedby_id,                                      
           Tbl_ReqRaisedBy.emp_name     AS ReqRaisedBy,                                      
           PO_MST.billingaddress,                                      
           PO_MST.supplier_id,                                      
           M_Supplier.supplier_name,                                      
           M_Supplier.address           AS SupplierAddress,                                      
           M_Supplier.gst_no            AS SupplierGSTNO,                                      
           Tbl_State.master_vals        AS SupplierState,                                      
           PO_MST.godown_id,                                      
           M_Godown.godown_name,                                      
           M_Godown.godown_address      AS ShippingAddress,                                      
           CONVERT( numeric(18,0), PO_MST.grossamount) AS grossamount,                                      
           PO_MST.advanceamount,  
           PO_MST.Admin_Charges,
           PO_MST.Insurance,
           PO_MST.Freight_Charges,
           PO_MST.Other_Charges,
           PO_MST.netamount,                                      
           PO_MST.paymentterms,                                      
           PO_MST.deliveryterms,                                      
           PO_MST.additionalterms,                                      
           PO_MST.authoriseperson_id,                                      
           Tbl_AuthorisePerson.emp_name AS AuthorisePerson,                                      
           PO_MST.approvedate,                                      
           PO_MST.remark,                                      
            CASE                                    
             WHEN PO_DTL.PendingQty <= 0 THEN 'Close'                                    
             ELSE ( CASE WHEN PO_MST.po_type = 'D' THEN 'Draft'                                    
                      ELSE ( CASE WHEN PO_MST.po_type = 'C' THEN 'Cancel'                            
          WHEN PO_MST.po_type = 'Q' THEN 'Force Close'                           
          WHEN PO_MST.po_type = 'X' THEN 'Delete'                           
                               ELSE 'Open'                                    
                             END )                                    
                    END )                                    
           END                          AS POStatus,                                    
           PO_DTL.OrderQty,                                    
           PO_DTL.PendingQty, PO_Dtl.UnitCost,                                   
    CASE                                    
             WHEN PO_DTL.PendingQty = PO_DTL.OrderQty                                    
              AND PO_MST.po_type != 'C' THEN 'Cancel'                                    
             ELSE ''                                    
           END                          AS IsCancel,                                           
           Tbl_CGST.master_numvals      AS CGSTPer,                                      
           Tbl_SGST.master_numvals      AS SGSTPer,                                      
           Tbl_IGST.master_numvals      AS IGSTPer,                                      
           PO_MST.cgst,                                      
           PO_MST.sgst,                                      
           PO_MST.igst,                                      
            CONVERT( numeric(18,3), PO_MST.cgsttotal ) AS cgsttotal,                                      
            CONVERT( numeric(18,3), PO_MST.sgsttotal ) AS sgsttotal,                                      
            CONVERT( numeric(18,3), PO_MST.igsttotal ) AS igsttotal,                               
    case when PO_MST.igst = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                            
           Tbl_User.emp_name            AS EntryUserName,                             
           Tbl_User.personal_no         AS EntryUserNo ,                                      
     Doc_Img_Name  ,                  
     PO_MST.Revision  ,  
  M_Project.Project_Name ,  
  M_SupplierDtl.SupItem_Code,  
  PO_DTL.Length,
  PO_DTL.Width,
  PO_DTL.Charg_Height,
  PO_DTL.Charg_Weight,
  PO_DTL.TotalWeight AS Total_Weight,
  PO_DTL.Discount_Percentage
 FROM   PO_DTL WITH (nolock)           
  left join M_SupplierDtl  with(nolock)  ON PO_DTL.SupDetail_Id = M_SupplierDtl.SupDetail_Id   
   left join PO_MST  with(nolock)  ON PO_DTL.PO_Id = PO_MST.PO_Id      
   left join M_Project  with(nolock)  ON PO_DTL.Project_Id = M_Project.Project_Id  
   left join M_Item  with(nolock)  ON PO_DTL.Item_Id = M_Item.Item_Id      
   outer Apply (        
   select SUM(ISNULL(GRN_Mst.NetAmount,0)) AS GRNAmt from GRN_Mst with(nolock) where GRN_Mst.PO_Id = PO_MST.PO_Id        
           
   ) AS Tbl_GRNMS        
           LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)    ON PO_MST.cgst = Tbl_CGST. master_id                                      
           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)     ON PO_MST.sgst = Tbl_SGST. master_id                                      
           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)  ON PO_MST.igst = Tbl_IGST.master_id                                      
           LEFT JOIN m_employee AS Tbl_User WITH(nolock)      ON PO_MST.entry_user = Tbl_User.emp_id                                      
      --     OUTER apply (SELECT Sum(Isnull(po_dtl.orderqty, 0))   AS OrderQty,                               
      --Sum( case when  Isnull(po_dtl.pendingqty, 0) > 0 then Isnull(po_dtl.pendingqty, 0) else 0 end  ) AS PendingQty ,       
              
      
      --Sum(((Isnull(PO_DTL.Weight, 0) * Isnull(PO_DTL.Length, 0) * Isnull(PO_DTL.OrderQty, 0)) / 1000)) AS TotalWeight      
      
      
      --                         /*Sum(Isnull(po_dtl.pendingqty, 0)) AS PendingQty        */                              
      --                  FROM   po_dtl WITH (nolock)                                      
      --                  WHERE  po_dtl.po_id = PO_MST.po_id) AS Tbl                                      
           LEFT JOIN M_Godown WITH (nolock)  ON PO_MST.godown_id = M_Godown.godown_id                                      
           LEFT JOIN m_department WITH (nolock)      ON PO_MST.dept_id = m_department.dept_id                                      
           LEFT JOIN m_employee AS Tbl_ReqRaisedBy WITH (nolock)  ON PO_MST.reqraisedby_id = Tbl_ReqRaisedBy.emp_id                                      
           LEFT JOIN m_employee AS Tbl_AuthorisePerson WITH (nolock) ON PO_MST.authoriseperson_id = Tbl_AuthorisePerson.emp_id                                      
           LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.supplier_id = M_Supplier.supplier_id                                      
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.master_id                                      
    WHERE   PO_MST.po_type <> 'X'         
  and CONVERT(DATE, dbo.PO_MST.PO_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)               
        AND ( ( @Dept_IDs = '' )                        
                  OR ( @Dept_IDs <> ''                        
                       AND dbo.PO_MST.Dept_ID IN (SELECT items FROM dbo.STSplit(@Dept_IDs) )                        
                     )                        
  )           
        AND ( ( @Supplier_Ids = '' )                        
                  OR ( @Supplier_Ids <> ''                        
                       AND dbo.PO_MST.Supplier_Id IN (SELECT items FROM dbo.STSplit(@Supplier_Ids) )                        
                     )                        
                )           
        AND ( ( @godown_ids = '' )                        
                  OR ( @godown_ids <> ''                        
                       AND dbo.PO_MST.Godown_Id IN (SELECT items FROM dbo.STSplit(@godown_ids) )                        
                     )                        
                )           
        AND ( ( @Project_Ids = '' )                        
                  OR ( @Project_Ids <> ''                        
                       AND dbo.PO_DTL.Project_Id IN (SELECT items FROM dbo.STSplit(@Project_Ids) )                        
                     )                        
                ) 
        AND ( ( @Item_Ids = '' )                        
                  OR ( @Item_Ids <> ''                        
                       AND dbo.PO_DTL.Item_Id IN (SELECT items FROM dbo.STSplit(@Item_Ids) )                        
                     )                        
                ) 				
    ORDER  BY M_Item.Item_Name ASC      
                                      
    /* ------------------------------------------------------------ */                                      
   -- SELECT Row_number()                                      
   --          OVER(                                      
   --            ORDER BY podtl_id)            AS SrNo,                                      
   --        PO_MST.orderno,                                      
   --        po_dtl.podtl_id,                                      
   --        po_dtl.po_id,                                      
   --        m_item.item_group_id,                    
   --        m_item_group.item_group_name,                                      
   --        m_item.item_cate_id,                                      
   --        m_item_category.item_cate_name,                                      
   --        po_dtl.item_id,                      
   --        m_item.item_name,                            
   --  m_item.Item_Code ,                          
   --        m_item.hsn_code,                                      
   --        po_dtl.supdetail_id,                                      
   --        m_supplierdtl.supitem_code,                                      
   --        po_dtl.orderqty,                                      
   --        /*ISNULL(PO_DTL.PendingQty,0)*/ 0 AS ReceiveQty,                                      
   --        Isnull(po_dtl.pendingqty, 0)      AS PendingQty,                                      
   --        po_dtl.unit_id,                                      
   --        Tbl_Unit.master_vals              AS Unit,                                      
   --        po_dtl.length,                                      
   --        po_dtl.weight,                                      
   --        po_dtl.totalweight,                                      
   --        po_dtl.unitcost,                        
   --        po_dtl.unitcost                   AS RUnitCost,                                      
   --       CONVERT( numeric(18,0), po_dtl.totalcost) AS totalcost,                                      
   --        po_dtl.remark,                                      
   --        CASE                             
   --          WHEN (case when  Isnull(po_dtl.pendingqty, 0) > 0 then Isnull(po_dtl.pendingqty, 0) else 0 end) <= 0 THEN 'Close'                                      
   --          ELSE 'Open'                                      
   --        END                               AS POStatus,                                      
   --        CONVERT(BIT, 0)                   AS IsSeletd,                        
   --        0                                 AS GrnDtl_Id,                                      
   --        0                                 AS GRN_Id,                                      
   --        po_dtl.project_id,                                      
   --        m_item.imagename,                                      
   --        m_project.project_name  ,                                
   --PO_DTL.Width  ,                        
   -- null AS Rack_Id                        
   -- FROM   po_dtl WITH (nolock)        
   --        LEFT JOIN m_project WITH (nolock)  ON po_dtl.project_id = m_project.project_id                                      
   --        LEFT JOIN PO_MST WITH (nolock) ON po_dtl.po_id = PO_MST.po_id                                      
   --        LEFT JOIN M_Master AS Tbl_Unit WITH (nolock)   ON po_dtl.unit_id = Tbl_Unit.master_id                                      
   --LEFT JOIN m_supplierdtl WITH (nolock) ON po_dtl.supdetail_id = m_supplierdtl.supdetail_id                                      
   --        LEFT JOIN m_item WITH (nolock) ON po_dtl.item_id = m_item.item_id                                      
   --        LEFT JOIN m_item_group WITH (nolock)   ON m_item.item_group_id = m_item_group.item_group_id                                      
   --        LEFT JOIN m_item_category WITH (nolock)   ON m_item.item_cate_id = m_item_category.item_cate_id                                      
   -- WHERE  PO_MST.order_type = 'PO'                  
   --and  PO_MST.Dept_ID  = case when   @Dept_ID = 0 then PO_MST.Dept_ID else @Dept_ID end                
   --        AND po_dtl.po_id = CASE                                      
   --                            WHEN @PO_Id = 0 THEN po_dtl.po_id                                      
   --                             ELSE @PO_Id                                      
   --                           END                                      
   --        AND PO_MST.supplier_id = CASE                                      
   --                                   WHEN @Supplier_Id = 0 THEN                                      
   --                                   PO_MST.supplier_id                                      
   --                                   ELSE @Supplier_Id                                      
   --                                 END                                      
   --        AND PO_MST.po_type = CASE                    
   --                               WHEN @PO_Type = '' THEN PO_MST.po_type                                      
   --                               ELSE @PO_Type                                      
   --                             END                                      
   -- ORDER  BY PO_MST.po_id DESC 
