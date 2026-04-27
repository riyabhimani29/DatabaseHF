USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Panel_Delete]    Script Date: 27-04-2026 13:09:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Panel_Delete]
@Id int ,
@_Panel VARCHAR(max),
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT 

AS

SET NOCOUNT ON
IF @_Panel = '_Fab'
BEGIN
IF NOT EXISTS(Select 1 from Fabrication_Panel With (NOLOCK) WHERE Fab_Id=@Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
DELETE Fabrication_Panel WHERE Fab_Id=@Id
END
IF @_Panel = '_Dis'
BEGIN
IF NOT EXISTS(Select 1 from Panel_Dispatch With (NOLOCK) WHERE Dis_Id=@Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
DELETE Panel_Dispatch WHERE Dis_Id=@Id
END
IF @_Panel = '_Asb'
BEGIN
IF NOT EXISTS(Select 1 from Assemble_Panel With (NOLOCK) WHERE Asmbl_Id=@Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
DELETE Assemble_Panel WHERE Asmbl_Id=@Id
END
IF @_Panel = '_Glz'
BEGIN
IF NOT EXISTS(Select 1 from Glazing_Panel With (NOLOCK) WHERE Glaz_Id=@Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
DELETE Glazing_Panel WHERE Glaz_Id=@Id
END
IF @_Panel = '_Ins'
BEGIN
IF NOT EXISTS(Select 1 from Installation_Panel With (NOLOCK) WHERE Instl_Id=@Id)
BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
END
DELETE Installation_Panel WHERE Instl_Id=@Id
END

IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


