USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Project_Insert_Inquiry]    Script Date: 27-04-2026 12:43:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                         
ALTER  PROCEDURE [dbo].[M_Project_Insert_Inquiry] @Project_Id         INT,          
                                         @Pro_InchargeId     INT,          
                                         @Project_Name       VARCHAR(500),          
                                         @Project_Type_Id    INT,          
                                         @Site_Address       VARCHAR(500),          
                                         @Country_Id         INT,          
                                         @State_Id           INT,          
                                         @City_Id            INT,          
                                         @Cust_Id    INT,          
                                         @Customer_Address   VARCHAR(500),          
                                         @Contact_Person     VARCHAR(500),          
                                         @Contact_Number     VARCHAR(500),          
                                         @PAN_No             VARCHAR(500),          
                                         @GST_No             VARCHAR(500),          
                                         @SiteEngineer_Id    INT,          
                                         @Quatation_Amt      NUMERIC,          
                                         @Project_Start_Date DATETIME,          
                                         @Expected_End_Date  DATETIME,          
                                         @Project_Status     VARCHAR(500),          
                                         @Is_Active          BIT,          
                                         @Is_Godown          BIT,              
                                         @Godown_Id          INT,               
                                         @Inquiry_Id          INT,         
                                         @Remark             VARCHAR(500),          
                                         @MAC_Add            VARCHAR(500),          
                                         @Entry_User         INT,          
                                         @Upd_User           INT,          
                                         @Year_Id            INT,          
                                         @Branch_ID          INT,          
                                         @RetVal             INT = 0 out,          
                                         @RetMsg             VARCHAR(max) = ''          
