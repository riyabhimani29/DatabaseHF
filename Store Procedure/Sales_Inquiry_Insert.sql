USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Inquiry_Insert]    Script Date: 27-04-2026 14:45:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_Inquiry_Insert]
--	@VisitorsId      INT,    
--    @VisitorsDate    DATE,    
 --   @VisitorsName    VARCHAR(500),    
--    @VisitorsContact VARCHAR(500),    
--    @VisitorsMail    VARCHAR(500),    
--    @VisitorsAddress VARCHAR(500),         
    @Inquiry_StatusId INT,
 --   @Inquiry_No          VARCHAR(500), 
    @Inquiry_For         INT,
--    @Inquiry_Date        DATE,  
    @Inquiry_Id          INT,  
    @BranchMaster_Id     INT,          
    @Project_Incharge_Id INT,  
    @Site_Engineer_Id    INT,  
    @Remark              VARCHAR(500),  
    @InquirySource_Id    INT,  
    @InquiryType_Id      INT,  
    @Architect_Dtl_Id    INT,
    @Architect_Contact_Id    INT,  
    @Site_Id    INT,  
    @Site_Contact_Id    INT,  
    @GlassType           VARCHAR(500),  
    @Stage           VARCHAR(500),  
    @System          VARCHAR(MAX),
    @Coating             VARCHAR(500),    
    @Reference             VARCHAR(500),
    @Color               VARCHAR(500),  
    @FlyMesh             VARCHAR(500),  
    @WindowSystem        VARCHAR(500),              
    @MAC_Add             VARCHAR(500),  
    @Entry_User          INT,  
    @Upd_User            INT,  
    @Year_Id             INT,  
    @Branch_ID           INT,  
    @ShowRoomVisitDtl AS dbo.Sales_ShowRoomVisit READONLY,
    @DtlFollowUpsVtsPara  AS dbo.Sales_FollowUp READONLY,
    @RetVal              INT = 0 OUT,  
    @RetMsg              VARCHAR(MAX) = '' OUT,  
    @_ImageName          VARCHAR(MAX) = '' OUT  
