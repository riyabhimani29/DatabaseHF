USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Project_GetListData]    Script Date: 27-04-2026 12:41:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


                 
ALTER   PROCEDURE [dbo].[M_Project_GetListData]                    
@Type int  = 1   ,                               
    @FDate date           ='2022-12-23' ,                              
    @TDate date           ='2023-01-23'                  
                    
AS                    
                    
SET NOCOUNT ON                    
                  
 SELECT                     
  M_Project.Project_Id,                    
  M_Project.Pro_InchargeId,                    
  Tbl_Incharge.Emp_Name as Incharge,                    
  M_Project.Project_Name,                    
  M_Project.Project_Type_Id,                    
  Tbl_ProjectType.Master_Vals as Project_Type,                    
  M_Project.Site_Address,                    
  M_Project.Country_Id,                    
  Tbl_Country.Master_Vals  AS CountryName,                    
  M_Project.State_Id,                    
  Tbl_State.Master_Vals  AS StateName,                    
  M_Project.City_Id,
  M_Project.PD_Numbers,
  Tbl_City.Master_Vals AS CityName,                    
  M_Project.Customer_Name,                    
  M_Project.Customer_Address,                    
  M_Project.Contact_Person,                    
  M_Project.Contact_Number,                    
  M_Project.PAN_No,                    
  M_Project.GST_No,                    
  M_Project.SiteEngineer_Id, 
  Tbl_Engineer.Emp_Name as Engineer,                    
  --M_Project.ProjectManager_Id,
  --Tbl_ProjectManager.Emp_Name as ProjectManager,
  M_Project.Quatation_Amt,                    
  M_Project.Project_Start_Date,                    
  M_Project.Expected_End_Date,                    
  M_Project.Project_Status,                    
  M_Project.Is_Active,                    
  M_Project.Remark,                    
  M_Project.MAC_Add,                    
  M_Project.Entry_User,                    
  M_Project.Entry_Date,                    
  M_Project.Upd_User,                    
  M_Project.Upd_Date,                    
  M_Project.Year_Id,                    
  M_Project.Branch_ID ,
  M_Project.Site_Code,
  ISNULL(M_Godown.Godown_Id,0) AS Godown_Id  ,        
  Case when ISNULL(M_Godown.Godown_Id,0) = 0  then CONVERT(bit,0) else  CONVERT(bit,1)  end  AS Is_Godown  ,      
  M_Employee.Emp_Name AS Entry_UserName  ,    
  Inquiry.Inquiry_No,    
  M_Godown.Godown_Name    
  From M_Project With (NOLOCK)       
 left join Inquiry With (NOLOCK) On M_Project.Inquiry_Id = Inquiry.Inquiry_Id       
  left join M_Employee With (NOLOCK) On M_Project.Entry_User = M_Employee.Emp_Id        
  left join M_Godown   With (NOLOCK) On M_Project.Project_Id = M_Godown.Project_Id          
  left join M_Master  AS Tbl_ProjectType  With (NOLOCK)  On M_Project.Project_Type_Id = Tbl_ProjectType.Master_Id                    
  left join M_Employee AS Tbl_Incharge  With (NOLOCK)  On M_Project.Pro_InchargeId = Tbl_Incharge.Emp_Id                    
  left join M_Employee AS Tbl_Engineer   With (NOLOCK)  On M_Project.SiteEngineer_Id = Tbl_Engineer.Emp_Id  
  --left join M_Employee AS Tbl_ProjectManager  With (NOLOCK)  On M_Project.ProjectManager_Id = Tbl_ProjectManager.Emp_Id  
  left join M_Master  AS Tbl_Country  With (NOLOCK)  On M_Project.Country_Id = Tbl_Country.Master_Id                    
  left join M_Master  AS Tbl_State  With (NOLOCK)  On M_Project.State_Id = Tbl_State.Master_Id                    
  left join M_Master  AS Tbl_City  With (NOLOCK)  On M_Project.City_Id = Tbl_City.Master_Id                 
  where M_Project.Is_Active = case when @Type = 0  then M_Project.Is_Active  else 1 end     
 and  M_Project.Entry_Date between @FDate and DATEADD(day, 1, @TDate   )
  order by  M_Project.Entry_Date DESC ---Project_Name  
GO


