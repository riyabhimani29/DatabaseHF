USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coatdc_mst_Job_insert]    Script Date: 27-04-2026 11:08:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


             
ALTER PROCEDURE [dbo].[Coatdc_mst_Job_insert] @DC_Type           VARCHAR(500),                        
                                          @CODC_Type         VARCHAR(500),                        
                                          @DC_Id             INT,                        
                                          @Project_Id        INT,                        
                                          @Godown_Id        INT,                        
                                          @DC_No             VARCHAR(500),                        
                                          @DC_Date           DATE,                        
                                          @SiteEnginner_Id   INT,                        
                                          @Supplier_Id       INT,                        
                                          @Coating_Shade     VARCHAR(500),                        
                                          @Coating_Rate      NUMERIC(18, 3),                        
                                          @Aluminium_Rate    NUMERIC(18, 3),                        
                                          @QuotationNo       VARCHAR(500),                        
                                          @ProjectDocument   VARCHAR(500),                        
                                          @TransportType     VARCHAR(50),                        
                                          @JobWorkType     VARCHAR(50),                        
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
                                          @Packing_Charge         NUMERIC(18, 3),   
                                          @DtlPara           Tbl_JOBDCDetail readonly,                        
                                          @RetVal            INT = 0 out,                        
                                          @RetMsg VARCHAR(max) = ''out ,                                  
                                      @_ImageName          VARCHAR(max) = '' out                             
AS                        
    SET nocount ON                        
                  
 DECLARE @_Id             AS INT= 0,                  
        @_SrNo           AS INT= 0,                  
        @_DCDtl_Id       AS INT= 0,                  
        @_Dept_ID        AS INT= 0,                  
        @_DO_Id          AS INT= 0,                  
        @_Item_Id        AS INT= 0,              
        @_StockLength      AS NUMERIC(18, 3) = 0,                  
        @_StockWidth   AS NUMERIC(18, 3) = 0,             
        @_TotalAmt      AS NUMERIC(18, 3) = 0,           
        @_Scrap_Qty            AS NUMERIC(18, 3) = 0,               
        @_Scrap_Length     AS NUMERIC(18, 3) = 0,                  
        @_Qty   AS NUMERIC(18, 3) = 0,                  
        @_DC_Qty AS NUMERIC(18, 3) = 0,                  
        @_Unit_Id           AS INT= 0,              
        @_Remark         AS VARCHAR(500)= '',                  
        @_ItemLength         AS NUMERIC(18, 3) = 0,                  
        @_DCWidth      AS NUMERIC(18, 3) = 0,                  
        @_Weight   AS NUMERIC(18, 3) = 0  ,               
        @_Stock_Type         AS VARCHAR(500)= '',                       
        @_Scrap_Width   AS NUMERIC(18, 3) = 0     ,                    
        @_UnitRate      AS NUMERIC(18, 3) = 0 ,          
        @_Tray_Dimension         AS VARCHAR(500)= ''              
             
                      DECLARE @_Godown_Id AS INT =0,                  
                              @_SType     AS VARCHAR(5) = '',                  
                              @_Scarpval  AS NUMERIC(18, 2) = 0  ,                  
                              @_Width  AS NUMERIC(18, 3) = 0 ,    
                              @_Rack_Id AS INT =0,      
                               @_Length AS NUMERIC(18,3) =0
        DECLARE @_History_Id INT = NULL;    
                  
          
