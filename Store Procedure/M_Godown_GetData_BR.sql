USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_GetData_BR]    Script Date: 27-04-2026 12:04:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Godown_GetData_BR]            
 @SearchParam VARCHAR(8000) = ''      
AS      
    SET nocount ON      
      
    DECLARE @SqlString NVARCHAR(max)      
      
    SET @SqlString ='      
SELECT M_Godown.Godown_Id,      
       M_Godown.Godown_Name   
FROM   M_Godown WITH (nolock)     
     '      
      
    IF Ltrim (Rtrim (@SearchParam)) <> ''      
      BEGIN      
          SET @SqlString = @SqlString + ' WHERE ' + @SearchParam      
      END      
      
    SET @SqlString = @SqlString      
                     + ' ORDER BY M_Godown.Godown_Name  '      
      
    EXECUTE Sp_executesql      
      @SqlString 
GO


