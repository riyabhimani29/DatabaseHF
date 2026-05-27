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
            @Department_Id = Dept_Id
        FROM MaterialRequirement
        WHERE MR_Id = @MR_Id;

        -----------------------------------------------------------------------
-- Validation before Approval (MR_Type = 'A')
-- For Planning Department (Department_Id = 1):
-- If any non-custom item has insufficient available stock
-- (Pending_Qty - Freeze_Qty < MR_Items.Qty), stop processing.
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- Validation before Approval/Checking
-- Show all items that have insufficient available stock.
-----------------------------------------------------------------------
IF ((@MR_Type = 'A' OR @MR_Type = 'C') AND @Department_Id = 1)
BEGIN
    DECLARE @ErrorItems NVARCHAR(MAX);

    ;WITH InvalidItems AS
    (
        SELECT
            M.Item_Code,
            AvailableQty =
                ISNULL(SV.Pending_Qty, 0) - ISNULL(SV.Freeze_Qty, 0),
            RequiredQty =
                ISNULL(MI.Qty, 0)
        FROM MR_Items MI
        INNER JOIN StockView SV
            ON SV.Id = MI.Stock_Id
        INNER JOIN M_Item M
            ON M.Item_Id = MI.Item_Id
        WHERE MI.MR_Id = @MR_Id
          AND ISNULL(MI.IsCustom, 0) = 0
          AND (
                ISNULL(SV.Pending_Qty, 0)
                - ISNULL(SV.Freeze_Qty, 0)
              ) < ISNULL(MI.Qty, 0)
    )
    SELECT
        @ErrorItems =
            STRING_AGG(
                'Item ' + Item_Code +
                ' (Available Qty: ' + CAST(AvailableQty AS NVARCHAR(50)) +
                ', Required Qty: ' + CAST(RequiredQty AS NVARCHAR(50)) + ')',
                '; '
            )
    FROM InvalidItems;

    IF @ErrorItems IS NOT NULL
    BEGIN
        SET @RetVal = -1;
        SET @RetMsg =
            'Stock validation failed for the following items: ' + @ErrorItems;

        ROLLBACK TRANSACTION;
        RETURN;
    END
END

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
            /* =========================================
               SOURCE DATA
            ========================================= */

            DECLARE @Source TABLE
            (
                MR_Items_Id INT,
                Godown_Id INT,
                Item_Id INT,
                Qty DECIMAL(18,2),
                Length DECIMAL(18,2),
                Width DECIMAL(18,2),
                Rack_Id INT,
                Stype VARCHAR(50)
            );

            INSERT INTO @Source
            (
                MR_Items_Id,
                Godown_Id,
                Item_Id,
                Qty,
                Length,
                Width,
                Rack_Id,
                Stype
            )
            SELECT
                MI.MR_Items_Id,
                MI.Godown_Id,
                MI.Item_Id,

                CASE
                    WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                        THEN ISNULL(SV.Pending_Qty,0)
                    ELSE MI.Qty
                END,

                MI.Length,
                MI.Width,
                MI.Godown_Rack_Id,
                SV.Stype

            FROM MR_Items MI
            INNER JOIN StockView SV
                ON SV.Id = MI.Stock_Id

            WHERE MI.MR_Id = @MR_Id
              AND MI.IsChecked = 1
              AND ISNULL(MI.IsCustom,0) = 0
              AND ISNULL(MI.Length,0) > 0;


             /* =========================================
               UPDATE EXISTING SPLIT STOCK
            ========================================= */

            UPDATE T
            SET
                T.Pending_Qty = ISNULL(T.Pending_Qty,0) + S.Qty,
                T.Total_Qty = ISNULL(T.Total_Qty,0) + S.Qty,
                T.LastUpdate = dbo.Get_sysdate()

            FROM StockView T

            INNER JOIN
            (
                SELECT
                    Godown_Id,
                    Item_Id,
                    Length,
                    Width,
                    Rack_Id,
                    Stype,
                    SUM(Qty) Qty

                FROM @Source

                GROUP BY
                    Godown_Id,
                    Item_Id,
                    Length,
                    Width,
                    Rack_Id,
                    Stype

            ) S

                ON T.Godown_Id = S.Godown_Id
                AND T.Item_Id = S.Item_Id
                AND T.Length = S.Length
                AND T.Width = S.Width
                AND T.Rack_Id = S.Rack_Id
                AND T.Stype = S.Stype;


            /* =========================================
               INSERT NEW SPLIT STOCK
            ========================================= */

            INSERT INTO StockView
            (
                Godown_Id,
                Item_Id,
                Stype,
                Total_Qty,
                Sales_Qty,
                Pending_Qty,
                Length,
                Width,
                Rack_Id,
                LastUpdate
            )
            SELECT
                S.Godown_Id,
                S.Item_Id,
                S.Stype,
                SUM(S.Qty),
                0,
                SUM(S.Qty),
                S.Length,
                S.Width,
                S.Rack_Id,
                dbo.Get_sysdate()

            FROM @Source S

            WHERE NOT EXISTS
            (
                SELECT 1
                FROM StockView T
                WHERE T.Godown_Id = S.Godown_Id
                AND T.Item_Id = S.Item_Id
                AND T.Length = S.Length
                AND T.Width = S.Width
                AND T.Rack_Id = S.Rack_Id
                AND T.Stype = S.Stype
            )

            GROUP BY
                S.Godown_Id,
                S.Item_Id,
                S.Stype,
                S.Length,
                S.Width,
                S.Rack_Id;



        /* =========================================
           CREATE STOCK MAPPING
        ========================================= */

            DECLARE @StockMapping TABLE
            (
                MR_Items_Id INT,
                New_Stock_Id INT
            );

            INSERT INTO @StockMapping
            (
                MR_Items_Id,
                New_Stock_Id
            )
            SELECT
                S.MR_Items_Id,
                SV.Id

            FROM @Source S

            INNER JOIN StockView SV
                ON SV.Godown_Id = S.Godown_Id
                AND SV.Item_Id = S.Item_Id
                AND SV.Length = S.Length
                AND SV.Width = S.Width
                AND SV.Rack_Id = S.Rack_Id
                AND SV.Stype = S.Stype;

        
           

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
                   S.Qty,
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
                FROM @Source S

            INNER JOIN StockView SV
                ON SV.Godown_Id = S.Godown_Id
                AND SV.Item_Id = S.Item_Id
                AND SV.Length = S.Length
                AND SV.Width = S.Width
                AND SV.Rack_Id = S.Rack_Id
                AND SV.Stype = S.Stype;

