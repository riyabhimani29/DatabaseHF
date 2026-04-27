USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Sales_Site_insert]    Script Date: 27-04-2026 14:48:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Sales_Site_insert]  
    @SiteId INT,  
    @SiteName VARCHAR(500),  
    @SiteAddress VARCHAR(500),    
    @Reference VARCHAR(500),
    @Country_Id INT,
    @State_Id INT,
    @City_Id INT,
    @Entry_User INT,   
    @Upd_User INT,   
    @RetVal INT = 0 OUT,    
    @RetMsg VARCHAR(MAX) = '' OUT   
AS  
BEGIN
    SET NOCOUNT ON;

    IF (@SiteId = 0)  
    BEGIN  
        -- Check if a record with the same name and type already exists
        IF EXISTS (SELECT 1 FROM Inquiry_Sites WITH (NOLOCK) WHERE SiteName = @SiteName)  
        BEGIN  
            SET @RetVal = -101; -- Indicates that a record already exists
            SET @RetMsg = 'Same Name Exist, Please Enter Other Name.';    
            RETURN;  
        END  
        
        -- Insert the new contact record
        INSERT INTO Inquiry_Sites WITH (ROWLOCK) (  
            SiteName, SiteAddress,Reference,Country_Id,State_Id,City_Id,Entry_User, Entry_Date)  
        VALUES (  
            @SiteName, @SiteAddress,@Reference,@Country_Id,@State_Id,@City_Id, @Entry_User, dbo.Get_Sysdate());  
        
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
        IF NOT EXISTS (SELECT 1 FROM Inquiry_Sites WITH (NOLOCK) WHERE SiteId = @SiteId)  
        BEGIN  
            SET @RetVal = -2; -- Indicates that the entry does not exist
            SET @RetMsg = 'Entry Not Exist.';    
            RETURN;  
        END  
        
        -- Check if another record with the same name and type exists, excluding the current ID
        IF EXISTS (SELECT 1 FROM Inquiry_Sites WITH (NOLOCK) WHERE SiteName = @SiteName AND SiteId <> @SiteId)  
        BEGIN  
            SET @RetVal = -101; -- Indicates a conflict with an existing record
            SET @RetMsg = 'Same Name Exist, Please Enter Other Name.';    
            RETURN; 
        END   
        
        -- Update the contact record
        UPDATE Inquiry_Sites WITH (ROWLOCK)  
        SET
            SiteName = @SiteName,
            SiteAddress = @SiteAddress,
            Upd_User = @Upd_User,
            Reference = @Reference,
            Country_Id = @Country_Id,
            State_Id = @State_Id,
            City_Id = @City_Id,
            Upd_Date = dbo.Get_Sysdate()   
        WHERE SiteId = @SiteId;  
        
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


