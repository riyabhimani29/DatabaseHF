USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[InternalStockTrans_Mst_GetList]    Script Date: 27-04-2026 11:50:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[InternalStockTrans_Mst_GetList]       
@SearchParam varchar(150)  = ''        ,
        
         @fr_date date ='2023-02-14',          
         @Tr_date date ='2023-01-14' 
        
AS        
        
SET NOCOUNT ON        
        
        
SELECT  StockTrans_Mst.TransId,        
  StockTrans_Mst.Entry_Date,        
  StockTrans_Mst.FrGodown_Id,        
  M_Godown.Godown_Name,        
  StockTrans_Mst.ToGodown_Id,        
  Tbl_ToGodown.Godown_Name AS ToGodown,        
  StockTrans_Mst.IssueBy,        
  Tbl_Issue.Emp_Name AS IssueName,        
  StockTrans_Mst.ReceiveBy,        
  Tbl_Receive.Emp_Name AS ReceiveName,        
  StockTrans_Mst.ProjectDocument,        
  StockTrans_Mst.ProductionDepartment,        
  StockTrans_Mst.Remark         
 From StockTrans_Mst With (NOLOCK)         
 left join M_Godown  With (NOLOCK)  on StockTrans_Mst.FrGodown_Id = M_Godown.Godown_Id        
 left join M_Godown  as Tbl_ToGodown  With (NOLOCK)  on StockTrans_Mst.ToGodown_Id = Tbl_ToGodown.Godown_Id        
 left join M_Employee as Tbl_Issue  With (NOLOCK)  on StockTrans_Mst.IssueBy = Tbl_Issue.Emp_Id        
 left join M_Employee as Tbl_Receive  With (NOLOCK)  on StockTrans_Mst.ReceiveBy = Tbl_Receive.Emp_Id        
 WHERE StockTrans_Mst.Trans_Type IN ('T_To_H', 'H_To_T');        
        
 SELECT StockTrans_Dtl.Dtl_Id,      
 case when  StockTrans_Mst.Trans_Type = 'T_To_H' then 'TWF To HIFAB'    
 when  StockTrans_Mst.Trans_Type = 'H_To_T' then 'HIFAB To TWF'     
 end AS Trans_Type,    
   StockTrans_Dtl.TransId,     
   StockTrans_Mst.Entry_Date,
    StockTrans_Mst.IssueBy,
   StockTrans_Mst.ReceiveBy,
   --StockTrans_Dtl.Item_Id,        
   M_Item.Item_Name,        
   M_Item.Item_Code,        
   M_Item.HSN_Code,
   M_Item.Weight_Mtr,
  -- M_Item.Item_Cate_Id,        
   M_Item_Category.Item_Cate_Name,        
  -- M_Item.Item_Group_Id,        
   M_Item_Group.Item_Group_Name,        
  -- StockTrans_Dtl.Stock_Id,        
   StockTrans_Dtl.Qty,        
   StockTrans_Dtl.Remark,
   StockTrans_Dtl.FrRack_Id,
   StockTrans_Dtl.ToRack_Id,
   StockTrans_Dtl.Fr_Godown_Id,
   StockTrans_Dtl.To_Godown_Id,
   M_Godown_Rack.Rack_Name From_Rack,      
  ISNULL( Tbl_ToRack.Rack_Name,'-')  AS To_Rack,      
   StockView.Length  ,    
   StockTrans_Dtl.SplitLength ,    
    M_Godown.Godown_Name,    
  ISNULL(Tbl_ToGodown.Godown_Name,'-')  AS ToGodown,    
     
 ISNULL( StockTrans_Mst.ProjectDocument,'-') AS ProjectDocument,        
  StockTrans_Mst.ProductionDepartment,    
 ISNULL(  Tbl_Issue.Emp_Name,'-') AS IssueName,     
  ISNULL( Tbl_Receive.Emp_Name,'-')  AS ReceiveName   ,
   CONVERT(DATE, StockTrans_Mst.Entry_Date )
 From StockTrans_Dtl With (NOLOCK)        
 left join StockTrans_Mst  With (NOLOCK)  on StockTrans_Dtl.TransId = StockTrans_Mst.TransId          
 left join M_Employee as Tbl_Issue  With (NOLOCK)  on StockTrans_Mst.IssueBy = Tbl_Issue.Emp_Id        
 left join M_Employee as Tbl_Receive  With (NOLOCK)  on StockTrans_Mst.ReceiveBy = Tbl_Receive.Emp_Id         
 left join M_Godown  With (NOLOCK)  on StockTrans_Dtl.Fr_Godown_Id = M_Godown.Godown_Id        
 left join M_Godown  as Tbl_ToGodown  With (NOLOCK)  on StockTrans_Dtl.To_Godown_Id = Tbl_ToGodown.Godown_Id         
       
 left join StockView  With (NOLOCK)  on StockTrans_Dtl.Stock_Id = StockView.Id      
 left join M_Godown_Rack  With (NOLOCK)  on StockTrans_Dtl.FrRack_Id = M_Godown_Rack.Rack_Id        
 left join M_Godown_Rack AS Tbl_ToRack  With (NOLOCK)  on StockTrans_Dtl.ToRack_Id = Tbl_ToRack.Rack_Id        
      
 left join M_Item  With (NOLOCK)  on StockTrans_Dtl.Item_Id = M_Item.Item_Id        
 left join M_Item_Category  With (NOLOCK)  on M_Item_Category.Item_Cate_Id = M_Item.Item_Cate_Id        
 left join M_Item_Group  With (NOLOCK)  on M_Item_Group.Item_Group_Id= M_Item.Item_Group_Id
 where  CONVERT(DATE, StockTrans_Mst.Entry_Date ) BETWEEN CONVERT(DATE, @fr_date) AND CONVERT(DATE, @Tr_date) 
 and (@SearchParam = '' OR StockTrans_Mst.Trans_Type = @SearchParam)
 AND StockTrans_Mst.Trans_Type IN ('T_To_H', 'H_To_T')
 order  by StockTrans_Dtl.Dtl_Id desc 
;
GO


