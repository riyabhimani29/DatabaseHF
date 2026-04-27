USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetLoginSession]    Script Date: 27-04-2026 11:56:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_GetLoginSession]          
@SessionUser  int  =1 ,  
@SessionId  VARCHAR(8000)  = '2b1b8cbf-1d29-8cea-e736-53504279a41f'  
          
AS          
          
SET NOCOUNT ON          
           
 SELECT   'Y'   flg    
  From M_Employee With (NOLOCK)            
  where M_Employee.Emp_Id = @SessionUser  
  and M_Employee.LoginSession = @SessionId
GO


