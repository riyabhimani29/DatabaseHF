USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_InsUpd]    Script Date: 27-04-2026 11:59:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_InsUpd]  @Emp_Id      INT,
                                           @Dept_ID     INT,
                                           @Emp_Name    VARCHAR(500),
                                           @Emp_RoleId  INT,
                                           @Personal_No VARCHAR(500),
                                           @Company_No  VARCHAR(500),
                                           @Email_ID    VARCHAR(500),
                                           @EmpAddress  VARCHAR(500),
                                           @State_Id    INT,
                                           @City_Id     INT,
                                           @Pin_Code    VARCHAR(500),
                                           @PanCard_No  VARCHAR(500),
                                           @AdharNo     VARCHAR(500),
                                           @Is_Active   BIT,
                                           @Remark      VARCHAR(500),
                                           @UName       VARCHAR(500),
                                           @UPassword   VARCHAR(500),
                                           @MAC_Add     VARCHAR(500),
                                           @Entry_User  INT,
                                           @Upd_User    INT,
                                           @Year_Id     INT,
                                           @Branch_ID   INT,
                                           @RetVal      INT = 0 out,
                                           @RetMsg      VARCHAR(max) = '' out
AS
    SET nocount ON

    IF ( @Emp_Id = 0 )
      BEGIN
          IF EXISTS(SELECT 1
                    FROM   m_employee WITH (nolock)
                    WHERE  emp_name = Upper(@Emp_Name)
                           AND dept_id = @Dept_ID)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg ='Same Employee Name Exist In Login Department.'

                RETURN
            END

          IF EXISTS(SELECT 1
                    FROM   m_employee WITH (nolock)
                    WHERE  uname = Upper(@UName)
                           AND uname <> '')
            BEGIN
                SET @RetVal = -102
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
                SET @RetMsg ='Same Login User Name Exist.'

                RETURN
            END

          INSERT INTO m_employee WITH(rowlock)
                      (dept_id,
                       emp_name,
                       emp_roleid,
                       personal_no,
                       company_no,
                       email_id,
                       empaddress,
                       state_id,
                       city_id,
                       pin_code,
                       pancard_no,
                       adharno,
                       is_active,
                       remark,
                       uname,
                       upassword,
                       mac_add,
                       entry_user,
                       entry_date,
                       year_id,
                       branch_id)
          VALUES     ( @Dept_ID,
                       ( @Emp_Name ), -- UPPER    
                       @Emp_RoleId,
                       @Personal_No,
                       @Company_No,
                       @Email_ID,
                       @EmpAddress,
                       @State_Id,
                       @City_Id,
                       @Pin_Code,
                       @PanCard_No,
                       @AdharNo,
                       @Is_Active,
                       @Remark,
                       @UName,
                       @UPassword,
                       @MAC_Add,
                       @Entry_User,
                       dbo.Get_sysdate(),
                       @Year_Id,
                       @Branch_ID )

          SET @RetMsg ='Employee Create Sucessfully.'
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
                        FROM   m_employee WITH (nolock)
                        WHERE  emp_id = @Emp_Id)
            BEGIN
                SET @RetVal = -2
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg =
                'This Employee Is Already Been Deleted By Another User.'

                RETURN
            END

          IF EXISTS(SELECT 1
                    FROM   m_employee WITH (nolock)
                    WHERE  emp_name = Upper(@Emp_Name)
                           AND dept_id = @Dept_ID
                           AND emp_id <> @Emp_Id)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.           
                SET @RetMsg ='Same Login User Name Exist.'

                RETURN
            END

          IF EXISTS(SELECT 1
                    FROM   m_employee WITH (nolock)
                    WHERE  uname = Upper(@UName)
                           AND uname <> ''
                           AND emp_id <> @Emp_Id)
            BEGIN
                SET @RetVal = -102
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg ='Same Login User Name Exist.'

                RETURN
            END

          UPDATE m_employee WITH (rowlock)
          SET    emp_name = ( @Emp_Name ), --UPPER   
                 emp_roleid = @Emp_RoleId,
                 personal_no = @Personal_No,
                 company_no = @Company_No,
                 email_id = @Email_ID,
                 empaddress = @EmpAddress,
                 state_id = @State_Id,
                 city_id = @City_Id,
                 pin_code = @Pin_Code,
                 pancard_no = @PanCard_No,
                 adharno = @AdharNo,
                 is_active = @Is_Active,
                 remark = @Remark,
                 uname = @UName,
                 upassword = @UPassword,
                 upd_user = @Upd_User,
                 upd_date = dbo.Get_sysdate()
          WHERE  emp_id = @Emp_Id

          IF @@ERROR = 0
            BEGIN
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED           
                SET @RetMsg ='Employee Details Update Successfully.'
            END
          ELSE
            BEGIN
                SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED           
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END 
GO


