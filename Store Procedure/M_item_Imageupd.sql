USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_item_Imageupd]    Script Date: 27-04-2026 12:24:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_item_Imageupd]    
                                      @Item_Id         INT,   
                                      @RetVal          INT = 0 out,    
                                      @RetMsg          VARCHAR(max) = '' out   ,    
                                      @_ImageName          VARCHAR(max) = '' out   
AS    
    SET nocount ON    
                                  
      BEGIN    
        
		   set @_ImageName = CONVERT(varchar(100), CONVERT(numeric(38,0),  REPLACE(REPLACE(REPLACE(REPLACE( SYSUTCDATETIME(),'-',''),' ',''),':',''),'.','')) + @Item_Id) +'.png'
          
		  update M_Item set ImageName = @_ImageName where Item_Id = @Item_Id

          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = @Item_Id    
                -- 1 IS FOR SUCCESSFULLY EXECUTED                              
                SET @RetMsg ='Description Details Update Successfully.'    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = 0    
                -- 0 WHEN AN ERROR HAS OCCURED                             
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END 
GO


