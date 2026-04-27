USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_DeptSettingUpd]    Script Date: 27-04-2026 12:19:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
ALTER PROCEDURE [dbo].[M_Item_DeptSettingUpd] @Dept_ID         INT,    
                                                 @Is_Total_Parameter  bit,    
             @Is_Coated_Area  bit,    
             @Is_NonCoated_Area  bit,    
             @Is_Calc_Area  bit,        
             @Is_Weight  bit,    
                
   
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
      
  IF NOT EXISTS(SELECT 1    
                        FROM   M_Depart_Setting WITH (nolock)    
                        WHERE  Dept_ID = @Dept_ID)    
            BEGIN    
     
        --  INSERT INTO m_item_stk_limit WITH(rowlock)    
        --              (godown_id,    
        --               item_id,    
        --               length,    
        --               min_limit,    
        --               cri_limit,    
        --               mac_add,    
        --               entry_user,    
        --               entry_date,    
        --               upd_user,    
        --               upd_date,    
        --               year_id,    
        --               branch_id ,    
        --Remark)    
        --  VALUES     ( @Godown_Id,    
        --               @Item_Id,    
        --               @Length,    
        --               @Min_Limit,    
        --               @Cri_limit,    
        --               @MAC_Add,    
        --               @Entry_User,    
        --               dbo.Get_sysdate(),    
        --               0,    
        --               '1900-01-01',    
        --               @Year_Id,    
        --               @Branch_ID,    
        --@Remark)    
  
  
 INSERT INTO [dbo].[M_Depart_Setting] with (rowlock)  
           ([Dept_ID]  
           ,[Is_Total_Parameter]  
           ,[Is_Coated_Area]  
           ,[Is_NonCoated_Area]  
           ,[Is_Calc_Area]
		   ,Is_Weight)  
     VALUES  
           (@Dept_ID  
           ,@Is_Total_Parameter  
           ,@Is_Coated_Area  
           ,@Is_NonCoated_Area  
           ,@Is_Calc_Area,
		   @Is_Weight)  
    
          SET @RetMsg ='Department Setting Save Sucessfully.'    
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
                        FROM   M_Depart_Setting WITH (nolock)    
                        WHERE  Dept_ID = @Dept_ID)    
            BEGIN    
                SET @RetVal = -2    
    SET @RetMsg ='Department Setting Save Sucessfully.'    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.    
    
                RETURN    
            END    
    
   UPDATE [dbo].[M_Depart_Setting]  with (rowlock)  
     SET  [Is_Total_Parameter] = @Is_Total_Parameter  
		 ,[Is_Coated_Area] = @Is_Coated_Area  
		 ,[Is_NonCoated_Area] = @Is_NonCoated_Area  
		 ,[Is_Calc_Area] = @Is_Calc_Area    
		 ,[Is_Weight] = @Is_Weight 
   WHERE Dept_ID = @Dept_ID  
    
    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED             
                SET @RetMsg ='Department Setting Update Successfully.'    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED    
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
            END    
      END 
GO