out          
AS          
    SET nocount ON          
          
    IF ( @Project_Id = 0 )          
      BEGIN          
          IF EXISTS(SELECT 1          
                    FROM   m_project WITH (nolock)          
                    WHERE  project_name = @Project_Name)          
            BEGIN          
                SET @RetVal = -101          
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                      
                SET @RetMsg ='Same Project Name Exist.'          
          
                RETURN          
            END          
      
  --set @Project_Type_Id = (select Master_Id from  m_master with(nolock) where Master_Type ='PROJECT TYPE' and Master_Vals = 'INQUIRY')  
  --set @Project_Type_Id = (select inquiryType_id from Inquiry with(nolock)  where Inquiry_id = @Inquiry_Id)
   
  
  declare  @_Customer_Name   VARCHAR(500),       
     @_Customer_Address   VARCHAR(500),          
                 @_Contact_Person     VARCHAR(500),          
                 @_Contact_Number     VARCHAR(500),          
                 @_PAN_No             VARCHAR(500),          
                 @_GST_No             VARCHAR(500)    
    
   select @_Customer_Name = Cust_Name,    
     @_Customer_Address = Cust_Address,    
     @_PAN_No =PAN_No,    
     @_GST_No = GST_No,    
     @_Contact_Person = Contact_Person,    
     @_Contact_Number = Contact_No     
   from M_Customer With(rowlock) where Cust_Id = @Cust_Id    
    
          INSERT INTO m_project WITH(rowlock)          
                      (pro_inchargeid,          
                       project_name,          
						project_type_id,          
                       site_address,          
                       country_id,          
                       state_id,          
                       city_id,          
                       Customer_Name,          
                       customer_address,          
                       contact_person,          
                       contact_number,          
                       pan_no,          
                       gst_no,          
                       siteengineer_id,          
                       quatation_amt,          
                       project_start_date,          
                       expected_end_date,          
                       project_status,          
                       is_active,          
                       remark,          
                       mac_add,          
                       entry_user,          
                       entry_date,          
                       year_id,          
                       branch_id,    
					Inquiry_Id)          
          VALUES     ( @Pro_InchargeId,          
                       @Project_Name,          
						@Project_Type_Id,          
                       @Site_Address,          
                       @Country_Id,          
                       @State_Id,          
                       @City_Id,          
                       @_Customer_Name,          
                       @_Customer_Address,          
                       @_Contact_Person,          
                       @_Contact_Number,          
                       @_PAN_No,          
                       @_GST_No,          
                       @SiteEngineer_Id,          
                       @Quatation_Amt,          
                       dbo.Get_sysdate() ,   --- @Project_Start_Date,          
                       dbo.Get_sysdate() ,   ---@Expected_End_Date,          
                       @Project_Status,          
                       @Is_Active,          
                       @Remark,          
                       @MAC_Add,          
                       @Entry_User,          
                       dbo.Get_sysdate(),          
                       @Year_Id,          
                       @Branch_ID ,    
						@Inquiry_Id)          
          
          SET @RetMsg ='Project Create Sucessfully.'          
          SET @RetVal = Scope_identity()          
          
          IF @@ERROR <> 0          
            BEGIN          
                SET @RetVal = 0 -- 0 IS FOR ERROR                    
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
            END 
			
   else     
   begin    
   update Inquiry WITH (rowlock)   set Project_Id = @RetVal where Inquiry_Id = @Inquiry_Id    

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
                                   branch_id,    
									Project_Id)      
                      VALUES     ( Upper(@Project_Name),      
                                   107 /*GODOWN TYPE : SITE */,      
                                   @Site_Address,      
                                   @State_Id,      
                                   @City_Id,      
                                   1,      
                                   @Remark,      
                                   @MAC_Add,      
                                   @Entry_User,      
                                   dbo.Get_sysdate(),      
                                   @Year_Id,      
                                   @Branch_ID,    
									@RetVal)      

   end    
                    
      END          
    --ELSE          
    --  BEGIN          
    --      IF NOT EXISTS(SELECT 1          
    --                    FROM   m_project WITH (nolock)          
    --                    WHERE  project_id = @Project_Id)          
    --        BEGIN          
    --            SET @RetVal = -2          
    --            -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                    
    --            SET @RetMsg =          
    --            'This Project Is Already Been Deleted By Another User.'          
          
    --            RETURN          
    --        END          
          
    --      IF EXISTS(SELECT 1          
    --                FROM   m_project WITH (nolock)          
    --                WHERE  project_name = @Project_Name          
    --                       AND project_id <> @Project_Id)          
    --        BEGIN          
    --            SET @RetVal = -101          
    --            -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                          
    --            SET @RetMsg ='Same Project Name Exist.'          
          
    --            RETURN          
    --        END          
          
    --      UPDATE m_project WITH (rowlock)          
    -- SET    pro_inchargeid = @Pro_InchargeId,          
    --             project_name = @Project_Name,          
    --             project_type_id = @Project_Type_Id,          
    --             site_address = @Site_Address,          
    --             country_id = @Country_Id,          
    --             state_id = @State_Id,          
    --             city_id = @City_Id,          
    --             customer_name = @Customer_Name,          
    --             customer_address = @Customer_Address,          
    --             contact_person = @Contact_Person,                          
    -- contact_number = @Contact_Number,          
    --             pan_no = @PAN_No,          
    --             gst_no = @GST_No,          
    --             siteengineer_id = @SiteEngineer_Id,          
    --             quatation_amt = @Quatation_Amt,          
    --             project_start_date = @Project_Start_Date,          
    --             expected_end_date = @Expected_End_Date,          
    --             project_status = @Project_Status,          
    --             is_active = @Is_Active,          
    --             remark = @Remark,          
    --             upd_user = @Upd_User,          
    --             upd_date = dbo.Get_sysdate()          
    --      WHERE  project_id = @Project_Id          
          
    --      IF @@ERROR = 0          
    --        BEGIN          
    --            SET @RetVal = @Project_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                    
    --            SET @RetMsg ='Project Details Update Successfully.'        
           
    --        END          
    --      ELSE          
    --        BEGIN          
    --            SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED                    
    --            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
    --        END          
    --  END 
GO


