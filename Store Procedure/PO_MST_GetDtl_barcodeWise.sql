USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_GetDtl_barcodeWise]    Script Date: 27-04-2026 13:13:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PO_MST_GetDtl_barcodeWise] @PO_Id       INT = 5026,              
													@PODtl_Id int = 5040                                    
AS                                      
    SET nocount ON                                      
     
                                    
    SELECT PO_MST.PO_Id,                                      
           PO_MST.PO_Type,                                      
           Order_Type,                                         
           case when Order_Type ='PO-GL' then  'Glass PO'      
    when Order_Type ='PO-HW' then  'Hardware PO'      
     else       
     Order_Type      
     end      
     AS Order_Type2,                                       
           PO_MST.Dept_ID,                                      
           m_department.Dept_Name,                                      
           PO_MST.Invoice_No,                                      
           PO_MST.OrderNo,                                      
           PO_MST.PO_Date,                                      
           PO_MST.ReqRaisedBy_Id,                                      
           Tbl_ReqRaisedBy.Emp_Name     AS ReqRaisedBy,                                      
           PO_MST.BillingAddress,                                      
           PO_MST.Supplier_Id,                                      
           M_Supplier.Supplier_Name,                                      
           M_Supplier.Address           AS SupplierAddress,                                      
           M_Supplier.GST_No            AS SupplierGSTNO,                                      
           Tbl_State.Master_Vals        AS SupplierState,                                      
           PO_MST.Godown_Id,                                      
           M_Godown.Godown_Name,                                      
           M_Godown.Godown_Address      AS ShippingAddress,                                      
           CONVERT( numeric(18,0), PO_MST.GrossAmount) AS grossamount,                                      
           PO_MST.AdvanceAmount,                                      
           PO_MST.NetAmount,                                      
           PO_MST.PaymentTerms,                                      
           PO_MST.DeliveryTerms,                                      
           PO_MST.AdditionalTerms,                                      
           PO_MST.AuthorisePerson_Id,                                      
           Tbl_AuthorisePerson.Emp_Name AS AuthorisePerson,                                      
           PO_MST.ApproveDate,                                      
           PO_MST.Remark,                                      
           CASE                                      
             WHEN Tbl.PendingQty <= 0 THEN 'Close'                                      
             ELSE ( CASE WHEN PO_MST.PO_Type = 'D' THEN 'Draft'                                      
                      ELSE ( CASE WHEN PO_MST.PO_Type = 'C' THEN 'Cancel'                              
          WHEN PO_MST.PO_Type = 'Q' THEN 'Force Close'                             
          WHEN PO_MST.PO_Type = 'X' THEN 'Delete'                             
                               ELSE 'Open'                                      
                             END )                                      
                    END )                                      
           END                          AS POStatus,                                      
           Tbl.OrderQty,                                      
           Tbl.PendingQty,                                      
           CASE                                      
             WHEN Tbl.PendingQty = Tbl.OrderQty                             
                  AND PO_MST.PO_Type != 'C' THEN 'Cancel'          
             ELSE ''                                      
           END                          AS IsCancel,                                    
           Tbl_CGST.Master_NumVals      AS CGSTPer,                                      
           Tbl_SGST.Master_NumVals      AS SGSTPer,                                      
           Tbl_IGST.Master_NumVals      AS IGSTPer,                                      
           PO_MST.CGST,                            
           PO_MST.SGST,                                      
           PO_MST.IGST,                    
            CONVERT( numeric(18,0), PO_MST.CGSTTotal ) AS cgsttotal,                                      
            CONVERT( numeric(18,0), PO_MST.SGSTTotal ) AS sgsttotal,                                      
            CONVERT( numeric(18,0), PO_MST.IGSTTotal ) AS igsttotal,                               
   case when PO_MST.IGST = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                            
           Tbl_User.Emp_Name            AS EntryUserName,                             
           Tbl_User.Personal_No         AS EntryUserNo ,             
     Doc_Img_Name  ,                  
   PO_MST.Revision  ,            
   PO_MST.Admin_Charges,            
   PO_MST.Insurance,            
   PO_MST.Other_Charges  ,          
   PO_MST.Freight_Charges   

   --row("Item_Name") + "," + row("Item_Code") + "," + row("OrderQty").ToString() + "," + _ArrVar.ToString() + "," + row("OrderNo") + "," + row("SupItem_Code") + "," + row("PODtl_Id").ToString() + "," + row("Item_Id").ToString() + "," + row("PO_Id").ToString()


 FROM   PO_MST WITH (nolock)                                      
           LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)    ON PO_MST.cgst = Tbl_CGST. master_id                                      
           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)     ON PO_MST.sgst = Tbl_SGST. master_id                                      
           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)  ON PO_MST.igst = Tbl_IGST.master_id                                      
           LEFT JOIN m_employee AS Tbl_User WITH(nolock)      ON PO_MST.entry_user = Tbl_User.emp_id                                      
           OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0))   AS OrderQty,                               
     Sum( case when  Isnull(PO_DTL.pendingqty, 0) > 0 then Isnull(PO_DTL.pendingqty, 0) else 0 end  ) AS PendingQty                                      
                               /*Sum(Isnull(PO_DTL.pendingqty, 0)) AS PendingQty        */                              
                        FROM   PO_DTL WITH (nolock)                                      
                        WHERE  PO_DTL.PO_Id = PO_MST.PO_Id) AS Tbl                                      
           LEFT JOIN m_godown WITH (nolock)  ON PO_MST.godown_id = m_godown.godown_id                                      
           LEFT JOIN m_department WITH (nolock)      ON PO_MST.dept_id = m_department.dept_id                                      
           LEFT JOIN m_employee AS Tbl_ReqRaisedBy WITH (nolock)  ON PO_MST.reqraisedby_id = Tbl_ReqRaisedBy.emp_id                                      
           LEFT JOIN m_employee AS Tbl_AuthorisePerson WITH (nolock) ON PO_MST.authoriseperson_id = Tbl_AuthorisePerson.emp_id                                      
           LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.supplier_id = M_Supplier.supplier_id                                      
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.master_id                                      
     WHERE  PO_MST.PO_Id =@PO_Id                                     
    ORDER  BY PO_MST.PO_Id DESC                                      
                                      
    /* ------------------------------------------------------------ */                                      
    SELECT Row_number()                                      
             OVER(                                      
               ORDER BY PODtl_Id )            AS SrNo,                                      
           PO_MST.OrderNo,                                      
           PO_DTL.PODtl_Id,                                     
           PO_DTL.PO_Id,       
     PO_MST.PO_Date,  
     M_Supplier.Supplier_Name as Supplier_Name,   
           M_Item.Item_Group_Id,                                      
           M_Item_Group.Item_Group_Name,                                      
           M_Item.Item_Cate_Id,             
     M_Item_Category.Item_Cate_Name,                                      
           PO_DTL.Item_Id,                                      
           M_Item.Item_Name,                            
   M_Item.Item_Code ,                          
           M_Item.HSN_Code,                                      
           PO_DTL.SupDetail_Id,                                      
           M_SupplierDtl.SupItem_Code,                                      
           PO_DTL.OrderQty,                                      
           /*ISNULL(PO_DTL.PendingQty,0)*/ 1 AS ReceiveQty,                                      
           Isnull(PO_DTL.PendingQty, 0)      AS PendingQty,                                      
           PO_DTL.Unit_Id,                                      
           Tbl_Unit.Master_Vals              AS Unit,                                      
           PO_DTL.Length,                                      
           PO_DTL.Weight,                                      
           PO_DTL.TotalWeight,                                      
           PO_DTL.UnitCost,                        
           PO_DTL.UnitCost                   AS RUnitCost,                                      
          CONVERT( numeric(18,0), PO_DTL.TotalCost) AS totalcost,                                      
           PO_DTL.Remark,                                      
           CASE                             
             WHEN (case when  Isnull(PO_DTL.pendingqty, 0) > 0 then Isnull(PO_DTL.pendingqty, 0) else 0 end) <= 0 THEN 'Close'                                      
             ELSE 'Open'                                      
           END                               AS POStatus,                                      
           CONVERT(BIT, 0)                   AS IsSeletd,                                      
           0                                 AS GrnDtl_Id,                                      
           0                                 AS GRN_Id,                                      
           PO_DTL.Project_Id,                                      
           M_Item.ImageName,                                      
           M_Project.Project_Name  ,                                
   PO_DTL.Width  ,                        
   null AS Rack_Id   ,            
   PO_DTL.Charg_Height,            
   PO_DTL.Charg_Weight   ,        
   PO_DTL.Ref_Code   ,
    Item_Name +','+Item_Code +','+CONVERT(varchar,OrderQty)+',1,'+OrderNo +',' + SupItem_Code +',' + CONVERT(varchar, PODtl_Id)+',' +
	CONVERT(varchar, PO_DTL.Item_Id) +',' + CONVERT(varchar, PO_DTL.PO_Id)--,
    FROM   PO_DTL WITH (nolock)                                      
           LEFT JOIN M_Project WITH (nolock)  ON PO_DTL.Project_Id = M_Project.Project_Id                                      
           LEFT JOIN PO_MST WITH (nolock) ON PO_DTL.PO_Id = PO_MST.PO_Id       
      LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.supplier_id = M_Supplier.supplier_id   
           LEFT JOIN M_Master AS Tbl_Unit WITH (nolock)   ON PO_DTL.Unit_Id = Tbl_Unit.Master_Id                                      
   LEFT JOIN M_SupplierDtl WITH (nolock) ON PO_DTL.SupDetail_Id = M_SupplierDtl.SupDetail_Id                                      
           LEFT JOIN M_Item WITH (nolock) ON PO_DTL.item_id = M_Item.item_id                                      
           LEFT JOIN M_Item_Group WITH (nolock)   ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id                                      
           LEFT JOIN M_Item_Category WITH (nolock)   ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id                                      
     WHERE  PO_DTL.PO_Id =@PO_Id
	AND PO_DTL.PODtl_Id =@PODtl_Id                               
    ORDER  BY PO_MST.PO_Id DESC                                    
   
                                   
GO


