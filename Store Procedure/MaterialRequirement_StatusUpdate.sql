USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MaterialRequirement_StatusUpdate]    Script Date: 27-04-2026 12:51:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[MaterialRequirement_StatusUpdate]
    @MR_Id INT,   
    @MR_Type NVARCHAR(2) = '',
    @Entry_User NVARCHAR(50),      
    @Upd_User NVARCHAR(50),
    @RetVal INT = 0 OUT,      
    @RetMsg NVARCHAR(MAX) = '' OUT  
AS      
BEGIN      
    SET NOCOUNT ON;

    DECLARE @Process_Type VARCHAR(50);
    DECLARE @Status VARCHAR(50);
    DECLARE @Action_Details NVARCHAR(1000);
    DECLARE @Entry_User_Id INT;
    DECLARE @Project_Id INT;
    DECLARE @Project_Code VARCHAR(50);
    DECLARE @Department_Id INT;
    DECLARE @Department_Code VARCHAR(50);
    DECLARE @TotalQty INT;

    BEGIN TRY      
        BEGIN TRANSACTION;

   

        -- Check if MR exists
        IF NOT EXISTS (SELECT 1 FROM MaterialRequirement WITH (UPDLOCK, HOLDLOCK) WHERE MR_Id = @MR_Id)
        BEGIN
            SET @RetVal = 2; -- Record deleted by another user
            SET @RetMsg = 'Record is already been deleted by another user.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Check if MR_Type is already updated
        IF EXISTS (SELECT 1 FROM MaterialRequirement WITH (UPDLOCK, HOLDLOCK) WHERE MR_Id = @MR_Id AND MR_Type = @MR_Type)
        BEGIN
            SET @RetVal = -124;
            SET @RetMsg = 'Already Updated.';
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Get Project_Id, Department_Id, and total quantity
        SELECT 
            @Project_Id = Project_Id,
            @Department_Id = Department_Id
        FROM MaterialRequirement
        WHERE MR_Id = @MR_Id;

        SELECT @TotalQty = SUM(Qty)
        FROM MR_Items
        WHERE MR_Id = @MR_Id;

        -- Get Project_Code and Department_Code
        SELECT @Project_Code = Project_Name
        FROM M_Project 
        WHERE Project_Id = @Project_Id;

        SELECT @Department_Code = Dept_Name 
        FROM M_Department 
        WHERE Dept_ID = @Department_Id;

        -- Determine Status based on MR_Type
        SET @Status = CASE 
                          WHEN @MR_Type = 'S' THEN 'Saved'
                          WHEN @MR_Type = 'D' THEN 'Draft'
                          WHEN @MR_Type = 'R' THEN 'Rejected'
                          WHEN @MR_Type = 'A' THEN 'Approved'
                          ELSE 'Unknown' -- Placeholder for other MR_Type values
                      END;

        -- Set Process_Type and Action_Details
        SET @Process_Type = CASE 
                                WHEN @Status = 'Saved' THEN 'MR_CheckedIn' -- Assuming 'S' indicates checking in
                                 WHEN @Status = 'Rejected' THEN 'MR_Rejected'
                                 WHEN @Status = 'Approved' THEN 'MR_Approved'
                                ELSE 'MR_Edit'
                            END;
        SET @Action_Details = 'This is updated to ' + @Status + ' with ' + ISNULL(CAST(@TotalQty AS NVARCHAR(10)), '0') + ' items.';

        -- Update MaterialRequirement
        UPDATE MaterialRequirement 
        SET 
            MR_Type = @MR_Type,
            Upd_User = @Upd_User, 
            Upd_Date = dbo.Get_sysdate(),
            Checked_Date = CASE 
                    WHEN @MR_Type = 'C' THEN dbo.Get_sysdate() 
                    ELSE Checked_Date 
                   END,
    Authorised_Date = CASE 
                        WHEN @MR_Type = 'A' THEN dbo.Get_sysdate() 
                        ELSE Authorised_Date 
                      END
        WHERE MR_Id = @MR_Id;

        -- Log status update
      INSERT INTO BOM_Logs
(
    Process_Type,
    Project_Id,
    Quantity,
    Status,
    Action_Details,
    Project_Code,
    Department_Code,
    Entry_User,
    Entry_Date
)
SELECT
    @Process_Type,
    @Project_Id,
    @TotalQty,
    @Status,
    @Action_Details,
    @Project_Code,
    @Department_Code,
    @Entry_User,
    dbo.Get_sysdate()
