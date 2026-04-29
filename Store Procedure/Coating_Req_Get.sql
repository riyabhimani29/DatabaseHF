USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coating_Req_Get]    Script Date: 27-04-2026 11:09:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Coating_Req_Get]
    @Dept_ID int = 0,
    @fr_date date = NULL,
    @Tr_date date = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
        SELECT 
            Coating_Request.Coating_Req_Id,
            Coating_Request.BOM_Id,
            Coating_Request.Dept_ID,
            Coating_Request.Is_read,
            M_Department.Dept_Name,
            MR_Header.Site_Engineer AS SiteEnginner_Id,
            MR_Header.Coating_Colour AS Coating_ShadeId,
            MR_Header.Pd_Ref_No AS ProjectDocument,
            M_Project.Project_Id,
            M_Project.Project_Name,
            Coating_Request.[Date],
            BOM_MST.Quotation_Number,
            BOM_MST.Ref_Document_No,
            Coating_Dtl.Details
        FROM Coating_Request
        JOIN M_Department ON Coating_Request.Dept_ID = M_Department.Dept_ID
        JOIN BOM_MST ON Coating_Request.BOM_Id = BOM_MST.Bom_Id
        JOIN M_Project ON BOM_MST.Project_Id = M_Project.Project_Id
       OUTER APPLY (
    SELECT TOP 1
        MR.Site_Engineer,
        MR.Coating_Colour,
        MR.Pd_Ref_No
    FROM Coating_RequestDtl CRD
    JOIN MR_Items MRI ON CRD.BOM_Dtl_Id = MRI.MR_Items_Id
    JOIN MaterialRequirement MR ON MRI.MR_Id = MR.MR_Id
    WHERE CRD.Coating_Req_Id = Coating_Request.Coating_Req_Id
) AS MR_Header

        OUTER APPLY (
            SELECT 
                Coating_RequestDtl.Coating_ReqDtl_Id,
                Coating_RequestDtl.BOM_Dtl_Id,
                MR_Items.MR_Items_Id,
                MR_Items.[Length],
                
                Coating_RequestDtl.Width,
                Coating_RequestDtl.Weight,
                Coating_RequestDtl.Qty,
                MR_Items.Item_Id,
                M_Item.ImageName,
                M_Item.Item_Cate_Id,
                M_Item.Weight_Mtr,
                M_Item.Calc_Area,
                M_Item_Category.Item_Cate_Name,
                M_Item.Item_Group_Id,
                M_Item_Group.Item_Group_Name,
                M_Item_Group.Dept_ID,
                M_Department.Dept_Name,
                M_Item.Item_Name,
                M_Item.Item_Code,
                M_Item.HSN_Code,
                MR_Items.Godown_Id,
                M_Godown.Godown_Name,
                MR_Items.Godown_Rack_Id,
                CASE 
                    WHEN ISNULL(M_Item.Avg_Cost, 0) = 0 
                        THEN ISNULL(M_Item.Item_Rate, 0)
                    ELSE M_Item.Avg_Cost
                END AS UnitCost,
                M_Godown_Rack.Rack_Name,
                Coating_RequestDtl.Is_Requested,
                 (SELECT top 1 SV.Id FROM StockView as SV WHERE 
                SV.Item_Id = MR_Items.Item_Id AND SV.[Length] = MR_Items.[Length]
                --AND SV.Godown_Id = MR_Items.Godown_Id AND SV.Rack_Id = MR_Items.Godown_Rack_Id
                and (MR_Items.Stock_Id = 0 OR SV.Id = MR_Items.Stock_Id)
                )
                AS Stock_Id
            FROM Coating_RequestDtl
            JOIN MR_Items ON Coating_RequestDtl.BOM_Dtl_Id = MR_Items.MR_Items_Id
            LEFT JOIN MaterialRequirement ON MR_Items.MR_Id = MaterialRequirement.MR_Id
            JOIN M_Godown ON MR_Items.Godown_Id = M_Godown.Godown_Id
            LEFT JOIN M_Godown_Rack ON MR_Items.Godown_Rack_Id = M_Godown_Rack.Rack_Id
            JOIN M_Item ON MR_Items.Item_Id = M_Item.Item_Id
            JOIN M_Item_Category ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
            JOIN M_Item_Group ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id
            JOIN M_Department ON M_Item_Group.Dept_ID = M_Department.Dept_ID
           -- LEFT JOIN M_SupplierDtl ON M_Item.Item_Id = M_SupplierDtl.Item_Id
           -- LEFT JOIN M_Supplier ON M_Supplier.Supplier_Id = M_SupplierDtl.Supplier_Id
           OUTER APPLY (
                SELECT TOP 1 
                    SD.Supplier_Id,
                    S.Supplier_Name
                FROM M_SupplierDtl SD
                JOIN M_Supplier S ON S.Supplier_Id = SD.Supplier_Id
                WHERE SD.Item_Id = M_Item.Item_Id
            ) AS SupplierData

            WHERE Coating_RequestDtl.Coating_Req_Id = Coating_Request.Coating_Req_Id
      --        AND (Coating_RequestDtl.Is_Requested is null or Coating_RequestDtl.Is_Requested = 0)
            FOR JSON PATH
        ) AS Coating_Dtl (Details)

        WHERE (
                (@fr_date IS NULL AND @Tr_date IS NULL) OR
                (CONVERT(DATE, Coating_Request.Entry_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date))
              )
          AND Coating_Request.Dept_ID = CASE WHEN @Dept_ID = 0 THEN Coating_Request.Dept_ID ELSE @Dept_ID END
          AND ISJSON(Coating_Dtl.Details) = 1
          AND Coating_Dtl.Details IS NOT NULL
          AND Coating_Dtl.Details <> '[]' -- ?Exclude if no details

        ORDER BY Coating_Request.Coating_Req_Id DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END
GO


