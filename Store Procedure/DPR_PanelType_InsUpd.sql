USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_PanelType_InsUpd]    Script Date: 27-04-2026 11:26:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[DPR_PanelType_InsUpd] @PanelType_Id      INT,         
                                         @Name    VARCHAR(500),      
                                         @Is_Active      BIT,      
                                         @Remark         VARCHAR(500),      
                                         @MAC_Add        VARCHAR(500),      
                                         @Entry_User     INT,      
                                         @Upd_User       INT,      
                                         @Year_Id        INT,      
                                         @RetVal         INT = 0 out,      
                                         @RetMsg         VARCHAR(max) = '' out      
AS      
    SET nocount ON      
      
    IF ( @PanelType_Id = 0 )      
      BEGIN      
          IF EXISTS(SELECT 1      
                    FROM   DPR_PanelTypes WITH (nolock)      
                    WHERE  [Name] = @Name)      
            BEGIN      
                SET @RetVal = -101   -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg =   'Same Name Already Exist.'      
      
                RETURN      
            END      
    
    INSERT INTO dbo.DPR_PanelTypes  WITH(rowlock)      
       (Name    
       ,Is_Active    
       ,Remark    
       ,MAC_Add    
       ,Entry_User    
       ,Entry_Date     
       ,Year_Id)    
    VALUES    
       (@Name    
       ,@Is_Active    
       ,@Remark    
       ,@MAC_Add    
       ,@Entry_User    
       ,dbo.Get_sysdate()     
       ,@Year_Id)    
     
          SET @RetMsg ='Create Sucessfully.'      
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
                        FROM   DPR_PanelTypes WITH (nolock)      
                        WHERE  PanelType_Id = @PanelType_Id)      
            BEGIN      
                SET @RetVal = -12  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg =  'This Elevation Is Already Been Deleted By Another User.'      
      
                RETURN      
            END      
      
          IF EXISTS(SELECT 1      
                    FROM   DPR_PanelTypes WITH (nolock)      
                    WHERE  [Name] = @Name
                           AND PanelType_Id <> @PanelType_Id)      
            BEGIN      
                SET @RetVal = -101      
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg =   'Same Elevation Name Exist ,Please Enter Other Name.'      
      
                RETURN      
            END      
      
          UPDATE DPR_PanelTypes WITH (rowlock)      
          SET    Name = @Name,    
			     Is_Active = @Is_Active,      
				 Remark = @Remark,      
                 Upd_User = @Upd_User,      
                 Upd_Date = dbo.Get_sysdate()      
          WHERE  PanelType_Id = @PanelType_Id
      
          IF @@ERROR = 0      
            BEGIN      
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED                 
                SET @RetMsg ='Update Successfully.'      
        END      
          ELSE      
            BEGIN      
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED              
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
            END      
      END 
GO


