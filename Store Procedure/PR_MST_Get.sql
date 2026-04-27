USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PR_MST_Get]    Script Date: 27-04-2026 14:32:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  PROCEDURE [dbo].[PR_MST_Get] @PO_Id       INT = 1011,                
                                    @Dept_ID int = 0,                  
                                    @Supplier_Id INT =0,                                        
                                    @PO_Type     VARCHAR(1)=''  ,          
                                    @fr_date date ='2022-04-22',          
                                    @Tr_date date ='2022-06-22',                                          
                                    @Order_Type     VARCHAR(100)=''                                       
AS                                        
    SET nocount ON                                        
                                        
    SELECT PR_MST.PR_Id,                                        
           PR_MST.PO_Type,                                        
           Order_Type,                                           
           case when Order_Type ='PR-GL' then  'Glass PO'        
    when Order_Type ='PR-HW' then  'Hardware PO' 
    when Order_Type = 'PR-UPVC' then 'UPVC PO'
    when Order_Type = 'PR-RF' then 'Reinforcement PO'
    when Order_Type = 'PR-SH' then 'Sheet PO'
    when Order_Type = 'PR-ALU' then 'Aluminium PO'
     else         
     Order_Type        
     end        
     AS Order_Type2,                                         
           PR_MST.Dept_ID,                                        
           m_department.Dept_Name,                                        
           PR_MST.Invoice_No,                                        
           PR_MST.OrderNo,                                        
           PR_MST.PO_Date,                                        
           PR_MST.ReqRaisedBy_Id,                                        
           Tbl_ReqRaisedBy.Emp_Name     AS ReqRaisedBy,                                        
           PR_MST.BillingAddress,                                        
           PR_MST.Supplier_Id,                                        
           M_Supplier.Supplier_Name,                                        
           M_Supplier.Address           AS SupplierAddress,                                        
           M_Supplier.GST_No            AS SupplierGSTNO,                                        
           Tbl_State.Master_Vals        AS SupplierState,                                        
           PR_MST.Godown_Id,                                        
           M_Godown.Godown_Name,                                        
           M_Godown.Godown_Address      AS ShippingAddress,                                        
           CONVERT( numeric(18,0), PR_MST.GrossAmount) AS grossamount,                                        
           PR_MST.AdvanceAmount,                                        
           PR_MST.NetAmount,                                        
           PR_MST.PaymentTerms,                                        
           PR_MST.DeliveryTerms,                                        
           PR_MST.AdditionalTerms,                                        
           PR_MST.AuthorisePerson_Id,                                        
           Tbl_AuthorisePerson.Emp_Name AS AuthorisePerson,                                        
           PR_MST.ApproveDate,                                        
           PR_MST.Remark,                                        
           CASE                                        
             WHEN Tbl.PendingQty <= 0 THEN 'Close'                                        
             ELSE ( CASE WHEN PR_MST.PO_Type = 'D' THEN 'Draft'                                        
                      ELSE ( CASE WHEN PR_MST.PO_Type = 'P' THEN 'Pending Approval'                                
          WHEN PR_MST.PO_Type = 'PP' THEN 'Pending Checked'                               
          WHEN PR_MST.PO_Type = 'F' THEN 'PR Created'                               
                               ELSE 'Open'                                        
                             END )                                        
                    END )                                        
           END                          AS POStatus,                                        
           Tbl.OrderQty,  
           PR_MST.DiscountPercentageOverall,
           Tbl.PendingQty,                                                   CASE                                        
             WHEN Tbl.PendingQty = Tbl.OrderQty                               
                  AND PR_MST.PO_Type != 'C' THEN 'Cancel'            
             ELSE ''                                        
           END                          AS IsCancel,                                      
           Tbl_CGST.Master_NumVals      AS CGSTPer,                                        
           Tbl_SGST.Master_NumVals      AS SGSTPer,                                        
           Tbl_IGST.Master_NumVals      AS IGSTPer,                                        
           PR_MST.CGST,                              
           PR_MST.SGST,                                        
           PR_MST.IGST,                      
            CONVERT( numeric(18,0), PR_MST.CGSTTotal ) AS cgsttotal,                                        
            CONVERT( numeric(18,0), PR_MST.SGSTTotal ) AS sgsttotal,                                        
            CONVERT( numeric(18,0), PR_MST.IGSTTotal ) AS igsttotal,                                 
   case when PR_MST.IGST = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                              
           Tbl_User.Emp_Name            AS EntryUserName,                               
           Tbl_User.Personal_No         AS EntryUserNo ,               
   Doc_Img_Name  ,                    
     PR_MST.Revision  ,              
     PR_MST.Admin_Charges,              
     PR_MST.Insurance,              
     PR_MST.Other_Charges  ,            
     PR_MST.Freight_Charges,
     PR_MST.CheckedBy_Id,
     PR_MST.AuthorizedBy_Id,
     Tbl_CheckedBy.Emp_Name as CheckedBy_Name,
     Tbl_AuthorizedBy.Emp_Name as AuthorizedBy_Name
 FROM   PR_MST WITH (nolock)                                        
           LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)    ON PR_MST.cgst = Tbl_CGST. master_id                                        
           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)     ON PR_MST.sgst = Tbl_SGST. master_id                                        
           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)  ON PR_MST.igst = Tbl_IGST.master_id                                        
           LEFT JOIN m_employee AS Tbl_User WITH(nolock)      ON PR_MST.entry_user = Tbl_User.emp_id                                        
           OUTER apply (SELECT Sum(Isnull(PR_DTL.orderqty, 0))   AS OrderQty,                                 
								Sum( case when  Isnull(PR_DTL.pendingqty, 0) > 0 then Isnull(PR_DTL.pendingqty, 0) else 0 end  ) AS PendingQty                                        
                               /*Sum(Isnull(PO_DTL.pendingqty, 0)) AS PendingQty        */                                
                        FROM   PR_DTL WITH (nolock)                                        
                        WHERE  PR_DTL.PR_Id = PR_DTL.PR_Id) AS Tbl                                        
           LEFT JOIN m_godown WITH (nolock)  ON PR_MST.godown_id = m_godown.godown_id                                        
           LEFT JOIN m_department WITH (nolock)      ON PR_MST.dept_id = m_department.dept_id                                        
           LEFT JOIN m_employee AS Tbl_ReqRaisedBy WITH (nolock)  ON PR_MST.reqraisedby_id = Tbl_ReqRaisedBy.emp_id 
           LEFT JOIN m_employee AS Tbl_AuthorisePerson WITH (nolock) ON PR_MST.authoriseperson_id = Tbl_AuthorisePerson.emp_id
           LEFT JOIN m_employee AS Tbl_CheckedBy WITH (nolock) ON PR_MST.CheckedBy_Id = Tbl_CheckedBy.emp_id
           LEFT JOIN m_employee AS Tbl_AuthorizedBy WITH (nolock)  ON PR_MST.AuthorizedBy_Id = Tbl_AuthorizedBy.emp_id
           OUTER APPLY (
                SELECT TOP 1 PR_DTL.Supplier_Id
                FROM PR_DTL WITH (NOLOCK)
                WHERE PR_DTL.PR_Id = PR_MST.PR_Id
                ORDER BY PR_DTL.PRDtl_Id
            ) AS DtlSupplier
           LEFT JOIN M_Supplier ON DtlSupplier.Supplier_Id = M_Supplier.supplier_id                                     
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.master_id                                        
    WHERE  --PO_MST.PO_Type <> 'X' 
    PR_MST.PO_Type NOT IN ('X')
	 and CONVERT(DATE, dbo.PR_MST.PO_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)      
   AND PR_MST.Order_Type = case when   @Order_Type = '' then PR_MST.Order_Type else @Order_Type end  -- @Order_Type /*'PO'*/        
   and  PR_MST.Dept_ID  = case when   @Dept_ID = 0 then PR_MST.Dept_ID else @Dept_ID end                  
           AND PR_MST.PR_Id = CASE   
                              WHEN @PO_Id = 0 THEN PR_MST.PR_Id                                        
                                ELSE @PO_Id          
                              END                                        
          -- AND PR_MST.supplier_id = CASE                                        
              --    WHEN @Supplier_Id = 0 THEN                                        
                            --          PR_MST.supplier_id                                        
                           --           ELSE @Supplier_Id                                        
           -- END                                        
           AND PR_MST.PO_Type = CASE                                        
                                  WHEN @PO_Type = '' THEN PR_MST.PO_Type                                        
                                  ELSE @PO_Type                                        
                                END                                        
    ORDER  BY PR_MST.PR_Id DESC                                        
                                        
    /* ------------------------------------------------------------ */                                        
    SELECT Row_number()                                        
             OVER(                                        
               ORDER BY PRDtl_Id )            AS SrNo,                                        
           PR_MST.OrderNo,                                        
           PR_DTL.PRDtl_Id,                                       
           PR_DTL.PR_Id,         
    PR_MST.PO_Date,    
    M_Supplier.Supplier_Name as Supplier_Name,
    M_Supplier.Supplier_Id,
           M_Item.Item_Group_Id,                                        
           M_Item_Group.Item_Group_Name,                                        
           M_Item.Item_Cate_Id,               
   M_Item_Category.Item_Cate_Name,                                        
           PR_DTL.Item_Id,                                        
           M_Item.Item_Name,                              
   M_Item.Item_Code ,                            
           M_Item.HSN_Code,                                        
           M_SupplierDtl.SupDetail_Id,                                        
           M_SupplierDtl.SupItem_Code,                                        
           PR_DTL.OrderQty,  
           PR_DTL.Discount_Percentage,
           /*ISNULL(PO_DTL.PendingQty,0)*/ 0 AS ReceiveQty,                                        
           Isnull(PR_DTL.PendingQty, 0)      AS PendingQty,                                        
           PR_DTL.Unit_Id,                                        
           Tbl_Unit.Master_Vals              AS Unit,  
           Tbl_AlternteUnit.Master_Vals      AS AlternteUnit,
           M_Item.AlternateUnitValue      AS AlternateUnitValue,
           PR_DTL.Length,                                        
           PR_DTL.Weight,                                        
           PR_DTL.TotalWeight,                                        
           PR_DTL.UnitCost,                          
           PR_DTL.UnitCost                   AS RUnitCost,                                        
          CONVERT( numeric(18,0), PR_DTL.TotalCost) AS totalcost,                                        
           PR_DTL.Remark,                                        
           CASE                               
             WHEN (case when  Isnull(PR_DTL.pendingqty, 0) > 0 then Isnull(PR_DTL.pendingqty, 0) else 0 end) <= 0 THEN 'Close'                                        
             ELSE 'Open'                                        
           END                               AS POStatus,                                        
           CONVERT(BIT, 0)                   AS IsSeletd,                                        
           0                                 AS GrnDtl_Id,                                        
           0                                 AS GRN_Id,                                        
           PR_DTL.Project_Id,     
           M_Item.ImageName,                                        
           M_Project.Project_Name  ,                                  
     PR_DTL.Width  ,                          
     PO_Request_Dtl.Godown_Rack_Id AS Rack_Id   ,              
     PR_DTL.Charg_Height,              
     PR_DTL.Charg_Weight   ,          
     PR_DTL.Ref_Code          ,
     PR_DTL.Req_Id,
     PR_DTL.MR_Code,
     PR_DTL.Pd_Ref_No,
     PR_DTL.Length_Mtr AS Length_Meter
    FROM   PR_DTL WITH (nolock)                                        
           LEFT JOIN M_Project WITH (nolock)  ON PR_DTL.Project_Id = M_Project.Project_Id                                        
           LEFT JOIN PR_MST WITH (nolock) ON PR_DTL.PR_Id = PR_MST.PR_Id
            LEFT JOIN M_Item WITH (nolock) ON PR_DTL.item_id = M_Item.item_id  
   LEFT JOIN M_Supplier WITH (nolock) ON PR_DTL.supplier_id = M_Supplier.supplier_id
    LEFT JOIN M_SupplierDtl WITH (nolock) ON M_Supplier.supplier_id = M_SupplierDtl.Supplier_Id AND M_SupplierDtl.Item_Id = M_Item.item_id
           LEFT JOIN M_Master AS Tbl_Unit WITH (nolock)   ON PR_DTL.Unit_Id = Tbl_Unit.Master_Id
           LEFT JOIN M_Item_Group WITH (nolock)   ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id                                        
           LEFT JOIN M_Item_Category WITH (nolock)   ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id   
           LEFT JOIN BOM_PO_RequestDtl WITH (nolock)  ON PR_DTL.Req_Id = BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id
           LEFT JOIN PO_Request_Dtl WITH (nolock) ON BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id = PO_Request_Dtl.BOM_PO_ReqDtl_Id
           LEFT JOIN M_Master AS Tbl_AlternteUnit WITH (nolock)   ON M_Item.Alternate_Unit_Id = Tbl_AlternteUnit.Master_Id
    WHERE  PR_DTL.Is_Checked = 1
    and PR_MST.PO_Type NOT IN ('X')    
	 and CONVERT(DATE, dbo.PR_MST.PO_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)      
   AND PR_MST.Order_Type = case when   @Order_Type = '' then PR_MST.Order_Type else @Order_Type end--  @Order_Type /*'PO'*/                   
           and   PR_MST.Dept_ID  = case when   @Dept_ID = 0 then PR_MST.Dept_ID else @Dept_ID end                  
           AND PR_DTL.PR_Id = CASE                                        
                               WHEN @PO_Id = 0 THEN PR_DTL.PR_Id                                        
                                ELSE @PO_Id                                        
                              END                                        
          -- AND PR_MST.Supplier_Id = CASE                                     
                                   --   WHEN @Supplier_Id = 0 THEN                                        
                                    --  PR_MST.Supplier_Id                                        
                                    --  ELSE @Supplier_Id                                        
                                 --   END         
   AND PR_MST.PO_Type = CASE                                        
                                  WHEN @PO_Type = '' THEN PR_MST.PO_Type                                        
                                  ELSE @PO_Type                                        
                                END                                        
    ORDER  BY PR_MST.PR_Id DESC

GO


