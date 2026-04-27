USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_Insert]    Script Date: 27-04-2026 11:39:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





                                        
ALTER    PROCEDURE [dbo].[GRN_Mst_Insert] @PO_Type        VARCHAR(500),                          
                                       @GRN_Id         INT,                          
                                       @PO_Id          INT,                           
                                       @Glass_QR_Id          INT,                         
                                       @Dept_ID        INT,                          
                                       @GRN_No         VARCHAR(500),                          
                                       @Challan_No     VARCHAR(500),                          
                                       @GRN_Date       DATE,                          
                                       @Challan_Date   DATE,                          
                                       @ReqRaisedBy_Id INT,                          
                                       @Supplier_Id    INT,                          
                                       @Godown_Id      INT,                          
                                       @Vehicle_No     VARCHAR(500),                          
                                       @EwayBill_No    VARCHAR(500),                          
                                       @GrossAmount    NUMERIC(18, 3),                          
                                       @AdvanceAmount  NUMERIC(18, 3),
                                        @DiscountAmountOverall NUMERIC(18, 3),
                                       @DiscountPercentageOverall NUMERIC(18, 3),
                                       @OtherAmount    NUMERIC(18, 3),   
                                       @Insurance      NUMERIC(18,3),
                                       @NetAmount      NUMERIC(18, 3),                          
                                       @ReceiveBy_Id   INT,                          
                                       @CheckBy_Id     INT,                          
                                       @Remark         VARCHAR(500),                          
                                       @MAC_Add        VARCHAR(500),                          
                                       @CGST           INT,                          
                                       @CGSTTotal      NUMERIC(18, 3),                          
                                       @SGST           INT,                          
                                       @SGSTTotal      NUMERIC(18, 3),                          
                                       @IGST           INT,                          
                                       @IGSTTotal      NUMERIC(18, 3),             
                                       @Entry_Type     VARCHAR(500) ='',                 
                                       @Entry_User     INT,                          
                                       @Upd_User       INT,                          
                                       @Year_Id        INT,                          
                                       @Branch_ID      INT,                          
                                       @DtlPara        TBL_POGRNDETAILs readonly,                          
                                       @RetVal         INT = 0 out,                          
                                       @RetMsg         VARCHAR(max) = '' out                          
