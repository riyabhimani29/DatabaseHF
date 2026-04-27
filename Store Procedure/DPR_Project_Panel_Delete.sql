USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Project_Panel_Delete]    Script Date: 27-04-2026 11:28:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Project_Panel_Delete]
@DPR_Panel_Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON

IF NOT EXISTS(Select 1 from DPR_Project_PanelTypes With (NOLOCK) WHERE DPR_Panel_Id=@DPR_Panel_Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
		
		DELETE FROM DPR_Project_PanelTypes
		WHERE DPR_Panel_Id=@DPR_Panel_Id

IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


