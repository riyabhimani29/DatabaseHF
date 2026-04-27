USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[ShowroomVisit_GetList]    Script Date: 27-04-2026 14:50:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                                    
ALTER PROCEDURE [dbo].[ShowroomVisit_GetList]                                                                    
@FDate Date  = '',                
@TDate Date  = ''
AS                                                                    
                                                                    
SET NOCOUNT ON                                   

SELECT 
Sales_Inquiry_Visit_Dtl.Id,
Sales_Inquiry_Visit_Dtl.Enter_By,
Sales_Inquiry_Visit_Dtl.Visitor_Id,
Sales_Inquiry_Visit_Dtl.Architect_Id,
--Visitors.VisitorsName,
--Visitors.VisitorsContact,
--Visitors.VisitorsMail,
--Visitors.VisitorsAddress,
M_Employee.Emp_Name as Enter_By_Name,
Inquiry.Architect_Dtl_Id,
Inquiry.Site_Id,
Sales_Inquiry_Visit_Dtl.Visitor_Date,
Sales_Inquiry_Visit_Dtl.ShowRoom_Visit,
Sales_Inquiry_Visit_Dtl.Purpose_Of_Visit,
Sales_Inquiry_Visit_Dtl.Remark,
Sales_Inquiry_Visit_Dtl.Documentation,
Inquiry.Inquiry_No,
Inquiry.Inquiry_Id
FROM 
Sales_Inquiry_Visit_Dtl
LEFT OUTER JOIN M_Employee
ON Sales_Inquiry_Visit_Dtl.Enter_By = M_Employee.Emp_Id
LEFT OUTER JOIN Inquiry ON Sales_Inquiry_Visit_Dtl.Inquiry_Id = Inquiry.Inquiry_Id 
--LEFT OUTER join Visitors on Sales_Inquiry_Visit_Dtl.Visitor_Id = Visitors.VisitorsId
WHERE 
  (
    (@FDate != '' AND @TDate != ''
      AND TRY_CONVERT(DATETIME, @FDate) IS NOT NULL
      AND TRY_CONVERT(DATETIME, @TDate) IS NOT NULL
      AND CONVERT(DATE, dbo.Sales_Inquiry_Visit_Dtl.Visitor_Date) BETWEEN @FDate AND @TDate
    )
    OR (@FDate = '' AND @TDate = '')
  )
      and Sales_Inquiry_Visit_Dtl.ShowRoom_Visit != 'Not Visited'
      order by Sales_Inquiry_Visit_Dtl.Visitor_Date DESC
GO


