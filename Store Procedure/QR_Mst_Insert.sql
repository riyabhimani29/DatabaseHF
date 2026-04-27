USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[QR_Mst_Insert]    Script Date: 27-04-2026 14:34:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[QR_Mst_Insert] @Scan_Id    INT =0 output,  
                                           @Item_Name  VARCHAR(500),  
                                           @Item_Code  VARCHAR(500),  
                                           @PO_Id      INT,  
                                           @Dept_ID    INT,  
                                           @OrderQty   NUMERIC(18, 3),  
                                           @ArrVar     NUMERIC(18, 3),  
                                           @PODtl_Id   INT,  
                                           @Item_Id    INT,  
                                           @Rack_Id    INT =0,  
                                           @QRCode     VARCHAR(500),  
                                           @Remark     VARCHAR(500),  
                                           @MAC_Add    VARCHAR(500),  
                                           @Entry_User INT,  
                                           @Upd_User   INT,  
                                           @Year_Id    INT,  
                                           @Branch_ID  INT,  
                                           @RetVal     INT = 0 out,  
                                           @RetMsg     VARCHAR(max) = '' out  
AS  
    SET nocount ON  
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))  
  
    DECLARE @_OrderQty  AS NUMERIC(18, 3) = 0,  
            @_TotalScan AS NUMERIC(18, 3) = 0  
  
  BEGIN try  
      BEGIN TRANSACTION  
  
      IF ( @Scan_Id = 0 )  
        BEGIN  
            /************************************* TRANSACTION *************************************/  
            DECLARE @_Challan_no AS INT = 0  
  
            IF EXISTS (SELECT 1  
                       FROM   QR_Dtl WITH (nolock)  
                       WHERE  PO_Id = @PO_Id  
                              AND PODtl_Id = @PODtl_Id  
                              AND TRIM(QR_Code) = TRIM(@QRCode)
							  AND QR_Typedtl = '' )  
              BEGIN  
                  ROLLBACK  
  
                  SET @RetMsg ='QR Code Already Use .'  
                  SET @RetVal = -850  
                  SET @Scan_Id = @_Challan_no  
  
                  RETURN  
              END  
  
            SELECT @_Challan_no = Isnull(Max(QR_Mst.Challan_no), 0) + 1  
            FROM   QR_Mst WITH(nolock)  
            WHERE  QR_Mst.Year_Id = @Year_Id    and QR_Mst.QR_Type = '' 
  
            INSERT INTO [dbo].[QR_Mst] WITH(rowlock)  
                        ([challan_no],  
                         [remark],  
                         [mac_add],  
                         [entry_user],  
                         [entry_date],  
                         [year_id],  
                         [branch_id],  
                         dept_id,
						 QR_Type)  
            VALUES      (@_Challan_no,  
                         @Remark,  
                         @MAC_Add,  
                         @Entry_User,  
                         dbo.Get_sysdate(),  
                         @Year_Id,  
                         @Branch_ID,  
                         @Dept_ID,
						 '')  
  
            SET @RetMsg ='GRN Challan Successfully And Generated No is : '  
                         + CONVERT(VARCHAR(100), @_Challan_no)  
                         + ' .'  
            SET @RetVal = Scope_identity()  
            SET @Scan_Id = @_Challan_no  
  
            IF @@ERROR <> 0  
              BEGIN  
                  SET @RetVal = -404  
                  -- 0 IS FOR ERROR                                          
                  SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
                  SET @Scan_Id = 0  
              END  
            ELSE  
              BEGIN  
                  SELECT @_OrderQty = Isnull(orderqty, 0)  
                  FROM   PO_DTL WITH(nolock)  
                  WHERE  PODtl_Id = @PODtl_Id  
  
                  SELECT @_TotalScan = Isnull(Count(1), 0)  
                  FROM   QR_Dtl WITH(nolock)  
                  WHERE  PO_Id = @PO_Id  
                         AND PODtl_Id = @PODtl_Id 
						 AND QR_Typedtl = ''
  
                  IF ( @_OrderQty >= @_TotalScan )  
                    BEGIN  
                        INSERT INTO [dbo].[QR_Dtl] WITH(rowlock)  
                                    ([QR_Id],  
                                     [PO_Id],  
                                     [PODtl_Id],  
                                     [Item_Id],  
                                     [Scan_Qty],  
                                     QR_Code,  
                                     [Remark],  
                                     Rack_Id,
									 QR_Typedtl)  
                        VALUES      (@RetVal,  
                                     @PO_Id,  
                                     @PODtl_Id,  
                                     @Item_Id,  
                                     @ArrVar,  
                                     @QRCode,  
                                     @Remark,  
                                     @Rack_Id,
									 '')  
  
                        COMMIT  
                    END  
              /************************************* COMMIT *************************************/  
              END  
        END  
      ELSE  
        BEGIN  
            IF EXISTS (SELECT 1  
                       FROM   QR_Dtl WITH (nolock)  
                       WHERE  PO_Id = @PO_Id  
                              AND PODtl_Id = @PODtl_Id  
                              AND Trim(QR_Code) = Trim(@QRCode)
							  AND QR_Typedtl = '')  
              BEGIN  
                  ROLLBACK  
  
                  SET @RetMsg ='QR Code Already Use .'  
                  SET @RetVal = -850  
                  SET @Scan_Id = @_Challan_no  
  
                  RETURN  
              END  
  
            SELECT @_OrderQty = Isnull(OrderQty, 0)  
            FROM   PO_DTL WITH(nolock)  
            WHERE  PODtl_Id = @PODtl_Id  
  
            SELECT @_TotalScan = Isnull(Count(1), 0)  
            FROM   QR_Dtl WITH(nolock)  
            WHERE  PO_Id = @PO_Id  
                   AND PODtl_Id = @PODtl_Id 
				   AND QR_Typedtl = ''
  
            IF ( @_OrderQty >= @_TotalScan )  
              BEGIN  
                  INSERT INTO [dbo].[QR_Dtl] WITH(rowlock)  
                              ([QR_Id],  
                               [PO_Id],  
                               [PODtl_Id],  
                               [Item_Id],  
                               [Scan_Qty],  
                               QR_Code,  
                               [Remark],  
                               Rack_Id,
							   QR_Typedtl)  
                  VALUES      (@Scan_Id,  
                               @PO_Id,  
                               @PODtl_Id,  
                               @Item_Id,  
                               @ArrVar,  
                               Trim(@QRCode),  
                               @Remark,  
                               @Rack_Id,
							   '')  
              END  
  
            IF @@ERROR <> 0  
              BEGIN  
                  SET @RetVal = -407  
                  -- 0 IS FOR ERROR                                          
                  SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
                  SET @Scan_Id = 0  
  
                  RETURN  
              END  
            ELSE  
              BEGIN  
                  SET @RetVal = Scope_identity()  
                  SET @RetMsg ='GRN Challan Successfully And Generated No is : '  
                               + CONVERT(VARCHAR(100), @Scan_Id) + ' .'  
                  SET @Scan_Id = @Scan_Id  
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
      SET @Scan_Id = 0  
  END catch 
GO


