USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Stk_Limit_InsUpd]    Script Date: 27-04-2026 12:26:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Item_Stk_Limit_InsUpd] @Id         INT,
                                                 @Godown_Id  INT,
                                                 @Item_Id    INT,
                                                 @Length     INT,
                                                 @Min_Limit  NUMERIC,
                                                 @Cri_limit  NUMERIC,
                                                 @Remark    VARCHAR(500),
                                                 @MAC_Add    VARCHAR(500),
                                                 @Entry_User INT,
                                                 @Upd_User   INT,
                                                 @Year_Id    INT,
                                                 @Branch_ID  INT,
                                                 @RetVal     INT = 0 out,
                                                 @RetMsg     VARCHAR(max) = ''
out
AS
    SET nocount ON

    IF ( @Id = 0 )
      BEGIN
          INSERT INTO m_item_stk_limit WITH(rowlock)
                      (godown_id,
                       item_id,
                       length,
                       min_limit,
                       cri_limit,
                       mac_add,
                       entry_user,
                       entry_date,
                       upd_user,
                       upd_date,
                       year_id,
                       branch_id ,
					   Remark)
          VALUES     ( @Godown_Id,
                       @Item_Id,
                       @Length,
                       @Min_Limit,
                       @Cri_limit,
                       @MAC_Add,
                       @Entry_User,
                       dbo.Get_sysdate(),
                       0,
                       '1900-01-01',
                       @Year_Id,
                       @Branch_ID,
					   @Remark)

          SET @RetMsg ='Item Limit Create Sucessfully.'
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
                        FROM   m_item_stk_limit WITH (nolock)
                        WHERE  id = @Id)
            BEGIN
                SET @RetVal = -2
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.

                RETURN
            END

          UPDATE m_item_stk_limit WITH (rowlock)
          SET    min_limit = @Min_Limit,
                 cri_limit = @Cri_limit,
                 upd_user = @Upd_User,
                 upd_date = dbo.Get_sysdate(),
				 Remark = @Remark
          WHERE  id = @Id

          IF @@ERROR = 0
            BEGIN
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED         
                SET @RetMsg ='Item Limit Update Successfully.'
            END
          ELSE
            BEGIN
                SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END 
GO