AS                          
    SET nocount ON                          
                           
 set @Year_Id = dbo.Get_Financial_YearId(CONVERT (date, @GRN_Date ))                       
                       
 declare @_Financial_Year as int = 0                        
 Set @_Financial_Year = dbo.Get_Financial_Year(CONVERT (date, @GRN_Date ))                       
                       
  BEGIN try                          
      BEGIN TRANSACTION                          
                          
      /************************************* TRANSACTION *************************************/                          
      DECLARE @_DeptShortNm AS VARCHAR(20)='GRN',                          
              @_Invoice_No  AS INT = 0                          
                          
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
                    + '/'                          
                    + CONVERT(VARCHAR(20), @_Financial_Year)                          
                          
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
                   Insurance,
                   DiscountAmountOverall,
                   DiscountPercentageOverall,
                   netamount,                          
                   ReceiveBy_Id,                          
                   CheckBy_Id,                          
                   remark,                          
                   mac_add,                          
                   entry_user,                          
                   [cgst],                          
                   [sgst],                          
                   [igst],                          
                   [cgsttotal],                          
                   [sgsttotal],                          
                   [igsttotal],                          
                   entry_date,                          
                   year_id,                          
                   branch_id,        
       Glass_QR_Id,Inv_No)                          
      VALUES      ( @PO_Type,                          
                    @GRN_No,                          
                    @PO_Id,                          
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
    @Insurance,
     @DiscountAmountOverall,
                                       @DiscountPercentageOverall,
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
     @Glass_QR_Id,  
  '')                          
                          
      SET @RetMsg ='GRN Generate Successfully And Generated GRN No is : ' + @GRN_No + ' .'                          
      SET @RetVal = Scope_identity()                          
                          
      IF @@ERROR <> 0                          
        BEGIN                          
        SET @RetVal = -404 -- 0 IS FOR ERROR                                            
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'                          
        END                          
      ELSE                          
        BEGIN                          
            DECLARE @_Req_Id      AS INT= 0,
                    @_PODtl_Id      AS INT= 0,                          
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
                    @_IsCoated      AS BIT ,                          
                    @_Rack_Id  AS INT= 0,
                    @_Length_Meter AS NUMERIC(18,3) = 0,
                    @_Discount_Percentage AS NUMERIC(18,3) = 0,
                    @_Discount_Amount  AS NUMERIC(18,3) = 0
                          
            DECLARE db_cursor CURSOR FOR                          
              SELECT Req_Id,
                     podtl_id,                           
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
                     width  ,                    
                     Rack_Id,
                     Length_Meter,
                     Discount_Percentage,
                     Discount_Amount
              FROM   @DtlPara;                          
                          
            OPEN db_cursor                     
                          
            FETCH next FROM db_cursor INTO @_Req_Id, @_PODtl_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty, @_ReceiveQty, @_Unit_Id, @_Length, @_Weight, @_TotalWeight, @_UnitCost, @_ReceiveCost, @_TotalCost, @_Remark, @_IsSeletd, @_IsCoated, @_Width , @_Rack_Id, @_Length_Meter,@_Discount_Percentage ,@_Discount_Amount      
       
       
          
             
                      
            WHILE @@FETCH_STATUS = 0                          
              BEGIN                     
                         
				declare @_DtlIId as int =0,
                @_NewWeight AS NUMERIC(18,3)=0
                  IF ( @_ReceiveQty > 0 and  @_Rack_Id > 0)  /*  if (@_IsSeletd = 1)                        */                          
                    BEGIN                     
                     
                        INSERT INTO GRN_Dtl WITH(rowlock)                          
                                    (grn_id,  
                                    Req_Id,
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
                                     Rack_Id,
                                     Length_Meter,
                                     Discount_Percentage,
                                     Discount_Amount)                          
                        VALUES      ( @RetVal,     
                        @_Req_Id,
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
                                     @_Rack_Id,
                                     @_Length_Meter,
                                     @_Discount_Percentage,
                                     @_Discount_Amount  )                   
                          
					set @_DtlIId = SCOPE_IDENTITY() 
                    
-------------------------------------------------------------
-- ? UPDATE PR_DTL (CORRECT FLOW)
IF (@_PODtl_Id > 0)
BEGIN
    UPDATE D
    SET D.Is_Read = 6
    FROM PO_DTL PO
    INNER JOIN PR_DTL D 
        ON D.PrDtl_Id = PO.Req_Id
    WHERE PO.PODtl_Id = @_PODtl_Id
      AND ISNULL(D.Is_Checked,0) = 1
      AND D.Supplier_Id = @Supplier_Id;
END

-- ? UPDATE BOM_PO_RequestDtl (CORRECT FLOW)
IF (@_PODtl_Id > 0)
BEGIN
    UPDATE R
    SET R.IS_PO = 6
    FROM PO_DTL PO
    INNER JOIN PR_DTL D 
        ON D.PrDtl_Id = PO.Req_Id
    INNER JOIN BOM_PO_RequestDtl R
        ON R.BOM_PO_ReqDtl_Id = D.Req_Id
    WHERE PO.PODtl_Id = @_PODtl_Id;
END
-------------------------------------------------------------

  /* ===================== New Weight CALCULATION ===================== */
                 IF (@Dept_ID = 1)
                 BEGIN
                 DECLARE @_CurrentWeight NUMERIC(18,3);
            

            SELECT  @_CurrentWeight = ISNULL(Weight_Mtr, 0)  FROM M_Item WITH (NOLOCK)
            WHERE Item_Id = @_Item_Id;

            SET @_NewWeight = ( @_TotalWeight *1000)/(@_ReceiveQty * @_Length);


                UPDATE M_Item
                SET Weight_Mtr = @_NewWeight
                WHERE Item_Id = @_Item_Id
           --     UPDATE GRN_Dtl
           --     SET Weight = @_NewWeight , TotalWeight =( CASE
                                                        --    WHEN @_Width = 0 THEN (@_NewWeight * @_Length * @_ReceiveQty)/1000
                                                        --    ELSE ((@_NewWeight * @_Length * @_ReceiveQty * (@_Width /1000))/1000)
                                                        --    END)
                                                                
              --  WHERE GrnDtl_Id = @_DtlIId
            END


