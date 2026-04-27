USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_FollowUp_Update]    Script Date: 27-04-2026 14:43:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                                    
ALTER PROCEDURE [dbo].[Sales_FollowUp_Update]              
@Id INT = 0
AS                                                                    
                                                                    
SET NOCOUNT ON                                   
      
      UPDATE Sales_Inquiry_FollowUps SET FollowUp_Status = 1 WHERE Id = @Id
GO


