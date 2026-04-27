USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Visitors_GetList]    Script Date: 27-04-2026 14:49:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                                    
ALTER PROCEDURE [dbo].[Sales_Visitors_GetList]                                                                    
@VisitorsId int  = 0   ,       
@Inquiry_Id int = 0,
@FDate Date  = '1900-01-01'   ,                          
@TDate Date  = '1900-01-01'    
                                                                    
AS                                                                    
                                                                    
SET NOCOUNT ON                                   
          
SELECT  Visitors.VisitorsId,        
      Visitors.VisitorsNo,        
      Visitors.VisitorsDate,        
      Visitors.VisitorsName,        
      Visitors.VisitorsContact,        
      Visitors.VisitorsMail,        
      Visitors.VisitorsAddress,        
      Visitors.Remark,         
      Visitors.Enter_By,         
      Visitors.Enter_By,        
   M_Employee.Emp_Name AS Attended_By  ,      
   Visitors.Is_Flg    ,  
   Visitors.Inquiry_Id  ,
   case when Visitors.Inquiry_Id > 1 then 'Move to Inquiry' else  'Open' end AS Visitors_Status
  FROM [dbo].[Visitors]  WITH(NOLOCK)         
  left join M_Employee  WITH(NOLOCK)  on M_Employee.Emp_Id  = Visitors.Enter_By        
           
  where /*convert(date, dbo.Visitors.VisitorsDate) Between @FDate AND @TDate               
      and */Visitors.VisitorsId = (case when @VisitorsId = 0 then Visitors.VisitorsId else @VisitorsId end )    
       AND Visitors.Inquiry_Id = (case when @Inquiry_Id = 0 then Visitors.Inquiry_Id ELSE @Inquiry_Id end )
AND ( ( @FDate = '1900-01-01' )            
           OR ( @FDate <> '1900-01-01'            
                AND convert(date, dbo.Visitors.VisitorsDate) Between @FDate AND @TDate ) )      
order by Visitors.VisitorsId desc 
GO