--WHERE NOT EXISTS
--(
  --  SELECT 1
   -- FROM BOM_Logs
   -- WHERE Project_Id = @Project_Id
    --  AND Process_Type = @Process_Type
     -- AND Status = @Status
--);

  IF @MR_Type = 'A'
        BEGIN
-- Split length data add in stock view
DECLARE @NewStock TABLE
(
    MR_Items_Id INT,
    New_Stock_Id INT
);

-- Only for split items
IF EXISTS (
    SELECT 1
    FROM MR_Items
    WHERE MR_Id = @MR_Id
      AND IsChecked = 1
      AND ISNULL(IsCustom,0) = 0 
      AND ISNULL(Length, 0) > 0
)
BEGIN
        MERGE StockView AS T
            USING
            (
                SELECT
                    MI.Stock_Id,
                    MI.MR_Items_Id,
                    MI.Godown_Id,
                    MI.Item_Id,
                   -- MI.Qty,
                    CASE 
                    WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                    THEN ISNULL(SV.Pending_Qty,0)
                    ELSE MI.Qty
                    END AS Qty,
                    MI.Length,
                    MI.Width,
                    MI.Godown_Rack_Id,
                    SV.Stype
                FROM MR_Items MI
                INNER JOIN StockView SV ON SV.Id = MI.Stock_Id
                WHERE MI.MR_Id = @MR_Id
                  AND MI.IsChecked = 1
                  AND ISNULL(MI.IsCustom,0) = 0 
                  AND ISNULL(MI.Length,0) > 0
            ) AS S
            ON  T.Godown_Id = S.Godown_Id
            AND T.Item_Id   = S.Item_Id
            AND T.Length    = S.Length
            AND T.Width     = S.Width
            AND T.Rack_Id   = S.Godown_Rack_Id
            AND T.ID = S.Stock_Id

            WHEN MATCHED THEN
                UPDATE SET
                    T.Pending_Qty = ISNULL(T.Pending_Qty,0) + S.Qty,
                    T.Total_Qty = T.Total_Qty + S.Qty,
                    T.LastUpdate = dbo.Get_sysdate()

            WHEN NOT MATCHED THEN
                INSERT
                (
                    Godown_Id,
                    Item_Id,
                    Stype,
                    Total_Qty,
                    Sales_Qty,
                    Pending_Qty,
                    [Length],
                    Width,
                    Rack_Id,
                    LastUpdate
                )
                VALUES
                (
                    S.Godown_Id,
                    S.Item_Id,
                    S.Stype,
                    S.Qty,
                    0,
                    S.Qty,
                    S.Length,
                    S.Width,
                    S.Godown_Rack_Id,
                    dbo.Get_sysdate()
                )

            OUTPUT
                S.MR_Items_Id,
                INSERTED.Id        -- ? SAME for update & insert
            INTO @NewStock (MR_Items_Id, New_Stock_Id);

            --Maintain the Stock transfer history for the split length 

            INSERT INTO Stock_Transfer_History
                (
                   Godown_Id,
                   Item_Id,
                   SType,
                   Transfer_Qty,
                   Length,
                   Transfer_Date,
                   Width,
                   Remark,
                   Rack_Id,
                   StockEntryPage,
                   Tbl_Name,
                   Transfer_Type,
                   Transfer_TypeInBit,
                   Stock_Id
                )
                SELECT
                   SV.Godown_Id,
                   SV.Item_Id,
                   SV.SType,
                   SV.Pending_Qty,
                   SV.Length,
                   dbo.Get_sysdate(),
                   SV.Width,
                   'MR Split Length Stock',
                   SV.Rack_Id,
                   'MR Approved',
                   'StockView',
                   'IN',
                   0,
                   SV.Id
                FROM @NewStock NS
                INNER JOIN MR_Items MI ON MI.MR_Items_Id = NS.MR_Items_Id
                INNER JOIN StockView SV ON SV.Id = NS.New_Stock_Id;


----------------------------remaining stock length-----------------------------------------------------

DECLARE @RemainingStock TABLE
(
    MR_Items_Id INT,
    Stock_Id INT
);