AS  
BEGIN
    SET NOCOUNT ON;  
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT(DATE, dbo.Get_sysdate()));

    DECLARE 
    		@Inquiry_No as INT = 0,
    		--showroom visit variables
    		@_Id AS INT = 0,      
            @_Enter_By AS INT = 0,      
            @_Visitor_Id AS VARCHAR(MAX) = '', 
            @_Architect_Id AS VARCHAR(MAX) = '', 
            @_Visitor_Date AS VARCHAR(MAX) = '',       
            @_ShowRoom_Visit AS VARCHAR(5555) = '',
            @_Purpose_Of_Visit AS VARCHAR(5555) = '',
            @_Documentation AS VARCHAR(5555) = '',
            @_Remark AS VARCHAR(500) = '',
			--follow up variables
			@_FId AS INT = 0,      
            @_FollowUp_Type AS INT = 0,      
            @_FollowUp_By AS INT = 0, 
            @_Contact_Person as INT = 0,
            @_FollowUp_Status as INT = 0,
            @_FollowUp_Status_Date AS VARCHAR(MAX) = '',       
            @_Description AS VARCHAR(5555) = '';
			
     	
 IF ( @Inquiry_Id = 0 )  
      BEGIN  
  
          if ( @Inquiry_No = 0 )  
            begin  
  DECLARE @FinancialYear INT
  SET @FinancialYear = 
            CASE 
                WHEN MONTH(dbo.Get_sysdate()) >= 4 
                THEN YEAR(dbo.Get_sysdate())  
                ELSE YEAR(dbo.Get_sysdate()) - 1
            END
              IF EXISTS (
            SELECT 1  
            FROM Inquiry  
            WHERE CASE 
                    WHEN MONTH(Inquiry_Date) >= 4 
                    THEN YEAR(Inquiry_Date) 
                    ELSE YEAR(Inquiry_Date) - 1 
                END = @FinancialYear
        )  
        BEGIN  
            SET @Inquiry_No = (
                SELECT ISNULL(MAX(CONVERT(NUMERIC(18, 0), Inquiry_No)), 0) + 1  
                FROM Inquiry WITH(NOLOCK)  
                WHERE CASE 
                        WHEN MONTH(Inquiry_Date) >= 4 
                        THEN YEAR(Inquiry_Date)  
                        ELSE YEAR(Inquiry_Date) - 1
                    END = @FinancialYear
            )  
        END  
        ELSE  
        BEGIN  
            -- Generate the starting number for the financial year (e.g., 2500001 for FY 2025)
            SET @Inquiry_No = CONVERT(NUMERIC(12, 0), CONVERT(VARCHAR(2), @FinancialYear % 100) + '00001')  
        END
            end  
  END
 
    IF (@Inquiry_Id = 0)  
    BEGIN  
        DECLARE @_Is_AutoNo AS BIT = 0; 

        BEGIN TRY  
            BEGIN TRANSACTION;  

            /************************************* TRANSACTION *************************************/  

            INSERT INTO dbo.Inquiry WITH (ROWLOCK)  
                (Inquiry_No,  
                 Inquiry_Date,  
                 BranchMaster_Id,  
                 Project_Incharge_Id,  
                 Site_Engineer_Id,  
                 Remark,  
                 MAC_Add,  
                 Entry_User,  
                 Entry_Date,  
                 Upd_User,  
                 Year_Id,  
                 Branch_ID,  
                 InquirySource_Id,  
                 InquiryType_Id,  
                 Architect_Dtl_Id,  
                 Architect_Contact_Id,
                 Site_Id,
                 Site_Contact_Id,
                 Is_AutoNo,  
                 GlassType,  
                 Coating,  
                 FlyMesh,  
                 Color,
                 Stage,
                 System,
                 Inquiry_StatusId,
                 Inquiry_For,
                 Reference,
                 WindowSystem)  
            VALUES  
                (@Inquiry_No,  
                 dbo.Get_sysdate(),  
                 @BranchMaster_Id, 
                 @Project_Incharge_Id,  
                 @Site_Engineer_Id,  
                 @Remark,  
                 @MAC_Add,  
                 @Entry_User,  
                 dbo.Get_sysdate(),  
                 0,  
                 @Year_Id,  
                 @Branch_ID,  
                 @InquirySource_Id,  
                 @InquiryType_Id,  
                 @Architect_Dtl_Id,  
                 @Architect_Contact_Id,
                 @Site_Id,
                 @Site_Contact_Id,
                 @_Is_AutoNo,  
                 @GlassType,  
                 @Coating,  
                 @FlyMesh,  
                 @Color,
                 @Stage,
                 @System,
                 @Inquiry_StatusId,
                 @Inquiry_For,
                 @Reference,
                 @WindowSystem);  
                 
            -- Correctly set @RetVal to the identity value
            SET @RetVal = SCOPE_IDENTITY(); 

            IF @RetVal IS NULL OR @RetVal = 0  
            BEGIN  
                SET @RetVal = -103;  
                SET @RetMsg = 'Failed to retrieve the new Inquiry ID.';  
                SET @_ImageName = '';  
                ROLLBACK;  
                RETURN;  
            END

            SET @RetMsg = 'Inquiry No [  ' + CONVERT(VARCHAR(50), @Inquiry_No) + '  ] Generated Successfully.';  
			
         
            -- Loop through the cursor to insert into Sales_Inquiry_Visit_Dtl
            
       --    SET @VisitorsId = SCOPE_IDENTITY();
            
            DECLARE visit_cur CURSOR FOR      
                SELECT Id,
                       Enter_By,      
                       Visitor_Id, 
                       Architect_Id,
                       Visitor_Date,
                       ShowRoom_Visit,
                       Purpose_Of_Visit,
                       Documentation,
                       Remark
                FROM @ShowRoomVisitDtl;      
      
            OPEN visit_cur;      
      
            FETCH NEXT FROM visit_cur INTO @_Id, @_Enter_By, @_Visitor_Id, 
            @_Architect_Id,@_Visitor_Date, @_ShowRoom_Visit, @_Purpose_Of_Visit, @_Documentation, @_Remark;
      
            WHILE @@FETCH_STATUS = 0      
            BEGIN      
                INSERT INTO Sales_Inquiry_Visit_Dtl WITH (ROWLOCK)      
                    (Inquiry_Id,  
                     Enter_By,
                     Visitor_Id,      
                     Architect_Id,
                     Visitor_Date,
                     ShowRoom_Visit,
                     Purpose_Of_Visit,
                     Documentation,
                     Remark)      
                VALUES      
                    (@RetVal,   
                     @_Enter_By,
                     @_Visitor_Id,   
                     @_Architect_Id,
                     @_Visitor_Date,
                     @_ShowRoom_Visit,      
                     @_Purpose_Of_Visit,      
                     @_Documentation,      
                     @_Remark);      

                FETCH NEXT FROM visit_cur INTO @_Id, @_Enter_By, @_Visitor_Id,@_Architect_Id, @_Visitor_Date, @_ShowRoom_Visit, @_Purpose_Of_Visit, @_Documentation, @_Remark; 
            END      
      
            CLOSE visit_cur;      
            DEALLOCATE visit_cur;      
      
            COMMIT;  
            /************************************* COMMIT *************************************/  
        END TRY  
        BEGIN CATCH  
            ROLLBACK;  
            /************************************* ROLLBACK *************************************/  
            SET @RetVal = -405; -- 0 IS FOR ERROR                
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';  
            SET @_ImageName = '';  
        END CATCH  
    END  
    ELSE  
    BEGIN  
        IF NOT EXISTS (SELECT 1  
                       FROM Inquiry WITH (NOLOCK)  
                       WHERE Inquiry_Id = @Inquiry_Id)  
        BEGIN  
            SET @RetVal = -12;  
            -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                      
            SET @RetMsg = 'This Inquiry Has Already Been Deleted By Another User.';  
            SET @_ImageName = '';  
            RETURN;  
        END  

        BEGIN TRY  
            BEGIN TRANSACTION;  

            UPDATE dbo.Inquiry WITH (ROWLOCK)  
            SET BranchMaster_Id = @BranchMaster_Id,  
                --Inquiry_Date = @Inquiry_Date,  
                Project_Incharge_Id = @Project_Incharge_Id,  
                Site_Engineer_Id = @Site_Engineer_Id,  
                InquirySource_Id = @InquirySource_Id,  
                Inquiry_StatusId = @Inquiry_StatusId,
                InquiryType_Id = @InquiryType_Id,  
                --Inquiry_For = @Inquiry_For,
                Architect_Dtl_Id = @Architect_Dtl_Id, 
                Architect_Contact_Id = @Architect_Contact_Id,
                Site_Id = @Site_Id,
                Site_Contact_Id = @Site_Contact_Id,
                Remark = @Remark,  
                Upd_User = @Upd_User,  
                Upd_Date = dbo.Get_sysdate(),  
                GlassType = @GlassType,  
                Coating = @Coating,  
                FlyMesh = @FlyMesh,  
                Color = @Color,
                Stage = @Stage,
                System = @System,
                WindowSystem = @WindowSystem  ,
                Reference = @Reference,
                Inquiry_For = @Inquiry_For
            WHERE Inquiry_Id = @Inquiry_Id;  

            IF @@ERROR = 0  
            BEGIN  
                SET @RetVal = 1;  
                -- 1 IS FOR SUCCESSFULLY EXECUTED                           
                SET @RetMsg = 'Inquiry Details Updated Successfully.';  
                SET @_ImageName = '';  
				--for the showroom visit
                DECLARE visit_cur CURSOR FOR      
                    SELECT Id,
                           Enter_By,      
                           Visitor_Id,     
                           Architect_Id,
                           Visitor_Date,
                           ShowRoom_Visit,
                           Purpose_Of_Visit,
                           Documentation,
                           Remark
                    FROM @ShowRoomVisitDtl;      
        IF (@Inquiry_StatusId = 334)
        BEGIN
        UPDATE Inquiry SET Quotation_Date = dbo.Get_sysdate() WHERE Inquiry_Id = @Inquiry_Id;
        END
                OPEN visit_cur;      
        
                FETCH NEXT FROM visit_cur INTO @_Id, @_Enter_By, @_Visitor_Id,@_Architect_Id, @_Visitor_Date, @_ShowRoom_Visit, @_Purpose_Of_Visit, @_Documentation, @_Remark;
        
                WHILE @@FETCH_STATUS = 0      
                BEGIN      
                    IF (@_Id = 0)      
                    BEGIN      
                        INSERT INTO Sales_Inquiry_Visit_Dtl WITH (ROWLOCK)      
                            (Inquiry_Id,  
                             Enter_By,
                             Visitor_Id,      
                             Architect_Id,
                             Visitor_Date,
                             ShowRoom_Visit,
                             Purpose_Of_Visit,
                             Documentation,
                             Remark)      
                        VALUES      
                            (@Inquiry_Id,   
                             @_Enter_By,
                             @_Visitor_Id,   
                             @_Architect_Id,
                             @_Visitor_Date,
                             @_ShowRoom_Visit,      
                             @_Purpose_Of_Visit,      
                             @_Documentation,      
                             @_Remark);      
                    END
                    ELSE
                    BEGIN
                        UPDATE Sales_Inquiry_Visit_Dtl
                        SET Enter_By = @_Enter_By,
                            Visitor_Id = @_Visitor_Id,   
                            Architect_Id = @_Architect_Id,
                            Visitor_Date = @_Visitor_Date,
                            ShowRoom_Visit = @_ShowRoom_Visit,      
                            Purpose_Of_Visit = @_Purpose_Of_Visit,      
                            Documentation = @_Documentation,      
                            Remark = @_Remark
                        WHERE Id = @_Id;
                    END

                    FETCH NEXT FROM visit_cur INTO @_Id, @_Enter_By, @_Visitor_Id,@_Architect_Id, @_Visitor_Date, @_ShowRoom_Visit, @_Purpose_Of_Visit, @_Documentation, @_Remark;
                END      
        
                CLOSE visit_cur;      
                DEALLOCATE visit_cur;      
			
                -- for the followups
                DECLARE follow_cur CURSOR FOR      
                    SELECT Id,
                           FollowUp_Type,      
                           FollowUp_By,      
                           Contact_Person,
                           FollowUp_Status,
                           FollowUp_Status_Date,
                           Description
                    FROM @DtlFollowUpsVtsPara ;      
        
                OPEN follow_cur;      
        
                FETCH NEXT FROM follow_cur INTO @_FId, @_FollowUp_Type, @_FollowUp_By, @_Contact_Person, @_FollowUp_Status, @_FollowUp_Status_Date, @_Description;
        
                WHILE @@FETCH_STATUS = 0      
                BEGIN      
                    IF (@_FId = 0)      
                    BEGIN      
                        INSERT INTO Sales_Inquiry_FollowUps WITH (ROWLOCK)      
                            (Inquiry_Id,  
                            FollowUp_Type, FollowUp_By, Contact_Person, FollowUp_Status, FollowUp_Status_Date, Description)      
                        VALUES      
                            (@Inquiry_Id,@_FollowUp_Type, @_FollowUp_By, @_Contact_Person, @_FollowUp_Status, @_FollowUp_Status_Date, @_Description);      
                    END
                    ELSE
                    BEGIN
                        UPDATE Sales_Inquiry_FollowUps
                        SET FollowUp_Type = @_FollowUp_Type,
                            FollowUp_By = @_FollowUp_By,   
                            Contact_Person = @_Contact_Person,
                            FollowUp_Status = @_FollowUp_Status,      
                            FollowUp_Status_Date = @_FollowUp_Status_Date,      
                            Description = @_Description
                        WHERE Id = @_FId;
                    END

                FETCH NEXT FROM follow_cur INTO @_FId, @_FollowUp_Type, @_FollowUp_By, @_Contact_Person, @_FollowUp_Status, @_FollowUp_Status_Date, @_Description;
                END      
        
                CLOSE follow_cur;      
                DEALLOCATE follow_cur;   
            END  
            ELSE  
            BEGIN  
                SET @RetVal = -1;  
                -- 0 WHEN AN ERROR HAS OCCURED                        
                SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';  
                SET @_ImageName = '';  
            END  

            COMMIT;  
        END TRY  
        BEGIN CATCH  
            ROLLBACK;  
            SET @RetVal = -405;  
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';  
            SET @_ImageName = '';  
        END CATCH  
    END  
END
GO


