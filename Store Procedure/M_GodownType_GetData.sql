USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_GodownType_GetData]    Script Date: 27-04-2026 12:07:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_GodownType_GetData]  
@SearchParam  VARCHAR(8000)  = ''  
  
AS  
  
SET NOCOUNT ON  
DECLARE @SqlString  NVARCHAR(Max)  
  
SET @SqlString ='  
	SELECT 
		Godown_TypeId,
		Godown_Type,
		Is_Active,
		Remark
	 From M_Godown_Type With (NOLOCK)
    
 '  
  
IF LTRIM ( RTRIM ( @SearchParam ) ) <> ''  
BEGIN  
SET @SqlString = @SqlString + ' WHERE ' + @SearchParam  
End  
  
EXECUTE sp_executesql   @SqlString
GO


