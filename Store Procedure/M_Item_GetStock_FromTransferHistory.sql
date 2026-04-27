USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_GetStock_FromTransferHistory]    Script Date: 27-04-2026 12:22:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Item_GetStock_FromTransferHistory]
(
    @Dept_ID        INT = 1,
    @Item_Group_Id  INT = 0,
    @Item_Cate_Id   INT = 0,
    @Godown_Id      INT = 0,
    @Type          INT = 0,
    @SType          CHAR = 'A',
    @ViewType VARCHAR(10) = 'D',
    @FilterDate    DATE = '9999-12-31'
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        STH.ID,
        MG.godown_name                AS Godown,
        MIG.item_group_name           AS Component,
        MIC.item_cate_name            AS System,
        MI.item_name                  AS [Description],
        MI.Item_Rate                  AS Rate,
        MI.hsn_code                   AS HSN,
        STH.[Length]                  AS [Length],
        STH.Transfer_Qty              AS StockQuantity,
        STH.Remark                    AS Remark,
        CASE 
            WHEN STH.SType = 'C' THEN 'Coated'
            ELSE 'Non-Coated'
        END                           AS StockType,
        MGR.Rack_Name,
        STH.Transfer_Date             AS TransferDate,
        CASE 
            WHEN STH.Transfer_Type = 'IN' THEN 'Inward'
            ELSE 'Outward'
        END                           AS Transfer_Type
    FROM Stock_Transfer_History STH WITH (NOLOCK)

    INNER JOIN m_item MI WITH (NOLOCK)
        ON STH.Item_Id = MI.Item_Id

    INNER JOIN m_item_group MIG WITH (NOLOCK)
        ON MI.Item_Group_Id = MIG.Item_Group_Id

    INNER JOIN m_item_category MIC WITH (NOLOCK)
        ON MI.Item_Cate_Id = MIC.Item_Cate_Id

    LEFT JOIN m_godown MG WITH (NOLOCK)
        ON STH.Godown_Id = MG.Godown_Id

    LEFT JOIN M_Godown_Rack MGR WITH (NOLOCK)
        ON STH.Rack_Id = MGR.Rack_Id

    WHERE
        MIG.Dept_Id =
            CASE WHEN @Dept_ID = 0 THEN MIG.Dept_Id ELSE @Dept_ID END
        AND STH.Godown_Id =
            CASE WHEN @Godown_Id = 0 OR @Godown_Id IS NULL THEN STH.Godown_Id ELSE @Godown_Id END
        AND MI.Item_Group_Id =
            CASE WHEN @Item_Group_Id = 0 THEN MI.Item_Group_Id ELSE @Item_Group_Id END
        AND MI.Item_Cate_Id =
            CASE WHEN @Item_Cate_Id = 0 THEN MI.Item_Cate_Id ELSE @Item_Cate_Id END
        AND STH.SType =
            CASE WHEN @SType = 'A' THEN STH.SType ELSE @SType END

    ORDER BY STH.Transfer_Date DESC;
END;
GO


