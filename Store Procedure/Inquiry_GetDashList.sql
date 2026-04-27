USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_GetDashList]    Script Date: 27-04-2026 11:47:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                            
ALTER    PROCEDURE [dbo].[Inquiry_GetDashList]                                                                              
@FDate Date  = ''   ,                  
@TDate Date  = ''  ,                  
@Inquiry_Status varchar(500)  = ''   
                                                            
AS                                                            
                                                            
SET NOCOUNT ON  

       SELECT Inquiry.Inquiry_Id,
       --M_Project.Entry_Date as Project_Created_Date,
       Inquiry.BranchMaster_Id,
       Inquiry.Stage,
       Inquiry.Inquiry_No,
       Inquiry.Inquiry_Date,
       M_Master.Master_Vals             as BranchMaster,
       Inquiry.Project_Name,
       Inquiry.Project_Reference,
       Inquiry.Project_Address,
       Inquiry.Country_Id,
       Inquiry.State_Id,
       Inquiry.City_Id,
       TblInquiry_Country.Master_Vals   AS Country_Nm,
       TblInquiry_State.Master_Vals     AS State_Nm,
       TblInquiry_City.Master_Vals      AS City_Nm,
       Inquiry.InquirySource_Id,
       Inquiry.InquiryType_Id,
       Inquiry.Architect_Dtl_Id,
       TblInquiry_Source.Master_Vals    AS Source_Nm,
       TblInquiry_Type.Master_Vals      AS Type_Nm,
       TblInquiry_ArcDtl.Master_Vals    AS ArcDtl_Nm,
       Inquiry.Cust_Id,
       M_Customer.Cust_Name,
       Inquiry.Project_Incharge_Id,
       M_Employee.Emp_Name              AS Project_Incharge,
       Inquiry.Site_Engineer_Id,
       TblSite_Engineer.Emp_Name        as Site_Engineer,
       Isnull(Inquiry.Aprox_QTN_Val, 0) AS Aprox_QTN_Val,
       Inquiry.Contact_Person,
       Inquiry.Contact_No,
       Inquiry.Inquiry_StatusId,
       TblInquiry_Status.Master_Vals    as Inquiry_Status,
       Inquiry.Reference,
       Inquiry.Attachments_Name,
       Inquiry.Remark,
       Inquiry.Project_Id,
       case
         when Inquiry.Upd_Date = '1900-01-01 00:00:00.000' then
         Inquiry.Entry_Date
         else Inquiry.Upd_Date
       end                              AS Upd_Date,
       ''                               as tr_Remark,
       '1900-01-01'                     as tr_Date
FROM   dbo.Inquiry WITH(nolock)
       left join M_Customer WITH(nolock) On Inquiry.Cust_Id = M_Customer.Cust_Id
       left join M_Master WITH(nolock) On Inquiry.BranchMaster_Id = M_Master.Master_Id
       left join M_Master AS TblInquiry_Status WITH(nolock) On Inquiry.Inquiry_StatusId = TblInquiry_Status.Master_Id
       left join M_Employee WITH(nolock) On Inquiry.Project_Incharge_Id = M_Employee.Emp_Id
       left join M_Employee AS TblSite_Engineer WITH(nolock) On Inquiry.Site_Engineer_Id = TblSite_Engineer.Emp_Id
       left join M_Master AS TblInquiry_Country WITH(nolock) On Inquiry.Country_Id = TblInquiry_Country.Master_Id
       left join M_Master AS TblInquiry_State WITH(nolock) On Inquiry.State_Id = TblInquiry_State.Master_Id
       left join M_Master AS TblInquiry_City WITH(nolock) On Inquiry.City_Id = TblInquiry_City.Master_Id
       left join M_Master AS TblInquiry_Source WITH(nolock) On Inquiry.InquirySource_Id = TblInquiry_Source.Master_Id
       left join M_Master AS TblInquiry_Type WITH(nolock) On Inquiry.InquiryType_Id = TblInquiry_Type.Master_Id
       left join M_Master AS TblInquiry_ArcDtl WITH(nolock) On Inquiry.Architect_Dtl_Id = TblInquiry_ArcDtl.Master_Id
where  convert(DATE, dbo.Inquiry.Inquiry_Date) Between @FDate AND @TDate
       and TblInquiry_Status.Master_Vals = CASE WHEN @Inquiry_Status = '' then TblInquiry_Status.Master_Vals
       else @Inquiry_Status end
order  by Inquiry.Inquiry_Id desc 

if @Inquiry_Status = ''
BEGIN
SELECT
    M_Project.Project_Id,
    M_Project.Project_Name,
    M_Project.Entry_Date,
    M_Project.Entry_User,
    M_Employee.Emp_Name as Entry_User_Name,
    Inquiry.Stage,
    TblInquiry_Type.Master_Vals AS Type_Nm,
    TblInquiry_Status.Master_Vals as Inquiry_Status
FROM
    M_Project
    join Inquiry on M_Project.Inquiry_Id = Inquiry.Inquiry_Id
    left join M_Master AS TblInquiry_Type WITH(nolock) On Inquiry.InquiryType_Id = TblInquiry_Type.Master_Id
    left join M_Master AS TblInquiry_Status WITH(nolock) On Inquiry.Inquiry_StatusId = TblInquiry_Status.Master_Id
    left join M_Employee WITH(nolock) On M_Project.Entry_User = M_Employee.Emp_Id WHERE
    convert(DATE, dbo.M_Project.Entry_Date) Between @FDate AND @TDate
END
GO


