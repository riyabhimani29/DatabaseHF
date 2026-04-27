USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_GetVersion]    Script Date: 27-04-2026 10:52:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                             
 ALTER PROCEDURE [dbo].[API_PROAPP_GetVersion]                            
 @PROUser_Id  int = 0       
 AS                             
    SET NOCOUNT ON           
         
   select 9.0 AS VersionNo   
GO


