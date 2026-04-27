USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_GetItemReport]    Script Date: 27-04-2026 11:38:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GRN_Mst_GetItemReport] @Dept_IDs     VARCHAR(max) = '',  
                                              @Supplier_Ids VARCHAR(max) = '',  
                                              @Project_Ids  VARCHAR(max) = '',  
                                              @Item_Ids     VARCHAR(max) = '',  
                                              @fr_date      DATE ='2022-02-01',  
                                              @Tr_date      DATE ='2023-01-01',  
                                              @godown_ids   VARCHAR(max) = ''  
AS  
    SET nocount ON  
  
    SELECT 
            GRN_Mst.DiscountAmountOverall,
           GRN_Mst.DiscountPercentageOverall,
           GRN_Dtl.UnitCost,
           GRN_Mst.OtherAmount,
           GRN_Mst.GRN_Id,  
           GRN_Mst.GRN_Type,  
           M_Item.Item_Name,  
           M_Item.Item_Code,  
           Proj.Project_Name AS ProjectName,
           M_Department.Dept_Name,  
           GRN_Mst.Invoice_No,                   
           GRN_Mst.Challan_No,                    
           GRN_Mst.Challan_Date,   
           GRN_Mst.GRN_No,  
           GRN_Mst.GRN_Date,  
           Datediff(day, GRN_Mst.GRN_Date, dbo.Get_sysdate()) AS NoofDays,  
           Isnull(GRN_Dtl.OrderQty, 0)                        AS Qty_Pcs,  
           ( ( Isnull(GRN_Dtl.Weight, 0) * Isnull(GRN_Dtl.Length, 0) * Isnull(GRN_Dtl.OrderQty, 0) ) / 1000 )       AS Qty_Kg,  
           Isnull(GRN_Dtl.ReceiveQty, 0)                      AS QtyReceive,  
           ( ( Isnull(GRN_Dtl.Weight, 0) * Isnull(GRN_Dtl.length, 0) * Isnull(GRN_Dtl.ReceiveQty, 0) ) / 1000 )     AS QtyRec_Kg,  
           Tbl_ReqRaisedBy.Emp_Name                           AS ReqRaisedBy,  
           M_Supplier.Supplier_Name,  
           M_Supplier.Address                                 AS SupplierAddress ,  
           M_Supplier.GST_No                                  AS SupplierGSTNO,  
           Tbl_State.Master_Vals                              AS SupplierState,  
           M_Godown.Godown_Name,  
           M_Godown.Godown_Address                            AS ShippingAddress ,  
           CONVERT(NUMERIC(18, 0), GRN_Mst.GrossAmount)       AS GrossAmount,  
           GRN_Mst.AdvanceAmount,  
           GRN_Mst.NetAmount,  
           GRN_Mst.Remark,  
           GRN_Dtl.OrderQty,  
           Tbl_CGST.Master_NumVals                            AS CGSTPer,  
           Tbl_SGST.Master_NumVals                            AS SGSTPer,  
           Tbl_IGST.Master_NumVals                            AS IGSTPer,  
           CONVERT(NUMERIC(18, 0), GRN_Mst.CGSTTotal)         AS CGSTTotal,  
           CONVERT(NUMERIC(18, 0), GRN_Mst.SGSTTotal)         AS SGSTTotal,  
           CONVERT(NUMERIC(18, 0), GRN_Mst.IGSTTotal)         AS IGSTTotal,  
           CASE  
             WHEN GRN_Mst.IGST = 0 THEN CONVERT(BIT, 0)  
             ELSE CONVERT(BIT, 1)  
           END                                                AS Is_IGST,  
           Tbl_User.Emp_Name                                  AS EntryUserName,  
           Tbl_User.Personal_No                               AS EntryUserNo,  
           M_SupplierDtl.SupItem_Code,  
           GRN_Dtl.Length  ,
		    ( case when GRN_Mst.GRN_Type ='PO-GRN'   then   PO_MST.OrderNo          
					when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_No  else PO_MST.OrderNo end )  AS PO_No 
    FROM   GRN_Dtl WITH (nolock)  
           LEFT JOIN M_SupplierDtl WITH(nolock) ON GRN_Dtl.SupDetail_Id = M_SupplierDtl.SupDetail_Id  
           LEFT JOIN GRN_Mst WITH(nolock) ON GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id  
           LEFT JOIN M_Item WITH(nolock) ON GRN_Dtl.Item_Id = M_Item.Item_Id  
           LEFT JOIN m_master AS Tbl_CGST WITH (nolock) ON GRN_Mst.cgst = Tbl_CGST. Master_Id  
           LEFT JOIN m_master AS Tbl_SGST WITH (nolock) ON GRN_Mst.sgst = Tbl_SGST. Master_Id  
           LEFT JOIN m_master AS Tbl_IGST WITH (nolock) ON GRN_Mst.igst = Tbl_IGST.Master_Id  
           LEFT JOIN m_employee AS Tbl_User WITH(nolock) ON GRN_Mst.Entry_User = Tbl_User.Emp_Id  
           LEFT JOIN M_Godown WITH (nolock) ON GRN_Mst.Godown_Id = M_Godown.Godown_Id  
           LEFT JOIN M_Department WITH (nolock) ON GRN_Mst.Dept_ID = M_Department.Dept_ID  
           LEFT JOIN m_employee AS Tbl_ReqRaisedBy WITH (nolock) ON GRN_Mst.ReqRaisedBy_Id = Tbl_ReqRaisedBy.Emp_Id  
           LEFT JOIN M_Supplier WITH (nolock) ON GRN_Mst.Supplier_Id = M_Supplier.Supplier_Id                                       
           left join PO_MST  With (NOLOCK)  On GRN_Mst.PO_Id  = PO_MST.PO_Id --and GRN_Mst.GRN_Type='PO-GRN'                      
           left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'     
           LEFT JOIN m_master AS Tbl_State WITH (nolock) ON M_Supplier.State_Id = Tbl_State.Master_Id  

           outer Apply(
                 select TOP 1 MP.Project_Name
                 from PO_DTL PD with (nolock)
                 INNER JOIN M_Project MP with (nolock)
                     on MP.Project_Id = PD.Project_Id
                 where PD.PODtl_Id = GRN_Dtl.PODtl_Id
                 AND ( @Project_Ids = '' 
                 OR PD.Project_Id IN (select items from dbo.STSplit(@Project_Ids)) )
                 AND ( @Item_Ids = '' 
                 OR PD.Item_Id IN (select items from dbo.STSplit(@Item_Ids)) )
           ) AS Proj
    WHERE  CONVERT(DATE, dbo.GRN_Mst.GRN_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)  
           AND ( ( @Dept_IDs = '' )  
                  OR ( @Dept_IDs <> ''  
                       AND dbo.GRN_Mst.dept_id IN (SELECT items FROM   dbo.Stsplit(@Dept_IDs) ) )  
               )  
           AND ( ( @Supplier_Ids = '' )  
                  OR ( @Supplier_Ids <> ''  
                       AND dbo.GRN_Mst.supplier_id IN (SELECT items FROM dbo.Stsplit(@Supplier_Ids)) )  
               )  
           AND ( ( @godown_ids = '' )  
                  OR ( @godown_ids <> ''  
                       AND dbo.GRN_Mst.Godown_Id IN (SELECT items FROM  dbo.Stsplit(@godown_ids) ) ) )  
           AND ( ( @Item_Ids = '' )  
                  OR ( @Item_Ids <> ''  
                       AND dbo.GRN_Dtl.Item_Id IN (SELECT items FROM   dbo.Stsplit(@Item_Ids) ) )  
               )  
    ORDER  BY M_Item.Item_Name ASC
GO


