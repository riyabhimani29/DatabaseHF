USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_Rack_InsUpd]    Script Date: 27-04-2026 12:07:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Godown_Rack_InsUpd] @Rack_Id      INT,    
                                         @Godown_Id  INT,    
                                         @Rack_Name    VARCHAR(500),    
                                           
                                         @Is_Active      BIT,    
                                         @Remark         VARCHAR(500),    
                                         @MAC_Add        VARCHAR(500),    
                                         @Entry_User     INT,    
                                         @Upd_User       INT,    
                                         @Year_Id        INT,    
                                         @Branch_ID      INT,    
                                         @RetVal         INT = 0 out,    
                                         @RetMsg         VARCHAR(max) = '' out    
AS    
    SET nocount ON    
    
    IF ( @Rack_Id = 0 )    
      BEGIN    
          IF EXISTS(SELECT 1    
                    FROM   M_Godown_Rack WITH (nolock)    
                    WHERE  Rack_Name = @Rack_Name AND Godown_Id = @Godown_Id)    
            BEGIN    
                SET @RetVal = -101    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.              
                SET @RetMsg =    
                'Same Rack Name Exist ,Please Enter Other Rack Name.'    
    
                RETURN    
            END    
    
          INSERT INTO M_Godown_Rack WITH(rowlock)    
                      (Rack_Name,    
                       Godown_Id,     
                       is_active,    
                       remark,    
                       mac_add,    
                       entry_user,    
                       entry_date,    
                       year_id,    
                       branch_id)    
          VALUES     ( Upper(@Rack_Name),    
                       @Godown_Id,    
                       @Is_Active,    
                       @Remark,    
                       @MAC_Add,    
                       @Entry_User,    
                       dbo.Get_sysdate(),    
                       @Year_Id,    
                       @Branch_ID )    
    
          SET @RetMsg ='Godown Rack Create Sucessfully.'    
          SET @RetVal = Scope_identity()    
    
          IF @@ERROR <> 0    
            BEGIN    
                SET @RetVal = 0 -- 0 IS FOR ERROR            
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END    
    ELSE    
      BEGIN    
          IF NOT EXISTS(SELECT 1    
                        FROM   M_Godown_Rack WITH (nolock)    
                        WHERE  Rack_Id = @Rack_Id)    
            BEGIN    
                SET @RetVal = -12    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg =    
                'This Rack Is Already Been Deleted By Another User.'    
    
                RETURN    
            END    
    
          IF EXISTS(SELECT 1    
                    FROM   M_Godown_Rack WITH (nolock)    
                    WHERE  Rack_Name = @Rack_Name 
						  AND Godown_Id = @Godown_Id
                           AND Rack_Id <> @Rack_Id)    
            BEGIN    
                SET @RetVal = -101    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.              
                SET @RetMsg =    
                'Same Godown Rack Name Exist ,Please Enter Other Godown Name.'    
    
                RETURN    
            END    
    
          UPDATE M_Godown_Rack WITH (rowlock)    
          SET    --Godown_Id = @Godown_Id,    
                 Rack_Name = Upper(@Rack_Name),    
                 is_active = @Is_Active,    
     remark = @Remark,    
                 upd_user = @Upd_User,    
                 upd_date = dbo.Get_sysdate()    
          WHERE  Rack_Id = @Rack_Id    
    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED               
                SET @RetMsg ='Godown Rack Details Update Successfully.'    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED            
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END 
GO


