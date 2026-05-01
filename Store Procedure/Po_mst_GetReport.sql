USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Po_mst_GetReport]    Script Date: 27-04-2026 13:15:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Po_mst_GetReport]              
          @Dept_IDs  varchar(max) = '',           
           @Supplier_Ids varchar(max) = '',         
           @Project_Ids varchar(max) = '',       
           @Item_Ids varchar(max) = '',        
         @fr_date date ='2022-04-22',        
         @Tr_date date ='2022-06-22',        
         @godown_ids varchar(max) = ''  ,        
         @Order_Type varchar(max) = ''        
        
AS                                  
    SET nocount ON                                  
                                  
    SELECT PO_MST.po_id,                                  
           PO_MST.po_type,  
           ISNULL(Proj.Project_Name,'') AS Project_Name,
           PO_MST.Order_Type,                                  
           PO_MST.dept_id,                                  
           M_Department.dept_name,                                  
           PO_MST.invoice_no,                                  
           PO_MST.orderno,                                  
           PO_MST.po_date,                                    
           PO_MST.po_date AS GRN_Date,                                
     DATEDIFF(DAY,PO_MST.po_date,dbo.Get_Sysdate()) AS NoofDays,    
     ISNULL(Tbl.OrderQty,0) AS Qty_Pcs,    
    ISNULL(Tbl.Qty_Kg,0)  AS Qty_Kg,    
     ISNULL(Tbl.OrderQty,0) - ISNULL(Tbl.PendingQty,0) AS QtyReceive,    
     Tbl_GRNMS.GRNAmt AS AmtGRN,    
           PO_MST.reqraisedby_id,                                  
           Tbl_ReqRaisedBy.emp_name     AS ReqRaisedBy,                                  
           PO_MST.billingaddress,                                  
           PO_MST.supplier_id,                                  
           M_Supplier.supplier_name,                                  
           M_Supplier.address           AS SupplierAddress,                                  
           M_Supplier.gst_no            AS SupplierGSTNO,                                  
           Tbl_State.master_vals        AS SupplierState,                                  
           PO_MST.godown_id,                                  
           m_godown.godown_name,                                  
           m_godown.godown_address      AS ShippingAddress,                                  
           CONVERT( numeric(18,0), PO_MST.grossamount) AS grossamount,                                  
           PO_MST.advanceamount,                                  
           PO_MST.netamount,                                  
           PO_MST.paymentterms,                                  
           PO_MST.deliveryterms,                                  
           PO_MST.additionalterms,                                  
           PO_MST.authoriseperson_id,                                  
           Tbl_AuthorisePerson.emp_name AS AuthorisePerson,                                  
           PO_MST.approvedate,                                  
           PO_MST.remark,                                  
           CASE                                  
             WHEN Tbl.pendingqty <= 0 THEN 'Close'                                  
             ELSE ( CASE WHEN PO_MST.po_type = 'D' THEN 'Draft'                                  
                      ELSE ( CASE WHEN PO_MST.po_type = 'C' THEN 'Cancel'                          
          WHEN PO_MST.po_type = 'Q' THEN 'Force Close'                         
          WHEN PO_MST.po_type = 'X' THEN 'Delete'                         
                               ELSE 'Open'                                  
                             END )                                  
                    END )                                  
           END                          AS POStatus,                                  
           Tbl.orderqty,                                  
           Tbl.pendingqty,                                  
           CASE                                  
             WHEN Tbl.pendingqty = Tbl.orderqty                                  
                  AND PO_MST.po_type != 'C' THEN 'Cancel'                                  
             ELSE ''                                  
           END                  AS IsCancel,                                  
           Tbl_CGST.Master_NumVals      AS CGSTPer,                                  
           Tbl_SGST.Master_NumVals      AS SGSTPer,                                  
           Tbl_IGST.Master_NumVals      AS IGSTPer,                                  
           PO_MST.CGST,                                  
           PO_MST.sgst,                                  
           PO_MST.igst,                                  
            CONVERT( numeric(18,3), PO_MST.cgsttotal ) AS cgsttotal,                                  
            CONVERT( numeric(18,3), PO_MST.sgsttotal ) AS sgsttotal,                                  
            CONVERT( numeric(18,3), PO_MST.igsttotal ) AS igsttotal,                           
    case when PO_MST.igst = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                        
           Tbl_User.emp_name            AS EntryUserName,                         
           Tbl_User.personal_no         AS EntryUserNo ,                                  
     Doc_Img_Name  ,              
     PO_MST.Revision,
     PO_MST.Admin_Charges,
     PO_MST.Insurance,
     PO_MST.Other_Charges,
     PO_MST.Freight_Charges
 FROM   PO_MST WITH (nolock)        
     
   outer Apply (    
   select SUM(ISNULL(GRN_Mst.NetAmount,0)) AS GRNAmt from GRN_Mst with(nolock) where GRN_Mst.PO_Id = PO_MST.PO_Id    
       
   ) AS Tbl_GRNMS    
           LEFT JOIN m_master AS Tbl_CGST WITH (nolock)    ON PO_MST.CGST = Tbl_CGST. master_id                                  
           LEFT JOIN m_master AS Tbl_SGST WITH (nolock)     ON PO_MST.sgst = Tbl_SGST. master_id                                  
           LEFT JOIN m_master AS Tbl_IGST WITH (nolock)  ON PO_MST.igst = Tbl_IGST.master_id                                  
           LEFT JOIN M_Employee AS Tbl_User WITH(nolock)      ON PO_MST.entry_user = Tbl_User.emp_id                                  
           OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0))   AS OrderQty,                           
						 Sum( case when  Isnull(PO_DTL.PendingQty, 0) > 0 then Isnull(PO_DTL.PendingQty, 0) else 0 end  ) AS PendingQty ,  
						  Sum(Isnull(PO_DTL.Weight, 0)  *  (Isnull(PO_DTL.Length, 0)  *  Isnull(PO_DTL.OrderQty, 0)) / 1000)   AS Qty_Kg   
                               /*Sum(Isnull(po_dtl.pendingqty, 0)) AS PendingQty        */                          
                        FROM   PO_DTL WITH (nolock)                                  
                        WHERE  PO_DTL.PO_Id = PO_MST.PO_Id
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
					) AS Tbl     
                    OUTER APPLY
                    (
                        SELECT TOP 1 MP.Project_Name
                        FROM PO_DTL PD
                        INNER JOIN M_Project MP ON MP.Project_Id = PD.Project_Id
                        WHERE PD.PO_Id = PO_MST.PO_Id
                            AND ( @Project_Ids = '' 
                                    OR PD.Project_Id IN (SELECT items FROM dbo.STSplit(@Project_Ids)) )
                            AND ( @Item_Ids = '' 
                                    OR PD.Item_Id IN (SELECT items FROM dbo.STSplit(@Item_Ids)) )
                      ) AS Proj

           LEFT JOIN m_godown WITH (nolock)  ON PO_MST.godown_id = m_godown.godown_id                                  
           LEFT JOIN m_department WITH (nolock)      ON PO_MST.dept_id = m_department.dept_id                                  
           LEFT JOIN M_Employee AS Tbl_ReqRaisedBy WITH (nolock)  ON PO_MST.reqraisedby_id = Tbl_ReqRaisedBy.emp_id                                  
           LEFT JOIN M_Employee AS Tbl_AuthorisePerson WITH (nolock) ON PO_MST.authoriseperson_id = Tbl_AuthorisePerson.emp_id                                  
           LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.supplier_id = M_Supplier.supplier_id                                  
           LEFT JOIN m_master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.master_id                                  
    WHERE  /* PO_MST.Order_Type = 'PO' AND */ PO_MST.PO_Type <> 'X'     
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
                                 
    ORDER  BY PO_MST.po_id DESC
