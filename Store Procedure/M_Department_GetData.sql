USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Department_GetData]    Script Date: 27-04-2026 11:53:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Department_GetData]       
   @ActiveStatus INT = 0  , @_Type varchar(20)=''    
AS      
    SET nocount ON      
      
  DECLARE @_DeptIds VARCHAR(50)=''    
    
  IF ( @_Type = 'DC' )    
    BEGIN    
     SET @_DeptIds ='1,5'    
    END     
    
  IF ( @_Type = 'SB' ) --Sheet Bending    
    BEGIN    
     SET @_DeptIds ='1'    
    END     
    
  SELECT M_Department.Dept_ID,    
         M_Department.Dept_Name,    
         M_Department.Dept_Short_Name,    
         M_Department.Is_Active,    
         M_Department.Remark,    
         M_Department.Dis_Order,    
         M_Department.MAC_Add,    
         M_Department.Entry_User,    
         M_Department.Entry_Date,    
         M_Department.Upd_User,    
         M_Department.Upd_Date,    
         M_Department.Year_Id,    
         M_Department.Branch_ID  ,  
   M_Depart_Setting.Is_Calc_Area ,  
   M_Depart_Setting.Is_Coated_Area,  
   M_Depart_Setting.Is_NonCoated_Area ,  
   M_Depart_Setting.Is_Total_Parameter ,
   M_Depart_Setting.Is_Weight
  FROM   M_Department WITH (nolock)    
  left join M_Depart_Setting  WITH (nolock)   On M_Department.Dept_ID = M_Depart_Setting.Dept_ID   
  WHERE  M_Department.Is_Active = ( CASE   WHEN @ActiveStatus = 0 THEN   M_Department.Is_Active   ELSE 1   END )    
         AND ( ( @_Type = '' ) OR ( @_Type <> ''    
         AND M_Department.Dept_ID IN (SELECT items FROM dbo.Stsplit(@_DeptIds)) ) )    
  ORDER  BY M_Department.Entry_Date DESC 
GO


