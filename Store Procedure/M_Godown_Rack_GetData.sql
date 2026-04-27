USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_Rack_GetData]    Script Date: 27-04-2026 12:06:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Godown_Rack_GetData]            
 @Godown_Id int = 10      ,            
@Type int = 0          
AS      
    SET nocount ON      
       
 SELECT dbo.M_Godown_Rack.Rack_Id,  
      dbo.M_Godown_Rack.Godown_Id,  
   M_Godown.Godown_Name,  
      dbo.M_Godown_Rack.Rack_Name,  
      dbo.M_Godown_Rack.Is_Active,  
      dbo.M_Godown_Rack.Remark,  
      dbo.M_Godown_Rack.MAC_Add,  
      dbo.M_Godown_Rack.Entry_User,  
      dbo.M_Godown_Rack.Entry_Date,  
      dbo.M_Godown_Rack.Upd_User,  
      dbo.M_Godown_Rack.Upd_Date,  
      dbo.M_Godown_Rack.Year_Id,  
      dbo.M_Godown_Rack.Branch_ID   
  FROM dbo.M_Godown_Rack  with(nolock)  
  left join M_Godown  with(nolock)on M_Godown_Rack.Godown_Id = M_Godown.Godown_Id  
   where M_Godown_Rack.is_active = CASE  
                                         WHEN @Type = 0 THEN  
           M_Godown_Rack.is_active  
                                         ELSE 1  
                                       END  
  AND M_Godown_Rack.Godown_Id = CASE  
                                             WHEN @Godown_Id = 0 THEN  
                                              M_Godown_Rack.Godown_Id  
                                             ELSE @Godown_Id  
                                           END  
GO


