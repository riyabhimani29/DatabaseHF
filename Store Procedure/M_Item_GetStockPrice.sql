USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetStockPrice]    Script Date: 27-04-2026 12:22:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[M_Item_GetStockPrice] @Item_Id  INT =0,  
  										 @Length float = 0,
                                         @SupDetail_Id INT =0,
  										 @SType         CHAR='N' --,
  										-- @Godown_Id INT = 0
AS  
    SET nocount ON  
    SELECT
    StockView.id,
    StockView.[Length],
    StockView.Width,
    StockView.Tbl_Name,
    StockView.Total_Qty,
    StockView.Pending_Qty,
    StockView.Sales_Qty,
    StockView.LastUpdate,
    StockView.Rack_Id,
    M_Godown_Rack.Rack_Name,
    StockView.Godown_Id,
    M_Godown.Godown_Name,
    GRN_Dtl.Stock_Id,
    M_Item.Unit_Id,
    M_Item.Alternate_Unit_Id,
    MM_Unit.Master_Vals as Unit_Name,
    MM_AltUnit.Master_Vals as Alternate_Unit_Name,
    M_Item.AlternateUnitValue as Alternate_Unit_Value,
   -- M_Item.Item_Rate AS  UnitCost,
    CASE 
    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
        THEN ISNULL(M_Item.Item_Rate, 0)
    ELSE M_Item.Avg_Cost
END AS UnitCost,
    M_Item.weight_mtr,
     (
        SELECT
            SUM(SV2.Pending_Qty)
        FROM
            StockView AS SV2
        WHERE
            SV2.Item_Id = StockView.Item_Id
            AND SV2.[Length] = StockView.[Length]
     --       AND SV2.Godown_Id = @Godown_Id
    ) AS Max_Qty
FROM
    StockView
    left JOIN M_Item ON StockView.Item_Id = M_Item.Item_Id  
    --left JOIN M_Master on Master_Id = M_Item.Unit_Id
    LEFT JOIN M_Master AS MM_Unit ON MM_Unit.Master_Id = M_Item.Unit_Id
    LEFT JOIN M_Master AS MM_AltUnit ON MM_AltUnit.Master_Id = M_Item.Alternate_Unit_Id

  --  LEFT JOIN GRN_Dtl on StockView.Item_Id = GRN_Dtl.Item_Id AND StockView.Id = GRN_Dtl.Stock_Id AND StockView.[Length] = GRN_Dtl.[Length]
   left JOIN GRN_Dtl 
    ON GRN_Dtl.SupDetail_Id = @SupDetail_Id 
   AND StockView.Item_Id = GRN_Dtl.Item_Id
   AND StockView.Id = GRN_Dtl.Stock_Id
   left JOIN StockView_Tack on GRN_Dtl.GrnDtl_Id = StockView_Tack.Dtl_Id
   left JOIN M_Godown_Rack on StockView.Rack_Id = M_Godown_Rack.Rack_Id
   left JOIN M_Godown on StockView.Godown_Id = M_Godown.Godown_Id
WHERE
    StockView.Item_id = @Item_Id 
    --And StockView.Pending_Qty > 0
    And StockView.Godown_Id = 28

     
  --  AND StockView.Width = GRN_Dtl.Weight
   
 -- AND StockView.Godown_Id = @Godown_Id
   -- AND StockView.[Length] = @Length
    GROUP BY    StockView.id,
    MM_Unit.Master_Vals,
    MM_AltUnit.Master_Vals,
    M_Item.AlternateUnitValue,
    M_Item.Unit_Id,
    M_Item.Alternate_Unit_Id,
    M_Item.weight_mtr,
    StockView.[Length],
    StockView.Width,
    StockView.Tbl_Name,
    M_Item.Item_Rate,
    M_Item.Avg_Cost,
    StockView.Total_Qty,
    StockView.Pending_Qty,
    StockView.Item_Id,
    StockView.Sales_Qty,
    StockView.Rack_Id,
    M_Godown_Rack.Rack_Name,
    StockView.Godown_Id,
    M_Godown.Godown_Name,
    StockView.LastUpdate,
    GRN_Dtl.Stock_Id
        ORDER BY StockView.LastUpdate;
GO


