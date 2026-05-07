USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[SP_GET_STOCK_TRACK]    Script Date: 07-05-2026 18:47:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[SP_GET_STOCK_TRACK]
    @STOCK_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT * FROM (
        
        -- ?? Opening Stock
        SELECT 
            SV.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.LENGTH,
            'Opening Stock' as Transfer_Page,
            'IN' as Transfer_Type,
            OSH.Total_Qty AS Qty,
            OSH.Entry_Date,
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM STOCKVIEW SV
        INNER JOIN OpeningStock_History OSH
            ON SV.ITEM_ID = OSH.ITEM_ID
            AND SV.STYPE = OSH.STYPE
            AND SV.RACK_ID = OSH.RACK_ID
            AND SV.GODOWN_ID = OSH.GODOWN_ID
            AND SV.LENGTH = OSH.LENGTH
            AND SV.WIDTH = OSH.WIDTH
        LEFT JOIN M_item mi
            ON mi.item_id = SV.ITEM_ID
        WHERE SV.ID = @STOCK_ID

         UNION ALL

        -- ?? GRN For Inward
        SELECT 
            GRN_Dtl.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            GRN_Dtl.LENGTH,
            'GRN IN - ' +  GM.GRN_No AS Transfer_Page,
            'IN' AS Transfer_Type,
            GRN_Dtl.ReceiveQty AS Qty,
            GM.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM GRN_Dtl
        LEFT JOIN GRN_Mst GM
            ON GM.GRN_Id = GRN_Dtl.GRN_Id
        LEFT JOIN M_item mi
            ON mi.item_id = GRN_Dtl.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = GRN_Dtl.Stock_Id
        WHERE GRN_Dtl.Stock_Id = @STOCK_ID
        AND GM.GRN_Type <> 'GRN-OUT'


           UNION ALL

        -- ?? GRN for Outward
        SELECT 
            GRN_Dtl.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            GRN_Dtl.LENGTH,
            'GRN OUT - '+  GM.GRN_No AS Transfer_Page,
            'OUT' AS Transfer_Type,
            GRN_Dtl.ReceiveQty AS Qty,
            GM.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM GRN_Dtl
        LEFT JOIN GRN_Mst GM
            ON GM.GRN_Id = GRN_Dtl.GRN_Id
        LEFT JOIN M_item mi
            ON mi.item_id = GRN_Dtl.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = GRN_Dtl.Stock_Id
        WHERE GRN_Dtl.Stock_Id = @STOCK_ID
        AND GM.GRN_Type = 'GRN-OUT'
           

        UNION ALL

        -- ?? MR (Material Issue)
        SELECT 
            MR_Items.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            MR_Items.LENGTH,
            'MR Item Issue - ' + mr.MR_Code AS Transfer_Page,
            'OUT' AS Transfer_Type,
            MR_Items.Issue_Qty AS Qty,
           mr.Authorised_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM MR_Items
        LEFT JOIN M_item mi
            ON mi.item_id = MR_Items.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = MR_Items.Stock_Id
        LEFT JOIN MaterialRequirement mr
            ON mr.MR_Id = MR_Items.MR_Id
        WHERE MR_Items.Stock_Id = @STOCK_ID
              AND MR_Items.Issue_Qty > 0


         UNION ALL

        -- ?? MR (Material Issue)
        SELECT 
            DCL.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.Length AS LENGTH,
            'Coating DC - ' + DC.DC_No AS Transfer_Page,
            'OUT' AS Transfer_Type,
            DCL.DC_Qty AS Qty,
            DC.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM DC_Dtl DCL
        LEFT JOIN DC_Mst DC
            ON DC.DC_Id = DCL.DC_Id
        LEFT JOIN M_item mi
            ON mi.item_id = DCL.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = DCL.Stock_Id
        WHERE DCL.Stock_Id = @STOCK_ID
              AND DC.CODC_Type = 'F'

                -- ?? stock transfer minus
         UNION ALL
          SELECT 
            STD.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.Length AS LENGTH,
            'Stock Transfer'  AS Transfer_Page,
            'OUT' AS Transfer_Type,
            STD.Qty AS Qty,
            ST.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM StockTrans_Dtl STD
        LEFT JOIN StockTrans_Mst ST
            ON ST.TransId = STD.TransId
        LEFT JOIN M_item mi
            ON mi.item_id = STD.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = STD.Stock_Id
        WHERE STD.Stock_Id = @STOCK_ID
              AND ST.Trans_Type NOT IN ('T_To_H', 'H_To_T')

                -- ?? stock transfer plus
         UNION ALL
          SELECT 
            STD.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            STD.SplitLength AS LENGTH,
            'Stock Transfer'  AS Transfer_Page,
            'In' AS Transfer_Type,
            STD.Qty AS Qty,
            ST.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM StockTrans_Dtl STD
        LEFT JOIN StockTrans_Mst ST
            ON ST.TransId = STD.TransId
        LEFT JOIN M_item mi
            ON mi.item_id = STD.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = STD.NewStock_Id
        WHERE STD.NewStock_Id = @STOCK_ID
              AND ST.Trans_Type NOT IN ('T_To_H', 'H_To_T')

                        -- ?? stock transfer t to h 
         UNION ALL
          SELECT 
            STD.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            STD.SplitLength AS LENGTH,
            'Stock Transfer H_TO_T '  AS Transfer_Page,
            'OUT' AS Transfer_Type,
            STD.Qty AS Qty,
            ST.Entry_Date as Entry_Date, 
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM StockTrans_Dtl STD
        LEFT JOIN StockTrans_Mst ST
            ON ST.TransId = STD.TransId
        LEFT JOIN M_item mi
            ON mi.item_id = STD.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = STD.Stock_Id
        WHERE STD.Stock_Id = @STOCK_ID
              AND ST.Trans_Type = 'H_To_T'

                            -- ?? stock transfer H to T
         UNION ALL
          SELECT 
            STD.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            STD.SplitLength AS LENGTH,
            'Stock Transfer T_TO_H'  AS Transfer_Page,
            'IN' AS Transfer_Type,
            STD.Qty AS Qty,
            ST.Entry_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM StockTrans_Dtl STD
        LEFT JOIN StockTrans_Mst ST
            ON ST.TransId = STD.TransId
        LEFT JOIN M_item mi
            ON mi.item_id = STD.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = STD.NewStock_Id
        WHERE STD.NewStock_Id = @STOCK_ID
              AND ST.Trans_Type = 'T_To_H'

                             -- ?? MR ORIGINAL LENGTH DEDUCTION
         UNION ALL
          SELECT 
            MRI.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.LENGTH AS LENGTH,
            'ORIGINAL LENGTH DEDUCT MR'  AS Transfer_Page,
            'OUT' AS Transfer_Type,
            MRI.Qty AS Qty,
            mr.Authorised_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM MR_Items MRI
        LEFT JOIN MaterialRequirement MR
            ON MR.MR_Id = MRI.MR_Id
        LEFT JOIN M_item mi
            ON mi.item_id = MRI.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = MRI.OriginalStock_Id
        WHERE MRI.OriginalStock_Id = @STOCK_ID
              AND MRI.IsChecked = 1
              AND MR.MR_TYPE = 'A'

                                     -- ?? SPLIT LENGTH ADD
         UNION ALL
          SELECT 
            MRI.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.LENGTH AS LENGTH,
            'SPLIT LENGTH MR'  AS Transfer_Page,
            'IN' AS Transfer_Type,
            MRI.Qty AS Qty,
            mr.Authorised_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM MR_Items MRI
        LEFT JOIN MaterialRequirement MR
            ON MR.MR_Id = MRI.MR_Id
        LEFT JOIN M_item mi
            ON mi.item_id = MRI.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = MRI.Stock_Id
        WHERE MRI.Stock_Id = @STOCK_ID
              AND MRI.IsChecked = 1
              AND MR.MR_TYPE = 'A'

                                     -- ?? REMAINING LENGTH ADD
         UNION ALL
          SELECT 
            MRI.ITEM_ID,
            mi.item_code,
            mi.item_name,
            SV.STYPE,
            SV.LENGTH AS LENGTH,
            'REMAINING LENGTH MR'  AS Transfer_Page,
            'IN' AS Transfer_Type,
            MRI.Qty AS Qty,
           mr.Authorised_Date as Entry_Date,  
            SV.Rack_ID,
            SV.GODOWN_ID,
            SV.WIDTH
        FROM MR_Items MRI
        LEFT JOIN MaterialRequirement MR
            ON MR.MR_Id = MRI.MR_Id
        LEFT JOIN M_item mi
            ON mi.item_id = MRI.ITEM_ID
        LEFT JOIN StockView SV
            ON SV.Id = MRI.RemainingStock_Id
        WHERE MRI.RemainingStock_Id = @STOCK_ID
              AND MRI.IsChecked = 1
              AND MR.MR_TYPE = 'A'

    ) A
    ORDER BY A.Entry_Date ASC
END;


GO


