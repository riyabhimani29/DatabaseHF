USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DC_Mst_Delete]    Script Date: 27-04-2026 11:20:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

         
ALTER PROCEDURE [dbo].[DC_Mst_Delete]    @DC_Id             INT,                  
                                          @CODC_Type            VARCHAR(500),                
                                          @Remark            VARCHAR(500),                    
                                          @MAC_Add           VARCHAR(500),                    
                                          @Entry_User        INT,                    
                                          @Upd_User          INT,                    
                                          @Year_Id           INT,                    
                                          @Branch_ID         INT,                          
                                          @RetVal            INT = 0 out,                    
                                          @RetMsg            VARCHAR(max) = ''out                       
AS                    
    SET nocount ON                    
          
   declare @DC_No varchar(10)=''    
    
  BEGIN              
      BEGIN try              
          BEGIN TRANSACTION              
              
          /************************************* TRANSACTION *************************************/              
    -- ??????? ?? ?? ???? ?????? ??? ?? ????? ??? ??     
    
    update DC_Mst set CODC_Type = @CODC_Type /*'Del' */where  DC_Id = @DC_Id    
  
--select * from DC_Mst where DC_Id = @DC_Id    
--select * from DC_Dtl where DC_Id = @DC_Id    
         
   IF @@ERROR =  0      
    BEGIN      
    SET @RetVal = @DC_Id -- 1 IS FOR SUCCESSFULLY EXECUTED           
    SET @RetMsg ='Record Deleted Successfully. '               
    End      
    ELSE      
    BEGIN      
    SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED           
      SET @RetMsg ='Failed to Delete Data. '               
    End    
         
                
          COMMIT              
          /************************************* COMMIT *************************************/        
    
          IF @@ERROR <> 0              
            BEGIN              
                SET @RetVal = 0 -- 0 IS FOR ERROR                                                             
                SET @RetMsg ='Error Occurred - ' + Error_message() + ' '              
            END         
      END try              
              
      BEGIN catch              
          ROLLBACK                       
          /************************************* ROLLBACK *************************************/              
          SET @RetVal = -405              
          -- 0 IS FOR ERROR                                                              
          SET @RetMsg ='Error Occurred ' + Error_message() + ''              
      END catch              
     
  END              
GO


