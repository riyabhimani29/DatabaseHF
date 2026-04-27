USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Setting_Get]    Script Date: 27-04-2026 12:45:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Setting_Get] @Cate_Type varchar(10)           ='DC'        
AS                    
    SET nocount ON                
           
SELECT [dbo].[M_Setting].[Ids],
       [dbo].[M_Setting].[Cate_Type],
       [dbo].[M_Setting].[Cate_Name],
       [dbo].[M_Setting].[Master_Id],
       m_master.Master_Vals,
       m_master.Master_NumVals
FROM   [dbo].[M_Setting] WITH(nolock)
       LEFT JOIN M_Master  WITH(nolock) ON [dbo].[M_Setting].master_id = M_Master.master_id
WHERE  [M_Setting].Cate_Type = @Cate_Type 
GO


