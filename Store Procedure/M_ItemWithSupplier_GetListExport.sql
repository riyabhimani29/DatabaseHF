USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_ItemWithSupplier_GetListExport]    Script Date: 27-04-2026 12:27:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_ItemWithSupplier_GetListExport]                          
              @Dept_ID       INT = 0,    
                                                    @Item_Group_Id INT = 0,    
                                                    @Item_Cate_Id  INT = 0,    
                                                    @Supplier_Id   INT = 0,    
                                                    @Type          INT = 0,    
                                                    @ListOnly      INT = 0    
AS    
    SET nocount ON    
    
    SELECT   M_Item.item_id,    
                                 M_Item.item_group_id,    
                                 M_Item.item_cate_id,    
                                 M_Item_Group.item_group_name,    
                                 M_Item_Category.item_cate_name,    
                                 M_Item.item_code,    
                                 M_Item.item_name,    
                                 M_Item.barcode,    
                                 M_Item.hsn_code,    
                                 M_Item.total_parameter,    
                                 M_Item.coated_area,    
                                 M_Item.noncoated_area,    
                                 M_Item.calc_area,    
                                 M_Item.thickness,    
                                 M_Item.weight_mtr,    
                                 M_Item.item_rate,    
                                 M_Item.unit_id,    
                                 M_Master.master_vals AS Unit_Name,
                                 M_Item.AlternateUnitValue,
                                 M_Item.AlternateUnitPrice,
                                 M_Item.Alternate_Unit_Id,
                                 m.master_vals AS Alternate_Unit_Name,
                                 M_Item.unitvalue,    
                                 M_Item.is_active,    
                                 M_Item.remark,    
                                 M_Item.stockalert,    
                                 M_Item.alertday,    
                                 M_Item.mac_add,    
                                 M_Item.year_id,    
                                 M_Item.branch_id,    
                                 M_Item.imagename,    
                                 M_Item.cadfilename,    
                                  M_SupplierDtl.SupItem_Code    ,  
          M_Supplier.supplier_name ,  
                                 --M_SupplierDtl.SupDetail_Id,                                
                                 0                    AS OpenStock    
    FROM   M_Item WITH (nolock)    
           LEFT JOIN M_Master WITH (nolock)  ON M_Item.Unit_Id = m_master.master_id
           LEFT JOIN M_Master AS m WITH (nolock)  ON M_Item.Alternate_Unit_Id = m.master_id  
           LEFT JOIN M_Item_Group WITH (nolock) ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id    
           LEFT JOIN M_Item_Category WITH (nolock)  ON M_Item.Item_Cate_Id = M_Item_Category.item_cate_id    
     left join M_SupplierDtl With (NOLOCK)  On M_SupplierDtl.Item_Id  = M_Item.Item_Id        
     LEFT JOIN m_supplier WITH (nolock)   ON m_supplierdtl.supplier_id = m_supplier.supplier_id  
    -- and  M_SupplierDtl.Item_Group_Id  = M_Item.Item_Group_Id and M_SupplierDtl.Item_Cate_Id  = M_Item.Item_Cate_Id                                    
    WHERE  M_Item.Is_Active = CASE    
                WHEN @Type = 0 THEN M_Item.Is_Active    
                           ELSE 1    
                         END 
		AND M_Item_Group.Dept_ID = case when @Dept_ID = 0 then M_Item_Group.Dept_ID else @Dept_ID end 			 
 ORDER  BY M_Item.entry_date DESC 
GO


