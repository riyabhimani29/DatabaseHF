USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_Detail_Insert]    Script Date: 27-04-2026 10:50:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
       
       
ALTER PROCEDURE [dbo].[API_PROAPP_Detail_Insert]  @GF_Id          INT = 0,
                                                 @AyojanId       INT = 0,
                                                 @FirstName      NVARCHAR(150) = '',
                                                 @MiddleName     NVARCHAR(150) = '',
                                                 @Birthdate      DATE = '1900-01-01',
                                                 @LastName       NVARCHAR(150) = '',
                                                 @MobileNo       VARCHAR(50) = '',
                                                 @Area           NVARCHAR(250) = '',
                                                 @City           NVARCHAR(150) = '',
                                                 @FamilyMemberId INT = 0,
                                                 @Categoryid     INT = 0,
                                                 @Remarks        nVARCHAR(250) = '',
                                                 @MemberName     NVARCHAR(150) = '',
                                                 @MemberNos      VARCHAR(50) = '',
                                                 @PROUser_Id     INT =0,
                                                 @Device_id      VARCHAR(50) = '',
                                                 @RetVal         INT = 0 out,
                                                 @RetMsg         VARCHAR(150) = '' out
AS
    SET nocount ON

    IF @GF_Id = 0
      BEGIN
          INSERT INTO [dbo].[gurukulfamily_dtl]
                      ([ayojanid], [firstname], [middlename], [lastname], [mobileno], [birthdate], [area], [city],
                       [familymemberid], [membername], [membernos], prouser_id, device_id, entrydate, categoryid, remarks)
          VALUES      (@AyojanId, @FirstName, @MiddleName, @LastName, @MobileNo, @Birthdate, @Area, @City, @FamilyMemberId,
                       @MemberName, @MemberNos, @PROUser_Id, @Device_id, dbo.Get_sysdate(), @Categoryid, @Remarks )

          SET @RetVal = Scope_identity()
          SET @RetMsg = 'Save Success.'

          IF @@ERROR <> 0
            BEGIN
                SET @RetVal = -1 -- 0 IS FOR ERROR           
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END
    ELSE
      BEGIN
          IF NOT EXISTS (SELECT 1
                         FROM   gurukulfamily_dtl WITH ( nolock )
                         WHERE  gf_id = @GF_Id)
            BEGIN
                SET @RetVal = -12 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.  
                SET @RetMsg = 'Not The Entry You Want To Edit...'

                RETURN
            END

          UPDATE [dbo].[gurukulfamily_dtl]
          SET    [ayojanid] = @AyojanId,
                 [firstname] = @FirstName,
                 [middlename] = @MiddleName,
                 [lastname] = @LastName,
                 [mobileno] = @MobileNo,
                 [birthdate] = @Birthdate,
                 [area] = @Area,
                 [city] = @City,
                 [familymemberid] = @FamilyMemberId,
                 [membername] = @MemberName,
                 [membernos] = @MemberNos,
                 [remarks] = @Remarks,
                 [categoryid] = @Categoryid
          WHERE  gf_id = @GF_Id

          IF @@ERROR = 0
            BEGIN
                SET @RetVal = @GF_Id -- 1 IS FOR SUCCESSFULLY EXECUTED  
                SET @RetMsg = 'Edit Success.'
            END
          ELSE
            BEGIN
                SET @RetVal = -2 -- 0 IS FOR ERROR           
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
            END
      END

    SET ansi_nulls ON
    SET quoted_identifier ON 
GO


