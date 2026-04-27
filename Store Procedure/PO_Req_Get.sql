USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_Req_Get]    Script Date: 27-04-2026 14:29:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PO_Req_Get]
    @Emp_Id int = 0,
    @Dept_ID int = 0,
    @Type int = 0,
    @fr_date date = NULL,
    @Tr_date date = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
    SELECT
  PO_Req_Id,
  Authorize_Person_Id,
  PO_Request_MST.Dept_ID,
  M_Department.Dept_Name,
  M_Employee.Emp_Name as Authorize_Person_Name,
  PO_Request_MST.Entry_Date,
  PO_Request_MST.Upd_Date,
  PO_Request_MST.Approve_Date,
  PO_Request_MST.Is_Approved,
  PO_Request_MST.PO_Ref_No,
  M_Supplier.Supplier_Id,
  M_Supplier.Supplier_Name,
   (
  SELECT
  PO_Request_Dtl.PO_ReqDtl_Id,
  PO_Request_Dtl.BOM_PO_ReqDtl_Id,
  PO_Req_Id,
  M_Item_Category.Item_Cate_Id,
  M_Item_Category.Item_Cate_Name,
  M_Item_Group.Item_Group_Id,
  M_Item_Group.Item_Group_Name,
  PO_Request_Dtl.Item_Id,
  M_Item.Item_Name,
  M_Item.HSN_Code,
  M_Item.Item_Code,
  M_Item.UnitValue,
  M_Godown.Godown_Id,
  M_Godown.Godown_Name,
  M_Godown_Rack.Rack_Id as Godown_Rack_Id,
  M_Godown_Rack.Rack_Name,
  PO_Request_Dtl.Qty,
  PO_Request_Dtl.[Length],
  PO_Request_Dtl.Weight,
  PO_Request_Dtl.Width,
  PO_Request_Dtl.Is_Approved,
  PO_Request_Dtl.Reject_Reason,
  M_SupplierDtl.SupDetail_Id,
  M_SupplierDtl.SupItem_Code,
  PO_Request_Dtl.Project_Id,
  M_Project.Project_Name,
  M_Master.Master_Vals as "UnitName",
ISNULL((
    SELECT TOP 1 GRN_Dtl.UnitCost 
    FROM StockView
    JOIN GRN_Dtl ON StockView.Item_Id = GRN_Dtl.Item_Id
    WHERE StockView.Item_Id = PO_Request_Dtl.Item_Id
      AND StockView.[Length] = GRN_Dtl.[Length]
    ORDER BY StockView.LastUpdate DESC
), BOM_PO_RequestDtl.UnitCost) AS Last_Updated_Price,
    (
  
 SELECT top 1 StockView.LastUpdate FROM StockView
     JOIN GRN_Dtl on StockView.Item_Id = GRN_Dtl.Item_Id
 WHERE StockView.Item_Id = PO_Request_Dtl.Item_Id
 AND StockView.[Length] = GRN_Dtl.[Length] ORDER BY StockView.LastUpdate DESC
  ) as Last_Updated_Date
  FROM PO_Request_Dtl
  LEFT join BOM_PO_RequestDtl ON BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id = PO_Request_Dtl.BOM_PO_ReqDtl_Id
  LEFT join M_Item on PO_Request_Dtl.Item_Id = M_Item.Item_Id
  LEFT join M_Master on M_Item.Unit_Id = M_Master.Master_Id
  LEFT join M_Project ON PO_Request_Dtl.Project_Id = M_Project.Project_Id
  LEFT join M_Item_Category on M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
  LEFT join M_Item_Group on M_Item_Category.Item_Group_Id = M_Item_Group.Item_Group_Id
  LEFT join M_Godown on PO_Request_Dtl.Godown_Id = M_Godown.Godown_Id
  LEFT join M_Godown_Rack on PO_Request_Dtl.Godown_Rack_Id = M_Godown_Rack.Rack_Id
  LEFT JOIN M_SupplierDtl on M_Supplier.Supplier_Id = M_SupplierDtl.Supplier_Id
  AND M_SupplierDtl.Item_Id = M_Item.Item_Id
  WHERE PO_Request_Dtl.PO_Req_Id = PO_Request_MST.PO_Req_Id 
    AND (
        (@Type = 1 AND PO_Request_Dtl.Is_Approved != 3) OR
        (PO_Request_Dtl.Is_Approved = PO_Request_Dtl.Is_Approved)
      )
            FOR JSON PATH
        ) AS Details
FROM
  PO_Request_MST
  JOIN M_Department ON PO_Request_MST.Dept_ID = M_Department.Dept_ID
  JOIN M_Employee ON PO_Request_MST.Authorize_Person_Id = M_Employee.Emp_Id
  LEFT JOIN M_Supplier ON PO_Request_MST.Supplier_Id = M_Supplier.Supplier_Id
   WHERE --PO_Request_MST.Authorize_Person_Id = CASE WHEN @Emp_Id = 0 THEN PO_Request_MST.Authorize_Person_Id ELSE @Emp_Id END
  --AND 
  (
        (@fr_date IS NULL AND @Tr_date IS NULL) OR
        (CONVERT(DATE, PO_Request_MST.Entry_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date))
      )
  AND PO_Request_MST.Dept_ID = CASE WHEN @Dept_ID = 0 THEN PO_Request_MST.Dept_ID ELSE @Dept_ID END
  AND (
        (@Type = 0 AND PO_Request_MST.Is_Approved = @Type)
        OR
         (@Type = 3 AND PO_Request_MST.Is_Approved IN (0, 1, 2, 3))
         OR
        (@Type <> 0 AND PO_Request_MST.Is_Approved IN (1, 2))
      )
  ORDER BY PO_Request_MST.PO_Req_Id DESC
   FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END
GO


