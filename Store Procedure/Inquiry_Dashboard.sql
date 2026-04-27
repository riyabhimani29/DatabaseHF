USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_Dashboard]    Script Date: 27-04-2026 11:47:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                      
ALTER PROCEDURE [dbo].[Inquiry_Dashboard]                                      
@FDate Date = '2022-01-01',
@TDate Date = '2022-12-31'
                                      
AS                                      
                                      
SET NOCOUNT ON                                      
   
select MONTH(Inquiry.Inquiry_Date) Month_No , count(1) AS Cnt  
from  Inquiry  with (nolock)
left join M_Master  with (nolock) on Inquiry.InquiryType_Id = M_Master.Master_Id 
where convert(date,Inquiry.Inquiry_Date) between @FDate and @TDate

group by MONTH(Inquiry.Inquiry_Date) 



Order By  Month_No
 
GO


