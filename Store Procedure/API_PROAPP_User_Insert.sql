USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_User_Insert]    Script Date: 27-04-2026 10:53:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

     
     
ALTER PROCEDURE [dbo].[API_PROAPP_User_Insert] @SantId   INT = 0,    
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
          SET @RetVal =-1    
          SET @RetMsg ='Your Login is Already Created.'    
    
          RETURN    
      END    
    ELSE    
      BEGIN    
          INSERT INTO [dbo].[m_pro_login]    
                      ([santid],    
                       [upwd],    
                       [is_active],    
                       [remark])    
          VALUES      (@SantId,    
                       @UPwd,    
                       1,    
                       @DeviceID)    
    
          SET @RetVal = SCOPE_IDENTITY()
          SET @RetMsg ='Your Login has been Success.'    
    
          IF @@ERROR <> 0    
            BEGIN    
                SET @RetVal = -1 -- 0 IS FOR ERROR         
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END    
    
    SET ansi_nulls ON    
    SET quoted_identifier ON 
GO


