USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_FollowUp_Data]    Script Date: 27-04-2026 14:42:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                                    
ALTER PROCEDURE [dbo].[Sales_FollowUp_Data]                                                                    
                                                           
AS                                                                    
                                                                    
SET NOCOUNT ON                                   
          
SELECT 
Id,
FollowUp_Type,
M_Master.Master_Vals as FollowUp_Type_Name,
Sales_Inquiry_FollowUps.FollowUp_By,
M_Employee.Email_ID FollowUp_By_Email,
M_Employee.Emp_Name FollowUp_By_Name,
Inquiry.Inquiry_No,
Sales_Inquiry_FollowUps.FollowUp_Status_Date
FROM Sales_Inquiry_FollowUps 
JOIN M_Employee on Sales_Inquiry_FollowUps.FollowUp_By
= M_Employee.Emp_Id
JOIN M_Master on Sales_Inquiry_FollowUps.FollowUp_Type = M_Master.Master_Id
JOIN Inquiry on Sales_Inquiry_FollowUps.Inquiry_Id = Inquiry.Inquiry_Id
WHERE --FollowUp_Status_Date = CONVERT(DATE,dbo.Get_sysdate())
--AND 
FollowUp_Status = 0
GO


