USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Role_GetData]    Script Date: 27-04-2026 12:00:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Employee_Role_GetData]              
 @Type Bit = 0    
AS        
    SET nocount ON        
  SELECT 
  M_Employee_Role.Id,
  M_Employee_Role.Emp_Id,
  M_Employee.Emp_Name,
  M_Employee_Role.Dept_Id,
  dpt.Master_Vals as Dept_Name,
  M_Employee_Role.Role_Id,
  role.Master_Vals as Role_Name
  FROM
  M_Employee_Role
  join
  M_Employee
  ON M_Employee.Emp_Id = M_Employee_Role.Emp_Id
  left outer join 
  M_Master as dpt
  ON M_Employee_Role.Dept_Id = dpt.Master_Id
  join 
  M_Master as role
  ON M_Employee_Role.Role_Id = role.Master_Id
GO


