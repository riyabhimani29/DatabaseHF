USE [db_a8637c_hifaberp]
GO
/****** Object:  StoredProcedure [dbo].[PO_MST_Insert]    Script Date: 13-05-2026 11:18:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PO_MST_Insert] @PO_Id              INT, 
                                      @PO_Req_Id          INT,
                                      @PO_Type            VARCHAR(50),      
                                      @Dept_ID            INT,      
                                      @Invoice_No         INT,      
                                      @OrderNo            VARCHAR(500),      
                                      @PO_Date            DATETIME,      
                                      @ReqRaisedBy_Id     INT,      
                                      @BillingAddress     VARCHAR(500),      
                                      @Supplier_Id        INT,      
                                      @Godown_Id          INT,      
                                      @GrossAmount        NUMERIC(18, 3),      
                                      @AdvanceAmount      NUMERIC(18, 3),
                                      @Other_Charges      NUMERIC(18,3),
                                      @DiscountPercentageOverall Numeric(18,3),
                                      @CGST               INT,      
                                      @CGSTTotal          NUMERIC(18, 3),      
                                      @SGST               INT,      
                                      @SGSTTotal          NUMERIC(18, 3),      
                                      @IGST               INT,      
                                      @IGSTTotal          NUMERIC(18, 3),      
                                      @NetAmount          NUMERIC(18, 3),      
                                      @PaymentTerms       VARCHAR(500),      
                                      @DeliveryTerms      VARCHAR(500),      
                                      @AdditionalTerms    VARCHAR(500),      
                                      @AuthorisePerson_Id INT,      
                                      @Remark             VARCHAR(500),      
                                      @MAC_Add            VARCHAR(500),      
                                      @Type               VARCHAR(500),      
                                      @Entry_User         INT,      
                                      @Upd_User           INT,      
                                      @Year_Id            INT,      
                                      @Branch_ID          INT,      
                                      @DtlPara            TBL_PODETAILs readonly,      
                                      @RetVal             INT = 0 out,      
                                      @RetMsg             VARCHAR(max) = '' out,      
                                      @_ImageName         VARCHAR(max) = '' out      
AS      
    SET nocount ON      
      
    DECLARE @Discount_Percentage AS NUMERIC(13,3) =0,
            @_Req_Id        AS INT= 0,
            @_PODtl_Id      AS INT= 0,      
            @_Item_Group_Id AS INT= 0,      
            @_Item_Cate_Id  AS INT= 0,      
            @_Item_Id       AS INT= 0,      
            @_SupDetail_Id  AS INT= 0,      
            @_OrderQty      AS NUMERIC(18, 3) = 0,      
            @_Unit_Id       AS INT= 0,      
            @_Length        AS NUMERIC(18, 3) = 0,      
            @_Weight        AS NUMERIC(18, 3) = 0,      
            @_TotalWeight   AS NUMERIC(18, 3) = 0,      
            @_UnitCost      AS NUMERIC(18, 3) = 0,      
            @_TotalCost     AS NUMERIC(18, 3) = 0,      
            @_Project_Id    AS INT= 0,      
            @_Remark        AS VARCHAR(500)= '',      
            @_Width         AS NUMERIC(18, 3) = 0,      
            @_Thickness     AS NUMERIC(18, 3) = 0,
            @_Pd_Ref_No     AS VARCHAR(550)=''
    DECLARE @_Financial_Year AS INT = 0      
    Declare @_Is_AutoNo as BIT = 0      
      
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, @PO_Date))      
    SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, @PO_Date))      
      
    IF ( @PO_Id = 0 )      
      BEGIN      
          IF ( @Invoice_No = 0 )      
            Begin      
                set @_Is_AutoNo = 1      
            end      
      
          BEGIN try      
              BEGIN TRANSACTION      
      
              /************************************* TRANSACTION *************************************/      
              DECLARE @_DeptShortNm AS VARCHAR(20)='',      
                      @_Invoice_No  AS INT = 0      
      
              IF ( @Dept_ID <> 0 )      
 BEGIN      
                    SELECT @_DeptShortNm = Isnull (M_Department.Dept_Short_Name , '-' )      
                    FROM   M_Department WITH (nolock)      
                    WHERE  M_Department.Dept_ID = @Dept_ID      
                END      
              ELSE      
                BEGIN      
                    SET @RetMsg ='Please Select Department.'      
                    SET @RetVal = -1      
      
                    RETURN      
                END      
      
              if ( @_Is_AutoNo = 1 )      
                begin      
     SELECT @_Invoice_No = Isnull(Max(PO_MST.Invoice_No), 0) + 1      
                    FROM   PO_MST WITH(nolock)      
                    WHERE  PO_MST.Year_Id = @Year_Id      
                           AND PO_Type <> 'D' -- = @PO_Type           
                           AND PO_MST.Dept_ID = @Dept_ID      
       --and PO_MST.Is_AutoNo = 1      
                end      
              else      
                begin      
                         
                    set @_Invoice_No = @Invoice_No      
                end      
      
              SET @OrderNo = 'HF/' + @_DeptShortNm + '/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)      
      
              -- Eg. HF/ALU/1002/2122                                                                              
              INSERT INTO PO_MST WITH(rowlock)      
                          (PO_Type,      
                           Dept_ID,      
                           orderno,      
                           Invoice_No,      
                           PO_Date,      
                           ReqRaisedBy_Id,      
                           BillingAddress,      
                           Supplier_Id,      
                           Godown_Id,      
                           GrossAmount,      
                           AdvanceAmount,
                           Other_Charges,
                           DiscountPercentageOverall,
                           NetAmount,      
                           PaymentTerms,      
                           DeliveryTerms,      
                           AdditionalTerms,      
                           AuthorisePerson_Id,      
                           ApproveDate,      
                           Remark,      
                           MAC_Add,      
                           Entry_User,      
                           Entry_Date,      
                           Upd_User,      
                           Upd_Date,      
                           Year_Id,      
                           Branch_ID,      
                           Order_Type,      
                           [CGST],      
                           [SGST],      
                           [IGST],      
                           [CGSTTotal],      
                           [SGSTTotal],      
                           [IGSTTotal],      
                           Revision,      
                           Is_AutoNo)      
              VALUES      ( @PO_Type,      
                            @Dept_ID,      
                            ( CASE      
                                WHEN @PO_Type = 'D' THEN '1'      
                                ELSE @OrderNo      
                              END ),      
                            ( CASE      
                                WHEN @PO_Type = 'D' THEN 1      
                                ELSE @_Invoice_No      
                              END ),      
                            @PO_Date,      
                            @ReqRaisedBy_Id,      
                            @BillingAddress,      
                            @Supplier_Id,      
                            @Godown_Id,      
                            @GrossAmount,      
                            @AdvanceAmount, 
                            @Other_Charges,
                            @DiscountPercentageOverall,
                            @NetAmount,      
                            @PaymentTerms,      
                            @DeliveryTerms,      
                            @AdditionalTerms,      
                            @AuthorisePerson_Id,      
                            '1900-01-01',      
                            @Remark,      
                            @MAC_Add,      
                            @Entry_User,      
 dbo.Get_sysdate(),      
                            @Upd_User,      
                            dbo.Get_sysdate(),      
                            @Year_Id,      
                            @Branch_ID,      
                            'PO',      
                            @CGST,      
                            @SGST,      
                            @IGST,                              @CGSTTotal,      
                            @SGSTTotal,      
                            @IGSTTotal,      
                            0,      
                            @_Is_AutoNo)      
      
              SET @RetVal = Scope_identity()      
      
       IF (@PO_Req_Id != 0)
                BEGIN
                UPDATE PO_Request_MST SET Is_Approved = 2,Upd_Date = dbo.Get_sysdate(), PO_Id = @RetVal
                WHERE PO_Request_MST.PO_Req_Id = @PO_Req_Id;
                END
                
              IF ( @PO_Type = 'D' )      
                BEGIN      
                    SET @RetMsg = 'Raise PO Generate Successfully And Generated Order No is : ' + CONVERT (VARCHAR(20), @RetVal) + ' .'      
                END      
              ELSE      
                BEGIN      
                    SET @RetMsg = 'Raise PO Generate Successfully And Generated Order No is : ' + @OrderNo + ' .'      
                END      
      
              SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0), Replace( Replace(Replace(Replace( Sysutcdatetime(), '-', ''), ' ', ''), ':', ''), '.', '')) + @RetVal) + '.png'      
      
              UPDATE PO_MST with(rowlock)      
              SET    Doc_Img_Name = @_ImageName      
              WHERE  PO_Id = @RetVal      
      
              UPDATE PO_MST with(rowlock)      
              SET    OrderNo = @RetVal      
              WHERE  PO_Id = @RetVal      
                     AND PO_Type = 'D'      
      
              IF @@ERROR <> 0      
                BEGIN      
                    SET @RetVal = 0 -- 0 IS FOR ERROR                                                                            
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
                END      
              ELSE      
                BEGIN      
                    DECLARE purchase_cur CURSOR FOR      
                      SELECT Req_Id,Item_Group_Id,      
                             Item_Cate_Id,      
                             Item_Id,      
                             SupDetail_Id,      
                             OrderQty, 
                             Discount_Percentage,
                             Unit_Id,      
                             CONVERT(NUMERIC(18, 3), length),      
                             CONVERT(NUMERIC(18, 3), weight),      
                             TotalWeight,      
                             UnitCost,      
                             TotalCost,      
                             Project_Id,      
                             Remark,      
                             Width,      
                             Thickness,
                             Pd_Ref_No
                      FROM   @DtlPara;      
      
                    OPEN purchase_cur      
      
                    FETCH next FROM purchase_cur INTO @_Req_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id, @_Length, @_Weight, @_TotalWeight ,      
                    @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness ,@_Pd_Ref_No     
      
                    WHILE @@FETCH_STATUS = 0      
                      BEGIN      
                          INSERT INTO PO_DTL WITH(rowlock)      
                                      (PO_Id,/*Item_Group_Id ,Item_Cate_Id ,*/    
                                      Req_Id,
                                       Item_Id,      
                                       SupDetail_Id,      
                                       OrderQty,Discount_Percentage,       
                                       PendingQty,      
                                       Unit_Id,      
                                       [Length],      
          [Weight],      
                                       TotalWeight,      
                                       UnitCost,      
                                       TotalCost,      
                                       Project_Id,      
                                       Remark,      
                                       Width,      
                                       Thickness,
                                       Pd_Ref_No)      
                          VALUES      ( @RetVal, /*@_Item_Group_Id,@_Item_Cate_Id,*/      
                          @_Req_Id,
                                        @_Item_Id,      
                                        @_SupDetail_Id,      
                                        @_OrderQty, @Discount_Percentage,      
                                        @_OrderQty,      
                                        @_Unit_Id,      
                                        CONVERT(NUMERIC(18, 3), @_Length),      
                                        CONVERT(NUMERIC(18, 3), @_Weight),      
                                        @_TotalWeight,      
                                        @_UnitCost,      
                                        @_TotalCost,      
                                        @_Project_Id,      
                                        @_Remark,      
                                        @_Width,      
                                        @_Thickness,
                                        @_Pd_Ref_No)     
                                        
                                        UPDATE BOM_PO_RequestDtl SET Is_Requested = 2 WHERE BOM_PO_ReqDtl_Id = @_Req_Id;
      
                          FETCH next FROM purchase_cur INTO @_Req_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id, @_Length, @_Weight, @_TotalWeight ,      
                          @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness, @_Pd_Ref_No      
                      END      
      
                    CLOSE purchase_cur;      
      
                    DEALLOCATE purchase_cur;      
                END      
       IF (@PO_Type = 'F')
