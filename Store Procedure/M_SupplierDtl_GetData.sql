USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_SupplierDtl_GetData]    Script Date: 27-04-2026 12:48:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_SupplierDtl_GetData] 
@Supplier_Id int =0

AS 
SET
   NOCOUNT 
   ON 
    

	SELECT 
	 0 AS SrNo, 
	 M_SupplierDtl.SupDetail_Id,
		M_SupplierDtl.Supplier_Id,
		M_SupplierDtl.SupItem_Code,
	 
		M_Item.Item_Code AS HiFab_Code ,
		M_Item.Item_Name AS [Description],
		M_SupplierDtl.Item_Id, 
		M_SupplierDtl.Is_Active,
		M_SupplierDtl.ItemRemark  

 From M_SupplierDtl With (NOLOCK)
 left join M_Item  With (NOLOCK) ON  M_Item.Item_Id  = M_SupplierDtl.Item_Id
 where M_SupplierDtl.Supplier_Id = @Supplier_Id
GO


