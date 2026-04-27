USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stockrecon_History_Get]    Script Date: 27-04-2026 15:00:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


    ALTER PROCEDURE [dbo].[Stockrecon_History_Get] 
    @Id INT = 0,
    @Dept_id INT = 0,
    @fr_date DATETIME = '2025-10-19',
    @tr_date DATETIME = '2025-12-19'
AS    
BEGIN
    SET NOCOUNT ON;
 
    SELECT 
        StockView_Tack.id,    
        StockView_Tack.E_Type,
 
        -- ? New Column
        CASE 
            WHEN StockView_Tack.E_Type = 'Reconciliation +' THEN 'Plus'
            WHEN StockView_Tack.E_Type = 'Reconciliation -' THEN 'Minus'
            ELSE ''
        END AS Reconciliation_Type,
 
        StockView_Tack.Remark,
        StockView_Tack.Entry_Date,
        StockView_Tack.Qty,
        m_godown.godown_name,      
        m_item.item_name,    
        m_item.item_code,    
        m_item.item_group_id,    
        m_item_group.item_group_name,    
        m_item.item_cate_id,    
        m_item_category.item_cate_name,    
        M_Godown_Rack.Rack_Name,
        M_Department.Dept_ID,
        M_Department.Dept_Name,
        StockView.Length,
        StockView.Width,
        StockView.SType
 
    FROM StockView_Tack WITH (NOLOCK)   
    LEFT JOIN StockView WITH (NOLOCK)    
        ON StockView.Id = StockView_Tack.Stock_Id   
    LEFT JOIN m_item WITH (NOLOCK)    
        ON m_item.item_id = StockView.item_id    
    LEFT JOIN M_Godown_Rack WITH (NOLOCK)    
        ON M_Godown_Rack.Rack_Id = StockView.Rack_Id   
    LEFT JOIN m_godown WITH (NOLOCK)    
        ON m_godown.godown_id = StockView.godown_id    
    LEFT JOIN m_item_group WITH (NOLOCK)    
        ON m_item.item_group_id = m_item_group.item_group_id    
    LEFT JOIN m_item_category WITH (NOLOCK)    
        ON m_item.item_cate_id = m_item_category.item_cate_id
    LEFT JOIN M_Department WITH (NOLOCK)    
        ON M_Department.Dept_ID = m_item_group.Dept_ID
 
    WHERE 
        StockView_Tack.E_Type IN ('Reconciliation +', 'Reconciliation -')
        AND (@Id = 0 OR StockView_Tack.Id = @Id)
         AND (@Dept_id = 0 OR M_Department.Dept_ID = @Dept_id)
        AND (
            (@fr_date IS NULL OR StockView_Tack.Entry_Date >= @fr_date)
            AND (@tr_date IS NULL OR StockView_Tack.Entry_Date <= @tr_date)
        )
 
    ORDER BY 
        StockView_Tack.Entry_Date DESC;
END
GO


