USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Auth]    Script Date: 27-04-2026 11:54:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

            
ALTER PROCEDURE [dbo].[M_Employee_Auth]            
@userName  VARCHAR(8000)  = 'varni',            
@Password  VARCHAR(8000)  = 'l8rVg/KyfCs='  ,            
@Uid  VARCHAR(8000)  = ''      
            
AS            
            
SET NOCOUNT ON         
        
declare @_User_ID int=0 ;    
      
 SELECT       
	   Emp_Id,    
	   Dept_ID,      
	   Emp_Name,      
	   Emp_RoleId,      
	   Personal_No,      
	   Company_No,      
	   Email_ID,      
	   EmpAddress,      
	   State_Id,      
	   City_Id,       
	   UName     ,  
	   1 as BranchId ,  
	   1 as YearId  
 From M_Employee With (NOLOCK)       
 where M_Employee.UName = @userName      
	 and M_Employee.UPassword = @Password      
	 and M_Employee.Is_Active = 1    
    
       
select @_User_ID =  M_Employee.Emp_Id                         
from  M_Employee With (NOLOCK)       
where M_Employee.UName = @userName      
 and M_Employee.UPassword = @Password      
 and M_Employee.Is_Active = 1    
  
/***************************************/  
     SELECT M_Menu_Rigths.Id  
    ,M_Menu_Rigths.MenuId  
    ,Tbl_master.Menu_Name as MainMenuName
    ,M_Menu.Menu_Name       
    ,M_Menu.Is_MainMenu  
    ,M_Menu.MainMenu_Id  
    ,M_Menu.Menu_Path  
    ,M_Menu.Menu_Icon  
    ,M_Menu.Is_Active  
    ,M_Menu.Menu_Order
    ,M_Menu_Rigths.Emp_Id  
    ,M_Menu_Rigths.IsListView  
    ,M_Menu_Rigths.IsView  
    ,M_Menu_Rigths.IsAdd  
    ,M_Menu_Rigths.IsDelete  
    ,M_Menu_Rigths.IsEdit  
  FROM dbo.M_Menu_Rigths   with(nolock) 
  
  left join M_Menu with(nolock) on m_menu.MenuId = M_Menu_Rigths.MenuId  
  left join M_Menu AS Tbl_master  with(nolock) On M_Menu.MainMenu_Id = Tbl_master.MenuId 
  where dbo.M_Menu_Rigths.Emp_Id =   @_User_ID    
  and M_Menu.Is_Active = 1  
  order by M_Menu.Menu_Order
         
if (@_User_ID>0)                      
begin                   
  update M_Employee set LoginSession  = @Uid where Emp_Id=@_User_ID      
 return                      
                     
end 
GO


