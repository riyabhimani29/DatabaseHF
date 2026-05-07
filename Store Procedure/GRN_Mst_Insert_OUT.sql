USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_Mst_Insert_OUT]    Script Date: 27-04-2026 11:39:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                             

                                             
ALTER    PROCEDURE [dbo].[GRN_Mst_Insert_OUT] @PO_Type        VARCHAR(500),                          
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
              @_Invoice_No AS INT = 0                          
                          
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
                             
      SELECT @_Invoice_No = Isnull(Max(GRN_Mst.Invoice_No), 0) + 1                    
      FROM   GRN_Mst WITH(nolock)                          
      WHERE  GRN_Mst.year_id = @Year_Id                          
                          
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
       Glass_QR_Id,    
    Entry_Type)                          
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
  'GRN-OUT')                          
                          
      SET @RetMsg ='GRN Generate Successfully And Generated GRN No is : ' + @GRN_No + ' .'                          
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
                    @_PendingQty    AS NUMERIC(18,3) =0,
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
                    @_Rack_Id  AS INT= 0                         
                          
            DECLARE db_cursor CURSOR FOR                          
              SELECT podtl_id,                           
                     item_id,                        
                     supdetail_id,                          
                     orderqty,                          
                     receiveqty,
                     PendingQty,
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
      Rack_Id                    
              FROM   @DtlPara;                          
     
            OPEN db_cursor                          
                          
            FETCH next FROM db_cursor INTO @_PODtl_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty, @_ReceiveQty,@_PendingQty, @_Unit_Id, @_Length, @_Weight, @_TotalWeight, @_UnitCost, @_ReceiveCost, @_TotalCost, @_Remark, @_IsSeletd, @_IsCoated, @_Width , @_Rack_Id       
  
    
       
       
          
             
                      
            WHILE @@FETCH_STATUS = 0                          
              BEGIN                     
                         
     declare @_DtlIId as int =0                    
                  IF ( @_ReceiveQty > 0 and  @_Rack_Id > 0)  /*  if (@_IsSeletd = 1)                        */                          
                    BEGIN                     
                     
                        INSERT INTO GRN_Dtl WITH(rowlock)                          
                                    (GRN_Id,                          
                                     PODtl_Id,                          
                                     Item_Group_Id,                          
                                     Item_Cate_Id,                          
                                     Item_Id,                          
                                     SupDetail_Id,                          
                                     OrderQty,                          
                 ReceiveQty,                          
                                     Unit_Id,                          
                                     [Length],                          
                                     Weight,                          
                                     TotalWeight,                          
                                     UnitCost,                          
                                    ReceiveCost,                          
                                     TotalCost,                          
                                     Remark,                          
                                     SType,                          
                                     Width,                    
                                     Rack_Id)                          
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
                                     @_Rack_Id)                   
                          
      set @_DtlIId = SCOPE_IDENTITY()          
           
      if (@Glass_QR_Id > 0)                       
      begin           

        IF(@_ReceiveQty = @_PendingQty)
         BEGIN
     
			 UPDATE GLASSQR_DTL WITH (rowlock)      
			 SET  Is_out = 1,      
				 GrnDtl_Id = @_DtlIId      
			 WHERE  GLASSQR_DTL.PODtl_Id = @_PODtl_Id      
				 AND GLASSQR_DTL.Is_out = 0    
				AND GLASSQR_DTL.QR_Typedtl = 'OUT'  
				 AND GLASSQR_DTL.GlassQRDtl_Id IN (SELECT GlassQRDtl_Id      
						FROM   (SELECT Row_number()  OVER( ORDER BY GlassQRDtl_Id ASC) AS Row#,      
							 GlassQRDtl_Id      
						  FROM   GLASSQR_DTL WITH (nolock )      
						  WHERE  GLASSQR_DTL.PODtl_Id = @_PODtl_Id        
									AND GLASSQR_DTL.QR_Typedtl = 'OUT'
									AND GlassQR_Dtl.Is_Out  = 0 )A      
						WHERE  A.row# <= @_ReceiveQty)   
           END
        
      end          
         
      --if (@_PODtl_Id > 0)                       
      --begin                      
      --    UPDATE PO_DTL with (rowlock)                          
      --    SET   PendingQty = Isnull(PendingQty, 0) - @_ReceiveQty                          
      --    WHERE  PO_DTL.PODtl_Id = @_PODtl_Id                            
      --end                       
                      
                        IF EXISTS(SELECT 1                          
                                FROM   StockView WITH (nolock)                          
                                  WHERE  Godown_Id = @Godown_Id                          
                                         AND Item_Id = @_Item_Id                          
                                         AND [Length] = @_Length                          
                                         AND Width = @_Width                          
                                         AND Rack_Id = @_Rack_Id                        
                                         AND SType = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ))                          
                          BEGIN                          
                              UPDATE StockView WITH (rowlock)                          
                              SET    --total_qty = Isnull(total_qty, 0) + @_ReceiveQty,                          
                                     pending_qty = Isnull(pending_qty, 0) - @_ReceiveQty ,                          
                                     lastupdate = dbo.Get_sysdate()  ,                
									 StockEntryPage = 'GRN-OUT'  ,              
									 StockEntryQty = @_ReceiveQty ,          
									 Dtl_Id = @_DtlIId ,          
									 Tbl_Name = 'GRN_Dtl'          
                              WHERE  godown_id = @Godown_Id                          
                                     AND item_id = @_Item_Id                          
                                     AND [length] = @_Length                          
                                    AND width = @_Width                        
                                     AND Rack_Id = @_Rack_Id                        
                                     AND stype = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END )                     
                               
                                 update GRN_Dtl set Stock_Id = (SELECT top 1 StockView.Id                          
                                  FROM   StockView WITH (nolock)                          
                                  WHERE  godown_id = @Godown_Id                          
                                    AND item_id = @_Item_Id                          
                                         AND [length] = @_Length                          
                                         AND width = @_Width                          
                                         AND Rack_Id = @_Rack_Id                        
                                         AND stype = ( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ))  where GrnDtl_Id = @_DtlIId                    
                          END                          