IF ( @DC_Id = 0 )                  
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
                           
   SELECT @_Invoice_No = Isnull(Max(dc_mst.invoice_no), 0) + 1                  
          FROM   dc_mst WITH(nolock)                  
          WHERE  dc_mst.dc_type = @DC_Type --'JB-DC'                  
                 AND dc_mst.year_id = @Year_Id                  
                  
          -- Eg. HF/ALU/1002/2122          
          --SET @OrderNo = 'HF/'+ @_DeptShortNm +'/'+ CONVERT(varchar(20),format(@_Invoice_No,'0000')) + '/' +CONVERT(varchar(20), YEAR(dbo.Get_Sysdate()))                      
                      
  SET @DC_No = 'HF/JBDC/'                  
                       + CONVERT(VARCHAR(20), Format(@_Invoice_No, '0000'))                  
                       + '/'                  
                       + CONVERT(VARCHAR(20), Year(dbo.Get_sysdate()))                  
                  
          INSERT INTO [dbo].[dc_mst] WITH (ROWLOCK)                  
                      (codc_type, [dc_type], [invoice_no], [dc_no], [dc_date], [project_id], [supplier_id], [siteenginner_id], [frgodown_id],                  
                       [godown_id], [quotationno], [projectdocument], [transporttype], [vehicle_no], [driver_name], [contact_of_driver],                  
                       [challantype], [coating_shade], [coating_rate], [aluminium_rate], [grossamount], [cgst], [sgst], [igst], [cgsttotal],                  
                       [sgsttotal], [igsttotal], [netamount], [remark], [mac_add], [entry_user], [entry_date], [year_id], [branch_id],                  
                       [cgst_mv], [sgst_mv], [igst_mv], [cgst_mvtotal], [sgst_mvtotal], [igst_mvtotal], issue_byid, packing_charge,JobWorkType)                  
          VALUES      (@CODC_Type, @DC_Type, @_Invoice_No, @DC_No, @DC_Date, @Project_Id, @Supplier_Id, @SiteEnginner_Id, 0 /*frgodown_id*/,                  
                       @Godown_Id, @QuotationNo, @ProjectDocument, @TransportType, @Vehicle_No, @Driver_Name, @Contact_of_Driver,                  
                   @ChallanType, @Coating_Shade, @Coating_Rate, @Aluminium_Rate, @GrossAmount, @CGST, @SGST, @IGST, @CGSTTotal,                  
                       @SGSTTotal, @IGSTTotal, @NetAmount, @Remark, @MAC_Add, @Entry_User, dbo.Get_sysdate(), @Year_Id, @Branch_ID,                  
                       @CGST_MV, @SGST_MV, @IGST_MV, @CGST_MVTotal, @SGST_MVTotal, @IGST_MVTotal, @Issue_ById, @Packing_Charge,@JobWorkType)                  
                  
          SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + @DC_No + '  !!!'                  
          SET @RetVal = Scope_identity()                  
                  
          SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0),                  
                            Replace( Replace(Replace(Replace( Sysutcdatetime(), '-', ''), ' ', ''), ':', ''), '.', '')) + @RetVal) + '.png'                  
                  
          UPDATE dc_mst WITH (ROWLOCK)                  
          SET    doc_img_name = @_ImageName                  
          WHERE  dc_id = @RetVal                  
                  
          IF @@ERROR <> 0                  
            BEGIN                  
                SET @RetVal = 0 -- 0 IS FOR ERROR                                                                 
                SET @RetMsg ='Error Occurred - ' + Error_message() + ' !!!'                  
            END                  
          ELSE                  
            BEGIN                  
                DECLARE db_cursor CURSOR FOR                  
                  SELECT SrNo, Id, DCDtl_Id, DC_Id, Dept_ID, Item_Id,StockLength  , StockWidth  ,   Scrap_Qty  ,          
						  Scrap_Length , Qty , DC_Qty , Unit_Id , ItemLength , DCWidth , Weight , TotalAmt ,  Remark ,           
						  Stock_Type  , Scrap_Width , UnitRate  , Tray_Dimension             
                  FROM   @DtlPara;                  
                 
                OPEN db_cursor                  
                  
                FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_StockLength, @_StockWidth,          
              @_Scrap_Qty, @_Scrap_Length, @_Qty, @_DC_Qty, @_Unit_Id,@_ItemLength , @_DCWidth, @_Weight , @_TotalAmt,  @_Remark,         
				@_Stock_Type,@_Scrap_Width, @_UnitRate ,  @_Tray_Dimension              
                  
                WHILE @@FETCH_STATUS = 0                  
                  BEGIN                  
                   
			INSERT INTO [dbo].[DC_Dtl]   WITH (rowlock)       
				 ([DC_Id],[Dept_ID],[Item_Group_Id],[Item_Cate_Id],[Item_Id],[Qty],[Unit_Id],[DC_Qty],[ItemLength],[Rate],[Running_Feet]          
				 ,[Rate_Feet],[Coating_Value],[Total_Weight],[Material_Value],[TotalValue],[Remark],[Scrap_Qty],[Scrap_Length],[DC_Width],          
			   [Scrap_Width],[Tray_Dimension],[Img_Name],Weight_Mtr)          
			  VALUES (@RetVal ,@_Dept_ID ,0 ,0 ,@_Item_Id ,@_Qty ,@_Unit_Id ,@_DC_Qty ,@_ItemLength ,@_UnitRate ,0 ,0          
				 ,0  /*Coating_Value*/ ,0 ,0 ,           
				 @_TotalAmt ,@_Remark ,@_Scrap_Qty ,@_Scrap_Length ,@_DCWidth ,@_Scrap_Width          
				 ,@_Tray_Dimension ,'', @_Weight )          
          
					DECLARE	@_vId as Int  =  Scope_identity()

                    SELECT @_Godown_Id = Isnull(godown_id, 0),                  
                             @_SType = stype ,              
							   @_Width = ISNULL(Width,0) ,              
							   @_Rack_Id = ISNULL(Rack_Id,0),
                               @_Length = [Length]
                      FROM   stockview WITH (nolock)                  
                      WHERE  id = @_Id 

                      SELECT @_Scarpval = Isnull(master_numvals, 0)                  
                      FROM   m_master WITH (nolock)                  
                      WHERE  m_master.master_type = 'SCRAP'                  
                             AND m_master.is_active = 1    

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
                                    DC_Dtl_Id
				
                                )
                                VALUES
                                (
                                    @_Godown_Id,
                                    @_Item_Id,
                                    @_SType,
                                    @_Qty,
                                    @_Length,       
                                    @_Width,
                                    @_Rack_Id,
                                    dbo.Get_sysdate(),
                                    'SB-DC(Save)',
                                    'SB-DC',
                                    'DC_Dtl',
                                    'OUT',
                                    1,
                                    @_Id,               
                                    @_vId
                                );

                      UPDATE stockview WITH (rowlock)                  
                      SET    sales_qty = Isnull(sales_qty, 0) + @_Qty,                  
                             pending_qty = Isnull(pending_qty, 0) - @_Qty  ,                
							   LastUpdate = dbo.Get_Sysdate() ,    
							   StockEntryPage = 'CO-DC',  
							StockEntryQty =  @_Qty ,
							Dtl_Id = @_vId,
							Tbl_Name = 'DC_Dtl'
                      WHERE  id = @_Id                  
                  
                      SELECT @_Godown_Id = Isnull(godown_id, 0),                  
                             @_SType = stype ,              
							   @_Width = ISNULL(Width,0) ,              
							   @_Rack_Id = ISNULL(Rack_Id,0)              
                      FROM   stockview WITH (nolock)                  
                      WHERE  id = @_Id                  
                  
                      SELECT @_Scarpval = Isnull(master_numvals, 0)                  
                      FROM   m_master WITH (nolock)                  
                      WHERE  m_master.master_type = 'SCRAP'                  
                             AND m_master.is_active = 1                  
                  
                      IF EXISTS (SELECT 1                  
                                 FROM   stockview WITH (nolock)                  
                                 WHERE  stockview.godown_id = @_Godown_Id                  
                                        AND stockview.item_id = @_Item_Id                  
                                        AND stockview.stype = @_SType                  
                                        AND stockview.length = @_Scrap_Length           
									  AND stockview.Width = @_Width    
									  AND StockView.Rack_Id = @_Rack_Id)                  
                        BEGIN                  
                            IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Qty )                  
                              BEGIN                  
                                  -- Scrap_Settle                      
                                  UPDATE stockview WITH (rowlock)                  
                                  SET    scrap_settle = Isnull( scrap_settle, 0) + @_Scrap_Qty,                  
                                         scrap_qty = Isnull( scrap_qty, 0) + @_Scrap_Qty    ,                
											LastUpdate = dbo.Get_Sysdate()    
                                  WHERE  stockview.godown_id = @_Godown_Id                  
                                         AND stockview.item_id = @_Item_Id                  
                                         AND stockview.stype = @_SType                  
                                         AND stockview.length = @_Scrap_Length    
									   AND stockview.Width = @_Width     
									  AND StockView.Rack_Id = @_Rack_Id                 
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
                                        DC_Dtl_Id
				
                                    )
                                    VALUES
                                    (
                                        @_Godown_Id,
                                        @_Item_Id,
                                        @_SType,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_Width,
                                        @_Rack_Id,
                                        dbo.Get_sysdate(),
                                        'SB-DC(Save)',
                                        'SB-DC-Scarp',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_vId
                                    );

                                  UPDATE stockview WITH (rowlock)                  
                                  SET    pending_qty = Isnull( pending_qty, 0) - @_Scrap_Qty ,                  
                                         scrap_qty = Isnull( scrap_qty, 0) + @_Scrap_Qty  ,                
										LastUpdate = dbo.Get_Sysdate()                  
                                  WHERE  stockview.godown_id = @_Godown_Id                  
                                         AND stockview.item_id = @_Item_Id                  
                                         AND stockview.stype = @_SType                  
                                         AND stockview.length = @_Scrap_Length     
									     AND StockView.Rack_Id = @_Rack_Id               
									     AND stockview.Width = @_Width                
                              END                  
              END                  
                      ELSE           
                        BEGIN                  
                            IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Qty )                  
                              BEGIN                  
                                  -- Scrap_Settle                      
                                  INSERT INTO [dbo].[stockview] WITH (rowlock)                  
									([godown_id], [item_id], [stype], [total_qty], [sales_qty], [pending_qty], [transfer_qty],                  
                                               [adjust_qty], [length], [scrap_qty], scrap_settle,LastUpdate,Ref_Id,Width,Dtl_Id,Tbl_Name)                  
                                  VALUES      (@_Godown_Id, @_Item_Id, @_SType, 0/*[total_qty]*/, 0/*[sales_qty]*/, 0/*[pending_qty]*/,                   
												0/*[transfer_qty]*/, 0/*adjust_qty*/, @_Scrap_Length, @_Scrap_Qty, @_Scrap_Qty,           
												dbo.Get_Sysdate(),@_Id,@_Width,0,'')                  
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
                                        DC_Dtl_Id
				
                                    )
                                    VALUES
                                    (
                                        @_Godown_Id,
                                        @_Item_Id,
                                        @_SType,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_Width,
                                        @_Rack_Id,
                                        dbo.Get_sysdate(),
                                        'SB-DC(Save)',
                                        'SB-DC-Scarp',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_vId
                                    );
                                     SET @_History_Id = NULL;
                                    SET @_History_Id = SCOPE_IDENTITY();

                                  INSERT INTO [dbo].[stockview] WITH (rowlock)                  
                                              ([godown_id], [item_id], [stype], [total_qty], [sales_qty], [pending_qty], [transfer_qty],                  
                                               [adjust_qty], [length], [scrap_qty], scrap_settle,LastUpdate,Ref_Id,Width,Dtl_Id,Tbl_Name)                  
                                  VALUES      (@_Godown_Id, @_Item_Id, @_SType, 0, 0, @_Scrap_Qty, 0, 0, @_Scrap_Length, @_Scrap_Qty,           
												0, dbo.Get_Sysdate(),@_Id,@_Width,0,'')                  
                              
                              UPDATE Stock_Transfer_History SET Stock_Id= SCOPE_IDENTITY() WHERE Id = @_History_Id;
                              END
                        END                  
                  
                FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_StockLength, @_StockWidth,          
              @_Scrap_Qty, @_Scrap_Length, @_Qty, @_DC_Qty, @_Unit_Id,@_ItemLength , @_DCWidth, @_Weight , @_TotalAmt,  @_Remark,         
     @_Stock_Type,@_Scrap_Width, @_UnitRate ,  @_Tray_Dimension                    
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
          SET @RetMsg ='Error Occurred ' + Error_message() + '.'                  
      END catch                  
  END                  
