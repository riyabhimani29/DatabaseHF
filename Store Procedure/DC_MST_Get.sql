USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DC_MST_Get]    Script Date: 27-04-2026 11:21:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                  
ALTER PROCEDURE [dbo].[DC_MST_Get]                  
@DC_Id int  =0                  
                  
AS                  
                  
SET NOCOUNT ON                  
                  
             
SELECT  DC_Mst.DC_Id,  
  DC_Mst.DC_Type,  
  DC_Mst.Invoice_No,  
  DC_Mst.DC_No,  
  DC_Mst.DC_Date,  
  DC_Mst.SiteEnginner_Id,  
  Tbl_SiteEnginner.Emp_Name as SiteEnginner,    
  DC_Mst.FrGodown_Id,       
  Tbl_FromGodown.Godown_Name AS FrGodown ,       
  DC_Mst.Godown_Id,       
  M_Godown.Godown_Name,       
  DC_Mst.QuotationNo,  
  DC_Mst.ProjectDocument,  
  DC_Mst.TransportType,  
  DC_Mst.Vehicle_No,  
  DC_Mst.Driver_Name,  
  DC_Mst.Contact_of_Driver,  
  DC_Mst.ChallanType,  
  DC_Mst.GrossAmount,  
  DC_Mst.CGST,  
  Tbl_CGST.Master_Vals AS CGSTPer,  
  DC_Mst.SGST,  
  Tbl_SGST.Master_Vals AS SGSTPer,  
  DC_Mst.IGST,  
  Tbl_IGST.Master_Vals AS IGSTPer,  
  DC_Mst.CGSTTotal,  
  DC_Mst.SGSTTotal,  
  DC_Mst.IGSTTotal,  
  DC_Mst.NetAmount,  
  DC_Mst.Remark ,  
  '' AS DCStatus  
 From DC_Mst With (NOLOCK)   
  left join M_Master AS Tbl_CGST  With (NOLOCK)  On DC_Mst.CGST  = Tbl_CGST.Master_Id   
  left join M_Master AS Tbl_SGST  With (NOLOCK)  On DC_Mst.SGST  = Tbl_SGST.Master_Id   
  left join M_Master AS Tbl_IGST  With (NOLOCK)  On DC_Mst.IGST  = Tbl_IGST.Master_Id   
  left join M_Employee AS Tbl_SiteEnginner  With (NOLOCK)  On DC_Mst.SiteEnginner_Id  = Tbl_SiteEnginner.Emp_Id    
  left join M_Godown With (NOLOCK)  On DC_Mst.FrGodown_Id  = M_Godown.Godown_Id      
  left join M_Godown AS Tbl_FromGodown With (NOLOCK)  On DC_Mst.Godown_Id  = Tbl_FromGodown.Godown_Id    
 Where DC_Mst.DC_Type = 'DC'     
  
  
 SELECT  ROW_NUMBER() OVER( ORDER BY DC_Dtl.DCDtl_Id) AS SrNo,   
  DC_Dtl.DCDtl_Id,  
  DC_Dtl.DC_Id,  
  DC_Dtl.Dept_ID,  
  M_Department.Dept_Name,  
  DC_Dtl.Item_Group_Id,      
  M_Item_Group.Item_Group_Name,    
  DC_Dtl.Item_Cate_Id,    
  M_Item_Category.Item_Cate_Name,    
  DC_Dtl.Item_Id,            
  M_Item.Item_Name,                
  M_Item.HSN_Code,     
  DC_Dtl.Qty,  
  DC_Dtl.Unit_Id,  
  tbl_Unit.Master_Vals AS Unit,  
  DC_Dtl.ItemLength,  
  DC_Dtl.Rate,  
  DC_Dtl.TotalValue,  
  DC_Dtl.Remark,  
  '' AS DCStatus  
 From DC_Dtl With (NOLOCK)   
 left join M_Master AS tbl_Unit  With (NOLOCK) on DC_Dtl.Unit_Id = tbl_Unit.Master_Id  
 left join M_Department  With (NOLOCK) on DC_Dtl.Dept_ID = M_Department.Dept_ID  
 left join DC_Mst  With (NOLOCK) on DC_Dtl.DC_Id = DC_Mst.DC_Id  
               
 left join M_Item  with (nolock) On DC_Dtl.Item_Id =   M_Item.Item_Id    
 left join M_Item_Group  with (nolock) On M_Item.Item_Group_Id =   M_Item_Group.Item_Group_Id                
 left join M_Item_Category  with (nolock) On M_Item.Item_Cate_Id =   M_Item_Category.Item_Cate_Id  
  Where DC_Mst.DC_Type = 'DC' 
GO


