USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetRoleWise]    Script Date: 27-04-2026 11:58:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_GetRoleWise]          
@Dept_ID  int  = 0 ,      
@Emp_RoleIds varchar(max)='' ,      
@Is_Active int = 0       
      
AS          
          
SET NOCOUNT ON     
  
SELECT M_Employee.Emp_Id,  
       M_Employee.Dept_ID,  
       M_Employee.Emp_Name,  
       M_Employee.Emp_RoleId,  
       Tbl_Role.Master_Vals AS Role_Name,  
       M_Employee.Personal_No  
FROM   M_Employee WITH (nolock)  
       LEFT JOIN M_Department WITH (nolock) ON M_Employee.Dept_ID = M_Department.Dept_ID  
       LEFT JOIN M_Master AS Tbl_Role WITH (nolock) ON M_Employee.Emp_RoleId = Tbl_Role.Master_Id   
WHERE M_Employee.Is_Active = CASE  
                                    WHEN @Is_Active = 0 THEN  
                                    M_Employee.Is_Active  
                                    ELSE 1  
                                  END  
       AND M_Employee.Dept_ID = CASE  
                                  WHEN @Dept_ID = 0 THEN M_Employee.Dept_ID  
                                  ELSE @Dept_ID  
                                END  
       AND ( ( @Emp_RoleIds = '' )  
              OR ( @Emp_RoleIds <> ''  
                   AND M_Employee.Emp_RoleId IN (SELECT items  
                                                 FROM  
                       dbo.Stsplit(@Emp_RoleIds)) ) ) 
order BY M_Employee.Emp_Name
GO


