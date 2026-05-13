USE [db_a8637c_hifaberp]
GO
/****** Object:  StoredProcedure [dbo].[BOM_Request_Get]    Script Date: 13-05-2026 11:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[BOM_Request_Get]
    @Dept_ID  INT = 0,
    @Type INT = 1,
    @fr_date  DATE = NULL,
    @Tr_date  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    if(@Type = 1)
    BEGIN

    SELECT (
        SELECT
            MIG.Item_Group_Id,
            MIG.Item_Group_Name,
            MIC.Item_Cate_Id,
            MIC.Item_Cate_Name,
            I.HSN_Code,
            Pdtl2.Discount_Percentage,
            Pmst.Dept_ID,
            I.Item_Code,
            Pmst.OrderNo,
            I.Item_Id,
            I.Unit_Id,
             ISNULL(Pdtl2.[Length], 0) AS [Length],
             ISNULL(Msd.SupDetail_Id, 0) AS SupDetail_Id,
            Pdtl2.PrDtl_Id,
            I.Item_Name,
            --PR.[Date],
            Pmst.PO_Date as [Date],
            P.Project_Id,
            P.Project_Name,
            Pdtl2.MR_Code,
            Msd.SupItem_Code,
            Ms.Supplier_Name,
            ISNULL(Ms.Supplier_Id, 0) AS Supplier_Id,
            MG.Godown_Name,
            ISNULL(Pdtl2.OrderQty, 0) AS OrderQty,
            ISNULL(Pdtl2.UnitCost, 0) AS UnitCost,  
            Pdtl2.Is_Read AS IS_PO,
            MM.Master_Vals,
            ISNULL( Pdtl2.TotalCost, 0) AS TotalCost,
            ISNULL(Pmst.GrossAmount, 0) AS GrossAmount,
            ISNULL(Pmst.CGSTTotal, 0) AS CGSTTotal,
             ISNULL(Pmst.IGSTTotal, 0) AS IGSTTotal,
            ISNULL(Pmst.SGSTTotal, 0) AS SGSTTotal,
            ISNULL(Pmst.NetAmount, 0) AS NetAmount,
            MEE.Emp_Name,
            Pdtl2.Remark,
            Pdtl2.Weight,
            Pdtl2.TotalWeight,
            Pdtl2.Width,
            Pdtl2.Length_Mtr AS Length_Meter,
            ISNULL(Pdtl2.Pd_Ref_No,'') AS Pd_Ref_No
            

          FROM  PR_DTL Pdtl2

            LEFT JOIN PR_MST Pmst
            ON Pmst.PR_Id = Pdtl2.PR_Id
         
        LEFT JOIN BOM_PO_RequestDtl PRD
            ON Pdtl2.Req_Id = PRD.BOM_PO_ReqDtl_Id

        LEFT JOIN BOM_PO_Request PR
            ON PR.BOM_PO_Req_Id = PRD.BOM_PO_Req_Id


        LEFT JOIN BOM_MST BM
            ON BM.Bom_Id = PR.BOM_Id

        LEFT JOIN M_Project P
            ON P.Project_Id = Pdtl2.Project_Id

        LEFT JOIN M_Department MD
            ON MD.Dept_ID = PR.Dept_ID

        LEFT JOIN M_Employee ME
            ON ME.Emp_Id = PR.Entry_User

        LEFT JOIN MR_Items MRI
            ON MRI.MR_Items_Id = PRD.BOM_Dtl_Id

        LEFT JOIN M_Item I
            ON I.Item_Id = Pdtl2.Item_Id

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

         LEFT JOIN M_Supplier Ms
            ON Ms.Supplier_Id = Pdtl2.Supplier_Id
       
        LEFT JOIN M_SupplierDtl Msd
            ON Msd.Supplier_Id = Ms.Supplier_Id and Msd.Item_Id = Pdtl2.Item_Id

         

         LEFT JOIN M_Godown MG
            ON MG.Godown_Id = Pmst.Godown_Id

         LEFT JOIN M_Master MM
            ON MM.Master_Id = I.Unit_Id

         LEFT JOIN M_Employee MEE
            ON MEE.Emp_Id = Pmst.ReqRaisedBy_Id           

        WHERE
            Pdtl2.Is_Checked = 1 AND
            (
                (@fr_date IS NULL AND @Tr_date IS NULL)
                OR (CONVERT(DATE, Pmst.PO_Date) BETWEEN @fr_date AND @Tr_date)
            )
          AND MIG.Dept_ID = @Dept_ID

        ORDER BY PR.BOM_PO_Req_Id DESC, PRD.BOM_PO_ReqDtl_Id DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;
END
ELSE
BEGIN
    SELECT (
        SELECT
            MIG.Item_Group_Id,
            MIG.Item_Group_Name,
            MIC.Item_Cate_Id,
            MIC.Item_Cate_Name,
            I.HSN_Code,
            Pdtl2.Discount_Percentage,
            Pmst.Dept_ID,
            I.Item_Code,
            Pmst.OrderNo,
            I.Item_Id,
            I.Unit_Id,
             ISNULL(Pdtl2.[Length], 0) AS [Length],
             ISNULL(Msd.SupDetail_Id, 0) AS SupDetail_Id,
            Pdtl2.PrDtl_Id,
            I.Item_Name,
            --PR.[Date],
            Pmst.PO_Date as [Date],
            P.Project_Id,
            P.Project_Name,
            MR.MR_Code,
            Msd.SupItem_Code,
            Ms.Supplier_Name,
            ISNULL(Ms.Supplier_Id, 0) AS Supplier_Id,
            MG.Godown_Name,
            ISNULL(Pdtl2.OrderQty, 0) AS OrderQty,
            ISNULL(Pdtl2.UnitCost, 0) AS UnitCost,  
            Pdtl2.Is_Read AS IS_PO,
            MM.Master_Vals,
            ISNULL( Pdtl2.TotalCost, 0) AS TotalCost,
            ISNULL(Pmst.GrossAmount, 0) AS GrossAmount,
            ISNULL(Pmst.CGSTTotal, 0) AS CGSTTotal,
             ISNULL(Pmst.IGSTTotal, 0) AS IGSTTotal,
            ISNULL(Pmst.SGSTTotal, 0) AS SGSTTotal,
            ISNULL(Pmst.NetAmount, 0) AS NetAmount,
            MEE.Emp_Name,
            Pdtl2.Remark,
            Pdtl2.Weight,
            Pdtl2.TotalWeight,
            Pdtl2.Width,
            Pdtl2.Length_Mtr AS Length_Meter
            

          FROM  PR_DTL Pdtl2

            LEFT JOIN PR_MST Pmst
            ON Pmst.PR_Id = Pdtl2.PR_Id
         
        LEFT JOIN BOM_PO_RequestDtl PRD
            ON Pdtl2.Req_Id = PRD.BOM_PO_ReqDtl_Id

        LEFT JOIN BOM_PO_Request PR
            ON PR.BOM_PO_Req_Id = PRD.BOM_PO_Req_Id


        LEFT JOIN BOM_MST BM
            ON BM.Bom_Id = PR.BOM_Id

        LEFT JOIN M_Project P
            ON P.Project_Id = Pdtl2.Project_Id

        LEFT JOIN M_Department MD
            ON MD.Dept_ID = PR.Dept_ID

        LEFT JOIN M_Employee ME
            ON ME.Emp_Id = PR.Entry_User

        LEFT JOIN MR_Items MRI
            ON MRI.MR_Items_Id = PRD.BOM_Dtl_Id

        LEFT JOIN M_Item I
            ON I.Item_Id = Pdtl2.Item_Id

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

         LEFT JOIN M_Supplier Ms
            ON Ms.Supplier_Id = Pdtl2.Supplier_Id
       
        LEFT JOIN M_SupplierDtl Msd
            ON Msd.Supplier_Id = Ms.Supplier_Id and Msd.Item_Id = Pdtl2.Item_Id

         

         LEFT JOIN M_Godown MG
            ON MG.Godown_Id = Pmst.Godown_Id

         LEFT JOIN M_Master MM
            ON MM.Master_Id = I.Unit_Id

         LEFT JOIN M_Employee MEE
            ON MEE.Emp_Id = Pmst.ReqRaisedBy_Id           

        WHERE
            Pdtl2.Is_Checked = 1 AND
            (
                (@fr_date IS NULL AND @Tr_date IS NULL)
                OR (CONVERT(DATE, Pmst.PO_Date) BETWEEN @fr_date AND @Tr_date)
            )
          AND MIG.Dept_ID = @Dept_ID
        AND Pmst.PO_Type IN ('PP','F','PC') 
        ORDER BY PR.BOM_PO_Req_Id DESC, PRD.BOM_PO_ReqDtl_Id DESC
        FOR JSON PATH, INCLUDE_NULL_VALUES
    ) AS json;

END
END

