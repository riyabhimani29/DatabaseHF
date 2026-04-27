USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_GetList]    Script Date: 27-04-2026 13:14:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                
ALTER PROCEDURE [dbo].[PO_MST_GetList]                
@SearchParam varchar(50)  =''  
                
AS                
                
SET NOCOUNT ON                
                
                
SELECT  PO_MST.PO_Id,                
  PO_MST.PO_Type,                
  Order_Type,                
  PO_MST.Dept_ID,                
  M_Department.Dept_Name,                
  PO_MST.Invoice_No,                
  PO_MST.OrderNo,                
  PO_MST.PO_Date,                
  PO_MST.ReqRaisedBy_Id,                
  Tbl_ReqRaisedBy.Emp_Name as ReqRaisedBy,                
  PO_MST.BillingAddress,                
  PO_MST.Supplier_Id,                
  M_Supplier.Supplier_Name,          
  M_Supplier.Address as SupplierAddress,        
  M_Supplier.GST_No as SupplierGSTNO ,         
  PO_MST.Godown_Id,            
  M_Godown.Godown_Name,            
  M_Godown.Godown_Address AS ShippingAddress,        
  PO_MST.GrossAmount,                
  PO_MST.AdvanceAmount,                
  PO_MST.NetAmount,                
  PO_MST.PaymentTerms,                
  PO_MST.DeliveryTerms,                
  PO_MST.AdditionalTerms,                
  PO_MST.AuthorisePerson_Id,                
  Tbl_AuthorisePerson.Emp_Name AS AuthorisePerson,                
  PO_MST.ApproveDate,                
  PO_MST.Remark,          
  case when   Tbl.PendingQty <= 0 then 'Close' else 'Open' end  AS POStatus          
 From PO_MST With (NOLOCK)              
 outer Apply (          
 select SUM(ISNULL(PO_DTL.OrderQty,0))as OrderQty,SUM(ISNULL(PO_DTL.PendingQty,0)) AS PendingQty from  PO_DTL With (NOLOCK) where PO_DTL.PO_Id = PO_MST.PO_Id          
 ) AS Tbl          
 left join M_Godown With (NOLOCK)  On PO_MST.Godown_Id  = M_Godown.Godown_Id                
 left join M_Department  With (NOLOCK)  On PO_MST.Dept_ID  = M_Department.Dept_ID                
 left join M_Employee AS Tbl_ReqRaisedBy  With (NOLOCK)  On PO_MST.ReqRaisedBy_Id  = Tbl_ReqRaisedBy.Emp_Id                
 left join M_Employee AS Tbl_AuthorisePerson  With (NOLOCK)  On PO_MST.AuthorisePerson_Id  = Tbl_AuthorisePerson.Emp_Id                
 left join M_Supplier   With (NOLOCK)  On PO_MST.Supplier_Id  = M_Supplier.Supplier_Id                
 Where Order_Type = 'PO'                
             
GO


