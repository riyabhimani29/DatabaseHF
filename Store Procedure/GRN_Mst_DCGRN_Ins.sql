USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_DCGRN_Ins]    Script Date: 27-04-2026 11:36:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




                                       
ALTER PROCEDURE [dbo].[GRN_Mst_DCGRN_Ins] @PO_Type        VARCHAR(500),          
                                           @GRN_Id         INT,          
                                           @DC_Id          INT,          
                                           @Dept_ID        INT,          
                                           @GRN_No         VARCHAR(500),          
                                           @Challan_No     VARCHAR(500),               
                                           @Inv_No     VARCHAR(500),      
                                           @GRN_Date       DATE,          
                                           @Challan_Date   DATE,          
                                           @ReqRaisedBy_Id INT,          
                                           @Supplier_Id    INT,          
                                           @Godown_Id      INT,          
                                           @Vehicle_No     VARCHAR(500),          
                                           @EwayBill_No    VARCHAR(500),          
                                           @GrossAmount    NUMERIC(18, 3),          
                                           @AdvanceAmount  NUMERIC(18, 3),          
                                           @OtherAmount    NUMERIC(18, 3),          
                                           @NetAmount      NUMERIC(18, 3),          
                                           @ReceiveBy_Id   INT,          
                                           @CheckBy_Id     INT,          
                                           @Remark         VARCHAR(500),          
                                           @MAC_Add        VARCHAR(500),          
                                           @CGST           INT,          
                                           @CGSTTotal      NUMERIC(18, 0),          
                                           @SGST           INT,          
                                           @SGSTTotal      NUMERIC(18, 0),          
                                           @IGST           INT,          
                                           @IGSTTotal      NUMERIC(18, 0),          
                                           @Entry_User     INT,          
                                           @Upd_User       INT,          
                                           @Year_Id        INT,          
                                           @Branch_ID      INT,          
                                           @DtlPara        Tbl_DC_GRNDetails readonly,          
                                           @RetVal         INT = 0 out,          
                                           @RetMsg         VARCHAR(max) = '' out          
