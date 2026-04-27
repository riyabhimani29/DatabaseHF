USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Delete]    Script Date: 27-04-2026 11:22:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[DPR_Delete]
@DprId int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON

IF NOT EXISTS(Select 1 from DPR With (NOLOCK) WHERE Dpr_Id=@DprId)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
		DELETE FROM Release_Panel WHERE Dpr_Id = @DprId;
		DELETE from Assemble_Panel WHERE Dpr_Id = @DprId;
				DELETE from Fabrication_Panel WHERE Dpr_Id = @DprId;
		DELETE from Glazing_Panel WHERE Dpr_Id = @DprId;
		DELETE from Installation_Panel WHERE Dpr_Id = @DprId;
		DELETE from Panel_Dispatch WHERE Dpr_Id = @DprId;

       DELETE FROM DPR
       WHERE Dpr_Id = @DprId


IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


