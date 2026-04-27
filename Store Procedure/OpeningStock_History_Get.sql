USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[OpeningStock_History_Get]    Script Date: 27-04-2026 13:08:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[OpeningStock_History_Get] @Id INT =0    
AS    
    SET nocount ON    
    
    SELECT openingstock_history.id,    
           openingstock_history.godown_id,    
           m_godown.godown_name,    
           openingstock_history.item_id,    
           m_item.item_name,    
           m_item.item_code,    
           m_item.item_group_id,    
           m_item_group.item_group_name,    
           m_item.item_cate_id,    
           m_item_category.item_cate_name,    
           openingstock_history.stype,    
           openingstock_history.total_qty,    
           openingstock_history.[length],  
			openingstock_history.Width ,  
           openingstock_history.remark,    
           openingstock_history.entry_date,    
           openingstock_history.entry_user  ,
		   OpeningStock_History.Rack_Id ,
		   M_Godown_Rack.Rack_Name,
           M_Department.Dept_ID,
           M_Department.Dept_Name
    FROM   openingstock_history WITH (nolock)    
           LEFT JOIN M_Godown_Rack WITH (nolock)    
                  ON M_Godown_Rack.Rack_Id = openingstock_history.Rack_Id   
           LEFT JOIN m_godown WITH (nolock)    
                  ON m_godown.godown_id = openingstock_history.godown_id    
           LEFT JOIN m_item WITH (nolock)    
                  ON m_item.item_id = openingstock_history.item_id    
           LEFT JOIN m_item_group WITH (nolock)    
                  ON m_item.item_group_id = m_item_group.item_group_id    
           LEFT JOIN m_item_category WITH (nolock)    
                  ON m_item.item_cate_id = m_item_category.item_cate_id
                  LEFT JOIN M_Department WITH (nolock)    
                  ON M_Department.Dept_ID = M_Item_Group.Dept_ID 
    ORDER  BY openingstock_history.entry_date DESC 
GO