AS          
    SET nocount ON          
          
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, @GRN_Date))          
          
    DECLARE @_Financial_Year AS INT = 0          
          
    SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, @GRN_Date))          
          
  BEGIN try          
      BEGIN TRANSACTION          
          
      /************************************* TRANSACTION *************************************/          
      DECLARE @_DeptShortNm AS VARCHAR(20)='GRN',          
              @_Invoice_No  AS INT = 0          
           
   set @Dept_ID = ( select top 1   ISNULL(DC_Dtl.Dept_ID,0) from DC_Dtl with(nolock)  where DC_Id  = @DC_Id  )        
         
      --if (@Dept_ID <> 0 )          
      -- begin          
      --  select @_DeptShortNm = ISNULL (M_Department.Dept_Short_Name,'-') from M_Department with (nolock) where M_Department.Dept_ID = @Dept_ID          
      -- END          
      --else          
      -- BEGIN          
      --  SET @RetMsg ='Please Select Department !!!'          
      --  SET @RetVal = -1          
      --  return          
      -- END          
          
      SELECT @_Invoice_No = Isnull(Max(grn_mst.invoice_no), 0) + 1          
      FROM   grn_mst WITH(nolock)          
      WHERE  grn_mst.year_id = @Year_Id          
          
      SET @GRN_No = 'HF/' + @_DeptShortNm + '/'          
                    + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000'))          
                    + '/' + CONVERT(VARCHAR(20), @_Financial_Year)          
          
      -- Eg. HF/ALU/1002/2122          
          
      INSERT INTO GRN_Mst WITH(rowlock)          
                  (grn_type,          
                   grn_no,          
                   po_id,          
                   dept_id,          
                   challan_no,          
                   invoice_no,          
                   grn_date,          
                   challan_date,          
					reqraisedby_id,          
                   supplier_id,          
                   godown_id,          
                   vehicle_no,          
                   ewaybill_no,          
                   grossamount,          
                   advanceamount,          
                   otheramount,          
                   netamount,          
                   receiveby_id,          
                   checkby_id,          
                   remark,          
                   mac_add,          
                   entry_user,          
                   cgst,          
                   sgst,          
                   igst,          
                   cgsttotal,          
                   sgsttotal,          
                   igsttotal,          
                   entry_date,          
                   year_id,          
                   branch_id,
				   Inv_No)          
      VALUES      ( @PO_Type,          
                    @GRN_No,          
                    @DC_Id,          
                    @Dept_ID,          
                    @Challan_No,          
                    @_Invoice_No,          
                    @GRN_Date,          
                    @Challan_Date,          
                    @ReqRaisedBy_Id,          
                    @Supplier_Id,          
                    @Godown_Id,          
                    @Vehicle_No,          
                    @EwayBill_No,          
                    @GrossAmount,          
                    @AdvanceAmount,          
                    @OtherAmount,          
                    @NetAmount,          
                    @ReceiveBy_Id,          
                    @CheckBy_Id,          
                    @Remark,          
                    @MAC_Add,          
                    @Entry_User,          
                    @CGST,          
                    @SGST,          
                    @IGST,          
                    @CGSTTotal,          
                    @SGSTTotal,          
                    @IGSTTotal,          
                    dbo.Get_sysdate(),          
                    @Year_Id,          
                    @Branch_ID,
					@Inv_No)          
          
      SET @RetMsg ='GRN Generate Successfully And Generated GRN No is : '  + @GRN_No + ' .'          
      SET @RetVal = Scope_identity()          
          
      IF @@ERROR <> 0          
        BEGIN          
            SET @RetVal = -404 -- 0 IS FOR ERROR                                      
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
        END          
      ELSE          
        BEGIN          
            DECLARE @_PODtl_Id      AS INT= 0,          
                    @_Item_Group_Id AS INT= 0,          
                    @_Item_Cate_Id  AS INT= 0,          
                    @_Item_Id       AS INT= 0,          
                    @_SupDetail_Id  AS INT= 0,          
                    @_OrderQty      AS NUMERIC(18, 3) = 0,          
                    @_ReceiveQty    AS NUMERIC(18, 3) = 0,          
                    @_Unit_Id       AS INT= 0,          
                    @_Length        AS NUMERIC(18, 3) = 0,          
                    @_Weight        AS NUMERIC(18, 3) = 0,          
                    @_TotalWeight   AS NUMERIC(18, 3) = 0,          
                    @_UnitCost      AS NUMERIC(18, 3) = 0,          
                    @_ReceiveCost   AS NUMERIC(18, 3) = 0,          
                    @_TotalCost     AS NUMERIC(18, 3) = 0,          
                    @_Width         AS NUMERIC(18, 3) = 0,          
                    @_Remark        AS VARCHAR(500)= '',          
     @_IsSeletd      AS BIT,          
                    @_IsCoated      AS BIT,          
                    @_Rack_Id       AS INT= 0,          
                    @_Material_Value     AS NUMERIC(18, 3) = 0,          
                    @_Coating_Value         AS NUMERIC(18, 3) = 0,
                    @_MR_Item_Id    AS INT =0
             
            DECLARE db_cursor CURSOR FOR        
              SELECT podtl_id,          
                     item_id,          
                     supdetail_id,          
                     orderqty,          
                     receiveqty,          
                     unit_id,          
                     CONVERT(NUMERIC(18, 3), length),          
                     CONVERT(NUMERIC (18, 3), weight),          
                     totalweight,          
                     unitcost,          
                     runitcost,          
                     totalcost,          
                     remark,          
                     isseletd,          
                     iscoated,          
                     width,          
                     rack_id ,        
                     Material_Value,        
                     Coating_Value,
                     MR_Item_Id
              FROM   @DtlPara;          
          
            OPEN db_cursor          
          
            FETCH next FROM db_cursor INTO @_PODtl_Id, @_Item_Id, @_SupDetail_Id  ,@_OrderQty, @_ReceiveQty, @_Unit_Id, @_Length,       
   @_Weight,@_TotalWeight,@_UnitCost, @_ReceiveCost, @_TotalCost, @_Remark, @_IsSeletd, @_IsCoated,      
            @_Width, @_Rack_Id ,@_Material_Value, @_Coating_Value, @_MR_Item_Id        
          
            WHILE @@FETCH_STATUS = 0          
              BEGIN          
                  DECLARE @_DtlIId AS INT =0  ,        
                          @_NewWeight AS NUMERIC(18,3)=0
                  IF ( @_ReceiveQty > 0          
                       AND @_Rack_Id > 0 )          
                    /*  if (@_IsSeletd = 1)                        */          
                    BEGIN          
                        INSERT INTO GRN_Dtl WITH(rowlock)          
                                    (grn_id,          
                                     podtl_id,          
                                     item_group_id,          
                                     item_cate_id,          
                                     item_id,          
                                     supdetail_id,          
                                     orderqty,          
                                     receiveqty,          
                                     unit_id,          
                                     [length],          
                                     weight,          
                                     totalweight,          
                                     unitcost,          
                                     receivecost,          
                                     totalcost,          
                                     remark,          
                                     stype,          
                                     width,          
                                     rack_id,        
          Material_Value,        
          Coating_Value)          
                        VALUES      ( @RetVal,          
                                      @_PODtl_Id,          
                                      0,          
                                      0,          
                                      @_Item_Id,          
                                      @_SupDetail_Id,          
                                      @_OrderQty,          
                                      @_ReceiveQty,          
                                      @_Unit_Id,          
                                      @_Length,          
                                      @_Weight,          
                                      @_TotalWeight,          
                                      @_UnitCost,          
                                      @_ReceiveCost,          
                                      @_TotalCost,          
                                      @_Remark,          
                                      ( CASE          
             WHEN @_IsCoated = 1 THEN 'C'          
                                          ELSE 'N'          
                                        END ),          
                                      @_Width,          
                                      @_Rack_Id,@_Material_Value, @_Coating_Value)          
          
                        SET @_DtlIId = Scope_identity()      
  /* ===================== New Weight CALCULATION ===================== */                    
        IF (@Dept_ID = 1)
