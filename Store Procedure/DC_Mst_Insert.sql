USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DC_Mst_Insert]    Script Date: 27-04-2026 11:22:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                     
ALTER PROCEDURE [dbo].[DC_Mst_Insert] @DC_Type           VARCHAR(500),      
                                       @DC_Id             INT,      
                                       @DC_No             VARCHAR(500),      
                                       @DC_Date           DATE,      
                                       @SiteEnginner_Id   INT,      
                                       @FrGodown_Id       INT,      
                                       @Godown_Id         INT,      
                                       @QuotationNo       VARCHAR(500),      
                                       @ProjectDocument   VARCHAR(500),      
                                       @TransportType     VARCHAR(500),      
                                       @Vehicle_No        VARCHAR(500),      
                                       @Driver_Name       VARCHAR(500),      
                                       @Contact_of_Driver VARCHAR(500),      
                                       @ChallanType       VARCHAR(500),      
                                       @GrossAmount       NUMERIC(18, 3),      
                                       @CGST              INT,      
                                       @CGSTTotal         NUMERIC(18, 3),      
                                       @SGST              INT,      
                                       @SGSTTotal         NUMERIC(18, 3),      
                                       @IGST              INT,      
                                       @IGSTTotal         NUMERIC(18, 3),      
                                       @NetAmount         NUMERIC(18, 3),      
                                       @Remark            VARCHAR(500),      
                                       @MAC_Add           VARCHAR(500),      
                                       @Entry_User        INT,      
                                       @Upd_User          INT,      
                                       @Year_Id           INT,      
                                       @Branch_ID         INT,      
                                       @DtlPara           TBL_GCDETAIL readonly,      
                                       @RetVal            INT = 0 out,      
                                       @RetMsg            VARCHAR(max) = '' out      
