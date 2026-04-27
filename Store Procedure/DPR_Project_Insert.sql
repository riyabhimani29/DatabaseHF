USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Project_Insert]    Script Date: 27-04-2026 11:28:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Project_Insert] 
    @Project_Id INT,
    @Project_Name VARCHAR(500),
    @Site_Address VARCHAR(500),
    @Country_Id INT,
    @State_Id INT,
    @City_Id INT,
    @Customer_Name VARCHAR(500),
    @Customer_Address VARCHAR(500),
    @Contact_Person VARCHAR(500),
    @Contact_Number VARCHAR(500),
    @PAN_No VARCHAR(500),
    @GST_No VARCHAR(500),
    @Remark VARCHAR(500),
    @Project_Status VARCHAR(500),
    @Is_Active BIT,
    @MAC_Add VARCHAR(500),
    @Entry_User INT,
    @Upd_User INT,
    @RetVal INT = 0 OUT,
    @RetMsg VARCHAR(MAX) = '' OUT,
    @DtlPara DPR_Project_PanelTypes_Type readonly

AS
BEGIN
    SET NOCOUNT ON;

   DECLARE @_DPR_Panel_Id      AS INT= 0,      
            @_ProjectType AS INT= 0,      
            @_PanelType  AS INT= 0,      
            @_Elevations AS VARCHAR(max) = ''
            
    IF (@Project_Id = 0) 
    BEGIN
        IF EXISTS (SELECT 1 FROM DPR_Project WITH (NOLOCK) WHERE project_name = @Project_Name) 
        BEGIN
            SET @RetVal = -101; -- Record already exists
            SET @RetMsg = 'Same Project Name Exist.';
            RETURN;
        END;

        INSERT INTO DPR_Project (
            project_name,
            site_address,
            country_id,
            state_id,
            city_id,
            customer_name,
            customer_address,
            contact_person,
            contact_number,
            pan_no,
            gst_no,
            project_status,
            is_active,
            remark,
      --      Panel_Type,
            mac_add,
            entry_user,
            entry_date
        )
        VALUES (
            @Project_Name,
            @Site_Address,
            @Country_Id,
            @State_Id,
            @City_Id,
            @Customer_Name,
            @Customer_Address,
            @Contact_Person,
            @Contact_Number,
            @PAN_No,
            @GST_No,
            @Project_Status,
            @Is_Active,
                        @Remark,
        --    @Panel_Type,
            @MAC_Add,
            @Entry_User,
            dbo.Get_sysdate()
        );

        SET @RetVal = SCOPE_IDENTITY();

         IF @@ERROR = 0 
        BEGIN
           -- SET @RetVal;
            SET @RetMsg = 'Project Details Inserted Successfully.';
            -- panel data fetch from the table type
                 DECLARE dpr_cur CURSOR FOR      
                      SELECT DPR_Panel_Id,
                     		 ProjectType,      
                             PanelType,      
                             Elevations
                      FROM   @DtlPara;      
      
                    OPEN dpr_cur      
      
                    FETCH next FROM dpr_cur INTO @_DPR_Panel_Id,@_ProjectType , @_PanelType, @_Elevations
                    
           			
           			 WHILE @@FETCH_STATUS = 0      
                      BEGIN      
                          INSERT INTO DPR_Project_PanelTypes WITH(rowlock)      
                                      (Project_Id,  
                                       ProjectType,      
                                       PanelType,      
                                       Elevations)      
                          VALUES      ( @RetVal,   
                                        @_ProjectType,      
                                        @_PanelType,      
                                        @_Elevations)      
                                        
           FETCH next FROM dpr_cur INTO @_DPR_Panel_Id,@_ProjectType , @_PanelType, @_Elevations                    
                      END      
      
                    CLOSE dpr_cur;      
      
                    DEALLOCATE dpr_cur;      
                END
        ELSE 
        BEGIN
            SET @RetVal = 0; -- Error occurred
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
        END;
    END
    ELSE 
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM DPR_Project WITH (NOLOCK) WHERE project_id = @Project_Id) 
        BEGIN
            SET @RetVal = -2; -- Record doesn't exist
            SET @RetMsg = 'This Project Is Already Been Deleted By Another User.';
            RETURN;
        END;

        IF EXISTS (SELECT 1 FROM DPR_Project WITH (NOLOCK) WHERE project_name = @Project_Name AND project_id <> @Project_Id) 
        BEGIN
            SET @RetVal = -101; -- Record already exists
            SET @RetMsg = 'Same Project Name Exist.';
            RETURN;
        END;

        UPDATE DPR_Project 
        SET
            project_name = @Project_Name,
            site_address = @Site_Address,
            country_id = @Country_Id,
            state_id = @State_Id,
            city_id = @City_Id,
            customer_name = @Customer_Name,
            customer_address = @Customer_Address,
            contact_person = @Contact_Person,
            contact_number = @Contact_Number,
            pan_no = @PAN_No,
            gst_no = @GST_No,
            project_status = @Project_Status,
            is_active = @Is_Active,
            remark = @Remark,
         --   Panel_Type = @Panel_Type,
            upd_user = @Upd_User,
            upd_date = dbo.Get_sysdate()
        WHERE
            project_id = @Project_Id;

        IF @@ERROR = 0 
        BEGIN
            SET @RetVal = @Project_Id;
            SET @RetMsg = 'Project Details Update Successfully.';
            
                   DECLARE dpr_cur CURSOR FOR      
                      SELECT DPR_Panel_Id,
                     		 ProjectType,      
                             PanelType,      
                             Elevations
                      FROM   @DtlPara;      
      
                    OPEN dpr_cur      
      
                    FETCH next FROM dpr_cur INTO @_DPR_Panel_Id,@_ProjectType , @_PanelType, @_Elevations
                    
           			
           			 WHILE @@FETCH_STATUS = 0      
                      BEGIN      
                          IF ( @_DPR_Panel_Id = 0 )      
                            BEGIN
                            
                          INSERT INTO DPR_Project_PanelTypes WITH(rowlock)      
                                      (Project_Id,  
                                       ProjectType,      
                                       PanelType,      
                                       Elevations)      
                          VALUES      ( @RetVal,   
                                        @_ProjectType,      
                                        @_PanelType,      
                                        @_Elevations)  
                                        END
                             ELSE      
                            BEGIN  
                            UPDATE DPR_Project_PanelTypes SET
                            ProjectType = @_ProjectType,      
                            PanelType = @_PanelType,      
                            Elevations = @_Elevations
                            WHERE DPR_Panel_Id = @_DPR_Panel_Id
                      END      
           FETCH next FROM dpr_cur INTO @_DPR_Panel_Id,@_ProjectType , @_PanelType, @_Elevations                    
                      END      
      
                    CLOSE dpr_cur;      
      
                    DEALLOCATE dpr_cur;      
        END
        ELSE 
        BEGIN
            SET @RetVal = 0; -- Error occurred
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
        END;
    END;
END;
GO