BEGIN
    DECLARE   
        @_CurrentQty    NUMERIC(18,3),
        @_NewAvgWeight  NUMERIC(18,3),
        @_CurrentWeight NUMERIC(18,3);

    /* Get current values */
    SELECT @_CurrentWeight = ISNULL(Weight_Mtr, 0)  
    FROM M_Item WITH (NOLOCK) 
    WHERE Item_Id = @_Item_Id;

    SELECT @_CurrentQty = ISNULL(SUM(pending_qty), 0) 
    FROM StockView WITH (NOLOCK) 
    WHERE item_id = @_Item_Id;


    SET @_NewWeight = (@_TotalWeight * 1000) 
                      / NULLIF((@_ReceiveQty * @_Length), 0);


    SET @_NewAvgWeight =
    (
        (@_CurrentQty * @_CurrentWeight) + 
        (@_ReceiveQty * ISNULL(@_NewWeight, @_CurrentWeight))
    ) 
    / NULLIF((@_CurrentQty + @_ReceiveQty), 0);

  
    UPDATE M_Item
    SET 
        Weight_Mtr = ISNULL(@_NewWeight, Weight_Mtr),
        AvgWeight  = ISNULL(@_NewAvgWeight, AvgWeight)
    WHERE Item_Id = @_Item_Id;
