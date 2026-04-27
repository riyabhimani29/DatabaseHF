USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[AllLogin_MST_Get]    Script Date: 27-04-2026 10:49:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                            
ALTER  PROCEDURE [dbo].[AllLogin_MST_Get]      
@Type  varchar(50)  = 'PO-GRN'        
                                            
AS                                            
                                            
SET NOCOUNT ON                                            
    
/***********************************************************************/    
        
  SELECT M_Department.Dept_ID,        
         M_Department.Dept_Name,        
         M_Department.Dept_Short_Name,        
         M_Department.Is_Active,        
         M_Department.Remark,        
         M_Department.Dis_Order,        
    M_Depart_Setting.Is_Calc_Area ,      
    M_Depart_Setting.Is_Coated_Area,      
    M_Depart_Setting.Is_NonCoated_Area ,      
    M_Depart_Setting.Is_Total_Parameter ,    
    M_Depart_Setting.Is_Weight    
  FROM   M_Department WITH (nolock)        
  left join M_Depart_Setting  WITH (nolock)   On M_Department.Dept_ID = M_Depart_Setting.Dept_ID       
  WHERE  M_Department.Is_Active = 1       
  ORDER  BY M_Department.Entry_Date DESC   
  
/***********************************************************************/  
  
--   SELECT M_Godown.Godown_Id,    
--        M_Godown.Godown_Name,    
--        M_Godown.Godown_TypeId,    
--        Tbl_Godown_Type.Master_Vals AS Godown_Type,    
--        M_Godown.Godown_Address,    
--        M_Godown.State_Id,    
--        Tbl_State.Master_Vals       AS StateName,    
--        M_Godown.City_Id,    
--        Tbl_City.Master_Vals        AS CityName,    
--        M_Godown.Is_Active   
-- FROM   M_Godown WITH (nolock)    
--        LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Godown.State_Id = Tbl_State.Master_Id    
--        LEFT JOIN M_Master AS Tbl_City WITH (nolock) ON M_Godown.City_Id = Tbl_City.Master_Id    
--        LEFT JOIN M_Master AS Tbl_Godown_Type WITH (nolock) ON M_Godown.Godown_TypeId = Tbl_Godown_Type.Master_Id    
-- where M_Godown.Is_Active = 1  
  
/***********************************************************************/  
  
            
--  SELECT                     
--   M_Project.Project_Id,                         
--   Tbl_Incharge.Emp_Name as Incharge,                    
--   M_Project.Project_Name,                       
--   Tbl_ProjectType.Master_Vals as Project_Type,                    
--   M_Project.Site_Address,                  
  --Tbl_Country.Master_Vals  AS CountryName,     
  --Tbl_State.Master_Vals  AS StateName,     
  --Tbl_City.Master_Vals AS CityName,   
--   Inquiry.Inquiry_No,    
    
--   M_Godown.Godown_Name  ,  
  
--   M_Project.Customer_Name,                    
--   M_Project.Customer_Address,                    
--   M_Project.Contact_Person,                    
--   M_Project.Contact_Number,                    
                           
--   Tbl_Engineer.Emp_Name as Engineer,                    
--   M_Project.Quatation_Amt,                          
--   M_Project.Project_Status,                    
--   M_Project.Is_Active,              
--   ISNULL(M_Godown.Godown_Id,0) AS Godown_Id  ,        
--   Case when ISNULL(M_Godown.Godown_Id,0) = 0  then CONVERT(bit,0) else  CONVERT(bit,1)  end  AS Is_Godown  ,      
--   M_Employee.Emp_Name AS Entry_UserName  ,  
--   M_Project.Remark   
  
--   From M_Project With (NOLOCK)       
--  left join Inquiry With (NOLOCK) On M_Project.Inquiry_Id = Inquiry.Inquiry_Id       
--   left join M_Employee With (NOLOCK) On M_Project.Entry_User = M_Employee.Emp_Id        
--   left join M_Godown   With (NOLOCK) On M_Project.Project_Id = M_Godown.Project_Id          
--   left join M_Master  AS Tbl_ProjectType  With (NOLOCK)  On M_Project.Project_Type_Id = Tbl_ProjectType.Master_Id                    
--   left join M_Employee AS Tbl_Incharge  With (NOLOCK)  On M_Project.Pro_InchargeId = Tbl_Incharge.Emp_Id                    
--   left join M_Employee AS Tbl_Engineer   With (NOLOCK)  On M_Project.SiteEngineer_Id = Tbl_Engineer.Emp_Id                    
  --left join M_Master  AS Tbl_Country  With (NOLOCK)  On M_Project.Country_Id = Tbl_Country.Master_Id                    
  --left join M_Master  AS Tbl_State  With (NOLOCK)  On M_Project.State_Id = Tbl_State.Master_Id                    
  --left join M_Master  AS Tbl_City  With (NOLOCK)  On M_Project.City_Id = Tbl_City.Master_Id                 
--   where M_Project.Is_Active =  1               
--   order by  M_Project.Entry_Date DESC ---Project_Name  
  
/***********************************************************************/  
     
--  SELECT      
--      dbo.M_Supplier.Supplier_Id,      
--      dbo.M_Supplier.Supplier_Name,    
--      dbo.M_Supplier.Email_ID,      
--      dbo.M_Supplier.Contact_No,    
--      dbo.M_Supplier.PAN_No,      
--      dbo.M_Supplier.GST_No,      
--      dbo.M_Supplier.Address,      
--      dbo.M_Supplier.Pin_Code,      
--      dbo.M_Supplier.State_Id,      
--      Tbl_State.Master_Vals as StateName,      
--      dbo.M_Supplier.City_Id,      
--      Tbl_City.Master_Vals as CityName,      
--      dbo.M_Supplier.Is_Active,      
--      dbo.M_Supplier.Remark,    
--      dbo.M_Supplier.Dept_ID      
--   From      
--      dbo.M_Supplier With (NOLOCK)      
--      left join M_Master as Tbl_State  With (NOLOCK) On M_Supplier.State_Id = Tbl_State.Master_Id      
--      left join M_Master as Tbl_City  With (NOLOCK) On M_Supplier.City_Id = Tbl_City.Master_Id      
--     where   M_Supplier.Is_Active  =  1 
GO


