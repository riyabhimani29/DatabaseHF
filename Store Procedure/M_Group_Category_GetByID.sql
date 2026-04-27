USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Group_Category_GetByID]    Script Date: 27-04-2026 12:08:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Group_Category_GetByID]
@Category_Id int =0 ,                     
@Type int = 0      

AS

SET NOCOUNT ON


SELECT 
	M_Group_Category.Category_Id,
	M_Group_Category.Category_Name,
	M_Group_Category.FrSrno,
	M_Group_Category.ToSrno,
	M_Group_Category.Is_Active,
	M_Group_Category.Dept_ID,
	M_Department.Dept_Name,
	M_Group_Category.Remark,
	M_Group_Category.MAC_Add,
	M_Group_Category.Entry_User,
	M_Group_Category.Entry_Date,
	M_Group_Category.Upd_User,
	M_Group_Category.Upd_Date,
	M_Group_Category.Year_Id,
	M_Group_Category.Branch_ID
 From M_Group_Category With (NOLOCK) 
 left join M_Department With (NOLOCK)  On M_Group_Category.Dept_ID = M_Department.Dept_ID
 Where M_Group_Category.Is_Active = case when @Type = 0  then M_Group_Category.Is_Active  else 1 end   

GO


