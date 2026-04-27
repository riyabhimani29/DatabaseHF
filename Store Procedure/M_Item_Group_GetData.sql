USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Group_GetData]    Script Date: 27-04-2026 12:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

              
ALTER PROCEDURE [dbo].[M_Item_Group_GetData]              
@Dept_ID  int  = 4,              
@Type int = 0              
              
AS              
              
SET NOCOUNT ON              
              
     SELECT m_item_group.Item_Group_Id,    
       m_item_group.Dept_ID,        
    M_Department.Dept_Name,    
       m_item_group.Category_Id,    
       m_group_category.Category_Name,    
       m_item_group.Category_No,    
       m_item_group.Item_Group_Name,    
       m_item_group.Is_Active,    
       m_item_group.Remark,    
       m_item_group.MAC_Add,    
       m_item_group.Entry_User,    
       --Entry_Date,              
       m_item_group.Upd_User,    
       --Upd_Date,              
       m_item_group.Year_Id,    
       m_item_group.Branch_ID    
FROM   m_item_group WITH (nolock)    
  left join M_Department With (NOLOCK)  On m_item_group.Dept_ID = M_Department.Dept_ID    
       LEFT JOIN m_group_category WITH (nolock) ON m_item_group.category_id = m_group_category.category_id    
WHERE  m_item_group.dept_id =case when @Dept_ID = 0 then m_item_group.dept_id  else @Dept_ID end  
       AND m_item_group.is_active = CASE    
                                      WHEN @Type = 0 THEN m_item_group.is_active    
                                      ELSE 1    
                                    END    
ORDER  BY m_item_group.entry_date DESC -- M_Item_Group.Item_Group_Name      
    
    
    
    
SELECT m_group_field_setting.id,    
       m_group_field_setting.item_group_id,    
       m_group_field_setting.field_id,    
       m_group_field.field_name,    
       m_item_group.item_group_name    
FROM   m_group_field_setting WITH (nolock)    
       LEFT JOIN m_group_field WITH (nolock)    
              ON m_group_field.field_id = m_group_field_setting.field_id    
       LEFT JOIN m_item_group WITH (nolock)    
              ON m_item_group.item_group_id =    
                 m_group_field_setting.item_group_id 
GO


