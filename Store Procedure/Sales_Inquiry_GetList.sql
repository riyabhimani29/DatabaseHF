USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Inquiry_GetList]    Script Date: 27-04-2026 14:44:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                          
ALTER    PROCEDURE [dbo].[Sales_Inquiry_GetList]                                                          
@Inquiry_Id int  = 0   ,                  
@FDate Date  = ''   ,                
@TDate Date  = '',                
@Type_Ids varchar(500)  = ''   ,            
@Source_Ids varchar(500)   = ''   ,            
@Architect_Ids varchar(500)   = ''  ,            
@Customer_Ids varchar(500)   = ''   ,            
@Branch_Ids varchar(500)   = ''      ,            
@From_Values int   = 0     ,            
@To_Values int  = 0     ,    
               
@FupDate Date  = ''   ,                
@TupDate Date  = ''        
                                                          
AS                                                          
                                                          
SET NOCOUNT ON                         
         
  SELECT Inquiry.Inquiry_Id,                    
       Inquiry.BranchMaster_Id,                    
    Inquiry.Inquiry_No,                  
    Inquiry.Inquiry_Date,                  
   M_Master.Master_Vals as BranchMaster,                    
       Inquiry.Project_Name,                 
   Inquiry.Project_Reference,              
    Inquiry.Project_Address,                                 
                   
    Inquiry.InquirySource_Id ,                  
    Inquiry.InquiryType_Id ,                  
    Inquiry.Architect_Dtl_Id ,        
    TblInquiry_ArcDtl.Master_Vals AS Architect_Firm,
 TblInquiry_Source.Master_Vals AS Source_Nm ,                   
 TblInquiry_Type.Master_Vals AS Type_Nm ,                   
 TblInquiry_ArcDtl.Master_Vals AS ArcDtl_Nm ,                   
 Inquiry.Cust_Id,              
 M_Customer.Cust_Name,              
              Inquiry.Inquiry_For,
       Inquiry.Project_Incharge_Id,                    
  M_Employee.Emp_Name  AS Project_Incharge ,                     
       Inquiry.Site_Engineer_Id,                   
     
     Inquiry.WindowSystem,
       Inquiry.Coating,
       Inquiry.Stage,
       Inquiry.Color,
       Inquiry.GlassType,
       Inquiry.Project_Id,
       Inquiry.FlyMesh,
       Inquiry.[System],
       Inquiry.Site_Id,
       Inquiry_Sites.SiteName AS Site_Name,
       Inquiry.Architect_Contact_Id,
       Inquiry.Site_Contact_Id,
              Entry_By.Emp_Name as Entry_By_Name,
       Inquiry_Contacts.ContactName as Site_Contact_Name,
              Inquiry_Contacts.ContactMail as Site_Contact_Mail,
  TblSite_Engineer.Emp_Name as Site_Engineer,                    
       isnull(Inquiry.Aprox_QTN_Val,0) AS Aprox_QTN_Val ,              
       Inquiry.Contact_Person,                    
       Inquiry.Contact_No,                    
       Inquiry.Inquiry_StatusId,                    
    TblInquiry_Status.Master_Vals as Inquiry_Status,                    
       Inquiry.Reference,                    
       Inquiry.Attachments_Name,         
       (SELECT 
       Sales_Inquiry_Visit_Dtl.Id,
       Sales_Inquiry_Visit_Dtl.Documentation,
       Sales_Inquiry_Visit_Dtl.Enter_By,
       M_Employee.Emp_Name as Enter_By_Name,
       Sales_Inquiry_Visit_Dtl.Inquiry_Id,
       Sales_Inquiry_Visit_Dtl.Architect_Id,
       Sales_Inquiry_Visit_Dtl.Purpose_Of_Visit,
       Sales_Inquiry_Visit_Dtl.ShowRoom_Visit,
       Sales_Inquiry_Visit_Dtl.Visitor_Date,
       Sales_Inquiry_Visit_Dtl.Visitor_Id,
       Sales_Inquiry_Visit_Dtl.Remark
       --Visitors.VisitorsName Visitor_Name
       FROM Sales_Inquiry_Visit_Dtl 
       --left outer join Visitors on Visitors.VisitorsId = Sales_Inquiry_Visit_Dtl.Visitor_Id
       left outer join M_Employee ON Sales_Inquiry_Visit_Dtl.Enter_By = M_Employee.Emp_Id
       WHERE Sales_Inquiry_Visit_Dtl.Inquiry_Id = Inquiry.Inquiry_Id FOR JSON PATH) as Inquiry_visit, 
	   (select 
	   Sales_Inquiry_FollowUps.Id,
	   Sales_Inquiry_FollowUps.FollowUp_By,
	   M_Employee.Emp_Name as FollowUp_By_Name,
	   Sales_Inquiry_FollowUps.FollowUp_Type,
	   M_Master.Master_Vals as FollowUp_Type_Name,
	   Sales_Inquiry_FollowUps.FollowUp_Status_Date,
	   Sales_Inquiry_FollowUps.FollowUp_Status,
	   Sales_Inquiry_FollowUps.Description,
	   Sales_Inquiry_FollowUps.Inquiry_Id,
	   Sales_Inquiry_FollowUps.Contact_Person,
	   Visitors.VisitorsName as Contact_Person_Name
	   from Sales_Inquiry_FollowUps 
	   join M_Master on Sales_Inquiry_FollowUps.FollowUp_Type = M_Master.Master_Id
	   join M_Employee on Sales_Inquiry_FollowUps.FollowUp_By = M_Employee.Emp_Id
	   join Visitors on Sales_Inquiry_FollowUps.Contact_Person = Visitors.VisitorsId
	   WHERE Sales_Inquiry_FollowUps.Inquiry_Id = Inquiry.Inquiry_Id FOR JSON PATH) as FollowUps,
