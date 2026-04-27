USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_Category_InsUpd]    Script Date: 27-04-2026 12:18:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

             
ALTER PROCEDURE [dbo].[M_Item_Category_InsUpd]  @Item_Cate_Id   INT,  
                                                @Item_Group_Id  INT,  
                                                @Item_Cate_Name VARCHAR(500),  
                                                @Item_Cate_Code VARCHAR(500),  
                                                @Is_Active      BIT,  
                                                @Remark         VARCHAR(500),  
                                                @MAC_Add        VARCHAR(500),  
                                                @Entry_User     INT,  
                                                @Upd_User       INT,  
                                                @Year_Id        INT,  
                                                @Branch_ID      INT,  
                                                @RetVal         INT = 0 out,  
                                                @RetMsg         VARCHAR(max) =  
'' out  
AS  
    SET nocount ON  
  
    IF ( @Item_Cate_Id = 0 )  
      BEGIN  
          IF EXISTS(SELECT 1  
                    FROM   m_item_category WITH (nolock)  
                    WHERE  item_cate_name = @Item_Cate_Name  
                           AND item_group_id = @Item_Group_Id)  
            BEGIN  
                SET @RetVal = -101  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg ='Same Category Name Exist In Selected Group.'  
  
                RETURN  
            END  
  
          INSERT INTO m_item_category WITH(rowlock)  
                      (item_group_id,  
                       item_cate_name,  
                       item_cate_code,  
                       is_active,  
                       remark,  
                       mac_add,  
                       entry_user,  
                       entry_date,  
                       year_id,  
                       branch_id)  
          VALUES     ( @Item_Group_Id,  
                       @Item_Cate_Name,  
                       @Item_Cate_Code,  
                       @Is_Active,  
                       @Remark,  
                       @MAC_Add,  
                       @Entry_User,  
                       dbo.Get_sysdate(),  
                       @Year_Id,  
                       @Branch_ID )  
  
          SET @RetMsg ='Category Create Sucessfully.'  
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
                        FROM   m_item_category WITH (nolock)  
                        WHERE  item_cate_id = @Item_Cate_Id)  
            BEGIN  
                SET @RetVal = -12  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg =  
                'This Category Is Already Been Deleted By Another User.'  
  
                RETURN  
            END  
  
          IF EXISTS(SELECT 1  
                    FROM   m_item_category WITH (nolock)  
                    WHERE  item_cate_name = @Item_Cate_Name  
                           AND item_group_id = @Item_Group_Id  
                           AND item_cate_id <> @Item_Cate_Id)  
            BEGIN  
                SET @RetVal = -101  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg ='Same Category Name Exist In Selected Group.'  
  
                RETURN  
            END  
  
          UPDATE m_item_category WITH (rowlock)  
          SET --Item_Group_Id = @Item_Group_Id ,          
				 item_cate_name = @Item_Cate_Name,  
				 is_active = @Is_Active,  
				 remark = @Remark,  
				 upd_user = @Upd_User,  
				 upd_date = dbo.Get_sysdate()  
          WHERE  item_cate_id = @Item_Cate_Id  
  
          IF @@ERROR = 0  
            BEGIN  
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED          
                SET @RetMsg ='Category Details Update Successfully.'  
            END  
          ELSE  
            BEGIN  
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED          
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
            END  
      END 
GO


