USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_GetHistoryList]    Script Date: 27-04-2026 11:48:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                      
ALTER    PROCEDURE [dbo].[Inquiry_GetHistoryList]                                                      
@Inquiry_Id int  = 0  
                                                      
AS                                                      
                                                      
SET NOCOUNT ON                     
                  
  SELECT tr_Tbl_Inquiry.Inquiry_Id,                
		
    tr_Tbl_Inquiry.Inquiry_No,              
    tr_Tbl_Inquiry.Inquiry_Date,              
   M_Master.Master_Vals as BranchMaster,                
       tr_Tbl_Inquiry.Project_Name,             
   tr_Tbl_Inquiry.Project_Reference,          
    tr_Tbl_Inquiry.Project_Address,                
              
  TblInquiry_Country.Master_Vals  AS Country_Nm,               
  TblInquiry_State.Master_Vals AS State_Nm ,               
  TblInquiry_City.Master_Vals AS City_Nm ,               
               
  --  tr_Tbl_Inquiry.InquirySource_Id ,              
   -- tr_Tbl_Inquiry.InquiryType_Id ,              
  --  tr_Tbl_Inquiry.Architect_Dtl_Id ,             
 TblInquiry_Source.Master_Vals AS Source_Nm ,               
 TblInquiry_Type.Master_Vals AS Type_Nm ,               
 TblInquiry_ArcDtl.Master_Vals AS ArcDtl_Nm ,               
-- tr_Tbl_Inquiry.Cust_Id,          
 M_Customer.Cust_Name,          
          
      -- tr_Tbl_Inquiry.Project_Incharge_Id,                
  M_Employee.Emp_Name  AS Project_Incharge ,                 
      -- tr_Tbl_Inquiry.Site_Engineer_Id,                
  TblSite_Engineer.Emp_Name as Site_Engineer,                
       isnull(tr_Tbl_Inquiry.Aprox_QTN_Val,0) AS Aprox_QTN_Val ,          
       tr_Tbl_Inquiry.Contact_Person,                
       tr_Tbl_Inquiry.Contact_No,                
     --  tr_Tbl_Inquiry.Inquiry_StatusId,                
    TblInquiry_Status.Master_Vals as Inquiry_Status,                
       tr_Tbl_Inquiry.Reference,                
       tr_Tbl_Inquiry.Attachments_Name,                
       tr_Tbl_Inquiry.Remark   ,
	   tr_Tbl_Inquiry.tr_Remark,
	   tr_Tbl_Inquiry.tr_Date
  FROM dbo.tr_Tbl_Inquiry  WITH(NOLOCK)                
  left join M_Customer  WITH(NOLOCK) On tr_Tbl_Inquiry.Cust_Id = M_Customer.Cust_Id              
  left join M_Master  WITH(NOLOCK) On tr_Tbl_Inquiry.BranchMaster_Id = M_Master.Master_Id                
  left join M_Master AS TblInquiry_Status  WITH(NOLOCK) On tr_Tbl_Inquiry.Inquiry_StatusId = TblInquiry_Status.Master_Id                 
  left join M_Employee  WITH(NOLOCK) On tr_Tbl_Inquiry.Project_Incharge_Id = M_Employee.Emp_Id                
  left join M_Employee AS TblSite_Engineer WITH(NOLOCK) On tr_Tbl_Inquiry.Site_Engineer_Id = TblSite_Engineer.Emp_Id                
               
  left join M_Master AS TblInquiry_Country  WITH(NOLOCK) On tr_Tbl_Inquiry.Country_Id = TblInquiry_Country.Master_Id                  
  left join M_Master AS TblInquiry_State  WITH(NOLOCK) On tr_Tbl_Inquiry.State_Id = TblInquiry_State.Master_Id                  
  left join M_Master AS TblInquiry_City  WITH(NOLOCK) On tr_Tbl_Inquiry.City_Id = TblInquiry_City.Master_Id                
             
  left join M_Master AS TblInquiry_Source  WITH(NOLOCK) On tr_Tbl_Inquiry.InquirySource_Id = TblInquiry_Source.Master_Id                  
  left join M_Master AS TblInquiry_Type  WITH(NOLOCK) On tr_Tbl_Inquiry.InquiryType_Id = TblInquiry_Type.Master_Id                  
  left join M_Master AS TblInquiry_ArcDtl  WITH(NOLOCK) On tr_Tbl_Inquiry.Architect_Dtl_Id = TblInquiry_ArcDtl.Master_Id                
        
  where tr_Tbl_Inquiry.tr_Inquiry_Id = @Inquiry_Id

order by tr_Tbl_Inquiry.Inquiry_Id desc 
GO


