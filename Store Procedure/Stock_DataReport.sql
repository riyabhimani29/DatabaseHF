USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stock_DataReport]    Script Date: 27-04-2026 14:53:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Stock_DataReport]
    @Year INT,
    @Dept_ID INT = 0,
    @Month INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Month = 0
    BEGIN
        WITH Months AS (
            SELECT 1 AS MonthNumber, 'January' AS MonthName UNION ALL
            SELECT 2, 'February' UNION ALL
            SELECT 3, 'March' UNION ALL
            SELECT 4, 'April' UNION ALL
            SELECT 5, 'May' UNION ALL
            SELECT 6, 'June' UNION ALL
            SELECT 7, 'July' UNION ALL
            SELECT 8, 'August' UNION ALL
            SELECT 9, 'September' UNION ALL
            SELECT 10, 'October' UNION ALL
            SELECT 11, 'November' UNION ALL
            SELECT 12, 'December'
        )
        SELECT Months.MonthName AS Month,
             COALESCE(SUM(CASE WHEN (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID) THEN StockView.total_qty ELSE 0 END), 0) AS TotalQty,            
            COALESCE(SUM(CASE WHEN (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID) THEN StockView.sales_qty ELSE 0 END), 0) AS SalesQty,
            COALESCE(SUM(CASE WHEN (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID) THEN StockView.pending_qty ELSE 0 END), 0) AS PendingQty,
             COALESCE(SUM(CONVERT(NUMERIC(18, 2),(CASE WHEN (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID) THEN (CASE  
        WHEN KK.field_id IS NOT NULL THEN ((ISNULL(m_item.[weight_mtr], 0) * ISNULL(StockView.[length], 0) * ISNULL(StockView.pending_qty, 0) * ISNULL(m_item.thickness, 0)) / 1000)  
        ELSE ((ISNULL(m_item.[weight_mtr], 0) * ISNULL(StockView.[length], 0) * ISNULL(StockView.pending_qty, 0)) / 1000)  
    END) ELSE 0 END))),0) AS TotalWeight
        FROM Months
        LEFT JOIN StockView ON MONTH(StockView.LastUpdate) = Months.MonthNumber AND YEAR(StockView.LastUpdate) = @Year  
            AND StockView.Pending_Qty > 0 
            AND StockView.item_id <> 0  
            AND StockView.pending_qty <> 0
        LEFT JOIN m_item WITH (NOLOCK) ON StockView.item_id = m_item.item_id  
        LEFT JOIN m_item_group WITH (NOLOCK) ON m_item.item_group_id = m_item_group.item_group_id
        OUTER APPLY 
    (SELECT m_group_field_setting.field_id  
     FROM m_group_field_setting WITH (NOLOCK)  
     WHERE m_group_field_setting.field_id = 1  
       AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK
        --WHERE (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID)
        GROUP BY Months.MonthNumber, Months.MonthName
        ORDER BY Months.MonthNumber;
    END
    ELSE
    BEGIN
        WITH numbers AS
        (
            SELECT 1 AS value
            UNION ALL
            SELECT value + 1 FROM numbers
            WHERE value + 1 <= DAY(EOMONTH(DATEFROMPARTS(@Year, @Month, 1)))
        )
        SELECT numbers.value AS Day,
            COALESCE(SUM(StockView.total_qty), 0) AS TotalQty,  
            COALESCE(SUM(StockView.sales_qty), 0) AS SalesQty,  
            COALESCE(SUM(StockView.pending_qty), 0) AS PendingQty,
                  COALESCE(SUM(CONVERT(NUMERIC(18, 2),(CASE WHEN (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID) THEN (CASE  
        WHEN KK.field_id IS NOT NULL THEN ((ISNULL(m_item.[weight_mtr], 0) * ISNULL(StockView.[length], 0) * ISNULL(StockView.pending_qty, 0) * ISNULL(m_item.thickness, 0)) / 1000)  
        ELSE ((ISNULL(m_item.[weight_mtr], 0) * ISNULL(StockView.[length], 0) * ISNULL(StockView.pending_qty, 0)) / 1000)  
    END) ELSE 0 END))),0) AS TotalWeight
        FROM numbers
        LEFT JOIN StockView ON DATEFROMPARTS(YEAR(StockView.LastUpdate), MONTH(StockView.LastUpdate), DAY(StockView.LastUpdate)) = DATEFROMPARTS(@Year, @Month, numbers.value)
            AND StockView.Pending_Qty > 0 
            AND StockView.item_id <> 0  
            AND StockView.pending_qty <> 0
        LEFT JOIN m_item WITH (NOLOCK) ON StockView.item_id = m_item.item_id  
        LEFT JOIN m_item_group WITH (NOLOCK) ON m_item.item_group_id = m_item_group.item_group_id
        OUTER APPLY 
    (SELECT m_group_field_setting.field_id  
     FROM m_group_field_setting WITH (NOLOCK)  
     WHERE m_group_field_setting.field_id = 1  
       AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK
       -- WHERE (@Dept_ID = 0 OR m_item_group.dept_id = @Dept_ID)
        GROUP BY numbers.value
        ORDER BY numbers.value;
    END
END;
GO


