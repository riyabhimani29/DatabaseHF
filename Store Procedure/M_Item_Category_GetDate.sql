USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Category_GetDate]    Script Date: 27-04-2026 12:18:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

      
ALTER PROCEDURE [dbo].[M_Item_Category_GetDate]      
@Dept_ID  int  = 0,      
@Item_Group_Id int =0,      
@Type int = 0      
      
AS      
      
SET NOCOUNT ON      
      
      
SELECT       
M_Item_Category.Item_Cate_Id,      
M_Item_Category.Item_Group_Id,      
M_Item_Group.Item_Group_Name,      
M_Item_Category.Item_Cate_Name,  M_Item_Category.Item_Cate_Code,    
M_Item_Category.Is_Active,      
M_Item_Category.Remark,      
M_Item_Category.MAC_Add,      
M_Item_Category.Entry_User,      
M_Item_Category.Entry_Date,      
M_Item_Category.Upd_User,      
M_Item_Category.Upd_Date,      
M_Item_Category.Year_Id,      
M_Item_Category.Branch_ID      
 From M_Item_Category With (NOLOCK)       
 left join M_Item_Group   With (NOLOCK)  On M_Item_Group.Item_Group_Id =  M_Item_Category.Item_Group_Id      
 Where  M_Item_Group.Dept_ID = case when @Dept_ID = 0  then  M_Item_Group.Dept_ID else @Dept_ID end           
 AND M_Item_Category.Item_Group_Id  = case when @Item_Group_Id = 0  then M_Item_Category.Item_Group_Id  else @Item_Group_Id end        
 and M_Item_Category.Is_Active = case when @Type = 0  then M_Item_Category.Is_Active  else 1 end 

 Order BY M_Item_Category.Item_Cate_Name
GO


