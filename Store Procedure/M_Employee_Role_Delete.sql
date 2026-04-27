USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Role_Delete]    Script Date: 27-04-2026 11:59:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Employee_Role_Delete]
@Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT  

AS

SET NOCOUNT ON

	IF NOT EXISTS(Select 1 from M_Employee_Role With (NOLOCK) WHERE Id = @Id)
	BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END
	
		IF EXISTS (Select 1 from MaterialRequirement With (NOLOCK) WHERE Site_Engineer = @Id or Prepared_By = @Id or Project_Manager = @Id or Checked_By = @Id or Authorised_By = @Id)     
        BEGIN        
            SET @RetVal = -124 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On MR.'              
            RETURN        
        END

       DELETE FROM M_Employee_Role
       WHERE Id = @Id


IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


