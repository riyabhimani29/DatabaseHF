USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_GetDtl_BAR]    Script Date: 27-04-2026 13:12:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


 
ALTER PROCEDURE [dbo].[PO_MST_GetDtl_BAR] 
    @PO_Id       INT = 6030,                      
    @Dept_ID     INT = 0,                        
    @Supplier_Id INT = 0,                                              
    @PO_Type     VARCHAR(1) = '',                                              
    @Order_Type  VARCHAR(100) = ''                                             
AS                                              
BEGIN
    SET NOCOUNT ON;                                              
 
    DECLARE @Is_Close INT = 0;     
    DECLARE @IsExist INT = 0;   -- ?? Variable to check GlassQR existence
 
    /* ? Check if PO + PODtl exists in GlassQR_Dtl */
    IF EXISTS (
        SELECT 1
        FROM PO_DTL PD
        INNER JOIN GlassQR_Dtl GQD 
            ON GQD.PODtl_Id = PD.PODtl_Id
           AND GQD.PO_Id = PD.PO_Id
        WHERE PD.PO_Id = @PO_Id
    )
    BEGIN
        SET @IsExist = 1;
    END
 
 
    /* ------------------------------------------------------------ */                                              
    SELECT 
           ROW_NUMBER() OVER (ORDER BY PO_DTL.PODtl_Id) AS SrNo,                                              
           PO_MST.OrderNo,                                              
           PO_DTL.PODtl_Id,                                             
           PO_DTL.PO_Id,               
           PO_MST.PO_Date,          
           UPPER(M_Supplier.Supplier_Name) AS Supplier_Name,           
           M_Item.Item_Group_Id,                                              
           M_Item_Group.Item_Group_Name,                                              
           M_Item.Item_Cate_Id,                     
           M_Item_Category.Item_Cate_Name,                                              
           PO_DTL.Item_Id,                                              
           UPPER(M_Item.Item_Name) AS Item_Name,                                    
           M_Item.Item_Code,                                  
           M_Item.HSN_Code,                                              
           PO_DTL.SupDetail_Id,                                              
           M_SupplierDtl.SupItem_Code,                                              
           ISNULL(PO_DTL.PendingQty, 0) AS OrderQty,                                              
           0 AS ReceiveQty,  
           PO_DTL.Unit_Id,                                              
           Tbl_Unit.Master_Vals AS Unit,                                              
           PO_DTL.Width Length,                                              
           PO_DTL.Length Weight,                                              
           PO_DTL.TotalWeight,                                              
           PO_DTL.UnitCost,                                
           PO_DTL.UnitCost AS RUnitCost,                                              
           CONVERT(NUMERIC(18,0), PO_DTL.TotalCost) AS TotalCost,                                              
           PO_DTL.Remark,                                              
 
           CASE                                     
             WHEN ISNULL(PO_DTL.PendingQty, 0) <= 0 
             THEN 'Close'                                              
             ELSE 'Open'                                              
           END AS POStatus,                                              
 
           CONVERT(BIT, 0) AS IsSeletd,                                              
           PO_DTL.Project_Id,                                              
           M_Item.ImageName,                                              
           UPPER(M_Project.Project_Name) AS Project_Name,                                        
           PO_DTL.Width,                       
           NULL AS Rack_Id,                    
           PO_DTL.Charg_Height,          
           PO_DTL.Charg_Weight,                
           PO_DTL.Ref_Code,    
 
           /* ?? Row-wise GlassQR match check */
           CASE 
               WHEN EXISTS (
                    SELECT 1 
                    FROM GlassQR_Dtl GQD
                    WHERE GQD.PODtl_Id = PO_DTL.PODtl_Id
                      AND GQD.PO_Id = PO_DTL.PO_Id
               ) 
               THEN 1 
               ELSE 0 
           END AS IsGlassQRExist,
 
           /* QR Code Column */
           UPPER(M_Item.Item_Name) + ',' + 
           M_Item.Item_Code + ',' + 
           CONVERT(VARCHAR(20), ISNULL(PO_DTL.OrderQty, 0)) + ',' +
           CONVERT(VARCHAR(20), ISNULL(PO_DTL.OrderQty, 0)) + ',' + 
           PO_MST.OrderNo + ',' + 
           M_SupplierDtl.SupItem_Code + ',' + 
           CONVERT(VARCHAR(20), PO_DTL.PODtl_Id) + ',' +  
           CONVERT(VARCHAR(20), PO_DTL.Item_Id) + ',' +  
           CONVERT(VARCHAR(20), PO_DTL.PO_Id) AS QRCode    
 
    FROM PO_DTL WITH (NOLOCK)                                 
    LEFT JOIN M_Project WITH (NOLOCK)  
        ON PO_DTL.Project_Id = M_Project.Project_Id            
    LEFT JOIN PO_MST WITH (NOLOCK) 
        ON PO_DTL.PO_Id = PO_MST.PO_Id               
    LEFT JOIN M_Supplier WITH (NOLOCK) 
        ON PO_MST.Supplier_Id = M_Supplier.Supplier_Id           
    LEFT JOIN M_Master AS Tbl_Unit WITH (NOLOCK)   
        ON PO_DTL.Unit_Id = Tbl_Unit.Master_Id                                              
    LEFT JOIN M_SupplierDtl WITH (NOLOCK) 
        ON PO_DTL.SupDetail_Id = M_SupplierDtl.SupDetail_Id                                              
    LEFT JOIN M_Item WITH (NOLOCK) 
        ON PO_DTL.Item_Id = M_Item.Item_Id                                              
    LEFT JOIN M_Item_Group WITH (NOLOCK)   
        ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id                                              
    LEFT JOIN M_Item_Category WITH (NOLOCK)   
        ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
 
    WHERE PO_DTL.PO_Id = 
        CASE 
            WHEN @PO_Id = 0 THEN PO_DTL.PO_Id
            ELSE @PO_Id
        END
 
    ORDER BY PO_MST.PO_Id DESC;
 
 
END

GO