END
   /* ===================== New Weight CALCULATION ===================== */

                        IF ( @_PODtl_Id > 0 )          
                          BEGIN          
                              UPDATE DC_Dtl WITH (rowlock)          
                              SET    pending_qty = Isnull(pending_qty, 0)   - @_ReceiveQty          
                              WHERE  dc_dtl.dcdtl_id = @_PODtl_Id          
                          END          
          
                        IF EXISTS(SELECT 1          
                                  FROM   stockview WITH (nolock)          
                                  WHERE  godown_id = @Godown_Id          
                                         AND item_id = @_Item_Id          
                                         AND [length] = @_Length          
                                         AND width = @_Width          
                                         AND rack_id = @_Rack_Id          
                                         AND stype = ( CASE          
                                                         WHEN @_IsCoated = 1          
                                                       THEN          
                                                         'C'          
                                                         ELSE 'N'          
                                                       END ))          
                          BEGIN  
                          
                           DECLARE @_StockView_Id INT = NULL;


                           SET @_StockView_Id =NULL;
                            SELECT @_StockView_Id = Id
                            FROM StockView WITH (NOLOCK)
                            WHERE godown_id = @Godown_Id
                              AND item_id = @_Item_Id
                              AND [length] = @_Length
                              AND width = @_Width
                              AND Rack_Id = @_Rack_Id
                              AND stype = (CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END);


                              /* ===== NEW : STOCK TRANSFER HISTORY (GRN - UPDATE) ===== */
                                INSERT INTO Stock_Transfer_History
                                (
                                    Godown_Id,
                                    Item_Id,
                                    SType,
                                    Transfer_Qty,
                                    [Length],
                                    Width,
                                    Rack_Id,
                                    Transfer_Date,
                                    Remark,
                                    StockEntryPage,
                                    Tbl_Name,
                                    Transfer_Type,
                                    Transfer_TypeInBit,
                                    GRN_Dtl_Id,
                                    Stock_Id,
                                    MR_Item_Id
                                )
                                VALUES
                                (
                                    @Godown_Id,
                                    @_Item_Id,
                                    (CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END),
                                    @_ReceiveQty,
                                    @_Length,
                                    @_Width,
                                    @_Rack_Id,
                                    dbo.Get_sysdate(),
                                    'DC-GRN',
                                    'DC-GRN',
                                    'GRN',
                                    'IN',
                                    0,
                                    @_DtlIId,
                                    @_StockView_Id,
                                    @_MR_Item_Id
                                );



                              UPDATE stockview WITH (rowlock)          
                              SET    total_qty = Isnull(total_qty, 0) + @_ReceiveQty,          
                                     pending_qty = Isnull(pending_qty, 0) + @_ReceiveQty   ,          
                                     lastupdate = dbo.Get_sysdate()  ,      
          StockEntryPage = 'DC-GRN' ,    
          StockEntryQty = @_ReceiveQty ,  
          Dtl_Id = @_DtlIId ,  
          Tbl_Name = 'GRN_Dtl'  
                              WHERE  godown_id = @Godown_Id          
                                     AND item_id = @_Item_Id          
                                     AND [length] = @_Length          
                                     AND width = @_Width          
                                     AND rack_id = @_Rack_Id          
                                     AND stype = ( CASE          
                                                     WHEN @_IsCoated = 1 THEN          
                                                     'C'          
                                                     ELSE 'N'          
                                                   END )          
          
                              UPDATE GRN_Dtl    WITH (rowlock)        
                              SET    stock_id = (SELECT TOP 1 stockview.id          
                                                 FROM   stockview WITH (nolock)          
                                                 WHERE  godown_id = @Godown_Id          
                                                        AND item_id = @_Item_Id          
                                                        AND [length] = @_Length          
                                                        AND width = @_Width          
                               AND rack_id = @_Rack_Id          
                                                        AND stype = ( CASE  WHEN   @_IsCoated = 1     THEN     'C'     ELSE 'N'     END ))          
                              WHERE  grndtl_id = @_DtlIId          
                          END          
                        ELSE          
                          BEGIN 
                          
                          DECLARE @_History_Id   INT = NULL;


                           SET @_History_Id= NULL;
                            INSERT INTO Stock_Transfer_History
                            (
                                Godown_Id,
                                Item_Id,
                                SType,
                                Transfer_Qty,
                                [Length],
                                Width,
                                Rack_Id,
                                Transfer_Date,
                                Remark,
                                StockEntryPage,
                                Tbl_Name,
                                Transfer_Type,
                                Transfer_TypeInBit,
                                GRN_Dtl_Id,
                                Stock_Id,
                                MR_Item_Id
                            )
                            VALUES
                            (
                                @Godown_Id,
                                @_Item_Id,
                                (CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END),
                                @_ReceiveQty,
                                @_Length,
                                @_Width,
                                @_Rack_Id,
                                dbo.Get_sysdate(),
                                'DC-GRN',
                                'DC-GRN',
                                'GRN',
                                'IN',
                                0,
                                @_DtlIId,
                                NULL,
                                @_MR_Item_Id
                            );
                    SET @_History_Id = SCOPE_IDENTITY();


                              INSERT INTO StockView WITH(rowlock)          
                                          (godown_id,          
                          item_id,          
                                           total_qty,          
                                           sales_qty,          
                                           pending_qty,          
                                           [length],          
                                           stype,          
                                           lastupdate,          
                                           width,          
                                           rack_id ,      
                                           StockEntryPage ,    
                                           StockEntryQty ,  
                                           Dtl_Id ,   
                                           Tbl_Name)          
                              VALUES      ( @Godown_Id,          
                                            @_Item_Id,          
                                            @_ReceiveQty,          
                                            0,          
                                            @_ReceiveQty,          
                                            @_Length,          
                                            ( CASE          
                                                WHEN @_IsCoated = 1 THEN 'C'          
                                                ELSE 'N'          
                                              END ),          
                                            dbo.Get_sysdate(),          
                                            @_Width,          
                                            @_Rack_Id,      
                                           'DC-GRN' ,    
                                           @_ReceiveQty ,  
                                           @_DtlIId,  
                                           'GRN_Dtl')          
          
                              UPDATE grn_dtl     WITH(rowlock)         
                              SET    stock_id = Scope_identity()          
                              WHERE  grndtl_id = @_DtlIId  
                             update Stock_Transfer_History set Stock_Id = SCOPE_IDENTITY() where ID = @_History_Id;
                          END          
                    END          
          
          IF(@_MR_Item_Id > 0)
          BEGIN 

            DECLARE @Process_Type VARCHAR(50);
            DECLARE @Status VARCHAR(50);
            DECLARE @Action_Details NVARCHAR(1000);
            DECLARE @TotalQty INT;
            DECLARE @Project_Id INT;
            DECLARE @Project_Code VARCHAR(50);
            DECLARE @Department_Code VARCHAR(50);
            
            DECLARE @MR_Items_Id INT;
            --DECLARE @Qty INT;
            DECLARE @Item_Id INT;
            DECLARE @Item_Name VARCHAR(550);
            DECLARE @Length DECIMAL(18,3);

                    SELECT TOP 1 
                    @Project_Id = MR.Project_Id,
                    @Department_Code = D.Dept_Name,
                    @Dept_ID = MR.Department_Id
                FROM MR_Items MRI
                INNER JOIN MaterialRequirement MR ON MRI.MR_Id = MR.MR_Id
                INNER JOIN M_Department D ON MR.Dept_ID = D.Dept_ID
                where MRI.MR_Items_Id = @_MR_Item_Id;

                IF @Project_Id IS NULL
                BEGIN
                    SET @RetVal = -400;
                    SET @RetMsg = 'Project not found for the provided MR item IDs.';
                    ROLLBACK TRANSACTION;
                    RETURN;
                END;
                 -- Get Project_Code
                SELECT @Project_Code = Project_Name 
                FROM M_Project 
                WHERE Project_Id = @Project_Id;

                SELECT 
                    @Item_Id = MRI.Item_Id,
                    @Length = MRI.Length
                FROM MR_Items MRI
                WHERE MRI.MR_Items_Id = @_MR_Item_Id;
                UPDATE SV
                    SET 
                    pending_qty = pending_qty - @_ReceiveQty,
                    SV.Freeze_Qty = SV.freeze_qty - @_ReceiveQty,
                    lastupdate = dbo.Get_sysdate(),
                    StockEntryPage = 'MR-Item-Issue',
                    StockEntryQty = @_ReceiveQty,
                    Dtl_Id = MRI.MR_Items_Id,
                    Tbl_Name = 'DC GRN',
                    ProDept_Qty =  ProDept_Qty + @_ReceiveQty 
                    FROM StockView SV
                     INNER JOIN MR_Items MRI ON SV.Id = MRI.Stock_Id
                        WHERE MRI.IsFreeze = 1 
                        AND MRI.MR_Items_Id = @_MR_Item_Id;



                     -- Update MR_Items
                    UPDATE MRI
                    SET 
                        Issue_Qty = ISNULL(Issue_Qty, 0) + @_ReceiveQty,
                        MRI.IsFreeze = 0,
                        MRI.Freeze_Qty = MRI.Freeze_Qty - @_ReceiveQty,
                        MRI.Release_Qty = MRI.Release_Qty - @_ReceiveQty
                    FROM MR_Items MRI
                    WHERE MRI.IsFreeze = 1 AND  MRI.MR_Items_Id = @_MR_Item_Id;


                    SELECT @Item_Name = ISNULL(Item_Name, 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10)))
            FROM M_Item
            WHERE Item_Id = @Item_Id;

            IF @Item_Name IS NULL
            BEGIN
                SET @Item_Name = 'Item ID: ' + CAST(@Item_Id AS VARCHAR(10));
            END

            SET @Process_Type = 'Issue';
            SET @Status = 'Issued';
            SET @Action_Details = 'This is issued to ' + 
                                  CASE WHEN 1 = 1 THEN 'Production' ELSE 'Warehouse' END + 
                                  ' with ' + CAST(@_ReceiveQty AS NVARCHAR(10)) + ' items (' + @Item_Name + ')' +
                                  CASE WHEN @Dept_ID = 1 THEN ', Length: ' + ISNULL(CAST(@Length AS NVARCHAR(20)), 'Unknown') ELSE '' END + '.';

            INSERT INTO BOM_Logs (
                Process_Type, Project_Id, Quantity, Status, Action_Details, Project_Code,
                Department_Code, Entry_User, Entry_Date
            )
            VALUES (
                @Process_Type, @Project_Id, @_ReceiveQty, @Status, @Action_Details,
                @Project_Code, @Department_Code, @Entry_User, dbo.Get_sysdate()
            );


          END


                  FETCH next FROM db_cursor INTO @_PODtl_Id, @_Item_Id,@_SupDetail_Id ,@_OrderQty, @_ReceiveQty, @_Unit_Id, @_Length,       
      @_Weight,@_TotalWeight ,@_UnitCost, @_ReceiveCost, @_TotalCost, @_Remark, @_IsSeletd, @_IsCoated,          
                  @_Width, @_Rack_Id , @_Material_Value, @_Coating_Value,@_MR_Item_Id        
              END          
          
            CLOSE db_cursor          
          
            DEALLOCATE db_cursor      
            
            /* ?? CHECK IF DC IS FULLY CLOSED */
            IF NOT EXISTS (
                SELECT 1
                FROM DC_Dtl
                WHERE DC_Id = @DC_Id
                  AND ISNULL(Pending_Qty,0) > 0
            )
            BEGIN
             -- Update Coating_Request
                UPDATE CR
                SET CR.Is_read = 3
                FROM DC_Mst DM
                INNER JOIN Coating_Request CR 
                    ON CR.Coating_Req_Id = DM.Coating_Req_Id
                WHERE DM.DC_Id = @DC_Id
                  AND ISNULL(CR.Is_read,0) <> 3;

                -- Update MR_Items only when Is_read = 3
                UPDATE MI
                SET MI.Cmp_Job_Work = 2
                FROM MR_Items MI
                INNER JOIN Coating_RequestDtl CRD 
                    ON CRD.BOM_Dtl_Id = MI.MR_Items_Id
                INNER JOIN DC_Mst DM 
                    ON DM.Coating_Req_Id = CRD.Coating_Req_Id
                INNER JOIN Coating_Request CR
                    ON CR.Coating_Req_Id = DM.Coating_Req_Id
                WHERE DM.DC_Id = @DC_Id
                  AND ISNULL(CR.Is_read,0) = 3;
            END
            
          
            COMMIT          
        /************************************* COMMIT *************************************/          
        END          
  END try          
          
  BEGIN catch          
      ROLLBACK          
          
      /************************************* ROLLBACK *************************************/          
      SET @RetVal = -405          
      -- 0 IS FOR ERROR                                                            
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
  END catch
GO


