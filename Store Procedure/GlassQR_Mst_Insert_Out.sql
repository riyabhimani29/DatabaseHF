USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GlassQR_Mst_Insert_Out]    Script Date: 27-04-2026 11:35:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  PROCEDURE [dbo].[GlassQR_Mst_Insert_Out] @Scan_Id    INT =0 output,              
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
              
          
 --set @Rack_Id = (select top 1 GRN_Dtl.Rack_Id          
 --    from   GRN_Dtl WITH(nolock)          
 --        left join GRN_Mst WITH(nolock)          
 --         on GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id          
 --    where  GRN_Dtl.PODtl_Id = @PODtl_Id          
 --        and GRN_Mst.GRN_Type = 'GLPO-GRN')          
        
 set @Rack_Id = ( select  top 1  GRN_Dtl.Rack_Id           
     from   GRN_Dtl WITH(nolock)          
         left join GRN_Mst WITH(nolock)  on GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id          
   outer Apply (select isnull(SUM(GlassQR_Dtl.Scan_Qty),0) AS Scan_Qty from GlassQR_Dtl  WITH(nolock)  where GlassQR_Dtl.PODtl_Id = GRN_Dtl.PODtl_Id and GlassQR_Dtl.QR_Typedtl = 'OUT'  and GlassQR_Dtl.Rack_Id = GRN_Dtl.Rack_Id) VV        
     where   GRN_Dtl.PODtl_Id =  @PODtl_Id           
         and  GRN_Mst.GRN_Type = 'GLPO-GRN'        
   and isnull(GRN_Dtl.ReceiveQty,0) - isnull(VV.Scan_Qty,0) > 0)        
        
 IF ( Isnull(@Rack_Id, 0) = 0 )          
   begin          
    SET @RetVal = -104          
    SET @RetMsg ='Rack Not Found .'          
    SET @Scan_Id = -104   
	return
   end           
          
          
  BEGIN try              
      BEGIN TRANSACTION              
              
      IF ( @Scan_Id = 0 )              
        BEGIN              
            /************************************* TRANSACTION *************************************/              
            DECLARE @_Challan_no AS INT = 0              
              
            IF EXISTS (SELECT 1              
                       FROM   GlassQR_Dtl WITH (nolock)              
                       WHERE  PO_Id = @PO_Id              
                              AND PODtl_Id = @PODtl_Id              
                              AND TRIM(QR_Code) = TRIM(@QRCode)            
         AND QR_Typedtl = 'OUT')              
              BEGIN              
                  ROLLBACK              
              
                  SET @RetMsg ='QR Code Already Use .'              
                  SET @RetVal = -850              
                  SET @Scan_Id = @_Challan_no              
              
                  RETURN              
              END              
              
            SELECT @_Challan_no = Isnull(Max(GlassQR_Mst.Challan_no), 0) + 1              
            FROM   GlassQR_Mst WITH(nolock)              
            WHERE  GlassQR_Mst.Year_Id = @Year_Id and GlassQR_Mst.QR_Type = 'OUT'             
              
            INSERT INTO [dbo].[GlassQR_Mst] WITH(rowlock)              
                      ([Challan_no],              
                         [Remark],              
                         [MAC_Add],              
                         [Entry_User],              
                         [Entry_Date],              
                         [Year_Id],              
                         [Branch_ID],              
                         Dept_ID,            
       QR_Type)              
            VALUES      (@_Challan_no,              
                         @Remark,              
                         @MAC_Add,              
                         @Entry_User,              
                         dbo.Get_sysdate(),              
                         @Year_Id,              
                         @Branch_ID,              
                         @Dept_ID,            
       'OUT')              
              
            SET @RetMsg ='GRN Challan Successfully And Generated No is : '  + CONVERT(VARCHAR(100), @_Challan_no)   + ' .'              
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
                  FROM   GlassQR_Dtl WITH(nolock)              
                  WHERE  PO_Id = @PO_Id              
                         AND PODtl_Id = @PODtl_Id              
              
                  IF ( @_OrderQty >= @_TotalScan )              
                    BEGIN              
                        INSERT INTO [dbo].[GlassQR_Dtl] WITH(rowlock)              
                                    ([Glass_QR_Id],              
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
          'OUT')              
              
                        COMMIT              
                    END              
              /************************************* COMMIT *************************************/              
              END              
        END              
      ELSE              
        BEGIN              
            IF EXISTS (SELECT 1              
                       FROM   GlassQR_Dtl WITH (nolock)              
             WHERE  PO_Id = @PO_Id              
                              AND PODtl_Id = @PODtl_Id              
                              AND Trim(QR_Code) = Trim(@QRCode)            
							AND QR_Typedtl ='OUT')              
              BEGIN              
                  ROLLBACK              
        
                  SET @RetMsg ='QR Code Already Use .'              
                  SET @RetVal = -850              
                  SET @Scan_Id = @_Challan_no              
              
                  RETURN              
              END              
              
            SELECT @_OrderQty = Isnull(orderqty, 0)        
            FROM   PO_DTL WITH(nolock)              
            WHERE  PODtl_Id = @PODtl_Id              
              
            SELECT @_TotalScan = Isnull(Count(1), 0)              
            FROM   GlassQR_Dtl WITH(nolock)              
            WHERE  PO_Id = @PO_Id              
                   AND PODtl_Id = @PODtl_Id     
					AND QR_Typedtl ='OUT'  
              
            IF ( @_OrderQty >= @_TotalScan )              
              BEGIN              
                  INSERT INTO [dbo].[GlassQR_Dtl] WITH(rowlock)              
                              ([Glass_QR_Id],              
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
 'OUT')              
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


