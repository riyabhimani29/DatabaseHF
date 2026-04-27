USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROApp_Login]    Script Date: 27-04-2026 10:52:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[API_PROApp_Login] @SantId   INT = 0,    
                                         @UPwd     VARCHAR(50) = '',    
                                         @DeviceID VARCHAR(50) = '',    
                                         @RetVal   INT = 0 out,    
                                         @RetMsg   VARCHAR(150) = '' out      
AS    
    SET nocount ON    
    
    IF EXISTS (SELECT 1    
               FROM   [dbo].[m_pro_login] WITH (nolock)    
               WHERE  [dbo].[m_pro_login].santid = @SantId)    
      BEGIN    
  
    IF Not EXISTS (SELECT 1    
               FROM   [dbo].[m_pro_login] WITH (nolock)    
               WHERE  [dbo].[m_pro_login].is_active = 1    
                 AND [dbo].[m_pro_login].santid = @SantId    
                 AND [dbo].[m_pro_login].upwd = @UPwd )    
BEGIN  
 SET @RetVal = -2    
          SET @RetMsg ='Wrong Password.'   
return  
end   
  
          --SELECT [id],    
          --       [santid],    
          --       [upwd],    
          --       [is_active],    
          --       [remark]    
          --FROM   [dbo].[m_pro_login] WITH (nolock)    
          --WHERE  [dbo].[m_pro_login].is_active = 1    
          --       AND [dbo].[m_pro_login].santid = @SantId    
          --       AND [dbo].[m_pro_login].upwd = @UPwd    
    
          DECLARE @_Id AS INT =0   --,  @_Pass AS varchar(50) = '' 
    
          SELECT @_Id = [id]    --, @_Pass = upwd
          FROM   [dbo].[m_pro_login] WITH (nolock)    
          WHERE  [dbo].[m_pro_login].is_active = 1    
                 AND [dbo].[m_pro_login].santid = @SantId    
                 AND [dbo].[m_pro_login].upwd = @UPwd    
    
          SET @RetVal = @_Id    
          SET @RetMsg ='Your Login has been Success.'
		 -- SET @RetPass = @_Pass
      END    
    ELSE    
      BEGIN    
          SET @RetVal = -1    
          SET @RetMsg ='Create a login ID first .Then login.'  
		 -- SET @RetPass = 'Nill'  
      END 
GO


