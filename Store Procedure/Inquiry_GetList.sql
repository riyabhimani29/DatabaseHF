USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_GetList]    Script Date: 27-04-2026 11:48:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                          
ALTER    PROCEDURE [dbo].[Inquiry_GetList]                                                          
@Inquiry_Id int  = 0   ,                  
@FDate Date  = ''   ,                
@TDate Date  = ''  ,                
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
    Inquiry.Country_Id ,                  
    Inquiry.State_Id ,                  
    Inquiry.City_Id ,                  
  TblInquiry_Country.Master_Vals  AS Country_Nm,                   
  TblInquiry_State.Master_Vals AS State_Nm ,                   
  TblInquiry_City.Master_Vals AS City_Nm ,                   
                   
    Inquiry.InquirySource_Id ,                  
    Inquiry.InquiryType_Id ,                  
    Inquiry.Architect_Dtl_Id ,                 
 TblInquiry_Source.Master_Vals AS Source_Nm ,                   
 TblInquiry_Type.Master_Vals AS Type_Nm ,                   
 TblInquiry_ArcDtl.Master_Vals AS ArcDtl_Nm ,                   
 Inquiry.Cust_Id,              
 M_Customer.Cust_Name,              
              
       Inquiry.Project_Incharge_Id,                    
  M_Employee.Emp_Name  AS Project_Incharge ,                     
       Inquiry.Site_Engineer_Id,                    
  TblSite_Engineer.Emp_Name as Site_Engineer,                    
       isnull(Inquiry.Aprox_QTN_Val,0) AS Aprox_QTN_Val ,              
       Inquiry.Contact_Person,                    
       Inquiry.Contact_No,                    
       Inquiry.Inquiry_StatusId,                    
    TblInquiry_Status.Master_Vals as Inquiry_Status,                    
       Inquiry.Reference,                    
       Inquiry.Attachments_Name,                    
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
                   
  left join M_Master AS TblInquiry_Country  WITH(NOLOCK) On Inquiry.Country_Id = TblInquiry_Country.Master_Id                      
  left join M_Master AS TblInquiry_State  WITH(NOLOCK) On Inquiry.State_Id = TblInquiry_State.Master_Id                      
  left join M_Master AS TblInquiry_City  WITH(NOLOCK) On Inquiry.City_Id = TblInquiry_City.Master_Id                    
                 
  left join M_Master AS TblInquiry_Source  WITH(NOLOCK) On Inquiry.InquirySource_Id = TblInquiry_Source.Master_Id             
  left join M_Master AS TblInquiry_Type  WITH(NOLOCK) On Inquiry.InquiryType_Id = TblInquiry_Type.Master_Id                      
  left join M_Master AS TblInquiry_ArcDtl  WITH(NOLOCK) On Inquiry.Architect_Dtl_Id = TblInquiry_ArcDtl.Master_Id                    
            
  where convert(date, dbo.Inquiry.Inquiry_Date) Between @FDate AND @TDate     
  and  convert(date,(case when Inquiry.Upd_Date = '1900-01-01 00:00:00.000' then Inquiry.Entry_Date else Inquiry.Upd_Date end)) Between @FupDate AND @TupDate    
  AND  dbo.Inquiry.Aprox_QTN_Val Between (case when @From_Values = 0 then Inquiry.Aprox_QTN_Val Else @From_Values END ) AND (case when @From_Values = 0 then Inquiry.Aprox_QTN_Val Else @To_Values END )             
          
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
   AND ( ( @Customer_Ids = '' )                                      
                  OR ( @Customer_Ids <> ''                                      
                       AND dbo.Inquiry.Cust_Id IN (SELECT items FROM dbo.STSplit(@Customer_Ids) )                                      
                     )                                      
                )              
   AND ( ( @Branch_Ids = '' )                                      
                  OR ( @Branch_Ids <> ''                                      
                       AND dbo.Inquiry.BranchMaster_Id IN (SELECT items FROM dbo.STSplit(@Branch_Ids) )                                      
                     )                                      
                )       
order by Inquiry.Inquiry_Id desc 
GO


