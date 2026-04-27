USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[StockTrans_Mst_Insert]    Script Date: 27-04-2026 15:01:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

   
ALTER  PROCEDURE [dbo].[StockTrans_Mst_Insert] @FrGodown_Id          INT,              
                                              @ToGodown_Id          INT,              
                                              @TransDate            DATE,              
                                              @IssueBy              INT,              
                                              @ReceiveBy            INT,              
                                              @ProjectDocument      VARCHAR(500) ,              
                                              @ProductionDepartment VARCHAR(500 ),              
                                              @Remark               VARCHAR(500) ,              
                                              @MAC_Add              VARCHAR(500 ),              
                                              @Entry_User           INT,              
                                              @Upd_User             INT,              
                                              @Year_Id              INT,              
                                              @Branch_ID            INT,              
                                              @Is_ProDept           BIT,              
                                              @DtlPara              TBL_STKTRANSDETAIL readonly,              
                                              @RetVal               INT = 0 out,              
                                              @RetMsg               VARCHAR(max) = '' out              
AS      
    SET nocount ON      
      
  BEGIN try      
      BEGIN TRANSACTION      
      
      /************************************* TRANSACTION *************************************/      
      INSERT INTO StockTrans_Mst WITH(rowlock)      
                  (FrGodown_Id,      
                   TransDate,      
                   ToGodown_Id,      
                   IssueBy,      
                   ReceiveBy,      
                   ProjectDocument,      
                   ProductionDepartment,      
                   Remark,      
                   MAC_Add,      
                   Entry_User,      
                   Entry_Date,      
                   Year_Id,      
                   Branch_ID,      
                   Is_ProDept)      
      VALUES      ( @FrGodown_Id,      
                    @TransDate,      
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
                    @Is_ProDept)      
      
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
            DECLARE @_Id          AS INT= 0,      
                    @_Item_Id     AS INT= 0,      
                    @_Qty         AS NUMERIC(18, 3) = 0,      
                    @_Length      AS NUMERIC(18, 3) = 0,      
                    @_Width       AS NUMERIC(18, 3) = 0,      
                    @_SplitLength AS NUMERIC(18, 3) = 0,      
                    @_IsSplit     AS BIT = 0,      
                    @_Remark      AS VARCHAR(500)= '',      
                    @_SType       AS VARCHAR(500)= '',      
                    @_Rack_Id     AS INT= 0    ,      
                    @_FrRack_Id     AS INT= 0  ,      
                    @_ToRack_Id     AS INT= 0    
  
  
            DECLARE db_cursor CURSOR FOR      
              SELECT Item_Id,      
                     Qty,      
                     id,      
                     [Length],      
                     Width,      
                     Remark,      
                     SType,      
                     splitlength,      
                     issplit,      
                     Rack_Id ,  
      FrRack_Id,  
      ToRack_Id  
              FROM   @DtlPara;      
      
            OPEN db_cursor      
      
            FETCH next FROM db_cursor INTO @_Item_Id, @_Qty, @_Id, @_Length, @_Width,      
            @_Remark, @_SType, @_SplitLength, @_IsSplit, @_Rack_Id  ,@_FrRack_Id ,  @_ToRack_Id  
      
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
							  ToRack_Id)      
                  VALUES      (@RetVal,      
                               @_Item_Id,      
                               @_Qty,      
                               @_Id,      
                               @_Remark,      
                               @_IsSplit,      
                               @_SplitLength,      
                               @_Rack_Id,  
							  @_FrRack_Id ,  
							  @_ToRack_Id)      
      
                  DECLARE @_PendLength AS NUMERIC(18, 3) =0      
				  declare @_V as int = Scope_identity()    
		
                  SET @_PendLength = @_Length - @_SplitLength      
      
                  DECLARE @_S AS CHAR(1)=''      
      
                  SET @_S = CASE      
                              WHEN @_SType = 'Non-Coated' THEN 'N'      
                              ELSE 'C'      
                            END      
      
                  IF ( @_IsSplit = 1 )      
                    BEGIN      
                        IF EXISTS (SELECT 1      
                                   FROM   StockView WITH (nolock)      
                                   WHERE  Item_Id = @_Item_Id      
                                          AND Godown_Id = @ToGodown_Id      
                                          AND [Length] = @_SplitLength      
                                          AND SType = @_S      
                                          AND Width = @_Width      
                                          AND Rack_Id = @_ToRack_Id)      
              BEGIN      
                  UPDATE StockView WITH (rowlock)      
                  SET    Total_Qty = Isnull (Total_Qty, 0) + @_Qty,      
                         Pending_Qty = Isnull (Pending_Qty, 0) + @_Qty ,      
                         LastUpdate = dbo.Get_sysdate(),      
                         StockEntryPage = 'STK-TRANS'  ,    
						StockEntryQty = @_Qty ,
						Dtl_Id = @_V,
						Tbl_Name = 'StockTrans_Dtl'
                  WHERE  Item_Id = @_Item_Id      
                         AND Godown_Id = @ToGodown_Id      
                         AND [Length] = @_SplitLength      
                         AND SType = @_S      
                         AND Width = @_Width      
                         AND Rack_Id = @_ToRack_Id      
              END      
                        ELSE      
                          BEGIN      
                              INSERT INTO [dbo].[StockView]      
                                          ([Godown_Id],      
                                           [Item_Id],      
                                           [SType],      
                                           [Total_Qty],      
                                           [sales_qty],      
                                           [Pending_Qty],      
                                           [Length],      
                                           LastUpdate,      
                                           Width,    
										   ref_id,      
                                           Rack_Id,      
                                           StockEntryPage,               
										   StockEntryQty,
										   Dtl_Id ,
										   Tbl_Name)      
                              VALUES      (@ToGodown_Id,      
                                           @_Item_Id,      
                                           @_S,      
                                           @_Qty,      
                                           0,      
                                           @_Qty,      
                                           @_SplitLength,
										   dbo.Get_sysdate(),      
                                           @_Width,      
                                           @_Id,      
                                           @_ToRack_Id,      
                                           'STK-TRANS',    
										   @_Qty,
										   @_V ,
										   'StockTrans_Dtl')      
                          END      
      
                        /**********************************/      
                        IF EXISTS (SELECT 1      
                                   FROM   StockView WITH (nolock)      
                                   WHERE  Item_Id = @_Item_Id      
                                          AND Godown_Id = @ToGodown_Id      
                                          AND [Length] = @_PendLength      
                                          AND SType = @_S      
                                          AND Width = @_Width      
                                          AND Rack_Id = @_ToRack_Id)      
              BEGIN      
                  UPDATE StockView WITH (rowlock)      
                  SET    Total_Qty = Isnull (Total_Qty, 0) + @_Qty,      
                         Pending_Qty = Isnull (Pending_Qty, 0) + @_Qty ,      
                         LastUpdate = dbo.Get_sysdate(),      
                         StockEntryPage = 'STK-TRANS',						 
						 StockEntryQty = @_Qty ,
						 Dtl_Id = @_V ,
						 Tbl_Name   ='StockTrans_Dtl'
                  WHERE  Item_Id = @_Item_Id      
                         AND Godown_Id = @ToGodown_Id      
                         AND [Length] = @_PendLength      
                         AND SType = @_S      
                         AND Width = @_Width      
                         AND Rack_Id = @_ToRack_Id      
              END      
                        ELSE      
                          BEGIN      
                              INSERT INTO [dbo].[StockView]      
                                          ([Godown_Id],      
                                           [Item_Id],      
                                           [SType],      
                                           [Total_Qty],      
                                           [sales_qty],      
                                           [Pending_Qty],      
                                           [Length],      
                                           LastUpdate,      
                                           Width,      
                                           ref_id,      
                                           Rack_Id,      
                                           StockEntryPage,   
										   StockEntryQty, 
										   Dtl_Id ,
										   Tbl_Name)      
                              VALUES      (@ToGodown_Id,      
                                           @_Item_Id,      
                                           @_S,      
                                           @_Qty,      
                                           0,      
                                           @_Qty,      
                                           @_PendLength,      
                                           dbo.Get_sysdate(),      
                                           @_Width,      
                                           @_Id,      
                                           @_ToRack_Id,      
                                           'STK-TRANS',    
										   @_Qty ,
										   @_V ,
										   'StockTrans_Dtl')      
                          END      
                    END      
                  ELSE      
                    BEGIN      
                        IF ( @Is_ProDept = 0 )      
                          BEGIN      
                              IF EXISTS (SELECT 1      
                                         FROM   StockView WITH (nolock)      
                                         WHERE  Item_Id = @_Item_Id      
                                                AND Godown_Id = @ToGodown_Id      
                                                AND [Length] = @_Length      
                                                AND SType = @_S      
                                                AND Width = @_Width      
                                                AND Rack_Id = @_ToRack_Id)      
                    BEGIN      
                        UPDATE StockView WITH (rowlock)      
                        SET    Total_Qty = Isnull (Total_Qty, 0) + @_Qty,      
                               Pending_Qty = Isnull (Pending_Qty, 0) + @_Qty ,      
                               LastUpdate = dbo.Get_sysdate(),      
                               StockEntryPage = 'STK-TRANS' ,   
							   StockEntryQty = @_Qty ,
							   Dtl_Id = @_V ,
							   Tbl_Name = 'StockTrans_Dtl'
                        WHERE  Item_Id = @_Item_Id      
                               AND Godown_Id = @ToGodown_Id      
                               AND [Length] = @_Length      
                               AND SType = @_S      
                               AND Width = @_Width      
                               AND Rack_Id = @_ToRack_Id      
      END      
                              ELSE      
                                BEGIN      
                                    INSERT INTO [dbo].[StockView]      
                                                ([Godown_Id],      
                                                 [Item_Id],      
                                                 [SType],      
                                                 [Total_Qty],      
                                                 [sales_qty],      
                                                 [Pending_Qty],      
                                                 [Length],      
                                                 LastUpdate,      
                                                 Width,      
                                                 Rack_Id,      
                                                 StockEntryPage,    
												 StockEntryQty ,
												 Dtl_Id ,
												 Tbl_Name)      
                                    VALUES      (@ToGodown_Id,      
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
                                END      
                          END      
                    END      
      
                  UPDATE StockView WITH (rowlock)      
                  SET    Pending_Qty = Isnull (Pending_Qty, 0) - @_Qty,      
                         transfer_qty = Isnull(transfer_qty, 0) + @_Qty,      
                         LastUpdate = dbo.Get_sysdate(),      
                         StockEntryPage = 'STK-TRANS',     
						 StockEntryQty =  @_Qty ,  
						 Dtl_Id = @_V ,
						 Tbl_Name = 'StockTrans_Dtl' , 
                         prodept_qty = ( CASE      
                                           WHEN @Is_ProDept = 1 THEN      
                                           Isnull(prodept_qty, 0) + @_Qty      
                                           ELSE prodept_qty      
                                         END )      
                  WHERE  id = @_Id      
      
                  FETCH next FROM db_cursor INTO @_Item_Id, @_Qty, @_Id, @_Length, @_Width,      
                  @_Remark, @_SType, @_SplitLength, @_IsSplit, @_Rack_Id  ,@_FrRack_Id ,  @_ToRack_Id    
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


