USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_MST_Get_Offset]    Script Date: 27-04-2026 11:38:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  PROCEDURE [dbo].[GRN_MST_Get_Offset]
@GRN_Id int  = 0  ,
@Dept_ID  int  = 0 ,
@Offset int = 1,
@SearchText VARCHAR(MAX) = 'No-Data',
@GRNType  varchar(50)  = 'GRN-OUT',
@Size int = 15
AS

SET NOCOUNT ON;
    DECLARE @GRN_IdList VARCHAR(MAX) = '';

                          
SELECT COUNT(GRN_Mst.GRN_Id) as orderLstCount
 From GRN_Mst With (NOLOCK)
 left join M_Employee AS Tbl_ReceiveBy With (NOLOCK)  On GRN_Mst.ReceiveBy_Id  = Tbl_ReceiveBy.Emp_Id
 left join M_Employee AS Tbl_CheckBy With (NOLOCK)  On GRN_Mst.CheckBy_Id  = Tbl_CheckBy.Emp_Id
 left join M_Godown With (NOLOCK)  On GRN_Mst.Godown_Id  = M_Godown.Godown_Id
 left join M_Department  With (NOLOCK)  On GRN_Mst.Dept_ID  = M_Department.Dept_ID
 left join M_Employee AS Tbl_ReqRaisedBy  With (NOLOCK)  On GRN_Mst.ReqRaisedBy_Id  = Tbl_ReqRaisedBy.Emp_Id
 left join PO_MST  With (NOLOCK)  On GRN_Mst.PO_Id  = PO_MST.PO_Id   and GRN_Mst.GRN_Type  IN ('PO-GRN','GRN-OUT') --='PO-GRN'
 left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'
 left join M_Project  With (NOLOCK)  On DC_Mst.Project_Id  =  M_Project.Project_Id
 left join M_Supplier   With (NOLOCK)  On GRN_Mst.Supplier_Id  = M_Supplier.Supplier_Id
 where GRN_Mst.Dept_ID = (case when @Dept_ID = 0 then GRN_Mst.Dept_ID else @Dept_ID end )
 AND GRN_Mst.GRN_Type = @GRNType AND 
   CASE 
    WHEN @SearchText != 'No-Data' AND (
        LOWER(GRN_Mst.GRN_Type) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Department.Dept_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Invoice_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Challan_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(FORMAT(GRN_Mst.GRN_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
LOWER(FORMAT(GRN_Mst.Challan_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
LOWER(M_Supplier.Supplier_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Godown.Godown_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Vehicle_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.EwayBill_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.GrossAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.AdvanceAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.OtherAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.NetAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_ReceiveBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Remark) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_CheckBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Project.Project_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(coating_shade) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Inv_No) LIKE '%' + Lower(@SearchText) + '%'
    ) THEN 1
    ELSE 0
END = 1;

    SELECT @GRN_IdList = COALESCE(@GRN_IdList + ',', '') + CAST(GRN_Mst.GRN_Id AS VARCHAR)
    FROM GRN_Mst WITH (NOLOCK)
    LEFT JOIN M_Employee AS Tbl_ReceiveBy WITH (NOLOCK) ON GRN_Mst.ReceiveBy_Id = Tbl_ReceiveBy.Emp_Id
    LEFT JOIN M_Employee AS Tbl_CheckBy WITH (NOLOCK) ON GRN_Mst.CheckBy_Id = Tbl_CheckBy.Emp_Id
    LEFT JOIN M_Godown WITH (NOLOCK) ON GRN_Mst.Godown_Id = M_Godown.Godown_Id
    LEFT JOIN M_Department WITH (NOLOCK) ON GRN_Mst.Dept_ID = M_Department.Dept_ID
    LEFT JOIN M_Employee AS Tbl_ReqRaisedBy WITH (NOLOCK) ON GRN_Mst.ReqRaisedBy_Id = Tbl_ReqRaisedBy.Emp_Id
    LEFT JOIN PO_MST WITH (NOLOCK) ON GRN_Mst.PO_Id = PO_MST.PO_Id AND GRN_Mst.GRN_Type IN ('PO-GRN', 'GRN-OUT')
    LEFT JOIN DC_Mst WITH (NOLOCK) ON GRN_Mst.PO_Id = DC_Mst.DC_Id AND GRN_Mst.GRN_Type = 'DC-GRN'
    LEFT JOIN M_Project WITH (NOLOCK) ON DC_Mst.Project_Id = M_Project.Project_Id
    LEFT JOIN M_Supplier WITH (NOLOCK) ON GRN_Mst.Supplier_Id = M_Supplier.Supplier_Id
    WHERE GRN_Mst.Dept_ID = CASE WHEN @Dept_ID = 0 THEN GRN_Mst.Dept_ID ELSE @Dept_ID END
    AND GRN_Mst.GRN_Type = @GRNType AND 
   CASE 
    WHEN @SearchText != 'No-Data' AND (
        LOWER(GRN_Mst.GRN_Type) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Department.Dept_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Invoice_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Challan_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(FORMAT(GRN_Mst.GRN_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
LOWER(FORMAT(GRN_Mst.Challan_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
LOWER(M_Supplier.Supplier_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Godown.Godown_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Vehicle_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.EwayBill_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.GrossAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.AdvanceAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.OtherAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.NetAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_ReceiveBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Remark) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_CheckBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Project.Project_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(coating_shade) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Inv_No) LIKE '%' + Lower(@SearchText) + '%'
    ) THEN 1
    ELSE 0
END = 1
    ORDER BY GRN_Mst.GRN_Id DESC
    OFFSET (@Size * (@Offset)) ROWS
    FETCH NEXT @Size ROWS ONLY;

SELECT  GRN_Mst.GRN_Id,
     GRN_Mst.GRN_Type,
     GRN_Mst.GRN_No,
     GRN_Mst.PO_Id,
     --PO_MST.OrderNo AS PO_No,
    ( case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT')   /* ='PO-GRN' */   then  '' --PO_MST.OrderNo
 when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_No  else '' end )  AS PO_No ,
  --DC_Mst.DC_No,
     GRN_Mst.Dept_ID,                                  
     M_Department.Dept_Name,                                    
     GRN_Mst.Invoice_No,                              
     GRN_Mst.Challan_No,                              
     GRN_Mst.GRN_Date,                              
     GRN_Mst.Challan_Date,                              
     GRN_Mst.ReqRaisedBy_Id,                              
                    
  ( case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT')   /* ='PO-GRN' */   then   Tbl_ReqRaisedBy.Emp_Name                  
    else '-' end )  as ReqRaisedBy,                               
     GRN_Mst.Supplier_Id,                                             
     M_Supplier.Supplier_Name,                                          
     GRN_Mst.Godown_Id,                                 
     M_Godown.Godown_Name,                                     
     GRN_Mst.Vehicle_No,                              
     GRN_Mst.EwayBill_No,                              
     GRN_Mst.GrossAmount,                              
     GRN_Mst.AdvanceAmount,                              
     GRN_Mst.OtherAmount,                              
     GRN_Mst.NetAmount,                              
     Tbl_ReceiveBy.Emp_Name AS ReceiveBy,                              
     Tbl_CheckBy.Emp_Name AS CheckBy,                          
     GRN_Mst.ReceiveBy_Id ,                        
     GRN_Mst.CheckBy_Id ,                        
     GRN_Mst.Remark  ,            
  M_Project.Project_Name     ,    
  '' coating_shade,    
  '' Reference_No  ,  
  GRN_Mst.Inv_No    
 From GRN_Mst With (NOLOCK)                            
 left join M_Employee AS Tbl_ReceiveBy With (NOLOCK)  On GRN_Mst.ReceiveBy_Id  = Tbl_ReceiveBy.Emp_Id                            
 left join M_Employee AS Tbl_CheckBy With (NOLOCK)  On GRN_Mst.CheckBy_Id  = Tbl_CheckBy.Emp_Id                               
 left join M_Godown With (NOLOCK)  On GRN_Mst.Godown_Id  = M_Godown.Godown_Id                                                
 left join M_Department  With (NOLOCK)  On GRN_Mst.Dept_ID  = M_Department.Dept_ID                                                
 left join M_Employee AS Tbl_ReqRaisedBy  With (NOLOCK)  On GRN_Mst.ReqRaisedBy_Id  = Tbl_ReqRaisedBy.Emp_Id                                                
 left join PO_MST  With (NOLOCK)  On GRN_Mst.PO_Id  = PO_MST.PO_Id   and GRN_Mst.GRN_Type  IN ('PO-GRN','GRN-OUT') --   ='PO-GRN'                             
 left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'             
 left join M_Project  With (NOLOCK)  On DC_Mst.Project_Id  =  M_Project.Project_Id            
 left join M_Supplier   With (NOLOCK)  On GRN_Mst.Supplier_Id  = M_Supplier.Supplier_Id                              
 where GRN_Mst.Dept_ID = (case when @Dept_ID = 0 then GRN_Mst.Dept_ID else @Dept_ID end )                       
 AND GRN_Mst.GRN_Type = @GRNType AND
 CASE 
    WHEN Lower(@SearchText) != 'No-Data' AND (
        LOWER(GRN_Mst.GRN_Type) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Department.Dept_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Invoice_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Challan_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(FORMAT(GRN_Mst.GRN_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
		LOWER(FORMAT(GRN_Mst.Challan_Date, 'dd-MMM-yyyy')) LIKE '%' + Lower(@SearchText) + '%' OR
		LOWER(M_Supplier.Supplier_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Godown.Godown_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Vehicle_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.EwayBill_No) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.GrossAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.AdvanceAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.OtherAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.NetAmount) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_ReceiveBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Remark) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(Tbl_CheckBy.Emp_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(M_Project.Project_Name) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(coating_shade) LIKE '%' + Lower(@SearchText) + '%' OR
        LOWER(GRN_Mst.Inv_No) LIKE '%' + Lower(@SearchText) + '%'
    ) THEN 1
    ELSE 0
END = 1

 order by GRN_Mst.GRN_Id DESC OFFSET (@Size * (@Offset)) ROWS FETCH NEXT @Size ROWS ONLY;                       
        
                              
SELECT  ROW_NUMBER() OVER( ORDER BY GRN_Dtl.PODtl_Id) AS SrNo,                               
   GRN_Dtl.GrnDtl_Id,                              
   GRN_Dtl.GRN_Id,               
     GRN_Mst.GRN_No,            
   GRN_Dtl.PODtl_Id,                              
   M_Item.Item_Group_Id,                                  
   M_Item_Group.Item_Group_Name,                	
   M_Item.Item_Cate_Id,                                 
   M_Item_Category.Item_Cate_Name,                      
   GRN_Dtl.Item_Id,                                      
   M_Item.Item_Name,                                        
   M_Item.Item_Code ,                               
   M_Item.HSN_Code,                      
   GRN_Dtl.SupDetail_Id,                                   
  -- M_SupplierDtl.SupItem_Code,                 
    (case when GRN_Mst.GRN_Type ='PO-GRN'   then   M_SupplierDtl.SupItem_Code                  
   else '-' end ) SupItem_Code,                
   GRN_Dtl.SType,                              
   GRN_Dtl.OrderQty,                              
   GRN_Dtl.ReceiveQty,                              
   GRN_Dtl.Unit_Id,                              
   Tbl_Unit.Master_Vals as Unit,                                
   GRN_Dtl.[Length],                              
   GRN_Dtl.[Weight],
   GRN_Dtl.TotalWeight,
   GRN_Dtl.UnitCost,
   GRN_Dtl.ReceiveCost,
   GRN_Dtl.TotalCost,
   GRN_Dtl.Remark ,
   --PO_MST.OrderNo

   (case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT') /* ='PO-GRN' */   then  PO_MST.OrderNo
  when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_No  else '' end )   AS OrderNo ,
  GRN_Dtl.Material_Value,
 GRN_Dtl.Coating_Value  ,
 M_Project.Project_Name,
 PO_DTL.Ref_Code,
 M_Godown_Rack.Rack_Name


 From GRN_Dtl With (NOLOCK)
 left join GRN_Mst With (NOLOCK) On GRN_Mst.GRN_Id  = GRN_Dtl.GRN_Id
 left join PO_DTL With (NOLOCK) On PO_DTL.PODtl_Id  = GRN_Dtl.PODtl_Id
 left join PO_MST  With (NOLOCK) On PO_DTL.PO_Id  = PO_MST.PO_Id      and GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT') --  = 'PO-GRN'
 left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'
 left join M_Master as Tbl_Unit with (nolock) On GRN_Dtl.Unit_Id =   Tbl_Unit.Master_Id
 left join M_SupplierDtl with (nolock) On GRN_Dtl.SupDetail_Id =   M_SupplierDtl.SupDetail_Id
 left join M_Item  with (nolock) On GRN_Dtl.Item_Id =   M_Item.Item_Id
 left join M_Item_Group  with (nolock) On M_Item.Item_Group_Id =   M_Item_Group.Item_Group_Id
 left join M_Item_Category  with (nolock) On M_Item.Item_Cate_Id =   M_Item_Category.Item_Cate_Id
 left join M_Project  With (NOLOCK) On PO_DTL.Project_Id = M_Project.Project_Id
 left join M_Godown_Rack  With (NOLOCK) On GRN_Dtl.Rack_Id = M_Godown_Rack.Rack_Id
 where GRN_Mst.Dept_ID = (case when @Dept_ID = 0 then GRN_Mst.Dept_ID else @Dept_ID end )
 AND GRN_Mst.GRN_Type = @GRNType 
     AND GRN_Dtl.GRN_Id IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@GRN_IdList, ','));
GO


