USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_ItemWithSupplier_GetList]    Script Date: 27-04-2026 12:27:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_ItemWithSupplier_GetList]                            
              @Dept_ID       INT = 0,      
                                                    @Item_Group_Id INT = 0,      
                                                    @Item_Cate_Id  INT = 0,      
                                                    @Supplier_Id   INT = 0,      
                                                    @Type          INT = 0,      
                                                    @ListOnly      INT = 0      
AS      
    SET nocount ON      
      
    SELECT /* M_Item.Item_Id,                                      
            M_Item.Item_Group_Id,                                      
            M_Item_Group.Item_Group_Name,                                      
            M_Item.Item_Cate_Id,                                      
            M_Item_Category.Item_Cate_Name,                                      
            M_Item.Item_Code,                                       
            M_Item.Item_Name,                                      
            M_Item.Barcode,                                      
            M_Item.HSN_Code ,                                  
            M_Item.Weight_Mtr,                         
           M_Item.Thickness,                      
            M_Master.Master_Vals AS Unit_Name,                                    
            M_Item.Unit_Id,                                  
            M_SupplierDtl.SupItem_Code    ,                                  
            M_SupplierDtl.SupDetail_Id,                                  
            0 AS OpenStock        */ M_Item.item_id,      
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
								 dbo.Get_Group_Field(M_Item.Item_Group_Id,2) AS Is_Thickness,
								 
								 dbo.Get_Group_Field(M_Item.Item_Group_Id,1) AS Is_Width,
                                 M_Item.Weight_Mtr,      
                                 M_Item.Item_Rate,      
                                 M_Item.Unit_Id,      
                                 m_master.master_vals AS Unit_Name, 
                                 M_Item.Alternate_Unit_Id,      
                                 m_master1.master_vals AS Alternate_Unit_Name, 
                                 M_Item.UnitValue,
                                 M_Item.AlternateUnitValue,                               
                                 M_Item.AlternateUnitPrice,
                                 M_Item.Is_Active,      
                                 M_Item.Remark,      
                                 M_Item.StockAlert,      
                                 M_Item.AlertDay,      
                                 M_Item.MAC_Add,      
                                 M_Item.Year_Id,      
                                 M_Item.Branch_ID,      
                                 M_Item.ImageName,      
                                 M_Item.CadFileName,      
                                 --M_SupplierDtl.SupItem_Code    ,                                  
                                 --M_SupplierDtl.SupDetail_Id,                                  
                                 0                    AS OpenStock   ,  
         M_Item_Group.Dept_ID  
    FROM   M_Item WITH (nolock)      
           LEFT JOIN m_master WITH (nolock)  ON M_Item.unit_id = m_master.master_id      
           LEFT JOIN m_master as m_master1 WITH (nolock)  ON M_Item.alternate_unit_id = m_master1.master_id      
           LEFT JOIN M_Item_Group WITH (nolock)     ON M_Item.item_group_id = M_Item_Group.item_group_id      
           LEFT JOIN M_Item_Category WITH (nolock)   ON M_Item.item_cate_id = M_Item_Category.item_cate_id      
    -- left join M_SupplierDtl With (NOLOCK)  On M_SupplierDtl.Item_Id  = M_Item.Item_Id      
    -- and  M_SupplierDtl.Item_Group_Id  = M_Item.Item_Group_Id and M_SupplierDtl.Item_Cate_Id  = M_Item.Item_Cate_Id                                      
    WHERE M_Item.is_active = CASE      
     WHEN @Type = 0 THEN M_Item.is_active      
          ELSE 1      
        END      
  and M_Item_Group.Dept_ID  LIKE (case when   @Dept_ID =0 then M_Item_Group.Dept_ID else @Dept_ID end)    
 ORDER  BY M_Item.entry_date DESC       
      
   SELECT m_supplierdtl.supitem_code,      
          m_supplierdtl.item_id,      
          m_supplier.supplier_id,      
         m_supplierdtl.supdetail_id,      
           m_supplier.supplier_name      
    FROM   m_supplierdtl WITH (nolock)      
          LEFT JOIN m_supplier WITH (nolock)     ON m_supplierdtl.supplier_id = m_supplier.supplier_id  
 where  M_Supplier.Dept_IDs  LIKE ('%' + cast(case when   @Dept_ID =0 then M_Supplier.Dept_ID else @Dept_ID end as varchar) + '%')

 --(CASE 
    -- WHEN @Dept_ID = 0 
     --     THEN ',' + M_Supplier.Dept_IDs + ',' 
   --  ELSE ',' + M_Supplier.Dept_IDs + ',' 
-- END) 
--LIKE 
--(CASE 
   --  WHEN @Dept_ID = 0 
      --    THEN ',' + CAST(M_Supplier.Dept_ID AS VARCHAR) + ',' 
    -- ELSE '%,' + CAST(@Dept_ID AS VARCHAR) + ',%' 
 --END)
GO