--                        ELSE                          
--                          BEGIN                  
                  
--                 INSERT INTO StockView WITH(rowlock)                          
--                                          (godown_id,                          
--                                           item_id,                          
--                                           total_qty,                          
--                                           sales_qty,                
--                                           pending_qty,                          
--                                           [length],                          
--                                           stype,                          
--           lastupdate,                          
--                                           width ,                    
--                                           Rack_Id,                
--            StockEntryPage,              
--            StockEntryQty,          
--            Dtl_Id ,          
--            Tbl_Name)                          
--                              VALUES      ( @Godown_Id,                          
--                                            @_Item_Id,                          
--                                            @_ReceiveQty,                          
--                                            0,                          
--                                            @_ReceiveQty,                          
--                                            @_Length,                          
--( CASE WHEN @_IsCoated = 1 THEN 'C' ELSE 'N' END ),                          
--                                            dbo.Get_sysdate(),                       
--                                            @_Width ,                    
--                                            @_Rack_Id,                
--             'GRN-OUT',              
--             @_ReceiveQty ,          
--             @_DtlIId ,          
--             'GRN_Dtl')                       
                               
--         update GRN_Dtl set Stock_Id = SCOPE_IDENTITY()  where GrnDtl_Id = @_DtlIId                    
--                          END                          
                    END                          
                          
                  FETCH next FROM db_cursor INTO @_PODtl_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty, @_ReceiveQty,@_PendingQty, @_Unit_Id, @_Length, @_Weight,                
     @_TotalWeight, @_UnitCost, @_ReceiveCost, @_TotalCost,  @_Remark, @_IsSeletd, @_IsCoated, @_Width, @_Rack_Id                         
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
