USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetCoatingDCDetails]    Script Date: 27-04-2026 11:31:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



 
ALTER PROCEDURE [dbo].[GetCoatingDCDetails]
    @Project_Id INT
AS
BEGIN
    SET NOCOUNT ON;
 
    SELECT 
        DC.Project_Id,
        DC.DC_Id,
        DC.DC_Date,
        DC.Vehicle_No,
        DCD.DC_Qty AS Qty,
        S.Supplier_Name,
 
        E.Emp_Name AS SiteEngineer_Name,
 
        I.Item_Id,
        I.Item_Name
 
    FROM DC_MST DC
 
    INNER JOIN DC_DTL DCD
        ON DC.DC_Id = DCD.DC_Id
 
    INNER JOIN M_Item I
        ON DCD.Item_Id = I.Item_Id
 
    LEFT JOIN M_Supplier S
        ON DC.Supplier_Id = S.Supplier_Id
 
    LEFT JOIN M_Employee E
        ON DC.SiteEnginner_Id = E.Emp_Id
 
    WHERE DC.Project_Id = @Project_Id;
 
END
GO


