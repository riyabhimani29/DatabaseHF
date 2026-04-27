USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_Insert]    Script Date: 27-04-2026 11:49:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Inquiry_Insert] @Inquiry_No          VARCHAR(500),  
                                       @Inquiry_Date        DATE,  
                                       @Inquiry_Id          INT,  
                                       @BranchMaster_Id     INT,  
  
                                       --@Project_Id          INT,                
                                       @Project_Incharge_Id INT,  
                                       @Site_Engineer_Id    INT,  
  
                                       --@Cust_Id             INT,                
                                       @Inquiry_StatusId    INT,  
                                       @Project_Name        VARCHAR(500),  
                                       @Project_Address     VARCHAR(500),  
                                       @Contact_Person      VARCHAR(500),  
                                       @Contact_No          VARCHAR(500),  
                                       @Reference           VARCHAR(500),  
                                       @Remark              VARCHAR(500),  
                                       @Project_Reference   VARCHAR(500),  
                                       @InquirySource_Id    INT,  
                                       @InquiryType_Id      INT,  
                                       @Architect_Dtl_Id    INT,  
                                       @Cust_Id             INT,  
                                       @Aprox_QTN_Val       NUMERIC(18, 3),  
  
                                       @GlassType           VARCHAR(500),  
                                       @Coating             VARCHAR(500),  
                                       @FlyMesh             VARCHAR(500),  
                                       @WindowSystem        VARCHAR(500),              
                                       @VisitorsId     INT,  
  
                                       @Country_Id          INT,  
                                       @State_Id            INT,  
                                       @City_Id             INT,  
                                       @MAC_Add             VARCHAR(500),  
                                       @Entry_User          INT,  
                                       @Upd_User            INT,  
                                       @Year_Id             INT,  
                                       @Branch_ID           INT,  
                                       @RetVal              INT = 0 out,  
                                       @RetMsg              VARCHAR(max) = ''  
out,  
                                       @_ImageName          VARCHAR(max) = ''  
