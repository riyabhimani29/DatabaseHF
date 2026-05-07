USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Glass_PO_MST_Get]    Script Date: 27-04-2026 11:33:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Glass_PO_MST_Get] 
    @PO_Id       INT = 0,                
    @Dept_ID     INT = 0,                  
    @Supplier_Id INT = 0,                                        
    @PO_Type     VARCHAR(1) = 'F',          
    @fr_date     DATE ='2022-04-22',          
    @Tr_date     DATE ='2022-06-22'                                      
AS                                        
BEGIN
    SET NOCOUNT ON;

    /* ============================================================
       MASTER DATA (ONLY PO PRESENT IN GlassQR_Dtl)
    ============================================================ */

    
        SELECT PO_MST.PO_Id,
               PO_MST.PO_Type,
               PO_MST.Order_Type,
               PO_MST.OrderNo,
               PO_MST.PO_Date,
               PO_MST.Supplier_Id,
               M_Supplier.Supplier_Name,
               PO_MST.Godown_Id,
               M_Godown.Godown_Name,
               PO_MST.ReqRaisedBy_Id,
               M_Employee.Emp_Name AS ReqRaisedBy,
               PO_Mst.Admin_Charges,
               PO_MST.Insurance,
               PO_MST.Other_Charges,
               PO_MST.Revision,
               PO_MST.NetAmount,
               PO_MST.Remark,
               Doc_Img_Name,
               CASE
                WHEN EXISTS (
                SELECT 1
                FROM GlassQR_Dtl G
                WHERE G.PO_Id = PO_MST.PO_Id
                AND G.Is_Out = 0
            ) THEN 'Open'

            ELSE 'Close'           END             AS POStatus

               -- ? PO Status from GRN_Mst
               --CASE 
                   --WHEN EXISTS (
                       -- SELECT 1 
                       -- FROM GRN_Mst g WITH (NOLOCK)
                       -- WHERE g.PO_Id = PO_MST.PO_Id
                       -- AND g.GRN_Type = 'GRN-OUT'
                   --)
                  -- THEN 'Close'
                  -- ELSE 'Open'
               --END AS POStatus

        FROM PO_MST WITH (NOLOCK)

        -- ?? IMPORTANT FILTER
        INNER JOIN (
            SELECT DISTINCT PO_Id 
            FROM GlassQR_Dtl WITH (NOLOCK)
        ) G ON G.PO_Id = PO_MST.PO_Id

        LEFT JOIN M_Supplier WITH (NOLOCK) 
            ON PO_MST.Supplier_Id = M_Supplier.Supplier_Id
        LEFT JOIN M_Godown WITH (NOLOCK)
            ON PO_MST.Godown_Id = M_Godown.Godown_Id
        LEFT JOIN M_Employee WITH (NOLOCK)
            ON PO_MST.ReqRaisedBy_Id = M_Employee.Emp_Id
 OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0))   AS OrderQty,                                 
								Sum( case when  Isnull(PO_DTL.pendingqty, 0) > 0 then Isnull(PO_DTL.pendingqty, 0) else 0 end  ) AS PendingQty                                        
                               /*Sum(Isnull(PO_DTL.pendingqty, 0)) AS PendingQty        */                                
                        FROM   PO_DTL WITH (nolock)                                        
                        WHERE  PO_DTL.PO_Id = PO_MST.PO_Id) AS Tbl

        --WHERE PO_MST.PO_Type <> 'X'
            WHERE  PO_MST.PO_Type <> 'X'    
	 and CONVERT(DATE, dbo.PO_MST.PO_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)  
    ORDER BY PO_Id DESC


    /* ============================================================
       DETAIL DATA (ONLY PODtl PRESENT IN GlassQR_Dtl)
    ============================================================ */

    SELECT 
           ROW_NUMBER() OVER (ORDER BY PO_DTL.PODtl_Id) AS SrNo,
           PO_DTL.PODtl_Id,
           PO_DTL.PO_Id,
           PO_MST.OrderNo,
           PO_MST.PO_Date,
           PO_MST.Supplier_Id AS SupDetail_Id,
           --M_Supplier.Supplier_Name,
           PO_DTL.Item_Id,
           M_Item.Item_Name,
           M_Item.Item_Code,
           M_Item.Item_Group_Id,
           M_Item_Group.Item_Group_Name ,
           M_Item.Item_Cate_Id,
           M_Item_Category.Item_Cate_Name,
           M_Item.ImageName,
           PO_DTL.OrderQty,
            CASE 
    WHEN (ISNULL(PO_DTL.OrderQty, 0) - ISNULL(tbl_RecQty.GrnRecQty,0)) < 0 
        THEN 0
    ELSE 
        (ISNULL(PO_DTL.OrderQty, 0) - ISNULL(tbl_RecQty.GrnRecQty,0))
    END AS PendingQty,
           PO_DTL.Charg_Weight,
           PO_DTL.Charg_Height,
           PO_DTL.UnitCost,
           PO_DTL.TotalCost,
           PO_DTL.Length,
           PO_DTL.Width,
           PO_DTL.Weight,
           PO_DTL.TotalWeight,
           PO_DTL.Project_Id,
           PO_DTL.Remark,
           PO_DTL.Ref_Code,
           M_Project.Project_Name,
           CASE 
            WHEN G.Is_Out = 1  THEN 'Close'
            ELSE 'Open'
            END AS POStatus                             
           -- Same Status Logic
          -- CASE 
               --WHEN EXISTS (
                    --SELECT 1 
                   -- FROM GRN_Mst g WITH (NOLOCK)
                    --WHERE g.PO_Id = PO_DTL.PO_Id
                    --AND g.GRN_Type = 'GRN-OUT'
               --)
               --THEN 'Close'
               --ELSE 'Open'
           --END AS POStatus

    FROM PO_DTL WITH (NOLOCK)
     OUTER apply (select isnull(sum(GRN_Dtl.ReceiveQty),0) AS GrnRecQty from GRN_Dtl        
       left join GRN_Mst on GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id and  GRN_Mst.GRN_Type = 'GRN-OUT'        
       where GRN_Mst.PO_Id = PO_DTL.PO_Id          
       and  PO_DTL.PODtl_Id = GRN_Dtl.PODtl_Id        
       and  GRN_Mst.GRN_Type = 'GRN-OUT') AS tbl_RecQty  
    INNER JOIN PO_MST WITH (NOLOCK)
        ON PO_DTL.PO_Id = PO_MST.PO_Id

    -- IMPORTANT FILTER
    INNER JOIN GlassQR_Dtl G WITH (NOLOCK)
        ON G.PO_Id = PO_DTL.PO_Id
        AND G.PODtl_Id = PO_DTL.PODtl_Id

    LEFT JOIN M_Item WITH (NOLOCK)
        ON PO_DTL.Item_Id = M_Item.Item_Id
    LEFT JOIN M_Item_Category WITH (NOLOCK)
        ON M_Item_Category.Item_Cate_Id = M_Item.Item_Cate_Id
    LEFT JOIN M_Item_Group WITH (NOLOCK)
        ON M_Item_Group.Item_Group_Id = M_Item.Item_Group_Id
    LEFT JOIN M_Supplier WITH (NOLOCK)
        ON PO_MST.Supplier_Id = M_Supplier.Supplier_Id
    LEFT JOIN M_Project WITH (NOLOCK)
        ON PO_DTL.Project_Id = M_Project.Project_Id

   -- WHERE PO_MST.PO_Type <> 'X'
       WHERE  PO_MST.PO_Type <> 'X'    
	 and CONVERT(DATE, dbo.PO_MST.PO_Date) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date)  
    ORDER BY PO_DTL.PODtl_Id;

END

