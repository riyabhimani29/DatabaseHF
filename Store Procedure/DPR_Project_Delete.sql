USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Project_Delete]    Script Date: 27-04-2026 11:26:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Project_Delete]
@Project_Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON

IF NOT EXISTS(Select 1 from DPR_Project With (NOLOCK) WHERE Project_Id=@Project_Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END

  IF EXISTS ( SELECT  1  FROM dbo.DPR WITH ( NOLOCK ) WHERE   Project_Id = @Project_Id )     
        BEGIN        
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On DPR Table.'              
            RETURN        
        END  

       DELETE FROM DPR_Project
       WHERE Project_Id = @Project_Id
		
		DELETE FROM DPR_Project_PanelTypes
		WHERE Project_Id = @Project_Id

IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End

GO


