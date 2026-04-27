USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[StockView_Limit_Upd]    Script Date: 27-04-2026 15:04:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[StockView_Limit_Upd]            
                                      @Item_Id         INT,                     
                                      @Length NUMERIC(18, 3),            
                                      @limit     NUMERIC(18, 3),   
                                      @RetVal          INT = 0 out,            
                                      @RetMsg          VARCHAR(max) = '' out            
AS            
    SET nocount ON            
            
        BEGIN            
          --IF NOT EXISTS(SELECT 1            
          --              FROM   m_item WITH (nolock)            
          --              WHERE  item_id = @Item_Id)            
          --  BEGIN            
          --      SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                         
          --      SET @RetMsg = 'This Description Is Already Been Deleted By Another User !!!'            
          --      RETURN            
          --  END            
            
			update StockView  WITH (rowlock)  set Stk_Limit = @limit where Item_Id = @Item_Id and  Length =@Length

          IF @@ERROR = 0            
            BEGIN            
                SET @RetVal = 1            
                -- 1 IS FOR SUCCESSFULLY EXECUTED                                      
                SET @RetMsg ='Description Details Update Successfully.'            
            END            
          ELSE            
            BEGIN            
                SET @RetVal = 0            
                -- 0 WHEN AN ERROR HAS OCCURED                                     
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'            
            END            
      END 
GO


