USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetSigleStock]    Script Date: 27-04-2026 12:21:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Item_GetSigleStock] @Dept_ID       INT = 0,                              
                                         @Item_Group_Id INT =0,                                        
                                         @StockId INT =0,                              
                                         @Item_Cate_Id  INT =0,                              
                                         --@Supplier_Id int =0,                                                               
                                         @Godown_Id     INT =10,                              
                                         @Type          INT = 0,                              
                                         @SType         CHAR='N'                              
AS                              
    SET nocount ON                              
                
 SELECT stockview.id,                        
       stockview.godown_id,                        
       m_godown.godown_name,                        
       m_item.item_group_id,                        
       m_item_group.item_group_name,                        
       m_item.item_cate_id,                        
       m_item_category.item_cate_name,                        
       stockview.item_id,                        
       m_item.item_name   AS [Description],                        
       m_item.item_code,                        
       m_item.hsn_code,                        
       stockview.total_qty,                        
       stockview.sales_qty,                        
       stockview.pending_qty,                        
       stockview.[length],                        
       Tbl_Unit.master_vals AS UnitName,                        
       m_item.unit_id,                        
       CASE                        
         WHEN stockview.stype = 'C' THEN 'Coated'                        
         ELSE 'Non-Coated'                        
       END                        
       SType,                        
       m_item.[total_parameter],                        
       m_item.[coated_area],                        
       m_item.[noncoated_area],                        
       m_item.[calc_area],                        
       m_item.[weight_mtr],                        
       lastupdate,                        
       --( Isnull(m_item.[weight_mtr], 0) * Isnull(stockview.[length], 0) *                         
       --    Isnull (stockview.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                        
       Isnull(m_item.thickness, 0)thickness,                        
       KK.field_id,                      
                
       convert (numeric(18,2),(( CASE                        
           WHEN KK.field_id IS NOT NULL THEN ( (                        
           Isnull(m_item.[weight_mtr], 0) * Isnull(stockview.[length], 0) *                       
     Isnull(stockview.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 )                        
         /* Is Width */                        
           ELSE ( ( Isnull(m_item.[weight_mtr], 0) *                        
                    Isnull(stockview.[length], 0) *                        
                    Isnull( stockview.pending_qty, 0) ) / 1000 )                        
         END ))) AS TotalWeight,                        
       m_item.item_group_id   ,                    
    StockView.Width ,                  
 StockView.RackNo,                  
 StockView.Remark   ,              
 M_Godown_Rack.Rack_Name,              
 StockView.Rack_Id              
FROM   stockview WITH (nolock)                        
       LEFT JOIN m_godown WITH (nolock) ON stockview.godown_id = m_godown.godown_id                 
       LEFT JOIN M_Godown_Rack WITH (nolock) ON stockview.Rack_Id = M_Godown_Rack.Rack_Id                         
       LEFT JOIN m_item WITH (nolock) ON stockview.item_id = m_item.item_id                        
       LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id                        
       OUTER apply (SELECT m_group_field_setting.field_id                        
                    FROM   m_group_field_setting WITH (nolock)                                            
     WHERE  m_group_field_setting.field_id = 1  --  Only 'Width' Entry                      
      AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK                        
       LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id                        
       LEFT JOIN m_master AS Tbl_Unit WITH (nolock) ON m_item.unit_id = Tbl_Unit.master_id                         
    WHERE   StockView.Id = @StockId   
 AND stockview.pending_qty > 0  AND stockview.item_id <> 0 --  stockview.pending_qty <> 0                 
 AND m_item_group.dept_id = ( CASE WHEN @Dept_ID = 0 THEN m_item_group.dept_id ELSE @Dept_ID END )                              
           AND stockview.godown_id = ( CASE   WHEN @Godown_Id = 0 THEN     stockview.godown_id                              
                                         ELSE @Godown_Id                              
                                       END )                              
           AND stockview.stype = ( CASE    WHEN @SType = 'A' THEN stockview.stype                              
         ELSE @SType                              
                                   END )                              
    ORDER  BY LastUpdate DESC--m_item.item_code 
GO