BEGIN
 

UPDATE D
SET D.Is_Read = 5
FROM PO_DTL PO
INNER JOIN PR_DTL D 
    ON D.PrDtl_Id = PO.Req_Id
WHERE PO.PO_Id = @RetVal
  AND ISNULL(D.Is_Checked,0) = 1
  AND D.Supplier_Id = @Supplier_Id;

UPDATE R
SET R.IS_PO = 5
FROM PO_DTL PO
INNER JOIN PR_DTL D 
    ON D.PrDtl_Id = PO.Req_Id
INNER JOIN BOM_PO_RequestDtl R
    ON R.BOM_PO_ReqDtl_Id = D.Req_Id
WHERE PO.PO_Id = @RetVal;

END
              COMMIT      
          /************************************* COMMIT *************************************/      
          END try      
      
          BEGIN catch      
              ROLLBACK      
      
              /************************************* ROLLBACK *************************************/      
              SET @RetVal = -405      
              -- 0 IS FOR ERROR                                                                            
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
          END catch      
      END 
    ELSE 
     IF(@Type = 'edit')
        BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
                     SET @_DeptShortNm  = '';
                    SET @_Invoice_No    = 0;

            -- Get Department Short Name
            SELECT @_DeptShortNm = ISNULL(Dept_Short_Name, '-')
            FROM M_Department WITH (NOLOCK)
            WHERE Dept_ID = @Dept_ID

            -- Auto Invoice No (only if required)
            IF (@Invoice_No = 0)
            BEGIN
                SELECT @_Invoice_No = ISNULL(MAX(Invoice_No),0) + 1
                FROM PO_MST WITH (NOLOCK)
                WHERE Year_Id = @Year_Id
                  AND PO_Type <> 'D'
                  AND Dept_ID = @Dept_ID
            END
            ELSE
            BEGIN
                SET @_Invoice_No = @Invoice_No
            END

            -- Generate OrderNo
            SET @OrderNo = 'HF/' + @_DeptShortNm + '/' 
                         + CONVERT(VARCHAR(20), FORMAT(@_Invoice_No, '0000')) 
                         + '/' + CONVERT(VARCHAR(20), @_Financial_Year)
        -- ? Update Master
        UPDATE PO_MST WITH (ROWLOCK)
        SET 
            PO_Type = @PO_Type,
            --OrderNo = @OrderNO,
            PO_Date = @PO_Date,
            OrderNo = ( CASE WHEN @PO_Type = 'D' THEN '1' ELSE @OrderNo END ),   
            ReqRaisedBy_Id = @ReqRaisedBy_Id,
            BillingAddress = @BillingAddress,
            Supplier_Id = @Supplier_Id,
            Godown_Id = @Godown_Id,
            GrossAmount = @GrossAmount,
            AdvanceAmount = @AdvanceAmount,
            Other_Charges = @Other_Charges,
            DiscountPercentageOverall = @DiscountPercentageOverall,
            NetAmount = @NetAmount,
            PaymentTerms = @PaymentTerms,
            DeliveryTerms = @DeliveryTerms,
            AdditionalTerms = @AdditionalTerms,
            CGST = @CGST,
            SGST = @SGST,
            IGST = @IGST,
            CGSTTotal = @CGSTTotal,
            SGSTTotal = @SGSTTotal,
            IGSTTotal = @IGSTTotal,
            Remark = @Remark,
            Upd_User = @Upd_User,
            Upd_Date = dbo.Get_sysdate()
        WHERE PO_Id = @PO_Id


        -- ? Remove old details
        DELETE FROM PO_DTL 
        WHERE PO_Id = @PO_Id


        -- ? Insert new details (NO CURSOR)
        INSERT INTO PO_DTL
        (
            PO_Id,
            Req_Id,
            Item_Id,
            SupDetail_Id,
            OrderQty,
            Discount_Percentage,
            PendingQty,
            Unit_Id,
            Length,
            Weight,
            TotalWeight,
            UnitCost,
            TotalCost,
            Project_Id,
            Remark,
            Width,
            Thickness,
            Pd_Ref_No
        )
        SELECT
            @PO_Id,
            Req_Id,
            Item_Id,
            SupDetail_Id,
            OrderQty,
            Discount_Percentage,
            OrderQty,  -- ? Pending = OrderQty (your requirement)
            Unit_Id,
            CONVERT(NUMERIC(18,3), Length),
            CONVERT(NUMERIC(18,3), Weight),
            TotalWeight,
            UnitCost,
            TotalCost,
            Project_Id,
            Remark,
            Width,
            Thickness,
            Pd_Ref_No
        FROM @DtlPara


        -- ? Success
        SET @RetVal = @PO_Id
        SET @RetMsg = 'PO Updated Successfully (Edit Mode)'

        COMMIT
    END TRY
    BEGIN CATCH
        ROLLBACK
        SET @RetVal = -405
        SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE()
    END CATCH

    RETURN
