USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Role_GetDataList]    Script Date: 27-04-2026 12:00:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Employee_Role_GetDataList]
 @Dept_Id INT = 0,
 @Role varchar(500) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        M_Employee_Role.Id,
        M_Employee_Role.Emp_Id,
        M_Employee.Emp_Name,
        M_Employee_Role.Dept_Id,
        dpt.Master_Vals AS Dept_Name,
        M_Employee_Role.Role_Id,
        role.Master_Vals AS Role_Name
    FROM
        M_Employee_Role
    JOIN
        M_Employee ON M_Employee.Emp_Id = M_Employee_Role.Emp_Id
    left outer JOIN 
        M_Master AS dpt ON M_Employee_Role.Dept_Id = dpt.Master_Id
    JOIN 
        M_Master AS role ON M_Employee_Role.Role_Id = role.Master_Id
    WHERE
        (@Dept_Id = 0 OR M_Employee_Role.Dept_Id = @Dept_Id)
        AND (@Role = '' OR role.Master_Vals = @Role)
END;
GO


