USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_ContactPerson_Delete]    Script Date: 27-04-2026 14:40:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_ContactPerson_Delete]
    @ContactId INT,
    @Entry_User INT,
    @Upd_User INT,
    @RetVal INT = 0 OUT,
    @RetMsg VARCHAR(MAX) = '' OUT
AS
BEGIN
    SET NOCOUNT ON;
	IF NOT EXISTS(SELECT * FROM Inquiry_Contacts WHERE ContactId = @ContactId)
	BEGIN
	  SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END
	
    IF EXISTS(SELECT * 
              FROM Sales_Inquiry_Visit_Dtl 
              WHERE Visitor_Id LIKE '%' + CAST(@ContactId AS VARCHAR) + '%' 
                 OR Architect_Id LIKE '%' + CAST(@ContactId AS VARCHAR) + '%')
    BEGIN
        SET @RetVal = 1; -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
        SET @RetMsg = 'Can Not delete because record Exist On PO Table.';         
        RETURN;
    END

    DELETE FROM Inquiry_Contacts
    WHERE ContactId = @ContactId;
	SET @RetMsg = 'Successfully Deleted.'
    IF @@ERROR = 0
    BEGIN
        SET @RetVal = 1; -- 1 IS FOR SUCCESSFULLY EXECUTED
    END
    ELSE
    BEGIN
        SET @RetVal = 0; -- 0 WHEN AN ERROR HAS OCCURRED
    END
END
GO


