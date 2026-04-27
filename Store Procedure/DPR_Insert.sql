USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Insert]    Script Date: 27-04-2026 11:24:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Insert]
	@DprId INT,
    @ProjectId INT,
    @Date DATETIME,
    @Remarks VARCHAR(550),
    @SessionUser INT,
    @SessionId VARCHAR(100),
    @ReleasePanels as dbo.Release_Panels READONLY,
    @Fabrications AS dbo.Fabrication_Panel READONLY,
    @PanelDispatches AS dbo.Panel_Dispatch READONLY,
    @Assembles AS dbo.Assemble_Panel READONLY,
    @Glazings AS dbo.Glazing_Panel READONLY,
    @Installations AS dbo.Installation_Panel READONLY,
    @RetVal INT = 0 out,     
    @RetMsg VARCHAR(max) = '' out
AS
BEGIN
    SET NOCOUNT ON;
DECLARE @Release TABLE (Release_Id INT);
DECLARE @Release_Id INT;
    -- Start transaction
    BEGIN TRANSACTION;

    BEGIN TRY
    
        IF @DprId = 0
        BEGIN
            -- If DPR does not exist, insert new record into Release_Panel table
            INSERT INTO [dbo].[DPR] ([Project_Id], [Entry_User], [Entry_Date], [Date], Remarks)
            VALUES (@ProjectId, @SessionUser, GETDATE(), @Date, @Remarks);

            -- Get the inserted Dpr_Id
            SET @DprId = SCOPE_IDENTITY();
          SET @RetMsg = 'successfully generated panel.'      
      		SET @RetVal = Scope_identity();
        END
        ELSE
        BEGIN
            -- If DPR exists, update the Remark in Release_Panel table
            UPDATE [dbo].[DPR]
            SET [Remarks] = @Remarks,
            [Project_Id] = @ProjectId,
            [Upd_User] = @SessionUser,
          --  [Date] = @Date,
            [Upd_Date] = dbo.Get_sysdate()
            WHERE [Dpr_Id] = @DprId;
               SET @RetMsg = 'successfully updated panel.'      
      		SET @RetVal = Scope_identity();
        END

 		-- Update or insert data in Release_Panel table
IF EXISTS (SELECT 1 FROM @ReleasePanels)
BEGIN
    -- Update existing records in Release_Panel table
    MERGE INTO [dbo].[Release_Panel] AS target
    USING @ReleasePanels AS source
    ON target.[Release_Id] = source.[Release_Id]
    WHEN MATCHED THEN
        UPDATE SET 
            PanelElevationDetails = source.[PanelElevationDetails],
            DPR_Panel_Id = source.[DPR_Panel_Id],
            Remarks = source.[Remarks],
              [Upd_User] = @SessionUser,
            [Upd_Date] = dbo.Get_sysdate()
            OUTPUT INSERTED.Release_Id INTO @Release;
   -- @Release_Id = source.[Release_Id];

    -- Insert new records into Release_Panel table
    INSERT INTO [dbo].[Release_Panel] (Dpr_Id, Remarks, PanelElevationDetails, DPR_Panel_Id,[Date], [Entry_User], [Entry_Date])
    OUTPUT INSERTED.Release_Id INTO @Release
    SELECT @DprId, source.[Remarks], source.[PanelElevationDetails], source.[DPR_Panel_Id],dbo.Get_sysdate(), @SessionUser, dbo.Get_sysdate()
    FROM @ReleasePanels AS source
    WHERE NOT EXISTS (SELECT 1 FROM [dbo].[Release_Panel] AS target WHERE target.[Release_Id] = source.[Release_Id]);
END

SELECT TOP 1 @Release_Id = Release_Id FROM @Release;