MERGE StockView AS T
USING
(
    SELECT
        MI.Stock_Id,
        MI.MR_Items_Id,
        MI.Godown_Id,
        MI.Item_Id,
        SV.Stype,
        CASE 
            WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                THEN ISNULL(SV.Pending_Qty,0)
            ELSE MI.Qty
        END AS Qty,
        (MI.Stock_Length - MI.Length) AS Length,
        MI.Width,
        MI.Godown_Rack_Id
    FROM MR_Items MI
    INNER JOIN StockView SV ON SV.Id = MI.Stock_Id
    WHERE MI.MR_Id = @MR_Id
      AND MI.IsChecked = 1
      AND ISNULL(MI.IsCustom,0) = 0
      AND (MI.Stock_Length - MI.Length) > 0
) AS S

ON  T.Godown_Id = S.Godown_Id
AND T.Item_Id   = S.Item_Id
AND T.Length    = S.Length
AND T.Width     = S.Width
AND T.Rack_Id   = S.Godown_Rack_Id
AND T.ID = S.Stock_Id

WHEN MATCHED THEN
UPDATE SET
    T.Pending_Qty =
        CASE
            WHEN S.Length >= 900
                THEN ISNULL(T.Pending_Qty,0) + S.Qty
            ELSE
                ISNULL(T.Pending_Qty,0)
        END,
    T.Total_Qty =
        CASE
            WHEN S.Length >= 900
                THEN ISNULL(T.Total_Qty,0) + S.Qty
            ELSE
                ISNULL(T.Total_Qty,0)
        END,
    T.Scrap_Qty =
        CASE
            WHEN S.Length < 900
                THEN ISNULL(T.Scrap_Qty,0) + S.Qty
            ELSE
                ISNULL(T.Scrap_Qty,0)
        END,
    T.Scrap_Settle =
        CASE
            WHEN S.Length < 900
                THEN ISNULL(T.Scrap_Settle,0) + S.Qty
            ELSE
                ISNULL(T.Scrap_Settle,0)
        END,

    T.LastUpdate = dbo.Get_sysdate()

WHEN NOT MATCHED THEN
    INSERT
    (
        Godown_Id, 
        Item_Id, 
        Stype,
        Sales_Qty,
        Total_Qty,
        Pending_Qty,
        Scrap_Qty,
        Scrap_Settle,
        Length, 
        Width, 
        Rack_Id,
        LastUpdate
    )
    VALUES
    (
        S.Godown_Id, 
        S.Item_Id, 
        S.Stype,
        0,
        CASE 
            WHEN S.Length >= 900 THEN S.Qty
            ELSE 0
        END,
        CASE 
            WHEN S.Length >= 900 THEN S.Qty
            ELSE 0
        END,
        CASE 
            WHEN S.Length < 900 THEN S.Qty
            ELSE 0
        END,
        CASE 
            WHEN S.Length < 900 THEN S.Qty
            ELSE 0
        END,
        S.Length, 
        S.Width, 
        S.Godown_Rack_Id,
        dbo.Get_sysdate()
    )



OUTPUT
    S.MR_Items_Id,
    INSERTED.Id
INTO @RemainingStock;

INSERT INTO Stock_Transfer_History
(
   Godown_Id,
   Item_Id,
   SType,
   Transfer_Qty,
   Length,
   Transfer_Date,
   Width,
   Remark,
   Rack_Id,
   StockEntryPage,
   Tbl_Name,
   Transfer_Type,
   Transfer_TypeInBit,
   Stock_Id
)
SELECT
    ST.Godown_Id,
    ST.Item_Id,
    ST.SType,
    MI.Qty,
    ST.Length,
    dbo.Get_sysdate(),
    ST.Width,
    'MR Split Length Remaining Stock',
    ST.Rack_Id,
    'MR Approved',
    'StockView',
    'IN',
    0,
    ST.Id
FROM @RemainingStock RS
INNER JOIN StockView ST ON ST.Id = RS.Stock_Id
INNER JOIN MR_Items MI ON MI.MR_Items_Id = RS.MR_Items_Id;

UPDATE MI
SET MI.RemainingStock_Id = RS.Stock_Id
FROM MR_Items MI
INNER JOIN @RemainingStock RS
    ON RS.MR_Items_Id = MI.MR_Items_Id;




---------------------------- end remaining stock length-----------------------------------------------------

-- Maintain the Stock Transfer History for the original length quantity

INSERT INTO Stock_Transfer_History
(
   Godown_Id,
   Item_Id,
   SType,
   Transfer_Qty,
   Length,
   Transfer_Date,
   Width,
   Remark,
   Rack_Id,
   StockEntryPage,
   Tbl_Name,
   Transfer_Type,
   Transfer_TypeInBit,
   Stock_Id
)

SELECT
SV.Godown_Id,
SV.Item_Id,
SV.SType,

