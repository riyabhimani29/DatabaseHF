USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_GetMenuRights]    Script Date: 27-04-2026 11:56:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_GetMenuRights]          
@Emp_Id  int = 1  
          
AS          
          
SET NOCOUNT ON        
  
 SELECT dbo.M_Menu.MenuId ,  
       dbo.M_Menu.Menu_Name,  
       dbo.M_Menu.Is_MainMenu,  
       dbo.M_Menu.MainMenu_Id,  
    Tbl_master.Menu_Name as MainMenuName,  
       dbo.M_Menu.Menu_Path,  
       dbo.M_Menu.Menu_Icon,  
       dbo.M_Menu.Is_Active,  
       dbo.M_Menu.Menu_Order,  
       KK.Id,   
       KK.Emp_Id,  
       KK.IsListView,  
       KK.IsView,  
       KK.IsAdd,  
       KK.IsDelete,  
       KK.IsEdit  
	  FROM dbo.M_Menu with(nolock)  
	  left join M_Menu AS Tbl_master  with(nolock) On M_Menu.MainMenu_Id = Tbl_master.MenuId  
  outer Apply (
  select dbo.M_Menu_Rigths.Id,   
		   dbo.M_Menu_Rigths.Emp_Id,  
		   dbo.M_Menu_Rigths.IsListView,  
		   dbo.M_Menu_Rigths.IsView,  
		   dbo.M_Menu_Rigths.IsAdd,  
		   dbo.M_Menu_Rigths.IsDelete,  
		   dbo.M_Menu_Rigths.IsEdit  from dbo.M_Menu_Rigths with(nolock)  where  dbo.M_Menu_Rigths.MenuId =  dbo.M_Menu.MenuId   
			 and dbo.M_Menu_Rigths.Emp_Id = @Emp_Id  --and  M_Menu_Rigths.IsView =  1
  ) AS KK
   
where M_Menu.Is_Active = 1    
  
 order by dbo.M_Menu.Menu_Order  
  
GO