/* ===================== AVERAGE COST CALCULATION ===================== */

DECLARE 
    @_CurrentQty   NUMERIC(18,3),
    @_CurrentRate  NUMERIC(18,3),
    @_NewAvgWeight NUMERIC(18,3),
    @_NewAvgCost   NUMERIC(18,3);

/* Get current stock quantity */
SELECT @_CurrentQty = ISNULL(SUM(pending_qty), 0)
FROM StockView WITH (NOLOCK)
WHERE item_id = @_Item_Id;

/* Get current item rate */
SELECT @_CurrentRate = ISNULL(Item_Rate, 0)
FROM M_Item WITH (NOLOCK)
WHERE Item_Id = @_Item_Id;

/* Calculate weighted average cost (no IF, no divide-by-zero) */
SET @_NewAvgCost =
(
    (@_CurrentQty * @_CurrentRate) +
    (@_ReceiveQty * @_UnitCost)
)
/
NULLIF((@_CurrentQty + @_ReceiveQty), 0); 

IF (@_Item_Id > 0 AND @_UnitCost > 0)
BEGIN
    UPDATE M_Item WITH (ROWLOCK)
    SET  Avg_Cost = @_NewAvgCost,
         Item_Rate = @_UnitCost,
         Upd_Date = dbo.Get_sysdate()
    WHERE Item_Id = @_Item_Id;
END
/* ===================== AVERAGE WEIGHT CALCULATION ===================== */
 IF (@Dept_ID = 1)
 BEGIN
SET @_NewAvgWeight =
(
    (@_CurrentQty * @_CurrentWeight) +   -- ?? OLD (ACTUAL) WEIGHT USED
    (@_ReceiveQty * ISNULL(@_NewWeight, @_CurrentWeight))
)
/
NULLIF((@_CurrentQty + @_ReceiveQty), 0);

 UPDATE M_Item
                SET AvgWeight = @_NewAvgWeight
                WHERE Item_Id = @_Item_Id
END

/* ===================== AVERAGE WEIGHT CALCULATION ===================== */
           
           IF (@_Req_Id > 0)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM BOM_PO_RequestDtl
        WHERE BOM_PO_ReqDtl_Id = @_Req_Id 
          AND Qty = ISNULL(Grn_Qty, 0) + @_ReceiveQty
    )
    BEGIN
        UPDATE BOM_PO_RequestDtl
        SET Grn_Qty = ISNULL(Grn_Qty, 0) + @_ReceiveQty,
            Is_Requested = 3
        WHERE BOM_PO_ReqDtl_Id = @_Req_Id;
    END
    ELSE
    BEGIN
        UPDATE BOM_PO_RequestDtl
        SET Grn_Qty = ISNULL(Grn_Qty, 0) + @_ReceiveQty
        WHERE BOM_PO_ReqDtl_Id = @_Req_Id;
    END