CASE 
    WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
        THEN ISNULL(SV.Pending_Qty,0)
    ELSE MI.Qty
END,

SV.Length,
dbo.Get_sysdate(),
SV.Width,
'MR Original Length Deduction',
SV.Rack_Id,
'MR Approved',
'StockView',
'OUT',
1,
SV.Id

FROM StockView SV
INNER JOIN MR_Items MI 
    ON SV.Id = MI.Stock_Id
WHERE MI.MR_Id = @MR_Id
AND MI.IsChecked = 1
AND ISNULL(MI.IsCustom,0) = 0
AND ISNULL(MI.Length,0) > 0;-----9

-- update the original length quantity
UPDATE SV WITH (ROWLOCK)
SET    
    Pending_Qty = ISNULL(SV.Pending_Qty,0) - 
        CASE 
            WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                THEN ISNULL(SV.Pending_Qty,0)
            ELSE MI.Qty
        END,

    Transfer_Qty = ISNULL(SV.Transfer_Qty,0) + 
        CASE 
            WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                THEN ISNULL(SV.Pending_Qty,0)
            ELSE MI.Qty
        END

FROM StockView SV
INNER JOIN MR_Items MI 
    ON SV.Id = MI.Stock_Id
WHERE MI.MR_Id = @MR_Id 
AND MI.IsChecked = 1
AND ISNULL(MI.IsCustom,0) = 0
AND ISNULL(MI.Length,0) > 0;

--UPDATE M_Item SET Stock_Id = @newStockId WHERE M_Items.MR_Id = @MR_Id AND M_Items
UPDATE MI
SET MI.Stock_Id = NS.New_Stock_Id
FROM MR_Items MI
INNER JOIN @NewStock NS
    ON NS.MR_Items_Id = MI.MR_Items_Id
WHERE MI.MR_Id = @MR_Id
AND MI.IsChecked = 1
AND ISNULL(MI.IsCustom, 0) = 0
AND ISNULL(MI.Length, 0) > 0;
END
/* ============================
   CUSTOM ITEM STOCK CREATION
============================ */

INSERT INTO StockView
(
    Godown_Id,
    Item_Id,
    Stype,
    Total_Qty,
    Sales_Qty,
    Pending_Qty,
    Freeze_Qty,
    Length,
    Width,
    Rack_Id,
    LastUpdate
)
SELECT
    SV.Godown_Id,
    SV.Item_Id,
    SV.Stype,
    0,
    0,
    0,
    0,
    MI.Length,          -- custom length
    SV.Width,
    SV.Rack_Id,
    dbo.Get_sysdate()
FROM MR_Items MI
INNER JOIN StockView SV
    ON SV.Id = MI.Stock_Id
WHERE MI.MR_Id = @MR_Id
  AND MI.IsCustom = 1
AND NOT EXISTS
(
    SELECT 1
    FROM StockView X
    WHERE X.Godown_Id = SV.Godown_Id
    AND X.Item_Id = SV.Item_Id
    AND X.Length = MI.Length
    AND X.Width = SV.Width
    AND X.Rack_Id = SV.Rack_Id
    AND X.Stype = SV.Stype
);


  UPDATE MI
SET MI.Stock_Id = SV_New.Id
FROM MR_Items MI
INNER JOIN StockView SV_Old
    ON SV_Old.Id = MI.Stock_Id
INNER JOIN StockView SV_New
    ON SV_New.Godown_Id = SV_Old.Godown_Id
   AND SV_New.Item_Id   = SV_Old.Item_Id
   AND SV_New.Length    = MI.Length       -- ?? custom length
   AND SV_New.Width     = SV_Old.Width
   AND SV_New.Rack_Id   = SV_Old.Rack_Id
   AND SV_New.Stype     = SV_Old.Stype
WHERE MI.MR_Id = @MR_Id
  AND MI.IsCustom = 1;


            INSERT INTO Stock_Transfer_History
                (
                   Godown_Id,
                   Item_Id,
                   SType,
                   Transfer_Qty,
                   Length,
                   Transfer_Date,
                   Width,
                   Remark,
                   Rack_Id,
                   StockEntryPage,
                   Tbl_Name,
                   Transfer_Type,
                   Transfer_TypeInBit,
                   Stock_Id
                )
                SELECT
                   ST.Godown_Id,
                   ST.Item_Id,
                   ST.SType,
                   0,
                   MR.Length,
                   dbo.Get_sysdate(),
                   ST.Width,
                   'MR Custom Length',
                   ST.Rack_Id,
                   'MR Approved',
                   'StockView',
                   'IN',
                   0,
                   ST.Id
                FROM MR_Items MR
                INNER JOIN StockView ST
                 ON ST.Id = MR.Stock_Id
                  AND ST.Item_Id = MR.Item_Id
                  AND ST.Rack_Id = MR.Godown_Rack_Id
                  AND ST.Width = MR.Width
                  AND ST.Length =  MR.[Length]
                WHERE MR.MR_Id = @MR_Id
                  AND MR.IsCustom = 1
   AND NOT EXISTS
