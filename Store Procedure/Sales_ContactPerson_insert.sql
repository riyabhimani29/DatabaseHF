USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_ContactPerson_insert]    Script Date: 27-04-2026 14:41:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_ContactPerson_insert]  
    @ContactId INT,  
    @ContactName VARCHAR(500),  
    @ContactNumber VARCHAR(500),  
    @ContactMail VARCHAR(500),  
    @ContactType VARCHAR(500),  
    @Master_Id VARCHAR(500),
    @Entry_User INT,   
    @Upd_User INT,   
    @RetVal INT = 0 OUT,    
    @RetMsg VARCHAR(MAX) = '' OUT   
AS  
BEGIN
    SET NOCOUNT ON;

    IF (@ContactId = 0)  
    BEGIN  
        -- Check if a record with the same name and type already exists
        IF EXISTS (SELECT 1 FROM Inquiry_Contacts WITH (NOLOCK) WHERE ContactName = @ContactName AND Master_Id = @Master_Id AND ContactType = @ContactType)  
        BEGIN  
            SET @RetVal = -101; -- Indicates that a record already exists
            SET @RetMsg = 'Same Name Exist, Please Enter Other Name.';    
            RETURN;  
        END  
        
        -- Insert the new contact record
        INSERT INTO Inquiry_Contacts WITH (ROWLOCK) (  
            ContactName, ContactNumber, ContactMail, ContactType,Master_Id, Entry_User, Entry_Date
        )  
        VALUES (  
            @ContactName, @ContactNumber, @ContactMail, @ContactType,@Master_Id, @Entry_User, dbo.Get_Sysdate()
        );  
        
        SET @RetMsg = 'Created Successfully.';   
        SET @RetVal = SCOPE_IDENTITY();  
        
        -- Check for errors after the insert
        IF @@ERROR <> 0  
        BEGIN  
            SET @RetVal = 0; -- Indicates an error
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';      
            RETURN;  
        END  

        RETURN;  
    END    
    ELSE 
    BEGIN     
        -- Check if the contact ID does not exist
        IF NOT EXISTS (SELECT 1 FROM Inquiry_Contacts WITH (NOLOCK) WHERE ContactId = @ContactId)  
        BEGIN  
            SET @RetVal = -2; -- Indicates that the entry does not exist
            SET @RetMsg = 'Entry Not Exist.';    
            RETURN;  
        END  
        
        -- Check if another record with the same name and type exists, excluding the current ID
        IF EXISTS (SELECT 1 FROM Inquiry_Contacts WITH (NOLOCK) WHERE ContactName = @ContactName AND ContactType = @ContactType AND Master_Id = @Master_Id AND ContactId <> @ContactId)  
        BEGIN  
            SET @RetVal = -101; -- Indicates a conflict with an existing record
            SET @RetMsg = 'Same Name Exist, Please Enter Other Name.';    
            RETURN; 
        END   
        
        -- Update the contact record
        UPDATE Inquiry_Contacts WITH (ROWLOCK)  
        SET
            ContactName = @ContactName,
            ContactNumber = @ContactNumber,
            ContactMail = @ContactMail,
            ContactType = @ContactType,
            Upd_User = @Upd_User,  
            Master_Id = @Master_Id,
            Upd_Date = dbo.Get_Sysdate()   
        WHERE ContactId = @ContactId;  
        
        -- Check for errors after the update
        IF @@ERROR = 0  
        BEGIN  
            SET @RetVal = 1; -- Indicates success
            SET @RetMsg = 'Updated Successfully.';   
        END  
        ELSE  
        BEGIN  
            SET @RetVal = 0; -- Indicates an error
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';       
        END  
    END
END;
GO


