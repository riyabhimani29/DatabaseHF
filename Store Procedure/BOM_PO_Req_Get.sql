USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_PO_Req_Get]    Script Date: 27-04-2026 10:56:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[BOM_PO_Req_Get]
    @Emp_Id int = 0,
    @Dept_ID int = 0,
    @BOM_Id int = 0,
    @Supplier_Id int = 0,
    @fr_date date = NULL,
    @Tr_date date = NULL,
    @OnlyUnrequested bit = 0  -- <-- NEW PARAMETER
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
        SELECT 
            BOM_PO_Request.BOM_PO_Req_Id,
            BOM_PO_Request.BOM_Id,
            BOM_PO_Request.PoRequestTo,
            BOM_PO_Request.Dept_ID,
            BOM_PO_Request.Is_read,
            M_Department.Dept_Name,
            M_Project.Project_Id,
            M_Project.Project_Name,
            BOM_PO_Request.[Date],
            BOM_MST.Quotation_Number,
            BOM_MST.Ref_Document_No,
            BOM_PO_Dtl.Details
        FROM BOM_PO_Request
        left JOIN M_Department ON BOM_PO_Request.Dept_ID = M_Department.Dept_ID
        left JOIN BOM_MST ON BOM_PO_Request.BOM_Id = BOM_MST.Bom_Id
        left JOIN M_Project ON BOM_MST.Project_Id = M_Project.Project_Id

        OUTER APPLY (
            SELECT 
                BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id,
                MR_Items.MR_Items_Id,
                MR_Items.[Length],
                BOM_PO_RequestDtl.Width,
                BOM_PO_RequestDtl.Weight,
                BOM_PO_RequestDtl.Qty,
                MR_Items.Item_Id,
                M_Item.Item_Cate_Id,
                M_Item_Category.Item_Cate_Name,
                M_Item.Item_Group_Id,
                M_Item_Group.Item_Group_Name,
                M_Item_Group.Dept_ID,
                M_Department.Dept_Name,
                M_Item.Item_Name,
                M_Item.HSN_Code,
                M_Item.Item_Code,
                M_Item.ImageName,
                MR_Items.Godown_Id,
                M_Godown.Godown_Name,
                MR_Items.Godown_Rack_Id,
                MR_Items.Qty as "Total_Qty",
                M_Item.UnitValue,
                M_Godown_Rack.Rack_Name,
                BOM_PO_RequestDtl.Is_Requested
            FROM BOM_PO_RequestDtl
            left JOIN MR_Items ON BOM_PO_RequestDtl.BOM_Dtl_Id = MR_Items.MR_Items_Id
            left JOIN M_Godown ON MR_Items.Godown_Id = M_Godown.Godown_Id
            LEFT JOIN M_Godown_Rack ON MR_Items.Godown_Rack_Id = M_Godown_Rack.Rack_Id
            left JOIN M_Item ON MR_Items.Item_Id = M_Item.Item_Id
            left JOIN M_Item_Category ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
            left JOIN M_Item_Group ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id
            left JOIN M_Department ON M_Item_Group.Dept_ID = M_Department.Dept_ID
            LEFT JOIN M_SupplierDtl ON M_Item.Item_Id = M_SupplierDtl.Item_Id
            LEFT JOIN M_Supplier ON M_Supplier.Supplier_Id = M_SupplierDtl.Supplier_Id
            WHERE BOM_PO_RequestDtl.BOM_PO_Req_Id = BOM_PO_Request.BOM_PO_Req_Id
              AND (@Supplier_Id = 0 OR M_Supplier.Supplier_Id = @Supplier_Id)
              AND (
                    @OnlyUnrequested = 1 OR
                    (BOM_PO_RequestDtl.Is_Requested IS NULL OR BOM_PO_RequestDtl.Is_Requested = 0)
                  )
              GROUP BY 
              BOM_PO_RequestDtl.BOM_PO_ReqDtl_Id,
              MR_Items.MR_Items_Id,
              MR_Items.[Length],
              BOM_PO_RequestDtl.Qty,
              BOM_PO_RequestDtl.Width, 
              BOM_PO_RequestDtl.Weight,
              MR_Items.Item_Id,
              M_Item.Item_Cate_Id, 
              M_Item_Category.Item_Cate_Name, 
              M_Item.Item_Group_Id,
              M_Item_Group.Item_Group_Name,
              M_Item_Group.Dept_ID,
              M_Item.Item_Code,
              M_Department.Dept_Name,
              M_Item.Item_Name,
              M_Item.UnitValue,
              M_Item.HSN_Code,
              MR_Items.Godown_Id,
              M_Godown.Godown_Name,
              MR_Items.Godown_Rack_Id,
              M_Godown_Rack.Rack_Name,
              BOM_PO_RequestDtl.Is_Requested,
              M_Item.ImageName,
              MR_Items.Qty
            FOR JSON PATH
        ) AS BOM_PO_Dtl (Details)

        WHERE 
        --BOM_PO_Request.PoRequestTo = CASE WHEN @Emp_Id = 0 THEN BOM_PO_Request.PoRequestTo ELSE @Emp_Id END
          --AND 
          (
                (@fr_date IS NULL AND @Tr_date IS NULL) OR
                (CONVERT(DATE, BOM_PO_Request.Entry_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date))
              )
          AND BOM_PO_Request.Dept_ID = CASE WHEN @Dept_ID = 0 THEN BOM_PO_Request.Dept_ID ELSE @Dept_ID END
           AND BOM_PO_Request.BOM_Id = CASE WHEN @BOM_Id = 0 THEN BOM_PO_Request.BOM_Id ELSE @BOM_Id END
          AND ISJSON(BOM_PO_Dtl.Details) = 1
          AND BOM_PO_Dtl.Details IS NOT NULL
          AND BOM_PO_Dtl.Details <> '[]'
        ORDER BY BOM_PO_Request.BOM_PO_Req_Id DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END

GO


