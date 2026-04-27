USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROApp_GetEventList]    Script Date: 27-04-2026 10:50:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

            
ALTER  PROCEDURE [dbo].[API_PROApp_GetEventList]     @ListType INT = 0  
AS  
    SET nocount ON  
  
    SELECT [ayojanid],  
           [ayojanname],  
           [isactive],  
           [remark]  
    FROM   [dbo].[m_ayojan]  
  
    SELECT [pro_master_id],  
           [master_name]  
    FROM   [dbo].[m_pro_masters]  
    WHERE  master_type = 'RELATION'  
           AND [is_active] = 1 

	
    SELECT [pro_master_id] Categoryid,  
           [master_name] CategoryName 
    FROM   [dbo].[m_pro_masters]  
    WHERE  master_type = 'CATEGORY'  
           AND [is_active] = 1 
GO


