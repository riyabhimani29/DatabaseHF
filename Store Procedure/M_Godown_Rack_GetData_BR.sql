USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_Rack_GetData_BR]    Script Date: 27-04-2026 12:06:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Godown_Rack_GetData_BR]              
 @Godown_Id int = 1415      ,              
@Type int = 0            
AS        
    SET nocount ON        
         
 SELECT    
		M_Godown.Godown_Name,    
      dbo.M_Godown_Rack.Rack_Name,  
      dbo.M_Godown_Rack.Godown_Id, 
	  dbo.M_Godown_Rack.Rack_Id,  
      dbo.M_Godown_Rack.Is_Active    ,


M_Godown.Godown_Name+','+dbo.M_Godown_Rack.Rack_Name+','+ CONVERT(varchar(20), dbo.M_Godown_Rack.Godown_Id)+','+ CONVERT(varchar(20),dbo.M_Godown_Rack.Rack_Id) AS QRStr
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


