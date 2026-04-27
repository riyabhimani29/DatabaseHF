USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coatdc_mst_insert_TMP]    Script Date: 27-04-2026 11:07:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 


ALTER PROCEDURE [dbo].[Coatdc_mst_insert_TMP] @DC_Type           VARCHAR(500),    
                                          @CODC_Type         VARCHAR(500),    
                                          @DC_Id             INT,    
                                          @Project_Id        INT,    
                                          @Godown_Id         INT,    
                                          @Coating_ShadeId   INT,    
                                          @DC_No             VARCHAR(500),    
                                          @DC_Date           DATE,    
                                          @SiteEnginner_Id   INT,    
                                          @Supplier_Id       INT,    
                                          @Coating_Shade     VARCHAR(500),    
                                          @Coating_Rate      NUMERIC(18, 3),    
                                          @Aluminium_Rate    NUMERIC(18, 3),    
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
                                          @CGST_MV           INT,    
                                          @CGST_MVTotal      NUMERIC(18, 3),    
                                          @SGST_MV           INT,    
                                          @SGST_MVTotal      NUMERIC(18, 3),    
                                          @IGST_MV           INT,    
                                          @IGST_MVTotal      NUMERIC(18, 3),    
                                          @Issue_ById        INT,    
                                          @NetAmount         NUMERIC(18, 3),    
                                          @Remark            VARCHAR(500),    
                                          @MAC_Add           VARCHAR(500),    
                                          @Entry_User        INT,    
                                          @Upd_User          INT,    
                                          @Year_Id           INT,    
                                          @Branch_ID         INT,    
                                          @Packing_Charge    NUMERIC(18, 3),    
                                          @DtlPara           TBL_COSTGCDETAIL readonly,    
                                          @RetVal            INT = 0 out,    
                                          @RetMsg            VARCHAR(max) = '' out,    
                                          @_ImageName        VARCHAR(max) = '' out    
