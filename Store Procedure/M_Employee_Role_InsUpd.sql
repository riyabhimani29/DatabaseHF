USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Role_InsUpd]    Script Date: 27-04-2026 12:02:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

          
ALTER PROCEDURE [dbo].[M_Employee_Role_InsUpd] @Id         INT,
										   @Emp_Id      INT,
                                           @Dept_Id     INT,
                                           @Role_Id    INT,
                                           @Entry_User  INT,
                                           @Upd_User    INT,
                                           @RetVal      INT = 0 out,
                                           @RetMsg      VARCHAR(max) = '' out
AS
    SET nocount ON

    IF ( @Id = 0 )
      BEGIN
          IF EXISTS(SELECT 1
                    FROM   M_Employee_Role WITH (nolock)
                    WHERE  Emp_Id = @Emp_Id
                           AND Dept_id = @Dept_Id
                           AND Role_Id = @Role_Id)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg ='Data Already Exist.'

                RETURN
            END

          INSERT INTO M_Employee_Role WITH(rowlock)
                      (
                      Emp_Id,
          				Dept_Id,
          				Role_Id,
          				Entry_User,
          				Entry_Date
                      )
          VALUES     ( 
          @Emp_Id,
          				@Dept_Id,
          				@Role_Id,
                       @Entry_User,
                       dbo.Get_sysdate())

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
                        FROM   M_Employee_Role WITH (nolock)
                        WHERE  Id = @Id)
            BEGIN
                SET @RetVal = -2
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg =
                'This Data Is Already Been Deleted By Another User.'

                RETURN
            END

         IF EXISTS(SELECT 1
                    FROM   M_Employee_Role WITH (nolock)
                    WHERE  Emp_Id = @Emp_Id
                           AND Dept_id = @Dept_Id
                           AND Role_Id = @Role_Id)
            BEGIN
                SET @RetVal = -101
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.          
                SET @RetMsg ='Data Already Exist.'

                RETURN
            END

          UPDATE M_Employee_Role WITH (rowlock)
          SET         Emp_Id = @Emp_Id,
          				Dept_Id = @Dept_Id,
          				Role_Id = @Role_Id,
                 upd_user = @Upd_User,
                 upd_date = dbo.Get_sysdate()
          WHERE  Id = @Id

          IF @@ERROR = 0
            BEGIN
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED           
                SET @RetMsg ='Details Update Successfully.'
            END
          ELSE
            BEGIN
                SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED           
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END 
GO


