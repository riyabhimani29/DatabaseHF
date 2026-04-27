USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Material_Inward_Get]    Script Date: 27-04-2026 12:48:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Material_Inward_Get] @Id INT = 0,
  @fr_date Date,
  @Tr_date Date,
  @Dept_Id INT = 0
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
       material_inward.approved_by,
       material_inward.checked_by,
       M_Godown_Rack.Rack_Name,
       M_Department.Dept_ID,
       M_Department.Dept_Name,
       material_inward.Status,
       empApproved.Emp_Name AS Approved_By_Name,
       empChecked.Emp_Name AS Checked_By_Name,
       material_inward.Inward_Reason

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

WHERE (@Id = 0 OR material_inward.id = @Id)
--AND material_inward.entry_date BETWEEN @fr_date AND @Tr_date
AND material_inward.entry_date >= @fr_date
AND material_inward.entry_date < DATEADD(DAY, 1, @Tr_date)
AND (@Dept_Id = 0 OR m_item_group.Dept_ID = @Dept_Id)


ORDER BY material_inward.entry_date DESC
GO