AS      
    SET nocount ON      
      
              
 set @Year_Id = dbo.Get_Financial_YearId(CONVERT (date, @DC_Date ))       
       
 declare @_Financial_Year as int = 0        
 Set @_Financial_Year = dbo.Get_Financial_Year(CONVERT (date, @DC_Date ))       
      
      
      
  BEGIN try      
      BEGIN TRANSACTION      
      /************************************* TRANSACTION *************************************/      
      DECLARE @_DeptShortNm AS VARCHAR(20)='',      
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
            
   SELECT @_Invoice_No = Isnull(Max(dc_mst.invoice_no), 0) + 1      
      FROM   dc_mst WITH(nolock)      
      WHERE  dc_mst.dc_type = 'DC'      
             AND dc_mst.year_id = @Year_Id      
      
      --SET @OrderNo = 'HF/'+ @_DeptShortNm +'/'+ CONVERT(varchar(20),format(@_Invoice_No,'0000')) + '/' +CONVERT(varchar(20), @_Financial_Year)     
         
      SET @DC_No = 'HF/DC/'      
                   + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000'))      
    + '/'      
                   + CONVERT(VARCHAR(20), @_Financial_Year)      
      
      -- Eg. HF/ALU/1002/2122            
      INSERT INTO dc_mst WITH(rowlock)      
                  (dc_type,      
                   invoice_no,      
                   dc_no,      
                   dc_date,      
                   siteenginner_id,      
                   frgodown_id,      
                   godown_id,      
                   quotationno,      
                   projectdocument,      
                   transporttype,      
                   vehicle_no,      
                   driver_name,      
                   contact_of_driver,      
                   challantype,      
                   grossamount,      
                   cgst,      
                   sgst,      
                   igst,      
                   cgsttotal,      
                   sgsttotal,      
                   igsttotal,      
                   netamount,      
                   remark,      
                   mac_add,      
                   entry_user,      
                   entry_date,      
                   year_id,      
                   branch_id)      
      VALUES     ( @DC_Type,      
                   @_Invoice_No,      
                   @DC_No,      
                   @DC_Date,      
                   @SiteEnginner_Id,      
                   @FrGodown_Id,      
                   @Godown_Id,      
                   @QuotationNo,      
                   @ProjectDocument,      
                   @TransportType,      
                   @Vehicle_No,      
                   @Driver_Name,      
                   @Contact_of_Driver,      
                   @ChallanType,      
                   @GrossAmount,      
                   @CGST,      
                   @SGST,      
                   @IGST,      
                   @CGSTTotal,      
                   @SGSTTotal,      
                   @IGSTTotal,      
                   @NetAmount,      
                   @Remark,      
                   @MAC_Add,      
                   @Entry_User,      
                   dbo.Get_sysdate(),      
                   @Year_Id,      
                   @Branch_ID )      
      
      SET @RetMsg = 'Delivery Challan Generate Successfully And Generated DC No is : ' + @DC_No + ' .'      
      SET @RetVal = Scope_identity()      
      
      IF @@ERROR <> 0      
        BEGIN      
            SET @RetVal = 0      
            -- 0 IS FOR ERROR                                           
            SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
        END      
      ELSE      
        BEGIN      
            DECLARE @_SrNo          AS INT= 0,      
                    @_Id            AS INT= 0,      
                    @_Dept_ID       AS INT= 0,      
                    @_DCDtl_Id      AS INT= 0,      
                    @_DC_Id         AS INT= 0,      
                    @_Item_Group_Id AS INT= 0,      
                    @_Item_Cate_Id  AS INT= 0,      
                    @_Item_Id       AS INT= 0,      
                    @_Qty           AS NUMERIC(18, 3) = 0,      
                    @_Unit_Id       AS INT= 0,      
                    @_ItemLength    AS NUMERIC(18, 3) = 0,      
                    @_Rate          AS NUMERIC(18, 3) = 0,      
                    @_TotalValue    AS NUMERIC(18, 3) = 0,      
                    @_Remark        AS VARCHAR(500)= ''      
                  
   DECLARE db_cursor CURSOR FOR      
              SELECT srno,      
                     id,      
                     dept_id,      
                     dcdtl_id,      
                     dc_id,      
                     item_group_id,      
                     item_cate_id,      
                     item_id,      
                     qty,      
                     unit_id,      
                     itemlength,      
                     rate,      
                     totalvalue,      
                     remark      
              FROM   @DtlPara;      
      
            OPEN db_cursor      
      
            FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_Dept_ID, @_DCDtl_Id, @_DC_Id,      
            @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_Qty, @_Unit_Id, @_ItemLength , @_Rate, @_TotalValue, @_Remark      
      
            WHILE @@FETCH_STATUS = 0      
              BEGIN      
                  INSERT INTO DC_Dtl WITH(rowlock)      
                              (dc_id,      
                               dept_id,      
                               item_group_id,      
                               item_cate_id,      
                               item_id,      
                               qty,      
                               unit_id,      
                               itemlength,      
                               rate,      
                               totalvalue,      
                               remark)      
                  VALUES     ( @RetVal,      
                               @_Dept_ID,      
                               @_Item_Group_Id,      
                               @_Item_Cate_Id,      
                               @_Item_Id,      
                               @_Qty,      
                               @_Unit_Id,      
                               @_ItemLength,      
                               @_Rate,      
                               @_TotalValue,      
                               @_Remark )      

				 Declare @_V As Int = Scope_identity()  	

                  UPDATE stockview WITH (rowlock)      
                  SET    sales_qty = Isnull(sales_qty, 0) + @_Qty,      
                         pending_qty = Isnull(pending_qty, 0) - @_Qty,      
                         lastupdate = dbo.Get_sysdate(),    
						 StockEntryPage = 'DC-GRN'   ,  
						 StockEntryQty  = @_Qty  ,
						 Dtl_Id = @_V ,
						 Tbl_Name = 'DC_Dtl'
                  WHERE  id = @_Id      
      
     FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_Dept_ID, @_DCDtl_Id, @_DC_Id,      
     @_Item_Group_Id, @_Item_Cate_Id, @_Item_Id, @_Qty, @_Unit_Id, @_ItemLength , @_Rate, @_TotalValue, @_Remark      
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
      
      SET @RetVal = -405 -- 0 IS FOR ERROR                                            
      SET @RetMsg ='Error Occurred - ' + Error_message() + '.'      
  END catch 
GO