----------------------------remaining stock length-----------------------------------------------------

    /* =========================================
       SOURCE DATA
    ========================================= */

    DECLARE @RemainingSource TABLE
    (
        MR_Items_Id INT,
        Godown_Id INT,
        Item_Id INT,
        Qty DECIMAL(18,2),
        Remaining_Length DECIMAL(18,2),
        Width DECIMAL(18,2),
        Rack_Id INT,
        Stype VARCHAR(50)
    );

    INSERT INTO @RemainingSource
    (
        MR_Items_Id,
        Godown_Id,
        Item_Id,
        Qty,
        Remaining_Length,
        Width,
        Rack_Id,
        Stype
    )
    SELECT
        MI.MR_Items_Id,
        MI.Godown_Id,
        MI.Item_Id,

        CASE
            WHEN MI.Qty > ISNULL(SV.Pending_Qty,0)
                THEN ISNULL(SV.Pending_Qty,0)
            ELSE MI.Qty
        END,

        (MI.Stock_Length - MI.Length),

        MI.Width,
        MI.Godown_Rack_Id,
        SV.Stype

    FROM MR_Items MI

    INNER JOIN StockView SV
        ON SV.Id = MI.Stock_Id

    WHERE MI.MR_Id = @MR_Id
      AND MI.IsChecked = 1
      AND ISNULL(MI.IsCustom,0)=0
      AND ISNULL(MI.Length,0)>0
      AND (ISNULL(MI.Stock_Length,0) - ISNULL(MI.Length,0)) > 0


    /* =========================================
       UPDATE EXISTING REMAINING STOCK
    ========================================= */

    UPDATE T
    SET

        T.Pending_Qty =
            CASE
                WHEN S.Remaining_Length >= 900
                    THEN ISNULL(T.Pending_Qty,0) + S.Qty
                ELSE
                    ISNULL(T.Pending_Qty,0)
            END,

        T.Total_Qty =
            CASE
                WHEN S.Remaining_Length >= 900
                    THEN ISNULL(T.Total_Qty,0) + S.Qty
                ELSE
                    ISNULL(T.Total_Qty,0)
            END,

        T.Scrap_Qty =
            CASE
                WHEN S.Remaining_Length < 900
                    THEN ISNULL(T.Scrap_Qty,0) + S.Qty
                ELSE
                    ISNULL(T.Scrap_Qty,0)
            END,

        T.Scrap_Settle =
            CASE
                WHEN S.Remaining_Length < 900
                    THEN ISNULL(T.Scrap_Settle,0) + S.Qty
                ELSE
                    ISNULL(T.Scrap_Settle,0)
            END,

        T.LastUpdate = dbo.Get_sysdate()

    FROM StockView T

    INNER JOIN
    (
        SELECT
            Godown_Id,
            Item_Id,
            Remaining_Length,
            Width,
            Rack_Id,
            Stype,
            SUM(Qty) Qty

        FROM @RemainingSource

        GROUP BY
            Godown_Id,
            Item_Id,
            Remaining_Length,
            Width,
            Rack_Id,
            Stype

    ) S

        ON T.Godown_Id = S.Godown_Id
        AND T.Item_Id = S.Item_Id
        AND T.Length = S.Remaining_Length
        AND T.Width = S.Width
        AND T.Rack_Id = S.Rack_Id
        AND T.Stype = S.Stype;


