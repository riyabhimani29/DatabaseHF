USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Complains_GetList]    Script Date: 27-04-2026 11:12:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                                         
ALTER    PROCEDURE [dbo].[Complains_GetList]                                                                        
@Complain_Id int  = 0  ,                                
@FDate Date  = '1900-01-01'   ,                              
@TDate Date  = '1900-01-01'              
                                                                        
AS                                                                        
                                                                        
SET NOCOUNT ON                                       
  
SELECT Complains.Complain_Id,  
       Complains.Complain_No,  
       Tbl_Complain_Title.Master_Vals AS Complain_Title, 
       Complains.Complain_Title_Id,  
       Complains.Cust_Name,  
       Complains.Cust_Address,  
       Complains.Area,  
       Complains.Pin_Code,  
       Complains.Contact_Person,  
       Complains.Contact_Person_No,  
       Complains.Contact_No,  
       Complains.Project_Type_Id,  
    Tbl_Project_Type.Master_Vals AS Project_Type,  
       Complains.Year_of_Site,  
    Tbl_Year_of_Site.Master_Vals AS Year_of_Site_name,  
       Complains.Complaint_Type_Id,  
    Tbl_Complaint_Type.Master_Vals AS Complaint_Type,  
       Complains.Payment_Type_Id,  
    Tbl_Payment_Type.Master_Vals AS Payment_Type,  
       Complains.Complain_Details,  
       Complains.Remark,  
       Complains.MAC_Add,  
       Complains.Entry_User,  
       Complains.Entry_Date,  
       Complains.Upd_User,  
       Complains.Upd_Date,  
       Complains.Year_Id,  
       Complains.Branch_ID,  
       Complains.Complain_Date,  
       Complains.Invoice_No,
       Complains.Complain_Status_Id,
       Tbl_Complain_Status.Master_Vals as Complain_Status,
       Complains.Complain_Paid_Unpain,
       Tbl_Complain_Paid.Master_Vals as Complain_Paid_Unpain_Value,
       Complains.Complain_Closure,
       Complains.MR_OR_Glass_Order_Date,
       Complains.MR_OR_Glass_Order_No,
       Complains.Quotation_No,
       Complains.Owner_No,
       Complains.Owner_Name,
       Complains.Complain_Registration_date,
       Complains.Complain_Closing_date
  FROM [dbo].[Complains] WITH(NOLOCK)    
  left join M_Master AS Tbl_Project_Type WITH(NOLOCK)    On Tbl_Project_Type.Master_Id = Complains.Project_Type_Id  
  left join M_Master AS Tbl_Year_of_Site WITH(NOLOCK)    On Tbl_Year_of_Site.Master_Id = Complains.Year_of_Site  
  left join M_Master AS Tbl_Complaint_Type WITH(NOLOCK)    On Tbl_Complaint_Type.Master_Id = Complains.Complaint_Type_Id  
  left join M_Master AS Tbl_Payment_Type WITH(NOLOCK)    On Tbl_Payment_Type.Master_Id = Complains.Payment_Type_Id   
  left join M_Master AS Tbl_Complain_Title WITH(NOLOCK)    On Tbl_Complain_Title.Master_Id = Complains.Complain_Title_Id  
  left join M_Master as Tbl_Complain_Status WITH(NOLOCK) ON Tbl_Complain_Status.Master_Id =
  Complains.Complain_Status_Id
  left join M_Master as Tbl_Complain_Paid WITH(NOLOCK) ON Tbl_Complain_Paid.Master_Id =
  Complains.Complain_Paid_Unpain
  where /*convert(date, dbo.Visitors.VisitorsDate) Between @FDate AND @TDate                   
      and */ Complains.Complain_Id = (case when @Complain_Id = 0 then Complains.Complain_Id else @Complain_Id end )        
           
AND ( ( @FDate = '1900-01-01' )                
           OR ( @FDate <> '1900-01-01'                
                AND convert(date, Complains.Complain_Date) Between @FDate AND @TDate ) )          
order by Complains.Complain_Id desc 
GO