-- Update or insert data in Fabrication_Panel table
IF EXISTS (SELECT 1 FROM @Fabrications)
BEGIN
    -- Update existing records in Fabrication_Panel table
    MERGE INTO [dbo].[Fabrication_Panel] AS target
    USING @Fabrications AS source
    ON target.[Fab_Id] = source.[Fab_Id]
    WHEN MATCHED THEN
        UPDATE SET 
            [Man_Power] = source.[Man_Power],
            [Male_Female] = source.[Male_Female],
            [Gutter] = source.[Gutter],
            [Bottom] = source.[Bottom],
            [Mid_Transfom] = source.[Mid_Transfom],
            [Adaptor] = source.[Adaptor],
            [Edge_Guard] = source.[Edge_Guard],
            [Running_Meter] = source.[Running_Meter],
            [Frame] = source.[Frame],
            [Shutter] = source.[Shutter],
            [Elevation] = source.[Elevation],
            [BatchNo] = source.[BatchNo],
            Remarks = source.[Remarks],
            Area = source.[Area],
            [Upd_User] = @SessionUser,
            [Upd_Date] = CAST(dbo.Get_sysdate() AS DATETIME)  -- Ensure valid DATETIME format
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            Dpr_Id, [Man_Power], [Male_Female], [Gutter], [Bottom], [Mid_Transfom], 
            [Adaptor], [Edge_Guard], [Running_Meter], [Frame], [Shutter], [Elevation], 
            [BatchNo], Remarks, Area, [Release_Id], [Entry_User], [Entry_Date]
        )
        VALUES (
            @DprId, source.[Man_Power], source.[Male_Female], source.[Gutter], source.[Bottom], 
            source.[Mid_Transfom], source.[Adaptor], source.[Edge_Guard], source.[Running_Meter], 
            source.[Frame], source.[Shutter], source.[Elevation], source.[BatchNo], 
            source.[Remarks], source.[Area], @Release_Id, @SessionUser, 
            CAST(dbo.Get_sysdate() AS DATETIME)  -- Ensure valid DATETIME format
        );
