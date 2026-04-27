USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Stock_Daily_GetHistory]    Script Date: 27-04-2026 14:51:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Stock_Daily_GetHistory]                                                               
    @Stock_Id INT = 598      -- , @Entry_Date  date=''        
AS                                                                                  
    SET nocount ON  
 DECLARE @_Item_Id     AS INT = 0,  
        @_Pending_Qty AS NUMERIC(18, 3) =0  ,  
        @_Length AS NUMERIC(18, 3) =0 ,
		@_Rack_Id AS int  =0 
  
SELECT @_Item_Id = Isnull(StockView.Item_Id, 0)  ,
		@_Length = Isnull(StockView.Length, 0)   ,
		@_Rack_Id = Isnull(StockView.Rack_Id, 0)  
FROM   StockView WITH(nolock)  
WHERE  StockView.Id = @Stock_Id  
 

SELECT XX.Id,
		XX.godown_name,
       XX.stype, 
		lag(XX.Pending_Qty) Over (order by  XX.Id) Total_Qty,
		--XX.Total_Qty,
		XX.sales_qty, 
       XX.Pending_Qty,
       XX.transfer_qty,
       XX.adjust_qty,
       XX.length,
       XX.scrap_qty,
       XX.scrap_settle,
       XX.lastupdate,
       XX.width,
       XX.rack_name,
       XX.remark,
       XX.entry_date
from  ( 
SELECT stock_daily.Id,
		m_godown.godown_name,
       stock_daily.stype,
       --,Stock_Daily.Total_Qty 
		   case when InStock.GRN_Date is not Null then InStock.ReceiveQty else null end AS Total_Qty,
		   null sales_qty,
       --stock_daily.sales_qty,
       stock_daily.pending_qty AS Pending_Qty,
       stock_daily.transfer_qty,
       stock_daily.adjust_qty,
       stock_daily.length,
       stock_daily.scrap_qty,
       stock_daily.scrap_settle,
       stock_daily.lastupdate,
       stock_daily.width,
       m_godown_rack.rack_name,
       stock_daily.remark,
       stock_daily.entry_date
FROM   stock_daily WITH(nolock)
	OUTER apply (SELECT CONVERT(VARCHAR, GRN_Mst.GRN_Date, 103)GRN_Date,
                           SUM(GRN_Dtl.ReceiveQty) AS ReceiveQty
                    FROM   GRN_Mst  WITH(nolock)
                           LEFT JOIN GRN_Dtl   WITH(nolock)ON GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id
                    WHERE  CONVERT(VARCHAR, GRN_Mst.GRN_Date, 103) = CONVERT(VARCHAR, stock_daily.entry_date, 103)
                           AND GRN_Dtl.item_id = stock_daily.item_id 
                           AND GRN_Dtl.stock_id = stock_daily.stock_id
						   group by CONVERT(VARCHAR, GRN_Mst.GRN_Date, 103)
						   ) AS InStock
       LEFT JOIN m_godown_rack WITH(nolock) ON stock_daily.rack_id = m_godown_rack.rack_id
       LEFT JOIN m_godown WITH(nolock) ON stock_daily.godown_id = m_godown.godown_id
WHERE  stock_daily.item_id = @_Item_Id
       AND stock_daily.length = @_Length
	   and  InStock.GRN_Date is not Null
 union All 
SELECT stock_daily.Id,
		m_godown.godown_name,
       stock_daily.stype,
       --,Stock_Daily.Total_Qty 
       Lag(pending_qty) OVER ( ORDER BY id )       AS Total_Qty,
		   case when WW.DC_Date is not Null then WW.Qty else null end AS sales_qty,
       --stock_daily.sales_qty,
       stock_daily.pending_qty AS Pending_Qty,
       stock_daily.transfer_qty,
       stock_daily.adjust_qty,
       stock_daily.length,
       stock_daily.scrap_qty,
       stock_daily.scrap_settle,
       stock_daily.lastupdate,
       stock_daily.width,
       m_godown_rack.rack_name,
       stock_daily.remark,
       stock_daily.entry_date
FROM   stock_daily WITH(nolock)
       OUTER apply (SELECT dc_mst.dc_date,
                           dc_dtl.qty
                    FROM   dc_mst  WITH(nolock)
                           LEFT JOIN dc_dtl  WITH(nolock) ON dc_dtl.dc_id = dc_mst.dc_id
                    WHERE  CONVERT(VARCHAR, dc_mst.dc_date, 103) = CONVERT(VARCHAR, stock_daily.entry_date, 103)
                           AND dc_dtl.item_id = stock_daily.item_id
                           --AND dc_dtl.itemlength = stock_daily.length
                           AND dc_dtl.stock_id = stock_daily.stock_id) AS WW
       LEFT JOIN m_godown_rack WITH(nolock) ON stock_daily.rack_id = m_godown_rack.rack_id
       LEFT JOIN m_godown WITH(nolock) ON stock_daily.godown_id = m_godown.godown_id
WHERE  stock_daily.item_id = @_Item_Id
       AND stock_daily.length = @_Length
	   and  WW.DC_Date is not Null
 ---ORDER  BY Stock_Daily.id DESC   
 ) XX
    
GO


