USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_GetReport]    Script Date: 27-04-2026 11:38:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GRN_Mst_GetReport]                
         @Dept_IDs  varchar(max) = '',             
         @Supplier_Ids varchar(max) = '',           
         @Project_Ids varchar(max) = '',         
         @Item_Ids varchar(max) = '',          
         @Godown_Ids varchar(max) = '',         
         @fr_date date ='2022-11-01',          
         @Tr_date date ='2022-11-30'           
          
AS                                    
    SET nocount ON                                    
	 
                                    
    SELECT 
    GRN_Mst.DiscountAmountOverall,
           GRN_Mst.DiscountPercentageOverall,
    GRN_Mst.GRN_Id,                                    
           GRN_Mst.GRN_Type,                                       
           GRN_Mst.Dept_ID,  
          Proj.Project_Name AS ProjectName,
           M_Department.Dept_Name,                                    
           GRN_Mst.Invoice_No,                                    
           GRN_Mst.GRN_No,                                    
           GRN_Mst.GRN_Date,
            Tbl_GRN_Dtl.UnitCost,
			DATEDIFF(DAY,GRN_Mst.GRN_Date,dbo.Get_Sysdate()) AS NoofDays,      
			ISNULL(Tbl.OrderQty,0) AS Qty_Pcs,      
			ISNULL(Tbl.Qty_Kg,0)  AS Qty_Kg,       
			ISNULL(Tbl2.RecQty_Kg,0)  AS RecQty_Kg,     
			ISNULL(Tbl2.RecQty,0)   AS QtyReceive,      
           Tbl_ReqRaisedBy.Emp_Name     AS ReqRaisedBy,                                    
           M_Supplier.Supplier_Name,                                    
           M_Supplier.Address           AS SupplierAddress,                                    
           M_Supplier.GST_No            AS SupplierGSTNO,                                    
           Tbl_State.master_vals        AS SupplierState,                                    
           M_Godown.Godown_Name,                                    
           M_Godown.Godown_Address      AS ShippingAddress,                                    
           CONVERT( numeric(18,0), GRN_Mst.GrossAmount) AS GrossAmount,                                    
           GRN_Mst.AdvanceAmount,                                    
           GRN_Mst.NetAmount,
           GRN_Mst.OtherAmount,
           GRN_Mst.Remark,                                    
           Tbl.OrderQty,                                    
           Tbl.PendingQty,                                    
           Tbl_CGST.Master_NumVals      AS CGSTPer,                                    
           Tbl_SGST.Master_NumVals      AS SGSTPer,                                    
           Tbl_IGST.Master_NumVals      AS IGSTPer,                                    
            CONVERT( numeric(18,0), GRN_Mst.CGSTTotal ) AS CGSTTotal,                                    
            CONVERT( numeric(18,0), GRN_Mst.SGSTTotal ) AS SGSTTotal,                                    
            CONVERT( numeric(18,0), GRN_Mst.IGSTTotal ) AS IGSTTotal,                             
			case when GRN_Mst.IGST = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                          
           Tbl_User.Emp_Name            AS EntryUserName,                           
           Tbl_User.Personal_No         AS EntryUserNo
 FROM   GRN_Mst WITH (nolock)     
		  outer Apply (
				select Sum(Isnull(GRN_Dtl.Weight, 0)  *  (Isnull(GRN_Dtl.Length, 0)  *  Isnull(GRN_Dtl.ReceiveQty, 0)) / 1000) AS RecQty_Kg , 
						Sum(Isnull(GRN_Dtl.ReceiveQty, 0))   AS RecQty 
				from  GRN_Dtl with (nolock) where GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id
		  ) AS Tbl2	
          outer Apply(
                select TOP 1 MP.Project_Name
                from GRN_Dtl GD with (nolock)
                INNER JOIN PO_DTL PD with (nolock)
                    on GD.PODtl_Id = PD.PODtl_Id
                INNER JOIN M_Project MP with (nolock)
                    on MP.Project_Id = PD.Project_Id
                where GD.GRN_Id = GRN_Mst.GRN_Id
                AND ( @Project_Ids = '' 
                OR PD.Project_Id IN (select items from dbo.STSplit(@Project_Ids)) )
                AND ( @Item_Ids = '' 
                OR PD.Item_Id IN (select items from dbo.STSplit(@Item_Ids)) )
          ) AS Proj

           LEFT JOIN M_Master AS Tbl_CGST WITH (nolock) ON GRN_Mst.CGST = Tbl_CGST.Master_Id                                    
           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock) ON GRN_Mst.sgst = Tbl_SGST.Master_Id                                    
           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock) ON GRN_Mst.igst = Tbl_IGST.Master_Id                                    
           LEFT JOIN M_Employee AS Tbl_User WITH(nolock) ON GRN_Mst.entry_user = Tbl_User.emp_id                                    
           OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0))   AS OrderQty,                             
						Sum( case when  Isnull(PO_DTL.PendingQty, 0) > 0 then Isnull(PO_DTL.PendingQty, 0) else 0 end  ) AS PendingQty ,    
						Sum(Isnull(PO_DTL.Weight, 0)  *  (Isnull(PO_DTL.Length, 0)  *  Isnull(PO_DTL.OrderQty, 0)) / 1000)   AS Qty_Kg     
                        FROM   PO_DTL WITH (nolock)                                    
                        WHERE  PO_DTL.PO_Id = GRN_Mst.PO_Id  
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
           LEFT JOIN M_Godown WITH (nolock)  ON GRN_Mst.Godown_Id = M_Godown.Godown_Id                                    
           LEFT JOIN M_Department WITH (nolock)      ON GRN_Mst.Dept_ID = M_Department.Dept_ID                                    
           LEFT JOIN M_Employee AS Tbl_ReqRaisedBy WITH (nolock)  ON GRN_Mst.ReqRaisedBy_Id = Tbl_ReqRaisedBy.Emp_Id                                    
           LEFT JOIN M_Supplier WITH (nolock) ON GRN_Mst.supplier_id = M_Supplier.Supplier_Id                                    
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.State_Id = Tbl_State.Master_Id  
           LEFT JOIN GRN_Dtl AS Tbl_GRN_Dtl WITH (nolock) ON Tbl_GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id

    WHERE  CONVERT(DATE, dbo.GRN_Mst.GRN_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)             
        AND ( ( @Dept_IDs = '' )                      
                  OR ( @Dept_IDs <> ''                      
                       AND dbo.GRN_Mst.Dept_ID IN (SELECT items FROM dbo.STSplit(@Dept_IDs) )                      
                     )                      
                )         
        AND ( ( @Supplier_Ids = '' )                      
                  OR ( @Supplier_Ids <> ''                      
                       AND dbo.GRN_Mst.Supplier_Id IN (SELECT items FROM dbo.STSplit(@Supplier_Ids) )                      
                     )                      
                )         
        AND ( ( @Godown_Ids = '' )                      
                  OR ( @Godown_Ids <> ''                      
                       AND dbo.GRN_Mst.Godown_Id IN (SELECT items FROM dbo.STSplit(@Godown_Ids) )                      
                     )                      
                )    
                                   
    ORDER  BY GRN_Mst.GRN_Id DESC
GO


