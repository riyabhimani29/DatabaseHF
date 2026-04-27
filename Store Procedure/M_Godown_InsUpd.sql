USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_InsUpd]    Script Date: 27-04-2026 12:05:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Godown_InsUpd] @Godown_Id      INT,
                                         @Godown_TypeId  INT,
                                         @Godown_Name    VARCHAR(500),
                                         @Godown_Address VARCHAR(500),
                                         @State_Id       INT,
                                         @City_Id        INT,
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

    IF ( @Godown_Id = 0 )
      BEGIN
          IF EXISTS(SELECT 1
                    FROM   m_godown WITH (nolock)
                    WHERE  godown_name = @Godown_Name)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg =
                'Same Godown Name Exist ,Please Enter Other Godown Name.'

                RETURN
            END

          INSERT INTO m_godown WITH(rowlock)
                      (godown_name,
                       godown_typeid,
                       godown_address,
                       state_id,
                       city_id,
                       is_active,
                       remark,
                       mac_add,
                       entry_user,
                       entry_date,
                       year_id,
                       branch_id)
          VALUES     ( Upper(@Godown_Name),
                       @Godown_TypeId,
                       @Godown_Address,
                       @State_Id,
                       @City_Id,
                       @Is_Active,
                       @Remark,
                       @MAC_Add,
                       @Entry_User,
                       dbo.Get_sysdate(),
                       @Year_Id,
                       @Branch_ID )

          SET @RetMsg ='Godown Create Sucessfully.'
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
                        FROM   m_godown WITH (nolock)
                        WHERE  godown_id = @Godown_Id)
            BEGIN
                SET @RetVal = -12
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.      
                SET @RetMsg =
                'This Godown Is Already Been Deleted By Another User.'

                RETURN
            END

          IF EXISTS(SELECT 1
                    FROM   m_godown WITH (nolock)
                    WHERE  godown_name = @Godown_Name
                           AND godown_id <> @Godown_Id)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg =
                'Same Godown Name Exist ,Please Enter Other Godown Name.'

                RETURN
            END

          UPDATE m_godown WITH (rowlock)
          SET    godown_typeid = @Godown_TypeId,
                 godown_name = Upper(@Godown_Name),
                 godown_address = @Godown_Address,
                 state_id = @State_Id,
                 city_id = @City_Id,
                 is_active = @Is_Active,
                 remark = @Remark,
                 upd_user = @Upd_User,
                 upd_date = dbo.Get_sysdate()
          WHERE  godown_id = @Godown_Id

          IF @@ERROR = 0
            BEGIN
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED           
                SET @RetMsg ='Godown Details Update Successfully.'
            END
          ELSE
            BEGIN
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED        
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END 
GO


