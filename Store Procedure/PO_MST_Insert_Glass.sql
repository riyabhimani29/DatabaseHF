USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_Insert_Glass]    Script Date: 27-04-2026 13:16:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_MST_Insert_Glass] @PO_Id              INT, 
@PO_Req_Id          INT,
                                            @PO_Type            VARCHAR(50),  
                                            @Dept_ID            INT,  
											@Invoice_No         INT,  
                                            @Order_Type         VARCHAR(500),  
                                            @OrderNo            VARCHAR(500),  
                                            @PO_Date            DATETIME,  
                                            @ReqRaisedBy_Id     INT,  
                                            @BillingAddress     VARCHAR(500),  
                                            @Supplier_Id        INT,  
                                            @Godown_Id          INT,  
                                            @Admin_Charges      NUMERIC(18, 3),  
                                            @Insurance          NUMERIC(18, 3),  
                                            @Other_Charges      NUMERIC(18, 3),  
                                            @Freight_Charges    NUMERIC(18, 3),  
                                            @GrossAmount        NUMERIC(18, 0),  
                                            @AdvanceAmount      NUMERIC(18, 0),
                                            @DiscountPercentageOverall Numeric(18,3),
                                            @CGST               INT,  
                                            @CGSTTotal          NUMERIC(18, 0),  
                                            @SGST               INT,  
                                            @SGSTTotal          NUMERIC(18, 0),  
                                            @IGST               INT,  
                                            @IGSTTotal          NUMERIC(18, 0),  
                                            @NetAmount          NUMERIC(18, 0),  
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
                                            @DtlPara   Tbl_PODetail_Glass readonly,  
                                            @RetVal             INT = 0 out,  
                                            @RetMsg             VARCHAR(max) = '' out,  
                                            @_ImageName         VARCHAR(max) = '' out  
