USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Dashboard_GetData]    Script Date: 27-04-2026 11:14:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                   
ALTER    PROCEDURE [dbo].[Dashboard_GetData]     
@FDate Date  = ''   ,                  
@TDate Date  = ''   
                                                            
AS                                                            
                                                            
SET NOCOUNT ON                           
                        
select TblInquiry_Status.Master_Vals as Inquiry_Status,
       Count(1)                      Status_Cnt
from   Inquiry with(nolock)
       left join M_Master AS TblInquiry_Status WITH(nolock)
              On Inquiry.Inquiry_StatusId = TblInquiry_Status.Master_Id
where Inquiry.Inquiry_date BETween @FDate AND @TDate
group  by TblInquiry_Status.Master_Vals 
order BY TblInquiry_Status.Master_Vals

 
GO


