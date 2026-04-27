USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Category_GetData]    Script Date: 27-04-2026 12:17:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

               
ALTER  PROCEDURE [dbo].[M_Item_Category_GetData]              
@Dept_ID  int  = 0,              
@Item_Group_Id int =0,              
@Type int = 0              
              
AS              
              
SET NOCOUNT ON              
              
              
SELECT M_Item_Category.item_cate_id,    
       M_Item_Category.item_group_id,    
       M_Item_Group.item_group_name,    
       M_Item_Category.item_cate_name,    
       M_Item_Category.item_cate_code,    
       M_Item_Category.is_active,    
       M_Item_Category.remark,    
       M_Item_Category.mac_add,    
       M_Item_Category.entry_user,    
       M_Item_Category.entry_date,    
       M_Item_Category.upd_user,    
       M_Item_Category.upd_date,    
       M_Item_Category.year_id,    
       M_Item_Category.branch_id  ,  
    M_Item_Group.Dept_ID  
FROM   M_Item_Category WITH (nolock)    
       LEFT JOIN M_Item_Group WITH (nolock)    
              ON M_Item_Group.item_group_id = M_Item_Category.item_group_id    
WHERE  M_Item_Group.dept_id = CASE    
                                WHEN @Dept_ID = 0 THEN M_Item_Group.dept_id    
                                ELSE @Dept_ID    
                              END    
       AND M_Item_Category.item_group_id = CASE    
                                             WHEN @Item_Group_Id = 0 THEN    
                                             M_Item_Category.item_group_id    
                                             ELSE @Item_Group_Id    
                                           END    
       AND M_Item_Category.is_active = CASE    
                                         WHEN @Type = 0 THEN    
                                         M_Item_Category.is_active    
                                         ELSE 1    
                                       END 
GO


