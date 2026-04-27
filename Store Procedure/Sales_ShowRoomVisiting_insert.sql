USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_ShowRoomVisiting_insert]    Script Date: 27-04-2026 14:47:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_ShowRoomVisiting_insert] 
										@Id INT,
										@Visitor_Id      VARCHAR(500),
										@Architect_Id      VARCHAR(500),
										@Inquiry_Id INT,
                                         @Visitor_Date    DATE,    
                                         @Documentation    VARCHAR(500),    
                                         @Purpose_Of_Visit VARCHAR(500),    
                                         @Enter_By    VARCHAR(500),    
                                         @ShowRoom_Visit VARCHAR(500),                                            
                                         @Remark          VARCHAR(500),
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
              INSERT INTO dbo.Sales_Inquiry_Visit_Dtl WITH ( rowlock )    
                          (--[VisitorsNo],    
                          Visitor_Id,
                          Architect_Id,
                           [Inquiry_Id],
                           Visitor_Date,    
                           [Documentation],    
                           [Purpose_Of_Visit],    
                           [Enter_By],    
                           [ShowRoom_Visit],    
  
                           [Remark])    
              VALUES      (--@VisitorsNo, 
              @Visitor_Id,
              @Architect_Id,
                           @Inquiry_Id,
                           @Visitor_Date,    
                           @Documentation,    
                           @Purpose_Of_Visit,    
                           @Enter_By,    
                           @ShowRoom_Visit,    
 
                           @Remark)    
    
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
    
          UPDATE dbo.Sales_Inquiry_Visit_Dtl WITH (rowlock)    
          SET   
          Visitor_Id = @Visitor_Id,
          Architect_Id = @Architect_Id,
          Documentation = @Documentation,    
                 Purpose_Of_Visit = @Purpose_Of_Visit,  
                 Visitor_Date= @Visitor_Date,
                 Enter_By = @Enter_By,    
                 ShowRoom_Visit = @ShowRoom_Visit,    
      
                 Remark = @Remark   
          WHERE  Id = @Id
    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = 200 -- 1 IS FOR SUCCESSFULLY EXECUTED                             
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


