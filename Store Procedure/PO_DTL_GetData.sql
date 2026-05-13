USE [db_a8637c_hifaberp]
GO
/****** Object:  StoredProcedure [dbo].[PO_DTL_GetData]    Script Date: 13-05-2026 11:19:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[PO_DTL_GetData]          
@PO_Id  int = 1002          
          
AS          
          
SET NOCOUNT ON          
           
                 
  SELECT     ROW_NUMBER() OVER( ORDER BY PODtl_Id) AS SrNo,                        
   PO_MST.OrderNo,                    
   PO_DTL.PODtl_Id,                                          
   PO_DTL.PO_Id,                                          
   M_Item.Item_Group_Id,      
   --PO_DTL.Item_Group_Id,                                          
   M_Item_Group.Item_Group_Name,                                          
   --PO_DTL.Item_Cate_Id,                                          
   M_Item.Item_Cate_Id ,      
   M_Item_Category.Item_Cate_Name,                                          
   PO_DTL.Item_Id,                       
   '('+M_Item.HSN_Code+') ' + M_Item.Item_Name AS Item_Name,                                          
   M_Item.HSN_Code,                                          
   PO_DTL.SupDetail_Id,                                          
   M_SupplierDtl.SupItem_Code,                                          
   PO_DTL.OrderQty, 
   PO_DTL.Discount_Percentage,
   PO_DTL.Item_Discount_Amount,
   ISNULL(tbl_Grn.ReceiveQty,0)  AS ReceiveQty,                                          
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
   M_Project.Project_Name ,    
   PO_DTL.Width  ,
   PO_DTL.Charg_Height,
   PO_DTL.Charg_Weight,
   PO_DTL.Ref_Code,
   ISNULL(PO_DTL.Pd_Ref_No,'') AS Pd_Ref_No
 From PO_DTL With (NOLOCK)    
 Cross Apply (  
 select sum(ISNULL(GRN_Dtl.ReceiveQty,0)) AS ReceiveQty from GRN_Dtl  With (NOLOCK) where GRN_Dtl.PODtl_Id  = PO_DTL.PODtl_Id  
 )AS tbl_Grn  
  
 left join M_Project   with (nolock) On PO_DTL.Project_Id =   M_Project.Project_Id                              
 left join PO_MST with (nolock) On PO_DTL.PO_Id =   PO_MST.PO_Id                                          
 left join M_Master as Tbl_Unit with (nolock) On PO_DTL.Unit_Id =   Tbl_Unit.Master_Id                                          
 left join M_SupplierDtl with (nolock) On PO_DTL.SupDetail_Id =   M_SupplierDtl.SupDetail_Id                                          
 left join M_Item  with (nolock) On PO_DTL.Item_Id =   M_Item.Item_Id                                                                  
 left join M_Item_Group  with (nolock) On M_Item.Item_Group_Id =   M_Item_Group.Item_Group_Id                                          
 left join M_Item_Category  with (nolock) On M_Item.Item_Cate_Id =   M_Item_Category.Item_Cate_Id                  
                                          
 where --PO_MST.Order_Type='PO'     And                       
  PO_MST.PO_Id =   @PO_Id                         
 --And PO_MST.Supplier_Id = case when @Supplier_Id =0 then PO_MST.Supplier_Id else @Supplier_Id end                         
 --AND PO_MST.PO_Type =case when @PO_Type = '' then PO_MST.PO_Type else @PO_Type end                        
 order by  PO_MST.PO_Id desc 