(
    SELECT 1
    FROM Stock_Transfer_History H
    WHERE H.Stock_Id = ST.Id
    AND H.Transfer_Qty = 0
    AND H.Remark = 'MR Custom Length'
    AND H.StockEntryPage = 'MR Approved'
    AND H.Transfer_Type = 'IN'
);
END
        /* ============================
           STOCK FREEZE (ONLY FOR A)
        ============================ */

       IF @MR_Type = 'A' 
        AND EXISTS
(
    SELECT 1
    FROM MR_Items MI
    INNER JOIN StockView SV ON SV.Id = MI.Stock_Id
    WHERE MI.MR_Id = @MR_Id
      AND (
            CASE 
                WHEN MI.Qty > ISNULL(SV.Pending_Qty, 0)
                    THEN ISNULL(SV.Pending_Qty, 0)
                ELSE MI.Qty
            END
          ) > 0
)
        BEGIN
        --update stockview
        UPDATE SV
        SET 
        Freeze_Qty = CASE 
                    WHEN MI.Qty > ISNULL(SV.Pending_Qty, 0) 
                        THEN ISNULL(SV.Pending_Qty, 0)  -- overwrite
                    ELSE ISNULL(SV.Freeze_Qty,0) + MI.Qty  -- add safely
                 END,
        LastUpdate = dbo.Get_sysdate()
        FROM StockView SV
        INNER JOIN MR_Items MI
        ON MI.Stock_Id = SV.Id
        AND MI.MR_Id = @MR_Id;
        
        

        -- update mr_items
        UPDATE MI
        SET
        IsFreeze = 1,
        Freeze_Qty = CASE
                    WHEN MI.Qty > ISNULL(SV.Pending_Qty, 0)
                        THEN ISNULL(SV.Pending_Qty, 0)  -- overwrite
                    ELSE ISNULL(MI.Freeze_Qty,0) + MI.Qty  -- add safely
                 END
        FROM MR_Items MI
        INNER JOIN StockView SV
        ON SV.Id = MI.Stock_Id
        WHERE MI.MR_Id = @MR_Id;



        --insert in bom logs

        INSERT INTO BOM_Logs
        (
        Process_Type,
        Project_Id,
        Quantity,
        Status,
        Action_Details,
        Project_Code,
        Department_Code,
        Entry_User,
        Entry_Date
         )
        SELECT
        'Stock_Freeze',                             -- Process_Type
        @Project_Id,                                -- Project_Id
        CASE                                        -- Frozen Qty
            WHEN MI.Qty > ISNULL(SV.Pending_Qty,0) THEN ISNULL(SV.Pending_Qty,0)
            ELSE MI.Qty
        END AS Quantity,
        'Frozen' AS Status,
        'This is frozen for stock with ' +
        CAST(
            CASE 
                WHEN MI.Qty > ISNULL(SV.Pending_Qty,0) THEN ISNULL(SV.Pending_Qty,0)
                ELSE MI.Qty
            END AS NVARCHAR(10)
        ) + ' items (' + ISNULL(MI_Name.Item_Name,'Unknown') + ').' AS Action_Details,
        @Project_Code,
        @Department_Code,
        @Entry_User,
        dbo.Get_sysdate()
        FROM MR_Items MI
        INNER JOIN StockView SV ON SV.Id = MI.Stock_Id
        LEFT JOIN M_Item MI_Name ON MI_Name.Item_Id = MI.Item_Id
        WHERE MI.MR_Id = @MR_Id;
        END
        /* ============================
              END STOCK FREEZE 
        ============================ */

        -- Set success return values
        SET @RetVal = @MR_Id;
        SET @RetMsg = 'Material Requirement updated successfully.';

        COMMIT TRANSACTION;
    END TRY      
    BEGIN CATCH      
        ROLLBACK TRANSACTION;
        SET @RetVal = -1;
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE();
    END CATCH;      
END;
