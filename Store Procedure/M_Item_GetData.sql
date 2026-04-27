USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetData]    Script Date: 27-04-2026 12:20:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER  PROCEDURE [dbo].[M_Item_GetData]          
@SearchParam  VARCHAR(8000)  = ''          
          
AS          
          
SET NOCOUNT ON          
DECLARE @SqlString  NVARCHAR(Max)          
          
SET @SqlString ='          
 SELECT           
   M_Item.Item_Id,           
   M_Item.Item_Group_Id,        
   M_Item.Item_Cate_Id,        
   M_Item_Group.Item_Group_Name,        
   M_Item_Category.Item_Cate_Name,        
   M_Item.Item_Code,          
   M_Item.Item_Name,          
   M_Item.Barcode,          
   M_Item.HSN_Code,          
   M_Item.Total_Parameter,          
   M_Item.Coated_Area,          
   M_Item.NonCoated_Area,          
   M_Item.Calc_Area,      
   M_Item.Thickness,  
   M_Item.Weight_Mtr,          
   M_Item.Item_Rate,          
   M_Item.Unit_Id,          
   M_Master.Master_Vals AS Unit_Name,      
   M_Item.UnitValue,          
   M_Item.Is_Active,          
   M_Item.Remark,          
   M_Item.StockAlert,          
   M_Item.AlertDay,          
   M_Item.MAC_Add,          
   M_Item.Year_Id,          
   M_Item.ImageName,     
   M_Item.Branch_ID          
  From M_Item With (NOLOCK)         
  left join M_Master With (NOLOCK)  On  M_Item.Unit_Id = M_Master.Master_Id      
  left join M_Item_Group  With (NOLOCK)  On M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id        
  left join M_Item_Category  With (NOLOCK)  On M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id         
  '          
          
IF LTRIM ( RTRIM ( @SearchParam ) ) <> ''          
BEGIN          
SET @SqlString = @SqlString + ' WHERE ' + @SearchParam          
End          
      SET @SqlString = @SqlString + ' ORDER BY   M_Item.Item_Id DESC '    
    
EXECUTE sp_executesql   @SqlString
GO


