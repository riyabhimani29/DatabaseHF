USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Customer_InsUpd]    Script Date: 27-04-2026 11:52:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[M_Customer_InsUpd] @Cust_Id      INT,         
                                         @Cust_Name    VARCHAR(500),      
                                         @Contact_No VARCHAR(500),       
                                         @Cust_Address    VARCHAR(500),      
                                         @Contact_Person    VARCHAR(500),      
                                         @GST_No   VARCHAR(500),       
                                         @PAN_No   VARCHAR(500),    
                                         @Email_Id        VARCHAR(500),  
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
      
    IF ( @Cust_Id = 0 )      
      BEGIN      
          IF EXISTS(SELECT 1      
                    FROM   M_Customer WITH (nolock)      
                    WHERE  Cust_Name = @Cust_Name)      
            BEGIN      
                SET @RetVal = -101   -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg =   'Same Customer Name Already Exist.'      
      
                RETURN      
            END      
    
    INSERT INTO dbo.M_Customer  WITH(rowlock)      
       (Cust_Name    
       ,Contact_No    
       ,Cust_Address    
       ,GST_No    
       ,PAN_No    
       ,Is_Active    
       ,Remark    
       ,MAC_Add    
       ,Entry_User    
       ,Entry_Date     
       ,Year_Id    
       ,Branch_ID  
    ,Contact_Person,
	Email_Id)    
    VALUES    
       (@Cust_Name    
       ,@Contact_No    
       ,@Cust_Address     
       ,@GST_No     
       ,@PAN_No     
       ,@Is_Active    
       ,@Remark    
       ,@MAC_Add    
       ,@Entry_User    
       ,dbo.Get_sysdate()     
       ,@Year_Id    
       ,@Branch_ID,  
    @Contact_Person,
	@Email_Id)    
     
          SET @RetMsg ='Customer Create Sucessfully.'      
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
                        FROM   M_Customer WITH (nolock)      
                        WHERE  Cust_Id = @Cust_Id)      
            BEGIN      
                SET @RetVal = -12  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg =  'This Customer Is Already Been Deleted By Another User.'      
      
                RETURN      
            END      
      
          IF EXISTS(SELECT 1      
                    FROM   M_Customer WITH (nolock)      
                    WHERE  Cust_Name = @Cust_Name      
                           AND Cust_Id <> @Cust_Id)      
            BEGIN      
                SET @RetVal = -101      
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                
                SET @RetMsg =   'Same Customer Name Exist ,Please Enter Other Customer Name.'      
      
                RETURN      
            END      
      
          UPDATE M_Customer WITH (rowlock)      
          SET    Cust_Name = @Cust_Name,    
				Contact_Person = @Contact_Person,     
                 Contact_No =  (@Contact_No),      
                 Cust_Address = @Cust_Address,      
                 GST_No = @GST_No,      
                 PAN_No = @PAN_No, 
				 Email_Id = @Email_Id ,
                 Is_Active = @Is_Active,      
				 Remark = @Remark,      
                 Upd_User = @Upd_User,      
                 Upd_Date = dbo.Get_sysdate()      
          WHERE  Cust_Id = @Cust_Id      
      
          IF @@ERROR = 0      
            BEGIN      
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED                 
                SET @RetMsg ='Customer Details Update Successfully.'      
        END      
          ELSE      
            BEGIN      
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED              
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
            END      
      END 
GO


