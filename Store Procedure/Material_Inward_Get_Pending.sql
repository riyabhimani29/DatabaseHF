USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Material_Inward_Get_Pending]    Script Date: 27-04-2026 12:49:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Material_Inward_Get_Pending] @Id INT = 0,
@User_id INT = 0 



AS    
SET NOCOUNT ON    
    
SELECT material_inward.id,    
       material_inward.godown_id,    
       m_godown.godown_name,    
       material_inward.item_id,    
       m_item.item_name,    
       m_item.item_code,    
       m_item.item_group_id,    
       m_item_group.item_group_name,    
       m_item.item_cate_id,    
       m_item_category.item_cate_name,    
       material_inward.stype,    
       material_inward.total_qty,    
       material_inward.[length],  
       material_inward.Width,  
       material_inward.remark,    
       material_inward.entry_date,    
       material_inward.entry_user,
       material_inward.Rack_Id,
       M_Godown_Rack.Rack_Name,
       M_Department.Dept_ID,
       M_Department.Dept_Name,
       material_inward.Status,
       empApproved.Emp_Name AS Approved_By_Name,
       empChecked.Emp_Name AS Checked_By_Name

FROM material_inward WITH (NOLOCK)    

LEFT JOIN M_Godown_Rack WITH (NOLOCK)    
       ON M_Godown_Rack.Rack_Id = material_inward.Rack_Id   

LEFT JOIN m_godown WITH (NOLOCK)    
       ON m_godown.godown_id = material_inward.godown_id    

LEFT JOIN m_item WITH (NOLOCK)    
       ON m_item.item_id = material_inward.item_id    

LEFT JOIN m_item_group WITH (NOLOCK)    
       ON m_item.item_group_id = m_item_group.item_group_id    

LEFT JOIN m_item_category WITH (NOLOCK)    
       ON m_item.item_cate_id = m_item_category.item_cate_id

LEFT JOIN M_Department WITH (NOLOCK)    
       ON M_Department.Dept_ID = M_Item_Group.Dept_ID 

LEFT JOIN M_Employee empApproved WITH (NOLOCK)    
       ON empApproved.Emp_Id = material_inward.approved_by

LEFT JOIN M_Employee empChecked WITH (NOLOCK)    
       ON empChecked.Emp_Id = material_inward.checked_by 

WHERE 
(
    @Id = 0 OR material_inward.id = @Id
)
AND
(
    (material_inward.status = 's' AND material_inward.checked_by = @User_id)
    OR
    (material_inward.status = 'p' AND material_inward.approved_by = @User_id)
)

ORDER BY material_inward.entry_date DESC
GO


