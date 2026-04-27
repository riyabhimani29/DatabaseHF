USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_GetEdit]    Script Date: 27-04-2026 13:13:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [dbo].[PO_MST_GetEdit]                  
@PO_Id int  =0                  
                  
AS                  
                  
SET NOCOUNT ON                  
                  
                  
SELECT  PO_MST.PO_Id,                  
  PO_MST.PO_Type,                  
  Order_Type,                  
  PO_MST.Dept_ID,                  
  M_Department.Dept_Name,                  
  PO_MST.Invoice_No,                  
  PO_MST.OrderNo,                  
  PO_MST.PO_Date,                  
  PO_MST.ReqRaisedBy_Id,                  
  Tbl_ReqRaisedBy.Emp_Name as ReqRaisedBy,                  
  PO_MST.BillingAddress,                  
  PO_MST.Supplier_Id,                  
  M_Supplier.Supplier_Name,            
  M_Supplier.Address as SupplierAddress,          
  M_Supplier.GST_No as SupplierGSTNO ,           
  PO_MST.Godown_Id,              
  M_Godown.Godown_Name,              
  M_Godown.Godown_Address AS ShippingAddress,          
  PO_MST.GrossAmount,                  
  PO_MST.AdvanceAmount,                  
  PO_MST.NetAmount,                  
  PO_MST.PaymentTerms,                  
  PO_MST.DeliveryTerms,                  
  PO_MST.AdditionalTerms,                  
  PO_MST.AuthorisePerson_Id,                  
  Tbl_AuthorisePerson.Emp_Name AS AuthorisePerson,                  
  PO_MST.ApproveDate,                  
  PO_MST.Remark,            
  case when   Tbl.PendingQty <= 0 then 'Close' else 'Open' end  AS POStatus            
 From PO_MST With (NOLOCK)                
 outer Apply (            
 select SUM(ISNULL(PO_DTL.OrderQty,0))as OrderQty,SUM(ISNULL(PO_DTL.PendingQty,0)) AS PendingQty from  PO_DTL With (NOLOCK) where PO_DTL.PO_Id = PO_MST.PO_Id            
 ) AS Tbl            
 left join M_Godown With (NOLOCK)  On PO_MST.Godown_Id  = M_Godown.Godown_Id                  
 left join M_Department  With (NOLOCK)  On PO_MST.Dept_ID  = M_Department.Dept_ID                  
 left join M_Employee AS Tbl_ReqRaisedBy  With (NOLOCK)  On PO_MST.ReqRaisedBy_Id  = Tbl_ReqRaisedBy.Emp_Id                  
 left join M_Employee AS Tbl_AuthorisePerson  With (NOLOCK)  On PO_MST.AuthorisePerson_Id  = Tbl_AuthorisePerson.Emp_Id                  
 left join M_Supplier   With (NOLOCK)  On PO_MST.Supplier_Id  = M_Supplier.Supplier_Id                  
 Where PO_MST.PO_Id = @PO_Id                 
                   
  SELECT     ROW_NUMBER() OVER( ORDER BY PODtl_Id) AS SrNo,             
  PO_DTL.PODtl_Id,                
  PO_DTL.PO_Id,                
  PO_DTL.Item_Group_Id,                
  M_Item_Group.Item_Group_Name,                
  PO_DTL.Item_Cate_Id,                
  M_Item_Category.Item_Cate_Name,                
  PO_DTL.Item_Id,                
  M_Item.Item_Name,                
  M_Item.HSN_Code,                
  PO_DTL.SupDetail_Id,                
  M_SupplierDtl.SupItem_Code,                
  PO_DTL.OrderQty,                
  ISNULL(PO_DTL.PendingQty,0) AS ReceiveQty,                
  ISNULL(PO_DTL.PendingQty,0) AS PendingQty,            
  PO_DTL.Unit_Id,                
  Tbl_Unit.Master_Vals as Unit,                
  PO_DTL.Length,                
  PO_DTL.Weight,                
  PO_DTL.TotalWeight,                
  PO_DTL.UnitCost,                
  PO_DTL.UnitCost AS RUnitCost,                
  PO_DTL.TotalCost,                
  PO_DTL.Remark    ,            
  case when   PO_DTL.PendingQty <= 0 then 'Close' else 'Open' end  AS POStatus   ,        
  CONVERT(bit , 0 )as IsSeletd ,        
  0 as GrnDtl_Id      ,        
  0 as GRN_Id    ,    
  PO_DTL.Project_Id ,    
  M_Project.Project_Name    
 From PO_DTL With (NOLOCK)        
 left join M_Project   with (nolock) On PO_DTL.Project_Id =   M_Project.Project_Id    
 left join PO_MST with (nolock) On PO_DTL.PO_Id =   PO_MST.PO_Id                
 left join M_Master as Tbl_Unit with (nolock) On PO_DTL.Unit_Id =   Tbl_Unit.Master_Id                
 left join M_SupplierDtl with (nolock) On PO_DTL.SupDetail_Id =   M_SupplierDtl.SupDetail_Id                
 left join M_Item  with (nolock) On PO_DTL.Item_Id =   M_Item.Item_Id                             
 left join M_Item_Group  with (nolock) On M_Item.Item_Group_Id =   M_Item_Group.Item_Group_Id                
 left join M_Item_Category  with (nolock) On M_Item.Item_Cate_Id =   M_Item_Category.Item_Cate_Id   
                
 where  PO_MST.PO_Id = @PO_Id 
GO