Inquiry.Remark      ,        
    Inquiry.Project_Id  ,    
 case when Inquiry.Upd_Date = '1900-01-01 00:00:00.000' then Inquiry.Entry_Date else Inquiry.Upd_Date end AS Upd_Date  ,
 '' as tr_Remark,
 '1900-01-01' as tr_Date


  FROM dbo.Inquiry  WITH(NOLOCK)                    
  left join M_Customer  WITH(NOLOCK) On Inquiry.Cust_Id = M_Customer.Cust_Id                  
  left join M_Master  WITH(NOLOCK) On Inquiry.BranchMaster_Id = M_Master.Master_Id                    
  left join M_Master AS TblInquiry_Status  WITH(NOLOCK) On Inquiry.Inquiry_StatusId = TblInquiry_Status.Master_Id                     
  left join M_Employee  WITH(NOLOCK) On Inquiry.Project_Incharge_Id = M_Employee.Emp_Id                    
  left join M_Employee AS TblSite_Engineer WITH(NOLOCK) On Inquiry.Site_Engineer_Id = TblSite_Engineer.Emp_Id  
                      
     left join M_Employee AS Entry_By WITH(NOLOCK) On Inquiry.Entry_User = Entry_By.Emp_Id     
  left join Inquiry_Sites on Inquiry.Site_Id = Inquiry_Sites.SiteId
  left join Inquiry_Contacts on Inquiry.Site_Contact_Id = Inquiry_Contacts.ContactId                       
  left join M_Master AS TblInquiry_Source  WITH(NOLOCK) On Inquiry.InquirySource_Id = TblInquiry_Source.Master_Id             
  left join M_Master AS TblInquiry_Type  WITH(NOLOCK) On Inquiry.InquiryType_Id = TblInquiry_Type.Master_Id                      
  left join M_Master AS TblInquiry_ArcDtl  WITH(NOLOCK) On Inquiry.Architect_Dtl_Id = TblInquiry_ArcDtl.Master_Id                    

WHERE 
  (
    (@FDate != '' AND @TDate != ''
      AND TRY_CONVERT(DATETIME, @FDate) IS NOT NULL
      AND TRY_CONVERT(DATETIME, @TDate) IS NOT NULL
      AND CONVERT(DATE, dbo.Inquiry.Inquiry_Date) BETWEEN @FDate AND @TDate
    )
    OR (@FDate = '' AND @TDate = '')
  )
  AND 
  (
    (@FupDate != '' AND @TupDate != ''
      AND TRY_CONVERT(DATETIME, @FupDate) IS NOT NULL
      AND TRY_CONVERT(DATETIME, @TupDate) IS NOT NULL
      AND CONVERT(DATE, 
        CASE 
          WHEN Inquiry.Upd_Date IS NULL OR Inquiry.Upd_Date < '1753-01-01' 
            THEN Inquiry.Entry_Date 
          WHEN Inquiry.Upd_Date = '1900-01-01 00:00:00.000' 
            THEN Inquiry.Entry_Date 
          ELSE Inquiry.Upd_Date 
        END
      ) BETWEEN @FupDate AND @TupDate
    )
    OR (@FupDate = '' AND @TupDate = '')
  )

   AND ( ( @Type_Ids = '' )                                      
                OR ( @Type_Ids <> ''                                      
                       AND dbo.Inquiry.InquiryType_Id IN (SELECT items FROM dbo.STSplit(@Type_Ids) )                                      
                     )                                      
                )               
   AND ( ( @Source_Ids = '' )                                      
                  OR ( @Source_Ids <> ''                                      
                       AND dbo.Inquiry.InquirySource_Id IN (SELECT items FROM dbo.STSplit(@Source_Ids) )                                      
                     )                     
                )               
   AND ( ( @Architect_Ids = '' )                                      
                  OR ( @Architect_Ids <> ''                                      
                       AND dbo.Inquiry.Architect_Dtl_Id IN (SELECT items FROM dbo.STSplit(@Architect_Ids) )                                      
                     )                                      
                )                         
   AND ( ( @Branch_Ids = '' )                                      
                  OR ( @Branch_Ids <> ''                                      
                       AND dbo.Inquiry.BranchMaster_Id IN (SELECT items FROM dbo.STSplit(@Branch_Ids) )                                      
                     )                                      
                )       
order by Inquiry.Inquiry_Id desc 
GO


