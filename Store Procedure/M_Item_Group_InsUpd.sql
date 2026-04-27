USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Group_InsUpd]    Script Date: 27-04-2026 12:24:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                
ALTER PROCEDURE [dbo].[M_Item_Group_InsUpd]  @Item_Group_Id   INT,    
                                             @Dept_ID         INT,    
                                             @Category_Id     INT,    
                                             @Item_Group_Name VARCHAR(500),    
                                             @Is_Active       BIT,    
                                             @Remark          VARCHAR(500),    
                                             @MAC_Add         VARCHAR(500),    
                                             @Entry_User      INT,    
                                             @Upd_User        INT,    
                                             @Year_Id         INT,    
                                             @Branch_ID       INT,    
                                             @DtlPara         TBL_FIELDGROUP readonly,    
                                             @RetVal          INT = 0 out,    
                                             @RetMsg          VARCHAR(max) = ''    
out    
AS    
    SET nocount ON    
    
    IF ( @Item_Group_Id = 0 )    
      BEGIN    
          IF EXISTS(SELECT 1    
                    FROM   m_item_group WITH (nolock)    
                    WHERE  item_group_name = @Item_Group_Name    
                           AND dept_id = @Dept_ID)    
            BEGIN    
                SET @RetVal = -101    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg ='Same Group Name Exist In Login Department.'    
    
                RETURN    
            END    
    
          DECLARE @_FrSrno      AS INT =0,    
                  @_ToSrno      AS INT =0,    
                  @_CurrentSrno AS INT =0,    
                  @_GrpCnt      AS INT =0,
                  @_NextSrno    INT = 0
    
          SELECT @_FrSrno = frsrno,    
                 @_ToSrno = tosrno    
          FROM   m_group_category WITH(nolock)    
          WHERE  category_id = @Category_Id    
    
          SELECT @_CurrentSrno = Isnull(category_no, @_FrSrno)    
          FROM   m_item_group WITH(nolock)    
          WHERE  category_id = @Category_Id    
    
          SELECT @_GrpCnt = Isnull(Count(*), 0)    
          FROM   m_item_group WITH(nolock)    
          WHERE  category_id = @Category_Id
          
          SELECT @_NextSrno =
          ISNULL(MAX(category_no), @_FrSrno - 1) + 1
          FROM m_item_group WITH (UPDLOCK, HOLDLOCK)
          WHERE category_id = @Category_Id
    
          INSERT INTO m_item_group WITH(rowlock)    
                      (dept_id,    
                       category_id,    
                       category_no,    
                       item_group_name,    
                       is_active,    
                       remark,    
                       mac_add,    
                       entry_user,    
                       entry_date,    
                       year_id,    
                       branch_id)    
          VALUES     (@Dept_ID,    
                      @Category_Id,    
                      @_NextSrno,    
                      @Item_Group_Name,    
                      @Is_Active,    
                      @Remark,    
                      @MAC_Add,    
                      @Entry_User,    
                      dbo.Get_sysdate(),    
                      @Year_Id,    
                      @Branch_ID )    
    
          SET @RetMsg ='Group Create Sucessfully.'    
          SET @RetVal = Scope_identity()    
    
          IF @@ERROR <> 0    
            BEGIN    
                SET @RetVal = 0 -- 0 IS FOR ERROR              
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
          ELSE    
            BEGIN    
                INSERT INTO m_group_field_setting WITH(rowlock)    
                            (item_group_id,  field_id)    
                SELECT @RetVal,    
                       field_id    
                FROM   @DtlPara    
                WHERE  isselect = 1;    
            END    
      END    
    ELSE    
      BEGIN    
          IF NOT EXISTS(SELECT 1    
                        FROM   m_item_group WITH (nolock)    
                        WHERE  item_group_id = @Item_Group_Id)    
            BEGIN    
                SET @RetVal = -12    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                 
                SET @RetMsg =    
                'This Group Is Already Been Deleted By Another User.'    
    
                RETURN    
            END    
    
          IF EXISTS(SELECT 1    
                    FROM   m_item_group WITH (nolock)    
                    WHERE  item_group_name = @Item_Group_Name    
                           AND dept_id = @Dept_ID    
                           AND item_group_id <> @Item_Group_Id)    
            BEGIN    
                SET @RetVal = -101  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg ='Same Group Name Exist In Login Department.'    
    
                RETURN    
            END    
    
          UPDATE m_item_group WITH (rowlock)    
          SET    -- Category_Id=@Category_Id ,            
				  item_group_name = @Item_Group_Name,    
				  is_active = @Is_Active,    
				  remark = @Remark,    
				  mac_add = @MAC_Add,    
				  upd_user = @Upd_User,    
				  upd_date = dbo.Get_sysdate()    
          WHERE  item_group_id = @Item_Group_Id    
    
          IF @@ERROR = 0    
            BEGIN    
                DELETE FROM m_group_field_setting    
                WHERE  item_group_id = @Item_Group_Id    
    
                INSERT INTO m_group_field_setting WITH(rowlock)    
                            (item_group_id,    
                             field_id)    
                SELECT @Item_Group_Id,    
                       field_id    
                FROM   @DtlPara    
                WHERE  isselect = 1;    
    
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED              
                SET @RetMsg ='Group Details Update Successfully.'    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED              
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END 
GO


