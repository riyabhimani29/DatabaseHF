USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetUser]    Script Date: 27-04-2026 11:58:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_GetUser]          
@Emp_Id  int = 1  
          
AS          
          
SET NOCOUNT ON        
  
 select M_Employee.Emp_Id,
		 M_Employee.Emp_Name,
		 M_Employee.UName 
 from M_Employee with(nolock) where M_Employee.Is_Active = 1 AND M_Employee.UName != ''
  
GO


