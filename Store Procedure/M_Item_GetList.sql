USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetList]    Script Date: 27-04-2026 12:21:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




                        
ALTER PROCEDURE [dbo].[M_Item_GetList]                        
@Dept_ID  int  = 1,                        
@Item_Group_Id int =44,                        
@Item_Cate_Id int = 113,                         
@Supplier_Id int = 0,                        
@Type int = 0     ,                        
@ListOnly int = 0                          
                        
AS                        
                        
SET NOCOUNT ON                        
           
        
if (@ListOnly = 0 )            
begin        
   SELECT
    M_Item_Group.Dept_ID,
    M_Item.Item_Id,                      
    M_Item.Item_Group_Id,                      
    M_Item_Group.Item_Group_Name,                      
    M_Item.Item_Cate_Id,                      
    M_Item_Category.Item_Cate_Name,                      
    M_Item.Item_Code,                       
    M_Item.Item_Name,                      
    M_Item.Barcode,                      
    M_Item.HSN_Code ,                  
    M_item.Weight_Mtr,         
    M_Item.Calc_Area,
    M_item.Thickness,      
    M_Master.Master_Vals AS Unit_Name,                    
    m_item.Unit_Id,  
      M_Item.Alternate_Unit_Id,
    M_Item.AlternateUnitValue,
    M_Item.AlternateUnitPrice,
    Alternate.Master_Vals as Alternate_Unit_Name,
    M_SupplierDtl.SupItem_Code    ,                  
    M_SupplierDtl.SupDetail_Id,         
   M_Item.ImageName,  
   CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Item_Rate,
   M_Supplier.Supplier_Name,
   M_Supplier.Supplier_Id,
    0 AS OpenStock                  
  From M_Item With (NOLOCK)                       
  left join M_Master With (NOLOCK)  On  M_Item.Unit_Id = M_Master.Master_Id    
  left join M_Master AS Alternate With (NOLOCK)  On  M_Item.Alternate_Unit_Id = Alternate.Master_Id 
  left join M_Item_Group  With (NOLOCK)  On M_Item.Item_Group_Id  = M_Item_Group.Item_Group_Id                      
  left join M_Item_Category  With (NOLOCK)  On M_Item.Item_Cate_Id  = M_Item_Category.Item_Cate_Id                      
  left join M_SupplierDtl With (NOLOCK)  On M_SupplierDtl.Item_Id  = M_Item.Item_Id       
  LEFT JOIN M_Supplier with (NOLOCK) ON M_SupplierDtl.Supplier_Id = M_Supplier.Supplier_Id
--   and  M_SupplierDtl.Item_Group_Id  = M_Item.Item_Group_Id and M_SupplierDtl.Item_Cate_Id  = M_Item.Item_Cate_Id                      
  Where  M_Item_Group.Dept_ID = case when  @Dept_ID   = 0  then M_Item_Group.Dept_ID  else  @Dept_ID   end                      
  AND M_Item.Item_Group_Id  = case when @Item_Group_Id = 0  then M_Item.Item_Group_Id  else @Item_Group_Id end                          
  AND M_Item.Item_Cate_Id  = case when @Item_Cate_Id = 0  then M_Item.Item_Cate_Id  else @Item_Cate_Id end                             
  and M_Item.Is_Active = case when @Type = 0  then M_Item.Is_Active  else 1 end                   
  AND ISNULL( M_SupplierDtl.Supplier_Id,0) =  case when @Supplier_Id = 0  then  ISNULL( M_SupplierDtl.Supplier_Id,0)  else @Supplier_Id end         
 end         
 else         
 begin        
   SELECT
    M_Item_Group.Dept_ID,
    M_Item.Item_Id,                      
    M_Item.Item_Group_Id,                      
    M_Item_Group.Item_Group_Name,                      
    M_Item.Item_Cate_Id,                      
    M_Item_Category.Item_Cate_Name,                      
    M_Item.Item_Code,                       
    M_Item.Item_Name,                      
    M_Item.Barcode,                      
    M_Item.HSN_Code ,     
    M_Item.Alternate_Unit_Id,
    M_Item.AlternateUnitValue,
    M_Item.AlternateUnitPrice,
    Alternate.Master_Vals as Alternate_Unit_Name,
       M_Item.Calc_Area,
    M_item.Weight_Mtr,          
 M_item.Thickness,           
    M_Master.Master_Vals AS Unit_Name,                    
    m_item.Unit_Id,                  
    '' SupItem_Code    ,  
    '' Supplier_Name,
    0 AS SupDetail_Id,            
   M_Item.ImageName,
    CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS Item_Rate,
    0 AS OpenStock,
    M_SupplierDtl.Supplier_Id
  From M_Item With (NOLOCK)                       
  left join M_Master With (NOLOCK)  On  M_Item.Unit_Id = M_Master.Master_Id     
  left join M_Master AS Alternate With (NOLOCK)  On  M_Item.Alternate_Unit_Id = Alternate.Master_Id     
  left join M_Item_Group  With (NOLOCK)  On M_Item.Item_Group_Id  = M_Item_Group.Item_Group_Id                      
  left join M_Item_Category  With (NOLOCK)  On M_Item.Item_Cate_Id  = M_Item_Category.Item_Cate_Id                      
  left join M_SupplierDtl With (NOLOCK)  On M_SupplierDtl.Item_Id  = M_Item.Item_Id          
  Where  M_Item_Group.Dept_ID =case when  @Dept_ID   = 0  then M_Item_Group.Dept_ID  else  @Dept_ID   end                       
  AND M_Item.Item_Group_Id  = case when @Item_Group_Id = 0  then M_Item.Item_Group_Id  else @Item_Group_Id end                          
  AND M_Item.Item_Cate_Id  = case when @Item_Cate_Id = 0 then M_Item.Item_Cate_Id  else @Item_Cate_Id end                             
  and M_Item.Is_Active = case when @Type = 0  then M_Item.Is_Active  else 1 end                   
 -- AND M_SupplierDtl.Supplier_Id =  case when @Supplier_Id = 0  then M_SupplierDtl.Supplier_Id  else @Supplier_Id end         
 end
GO


