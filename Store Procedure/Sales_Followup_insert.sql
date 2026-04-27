USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Followup_insert]    Script Date: 27-04-2026 14:42:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_Followup_insert] 
										@Id INT,
										@Inquiry_Id      INT,
										@Contact_Person INT,
										@FollowUp_By INT,
										@FollowUp_Type INT,
                                         @FollowUp_Status_Date    DATE,    
                                         @FollowUp_Status INT,
                                         @Description    VARCHAR(500),                                        
                                       --  @Remark          VARCHAR(500),
                                         @RetVal          INT = 0 out,    
                                         @RetMsg          VARCHAR(max) = '' out--,    
                                     --    @_ImageName      VARCHAR(max) = '' out    
AS    
    SET nocount ON    
    
    IF ( @Id = 0 )    
      BEGIN    
        --  declare @_Is_AutoNo as BIT = 0    
    
          BEGIN try    
  BEGIN TRANSACTION    
    
              /************************************* TRANSACTION *************************************/    
              INSERT INTO dbo.Sales_Inquiry_FollowUps WITH ( rowlock )    
                          (--[VisitorsNo],    
                          Inquiry_Id,
                           Contact_Person,  
                           FollowUp_Status_Date,    
                           Description,
                           FollowUp_Type,    
                           FollowUp_By)    
              VALUES      (--@VisitorsNo, 
                           --@Visitor_Id,
                           @Inquiry_Id,
                           @Contact_Person,
                           @FollowUp_Status_Date,    
                           @Description,      
                           @FollowUp_Type,    
                           @FollowUp_By)    
    
              SET @RetVal = Scope_identity()    
                           SET @RetMsg = 'Details added.'
    
              IF @@ERROR <> 0    
                BEGIN    
                    SET @RetVal = 0 -- 0 IS FOR ERROR                  
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
             --       SET @_ImageName = ''    
                END    
    
              COMMIT    
          /************************************* COMMIT *************************************/    
          END try    
    
          BEGIN catch    
              ROLLBACK    
    
              /************************************* ROLLBACK *************************************/    
              SET @RetVal = -405 -- 0 IS FOR ERROR                  
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
      --        SET @_ImageName = ''    
          END catch    
      END    
    ELSE    
      BEGIN    
    
          UPDATE dbo.Sales_Inquiry_FollowUps WITH (rowlock)    
          SET   
          Inquiry_Id=@Inquiry_Id,
                           Contact_Person=@Contact_Person,
                           FollowUp_Status_Date=@FollowUp_Status_Date,    
                           Description=@Description,     
                           FollowUp_Type=@FollowUp_Type,    
                           FollowUp_By=@FollowUp_By,
                           FollowUp_Status=@FollowUp_Status
          WHERE  Id = @Id
    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = @Id -- 1 IS FOR SUCCESSFULLY EXECUTED                             
                SET @RetMsg ='Details Update.'    
              --  SET @_ImageName = ''    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED                          
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
               -- SET @_ImageName = ''    
            END    
      END   
GO