END
		
		-- Update or insert data in dispatch_Panel table
        IF EXISTS (SELECT 1 FROM @PanelDispatches)
        BEGIN
            -- Update existing records in dispatch_Panel table
            MERGE INTO [dbo].[Panel_Dispatch] AS target
            USING @PanelDispatches AS source
            ON target.Dis_Id = source.Dis_Id
            WHEN MATCHED THEN
                UPDATE SET 
                    [Dispatch] = source.[Dispatch],
                    [Running_Meter] = source.[Running_Meter],
                    [Elevation] = source.[Elevation],
                    [BatchNo] = source.[BatchNo],
                    Remarks = source.[Remarks],
                    Area = source.[Area],
                      [Upd_User] = @SessionUser,
            [Upd_Date] = dbo.Get_sysdate()
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Dpr_Id,[Dispatch],Running_Meter,[Elevation],[BatchNo],Remarks,Area,Release_Id, [Entry_User], [Entry_Date])
                VALUES (@DprId,source.[Dispatch],source.[Running_Meter],source.[Elevation],source.[BatchNo],source.[Remarks], source.[Area],@Release_Id, @SessionUser, GETDATE());
        END
        
        -- Update or insert data in Assemble_Panel table
        IF EXISTS (SELECT 1 FROM @Assembles)
        BEGIN
            -- Update existing records in Assemble_Panel table
            MERGE INTO [dbo].[Assemble_Panel] AS target
            USING @Assembles AS source
            ON target.[Asmbl_Id] = source.[Asmbl_Id]
            WHEN MATCHED THEN
                UPDATE SET 
                    [Man_Power] = source.[Man_Power],
                    [Panel_Assemble] = source.[Panel_Assemble],
                    [Hook_Bracket_Assemble] = source.[Hook_Bracket_Assemble],
                    [GI_Trey_Assemble] = source.[GI_Trey_Assemble], 
                    [Frame_Assemble] = source.[Frame_Assemble],
                    [Shutter_Assemble] = source.[Shutter_Assemble],
                    [Hardware_Assemble] = source.[Hardware_Assemble],
                    [Elevation] = source.[Elevation],
                    [BatchNo] = source.[BatchNo],
                    Remarks = source.[Remarks],
                    Area = source.[Area],
                     [Upd_User] = @SessionUser,
            [Upd_Date] = dbo.Get_sysdate()
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Dpr_Id,[Man_Power], [Panel_Assemble], [Hook_Bracket_Assemble], [GI_Trey_Assemble],[Frame_Assemble],[Shutter_Assemble],[Hardware_Assemble],[Elevation],[BatchNo],Remarks,Area,Release_Id, [Entry_User], [Entry_Date])
                VALUES (@DprId,source.[Man_Power], source.[Panel_Assemble], source.[Hook_Bracket_Assemble], source.[GI_Trey_Assemble],source.[Frame_Assemble],source.[Shutter_Assemble],source.[Hardware_Assemble],source.[Elevation],source.[BatchNo],source.[Remarks],source.[Area],@Release_Id, @SessionUser, GETDATE());
        END
        
        -- Update or insert data in Glazing_Panel table
        IF EXISTS (SELECT 1 FROM @Glazings)
        BEGIN
            -- Update existing records in Glazing_Panel table
            MERGE INTO [dbo].[Glazing_Panel] AS target
            USING @Glazings AS source
            ON target.[Glaz_Id] = source.[Glaz_Id]
            WHEN MATCHED THEN
                UPDATE SET 
                    [Man_Power] = source.[Man_Power],
                    [Glass_Pesting] = source.[Glass_Pesting],
                    [Panel_Glazing] = source.[Panel_Glazing],
                    [Weather_Silicon] = source.[Weather_Silicon],
                    [Elevation] = source.[Elevation],
                    [BatchNo] = source.[BatchNo],
                    Remarks = source.[Remarks],
                                        Area = source.[Area],
                                         [Upd_User] = @SessionUser,
            [Upd_Date] = dbo.Get_sysdate()
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Dpr_Id,[Man_Power], [Glass_Pesting], [Panel_Glazing], [Weather_Silicon],[Elevation],[BatchNo],Remarks,Area,Release_Id, [Entry_User], [Entry_Date])
                VALUES (@DprId,source.[Man_Power], source.[Glass_Pesting], source.[Panel_Glazing], source.[Weather_Silicon],source.[Elevation],source.[BatchNo],source.[Remarks],source.[Area],@Release_Id, @SessionUser, GETDATE());
        END
        
        -- Update or insert data in Installation_Panel table
        IF EXISTS (SELECT 1 FROM @Installations)
        BEGIN
            -- Update existing records in Installation_Panel table
            MERGE INTO [dbo].[Installation_Panel] AS target
            USING @Installations AS source
            ON target.[Instl_Id] = source.[Instl_Id]
            WHEN MATCHED THEN
                UPDATE SET 
                    [Man_Power] = source.[Man_Power],
                    [Panel_Installation] = source.[Panel_Installation] ,
                    [Running_Meter] = source.[Running_Meter],
                    [Elevation] = source.[Elevation],
                    [BatchNo] = source.[BatchNo],
                    Remarks = source.[Remarks],
                                        Area = source.[Area],
                                         [Upd_User] = @SessionUser,
            [Upd_Date] = dbo.Get_sysdate()
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (Dpr_Id,[Man_Power], [Panel_Installation],[Running_Meter],[Elevation],[BatchNo],Remarks,Area,Date,Release_Id, [Entry_User], [Entry_Date])
                VALUES (@DprId,source.[Man_Power], source.[Panel_Installation],source.[Running_Meter],source.[Elevation],source.[BatchNo],source.[Remarks],source.[Area],
                dbo.Get_sysdate(),@Release_Id, @SessionUser, GETDATE());      
        END  

-- Commit transaction
        COMMIT TRANSACTION;                
    END TRY
    BEGIN CATCH
        -- Rollback transaction if any error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Throw the error
        THROW;
    END CATCH

    -- Return the Dpr_Id of the inserted/updated record
       
END;
GO


