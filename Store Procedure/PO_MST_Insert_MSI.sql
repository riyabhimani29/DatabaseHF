USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_Insert_MSI]    Script Date: 27-04-2026 14:23:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[PO_MST_Insert_MSI]                  
            @PO_Id              INT, 
            @PO_Req_Id             INT,
                                      @PO_Type            VARCHAR(50),                
                                      @Dept_ID            INT,
                                      @Invoice_No          INT,
                                      @OrderNo            VARCHAR(500),                
                                      @PO_Date            DATETIME,                
                                      @ReqRaisedBy_Id     INT,                
                                      @BillingAddress     VARCHAR(500),                
                                      @Supplier_Id        INT,                
                                      @Godown_Id          INT,                
                                      @GrossAmount        NUMERIC(18, 3),                
                                      @AdvanceAmount      NUMERIC(18, 3),
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
                                      @Type            VARCHAR(500),                
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
            @_Thickness     AS NUMERIC(18, 3) = 0                
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
                    SELECT @_DeptShortNm =                
               Isnull (m_department.dept_short_name, '-')                
                    FROM   m_department WITH (nolock)                
                    WHERE  m_department.dept_id = @Dept_ID                
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
                end      
              else      
                begin            
                    set @_Invoice_No = @Invoice_No      
                end 
                
             -- SELECT @_Invoice_No = Isnull(Max(po_mst.invoice_no), 0) + 1                
             -- FROM   po_mst WITH(nolock)                
             -- WHERE  po_mst.year_id = @Year_Id                
                  --   AND po_type <> 'D' -- = @PO_Type 
					-- AND  PO_MST.Dept_ID = @Dept_ID
                      
              SET @OrderNo = 'HF/' + @_DeptShortNm + '/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)                
                                                                                   
              INSERT INTO PO_MST WITH(rowlock)                
                          (po_type,                
                           dept_id,                
                           orderno,                
                           invoice_no,                
                           po_date,                
                           reqraisedby_id,                
                           billingaddress,                
                           supplier_id,                
                           godown_id,                
                           grossamount,                
                           advanceamount, 
                           DiscountPercentageOverall,
                           netamount,                
                           paymentterms,                
                           deliveryterms,                
                           additionalterms,                
                           authoriseperson_id,                
                           approvedate,                
                           remark,                
                           mac_add,                
                           entry_user,                
                           entry_date,                
                           upd_user,                
                           upd_date,                
                           year_id,                
                           branch_id,                
                           order_type,                
                           [cgst],                
                           [sgst],                
                           [igst],                
                           [cgsttotal],                
                           [sgsttotal],                
                           [igsttotal],            
         Revision)                
              VALUES     ( @PO_Type,                
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
                           'PO-MSI',                
                           @CGST,                
                           @SGST,                
               @IGST,                
                           @CGSTTotal,                
                           @SGSTTotal,                
                           @IGSTTotal,            
         0)                
                
              SET @RetVal = Scope_identity()                
                
              IF ( @PO_Type = 'D' )                
                BEGIN                
                    SET @RetMsg = 'Raise PO Generate Successfully And Generated Order No is : ' + CONVERT (VARCHAR(20), @RetVal) + ' .'                
                END                
              ELSE                
                BEGIN                
                    SET @RetMsg = 'Raise PO Generate Successfully And Generated Order No is : ' + @OrderNo + ' .'                
                END                
                
              SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0),                
                                Replace( Replace(Replace(Replace( Sysutcdatetime(), '-', ''), ' ', ''), ':', ''), '.', '')) + @RetVal) + '.png'                
                
              UPDATE PO_MST   with(rowlock)              
              SET    Doc_Img_Name = @_ImageName                
              WHERE  PO_Id = @RetVal                
                
              UPDATE PO_MST  with(rowlock)                         
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
                      SELECT 
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
                             thickness                
                      FROM   @DtlPara;                
                
                    OPEN purchase_cur                
                
                    FETCH next FROM purchase_cur INTO @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id,                 
      @_Length, @_Weight, @_TotalWeight , @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness                
                
                    WHILE @@FETCH_STATUS = 0                
         BEGIN                
                          INSERT INTO po_dtl WITH(rowlock)                
                                      (
                                       po_id,/*Item_Group_Id ,Item_Cate_Id ,*/                
                                       item_id,                
                                       supdetail_id,                
                                       orderqty,Discount_Percentage, 
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
                                       thickness)                
                          VALUES     ( 
                                       @RetVal,                
                                       /*@_Item_Group_Id,@_Item_Cate_Id,*/                
                                       @_Item_Id,                
                                       @_SupDetail_Id,                
                                       @_OrderQty,  @Discount_Percentage, 
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
                                       @_Thickness )                
                
                          FETCH next FROM purchase_cur INTO  @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id , @_SupDetail_Id, @_OrderQty,@Discount_Percentage,                 
           @_Unit_Id, @_Length, @_Weight, @_TotalWeight , @_UnitCost, @_TotalCost, @_Project_Id,                 
           @_Remark, @_Width, @_Thickness                
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
                
              SET @RetVal = -405 -- 0 IS FOR ERROR                                                                    
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'                
          END catch                
      END                
    ELSE   /*---------- Edit Mode---------*/              
      BEGIN    
      IF ( @Invoice_No = 0 )      
            Begin      
                set @_Is_AutoNo = 1      
            end  
          BEGIN try               
              IF NOT EXISTS(SELECT 1                
                            FROM   po_mst WITH (nolock)                
                            WHERE  po_id = @PO_Id)                
                BEGIN                
                    SET @RetVal = -2                
                    -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                        
                    SET @RetMsg = @OrderNo + ' This PO Not Exist .'                
                
                    RETURN                
                END                
                
              DECLARE @OrderQty   AS NUMERIC(18, 3)=0,                
                      @PendingQty AS NUMERIC(18, 3)=0                
                  
  if @Type = 'Revision'              
  begin              
     --SELECT @OrderQty = Isnull(Sum(orderqty), 0),                
     --@PendingQty = Isnull(Sum(pendingqty), 0)                
     --FROM   po_dtl WITH(nolock)                
     --WHERE  po_id = @PO_Id                
                     
  select @PendingQty = (sum (Isnull(RR.ReceiveQty,0)) + sum (Isnull(PO_DTL.PendingQty,0))) ,                
    @OrderQty = Sum(Isnull(PO_DTL.OrderQty, 0))  from  PO_DTL   WITH(nolock)                
  Cross Apply (   select SUM (GRN_Dtl.ReceiveQty) AS  ReceiveQty from  GRN_Dtl   WITH(nolock)                
      where GRN_Dtl.PODtl_Id  = PO_DTL.PODtl_Id              
     ) as RR              
  where PO_DTL.PO_Id = @PO_Id               
               
  end              
  else               
  begin              
     SELECT @OrderQty = Isnull(Sum(orderqty), 0),                
     @PendingQty = Isnull(Sum(pendingqty), 0)                
     FROM   po_dtl WITH(nolock)                
     WHERE  po_id = @PO_Id                
  end              
                       
              IF ( @OrderQty <> @PendingQty )                
                BEGIN                
                    SET @RetVal = -4                
                    -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                        
                   SET @RetMsg = @OrderNo    + ' This PO Not Edit Beacuse PO QTY Use .'                     
                    RETURN                
                END                
                
              SET @_ImageName = ''                
                
              DECLARE @_POIdddd INT = 0  , @_PO_Type111 varchar(10)   =''              
  BEGIN TRANSACTION                
              /************************************* TRANSACTION *************************************/                
                
              IF ( @Dept_ID <> 0 )                
                BEGIN                
                    SELECT @_DeptShortNm =  Isnull (m_department.dept_short_name, '-')                
                    FROM   m_department WITH (nolock)                
                    WHERE  m_department.dept_id = @Dept_ID                
                END                
              ELSE                
                BEGIN                
                    SET @RetMsg ='Please Select Department.'                
                    SET @RetVal = -1                
                
                    RETURN                
                END                
                
              SELECT @_POIdddd = Isnull(po_id, 0)   ,
					 @_PO_Type111 = Isnull(PO_MST.PO_Type, '')              
              FROM   po_mst                
              WHERE  po_id = @PO_Id  AND po_type = 'D'                
                
              IF ( @PO_Type <> 'D' )                
                BEGIN                
					--SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))                
     --               SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, dbo.Get_sysdate()) )             
					SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, @PO_Date))                
                    SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, @PO_Date) )  	 
                
    -- SELECT @_Invoice_No = Isnull(Max(po_mst.invoice_no), 0) + 1                
    -- FROM   po_mst WITH(nolock)                
   --  WHERE  po_mst.year_id = @Year_Id                
    --   AND po_type <> 'D' -- = @PO_Type  
	  -- AND  PO_MST.Dept_ID = @Dept_ID

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
      
                
     SET @OrderNo = 'HF/' + @_DeptShortNm + '/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)                 
     UPDATE PO_MST WITH (rowlock)              
     SET    Invoice_No = case when @_PO_Type111 = 'D' then  @_Invoice_No else PO_MST.Invoice_No end ,     
		   OrderNo = case when @_PO_Type111 = 'D' then   @OrderNo else PO_MST.OrderNo end,              
		   Year_Id = case when @_PO_Type111 = 'D' then   @Year_Id else PO_MST.Year_Id end,              
		   PO_Date = case when @_PO_Type111 = 'D' then   @PO_Date/*dbo.Get_sysdate()*/   else  PO_MST.PO_Date  end  	   
     WHERE  po_id = @PO_Id                    
    END                
                
    UPDATE PO_MST WITH (rowlock)                
    SET                
     ---OrderNo = ( case when @_POIdddd > 0 then  @OrderNo  else  OrderNo end  ) ,                            
     -- PO_Date = @PO_Date  ,                                                      
     po_type = @PO_Type,                
     reqraisedby_id = @ReqRaisedBy_Id,                
     godown_id = @Godown_Id,                
     grossamount = @GrossAmount,                
     advanceamount = @AdvanceAmount,                
     netamount = @NetAmount,                
     paymentterms = @PaymentTerms,             
     deliveryterms = @DeliveryTerms,                
     additionalterms = @AdditionalTerms,
     DiscountPercentageOverall=@DiscountPercentageOverall,
     [cgst] = @CGST,                
     [sgst] = @SGST,                
     [igst] = @IGST,                
     [cgsttotal] = @CGSTTotal,                
     [sgsttotal] = @SGSTTotal,                
     [igsttotal] = @IGSTTotal,                
     remark = @Remark,                
     upd_user = @Upd_User,                
     upd_date = dbo.Get_sysdate()                
    WHERE  po_id = @PO_Id                
                
    IF @@ERROR = 0                
    BEGIN              
             
  SET @RetVal = @PO_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                                                        
  SET @RetMsg = 'Raise PO Update Successfully And Update Order No is : ' + @OrderNo + ' .'                
            
     if  @Type = 'Revision'              
     begin            
    update PO_MST set Revision = ISNULL(Revision,0) + 1    WHERE  po_id = @PO_Id                
            
            
   end            
            
    --if  @Type != 'Revision'              
    begin              
   DELETE FROM po_dtl WITH(rowlock)                
   WHERE  po_dtl.podtl_id NOT IN (SELECT podtl_id FROM   @DtlPara) AND po_dtl.po_id = @PO_Id                 
    end              
              
  DECLARE purchase_cur CURSOR FOR                
              
  SELECT 
    podtl_id,                
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
    thickness                
  FROM   @DtlPara  where podtl_id = (case when @Type = 'Revision' then podtl_id else 0 end )  ;                
                
  OPEN purchase_cur                
                
  FETCH next FROM purchase_cur INTO @_PODtl_Id, @_Item_Group_Id,                
  @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage, @_Unit_Id ,                
  @_Length , @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id,                
  @_Remark, @_Width, @_Thickness                
                
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
   thickness)                
   VALUES (@Discount_Percentage,
   @RetVal,   
   0,
   0,            
   @_Item_Id,                
   @_SupDetail_Id,                
   ISNULL( @_OrderQty,0),    

   ISNULL(@_OrderQty,0),                
   @_Unit_Id,                
   CONVERT(NUMERIC(18, 3), @_Length),                
   CONVERT(NUMERIC(18, 3), @_Weight),                
   @_TotalWeight,                
   @_UnitCost,                
   @_TotalCost,                
   @_Project_Id,                
   @_Remark,                
   @_Width,                
   @_Thickness )                
   END                
  ELSE                
  BEGIN                
            
 declare @__PendingQty as numeric(18,3) = 0            
 if  @Type != 'Revision'              
    begin              
  select @__PendingQty = isnull (PO_DTL.PendingQty,0) from PO_DTL with(nolock) where PODtl_Id = @_PODtl_Id            
    end           
 else           
 begin          
  declare @__ReceiveQty as numeric(18,3) = 0            
  select @__ReceiveQty = SUM(ISNULL(GRN_Dtl.ReceiveQty ,0)) from GRN_Dtl with(nolock) where PODtl_Id = @_PODtl_Id           
  --select @__PendingQty = isnull (PO_DTL.OrderQty,0) from PO_DTL with(nolock) where PODtl_Id = @_PODtl_Id            
          
  --set  @__PendingQty = @_OrderQty - @__ReceiveQty 
  set @__PendingQty = ISNULL(@_OrderQty - @__ReceiveQty, @_OrderQty)

             
 end           
             
   UPDATE [dbo].[po_dtl]                
    SET  
    [orderqty] = @_OrderQty,  
[Discount_Percentage] = @Discount_Percentage,
    [pendingqty] = ISNULL(@__PendingQty ,0)   ,       
    [project_id] = @_Project_Id,                
    [length] = CONVERT(NUMERIC(18, 3), @_Length) ,                
    [totalweight] = @_TotalWeight,                
    [unitcost] = @_UnitCost,                
    [totalcost] = @_TotalCost,                
    [width] = @_Width,                
    [thickness] = @_Thickness,                
    [remark] = @_Remark                
    WHERE  podtl_id = @_PODtl_Id                
  END                
                
  FETCH next FROM purchase_cur INTO  @_PODtl_Id, @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_SupDetail_Id, @_OrderQty,@Discount_Percentage,                
  @_Unit_Id , @_Length , @_Weight, @_TotalWeight, @_UnitCost, @_TotalCost, @_Project_Id, @_Remark, @_Width, @_Thickness                
  END                
                
  CLOSE purchase_cur;                
                
  DEALLOCATE purchase_cur;                
  END                
    ELSE                
    BEGIN                
    SET @RetVal = 0                
    -- 0 WHEN AN ERROR HAS OCCURED                                                        
    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'              END                
                
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
GO


