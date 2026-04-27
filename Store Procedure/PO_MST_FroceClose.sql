USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_FroceClose]    Script Date: 27-04-2026 13:10:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                   
ALTER PROCEDURE [dbo].[PO_MST_FroceClose] @PO_Id    INT,    
                                            @CloseReason   VARCHAR(500),  
                                            @MAC_Add   VARCHAR(500),  
                                            @Entry_User INT,  
                                            @Upd_User INT,  
                                            @Year_Id INT,  
                                            @Branch_ID INT,  
                                            @RetVal   INT = 0 out,  
                                            @RetMsg   VARCHAR(max) = '' out  
AS  
    SET nocount ON  
  
    UPDATE PO_MST WITH (rowlock)  
    SET    CloseReason = @CloseReason, 
			PO_Type = 'Q' , 
           Upd_User = @Upd_User,  
           Upd_Date = dbo.Get_sysdate()   
    WHERE  PO_MST.PO_Id = @PO_Id  
           AND PO_MST.PO_Type <> 'C' 
		   and  PO_MST.PO_Type ='F'
  
    IF @@ERROR = 0  
      BEGIN  
          SET @RetMsg ='Raise PO Close Successfully.'  
          SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED    
      END  
    ELSE  
      BEGIN  
          SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
          SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED    
      END 
GO


