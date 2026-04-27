USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Group_Field_GetData]    Script Date: 27-04-2026 12:10:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

        
ALTER PROCEDURE [dbo].[M_Group_Field_GetData]               
@Type int = 0        
        
AS        
        
SET NOCOUNT ON       


SELECT 
	M_Group_Field.Field_Id,
	M_Group_Field.Field_Name,
	M_Group_Field.Is_Active,
	M_Group_Field.Remark,
	convert(bit,0) as IsSelect
 From M_Group_Field With (NOLOCK)
 where M_Group_Field.Is_Active = 1
GO


