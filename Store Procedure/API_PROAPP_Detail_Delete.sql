USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_Detail_Delete]    Script Date: 27-04-2026 10:49:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

      
         
         
ALTER PROCEDURE [dbo].[API_PROAPP_Detail_Delete]  @GF_Id          INT = 0,   
                                                 @RetVal         INT = 0 out,  
                                                 @RetMsg         VARCHAR(150) = '' out  
AS  
    SET nocount ON  
   
          UPDATE [dbo].[gurukulfamily_dtl]  
          SET    Is_Active = 0
          WHERE  gf_id = @GF_Id   AND Is_Active = 1 
  
          IF @@ERROR = 0  
            BEGIN  
                SET @RetVal = @GF_Id -- 1 IS FOR SUCCESSFULLY EXECUTED    
                SET @RetMsg = 'Delete Success.'  
            END  
          ELSE  
            BEGIN  
                SET @RetVal = -2 -- 0 IS FOR ERROR             
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
            END   
  
    SET ansi_nulls ON  
    SET quoted_identifier ON 
GO