AS    
    SET nocount ON    
    
    /************** Variable Declare *****************/    
    DECLARE @_Id             AS INT= 0,    
            @_SrNo           AS INT= 0,    
            @_DCDtl_Id       AS INT= 0,    
            @_Dept_ID        AS INT= 0,    
            @_DO_Id          AS INT= 0,    
            @_Item_Id        AS INT= 0,    
            @_Calc_Area      AS NUMERIC(18, 3) = 0,    
            @_Running_Feet   AS NUMERIC(18, 3) = 0,    
            @_Rate_Feet      AS NUMERIC(18, 3) = 0,    
            @_Coating_Value  AS NUMERIC(18, 3) = 0,    
            @_Qty            AS NUMERIC(18, 3) = 0,    
            @_ItemLength     AS NUMERIC(18, 3) = 0,    
            @_Total_Weight   AS NUMERIC(18, 3) = 0,    
            @_Material_Value AS NUMERIC(18, 3) = 0,    
            @_Remark         AS VARCHAR(500)= '',    
            @_DC_Qty         AS NUMERIC(18, 3) = 0,    
            @_Scrap_Qty      AS NUMERIC(18, 3) = 0,    
            @_Scrap_Length   AS NUMERIC(18, 3) = 0,    
            @_Godown_Id1     AS INT= 0,    
            @_Weight         AS NUMERIC(18, 3) = 0,    
            @_IsRevision     AS BIT =0,    
            @_DCStatus       AS VARCHAR(500)= ''    
    
    SET @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, @DC_Date))    
    
    DECLARE @_Financial_Year AS INT = 0    
    
    SET @_Financial_Year = dbo.Get_financial_year(CONVERT (DATE, @DC_Date))    
    
    /************** Variable Declare *****************/    
    IF ( @DC_Id = 0 )    
      /*********** New Entry  Start ***********/    
      BEGIN    
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
                  
     SELECT @_Invoice_No = Isnull(Max(DC_Mst.invoice_no), 0) + 1    
              FROM   DC_Mst WITH(nolock)    
              WHERE  DC_Mst.dc_type = @DC_Type --'CO-DC'                                            
                     AND DC_Mst.year_id = @Year_Id    
                     AND codc_type <> 'D'    
              -- = @CODC_Type                                
              -- Eg. HF/ALU/1002/2122                                                                                         
              --SET @OrderNo = 'HF/'+ @_DeptShortNm +'/'+ CONVERT(varchar(20),format(@_Invoice_No,'0000')) + '/' +CONVERT(varchar(20), @_Financial_Year)                                                
              SET @DC_No = 'HF/CODC/'    
                           + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000'))    
                           + '/' + CONVERT(VARCHAR(20), @_Financial_Year)    
    
              INSERT INTO [dbo].[DC_Mst] WITH (rowlock)    
                          (codc_type,    
                           [dc_type],    
                           [invoice_no],    
                           [dc_no],    
                           [dc_date],    
                           [project_id],    
                           [supplier_id],    
                           [siteenginner_id],    
                           [frgodown_id],    
                           [Godown_Id],    
                           [quotationno],    
                           [projectdocument],    
                           [transporttype],    
                    [vehicle_no],    
                           [driver_name],    
                           [contact_of_driver],    
                           coating_shadeid,    
                           [challantype],    
                           [coating_shade],    
                          [coating_rate],    
                           [aluminium_rate],    
                           [grossamount],    
                           [cgst],    
                           [sgst],    
                           [igst],    
                           [cgsttotal],    
                           [sgsttotal],    
                           [igsttotal],    
                           [netamount],    
                           [remark],    
                           [mac_add],    
                           [entry_user],    
                           [entry_date],    
                           [year_id],    
                           [branch_id],    
                           [cgst_mv],    
                           [sgst_mv],    
                           [igst_mv],    
                           [cgst_mvtotal],    
                           [sgst_mvtotal],    
                           [igst_mvtotal],    
                           issue_byid,    
                           packing_charge)    
              VALUES      (@CODC_Type,    
                           @DC_Type,    
                           @_Invoice_No,    
                           @DC_No    
                           /*(Case When @CODC_Type = 'D' then 1 else  @_Invoice_No end ) ,(Case When @CODC_Type = 'D' then '1' else   @DC_No end )*/,    
                           @DC_Date,    
                           @Project_Id,    
                           @Supplier_Id,    
                           @SiteEnginner_Id,    
                           0 /*frgodown_id*/,    
                           @Godown_Id,    
                           Isnull(@QuotationNo, ''),    
                           @ProjectDocument,    
                           @TransportType,    
                           @Vehicle_No,    
                           @Driver_Name,    
                           @Contact_of_Driver,    
                           @Coating_ShadeId,    
                           @ChallanType,    
                           @Coating_Shade,    
                           @Coating_Rate,    
                           @Aluminium_Rate,    
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
                           @Branch_ID,    
                           @CGST_MV,    
                           @SGST_MV,    
                           @IGST_MV,    
                           @CGST_MVTotal,    
                           @SGST_MVTotal,    
                           @IGST_MVTotal,    
                           @Issue_ById,    
                           @Packing_Charge)    
    
              SET @RetVal = Scope_identity()    
    
              IF ( @CODC_Type = 'D' )    
                BEGIN    
                    SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + CONVERT (VARCHAR(20), @RetVal) + '.'    
                END    
              ELSE    
                BEGIN    
                    SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + @DC_No + '.'    
                END    
    
              --   SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + @DC_No + '.'        
         
              SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0),    
                                Replace(    
                                Replace(Replace(Replace(    
                                Sysutcdatetime(), '-', ''), ' ', ''), ':', ''), '.', '')) + @RetVal) + '.png'    
    
              UPDATE DC_Mst WITH (rowlock)    
              SET    Doc_Img_Name = @_ImageName    
              WHERE  DC_Id = @RetVal    
    
              UPDATE DC_Mst  WITH (rowlock)    
              SET    DC_No = @RetVal    
              WHERE  DC_Id = @RetVal    
                     AND CODC_Type = 'D'    
    
              IF @@ERROR <> 0    
                BEGIN    
                    SET @RetVal = 0 -- 0 IS FOR ERROR                                                                                           
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
                END    
              ELSE    
                BEGIN    
                    DECLARE db_cursor CURSOR FOR    
    
                      SELECT srno,    
                             id,    
                             dcdtl_id,    
                             DC_Id,    
                             dept_id,    
                             Item_Id,    
                             calc_area,    
                             running_feet,    
                             rate_feet,    
                             coating_value,    
                             qty,    
                             dc_qty,    
                             itemlength,    
                             total_weight,    
                             material_value,    
                             remark,    
                             Scrap_Qty,    
                             scrap_length,    
                             Godown_Id,    
                             [weight]    
                      FROM   @DtlPara;    
    
                    OPEN db_cursor    
    
                    FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet,    
                    @_Coating_Value, @_Qty, @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value, @_Remark , @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight    
    
                    WHILE @@FETCH_STATUS = 0    
                      BEGIN    
                          INSERT INTO [dbo].[DC_Dtl] WITH (rowlock)    
                                      ([DC_Id],    
                                       [dept_id],    
                                       [item_group_id],    
                                       [item_cate_id],    
                                       [Item_Id],    
                                       [qty],    
                                       [unit_id],    
                                       [itemlength],    
                                       [rate],    
                                       [running_feet],    
                                       [rate_feet],    
                                       [coating_value],    
                                       [total_weight],    
                                       [material_value],    
                                       [totalvalue],    
                                       [remark],    
                                       dc_qty,    
                                       Scrap_Qty,    
                                       scrap_length,    
                                       Godown_Id,    
                                       stock_id,    
                                       calc_area,    
                                       weight_mtr,    
                                       Pending_Qty)    
                          VALUES      (@RetVal,    
                                       @_Dept_ID,    
                                       0,    
                                       0,    
                                       @_Item_Id,    
                                       @_Qty,    
                          0 /*unit_id*/,    
                                       @_ItemLength,    
                                       0 /*rate*/,    
                                       @_Running_Feet,    
                                       @_Rate_Feet,    
                                       @_Coating_Value,    
                                       @_Total_Weight,    
                                       @_Material_Value,    
                                       0 /*totalvalue*/,    
                                       @_Remark,    
                                       @_DC_Qty,    
                       @_Scrap_Qty,    
                                       @_Scrap_Length,    
                                       @_Godown_Id1,    
                                       @_Id,    
                                       @_Calc_Area,    
                                       @_Weight,    
                                       @_DC_Qty)    
    
                          DECLARE @_DID AS INT = Scope_identity()    
    
                          IF ( @CODC_Type = 'F' )    
                            /* Only Finally Save Then Stock Effect*/    
                            BEGIN    
                                UPDATE StockView WITH (rowlock)    
                                SET    sales_qty = Isnull(sales_qty, 0) + @_Qty,    
                                       Pending_Qty = Isnull(Pending_Qty, 0) - @_Qty,    
                                       LastUpdate = dbo.Get_sysdate()    
                                WHERE  id = @_Id    
    
                                DECLARE @_Godown_Id AS INT = 0,    
                                        @_SType     AS VARCHAR(5) = '',    
                                        @_Scarpval  AS NUMERIC(18, 2) = 0,    
                                        @_Width     AS NUMERIC(18, 3) = 0    
    
                                SELECT @_Godown_Id = Isnull(Godown_Id, 0),    
                                       @_SType = SType,    
                                       @_Width = Isnull(Width, 0)    
                                FROM   StockView WITH (nolock)    
                                WHERE  id = @_Id    
    
                                UPDATE DC_Dtl WITH (rowlock)    
                                SET    dc_width = @_Width,    
                                       scrap_width = @_Width    
                                WHERE  DC_Id = @_DID    
    
                                SELECT @_Scarpval = Isnull(master_numvals, 0)    
                                FROM   m_master WITH (nolock)    
                                WHERE  m_master.master_type = 'SCRAP'    
                                       AND m_master.is_active = 1    
    
                                IF EXISTS (SELECT 1    
                                           FROM   StockView WITH (nolock)    
                                           WHERE  StockView.Godown_Id = @_Godown_Id    
                                                  AND StockView.Item_Id = @_Item_Id    
                                                  AND StockView.SType = @_SType    
                                                  AND StockView.length = @_Scrap_Length    
                                                  AND StockView.Width = @_Width)    
                                  BEGIN    
                                      IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Length )    
                                        BEGIN    
                                            -- Scrap_Settle                                  
                                            UPDATE StockView WITH (rowlock)    
                                            SET    Scrap_Settle = Isnull( Scrap_Settle , 0) + @_Scrap_Qty,    
                                                   Scrap_Qty = Isnull( Scrap_Qty , 0) + @_Scrap_Qty,    
                                                   LastUpdate = dbo.Get_sysdate()    
            WHERE  StockView.Godown_Id = @_Godown_Id    
                                                   AND StockView.Item_Id = @_Item_Id    
                                                   AND StockView.SType = @_SType    
                                                   AND StockView.Length = @_Scrap_Length    
                                                   AND StockView.Width = @_Width    
                                        END    
                                      ELSE    
                                        BEGIN    
                                            UPDATE StockView WITH (rowlock)    
                                            SET    Pending_Qty = Isnull( Pending_Qty , 0) + @_Scrap_Qty ,    
                                               Scrap_Qty = Isnull( Scrap_Qty, 0) + @_Scrap_Qty,    
                                                   LastUpdate = dbo.Get_sysdate()    
                                            WHERE  StockView.Godown_Id = @_Godown_Id    
                                                   AND StockView.Item_Id = @_Item_Id    
                                                   AND StockView.SType = @_SType    
                                                   AND StockView.length = @_Scrap_Length    
                                                   AND StockView.Width = @_Width    
                                        END    
                                  END    
                                ELSE    
                                  BEGIN    
                                      IF ( @_Scarpval > 0    
                                           AND @_Scarpval > @_Scrap_Length )    
                                        BEGIN    
                                            -- Scrap_Settle                                                
                                            INSERT INTO [dbo].[StockView] WITH ( rowlock)    
                                                        ([Godown_Id],    
                                                         [Item_Id],    
                                                         [SType],    
                                                         [Total_Qty],    
                                                         [sales_qty],    
                                                         [Pending_Qty],    
                                                         [transfer_qty],    
                                                         [adjust_qty],    
                                                         [length],    
                                                         [Scrap_Qty],    
                                                         scrap_settle,    
                                                         LastUpdate,    
                                                         ref_id,    
                                                         Width)    
                                            VALUES      (@_Godown_Id,    
                                                         @_Item_Id,    
                                                         @_SType,    
                                                         0/*[Total_Qty]*/,    
                                                         0/*[sales_qty]*/,    
                                                         0/*[Pending_Qty]*/,    
                                                         0/*[transfer_qty]*/,    
                                                         0/*adjust_qty*/,    
                                                         @_Scrap_Length,    
                                                         @_Scrap_Qty,    
                                                         @_Scrap_Qty,    
                                                         dbo.Get_sysdate(),    
                                                         @_Id,    
                                                         @_Width)    
      END    
                                      ELSE    
                                        BEGIN    
                                            INSERT INTO [dbo].[StockView] WITH ( rowlock)    
                                                        ([Godown_Id],    
                                                         [Item_Id],    
                                                         [SType],    
                                                         [Total_Qty],    
                                                         [sales_qty],    
                                                         [Pending_Qty],    
                                                         [transfer_qty],    
                                                         [adjust_qty],    
                                                         [length],    
                                                         [Scrap_Qty],    
                                                         scrap_settle,    
                                                         LastUpdate,    
                                                         ref_id,    
                                                         Width)    
                                            VALUES      (@_Godown_Id,    
                                                         @_Item_Id,    
                                                         @_SType,    
                                                         0,    
                                                         0,    
                                                         @_Scrap_Qty,    
                                                         0,    
                                                         0,    
                                                         @_Scrap_Length,    
                                                         @_Scrap_Qty,    
                                                         0,    
                                                         dbo.Get_sysdate(),    
                                                         @_Id,    
                                                         @_Width)    
                                        END    
                                  END    
                            END    
    
                          FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, @_Coating_Value ,    
                          @_Qty, @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value, @_Remark, @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight    
    
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
              SET @RetMsg ='Error Occurred ' + Error_message() + '!!!'    
          END catch    
      END    
    /*********** New Entry  End ***********/    
    ELSE    
      BEGIN    
          /*********** Edit Entry Start ***********/    
          BEGIN try    
              BEGIN TRANSACTION    
    
              /************************************* TRANSACTION *************************************/    
              IF NOT EXISTS(SELECT 1    
                            FROM   [DC_Mst] WITH (nolock)    
                            WHERE  DC_Id = @DC_Id)    
                BEGIN    
                    SET @RetVal = -2    
                    -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                               
                    SET @RetMsg = @DC_No + ' This Coating DC is Not Exist.'    
    
                    RETURN    
                END    
    
              DECLARE @_POIdddd INT = 0    
    
              SELECT @_POIdddd = Isnull(DC_Id, 0)    
              FROM   DC_Mst    
              WHERE  DC_Id = @DC_Id    
                     AND codc_type = 'D'    
    
              SELECT @_Invoice_No = Isnull(Max(DC_Mst.invoice_no), 0) + 1    
              FROM   DC_Mst WITH(nolock)    
              WHERE  DC_Mst.year_id = @Year_Id    
                     AND codc_type = 'F' -- = @CODC_Type                
    
              IF ( @CODC_Type = 'F' )    
                BEGIN    
                    SET @DC_No = 'HF/CODC/' + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000') ) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)    
                   
                END    
    
              UPDATE [dbo].[DC_Mst] WITH (rowlock)    
              SET    dc_date = ( CASE    
                                   WHEN ( @CODC_Type <> 'D' ) THEN @DC_Date    
                                   ELSE dc_date    
                                 END ),    
                     invoice_no = ( CASE    
                                      WHEN ( @CODC_Type <> 'D' ) THEN    
                                      @_Invoice_No    
                                      ELSE invoice_no    
                                    END ),    
                     year_id = ( CASE    
                                   WHEN ( @CODC_Type <> 'D' ) THEN @Year_Id    
                                   ELSE year_id    
                                 END ),    
                     dc_no = ( CASE    
                                 WHEN ( @CODC_Type <> 'D' ) THEN @DC_No    
                                 ELSE dc_no    
                               END ),    
                     [codc_type] = @CODC_Type,    
                     [supplier_id] = @Supplier_Id,    
                     [siteenginner_id] = @SiteEnginner_Id,    
                     [issue_byid] = @Issue_ById,    
                     [project_id] = @Project_Id,    
                     [Godown_Id] = @Godown_Id,    
                     [quotationno] = @QuotationNo,    
                     coating_shadeid = @Coating_ShadeId,    
                     [projectdocument] = @ProjectDocument,    
                     [transporttype] = @TransportType,    
                     [vehicle_no] = @Vehicle_No,    
                     [driver_name] = @Driver_Name,    
                     [contact_of_driver] = @Contact_of_Driver,    
                     [challantype] = @ChallanType,    
                     [coating_shade] = @Coating_Shade,    
                     --,[Coating_Rate] = @Coating_Rate                                            
                     --,[Aluminium_Rate] = @Aluminium_Rate                                             
                     [grossamount] = @GrossAmount,    
                     [cgst_mv] = @CGST_MV,    
                     [sgst_mv] = @SGST_MV,    
                     [igst_mv] = @IGST_MV,    
                     [cgst_mvtotal] = @CGST_MVTotal,    
                     [sgst_mvtotal] = @SGST_MVTotal,    
                     [igst_mvtotal] = @IGST_MVTotal,    
                     [cgst] = @CGST,    
                     [sgst] = @SGST,    
                     [igst] = @IGST,    
                     [cgsttotal] = @CGSTTotal,    
                     [sgsttotal] = @SGSTTotal,    
                     [igsttotal] = @IGSTTotal,    
                     [netamount] = @NetAmount,    
                     [remark] = @Remark,    
                     [upd_user] = @Upd_User,    
                     [upd_date] = dbo.Get_sysdate()    
              WHERE  DC_Id = @DC_Id    
    
              /********************************/    
              IF @@ERROR = 0    
                BEGIN    
                    SET @RetVal = @DC_Id    
                    -- 1 IS FOR SUCCESSFULLY EXECUTED                       
                    SET @RetMsg = 'Coating DC Update Successfully And Update Coating DC No is : ' + @DC_No + '.'    
    
                    /******************************* Splited DC Qty Plus In Stock*******************************/    
                    BEGIN    
                        DECLARE db_curspl CURSOR FOR    
    
                          SELECT srno,    
                                 id,    
                                 dcdtl_id,    
                                 DC_Id,    
                                 dept_id,    
                                 Item_Id,    
                                 calc_area,    
                                 running_feet,    
                                 rate_feet,    
                                 coating_value,    
         qty,    
                                 dc_qty,    
                                 itemlength,    
                                 total_weight,    
                                 material_value,    
                                 remark,    
                                 Scrap_Qty,    
                                 scrap_length,    
                                 Godown_Id,    
                                 [weight] /* ,   IsRevision ,DCStatus  */    
                          FROM   @DtlPara /*where  DCStatus = 'S' */;    
    
                        OPEN db_curspl    
    
                        FETCH next FROM db_curspl INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, @_Coating_Value,    
                        @_Qty, @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value , @_Remark , @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight    
                        /*,@_IsRevision ,@_DCStatus  */    
    
                        WHILE @@FETCH_STATUS = 0    
                          BEGIN    
                              IF ( @_DCDtl_Id = 0 )  /*Draft Time New Item Add Save */  
                                BEGIN    
                                    BEGIN    
                                        DECLARE @__Rack_Id   AS INT =0,    
                                                @__Godown_Id AS INT = 0,    
                                                @__SType     AS CHAR = '',    
                                                @__DC_Width  AS NUMERIC(18, 3)=0    
    
                                        SELECT @__DC_Width = Isnull(dc_width, 0)    
                                        FROM   DC_Dtl WITH(nolock)    
                                        WHERE  DC_Dtl.dcdtl_id = @_DCDtl_Id    
    
                                        SELECT @__Rack_Id = Isnull(rack_id, 0),    
                                               @__Godown_Id = Isnull(Godown_Id, 0),    
                                               @__SType = SType    
                                        FROM   StockView WITH(nolock)    
                                        WHERE  id = @_Id    
    
                                        IF EXISTS (SELECT 1    
                                                   FROM   StockView WITH (nolock )    
                                                   WHERE  StockView.Godown_Id = @__Godown_Id    
                                                          AND StockView.Item_Id = @_Item_Id    
                                                          AND StockView.SType = @__SType    
                                                          AND StockView.length = @_ItemLength    
                                                          AND rack_id = @__Rack_Id    
                                                          AND StockView.Width = @__DC_Width)    
                                          BEGIN    
                                              UPDATE StockView WITH (rowlock)    
                                              SET    Total_Qty = Isnull( Total_Qty, 0 ) + @_DC_Qty ,    
               Pending_Qty = Isnull(Pending_Qty, 0) + @_DC_Qty ,    
               LastUpdate = dbo.Get_sysdate()    
                                         WHERE  StockView.Godown_Id = @__Godown_Id    
                                                     AND StockView.Item_Id = @_Item_Id    
                                                     AND StockView.SType = @__SType    
                                                     AND StockView.length = @_ItemLength    
                                                     AND rack_id = @__Rack_Id    
                                                     AND StockView.Width = @__DC_Width    
                                          END    
                                        ELSE    
                                          BEGIN    
                                              INSERT INTO [dbo].[StockView] WITH ( rowlock)    
                                                          ([Godown_Id],    
                                                           [Item_Id],    
                                                           [SType],    
                                                           [Total_Qty],    
                                                           [sales_qty],    
                                                           [Pending_Qty],    
                                                           [transfer_qty],    
                                                           [adjust_qty],    
                                                           [length],    
                                                           [Scrap_Qty],    
                                                           scrap_settle,    
                                                           LastUpdate,    
                                                           ref_id,    
                                                           Width)    
                                              VALUES      (@__Godown_Id,    
                                                           @_Item_Id,    
                                                           @__SType,    
                                                           @_DC_Qty ,   /*[Total_Qty]*/    
                                                           0/*[sales_qty]*/,    
                                                           @_DC_Qty /*[Pending_Qty]*/ ,    
                 0/*[transfer_qty]*/,    
                 0/*adjust_qty*/,    
                 @_ItemLength,    
                 0,    
                 0,    
                 dbo.Get_sysdate(),    
                 0,    
                 @__DC_Width)    
           END    
            
          END    
         END    
    
                        FETCH next FROM db_curspl INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, @_Coating_Value,    
                        @_Qty, @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value , @_Remark , @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight    
                        /*,@_IsRevision ,@_DCStatus  */   
    END    
    
       CLOSE db_curspl    
    
       DEALLOCATE db_curspl    
     END    
    
  /*****3333*********************************************************/  
  /* ???? ??? ??????? ????? ??? ??? ???? ??? ??? ?? ???? ????? ??? ??? ?? ???? ????? ????? ??? ??. */  
  DELETE FROM DC_Dtl WITH(rowlock)    
  WHERE  DC_Dtl.dcdtl_id NOT IN (SELECT dcdtl_id  FROM   @DtlPara)    
  AND DC_Dtl.DC_Id = @DC_Id    
    
  /*****************************************************/    
      
  /**  **/  
   BEGIN  
    DECLARE db_cursor CURSOR FOR  
      SELECT srno,  
       id,  
       dcdtl_id,  
       dc_id,  
       dept_id,  
       item_id,  
       calc_area,  
       running_feet,  
       rate_feet,  
       coating_value,  
       qty,  
       dc_qty,  
       itemlength,  
       total_weight,  
       material_value,  
       remark,  
       scrap_qty,  
       scrap_length,  
       godown_id,  
       [weight] /*  ,  IsRevision ,DCStatus  */  
      FROM   @DtlPara /*where  DCStatus != 'S'*/;  
  
    OPEN db_cursor  
  
    FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID,  
    @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, @_Coating_Value, @_Qty,  
    @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value, @_Remark,  
    @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight  
  
    /*  ,@_IsRevision ,@_DCStatus  */  
    WHILE @@FETCH_STATUS = 0  
      BEGIN  
       IF ( @_DCDtl_Id =  0 )  
      BEGIN  
       INSERT INTO [dbo].[dc_dtl] WITH (rowlock)  
          ([dc_id],  
           [dept_id],  
           [item_group_id],  
           [item_cate_id],  
           [item_id],  
           [qty],  
           [unit_id],  
           [itemlength],  
           [rate],  
           [running_feet],  
           [rate_feet],  
           [coating_value],  
           [total_weight],  
           [material_value],  
           [totalvalue],  
           [remark],  
           dc_qty,  
           scrap_qty,  
           scrap_length,  
           godown_id,  
           stock_id,  
           calc_area,  
           weight_mtr,  
           pending_qty)  
       VALUES      (@RetVal,  
           @_Dept_ID,  
           0,  
           0,  
           @_Item_Id,  
           @_Qty,  
           0 /*unit_id*/,  
           @_ItemLength,  
           0 /*rate*/,  
           @_Running_Feet,  
           @_Rate_Feet,  
           @_Coating_Value,  
           @_Total_Weight,  
           @_Material_Value,  
           0 /*totalvalue*/,  
           @_Remark,  
           @_DC_Qty,  
           @_Scrap_Qty,  
           @_Scrap_Length,  
           @_Godown_Id1,  
           @_Id,  
           @_Calc_Area,  
           @_Weight,  
           @_DC_Qty)  
  
       DECLARE @_DEID AS INT = Scope_identity()  
  
       IF ( @CODC_Type = 'F' AND @_DCStatus = '' )  
         /* Only Finally Save Then Stock Effect*/  
         BEGIN  
          UPDATE stockview WITH (rowlock)  
          SET    sales_qty = Isnull(sales_qty, 0) + @_Qty,  
           pending_qty = Isnull(pending_qty, 0) - @_Qty,  
           lastupdate = dbo.Get_sysdate()  
          WHERE  id = @_Id  
  
          DECLARE @_EdtGodown_Id AS INT =0,  
            @_Rack_Id      AS INT =0,  
            @_EdtSType     AS VARCHAR(5) = '',  
            @_EdtScarpval  AS NUMERIC(18, 2) = 0,  
            @_EdtWidth     AS NUMERIC(18, 3) = 0  
  
          SELECT @_EdtGodown_Id = Isnull(godown_id, 0),  
           @_EdtSType = stype,  
           @_EdtWidth = width,  
           @_Rack_Id = rack_id  
          FROM   stockview WITH (nolock)  
          WHERE  id = @_Id  
  
          UPDATE dc_dtl  
          SET    dc_width = @_EdtWidth,  
           scrap_width = @_EdtWidth  
          WHERE  dc_id = @_DEID  
  
          SELECT @_EdtScarpval = Isnull(master_numvals, 0)  
          FROM   m_master WITH (nolock)  
          WHERE  m_master.master_type = 'SCRAP'  
           AND m_master.is_active = 1  
  
          IF EXISTS (SELECT 1  
            FROM   stockview WITH (nolock)  
            WHERE  stockview.godown_id = @_EdtGodown_Id  
             AND stockview.item_id = @_Item_Id  
             AND stockview.stype = @_EdtSType  
             AND rack_id = @_Rack_Id  
             AND stockview.length = @_Scrap_Length  
             AND stockview.width = @_EdtWidth)  
         BEGIN  
          IF ( @_EdtScarpval > 0  
            AND @_EdtScarpval > @_Scrap_Length )  
            BEGIN  
             -- Scrap_Settle                                                
             UPDATE stockview WITH (rowlock)  
             SET    scrap_settle = Isnull( scrap_settle, 0)  
                 +  
                 @_Scrap_Qty,  
              scrap_qty = Isnull( scrap_qty, 0) +  
                 @_Scrap_Qty,  
              lastupdate = dbo.Get_sysdate()  
             WHERE  stockview.godown_id = @_EdtGodown_Id  
              AND stockview.item_id = @_Item_Id  
              AND stockview.stype = @_EdtSType  
              AND rack_id = @_Rack_Id  
              AND stockview.length = @_Scrap_Length  
              AND stockview.width = @_EdtWidth  
            END  
          ELSE  
            BEGIN  
             UPDATE stockview WITH (rowlock)  
             SET    pending_qty = Isnull( pending_qty, 0) +  
                   @_Scrap_Qty  
              ,  
              scrap_qty = Isnull(  
              scrap_qty, 0) + @_Scrap_Qty,  
              lastupdate = dbo.Get_sysdate()  
             WHERE  stockview.godown_id = @_EdtGodown_Id  
              AND stockview.item_id = @_Item_Id  
              AND stockview.stype = @_EdtSType  
              AND rack_id = @_Rack_Id  
              AND stockview.length = @_Scrap_Length  
              AND stockview.width = @_EdtWidth  
            END  
         END  
          ELSE  
         BEGIN  
          IF ( @_EdtScarpval > 0 AND @_EdtScarpval > @_Scrap_Length )  
            BEGIN  
             -- Scrap_Settle                                    
             INSERT INTO [dbo].[stockview] WITH ( rowlock)  
                ([godown_id],  
                 [item_id],  
                 [stype],  
                 [total_qty],  
                 [sales_qty],  
                 [pending_qty],  
                 [transfer_qty],  
                 [adjust_qty],  
                 [length],  
                 [scrap_qty],  
                 scrap_settle,  
                 lastupdate,  
                 ref_id,  
                 width,  
                 rack_id)  
             VALUES      (@_EdtGodown_Id,  
                 @_Item_Id,  
                 @_EdtSType,  
                 0/*[Total_Qty]*/,  
                 0/*[sales_qty]*/,  
                 0/*[Pending_Qty]*/,  
                 0/*[transfer_qty]*/,  
                 0/*adjust_qty*/,  
                 @_Scrap_Length,  
                 @_Scrap_Qty,  
                 @_Scrap_Qty,  
                 dbo.Get_sysdate(),  
                 @_Id,  
                 @_EdtWidth,  
                 @_Rack_Id)  
            END  
          ELSE  
            BEGIN  
             INSERT INTO [dbo].[stockview] WITH ( rowlock)  
                ([godown_id],  
                 [item_id],  
                 [stype],  
                 [total_qty],  
                 [sales_qty],  
                 [pending_qty],  
                 [transfer_qty],  
                 [adjust_qty],  
                 [length],  
                 [scrap_qty],  
                 scrap_settle,  
                 lastupdate,  
                 ref_id,  
                 width,  
                 rack_id)  
             VALUES      (@_EdtGodown_Id,  
                 @_Item_Id,  
                 @_EdtSType,  
                 0/*[Total_Qty]*/,  
                 0/*[sales_qty]*/,  
                 @_Scrap_Qty,  
                 0/*[transfer_qty]*/,  
                 0/*adjust_qty*/,  
                 @_Scrap_Length,  
                 @_Scrap_Qty,  
                 0,  
                 dbo.Get_sysdate(),  
                 @_Id,  
                 @_EdtWidth,  
                 @_Rack_Id)  
            END  
         END  
         END  
      END  
  
       /*else                                             
       begin                                            
       -- Update PO Detail                                            
       end*/  
       FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id,  
       @_Dept_ID,  
       @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, @_Coating_Value,  
       @_Qty,  
       @_DC_Qty, @_ItemLength, @_Total_Weight, @_Material_Value, @_Remark,  
       @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight  
      /* ,@_IsRevision ,@_DCStatus                                   */  
      END  
  
    CLOSE db_cursor  
  
    DEALLOCATE db_cursor  
   END   
         
    END    
  /*************GGGG****************************************/   
              ELSE    
       BEGIN    
       SET @RetVal = 0    -- 0 WHEN AN ERROR HAS OCCURED                                         
       SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
     END     
      
              COMMIT    
    /************************************* COMMIT *************************************/    
          END try      
          BEGIN catch    
    ROLLBACK      
    /************************************* ROLLBACK *************************************/    
   SET @RetVal = -405  -- 0 IS FOR ERROR                                                                            
   SET @RetMsg ='Error Occurred - ' + Error_message() + '.'    
    END catch    
    /*********** Edit Entry End ***********/    
    END 
GO


