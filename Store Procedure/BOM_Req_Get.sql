USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_Req_Get]    Script Date: 27-04-2026 10:59:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[BOM_Req_Get]
    @Emp_Id   INT = 0,
    @Dept_ID  INT = 0,
    @Type     INT = 0,
    @fr_date  DATE = NULL,
    @Tr_date  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
        SELECT
            -- ===== HEADER DATA =====
            PR.BOM_PO_Req_Id,
            PR.BOM_Id,
            PR.PoRequestTo,
            PR.Dept_ID,
            PR.[Date],
            PR.Entry_User,
            PR.Entry_Date,
            PR.Upd_User,
            PR.Upd_Date,
            PR.Is_read,

            P.Project_Id,
            P.Project_Name,
            MD.Dept_Name,
            ME.Emp_Name,

            BM.Quotation_Number,
            BM.Ref_Document_No,

            -- ===== DETAIL DATA (FLAT) =====
            PRD.BOM_PO_ReqDtl_Id,
            PRD.BOM_Dtl_Id,
            PRD.Qty,
            PRD.[Length],
            PRD.[Width],
            I.[Weight_Mtr] AS [Weight],
            PRD.UnitCost,
            PRD.Grn_Qty,
            PRD.Is_Requested,
            PRD.Is_PO,
            MRI.SupDetail_Id,
            I.Item_Id,
            I.Item_Code,
            I.Item_Name,
            I.Unit_Id,
            I.HSN_Code,
            I.Item_Group_Id,
            I.Item_Cate_Id,
             (
                  SELECT STRING_AGG(CAST(SD.Supplier_Id AS VARCHAR(20)), ',')
                  FROM M_SupplierDtl SD
                  WHERE SD.Item_Id = I.Item_Id
             ) AS Supplier_Ids,
             (
               SELECT STRING_AGG(S.Supplier_Name, ',')
               FROM M_SupplierDtl SD
               INNER JOIN M_Supplier S
               ON S.Supplier_Id = SD.Supplier_Id
               WHERE SD.Item_Id = I.Item_Id
               ) AS Supplier_Names,
            MIG.Item_Group_Name,
            MIC.Item_Cate_Name,

            MR.MR_Code,
            MR.Pd_Ref_No,
            MR.Quotation_No,

            P2.Project_Id   AS Item_Project_Id,
            P2.Project_Name AS Item_Project_Name,
            PRD.Remark

        FROM BOM_PO_Request PR
        LEFT JOIN BOM_PO_RequestDtl PRD
            ON PRD.BOM_PO_Req_Id = PR.BOM_PO_Req_Id

        LEFT JOIN BOM_MST BM
            ON BM.Bom_Id = PR.BOM_Id

        LEFT JOIN M_Project P
            ON P.Project_Id = BM.Project_Id

        LEFT JOIN M_Department MD
            ON MD.Dept_ID = PR.Dept_ID

        LEFT JOIN M_Employee ME
            ON ME.Emp_Id = PR.Entry_User

        LEFT JOIN MR_Items MRI
            ON MRI.MR_Items_Id = PRD.BOM_Dtl_Id

        LEFT JOIN M_Item I
            ON I.Item_Id = MRI.Item_Id

        LEFT JOIN MaterialRequirement MR
            ON MR.MR_Id = MRI.MR_Id

        LEFT JOIN M_Item_Group MIG
            ON MIG.Item_Group_Id = I.Item_Group_Id

        LEFT JOIN M_Item_Category MIC
            ON MIC.Item_Cate_Id = I.Item_Cate_Id

        LEFT JOIN BOM_MST BM2
            ON BM2.Bom_Id = PR.BOM_Id

        LEFT JOIN M_Project P2
            ON P2.Project_Id = BM2.Project_Id

        WHERE
            (
                (@fr_date IS NULL AND @Tr_date IS NULL)
                OR (CONVERT(DATE, PR.[Date]) BETWEEN @fr_date AND @Tr_date)
            )
            AND PR.Dept_ID = CASE 
                                WHEN @Dept_ID = 0 THEN PR.Dept_ID 
                                ELSE @Dept_ID 
                             END

        ORDER BY PR.BOM_PO_Req_Id DESC, PRD.BOM_PO_ReqDtl_Id DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END
GO


