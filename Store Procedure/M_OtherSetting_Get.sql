USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_OtherSetting_Get]    Script Date: 27-04-2026 12:39:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[M_OtherSetting_Get] @Master_Id INT = 99                  
AS                    
    SET nocount ON                         
SELECT  M_Setting.Lockindate 
 From M_Setting With (NOLOCK)
 where Master_Id = @Master_Id
GO