END

				  if (@Glass_QR_Id > 0)                       
				  begin           
						 UPDATE GLASSQR_DTL WITH (rowlock)      
						 SET    Is_GRN = 1,      
								GrnDtl_Id = @_DtlIId      
						 WHERE  GLASSQR_DTL.PODtl_Id = @_PODtl_Id      
							 AND GLASSQR_DTL.Is_GRN = 0      
							 AND GLASSQR_DTL.QR_Typedtl = ''    
							 AND GLASSQR_DTL.GlassQRDtl_Id IN (SELECT GlassQRDtl_Id      
									FROM   (SELECT Row_number()  OVER( ORDER BY GlassQRDtl_Id ASC) AS Row#,      
												GlassQRDtl_Id      
									  FROM   GLASSQR_DTL WITH (nolock )      
									  WHERE  GLASSQR_DTL.PODtl_Id = @_PODtl_Id    
												AND GLASSQR_DTL.QR_Typedtl = '' and GlassQR_Dtl.Is_GRN = 0  )A      
									WHERE  A.row# <= @_ReceiveQty)       
        
			   -- update articles        
			   --set num_comments =        
			   --(select count (*) from comments        
			   --where comments.article_id = articles.id)        
        
				  end          
        
        
				  if (@_PODtl_Id > 0)                       
				  begin                      
					  UPDATE PO_DTL with (rowlock)                          
					  SET   PendingQty = Isnull(PendingQty, 0) - @_ReceiveQty                          
					  WHERE  PO_DTL.PODtl_Id = @_PODtl_Id                            
				  end                       
                      
                        IF EXISTS(SELECT 1                          
                                FROM   StockView WITH (nolock)                          
                                  WHERE  godown_id = @Godown_Id
                                         AND item_id = @_Item_Id                          
                                         AND [length] = @_Length                          
                                         AND width = @_Width                          
                                         AND Rack_Id = @_Rack_Id                        
                                         AND stype = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ))                          
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
                                    Stock_Id
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
                                    'PO-GRN',
                                    'PO-GRN',
                                    'OpeningStock',
                                    'IN',
                                    0,
                                    @_DtlIId,
                                    @_StockView_Id
                                );

                              UPDATE stockview WITH (rowlock)                          
                              SET    total_qty = Isnull(total_qty, 0) + @_ReceiveQty,                          
                                     pending_qty = Isnull(pending_qty, 0) + @_ReceiveQty ,                          
                                     lastupdate = dbo.Get_sysdate()  ,                
            StockEntryPage = 'PO-GRN'  ,              
            StockEntryQty = @_ReceiveQty ,          
            Dtl_Id = @_DtlIId ,          
            Tbl_Name = 'GRN_Dtl'
         
                              WHERE  godown_id = @Godown_Id
                                     AND item_id = @_Item_Id                          
                                     AND [length] = @_Length                          
                                    AND width = @_Width                        
                                     AND Rack_Id = @_Rack_Id                        
                                     AND stype = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END )                     
                               
                                 update GRN_Dtl set Stock_Id = (SELECT top 1 stockview.Id                          
                                  FROM   StockView WITH (nolock)                          
                                  WHERE  godown_id = @Godown_Id                          
                                    AND item_id = @_Item_Id                          
                                         AND [length] = @_Length                          
                                         AND width = @_Width         
                                         AND Rack_Id = @_Rack_Id                        
                                         AND stype = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ))  where GrnDtl_Id = @_DtlIId                    
                          END                          
                        ELSE                          
                          BEGIN                  
                  
                    /* ===== NEW : STOCK TRANSFER HISTORY (GRN - UPDATE) ===== */
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
                                Stock_Id
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
                                'PO-GRN',
                                'PO-GRN',
                                'OpeningStock',
                                'IN',
                                0,
                                @_DtlIId,
                                NULL
                            );
                    SET @_History_Id = SCOPE_IDENTITY();

                 INSERT INTO stockview WITH(rowlock)                          
                                          (godown_id,                          
         item_id,                          
                                           total_qty,                          
                                           sales_qty,                          
                                           pending_qty,                          
                                           [length],                          
                                           stype,                          
           lastupdate,                          
                                           width ,                    
                                           Rack_Id,                
             StockEntryPage,              
             StockEntryQty,          
             Dtl_Id ,          
             Tbl_Name,
             GRN_Id)                          
                              VALUES      ( @Godown_Id,                          
                                            @_Item_Id,                          
                                            @_ReceiveQty,                          
                                            0,                          
                                            @_ReceiveQty,                          
                                            @_Length,                          
( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ),                          
                                            dbo.Get_sysdate(),                       
                                            @_Width ,                    
                                            @_Rack_Id,                
                                            'PO-GRN',              
                                            @_ReceiveQty ,          
                                            @_DtlIId ,          
                                            'GRN_Dtl',
                                            @RetVal)                       
                               
         update GRN_Dtl set Stock_Id = SCOPE_IDENTITY()  where GrnDtl_Id = @_DtlIId 
         update Stock_Transfer_History set Stock_Id = SCOPE_IDENTITY() where ID = @_History_Id;
                          END                          
                    END                          
                          
                  FETCH next FROM db_cursor INTO @_Req_Id, @_PODtl_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty, @_ReceiveQty, @_Unit_Id, @_Length, @_Weight,                
     @_TotalWeight, @_UnitCost, @_ReceiveCost, @_TotalCost,  @_Remark, @_IsSeletd, @_IsCoated, @_Width, @_Rack_Id,@_Length_Meter,@_Discount_Percentage ,@_Discount_Amount                          
              END                          
                          
            CLOSE db_cursor                          
                          
            DEALLOCATE db_cursor                          
                          
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


