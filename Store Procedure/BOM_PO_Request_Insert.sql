USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_PO_Request_Insert]    Script Date: 27-04-2026 10:56:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[BOM_PO_Request_Insert]
    @BOM_Id INT,
    @PoRequestTo INT,
    @Dept_ID INT,
    @Entry_User INT,
    @Upd_User INT,
    @DtlPara TBL_BOM_PO_DTLS READONLY,
    @RetVal INT = 0 OUT,
    @RetMsg VARCHAR(MAX) = '' OUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @_Id INT, 
            @_BOM_Dtl_Id INT, 
            @_Name VARCHAR(550),      
            @_Length NUMERIC(18, 3),      
            @_Weight NUMERIC(18, 3),      
            @_Width NUMERIC(18, 3),     
            @_Qty NUMERIC(18, 3),
            @_UnitCost NUMERIC(18, 3);
    DECLARE @Project_Id INT;
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Code VARCHAR(50);
    DECLARE @Process_Type VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @Action_Details NVARCHAR(1000);


    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get Project_Id from BOM_MST
        SELECT @Project_Id = Project_Id
        FROM BOM_MST
        WHERE BOM_Id = @BOM_Id;

        IF @Project_Id IS NULL
        BEGIN
            SET @RetVal = -400;
            SET @RetMsg = 'BOM record not found for BOM_Id: ' + CAST(@BOM_Id AS VARCHAR(10)) + '.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Get Project_Code and Department_Code
        SELECT @Project_Code = Project_Name 
        FROM M_Project 
        WHERE Project_Id = @Project_Id;

        SELECT @Department_Code = Dept_Name 
        FROM M_Department 
        WHERE Dept_Id = @Dept_ID;

        -- Insert into BOM_PO_Request
        INSERT INTO BOM_PO_Request WITH (ROWLOCK) (
            BOM_Id, PoRequestTo, Dept_ID, Date, Entry_User, Entry_Date, Upd_User, Upd_Date, Is_read
        )
        VALUES (
            @BOM_Id, @PoRequestTo, @Dept_ID, dbo.Get_sysdate(), @Entry_User, 
            dbo.Get_sysdate(), @Upd_User, dbo.Get_sysdate(), 0
        );
      
        SET @RetVal = SCOPE_IDENTITY();
        SET @RetMsg = 'Successfully sent request.';


        -- Insert details from DtlPara and log each item
        DECLARE bom_cur CURSOR FOR      
        SELECT Id, BOM_Dtl_Id, Name, CONVERT(NUMERIC(18, 3), Length), 
               CONVERT(NUMERIC(18, 3), Weight), Width, Qty, UnitCost
        FROM @DtlPara;      
      
        OPEN bom_cur;      
        FETCH NEXT FROM bom_cur INTO @_Id, @_BOM_Dtl_Id, @_Name, @_Length, @_Weight, @_Width, @_Qty, @_UnitCost;
      
        WHILE @@FETCH_STATUS = 0      
        BEGIN      
            INSERT INTO BOM_PO_RequestDtl WITH (ROWLOCK) (
                BOM_PO_Req_Id, BOM_Dtl_Id, [Name], [Length], [Weight], Width, Qty, UnitCost,Is_PO
            )
            VALUES (
                @RetVal, @_BOM_Dtl_Id, @_Name, CONVERT(NUMERIC(18, 3), @_Length), 
                CONVERT(NUMERIC(18, 3), @_Weight), @_Width, @_Qty, @_UnitCost, 0
            );
                         
            UPDATE MR_Items 
            SET IsPORequested = 1, Request_Qty = ISNULL(Request_Qty, 0) + @_Qty 
            WHERE MR_Items_Id = @_BOM_Dtl_Id;

            -- Log PO Request for each item
            SET @Process_Type = 'PO_Request';
            SET @Status = 'Requested';
            SET @Action_Details = 'This is requested for purchase order with ' + 
                                  CAST(@_Qty AS NVARCHAR(20)) + ' items (' + ISNULL(@_Name, 'Unknown') + ')' +
                                  CASE WHEN @Dept_ID = 1 THEN ', Length: ' + CAST(@_Length AS NVARCHAR(20)) ELSE '' END + '.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, CAST(@_Qty AS INT), @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
            );
                         
            FETCH NEXT FROM bom_cur INTO @_Id, @_BOM_Dtl_Id, @_Name, @_Length, @_Weight, @_Width, @_Qty, @_UnitCost;
        END;
      
        CLOSE bom_cur;      
        DEALLOCATE bom_cur;  

        -- Department-specific logic
        IF @Dept_ID = 1
        BEGIN
            PRINT 'Dept_ID is 1';
        END;
        
        IF @Dept_ID = 3
        BEGIN
            PRINT 'Dept_ID is 3';
        END;
        
        IF @Dept_ID = 5
        BEGIN
            PRINT 'Dept_ID is 5';
        END;
      
        COMMIT TRANSACTION;
    END TRY      
    BEGIN CATCH      
        ROLLBACK TRANSACTION;
        SET @RetVal = -405;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';
    END CATCH;
END;
GO


