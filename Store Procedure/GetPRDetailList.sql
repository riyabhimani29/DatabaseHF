USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetPRDetailList]    Script Date: 27-04-2026 11:32:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[GetPRDetailList] 
    @Project_Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        PD.Project_Id,
        PD.Item_Id,
        I.Item_Name,
        PD.OrderQty AS Quantity,
        PD.TotalCost,
        PM.Supplier_Id,
        ISNULL(S.Supplier_Name, 'N/A') AS Supplier_Name

    FROM PR_DTL PD

    INNER JOIN PR_MST PM 
        ON PD.PR_Id = PM.PR_Id

    LEFT JOIN M_Supplier S 
        ON PM.Supplier_Id = S.Supplier_Id

    LEFT JOIN M_Item I
        ON PD.Item_Id = I.Item_Id

    WHERE PD.Project_Id = @Project_Id

END
GO