END
    ELSE /*---------- Edit Mode---------*/      
      BEGIN      
          IF ( @Invoice_No = 0 )      
            Begin      
                set @_Is_AutoNo = 1      
            end      
      
          BEGIN try      
              IF NOT EXISTS(SELECT 1      
                            FROM   PO_MST WITH (nolock)      
                            WHERE  PO_Id = @PO_Id)      
                BEGIN      
                    SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                                
                    SET @RetMsg = @OrderNo + ' This PO Not Exist .'      
      
                    RETURN      
                END      
      
              DECLARE @OrderQty   AS NUMERIC(18, 3)=0,      
                      @PendingQty AS NUMERIC(18, 3)=0      
      
              if @Type = 'Revision'      
                begin      
                    --SELECT @OrderQty = Isnull(Sum(orderqty), 0),                        
                    --@PendingQty = Isnull(Sum(pendingqty), 0)                        
                    --FROM   PO_DTL WITH(nolock)                        
                    --WHERE  PO_Id = @PO_Id                        
                          
					select @PendingQty = ( Sum (Isnull(RR.ReceiveQty, 0)) + Sum (Isnull(PO_DTL.PendingQty, 0)) ),      
                           @OrderQty = Sum(Isnull(PO_DTL.OrderQty, 0))      
                    from   PO_DTL WITH(nolock)      
                           Cross apply (select Sum (GRN_Dtl.ReceiveQty) AS ReceiveQty      
                                        from   GRN_Dtl WITH(nolock)      
										left join GRN_Mst  WITH(nolock)  On GRN_Mst.GRN_Id = GRN_Dtl.GRN_Id   
                                        where GRN_Dtl.PODtl_Id = PO_DTL.PODtl_Id  
											AND GRN_Mst.GRN_Type ='PO-GRN')      
                                       as RR      
                    where  PO_DTL.PO_Id = @PO_Id      
                end      
              else      
                begin      
                    SELECT @OrderQty = Isnull(Sum(PO_DTL.OrderQty), 0),      
                           @PendingQty = Isnull(Sum(PO_DTL.PendingQty), 0)      
                    FROM   PO_DTL WITH(nolock)      
                    WHERE  PO_Id = @PO_Id      
                end      
      
              IF ( @OrderQty <> @PendingQty )      
         BEGIN      
                    SET @RetVal = -4 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                                
                    SET @RetMsg = @OrderNo + ' This PO Not Edit Beacuse PO QTY Use . -' + @Type    
      
                    RETURN      
                END      
      
              SET @_ImageName = ''      
      
              DECLARE @_POIdddd    INT = 0,      
                      @_PO_Type111 VARCHAR(10) ='',
                      @_Old_PO_Type varchar(10) = '';

        SELECT @_Old_PO_Type = PO_Type
        FROM PO_MST WITH (NOLOCK)
        WHERE PO_Id = @PO_Id;
      
              BEGIN TRANSACTION      
      
              /************************************* TRANSACTION *************************************/      
              IF ( @Dept_ID <> 0 )      
                BEGIN      
                    SELECT @_DeptShortNm = Isnull (M_Department.Dept_Short_Name, '-' )      
                    FROM   M_Department WITH (nolock)      
                    WHERE  M_Department.Dept_ID = @Dept_ID      
                END      
              ELSE      
                BEGIN      
                    SET @RetMsg ='Please Select Department.'      
                    SET @RetVal = -1      
      
                    RETURN      
                END      
      
              SELECT @_POIdddd = Isnull(PO_MST.PO_Id, 0),      
                     @_PO_Type111 = Isnull(PO_MST.PO_Type, '')      
              FROM   PO_MST with(nolock)      
              WHERE  PO_MST.PO_Id = @PO_Id      
                     AND PO_Type = 'D'      
      
              IF ( @PO_Type <> 'D' )      
                BEGIN      
                    SET @Year_Id = dbo.Get_financial_yearid( CONVERT (DATE, @PO_Date) )      
                    SET @_Financial_Year = dbo.Get_financial_year( CONVERT (DATE, @PO_Date) )      
      
                    --SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))                        
                    --               SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, dbo.Get_sysdate()) )                        
                    if ( @_Is_AutoNo = 1 )      
                      begin      
      
                          SELECT @_Invoice_No = Isnull(Max(PO_MST.Invoice_No), 0 ) + 1      
                          FROM   PO_MST WITH(nolock)      
                          WHERE  PO_MST.Year_Id = @Year_Id      
                                 AND PO_Type <> 'D' -- = @PO_Type                
                                 AND PO_MST.Dept_ID = @Dept_ID      
								-- and PO_MST.Is_AutoNo = 1      
                      end      
                    else      
                      begin      
                          set @_Invoice_No = @Invoice_No      
                      end      
      
                    --AND @Type <> 'Revision'          
                    SET @OrderNo = 'HF/' + @_DeptShortNm + '/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year )      
      
                    UPDATE PO_MST WITH (rowlock)      
                    SET    Invoice_No = case      
                                          when @_PO_Type111 = 'D' then @_Invoice_No      
                                          else PO_MST.Invoice_No      
                                        end,      
                           OrderNo = case   
                                       when @_PO_Type111 = 'D' then @OrderNo      
                                       else PO_MST.OrderNo      
                                     end,      
                           Year_Id = case      
                                       when @_PO_Type111 = 'D' then @Year_Id      
                                       else PO_MST.Year_Id      
                                     end,      
                           PO_Date = case      
                                       when @_PO_Type111 = 'D' then @PO_Date /*dbo.Get_sysdate()*/      
                                       else PO_MST.PO_Date      
                                     end,      
                           Is_AutoNo = case      
                                       when @_PO_Type111 = 'D' then @_Is_AutoNo /*dbo.Get_sysdate()*/      
                                       else PO_MST.Is_AutoNo      
                                     end      
                    WHERE  PO_Id = @PO_Id      
                END      
      
              UPDATE PO_MST WITH (rowlock)      
              SET      
              ---OrderNo = ( case when @_POIdddd > 0 then  @OrderNo  else  OrderNo end  ) ,                                    
              -- PO_Date = @PO_Date  ,                                                              
              PO_Type = @PO_Type,      
              ReqRaisedBy_Id = @ReqRaisedBy_Id,      
              Godown_Id = @Godown_Id,      
              grossamount = @GrossAmount,      
              advanceamount = @AdvanceAmount, 
              Other_Charges = @Other_Charges,
              DiscountPercentageOverall=@DiscountPercentageOverall,
              netamount = @NetAmount,      
              paymentterms = @PaymentTerms,      
              deliveryterms = @DeliveryTerms,      
              additionalterms = @AdditionalTerms,      
              [CGST] = @CGST,      
            [SGST] = @SGST,      
              [IGST] = @IGST,      
              [CGSTTotal] = @CGSTTotal,      
              [SGSTTotal] = @SGSTTotal,      
              [IGSTTotal] = @IGSTTotal,      
              Remark = @Remark,      
              Upd_User = @Upd_User,      
              Upd_Date = dbo.Get_sysdate() --, Is_AutoNo = @_Is_AutoNo      
              WHERE  PO_Id = @PO_Id      
      
              IF @@ERROR = 0      
                BEGIN      
                    SET @RetVal = @PO_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                                                                
                    SET @RetMsg = 'Raise PO Update Successfully And Update Order No is : ' + @OrderNo + ' .'      
      
                    if @Type = 'Revision'      
                      begin      
                          update PO_MST      
                          set    Revision = Isnull(Revision, 0) + 1      
                          WHERE  PO_Id = @PO_Id      
                      end      
      
                    --if  @Type != 'Revision'                      
                    begin      
                        DELETE FROM PO_DTL WITH(rowlock)      
                        WHERE  PO_DTL.PODtl_Id NOT IN (SELECT PODtl_Id FROM   @DtlPara) AND PO_DTL.PO_Id = @PO_Id      
                    end      
      
                    DECLARE purchase_cur CURSOR FOR      
                      SELECT PODtl_Id,      
                             Item_Group_Id,      
                             Item_Cate_Id,      
                             Item_Id,      
                             SupDetail_Id,      
                             OrderQty,
                             Discount_Percentage, 
                             Unit_Id,      
                             CONVERT(NUMERIC(18, 3), length),      
                             CONVERT(NUMERIC(18, 3), weight),      
                             TotalWeight,      
                             UnitCost,      
                             TotalCost,      
                             Project_Id,      
                             Remark,      
                             Width,      
                             Thickness,
                             Pd_Ref_No
                      FROM   @DtlPara      
                   where  PODtl_Id = ( case when @Type = 'Revision' then PODtl_Id else 0 end );      
      
                    OPEN purchase_cur      
      
                    FETCH next FROM purchase_cur INTO @_PODtl_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id , @_Length ,      
                    @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness ,@_Pd_Ref_No     
      
                    WHILE @@FETCH_STATUS = 0      
                      BEGIN      
                          IF ( @_PODtl_Id = 0 )      
                            BEGIN      
                                INSERT INTO PO_DTL WITH(rowlock)      
                                            (Discount_Percentage,PO_Id,      
                                             Item_Group_Id,      
                                             Item_Cate_Id,      
                                             Item_Id,      
                                             SupDetail_Id,      
                                             OrderQty,      
                                  PendingQty,      
                                             Unit_Id,      
                                             [Length],      
                                             [Weight],      
                                             TotalWeight,      
                                             UnitCost,      
                                             TotalCost,      
                                             Project_Id,      
                                             Remark,      
                                             Width,      
                                             Thickness,
                                             Pd_Ref_No)      
                                VALUES      ( @Discount_Percentage,@RetVal,      
                                              0,      
                                              0,      
                                              @_Item_Id,      
                                              @_SupDetail_Id,      
                                              Isnull(@_OrderQty, 0),      
              Isnull(@_OrderQty, 0),      
                                              @_Unit_Id,      
                                              CONVERT(NUMERIC(18, 3), @_Length),      
                                              CONVERT(NUMERIC(18, 3), @_Weight),      
                                              @_TotalWeight,      
                                              @_UnitCost,      
                                              @_TotalCost,      
                                              @_Project_Id,      
                                              @_Remark,      
                                              @_Width,      
                                              @_Thickness,
                                              @_Pd_Ref_No)      
                            END      
                          ELSE      
                            BEGIN      
                                declare @__PendingQty as NUMERIC(18, 3) = 0      
      
                                if @Type != 'Revision'      
                                  begin      
                                      select @__PendingQty = Isnull (PO_DTL.PendingQty, 0)      
                                      from   PO_DTL with(nolock)      
                                      where  PODtl_Id = @_PODtl_Id      
                                  end      
                                else      
                                  begin      
                                      declare @__ReceiveQty as NUMERIC(18, 3) = 0      
      
                                      select @__ReceiveQty = Isnull(Sum( Isnull(GRN_Dtl.ReceiveQty , 0 )) , 0)      
                                      from   GRN_Dtl with(nolock)    
										left join GRN_Mst with(nolock)   on GRN_Dtl.GRN_Id = GRN_Mst.GRN_Id
                                      where  GRN_Mst.GRN_Type= 'PO-GRN' and  PODtl_Id = @_PODtl_Id      
      
                                      --select @__PendingQty = isnull (PO_DTL.OrderQty,0) from PO_DTL with(nolock) where PODtl_Id = @_PODtl_Id                    
                                   set @__PendingQty =   @_OrderQty - @__ReceiveQty      
                                  end      
      
                                UPDATE [dbo].[PO_DTL]      
                                SET    [OrderQty] = @_OrderQty,   
                                       [Discount_Percentage] = @Discount_Percentage,
                                       [PendingQty] = Isnull(@__PendingQty, 0),      
                                       Item_Group_Id = @_Item_Group_Id,      
                                       Item_Cate_Id = @_Item_Cate_Id,      
                                       [Project_Id] = @_Project_Id,      
                                       [Length] = CONVERT(NUMERIC(18, 3), @_Length),      
                                       [TotalWeight] = @_TotalWeight,      
                                       [UnitCost] = @_UnitCost,      
                                       [TotalCost] = @_TotalCost,      
                                       [Width] = @_Width,      
                                       [Thickness] = @_Thickness,      
                                       [Remark] = @_Remark,
                                       [Pd_Ref_No] = @_Pd_Ref_No
                                WHERE  PODtl_Id = @_PODtl_Id      
              END      
      
                          FETCH next FROM purchase_cur INTO @_PODtl_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id , @_Length ,      
                          @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness,@_Pd_Ref_No      
                      END      
      
                    CLOSE purchase_cur;      
       IF (@_Old_PO_Type = 'D' AND @PO_Type = 'F')
BEGIN
 

UPDATE D
SET D.Is_Read = 5
FROM PO_DTL PO
INNER JOIN PR_DTL D 
    ON D.PrDtl_Id = PO.Req_Id
WHERE PO.PO_Id = @RetVal
  AND ISNULL(D.Is_Checked,0) = 1
  AND D.Supplier_Id = @Supplier_Id;

UPDATE R
SET R.IS_PO = 5
FROM PO_DTL PO
INNER JOIN PR_DTL D 
    ON D.PrDtl_Id = PO.Req_Id
INNER JOIN BOM_PO_RequestDtl R
    ON R.BOM_PO_ReqDtl_Id = D.Req_Id
WHERE PO.PO_Id = @PO_Id;

END
                    DEALLOCATE purchase_cur;      
                END      
              ELSE      
                BEGIN      
                    SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED                                                                
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
                END      
      
              COMMIT      
          /************************************* COMMIT *************************************/      
          END try      
      
          BEGIN catch      
              ROLLBACK      
      
              /************************************* ROLLBACK *************************************/      
              SET @RetVal = -405 -- 0 IS FOR ERROR                       
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
          END catch      
      END