ELSE                  
  BEGIN                  
      BEGIN try                  
          BEGIN TRANSACTION                  
  
          /************************************* TRANSACTION *************************************/                  
          IF NOT EXISTS(SELECT 1                  
                        FROM   [dc_mst] WITH (nolock)                  
                        WHERE  dc_id = @DC_Id)                  
            BEGIN                  
                SET @RetVal = -2                  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                     
                SET @RetMsg = @DC_No  + ' This Coating DC is Not Exist .'                     
                RETURN                  
            END                  
                  
          UPDATE [dbo].[dc_mst]  WITH (ROWLOCK)                  
          SET    [codc_type] = @CODC_Type,                  
                 [supplier_id] = @Supplier_Id,                  
                 [siteenginner_id] = @SiteEnginner_Id,                  
                 [issue_byid] = @Issue_ById,                  
                 [project_id] = @Project_Id,                  
                 [godown_id] = @Godown_Id,                  
				 [quotationno] = @QuotationNo,                  
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
          WHERE  dc_id = @DC_Id                  
                  
          /********************************/                  
          IF @@ERROR = 0                  
            BEGIN                  
                SET @RetVal = @DC_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                                      
                SET @RetMsg = 'Coating DC Update Successfully And Update Coating DC No is : ' + @DC_No + '  .'                  
                  
                /*****************************************************/                  
                DECLARE db_cursor CURSOR FOR                  
                  SELECT SrNo, Id, DCDtl_Id, DC_Id, Dept_ID, Item_Id,StockLength  , StockWidth  ,   Scrap_Qty  ,          
						Scrap_Length , Qty , DC_Qty , Unit_Id , ItemLength , DCWidth , Weight , TotalAmt ,  Remark ,           
						Stock_Type  , Scrap_Width , UnitRate  , Tray_Dimension         
           
                  FROM   @DtlPara;                 
                  
                OPEN db_cursor                  
                  
                FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_StockLength, @_StockWidth,          
						   @_Scrap_Qty, @_Scrap_Length, @_Qty, @_DC_Qty, @_Unit_Id,@_ItemLength , @_DCWidth, @_Weight , @_TotalAmt,  @_Remark,         
						   @_Stock_Type,@_Scrap_Width, @_UnitRate ,  @_Tray_Dimension             
                  
                WHILE @@FETCH_STATUS = 0                  
                  BEGIN                  
                      IF ( @_DCDtl_Id = 0 )                  
                        BEGIN           
              
    INSERT INTO [dbo].[DC_Dtl]  WITH (rowlock)        
         ([DC_Id],[Dept_ID],[Item_Group_Id],[Item_Cate_Id],[Item_Id],[Qty],[Unit_Id],[DC_Qty],[ItemLength],[Rate],[Running_Feet]          
         ,[Rate_Feet],[Coating_Value],[Total_Weight],[Material_Value],[TotalValue],[Remark],[Scrap_Qty],[Scrap_Length],[DC_Width],          
       [Scrap_Width],[Tray_Dimension],[Img_Name], Weight_Mtr)          
      VALUES (@RetVal ,@_Dept_ID ,0 ,0 ,@_Item_Id ,@_Qty ,@_Unit_Id ,@_DC_Qty ,@_ItemLength ,@_UnitRate ,0 ,0          
         ,0  /*Coating_Value*/ ,0 ,0 ,           
         @_TotalAmt ,@_Remark ,@_Scrap_Qty ,@_Scrap_Length ,@_DCWidth ,@_Scrap_Width          
         ,@_Tray_Dimension ,'',@_Weight )                  
                  
       declare @_V1 as Int = Scope_identity()     
                   
                   
                      SELECT @_Godown_Id = Isnull(godown_id, 0),                  
                             @_SType = stype ,              
							   @_Width = ISNULL(Width,0)  ,    
							   @_Rack_Id = ISNULL(Rack_Id ,0 )    
                      FROM   stockview WITH (nolock)                  
                      WHERE  id = @_Id                  
                  
                      SELECT @_Scarpval = Isnull(master_numvals, 0)                  
                      FROM   m_master WITH (nolock)                  
                      WHERE  m_master.master_type = 'SCRAP'                  
                             AND m_master.is_active = 1   
                             

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
                                    DC_Dtl_Id
				
                                )
                                VALUES
                                (
                                    @_Godown_Id,
                                    @_Item_Id,
                                    @_SType,
                                    @_Qty,
                                    @_Length,       
                                    @_Width,
                                    @_Rack_Id,
                                    dbo.Get_sysdate(),
                                    'SB-DC(Edit)',
                                    'SB-DC',
                                    'DC_Dtl',
                                    'OUT',
                                    1,
                                    @_Id,               
                                    @_V1
                                );
                                UPDATE stockview WITH (rowlock)                  
                      SET    sales_qty = Isnull(sales_qty, 0) + @_Qty,                  
                             pending_qty = Isnull(pending_qty, 0) - @_Qty  ,                
							  LastUpdate = dbo.Get_Sysdate()  ,    
							  StockEntryPage = 'CO-DC' ,  
							StockEntryQty  = @_Qty,
							Dtl_Id = @_V1 ,
							Tbl_Name = 'DC_Dtl'
                      WHERE  id = @_Id    

                  
                      IF EXISTS (SELECT 1                  
                                 FROM   stockview WITH (nolock)                  
                                 WHERE  stockview.godown_id = @_Godown_Id                  
                                        AND stockview.item_id = @_Item_Id                  
                                        AND stockview.stype = @_SType                  
                                        AND stockview.length = @_Scrap_Length    
										  AND StockView.Rack_Id = @_Rack_Id              
										  AND stockview.Width = @_Width)                  
                        BEGIN                  
                            IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Qty )                  
                              BEGIN                  
                                  -- Scrap_Settle                      
                                  UPDATE stockview WITH (rowlock)                  
                                  SET    scrap_settle = Isnull( scrap_settle, 0) + @_Scrap_Qty,                  
                                         scrap_qty = Isnull( scrap_qty, 0) + @_Scrap_Qty  ,    
										LastUpdate = dbo.Get_Sysdate()         
                                  WHERE  stockview.godown_id = @_Godown_Id                  
                                         AND stockview.item_id = @_Item_Id                  
                                         AND stockview.stype = @_SType     
										 AND StockView.Rack_Id = @_Rack_Id                 
                                         AND stockview.length = @_Scrap_Length              
										AND stockview.Width = @_Width                  
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
                                        DC_Dtl_Id
				
                                    )
                                    VALUES
                                    (
                                        @_Godown_Id,
                                        @_Item_Id,
                                        @_SType,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_Width,
                                        @_Rack_Id,
                                        dbo.Get_sysdate(),
                                        'SB-DC(Edit)',
                                        'SB-DC-Scarp',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_vId
                                    );


                                  UPDATE stockview WITH (rowlock)                  
                                  SET    pending_qty = Isnull( pending_qty, 0) - @_Scrap_Qty ,                  
                                         scrap_qty = Isnull( scrap_qty, 0) + @_Scrap_Qty  ,                
										 LastUpdate = dbo.Get_Sysdate()                
                                  WHERE  stockview.godown_id = @_Godown_Id                  
                                         AND stockview.item_id = @_Item_Id                  
                                         AND stockview.stype = @_SType                  
                                         AND stockview.length = @_Scrap_Length       
										  AND StockView.Rack_Id = @_Rack_Id             
										   AND stockview.Width = @_Width                
                              END                  
              END                  
                      ELSE                  
                        BEGIN                  
                            IF ( @_Scarpval > 0 AND @_Scarpval > @_Scrap_Qty )                  
                              BEGIN                  
                                  -- Scrap_Settle                      
                                  INSERT INTO [dbo].[stockview] WITH (rowlock)                  
                                              ([godown_id], [item_id], [stype], [total_qty], [sales_qty], [pending_qty], [transfer_qty],                  
                                               [adjust_qty], [length], [scrap_qty], scrap_settle,LastUpdate,Ref_Id,Width ,Dtl_Id ,Tbl_Name )                  
                                  VALUES      (@_Godown_Id, @_Item_Id, @_SType, 0/*[total_qty]*/, 0/*[sales_qty]*/, 0/*[pending_qty]*/,                   
												0/*[transfer_qty]*/, 0/*adjust_qty*/, @_Scrap_Length, @_Scrap_Qty, @_Scrap_Qty,           
												dbo.Get_Sysdate(),@_Id,@_Width , 0, ''  )                  
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
                                        DC_Dtl_Id
				
                                    )
                                    VALUES
                                    (
                                        @_Godown_Id,
                                        @_Item_Id,
                                        @_SType,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_Width,
                                        @_Rack_Id,
                                        dbo.Get_sysdate(),
                                        'SB-DC(Save)',
                                        'SB-DC-Scarp',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_vId
                                    );
                                     SET @_History_Id = NULL;
                                    SET @_History_Id = SCOPE_IDENTITY();


                                INSERT INTO [dbo].[stockview] WITH (rowlock)                  
                                              ([godown_id], [item_id], [stype], [total_qty], [sales_qty], [pending_qty], [transfer_qty],                  
                                               [adjust_qty], [length], [scrap_qty], scrap_settle,LastUpdate,Ref_Id,Width ,Dtl_Id ,Tbl_Name )                  
                                  VALUES      (@_Godown_Id, @_Item_Id, @_SType, 0, 0, @_Scrap_Qty, 0, 0, @_Scrap_Length, @_Scrap_Qty,           
            0, dbo.Get_Sysdate(),@_Id,@_Width ,0 , '' ) 
            UPDATE Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                              END                  
                        END      
                                             
          END                  
                  
                      /*else                   
                        begin                  
                         -- Update PO Detail                  
                         end*/                  
                  
                FETCH next FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id , @_Dept_ID, @_Item_Id, @_StockLength, @_StockWidth,          
              @_Scrap_Qty, @_Scrap_Length, @_Qty, @_DC_Qty, @_Unit_Id,@_ItemLength , @_DCWidth, @_Weight , @_TotalAmt,  @_Remark,         
     @_Stock_Type,@_Scrap_Width, @_UnitRate ,  @_Tray_Dimension            
                          
                  END                  
                  
                CLOSE db_cursor                  
                  
                DEALLOCATE db_cursor                  
            /*****************************************************/                  
            END                  
          ELSE                  
            BEGIN                  
                SET @RetVal = 0                  
                -- 0 WHEN AN ERROR HAS OCCURED                                  
                SET @RetMsg ='Error Occurred - ' + Error_message() + ' .'                  
            END                  
                  
          COMMIT                  
      /************************************* COMMIT *************************************/                  
      END try                  
                  
      BEGIN catch                  
          ROLLBACK                  
                  
          /************************************* ROLLBACK *************************************/                  
          SET @RetVal = -405 -- 0 IS FOR ERROR                                                  
          SET @RetMsg ='Error Occurred - ' + Error_message() + ' .'                  
      END catch                  
  END
GO


