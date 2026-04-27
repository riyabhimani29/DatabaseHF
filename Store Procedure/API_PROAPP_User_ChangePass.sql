USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_User_ChangePass]    Script Date: 27-04-2026 10:53:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

       
       
ALTER PROCEDURE [dbo].[API_PROAPP_User_ChangePass] @SantId   INT = 0,      
                                             @UPwd     VARCHAR(50) = '',      
                                             @NewUPwd     VARCHAR(50) = '',      
                                             @RetVal   INT = 0 out,      
                                             @RetMsg   VARCHAR(150) = '' out      
AS      
    SET nocount ON      
      
    IF NOT EXISTS (SELECT 1      
               FROM   [dbo].[m_pro_login] WITH (nolock)      
               WHERE  [dbo].[m_pro_login].santid = @SantId /*AND UPwd  = @UPwd*/)      
      BEGIN      
          SET @RetVal =-1      
          SET @RetMsg ='Please Enter The Correct Old Password.'         
          RETURN      
      END      
    ELSE      
      BEGIN      
           
  UPDATE [dbo].[M_PRO_Login]  
     SET  [UPwd] = @NewUPwd   
   WHERE [dbo].[m_pro_login].santid = @SantId   
        
      
           IF @@ERROR = 0                         
                BEGIN                              
                    SET @RetVal = @SantId -- 1 IS FOR SUCCESSFULLY EXECUTED       
     SET @RetMsg ='Your Password Has Been Successfully.'                           
                END                              
            ELSE                         
                BEGIN                              
                    SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED       
     SET @RetMsg ='Error Occurred - ' + Error_message() + '.'                           
                END     
      END      
      
    SET ansi_nulls ON      
    SET quoted_identifier ON 
GO


