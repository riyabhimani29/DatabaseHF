USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Visitors_insert]    Script Date: 27-04-2026 14:50:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_Visitors_insert] @VisitorsId      INT,
										--@Inquiry_Id INT,
                                         --@VisitorsNo      VARCHAR(500),    
                                         @VisitorsDate    DATE,    
                                         @VisitorsName    VARCHAR(500),    
                                         @VisitorsContact VARCHAR(500),    
                                         @VisitorsMail    VARCHAR(500),    
                                         @VisitorsAddress VARCHAR(500),                                            
                                         @Remark          VARCHAR(500),    
                                         @MAC_Add         VARCHAR(500),    
                                         @Entry_User      INT,    
                                         @Upd_User        INT,    
                                         @Year_Id         INT,    
                                         @Branch_ID       INT,     
                                         @Enter_By       INT,  
                                         @RetVal          INT = 0 out,    
                                         @RetMsg          VARCHAR(max) = '' out,    
                                         @_ImageName      VARCHAR(max) = '' out    
AS    
    SET nocount ON    
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))    
    
    IF ( @VisitorsId = 0 )    
      BEGIN    
        --  declare @_Is_AutoNo as BIT = 0    
    
          BEGIN try    
  BEGIN TRANSACTION    
    
              /************************************* TRANSACTION *************************************/    
              INSERT INTO dbo.Visitors WITH ( rowlock )    
                          (--[VisitorsNo],    
                          --[Inquiry_Id],
                           [VisitorsDate],    
                           [VisitorsName],    
                           [VisitorsContact],    
                           [VisitorsMail],    
                           [VisitorsAddress],    
                           --[Reference],    
                           --[ArchitectName],    
                           --[FirmName],    
                           --[ContactNo],    
                           --[MailId],    
                           --[InquiryFor],    
                           --[TotalSqFt],    
                           --[InitialQuote],    
                           --[Stage],    
                           --[RequirementFor],    
                           --[WindowSystem],    
                           --[GlassType],    
                           --[Coating],    
                           --[FlyMesh],    
                           --[Is_AutoNo],    
                           [Remark],    
                           [MAC_Add],    
                           [Entry_User],    
                           [Entry_Date],    
                           [Upd_User],    
                           [Upd_Date],    
                           [Year_Id],    
                           [Branch_ID],  
         Enter_By)    
              VALUES      (--@VisitorsNo, 
              --@Inquiry_Id,
                           @VisitorsDate,    
                           @VisitorsName,    
                           @VisitorsContact,    
                           @VisitorsMail,    
                           @VisitorsAddress,    
                           --@Reference,    
                           --@ArchitectName,    
                           --@FirmName,    
                           --@ContactNo,    
                           --@MailId,    
                           --@InquiryFor,    
                           --@TotalSqFt,    
                           --@InitialQuote,    
                           --@Stage,    
                           --@RequirementFor,    
                           --@WindowSystem,    
                           --@GlassType,    
                           --@Coating,    
                           --@FlyMesh,    
                           --@_Is_AutoNo,    
                           @Remark,    
                           @MAC_Add,    
                           @Entry_User,    
                           dbo.Get_Sysdate(),    
                           '',    
                           '1900-01-01',    
                           @Year_Id,    
                           @Branch_ID,  
         @Enter_By)    
    
              SET @RetVal = Scope_identity()    
                           SET @RetMsg = 'Details added.'    
             --SET @RetMsg = 'Visitors No [ INQ' + convert(VARCHAR(50), @VisitorsNo) + '  ] Generate Successfully.'    
              SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0),    
                                Replace(    
                                Replace(Replace(Replace(    
                                Sysutcdatetime(), '-', ''), ' ', ''), ':', ''),    
                                '.',    
                                ''))    
                                +    
                                @RetVal)    
                                + '.PDF'    
    
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
                        FROM   Visitors WITH (nolock)    
                        WHERE  VisitorsId = @VisitorsId)    
            BEGIN    
                SET @RetVal = -12    
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                        
                SET @RetMsg = 'This Visitors Is Already Been Deleted By Another User.'    
                SET @_ImageName = ''    
    
                RETURN    
            END
    
          UPDATE dbo.Visitors WITH (rowlock)    
          SET    VisitorsName = @VisitorsName,    
                 VisitorsContact = @VisitorsContact,  
                 VisitorsDate= @VisitorsDate,
                 VisitorsMail = @VisitorsMail,    
                 VisitorsAddress = @VisitorsAddress,    
                 --Reference = @Reference,    
                 --ArchitectName = @ArchitectName,    
                 --FirmName = @FirmName,    
                 --ContactNo = @ContactNo,    
                 --MailId = @MailId,    
                 --InquiryFor = @InquiryFor,    
                 --TotalSqFt = @TotalSqFt,    
                 --InitialQuote = @InitialQuote,    
                 --Stage = @Stage,    
                 --RequirementFor = @RequirementFor,    
                 --WindowSystem = @WindowSystem,    
                 --GlassType = @GlassType,    
                 --Coating = @Coating,    
                 --FlyMesh = @FlyMesh,    
                 Remark = @Remark,  
				 Enter_By = @Enter_By,
                 Upd_User = @Upd_User,    
                 Upd_Date = dbo.Get_sysdate()    
          WHERE  VisitorsId = @VisitorsId    
    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = @VisitorsId -- 1 IS FOR SUCCESSFULLY EXECUTED                             
                SET @RetMsg ='Details Update.'    
                SET @_ImageName = ''    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED                          
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
                SET @_ImageName = ''    
            END    
      END   
GO