out  
AS  
    SET nocount ON  
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))  
  
    IF ( @Inquiry_Id = 0 )  
      BEGIN  
          declare @_Is_AutoNo as BIT = 0  
  
          if ( @Inquiry_No = 0 )  
            begin  
                set @_Is_AutoNo = 1  
  DECLARE @FinancialYear INT
  SET @FinancialYear = 
            CASE 
                WHEN MONTH(@Inquiry_Date) >= 4 
                THEN YEAR(@Inquiry_Date) + 1 
                ELSE YEAR(@Inquiry_Date) 
            END
              IF EXISTS (
            SELECT 1  
            FROM Inquiry  
            WHERE Is_AutoNo = 1 
            AND CASE 
                    WHEN MONTH(Inquiry_Date) >= 4 
                    THEN YEAR(Inquiry_Date) + 1 
                    ELSE YEAR(Inquiry_Date) 
                END = @FinancialYear
        )  
        BEGIN  
            SET @Inquiry_No = (
                SELECT ISNULL(MAX(CONVERT(NUMERIC(18, 0), Inquiry_No)), 0) + 1  
                FROM Inquiry WITH(NOLOCK)  
                WHERE Is_AutoNo = 1 
                AND CASE 
                        WHEN MONTH(Inquiry_Date) >= 4 
                        THEN YEAR(Inquiry_Date) + 1 
                        ELSE YEAR(Inquiry_Date) 
                    END = @FinancialYear
            )  
        END  
        ELSE  
        BEGIN  
            -- Generate the starting number for the financial year (e.g., 2500001 for FY 2025)
            SET @Inquiry_No = CONVERT(NUMERIC(12, 0), CONVERT(VARCHAR(2), @FinancialYear % 100) + '00001')  
        END
            end  
  
          if ( @Inquiry_No = 0 )  
            begin  
                SET @RetMsg = 'Please Enter New Inquiry No.'  
                SET @_ImageName = ''  
                SET @RetVal = -102  
  
                return  
            END  
  
          If Exists (select 1  
                     from   Inquiry with(rowlock)  
                     where  Inquiry_No = @Inquiry_No)  
            begin  
                SET @RetMsg = 'Inquiry No [  ' + convert(VARCHAR(50), @Inquiry_No) + '  ] Already Exists , Please Enter New Inquiry No.'  
                SET @_ImageName = ''  
                SET @RetVal = -101  
  
                return  
            end  
  
              SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0),  
                                Replace( Replace(Replace(Replace( Sysutcdatetime(), '-', ''), ' ', ''), ':', ''), '.', '')) ) + '.PDF'  
                 
  
          BEGIN try  
              BEGIN TRANSACTION  
  
              /************************************* TRANSACTION *************************************/  
        
     INSERT INTO dbo.Inquiry WITH ( rowlock )  
                          (Inquiry_No,  
                           Inquiry_Date,  
                           BranchMaster_Id,  
                           Project_Name,  
                           Project_Address,  
                           Country_Id,  
                           State_Id,  
                           City_Id,  
                           Project_Incharge_Id,  
                           Site_Engineer_Id,  
                           Contact_Person,  
                           Contact_No,  
                           Inquiry_StatusId,  
                           Reference,  
                           Attachments_Name,  
                           Remark,  
                           MAC_Add,  
                           Entry_User,  
                           Entry_Date,  
                           Upd_User,  
                           Year_Id,  
                           Branch_ID,  
                           Project_Reference,  
                           InquirySource_Id,  
                           InquiryType_Id,  
                           Architect_Dtl_Id,  
                           Cust_Id,  
                           Aprox_QTN_Val,  
                           Is_AutoNo,  
                           GlassType,  
                           Coating,  
                           FlyMesh,  
                           WindowSystem)  
              VALUES      (@Inquiry_No,  
                           @Inquiry_Date,  
                           @BranchMaster_Id,  
                           @Project_Name,  
                           @Project_Address,  
                           @Country_Id,  
                           @State_Id,  
                           @City_Id,  
                           @Project_Incharge_Id,  
                           @Site_Engineer_Id,  
                           @Contact_Person,  
                           @Contact_No,  
                           @Inquiry_StatusId,  
                           @Reference,  
                           @_ImageName,  
                           @Remark,  
                           @MAC_Add,  
                           @Entry_User,  
                           dbo.Get_sysdate(),  
                           0,  
                           @Year_Id,  
                           @Branch_ID,  
                           @Project_Reference,  
                           @InquirySource_Id,  
                           @InquiryType_Id,  
                           @Architect_Dtl_Id,  
                           @Cust_Id,  
                           @Aprox_QTN_Val,  
                           @_Is_AutoNo,  
                           @GlassType,  
                           @Coating,  
                           @FlyMesh,  
                           @WindowSystem )  
  
              --INSERT INTO dbo.inquiry WITH ( rowlock )                
              --            (BranchMaster_Id ,project_id ,project_incharge_id ,site_engineer_id ,cust_id ,contact_person ,contact_no ,inquiry_statusid ,reference ,attachments_name ,remark ,mac_add ,entry_user ,                
              --entry_date ,upd_user ,upd_date ,year_id ,branch_id) VALUES                
              --            (                
              --                        @BranchMaster_Id,                
              --                        @Project_Id,                
              --                        @Project_Incharge_Id,                
              --                        @Site_Engineer_Id,                
              --                        @Cust_Id,                
              --                        @Contact_Person,                
              --                        @Contact_No,                
              --                        @Inquiry_StatusId,                
              --                        @Reference,                
              --                        '',                
              --                        @Remark,                
              --                        @MAC_Add,                
              --                        @Entry_User,                
              --                        dbo.Get_sysdate(),                
              --                        @Upd_User,                
              --                        '1900-01-01',                
              --                        @Year_Id,                
              --                        @Branch_ID                
              --     )                
                
     SET @RetVal = Scope_identity()  
              SET @RetMsg = 'Inquiry No [  ' + convert(VARCHAR(50), @Inquiry_No) + '  ] Generate Successfully.'  
  
     update Visitors  WITH ( rowlock ) set Inquiry_Id = @RetVal where VisitorsId = @VisitorsId  
  
              --UPDATE inquiry WITH(rowlock)  
              --SET    attachments_name = @_ImageName  
              --WHERE  inquiry_id = @RetVal  
  
              IF @@ERROR <> 0  
                BEGIN  
                    SET @RetVal = 0 -- 0 IS FOR ERROR                
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
                    SET @_ImageName = ''  
                END  
  
              COMMIT  
          /************************************* COMMIT *************************************/  
          END try  
  
          BEGIN catch  
              ROLLBACK  
  
              /************************************* ROLLBACK *************************************/  
              SET @RetVal = -405 -- 0 IS FOR ERROR                
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
              SET @_ImageName = ''  
          END catch  
      END  
    ELSE  
      BEGIN  
          IF NOT EXISTS(SELECT 1  
                        FROM   Inquiry WITH (nolock)  
                        WHERE  Inquiry_Id = @Inquiry_Id)  
            BEGIN  
                SET @RetVal = -12  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                      
                SET @RetMsg = 'This Inquiry Is Already Been Deleted By Another User.'  
                SET @_ImageName = ''  
  
                RETURN  
            END  
  
          If Exists (select 1  
                     from   Inquiry with(rowlock)  
                     where  Inquiry_No = @Inquiry_No  
                            AND Inquiry_Id <> @Inquiry_Id)  
            begin  
                SET @RetMsg = 'Inquiry No Already Exists , Please Enter New Inquiry No.'  
                SET @_ImageName = ''  
                SET @RetVal = -101  
  
                return  
            end  
  
          UPDATE dbo.Inquiry WITH (rowlock)  
          SET    BranchMaster_Id = @BranchMaster_Id,  
                 Project_Name = @Project_Name,  
                 Project_Address = @Project_Address,  
                 Country_Id = @Country_Id,  
                 State_Id = @State_Id,  
                 City_Id = @City_Id,  
                 Inquiry_Date = @Inquiry_Date,  
                 --Project_Id =@Project_Id,              
                 Project_Incharge_Id = @Project_Incharge_Id,  
                 Site_Engineer_Id = @Site_Engineer_Id,  
                 --Cust_Id = @Cust_Id,              
                 Contact_Person = @Contact_Person,  
                 Contact_No = @Contact_No,  
                 Inquiry_StatusId = @Inquiry_StatusId,  
                 Reference = @Reference,  
                 Project_Reference = @Project_Reference,  
                 InquirySource_Id = @InquirySource_Id,  
                 InquiryType_Id = @InquiryType_Id,  
                 Architect_Dtl_Id = @Architect_Dtl_Id,  
                 Cust_Id = @Cust_Id,  
                 Aprox_QTN_Val = @Aprox_QTN_Val,  
                 Remark = @Remark,  
                 Upd_User = @Upd_User,  
                 Upd_Date = dbo.Get_sysdate(),  
                 GlassType = @GlassType,  
                 Coating = @Coating,  
                 FlyMesh = @FlyMesh,  
                 WindowSystem = @WindowSystem  
          WHERE  Inquiry_Id = @Inquiry_Id  
  
          IF @@ERROR = 0  
            BEGIN  
                SET @RetVal = 1  
                -- 1 IS FOR SUCCESSFULLY EXECUTED                           
                SET @RetMsg ='Inquiry Details Update Successfully.'  
                SET @_ImageName = ''  
            END  
          ELSE  
            BEGIN  
                SET @RetVal = -1  
                -- 0 WHEN AN ERROR HAS OCCURED                        
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
                SET @_ImageName = ''  
            END  
      END 
GO


