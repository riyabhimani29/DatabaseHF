USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[StockView_Tack_Get]    Script Date: 27-04-2026 15:05:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[StockView_Tack_Get]
    @Stock_Id INT = 6052
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @_Item_Id     INT = 0,
        @_Pending_Qty NUMERIC(18,3) = 0,
        @_Opening_Qty NUMERIC(18,3) = 0,
        @_Length      NUMERIC(18,3) = 0,
        @_Rack_Id     INT = 0,
        @_Godown_Id   INT = 0,
        @_SType       CHAR = 'N';

    /*====================================================
      STOCK BASIC INFO
    ====================================================*/
    SELECT 
        @_Item_Id   = ISNULL(Item_Id,0),
        @_Length    = ISNULL(Length,0),
        @_Rack_Id   = ISNULL(Rack_Id,0),
        @_Godown_Id = ISNULL(Godown_Id,0),
        @_SType     = ISNULL(SType,'N')
    FROM StockView WITH (NOLOCK)
    WHERE Id = @Stock_Id;

    /*====================================================
      OPENING QTY
    ====================================================*/
    SET @_Opening_Qty =
    (
        SELECT ISNULL(SUM(Total_Qty),0)
        FROM OpeningStock_History WITH (NOLOCK)
        WHERE Item_Id   = @_Item_Id
          AND Length    = @_Length
          AND Rack_Id   = @_Rack_Id
          AND Godown_Id = @_Godown_Id
          AND SType     = @_SType
    );

    IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
        DROP TABLE #tmp;

    SELECT XX.*
    INTO #tmp
    FROM
    (
        /*================================================
          OPENING STOCK ROW
        ================================================*/
        SELECT
            0 AS Id,
            0 AS Stock_Id,
            '' AS Remark,
            NULL AS Is_NewStock,
            NULL AS Is_EditStock,
            '' AS Item_Code,
            '' AS Item_Name,
            '' AS SType,
            @_Length AS Length,
            'Opening Stock' AS E_Type,
            0 AS Total_Qty,
            0 AS PreBal,
            0 AS Credit_Stock,
            0 AS Debit_Stock,
            @_Opening_Qty AS Pending_Qty,
            NULL AS Entry_Date,
            0 AS Qty,
            'Opening Stock' AS DocumentNo,
            '' AS MR_Code,
            '' AS Project_Name

        UNION ALL

        /*================================================
          STOCK TRANSACTIONS
        ================================================*/
        SELECT
            SVT.Id,
            SVT.Stock_Id,
            SVT.Remark,
            SVT.Is_NewStock,
            SVT.Is_EditStock,
            MI.Item_Code,
            MI.Item_Name,
            SV.SType,
            SV.Length,

            CASE 
                WHEN SVT.E_Type = 'MR-Item-Issue' THEN 'MR Issue (Outward)'
                ELSE SVT.E_Type
            END AS E_Type,

            SV.Total_Qty,
            0 AS PreBal,

            /*============================================
              CREDIT STOCK
            ============================================*/
            CASE 
                WHEN SVT.E_Type IN ('PO-GRN','DC-GRN','Reconciliation +')
                THEN SVT.Qty

                WHEN SVT.E_Type IN ('STK-TRANS','Internal-STK-TRANS')
                     AND STD.NewStock_Id = @Stock_Id
                THEN SVT.Qty

                ELSE 0
            END AS Credit_Stock,

            /*============================================
              DEBIT STOCK
            ============================================*/
            CASE 
                WHEN SVT.E_Type IN ('CO-DC','MR-Item-Issue')
                     AND SVT.Is_EditStock = 1
                THEN SVT.Qty

                WHEN SVT.E_Type = 'Reconciliation -'
                     AND SVT.Is_EditStock = 1
                THEN SVT.Qty

                WHEN SVT.E_Type IN ('STK-TRANS','Internal-STK-TRANS')
                     AND STD.Stock_Id = @Stock_Id
                THEN SVT.Qty

                ELSE 0
            END AS Debit_Stock,

            SV.Pending_Qty,
            SVT.Entry_Date,
            SVT.Qty,

            CASE
                WHEN SVT.E_Type = 'PO-GRN' THEN GRN_Mst.GRN_No
                WHEN SVT.E_Type = 'CO-DC' THEN DC_Mst.DC_No
                WHEN SVT.E_Type IN ('STK-TRANS','Internal-STK-TRANS') THEN 'StockTrans_Dtl'
                ELSE ''
            END AS DocumentNo,

            MR.MR_Code,
            MP.Project_Name

        FROM StockView_Tack SVT WITH (NOLOCK)

        LEFT JOIN StockView SV WITH (NOLOCK) 
            ON SVT.Stock_Id = SV.Id

        LEFT JOIN M_Item MI WITH (NOLOCK) 
            ON SV.Item_Id = MI.Item_Id

        LEFT JOIN MR_Items MRI WITH (NOLOCK) 
            ON SVT.E_Type = 'MR-Item-Issue'
           AND SVT.Dtl_Id = MRI.MR_Items_Id

        LEFT JOIN MaterialRequirement MR WITH (NOLOCK)  
            ON MRI.MR_Id = MR.MR_Id

        LEFT JOIN M_Project MP WITH (NOLOCK)  
            ON MR.Project_Id = MP.Project_Id

        LEFT JOIN GRN_Dtl WITH (NOLOCK) 
            ON SVT.E_Type IN ('PO-GRN','DC-GRN','GRN-OUT') 
           AND SVT.Dtl_Id = GRN_Dtl.GrnDtl_Id 
           AND SVT.Qty = GRN_Dtl.ReceiveQty

        LEFT JOIN GRN_Mst WITH (NOLOCK) 
            ON GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id

        LEFT JOIN DC_Dtl WITH (NOLOCK) 
            ON SVT.E_Type IN ('CO-DC','CO-DC-Scrap') 
           AND SVT.Dtl_Id = DC_Dtl.DCDtl_Id 
           AND SVT.Qty = DC_Dtl.Qty

        LEFT JOIN DC_Mst WITH (NOLOCK) 
            ON DC_Dtl.DC_Id = DC_Mst.DC_Id

        LEFT JOIN StockTrans_Dtl STD WITH (NOLOCK)
            ON SVT.E_Type IN ('STK-TRANS','Internal-STK-TRANS')
           AND SVT.Dtl_Id = STD.Dtl_Id

        LEFT JOIN StockTrans_Mst STM WITH (NOLOCK)
            ON STD.TransId = STM.TransId

        WHERE SVT.Stock_Id = @Stock_Id
    ) XX;

    /*====================================================
      FINAL RESULT
    ====================================================*/
    SELECT *
    FROM #tmp
    ORDER BY Entry_Date;

END


GO


