USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetData]    Script Date: 27-04-2026 11:55:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Employee_GetData]        
 @SearchParam VARCHAR(8000) = '',  -- Custom WHERE clause conditions
 @is_active BIT = 1                -- Filter active/inactive employees
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SqlString NVARCHAR(MAX);

    -- Base SQL query with parameterized @is_active
    SET @SqlString = '
        SELECT 
            m_employee.emp_id,
            m_employee.dept_id,
            m_employee.emp_name,
            m_employee.emp_roleid,
            Tbl_Role.master_vals AS Role_Name,
            m_employee.personal_no,
            m_employee.company_no,
            m_employee.email_id,
            m_employee.empaddress,
            m_employee.state_id,
            Tbl_State.master_vals AS StateName,
            m_employee.city_id,
            Tbl_City.master_vals AS CityName,
            m_employee.pin_code,
            m_employee.pancard_no,
            m_employee.adharno,
            m_employee.is_active,
            m_employee.remark,
            m_employee.uname,
            m_employee.upassword,
            m_employee.mac_add,
            m_employee.entry_user,
            m_employee.entry_date,
            m_employee.upd_user,
            m_employee.upd_date,
            m_employee.year_id,
            m_employee.branch_id
        FROM m_employee WITH (NOLOCK)
        LEFT JOIN m_master AS Tbl_Role WITH (NOLOCK) 
            ON m_employee.emp_roleid = Tbl_Role.master_id
        LEFT JOIN m_master AS Tbl_State WITH (NOLOCK) 
            ON m_employee.state_id = Tbl_State.master_id
        LEFT JOIN m_master AS Tbl_City WITH (NOLOCK) 
            ON m_employee.city_id = Tbl_City.master_id
        WHERE m_employee.emp_id <> 1
          AND m_employee.is_active = @is_active
    ';

    -- Add dynamic search parameter
    IF LTRIM(RTRIM(@SearchParam)) <> ''
    BEGIN
        SET @SqlString = @SqlString + ' AND ' + @SearchParam;
    END;

    -- Add ordering
    SET @SqlString = @SqlString + ' ORDER BY m_employee.entry_date DESC';

    -- Execute the dynamic query with parameter @is_active
    EXEC sp_executesql 
        @SqlString,
        N'@is_active BIT',
        @is_active;
END;
GO


