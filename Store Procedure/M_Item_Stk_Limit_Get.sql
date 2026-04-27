USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Stk_Limit_Get]    Script Date: 27-04-2026 12:26:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[M_Item_Stk_Limit_Get] @Dept_ID       INT = 0,                    
                                         @Item_Group_Id INT =0,                    
                                         @Item_Cate_Id  INT =0,                    
                                         --@Supplier_Id int =0,                                                     
                                         @Godown_Id     INT =10,                    
                                         @Type          INT = 0,                    
                                         @SType         CHAR='N'                    
AS                    
    SET nocount ON                    
     
SELECT  M_Item_Stk_Limit.Id,
		M_Item_Stk_Limit.Godown_Id,
		M_Godown.Godown_Name,
		M_Item_Stk_Limit.Item_Id,
		M_Item.Item_Name,
		 M_Item.Item_Cate_Id,
		 M_Item.Item_Group_Id,
		M_Item_Group.Item_Group_Name,
		M_Item_Category.Item_Cate_Name,
		M_Item_Stk_Limit.Length,
		M_Item_Stk_Limit.Min_Limit,
		M_Item_Stk_Limit.Cri_limit,
		M_Item_Stk_Limit.Remark  
 From M_Item_Stk_Limit With (NOLOCK) 
 left join M_Godown  With (NOLOCK) On M_Item_Stk_Limit.Godown_Id = M_Godown.Godown_Id
 left join M_Item  With (NOLOCK) On M_Item_Stk_Limit.Item_Id = M_Item.Item_Id
 left join M_Item_Category  With (NOLOCK) On M_Item_Category.Item_Cate_Id= M_Item.Item_Cate_Id
 left join M_Item_Group  With (NOLOCK) On M_Item_Group.Item_Group_Id = M_Item.Item_Group_Id
GO


