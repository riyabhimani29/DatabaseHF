USE [db_a8637c_hifaberp]
GO
/****** Object:  StoredProcedure [dbo].[Stocktrans_mst_insert_new]    Script Date: 13-05-2026 11:08:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[Stocktrans_mst_insert_new] @Trans_Type           VARCHAR (500),  
                                                   @FrGodown_Id          INT,  
                                                   @ToGodown_Id          INT,  
                                                   @TransDate            DATE,  
                                                   @IssueBy              INT,  
                                                   @ReceiveBy            INT,  
                                                   @ProjectDocument      VARCHAR (500),  
                                                   @ProductionDepartment VARCHAR (500 ),  
                                                   @Remark               VARCHAR (500),  
                                                   @MAC_Add              VARCHAR (500 ),  
                                                   @Entry_User           INT,  
                                                   @Upd_User             INT,  
                                                   @Year_Id              INT,  
                                                   @Branch_ID            INT,  
                                                   @Is_ProDept           BIT,  
                                                   @DtlPara    TBL_STKTRANS_NEWs readonly,  
                                                   @RetVal               INT = 0 out,  
                                                   @RetMsg               VARCHAR (max) = '' out  
AS  
    SET nocount ON  
  
  BEGIN try  
      BEGIN TRANSACTION  
  
      /************************************* TRANSACTION *************************************/  
      INSERT INTO StockTrans_Mst WITH(rowlock)  
                  (frgodown_id,  
                   transdate,  
                   togodown_id,  
                   issueby,  
                   receiveby,  
                   projectdocument,  
                   productiondepartment,  
                   remark,  
                   mac_add,  
                   entry_user,  
                   entry_date,  
                   year_id,  
                   branch_id,  
                   is_prodept,  
                   trans_type)  
      VALUES      ( @FrGodown_Id,  
                    dbo.Get_sysdate(),  
                    @ToGodown_Id,  
                    @IssueBy,  
                    @ReceiveBy,  
                    @ProjectDocument,  
                    @ProductionDepartment,  
                    @Remark,  
                    @MAC_Add,  
                    @Entry_User,  
                    dbo.Get_sysdate(),  
                    @Year_Id,  
                    @Branch_ID,  
                    @Is_ProDept,  
                    @Trans_Type)  
  
      SET @RetMsg ='Stock Transfer Successfully.'  
      SET @RetVal = Scope_identity()  
  
      IF @@ERROR <> 0  
        BEGIN  
            SET @RetVal = 0  
            -- 0 IS FOR ERROR                                                             
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
        END  
      ELSE  
        BEGIN  
            DECLARE @_Id           AS INT= 0,  
                    @_Item_Id      AS INT= 0,
                    @_Item_code     AS VARCHAR(50)= '',
                    @_Qty          AS NUMERIC(18, 3) = 0,  
                    @_Length       AS NUMERIC(18, 3) = 0,  
                    @_Width        AS NUMERIC(18, 3) = 0,  
                    @_SplitLength  AS NUMERIC(18, 3) = 0,  
                    @_IsSplit      AS BIT = 0,  
                    @_Remark       AS VARCHAR(500)= '',  
                    @_SType        AS VARCHAR(500)= '',  
                    @_Rack_Id      AS INT= 0,  
                    @_FrRack_Id    AS INT= 0,  
                    @_ToRack_Id    AS INT= 0,  
                    @_FrGodown_Id2 AS INT= 0,  
                    @_ToGodown_Id2 AS INT= 0  
  
            DECLARE db_cursor CURSOR FOR  
              SELECT Item_Id, 
                     Item_Code,
                     qty,  
                     id,  
                     [Length],  
                     Width,  
                     remark,  
                     SType,  
                     splitlength,  
                     issplit,  
                     Rack_Id,  
                     frrack_id,  
                     torack_id,  
                     FrGodown_Id,  
                     ToGodown_Id  
              FROM   @DtlPara;  
  
            OPEN db_cursor  
  
            FETCH next FROM db_cursor INTO @_Item_Id,@_Item_code, @_Qty, @_Id, @_Length,  @_Width,  
            @_Remark, @_SType, @_SplitLength, @_IsSplit, @_Rack_Id, @_FrRack_Id,  
            @_ToRack_Id, @_FrGodown_Id2, @_ToGodown_Id2  
  
            WHILE @@FETCH_STATUS = 0  
              BEGIN  
                  INSERT INTO StockTrans_Dtl WITH(rowlock)  
                              (TransId,  
                               Item_Id,  
                               Qty,  
                               Stock_Id,  
                               Remark,  
                               IsSplit,  
                               SplitLength,  
                               Rack_Id,  
                               FrRack_Id,  
                               ToRack_Id,  
                               Fr_Godown_Id,  
                               To_Godown_Id)  
                  VALUES      (@RetVal,  
                               @_Item_Id,  
                               @_Qty,  
                               @_Id,  
                               @_Remark,  
                               @_IsSplit,  
                               @_SplitLength,  
                               @_Rack_Id,  
                               @_FrRack_Id,  
                               @_ToRack_Id,  
                               @_FrGodown_Id2,  
                               @_ToGodown_Id2)  
  
                  DECLARE @_PendLength AS NUMERIC(18, 3) =0  
                  DECLARE @_V AS INT = Scope_identity()  
  
                  SET @_PendLength = (isnull(@_Length,0) - isnull(@_SplitLength,0)  )--+0.001
  
   --SET @RetMsg ='Stock Transfer Successfully. @@@'   + Convert(varchar(15), @_PendLength)
   --   SET @RetVal = -101
	  --rollback
	  --return

                  DECLARE @_S AS CHAR(1)='' 
                  Declare @_History_Id AS INT = NULL;
  
                  SET @_S = CASE  
                              WHEN @_SType = 'Non-Coated' THEN 'N'  
                              ELSE 'C'  
                            END  
  
                  IF ( @Trans_Type = 'SPLIT_LENGTH' )  
                    BEGIN 
                        /**********************************/  
                        IF EXISTS (SELECT 1  
                                   FROM   StockView WITH (nolock)  
                                   WHERE  item_id = @_Item_Id  
                                          AND godown_id = @_FrGodown_Id2  
                                          AND [length] = @_PendLength  
                                          AND stype = @_S  
                                          AND width = @_Width  
                                          AND rack_id = @_FrRack_Id)  
              BEGIN 
              
              
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
                            Stock_Id,
                            StockTrans_Dtl_Id
                        )
                        VALUES
                        (
                            @_FrGodown_Id2,
                            @_Item_Id,
                            @_S,
                            @_Qty,
                            @_PendLength,       
                            @_Width,
                            @_FrRack_Id,
                            dbo.Get_sysdate(),
                            'Pending Length',
                            'STK-TRANS',
                            'StockTrans_Dtl',
                            'IN',
                            0,
                            NULL,               
                            @_V
                        );
                   SET @_History_Id = NULL;
                   SET @_History_Id  = SCOPE_IDENTITY();


                  UPDATE stockview WITH (rowlock)  
                  SET    total_qty = Isnull (total_qty, 0) + @_Qty,  
                         pending_qty = Isnull (pending_qty, 0) + @_Qty ,  
                         lastupdate = dbo.Get_sysdate(),  
                         stockentrypage = 'STK-TRANS',  
                         stockentryqty = @_Qty,  
                         dtl_id = @_V,  
                         tbl_name = 'StockTrans_Dtl',  
                         RackNo = 'PEND  UPD'  
                  WHERE  item_id = @_Item_Id  
                         AND godown_id = @_FrGodown_Id2  
                         AND [length] =  @_PendLength  
                         AND stype = @_S  
                         AND width = @_Width  
                         AND rack_id = @_FrRack_Id  
  
                  UPDATE stocktrans_dtl WITH (rowlock)  
                  SET    newstock_id = (SELECT TOP 1 id  
                                        FROM   stockview WITH (nolock)  
                                        WHERE  item_id = @_Item_Id  
                                               AND godown_id = @_FrGodown_Id2  
                                               AND [length] = @_PendLength  
                                               AND stype = @_S  
                                               AND width = @_Width  
                                               AND rack_id = @_FrRack_Id)  
                                        WHERE  dtl_id = @_V  

                UPDATE Stock_Transfer_History
                    SET Stock_Id = (
                            SELECT newstock_id
                            FROM stocktrans_dtl WITH (NOLOCK)
                            WHERE dtl_id = @_V
                        )
                    WHERE Id = @_History_Id;
              END  
                        ELSE  
                          BEGIN
                          
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
                                Stock_Id,
                                StockTrans_Dtl_Id
                            )
                            VALUES
                            (
                                @_FrGodown_Id2,
                                @_Item_Id,
                                @_S,
                                @_Qty,
                                @_PendLength,       
                                @_Width,
                                @_FrRack_Id,
                                dbo.Get_sysdate(),
                                'Pending Length',
                                'STK-TRANS',
                                'StockTrans_Dtl',
                                'IN',
                                0,
                                NULL,               
                                @_V
                            );
                           SET @_History_Id = NULL;
                           SET @_History_Id  = SCOPE_IDENTITY();


                              INSERT INTO [dbo].[stockview] WITH (rowlock)  
                                          ([godown_id],  
                                           [item_id],  
                                           [stype],  
                                           [total_qty],  
                                           [sales_qty],  
                                           [pending_qty],  
                                           [length],  
                                           lastupdate,  
                                           width,  
                                           ref_id,  
                                           rack_id,  
                                           stockentrypage,  
                                           stockentryqty,  
                                           dtl_id,  
                                           tbl_name,  
                                           RackNo)  
                              VALUES      (@_FrGodown_Id2,  
                                           @_Item_Id,  
                                           @_S,  
                                           @_Qty,  
                                           0,  
                                           @_Qty,  
                                           @_PendLength,  
                                           dbo.Get_sysdate(),  
                                           @_Width,  
                                           @_Id,  
                                           @_FrRack_Id,  
                                           'STK-TRANS',  
                                           @_Qty,  
                                           @_V,  
                                           'StockTrans_Dtl',  
                                           'PEND  INS')  
                                           update Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                          --UPDATE stocktrans_dtl WITH (rowlock)    
                          --SET    newstock_id = Scope_identity()    
                          --WHERE  dtl_id = @_V    
                          END  
                    
 
                        IF EXISTS (SELECT 1  
                                   FROM   stockview WITH (nolock)  
                                   WHERE  item_id = @_Item_Id  
                                          AND godown_id = @_FrGodown_Id2  
                                          AND [length] = @_SplitLength  
                                          AND stype = @_S  
                                          AND width = @_Width  
                                          AND rack_id = @_FrRack_Id)  
							 BEGIN  

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
                                        Stock_Id,
                                        StockTrans_Dtl_Id
                                    )
                                    VALUES
                                    (
                                        @_FrGodown_Id2,
                                        @_Item_Id,
                                        @_S,
                                        @_Qty,
                                        @_SplitLength,       -- split/pending length
                                        @_Width,
                                        @_FrRack_Id,
                                        dbo.Get_sysdate(),
                                        'Split Length',
                                        'STK-TRANS',
                                        'StockTrans_Dtl',
                                        'IN',
                                        0,
                                        NULL,               -- will update after stockview update
                                        @_V
                                    );
                       SET @_History_Id = NULL;
                       SET @_History_Id  = SCOPE_IDENTITY();

							  UPDATE stockview WITH (rowlock)  
							  SET    total_qty = Isnull (total_qty, 0) + @_Qty,  
									   pending_qty = Isnull (pending_qty, 0) + @_Qty  ,  
									   lastupdate = dbo.Get_sysdate(),  
									   stockentrypage = 'STK-TRANS',  
									   stockentryqty = @_Qty,  
									   dtl_id = @_V,  
									   tbl_name = 'StockTrans_Dtl',  
									   RackNo = 'SplitLength  UPD'  
								  WHERE  item_id = @_Item_Id  
									   AND godown_id = @_FrGodown_Id2  
									   AND [length] = @_SplitLength  
									   AND stype = @_S  
									   AND width = @_Width  
									   AND rack_id = @_FrRack_Id  
  
							  UPDATE StockTrans_Dtl WITH (rowlock)  
							  SET    newstock_id = (SELECT TOP 1 id  
								  FROM   stockview WITH (nolock)  
								  WHERE  item_id = @_Item_Id  
									  AND godown_id = @_FrGodown_Id2  
									  AND [length] = @_SplitLength  
									  AND stype = @_S  
									  AND width = @_Width  
									  AND rack_id = @_FrRack_Id)  

							  WHERE  dtl_id = @_V  
                              UPDATE Stock_Transfer_History
                                SET Stock_Id = (
                                        SELECT newstock_id
                                        FROM stocktrans_dtl WITH (NOLOCK)
                                        WHERE dtl_id = @_V
                                    )
                                WHERE Id = @_History_Id;
							 END  
                        ELSE  
                          BEGIN  

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
                                Stock_Id,
                                StockTrans_Dtl_Id
                            )
                            VALUES
                            (
                                @_FrGodown_Id2,
                                @_Item_Id,
                                @_S,
                                @_Qty,
                                @_SplitLength,       
                                @_Width,
                                @_FrRack_Id,
                                dbo.Get_sysdate(),
                                'Split Length',
                                'STK-TRANS',
                                'StockTrans_Dtl',
                                'IN',
                                0,
                                NULL,               
                                @_V
                            );
                           SET @_History_Id = NULL;
                           SET @_History_Id  = SCOPE_IDENTITY();

                              INSERT INTO [dbo].[stockview] WITH (rowlock)  
											([godown_id],  
                                           [item_id],  
                                           [stype],  
                                           [total_qty],  
                                           [sales_qty],  
                                           [pending_qty],  
                                           [length],  
                                           lastupdate,  
                                           width,  
                                           ref_id,  
                                           rack_id,  
                                           stockentrypage,  
                                           stockentryqty,  
                                           dtl_id,  
                                           tbl_name,  
                                           RackNo)  
                              VALUES      (@_FrGodown_Id2,  
                                           @_Item_Id,  
                                           @_S,  
                                           @_Qty,  
                                           0,  
                                           @_Qty,  
                                           @_SplitLength,  
                                           dbo.Get_sysdate(),  
                                           @_Width,  
                                           @_Id,  
                                           @_FrRack_Id,  
                                           'STK-TRANS',  
                                           @_Qty,  
                                           @_V,  
                                           'StockTrans_Dtl',  
                                           'SplitLength  INS')  
                       update Stock_Transfer_History set Stock_Id = SCOPE_IDENTITY() where ID = @_History_Id;
                              UPDATE stocktrans_dtl WITH (rowlock)  
                              SET    newstock_id = Scope_identity()  
                              WHERE  dtl_id = @_V  
                          END  
  					
					
					END  
                  ELSE  
                    BEGIN  
                        IF ( @Trans_Type = 'G_TO_G' )  
                          --    IF ( @Is_ProDept = 0 )    
                          BEGIN  
                              IF EXISTS (SELECT 1  
                                         FROM   stockview WITH (nolock)  
                                         WHERE  item_id = @_Item_Id  
                                                AND godown_id = @_ToGodown_Id2  
                                                AND [length] = @_Length  
                                                AND stype = @_S  
                                                AND width = @_Width  
                                                AND rack_id = @_ToRack_Id)  
                    BEGIN 
                    
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
                            Stock_Id,
                            StockTrans_Dtl_Id
                        )
                        VALUES
                        (
                            @_ToGodown_Id2,
                            @_Item_Id,
                            @_S,
                            @_Qty,
                            @_Length,       
                            @_Width,
                            @_ToRack_Id,
                            dbo.Get_sysdate(),
                            'Godown-Godown',
                            'STK-TRANS',
                            'StockTrans_Dtl',
                            'IN',
                            0,
                            NULL,               
                            @_V
                        );
                   SET @_History_Id = NULL;
                   SET @_History_Id  = SCOPE_IDENTITY();


                        UPDATE stockview WITH (rowlock)  
                        SET    total_qty = Isnull (total_qty, 0) + @_Qty,  
                               pending_qty = Isnull (pending_qty, 0) + @_Qty ,  
                               lastupdate = dbo.Get_sysdate(),  
                               stockentrypage = 'STK-TRANS',  
                               stockentryqty = @_Qty,  
                               dtl_id = @_V,  
                               tbl_name = 'StockTrans_Dtl'  
                        WHERE  item_id = @_Item_Id  
                               AND godown_id = @_ToGodown_Id2  
                               AND [length] = @_Length  
                               AND stype = @_S  
                               AND width = @_Width  
                               AND rack_id = @_ToRack_Id  
  
                        UPDATE stocktrans_dtl WITH (rowlock)  
                        SET    newstock_id = (SELECT TOP 1 id  
                                              FROM   stockview WITH (nolock)  
                     WHERE  item_id = @_Item_Id  
                                                     AND godown_id = @_ToGodown_Id2  
                                                     AND [length] = @_Length  
                                                     AND stype = @_S  
                                                     AND width = @_Width  
                                                     AND rack_id = @_ToRack_Id)  
                                                     WHERE  dtl_id = @_V 
                       UPDATE Stock_Transfer_History
                            SET Stock_Id = (
                                    SELECT newstock_id
                                    FROM stocktrans_dtl WITH (NOLOCK)
                                    WHERE dtl_id = @_V
                                )
                            WHERE Id = @_History_Id;
                    END  
                              ELSE  
                                BEGIN  

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
                                            Stock_Id,
                                            StockTrans_Dtl_Id
                                        )
                                        VALUES
                                        (
                                            @_ToGodown_Id2,
                                            @_Item_Id,
                                            @_S,
                                            @_Qty,
                                            @_Length,       
                                            @_Width,
                                            @_ToRack_Id,
                                            dbo.Get_sysdate(),
                                            'Godown-Godown',
                                            'STK-TRANS',
                                            'StockTrans_Dtl',
                                            'IN',
                                            0,
                                            NULL,               
                                            @_V
                                        );
                                    SET @_History_Id = NULL;
                                    SET @_History_Id  = SCOPE_IDENTITY();

                                    INSERT INTO [dbo].[stockview] WITH (rowlock)  
                                                ([godown_id],  
                                                 [item_id],  
                                                 [stype],  
                                                 [total_qty],  
                                                 [sales_qty],  
                                                 [pending_qty],  
                                                 [length],  
                                                 lastupdate,  
                                                 width,  
                                                 rack_id,  
                                                 stockentrypage,  
                                                 stockentryqty,  
                                                 dtl_id,  
                                                 tbl_name)  
                                    VALUES      (@_ToGodown_Id2,  
                                                 @_Item_Id,  
                                                 @_S,  
                                                 @_Qty,  
                                                 0,  
                                                 @_Qty,  
                                                 @_Length,  
                                                 dbo.Get_sysdate(),  
                                                 @_Width,  
                                                 @_ToRack_Id,  
                                                 'STK-TRANS',  
                                                 @_Qty,  
                                                 @_V,  
                                                 'StockTrans_Dtl')  
  
                                    UPDATE stocktrans_dtl WITH (rowlock)  
                                    SET    newstock_id = Scope_identity()  
                                    WHERE  dtl_id = @_V
                                    update Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                                END  
                          END  
                    END  
  
                  IF ( @Trans_Type = 'R_TO_R' )  
                    BEGIN  
                        IF EXISTS (SELECT 1  
                                   FROM   StockView WITH (nolock)  
                                   WHERE  Item_Id = @_Item_Id  
                                          AND Godown_Id = @_FrGodown_Id2  
                                          AND [Length] = @_Length  
                                          AND SType = @_S  
                                          AND Width = @_Width  
                                          AND Rack_Id = @_ToRack_Id)  
              BEGIN 
              
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
                        Stock_Id,
                        StockTrans_Dtl_Id
                    )
                    VALUES
                    (
                        @_FrGodown_Id2,
                        @_Item_Id,
                        @_S,
                        @_Qty,
                        @_Length,       
                        @_Width,
                        @_ToRack_Id,
                        dbo.Get_sysdate(),
                        'Rack-Rack',
                        'STK-TRANS',
                        'StockTrans_Dtl',
                        'IN',
                        0,
                        NULL,               
                        @_V
                    );
                   SET @_History_Id = NULL;
                   SET @_History_Id  = SCOPE_IDENTITY();

                  UPDATE StockView WITH (rowlock)  
                  SET    total_qty = Isnull (total_qty, 0) + @_Qty,  
                         pending_qty = Isnull (pending_qty, 0) + @_Qty  
                         ,  
                         lastupdate = dbo.Get_sysdate(),  
                         stockentrypage = 'STK-TRANS',  
                         stockentryqty = @_Qty,  
                         dtl_id = @_V,  
                         tbl_name = 'StockTrans_Dtl'  
                  WHERE  Item_Id = @_Item_Id  
                         AND Godown_Id = @_FrGodown_Id2  
                         AND [Length] = @_Length  
                         AND SType = @_S  
                         AND Width = @_Width  
                   AND Rack_Id = @_ToRack_Id  
  
                  UPDATE StockTrans_Dtl WITH (rowlock)  
                  SET    newstock_id = (SELECT TOP 1 id  
                                        FROM   StockView WITH (nolock)  
                                        WHERE  Item_Id = @_Item_Id  
                                               AND Godown_Id =  
                                                   @_FrGodown_Id2  
                                               AND [Length] = @_Length  
                                               AND SType = @_S  
                                               AND Width = @_Width  
                                               AND Rack_Id = @_ToRack_Id)  
                                                WHERE  dtl_id = @_V  

                UPDATE Stock_Transfer_History
                      SET Stock_Id = (
                              SELECT newstock_id
                              FROM stocktrans_dtl WITH (NOLOCK)
                              WHERE dtl_id = @_V
                          )
                  WHERE Id = @_History_Id;
              END  
                        ELSE  
                          BEGIN 
                          
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
                                        Stock_Id,
                                        StockTrans_Dtl_Id
                                    )
                                    VALUES
                                    (
                                        @_FrGodown_Id2,
                                        @_Item_Id,
                                        @_S,
                                        @_Qty,
                                        @_Length,       
                                        @_Width,
                                        @_ToRack_Id,
                                        dbo.Get_sysdate(),
                                        'Rack-Rack',
                                        'STK-TRANS',
                                        'StockTrans_Dtl',
                                        'IN',
                                        0,
                                        NULL,               
                                        @_V
                                    );
                              SET @_History_Id = NULL;
                              SET @_History_Id  = SCOPE_IDENTITY();

                              INSERT INTO [dbo].[StockView]  
                                          ([Godown_Id],  
                                           [Item_Id],  
                                           [SType],  
                                           [total_qty],  
                                           [sales_qty],  
                                           [pending_qty],  
                                           [Length],  
                                           lastupdate,  
                                           Width,  
                                           Rack_Id,  
                                           stockentrypage,  
                                           stockentryqty,  
                                           dtl_id,  
                                           tbl_name)  
                              VALUES      (@_FrGodown_Id2,  
                                           @_Item_Id,  
                                           @_S,  
                                           @_Qty,  
                                           0,  
                                           @_Qty,  
                                           @_Length,  
                                           dbo.Get_sysdate(),  
                                           @_Width,  
                                           @_ToRack_Id,  
                                           'STK-TRANS',  
                                           @_Qty,  
                                           @_V,  
                                           'StockTrans_Dtl')  
  
                              UPDATE StockTrans_Dtl WITH (rowlock)  
                              SET    newstock_id = Scope_identity()  
                              WHERE  dtl_id = @_V 
                              update Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                          END  
                    END  
  
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
                        Stock_Id,
                        StockTrans_Dtl_Id
                    )
                    VALUES
                    (
                        @_FrGodown_Id2,         
                        @_Item_Id,
                        @_S,
                        @_Qty,                 
                        @_Length,              
                        @_Width,
                        @_FrRack_Id,
                        dbo.Get_sysdate(),
                        'Stock Transfer OUT',
                        'STK-TRANS',
                        'StockTrans_Dtl',
                        'OUT',                  
                        1,                      
                        @_Id,                   
                        @_V                     
                    );


                  UPDATE StockView WITH (rowlock)  
                  SET    pending_qty = Isnull (pending_qty, 0) - @_Qty,  
                         transfer_qty = Isnull(transfer_qty, 0) + @_Qty,  
                         lastupdate = dbo.Get_sysdate(),  
                         stockentrypage = 'STK-TRANS',  
                         stockentryqty = @_Qty,  
                         dtl_id = @_V,  
                         tbl_name = 'StockTrans_Dtl',  
                         prodept_qty = ( CASE  
                                           WHEN @Is_ProDept = 1 THEN  
                                           Isnull(prodept_qty, 0) + @_Qty  
                                           ELSE prodept_qty  
                                         END )  
                  WHERE  id = @_Id  
  
            FETCH next FROM db_cursor INTO @_Item_Id,@_Item_code, @_Qty, @_Id, @_Length,  @_Width,  
           @_Remark, @_SType, @_SplitLength, @_IsSplit, @_Rack_Id, @_FrRack_Id,  
           @_ToRack_Id, @_FrGodown_Id2, @_ToGodown_Id2  
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