AS  
    SET nocount ON  
  
    DECLARE @Discount_Percentage AS NUMERIC(13,3) =0,
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
            @_Charg_Height  AS NUMERIC(18, 3) = 0,  
            @_Charg_Weight  AS NUMERIC(18, 3) = 0,  
            @_Ref_Code      AS VARCHAR(500)= ''  
  
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
                    SELECT @_DeptShortNm = Isnull (M_Department.Dept_Short_Name, '-' )  
                    FROM   M_Department WITH (nolock)  
                    WHERE  M_Department.dept_id = @Dept_ID  
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
					  WHERE  PO_MST.year_id = @Year_Id  
							 AND PO_Type <> 'D' -- = @PO_Type            
							 AND Order_Type = @Order_Type  
							 AND PO_MST.Dept_ID = @Dept_ID  
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
                           OrderNo,  
                           Invoice_No,  
                           PO_Date,  
                           ReqRaisedBy_Id,  
                           BillingAddress,  
                           Supplier_Id,  
                           Godown_Id,  
                           GrossAmount,  
                           AdvanceAmount, 
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
                           Admin_Charges,  
                           Insurance,  
                           Other_Charges,  
                           Freight_Charges,  
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
                            @Order_Type,/*'PO-GL',              */  
                            @CGST,  
                            @SGST,  
                            @IGST,  
                            @CGSTTotal,  
                            @SGSTTotal,  
                            @IGSTTotal,  
                            0,  
                            @Admin_Charges,  
                            @Insurance,  
                            @Other_Charges,  
                            @Freight_Charges,  
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
  
              UPDATE PO_MST WITH(rowlock)  
              SET    Doc_Img_Name = @_ImageName  
              WHERE  PO_Id = @RetVal  
  
              UPDATE PO_MST WITH(rowlock)  
              SET    OrderNo = @RetVal  
              WHERE  PO_Id = @RetVal  
                     AND PO_Type = 'D'  
  
              IF @@ERROR <> 0  
                BEGIN  
                    SET @RetVal = 0  
                    -- 0 IS FOR ERROR                                                                          
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
                END  
              ELSE  
                BEGIN  
                    DECLARE purchase_cur CURSOR FOR  
                      SELECT item_group_id,  
                             item_cate_id,  
                             item_id,  
                             supdetail_id,  
                             orderqty,  
                             Discount_Percentage,
                             unit_id,  
                             CONVERT(NUMERIC(18, 3), length),  
                             CONVERT(NUMERIC(18, 3), weight),  
                             totalweight,  
                             unitcost,  
                             totalcost,  
                             project_id,  
                             remark,  
                             width,  
                             thickness,  
                             Ref_Code,  
                             Charg_Height,  
                             Charg_Weight  
                      FROM   @DtlPara;  
  
                    OPEN purchase_cur  
  
                    FETCH next FROM purchase_cur INTO @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id, @_Length, @_Weight,  
              @_TotalWeight , @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness, @_Ref_Code, @_Charg_Height, @_Charg_Weight  
  
                    WHILE @@FETCH_STATUS = 0  
                      BEGIN  
                          INSERT INTO PO_DTL WITH(rowlock)  
                                      (PO_Id,/*Item_Group_Id ,Item_Cate_Id ,*/  
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
                                       Ref_Code,  
                                       Charg_Height,  
                                       Charg_Weight)  
                          VALUES      ( @RetVal,  
                                        /*@_Item_Group_Id,@_Item_Cate_Id,*/  
                                        @_Item_Id,  
                                        @_SupDetail_Id,  
                                        @_OrderQty,@Discount_Percentage, 
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
                                        @_Ref_Code,  
                                        @_Charg_Height,  
                                        @_Charg_Weight)  
  
                          FETCH next FROM purchase_cur INTO @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id, @_Length, @_Weight,  @_TotalWeight ,  
             @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness, @_Ref_Code, @_Charg_Height, @_Charg_Weight  
                      END  
  
                    CLOSE purchase_cur;  
  
                    DEALLOCATE purchase_cur;  
                END  
  
              COMMIT  
          /************************************* COMMIT *************************************/  
          END try  
  
          BEGIN catch  
              ROLLBACK  
  
              /************************************* ROLLBACK *************************************/  
              SET @RetVal = -405              -- 0 IS FOR ERROR                                                                          
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
          END catch  
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
  
              IF @Type = 'Revision'  
                BEGIN  
                    --SELECT @OrderQty = Isnull(Sum(orderqty), 0),                      
                    --@PendingQty = Isnull(Sum(pendingqty), 0)                      
                    --FROM   po_dtl WITH(nolock)                      
                    --WHERE  po_id = @PO_Id                      
                    SELECT @PendingQty = ( Sum (Isnull(RR.ReceiveQty, 0)) + Sum (Isnull(PO_DTL.PendingQty, 0)) ),  
                           @OrderQty = Sum(Isnull(PO_DTL.OrderQty, 0))  
                    FROM   PO_DTL WITH(nolock)  
                           CROSS apply (SELECT Sum (GRN_Dtl.ReceiveQty) AS  
                                               ReceiveQty  
                                        FROM   GRN_Dtl WITH(nolock)  
                                        WHERE GRN_Dtl.PODtl_Id = PO_DTL.PODtl_Id)  
                                       AS RR  
                    WHERE  PO_DTL.PO_Id = @PO_Id  
                END  
              ELSE  
                BEGIN  
                    SELECT @OrderQty = Isnull(Sum(orderqty), 0),  
                           @PendingQty = Isnull(Sum(pendingqty), 0)  
                    FROM   PO_DTL WITH(nolock)  
                    WHERE  po_id = @PO_Id  
                END  
  
              IF ( @OrderQty <> @PendingQty )  
                BEGIN  
                    SET @RetVal = -4 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                              
                    SET @RetMsg = @OrderNo + ' This PO Not Edit Beacuse PO QTY Use .'  
  
                    RETURN  
                END  
  
              SET @_ImageName = ''  
  
              DECLARE @_POIdddd    INT = 0,  
                      @_PO_Type111 varchar(10) =''  
  
              BEGIN TRANSACTION  
  
              /************************************* TRANSACTION *************************************/  
              IF ( @Dept_ID <> 0 )  
                BEGIN  
                    SELECT @_DeptShortNm = Isnull (M_Department.dept_short_name, '-' )  
                    FROM   M_Department WITH (nolock)  
                    WHERE  M_Department.dept_id = @Dept_ID  
                END  
              ELSE  
                BEGIN  
                    SET @RetMsg ='Please Select Department.'  
                    SET @RetVal = -1  
  
                    RETURN  
                END  
  
              SELECT @_POIdddd = Isnull(po_id, 0),  
                     @_PO_Type111 = Isnull(PO_MST.PO_Type, '')  
              FROM   PO_MST with(nolock)  
              WHERE  po_id = @PO_Id AND po_type = 'D'  
  
              IF ( @PO_Type <> 'D' )  
                BEGIN  
                    SET @Year_Id = dbo.Get_financial_yearid( CONVERT (DATE, @PO_Date) )  
                    SET @_Financial_Year = dbo.Get_financial_year( CONVERT (DATE, @PO_Date) )  

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
  
                    --SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))                      
                    --               SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, dbo.Get_sysdate()) )                      
                    --SELECT @_Invoice_No = Isnull(Max(PO_MST.invoice_no), 0) + 1  
                    --FROM   PO_MST WITH(nolock)  
                    --WHERE  PO_MST.year_id = @Year_Id  
                    --       AND PO_Type <> 'D' -- = @PO_Type     
                    --       AND PO_MST.Dept_ID = @Dept_ID  
  
                    SET @OrderNo = 'HF/' + @_DeptShortNm + '/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year )  
  
                    UPDATE PO_MST WITH (rowlock)  
                    SET    Invoice_No = CASE  
                                          WHEN @_PO_Type111 = 'D' THEN  
                                          @_Invoice_No  
                                          ELSE PO_MST.Invoice_No  
                                        END,  
                           OrderNo = CASE  
                                       WHEN @_PO_Type111 = 'D' THEN @OrderNo  
                                       ELSE PO_MST.OrderNo  
                                     END,  
                           Year_Id = CASE  
                                       WHEN @_PO_Type111 = 'D' THEN @Year_Id  
                                       ELSE PO_MST.Year_Id  
                                     END,  
                           PO_Date = CASE  
                                       WHEN @_PO_Type111 = 'D' THEN @PO_Date  
                                     /*dbo.Get_sysdate()*/  
                                       ELSE PO_MST.PO_Date  
                                     END  ,  
                           Is_AutoNo = case  
                                       when @_PO_Type111 = 'D' then @_Is_AutoNo /*dbo.Get_sysdate()*/  
                                       else PO_MST.Is_AutoNo  
                                     end  
                    WHERE  po_id = @PO_Id  
                END  
  
              UPDATE PO_MST WITH (rowlock)  
              SET  ---OrderNo = ( case when @_POIdddd > 0 then  @OrderNo  else  OrderNo end  ) ,                                  
       -- PO_Date = @PO_Date  ,                                                            
				   PO_Type = @PO_Type,  
				   ReqRaisedBy_Id = @ReqRaisedBy_Id,  
				   Godown_Id = @Godown_Id,  
				   GrossAmount = @GrossAmount,  
				   AdvanceAmount = @AdvanceAmount,
                   DiscountPercentageOverall=@DiscountPercentageOverall,  
				   Admin_Charges = @Admin_Charges,  
				   Insurance = @Insurance,  
				   Other_Charges = @Other_Charges,  
				   NetAmount = @NetAmount,  
				   PaymentTerms = @PaymentTerms,  
				   DeliveryTerms = @DeliveryTerms,  
				   AdditionalTerms = @AdditionalTerms,  
				   [CGST] = @CGST,  
				   [SGST] = @SGST,  
				   [IGST] = @IGST,  
				   [CGSTTotal] = @CGSTTotal,  
				   [SGSTTotal] = @SGSTTotal,  
				   [IGSTTotal] = @IGSTTotal,  
				   Remark = @Remark,  
				   Upd_User = @Upd_User,  
				   Upd_Date = dbo.Get_sysdate()  
              WHERE  PO_Id = @PO_Id  
  
              IF @@ERROR = 0  
                BEGIN  
                    SET @RetVal = @PO_Id  
                    -- 1 IS FOR SUCCESSFULLY EXECUTED                                                              
                    SET @RetMsg = 'Raise PO Update Successfully And Update Order No is : ' + @OrderNo + ' .'  
  
                    IF @Type = 'Revision'  
                      BEGIN  
                          UPDATE PO_MST  
                          SET    Revision = Isnull(Revision, 0) + 1  
                          WHERE  PO_Id = @PO_Id  
                      END  
  
                    --if  @Type != 'Revision'                    
                    BEGIN  
                        DELETE FROM po_dtl WITH(rowlock)  
                        WHERE  po_dtl.podtl_id NOT IN (SELECT podtl_id  
                                                       FROM   @DtlPara)  
                               AND po_dtl.po_id = @PO_Id  
                    END  
  
                    DECLARE purchase_cur CURSOR FOR  
                      SELECT podtl_id,  
                             item_group_id,  
                             item_cate_id,  
                             item_id,  
                             supdetail_id,  
                             orderqty, 
                             Discount_Percentage,
                             unit_id,  
                             CONVERT(NUMERIC(18, 3), length),  
                             CONVERT(NUMERIC(18, 3), weight),  
                             totalweight,  
                             unitcost,  
                             totalcost,  
                             project_id,  
                             remark,  
                             width,  
                             thickness,  
                             Ref_Code,  
                             Charg_Height,  
                             Charg_Weight  
                      FROM   @DtlPara  
                      WHERE  podtl_id = ( CASE  
                                            WHEN @Type = 'Revision' THEN  
                                            podtl_id  
                                            ELSE 0  
                                          END );  
  
                    OPEN purchase_cur  
  
                    FETCH next FROM purchase_cur INTO @_PODtl_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id , @_Length ,  
       @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness, @_Ref_Code, @_Charg_Height, @_Charg_Weight  
  
                    WHILE @@FETCH_STATUS = 0  
                      BEGIN  
                          IF ( @_PODtl_Id = 0 )  
                            BEGIN  
                                INSERT INTO po_dtl WITH(rowlock)  
                                            (Discount_Percentage,
                                             po_id,  
                                             Item_Group_Id,  
                                             Item_Cate_Id,  
                                             item_id,  
                                             supdetail_id,  
                                             orderqty,  
												pendingqty,  
                                             unit_id,  
                                             [length],  
                                             [weight],  
                                             totalweight,  
                                             unitcost,  
                                             totalcost,  
                                             project_id,  
                                             remark,  
                                             width,  
                                             thickness,  
                                             Ref_Code,  
                                             Charg_Height,  
                                             Charg_Weight)  
                                VALUES      ( @Discount_Percentage,
                                              @RetVal,  
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
                                              @_Ref_Code,  
                                              @_Charg_Height,  
                                              @_Charg_Weight )  
                            END  
                          ELSE  
                            BEGIN  
                                DECLARE @__PendingQty AS numeric(18, 3) = 0  
  
                                IF @Type != 'Revision'  
                                  BEGIN  
                                      SELECT @__PendingQty = Isnull (PO_DTL.PendingQty, 0)  
                                      FROM   PO_DTL WITH(nolock)  
                                      WHERE  PODtl_Id = @_PODtl_Id  
                                  END  
                                ELSE  
                                  BEGIN  
                                      DECLARE @__ReceiveQty AS numeric(18, 3) = 0  
  
                                      SELECT @__ReceiveQty = Isnull(Sum( Isnull(GRN_Dtl.ReceiveQty , 0 )) , 0)  
                                      FROM   GRN_Dtl WITH(nolock)  
                                      WHERE  PODtl_Id = @_PODtl_Id  
  
                                      --select @__PendingQty = isnull (PO_DTL.OrderQty,0) from PO_DTL with(nolock) where PODtl_Id = @_PODtl_Id                  
                                      SET @__PendingQty = @_OrderQty - @__ReceiveQty  
                                  END  
  
                                UPDATE [dbo].[PO_DTL]  
                                SET    [OrderQty] = @_OrderQty,
                                [Discount_Percentage] = @Discount_Percentage,
                                       [PendingQty] = Isnull(@__PendingQty, 0),  
                                       [Project_Id] = @_Project_Id,  
                                       [Length] = CONVERT(NUMERIC(18, 3), @_Length),  
                                       [TotalWeight] = @_TotalWeight,  
                                       [UnitCost] = @_UnitCost,  
                                       [TotalCost] = @_TotalCost,  
                                       [Width] = @_Width,  
                                       [Thickness] = @_Thickness,  
                                       [Remark] = @_Remark,  
                           Ref_Code = @_Ref_Code,  
                                       Charg_Height = @_Charg_Height,  
                                       Charg_Weight = @_Charg_Weight  
                                WHERE  PODtl_Id = @_PODtl_Id  
                            END  
  
                          FETCH next FROM purchase_cur INTO @_PODtl_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id , @_Length ,  
                          @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness, @_Ref_Code, @_Charg_Height, @_Charg_Weight  
                      END  
  
                    CLOSE purchase_cur;  
  
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
GO


