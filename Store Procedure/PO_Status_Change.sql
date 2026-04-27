USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_Status_Change]    Script Date: 27-04-2026 14:31:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PO_Status_Change]
(
    @PO_Id        INT,
    @PO_Type      VARCHAR(50),
    @Type          VARCHAR(50),-- P or PP
    @MAC_Add      VARCHAR(500),
    @Upd_User     INT,
    @Year_Id      INT,
    @Branch_ID    INT,
    @DtlPara      Tbl_PRApproves readonly, 
    @RetVal       INT OUTPUT,
    @RetMsg       VARCHAR(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        DECLARE @_Old_PO_Type VARCHAR(10);

        /* ?? Get current PO type */
        SELECT @_Old_PO_Type = PO_Type
        FROM PR_MST WITH (NOLOCK)
        WHERE PR_Id = @PO_Id;

        IF (@_Old_PO_Type IS NULL)
        BEGIN
            SET @RetVal = -1;
            SET @RetMsg = 'PO not found.';
            RETURN;
        END
        if( @Type = 'R')
         BEGIN
         BEGIN TRANSACTION;
             UPDATE PR_MST WITH (ROWLOCK)
            SET
                PO_Type  = 'D',
                Upd_User = @Upd_User,
                Upd_Date = dbo.Get_sysdate(),
                MAC_Add  = @MAC_Add
            WHERE PR_Id = @PO_Id;

            UPDATE D
            SET 
            D.Is_Read = CASE 
            WHEN TP.Is_Checked = 1 THEN 1
            ELSE D.Is_Read
            END
            FROM PR_DTL D
            INNER JOIN @DtlPara TP
            ON D.PrDtl_Id = TP.PODtl_Id
            WHERE D.PR_Id = @PO_Id;
            
            UPDATE R
            SET R.Is_PO = 1
            FROM BOM_PO_RequestDtl R
            INNER JOIN PR_DTL D
                ON R.BOM_PO_ReqDtl_Id = D.Req_Id
            WHERE D.PR_Id = @PO_Id
              AND D.Req_Id IS NOT NULL
              AND ISNULL(R.Is_PO,0) <> 1;

               COMMIT;

            SET @RetVal = 1;
            SET @RetMsg = 'PR Reject successfully.';
            RETURN;
            
        END

        /* =================================================
           ?? P ? PP (Approve PO)
        ================================================= */
        IF (@_Old_PO_Type = 'P' AND @PO_Type = 'P')
        BEGIN
            BEGIN TRANSACTION;

            -- Update PO status
            UPDATE PR_MST WITH (ROWLOCK)
            SET
                PO_Type  = 'PP',
                Upd_User = @Upd_User,
                Upd_Date = dbo.Get_sysdate(),
                MAC_Add  = @MAC_Add
            WHERE PR_Id = @PO_Id
              AND PO_Type = 'P';

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK;
                SET @RetVal = -2;
                SET @RetMsg = 'PR already processed.';
                RETURN;
            END
            /* UPDATE D
                SET D.Is_Checked = TP.Is_Checked,
                 D.Remark = TP.Remark
                FROM PR_DTL D
                INNER JOIN @DtlPara TP
                    ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id;  */

                UPDATE D
                SET 
                D.Is_Checked = TP.Is_Checked,
                D.Remark = TP.Remark,
                D.Is_Read = 3
                FROM PR_DTL D
                INNER JOIN @DtlPara TP
                ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id;

                -- 3?? Update BOM_PO_RequestDtl.Is_PO based on Is_Checked
                UPDATE R
                SET R.Is_PO = CASE 
                                 WHEN D.Is_Checked = 1 THEN 3
                                 ELSE 7
                             END,
                   R.Remark = TP.Remark
                FROM BOM_PO_RequestDtl R
                INNER JOIN PR_DTL D
                    ON R.BOM_PO_ReqDtl_Id = D.Req_Id
                INNER JOIN @DtlPara TP
                    ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id
                  AND D.Req_Id IS NOT NULL;
          

            COMMIT;

            SET @RetVal = 1;
            SET @RetMsg = 'PO approved successfully.';
            RETURN;
        END

        /* =================================================
           ?? PP ? F (Finalize PO)
        ================================================= */
        IF (@_Old_PO_Type = 'PP' AND @PO_Type = 'PP')
        BEGIN
            DECLARE
                @_Invoice_No INT,
                @_Dept_ID INT,
                @_DeptShortNm VARCHAR(20),
                @_PO_Date DATE,
                @_Financial_Year INT,
                @_OrderNo VARCHAR(100);

            -- Fetch required PO info
            SELECT
                @_Dept_ID = Dept_ID,
                @_PO_Date = PO_Date
            FROM PR_MST
            WHERE PR_Id = @PO_Id;

            SET @_Financial_Year = dbo.Get_financial_year(@_PO_Date);
            SET @Year_Id = dbo.Get_financial_yearid(@_PO_Date);

            SELECT @_DeptShortNm = Dept_Short_Name
            FROM M_Department WITH (NOLOCK)
            WHERE Dept_ID = @_Dept_ID;

            IF (@_DeptShortNm IS NULL)
            BEGIN
                SET @RetVal = -3;
                SET @RetMsg = 'Invalid Department.';
                RETURN;
            END
             
            SELECT @_Invoice_No = Invoice_No
            from PR_MST WITH (NOLOCK)
            WHERE PR_Id = @PO_Id

            if(@_Invoice_No = 0)
            BEGIN
            -- Generate Invoice No
            SELECT @_Invoice_No = ISNULL(MAX(Invoice_No),0) + 1
            FROM PR_MST WITH (NOLOCK)
            WHERE Year_Id = @Year_Id
              AND Dept_ID = @_Dept_ID
              AND PO_Type NOT IN ('D','P','PP');
            END

            -- Generate Order No
            SET @_OrderNo =
                'HF/' + @_DeptShortNm + 'PR/' +
                FORMAT(@_Invoice_No,'0000') + '/' +
                CONVERT(VARCHAR(20), @_Financial_Year);

            BEGIN TRANSACTION;

            -- Finalize PO
            UPDATE PR_MST WITH (ROWLOCK)
            SET
                PO_Type    = 'F',
                Invoice_No = @_Invoice_No,
                OrderNo    = @_OrderNo,
                Upd_User   = @Upd_User,
                Upd_Date   = dbo.Get_sysdate(),
                MAC_Add    = @MAC_Add,
                Year_Id    = @Year_Id,
                Branch_ID  = @Branch_ID
            WHERE PR_Id = @PO_Id
              AND PO_Type = 'PP';

            IF @@ROWCOUNT = 0
            BEGIN
                ROLLBACK;
                SET @RetVal = -4;
                SET @RetMsg = 'PR already finalized.';
                RETURN;
            END
                         /*  UPDATE D
                SET D.Is_Checked = TP.Is_Checked,
                 D.Remark = TP.Remark
                FROM PR_DTL D
                INNER JOIN @DtlPara TP
                    ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id;*/

                UPDATE D
                SET 
                D.Is_Checked = TP.Is_Checked,
                D.Remark = TP.Remark,
                D.Is_Read = 4
                FROM PR_DTL D
                INNER JOIN @DtlPara TP
                ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id;

                -- 3?? Update BOM_PO_RequestDtl.Is_PO based on Is_Checked
                UPDATE R
                SET R.Is_PO = CASE 
                                 WHEN D.Is_Checked = 1 THEN 4
                                 ELSE 7
                             END,
                R.Remark = TP.Remark
                FROM BOM_PO_RequestDtl R
                INNER JOIN PR_DTL D
                    ON R.BOM_PO_ReqDtl_Id = D.Req_Id
                INNER JOIN @DtlPara TP
                    ON D.PrDtl_Id = TP.PODtl_Id
                WHERE D.PR_Id = @PO_Id
                  AND D.Req_Id IS NOT NULL;


            COMMIT;

            SET @RetVal = 1;
            SET @RetMsg = 'PO finalized successfully.';
            RETURN;
        END

        /* ? Invalid transition */
        SET @RetVal = -9;
        SET @RetMsg = 'Invalid PO status transition.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;

        SET @RetVal = -405;
        SET @RetMsg = ERROR_MESSAGE();
    END CATCH
END
GO


