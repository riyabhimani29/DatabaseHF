USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[CoatingDC_Master_Get]    Script Date: 27-04-2026 11:10:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CoatingDC_Master_Get]             
 @SettingParam varchar(500)='',        
 @Type int =0,        
 @SupplierDept_ID  int =0,        
 @EmpDept_ID int =0,        
 @GSTParam varchar(500)='',        
 @GSTRef_Id INT = 0                 
AS                                                          
    SET nocount ON                                                      
      
    /***********************************************/      
    SELECT dbo.M_Setting.Ids,      
           dbo.M_Setting.Cate_Type,      
           dbo.M_Setting.Cate_Name,      
           dbo.M_Setting.Master_Id,      
           M_Master.Master_Vals,      
           M_Master.Master_NumVals      
    FROM   dbo.M_Setting WITH(nolock)      
           LEFT JOIN M_Master WITH(nolock)   ON dbo.M_Setting.Master_Id = M_Master.Master_Id      
    WHERE  M_Setting.Cate_Type = @SettingParam      
    /***********************************************/      
    SELECT M_Godown.Godown_Id,      
           M_Godown.Godown_TypeId,      
           M_Godown.Godown_Name,      
           Tbl_Godown_Type.Master_Vals AS Godown_Type,      
           M_Godown.Godown_Address,      
           M_Godown.State_Id,      
           Tbl_State.Master_Vals       AS StateName,      
           M_Godown.City_Id,      
           Tbl_City.Master_Vals        AS CityName,      
           M_Godown.Is_Active,      
           M_Godown.Remark--,      
           --M_Godown.mac_add,      
           --M_Godown.entry_user,      
           --M_Godown.entry_date,      
           --M_Godown.upd_user,      
           --M_Godown.upd_date,      
           --M_Godown.year_id,      
           --M_Godown.branch_id      
    FROM   M_Godown WITH (nolock)      
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Godown.state_id = Tbl_State.Master_Id      
           LEFT JOIN M_Master AS Tbl_City WITH (nolock) ON M_Godown.city_id = Tbl_City.Master_Id      
           LEFT JOIN M_Master AS Tbl_Godown_Type WITH (nolock) ON M_Godown.godown_typeid = Tbl_Godown_Type.Master_Id      
    ORDER  BY M_Godown.Entry_Date DESC      
      
    /***********************************************/      
    SELECT M_Project.Project_Id,      
           M_Project.Pro_InchargeId,      
           Tbl_Incharge.Emp_Name         AS Incharge,      
           M_Project.Project_Name,      
           M_Project.Project_Type_Id,      
           Tbl_ProjectType.Master_Vals   AS Project_Type,      
           M_Project.Site_Address,      
           M_Project.Country_Id,      
           Tbl_Country.Master_Vals       AS CountryName,      
           M_Project.State_Id,      
           Tbl_State.Master_Vals         AS StateName,      
           M_Project.City_Id,      
           Tbl_City.Master_Vals          AS CityName,      
           M_Project.Customer_Name,      
           M_Project.Customer_Address,      
           M_Project.Contact_Person,      
           M_Project.Contact_Number,      
           M_Project.PAN_No,      
           M_Project.GST_No,      
           M_Project.SiteEngineer_Id,      
           Tbl_Engineer.Emp_Name         AS Engineer,      
           --M_Project.quatation_amt,      
           --M_Project.project_start_date,      
           --M_Project.expected_end_date,      
           M_Project.Project_Status,      
           M_Project.Is_Active,      
           M_Project.Remark,      
           --M_Project.mac_add,      
           --M_Project.entry_user,      
           --M_Project.entry_date,      
           --M_Project.upd_user,      
           --M_Project.upd_date,      
           --M_Project.year_id,      
           --M_Project.branch_id,      
           Isnull(M_Godown.Godown_Id, 0) AS Godown_Id,      
           CASE      
             WHEN Isnull(M_Godown.godown_id, 0) = 0 THEN CONVERT(BIT, 0)      
             ELSE CONVERT(BIT, 1)      
           END                           AS Is_Godown,      
           M_Employee.Emp_Name           AS Entry_UserName      
    FROM   M_Project WITH (nolock)      
           LEFT JOIN M_Employee WITH (nolock) ON M_Project.Entry_User = M_Employee.Emp_Id      
           LEFT JOIN M_Godown WITH (nolock) ON M_Project.Project_Id = M_Godown.project_id      
           LEFT JOIN M_Master AS Tbl_ProjectType WITH (nolock) ON M_Project.Project_Type_Id = Tbl_ProjectType.Master_Id      
           LEFT JOIN M_Employee AS Tbl_Incharge WITH (nolock) ON M_Project.Pro_InchargeId = Tbl_Incharge.Emp_Id      
           LEFT JOIN M_Employee AS Tbl_Engineer WITH (nolock) ON M_Project.SiteEngineer_Id = Tbl_Engineer.Emp_Id      
           LEFT JOIN M_Master AS Tbl_Country WITH (nolock) ON M_Project.Country_Id = Tbl_Country.Master_Id      
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Project.State_Id = Tbl_State.Master_Id      
           LEFT JOIN M_Master AS Tbl_City WITH (nolock) ON M_Project.city_id = Tbl_City.Master_Id      
    WHERE  M_Project.Is_Active = CASE      
                                   WHEN @Type = 0 THEN M_Project.Is_Active      
                                   ELSE 1      
                                 END      
    ORDER  BY M_Project.entry_date DESC      
      
    /***********************************************/      
    SELECT dbo.M_Supplier.Supplier_Id,      
           dbo.M_Supplier.Supplier_Name,      
           dbo.M_Supplier.Email_ID,      
           dbo.M_Supplier.Contact_No,      
           dbo.M_Supplier.PAN_No,      
           dbo.M_Supplier.GST_No,      
           dbo.M_Supplier.Address,      
           --dbo.M_Supplier.pin_code,      
           dbo.M_Supplier.State_Id,      
           Tbl_State.Master_Vals AS StateName,      
           dbo.M_Supplier.City_Id,      
           Tbl_City.Master_Vals  AS CityName,      
           dbo.M_Supplier.Is_Active,      
           dbo.M_Supplier.Remark,      
           dbo.M_Supplier.Dept_ID --,      
           --dbo.M_Supplier.year_id,      
           --dbo.M_Supplier.branch_id,      
           --dbo.M_Supplier.mac_add,      
           --dbo.M_Supplier.entry_user,      
           --dbo.M_Supplier.entry_date,      
           --dbo.M_Supplier.upd_user,      
           --dbo.M_Supplier.upd_date      
    FROM   dbo.M_Supplier WITH (nolock)      
           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.State_Id = Tbl_State.Master_Id      
           LEFT JOIN M_Master AS Tbl_City WITH (nolock) ON M_Supplier.City_Id = Tbl_City.Master_Id      
    WHERE  dbo.M_Supplier.Dept_IDs LIKE ( CASE      
                                        WHEN @SupplierDept_ID = 0 THEN dbo.M_Supplier.Dept_ID      
                                        ELSE @SupplierDept_ID      
                                      END )      
           AND M_Supplier.Is_Active = ( CASE      
                                          WHEN @Type = 0 THEN      
                                          dbo.M_Supplier.Is_Active      
                                          ELSE @Type      
                                        END )      
      
    /***********************************************/      
    SELECT M_Employee.Emp_Id,      
           M_Employee.Dept_ID,      
           M_Employee.Emp_Name,      
           M_Employee.Emp_RoleId,      
           Tbl_Role.master_vals AS Role_Name,      
           M_Employee.Personal_No      
    FROM   M_Employee WITH (nolock)      
           LEFT JOIN M_Department WITH (nolock) ON M_Employee.Dept_ID = M_Department.Dept_ID      
           LEFT JOIN M_Master AS Tbl_Role WITH (nolock) ON M_Employee.Emp_RoleId = Tbl_Role.Master_Id      
    WHERE  M_Employee.Emp_Id <> 1      
           AND M_Employee.Is_Active = CASE      
                                        WHEN @Type = 0 THEN M_Employee.Is_Active      
                                        ELSE 1      
                                      END      
           AND M_Employee.Dept_ID = CASE      
                                      WHEN @EmpDept_ID = 0 THEN      
                                      M_Employee.Dept_ID      
                                      ELSE @EmpDept_ID      
                              END      
      
    --AND ( ( @Emp_RoleIds = '' )        
    --       OR ( @Emp_RoleIds <> ''        
    --            AND M_Employee.Emp_RoleId IN (SELECT items        
    --                                          FROM        
    --         dbo.Stsplit(@Emp_RoleIds)) ) )       
    /***********************************************/      
    IF ( @GSTParam = '' )      
      BEGIN      
          SELECT Master_Id,      
                 Ref_Id,      
                 Master_Type,      
                 Master_Vals,      
                 Master_NumVals,      
                 Is_Active,      
                 Remark      
          FROM   M_Master WITH (nolock)      
          WHERE  Master_Type IN ( CASE      
                                 WHEN @GSTParam = '' THEN Master_Type      
                                 ELSE @GSTParam      
                               END )     
                 AND Ref_Id = CASE      
                                WHEN @GSTRef_Id = 0 THEN Ref_Id      
                                ELSE @GSTRef_Id      
                              END      
          ORDER  BY M_Master.Entry_Date DESC      
      END      
    ELSE      
      BEGIN      
          SELECT Master_Id,      
                 Ref_Id,      
                 Master_Type,      
                 Master_Vals,      
                 Master_NumVals,      
                 Is_Active,      
                 Remark      
          FROM   M_Master WITH (nolock)      
          WHERE  Master_Type IN (SELECT items      
                                 FROM   dbo.Stsplit (@GSTParam))      
                 AND Ref_Id = CASE      
                                WHEN @GSTRef_Id = 0 THEN Ref_Id      
                                ELSE @GSTRef_Id      
                              END      
          ORDER  BY M_Master.Entry_Date DESC      
      END 
GO