/* =========================================
       INSERT NEW REMAINING STOCK
    ========================================= */

    INSERT INTO StockView
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
    SELECT
        S.Godown_Id,
        S.Item_Id,
        S.Stype,

        0,

        CASE
            WHEN S.Remaining_Length >= 900
                THEN SUM(S.Qty)
            ELSE 0
        END,

        CASE
            WHEN S.Remaining_Length >= 900
                THEN SUM(S.Qty)
            ELSE 0
        END,

        CASE
            WHEN S.Remaining_Length < 900
                THEN SUM(S.Qty)
            ELSE 0
        END,

        CASE
            WHEN S.Remaining_Length < 900
                THEN SUM(S.Qty)
            ELSE 0
        END,

        S.Remaining_Length,
        S.Width,
        S.Rack_Id,
        dbo.Get_sysdate()

    FROM @RemainingSource S

    WHERE NOT EXISTS
    (
        SELECT 1
        FROM StockView T
        WHERE T.Godown_Id = S.Godown_Id
        AND T.Item_Id = S.Item_Id
        AND T.Length = S.Remaining_Length
        AND T.Width = S.Width
        AND T.Rack_Id = S.Rack_Id
        AND T.Stype = S.Stype
    )

    GROUP BY
        S.Godown_Id,
        S.Item_Id,
        S.Stype,
        S.Remaining_Length,
        S.Width,
        S.Rack_Id;


    /* =========================================
       CREATE STOCK MAPPING
    ========================================= */

    DECLARE @RemainingStockMapping TABLE
    (
        MR_Items_Id INT,
        Remaining_Stock_Id INT
    );

    INSERT INTO @RemainingStockMapping
    (
        MR_Items_Id,
        Remaining_Stock_Id
    )
    SELECT
        S.MR_Items_Id,
        SV.Id

    FROM @RemainingSource S

    INNER JOIN StockView SV
        ON SV.Godown_Id = S.Godown_Id
        AND SV.Item_Id = S.Item_Id
        AND SV.Length = S.Remaining_Length
        AND SV.Width = S.Width
        AND SV.Rack_Id = S.Rack_Id
        AND SV.Stype = S.Stype;


    /* =========================================
       UPDATE MR_ITEMS RemainingStock_Id
    ========================================= */

    UPDATE MI
    SET MI.RemainingStock_Id = RSM.Remaining_Stock_Id

    FROM MR_Items MI

    INNER JOIN @RemainingStockMapping RSM
        ON RSM.MR_Items_Id = MI.MR_Items_Id

    WHERE MI.MR_Id = @MR_Id
      AND MI.IsChecked = 1
      AND ISNULL(MI.IsCustom,0)=0
      AND ISNULL(MI.Length,0)>0

      -- IMPORTANT CONDITION
      AND ISNULL(MI.RemainingStock_Id,0)=0;


      /* =========================================
       STOCK TRANSFER HISTORY
    ========================================= */

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
       RS.Qty,
       SV.Length,
       dbo.Get_sysdate(),
       SV.Width,
       'MR Split Remaining Length',
       SV.Rack_Id,
       'MR Approved',
       'StockView',
       'IN',
       0,
       SV.Id

    FROM @RemainingSource RS

    INNER JOIN StockView SV
        ON SV.Godown_Id = RS.Godown_Id
        AND SV.Item_Id = RS.Item_Id
        AND SV.Length = RS.Remaining_Length
        AND SV.Width = RS.Width
        AND SV.Rack_Id = RS.Rack_Id
        AND SV.Stype = RS.Stype;


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

            /* =========================================
               UPDATE MR_ITEMS STOCK_ID
            ========================================= */

            UPDATE MI
            SET MI.Stock_Id = SM.New_Stock_Id

            FROM MR_Items MI

            INNER JOIN @StockMapping SM
                ON SM.MR_Items_Id = MI.MR_Items_Id

            WHERE MI.MR_Id = @MR_Id
              AND MI.IsChecked = 1
              AND ISNULL(MI.IsCustom,0)=0
              AND ISNULL(MI.Length,0)>0;


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
  AND MI.IsCustom = 1
  AND ISNULL(MI.IsChecked,0)=0
AND ISNULL(MI.Length,0)>0;


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
