USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coatdc_mst_insert]    Script Date: 27-04-2026 11:06:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[Coatdc_mst_insert] 
    @Dept_ID           INT,
    @DC_Type           VARCHAR(500),                                
    @CODC_Type         VARCHAR(500),                                
    @DC_Id             INT,                                
    @Project_Id        INT,                                
    @Godown_Id         INT,                                
    @Coating_ShadeId   INT,     
    @Coating_Req_Id    INT,
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
    @Revision          VARCHAR(500),                                
    @Remark            VARCHAR(500),                                
    @MAC_Add           VARCHAR(500),                                
    @Entry_User        INT,     
    @Upd_User          INT,                     
    @Year_Id           INT,                             
    @Branch_ID         INT,                                
    @Packing_Charge    NUMERIC(18, 3),                                
    @DtlPara           TBL_COSTGCDETAILS READONLY,                                
    @RetVal            INT = 0 OUT,                                
    @RetMsg            VARCHAR(MAX) = '' OUT,                                
    @_ImageName        VARCHAR(MAX) = '' OUT                                
AS                                
    SET NOCOUNT ON                                

BEGIN                              
    /************** Variable Declare *****************/                        
    DECLARE @_Id             AS INT = 0,                              
            @_SrNo           AS INT = 0,                              
            @_DCDtl_Id       AS INT = 0,                              
            @_Dept_ID        AS INT = 0,                              
            @_DO_Id          AS INT = 0,                              
            @_Item_Id        AS INT = 0,                              
            @_Calc_Area      AS NUMERIC(18, 3) = 0,                              
            @_Running_Feet   AS NUMERIC(18

, 3) = 0,                              
            @_Rate_Feet      AS NUMERIC(18, 3) = 0,                              
            @_Coating_Value  AS NUMERIC(18, 3) = 0,                              
            @_Qty            AS NUMERIC(18, 3) = 0,                              
            @_ItemLength     AS NUMERIC(18, 3) = 0,                              
            @_Total_Weight   AS NUMERIC(18, 3) = 0,                              
            @_Material_Value AS NUMERIC(18, 3) = 0,                              
            @_Remark         AS VARCHAR(500) = '',                              
            @_DC_Qty         AS NUMERIC(18, 3) = 0,                              
            @_Scrap_Qty      AS NUMERIC(18, 3) = 0,                              
            @_Scrap_Length   AS NUMERIC(18, 3) = 0,                              
            @_Godown_Id1     AS INT = 0,                              
            @_Weight         AS NUMERIC(18, 3) = 0,                              
            @_IsRevision     AS BIT = 0,                              
            @_DCStatus       AS VARCHAR(500) = '',                              
            @_Financial_Year AS INT = 0,                              
            @_MR_Item_Id     AS INT = 0,
            @_Coating_Rate   AS NUMERIC(18,3) = 0

    SET @Year_Id = dbo.Get_financial_yearid(CONVERT(DATE, @DC_Date))                              
    SET @_Financial_Year = dbo.Get_financial_year(CONVERT(DATE, @DC_Date))                              
    Declare @_History_Id INT = NULL;
    /************** Variable Declare *****************/                              
    IF (@DC_Id = 0)                              
    /*********** New Entry Start ***********/                                
    BEGIN             
        /********************************* Minus Stock Check *********************************/        
        --IF (@CODC_Type = 'F') /* Only Finally Save Then Stock Effect*/              
        --BEGIN        
        --    TRUNCATE TABLE StockDCCheck        
        --    SELECT Id, qty INTO StockDCCheck FROM @DtlPara WHERE godown_id <> 0;        
        --    IF EXISTS (SELECT 1 FROM StockView WITH (NOLOCK) LEFT JOIN @DtlPara AS AA ON AA.Id = StockView.Id        
        --               WHERE (ISNULL(StockView.Pending_Qty, 0) - ISNULL(AA.qty, 0)) < 0)        
        --    BEGIN        
        --        SET @RetVal = -101          
        --        SET @RetMsg = 'The stock goes into the Minus !!!'        
        --        SET @_ImageName = ''        
        --        RETURN        
        --    END        
        --END        
        /********************************* Minus Stock Check *********************************/        

        BEGIN TRY              
            BEGIN TRANSACTION              
            /************************************* TRANSACTION START (1) *************************************/              
            DECLARE @_DeptShortNm AS VARCHAR(20) = '',              
                    @_Invoice_No  AS INT = 0 ,
                    @_DID AS INT = 0
                    



            /* IF (@Dept_ID <> 0)                              
            BEGIN                              
                SELECT @_DeptShortNm = ISNULL(m_department.dept_short_name, '-') FROM m_department WITH (NOLOCK) WHERE m_department.dept_id = @Dept_ID                              
            END                              
            ELSE                              
            BEGIN                              
                SET @RetMsg = 'Please Select Department !!!'                              
                SET @RetVal = -1                              
                RETURN                              
            END */              

            SELECT @_Invoice_No = ISNULL(MAX(DC_Mst.invoice_no), 0) + 1              
            FROM DC_Mst WITH (NOLOCK)              
            WHERE DC_Mst.dc_type = @DC_Type AND DC_Mst.Year_Id = @Year_Id AND CODC_Type IN ('F', 'C')          

            SET @DC_No = 'HF/CODC/' + CONVERT(VARCHAR(20), FORMAT(@_Invoice_No, '0000')) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)              

            INSERT INTO [dbo].[DC_Mst] WITH (ROWLOCK)              
                (Dept_ID,CODC_Type, dc_type, invoice_no, DC_No, dc_date, project_id, supplier_id, siteenginner_id, frgodown_id, Godown_Id, 
                 quotationno, projectdocument, transporttype, vehicle_no, driver_name, contact_of_driver, coating_shadeid, challantype, 
                 coating_shade, coating_rate, aluminium_rate, grossamount, cgst, sgst, igst, cgsttotal, sgsttotal, igsttotal, 
                 netamount, remark, mac_add, entry_user, entry_date, Year_Id, branch_id, cgst_mv, sgst_mv, igst_mv, 
                 cgst_mvtotal, sgst_mvtotal, igst_mvtotal, issue_byid, packing_charge,Coating_Req_Id)              
            VALUES (@Dept_ID,@CODC_Type, @DC_Type, @_Invoice_No, @DC_No, @DC_Date, @Project_Id, @Supplier_Id, @SiteEnginner_Id, 
                    0, @Godown_Id, ISNULL(@QuotationNo, ''), @ProjectDocument, @TransportType, @Vehicle_No, @Driver_Name, 
                    @Contact_of_Driver, @Coating_ShadeId, @ChallanType, @Coating_Shade, CONVERT(NUMERIC(18, 2), @Coating_Rate), 
                    @Aluminium_Rate, @GrossAmount, @CGST, @SGST, @IGST, @CGSTTotal, @SGSTTotal, @IGSTTotal, 
                    @NetAmount, @Remark, @MAC_Add, @Entry_User, dbo.Get_sysdate(), @Year_Id, @Branch_ID, 
                    @CGST_MV, @SGST_MV, @IGST_MV, @CGST_MVTotal, @SGST_MVTotal, @IGST_MVTotal, @Issue_ById, @Packing_Charge,@Coating_Req_Id)              

            SET @RetVal = SCOPE_IDENTITY()              

					
            DECLARE @_Req_Id INT = 0;

            SELECT @_Req_Id = Coating_Req_Id
            FROM DC_Mst WITH (NOLOCK)
            WHERE DC_Id = @RetVal;

            IF (@_Req_Id > 0)
            BEGIN
                UPDATE Coating_Request
                SET Is_read =
                    CASE 
                        WHEN @CODC_Type = 'D' THEN 1   -- Draft
                        WHEN @CODC_Type = 'F' THEN 2   -- Final
                        ELSE Is_read
                    END
                WHERE Coating_Req_Id = @_Req_Id;
            END
            IF (@CODC_Type = 'D')              
            BEGIN              
                SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + CONVERT(VARCHAR(20), @RetVal) + '.'              
            END              
            ELSE              
            BEGIN              
                SET @RetMsg = 'Coating DC Generate Successfully And Generated Coating DC No is : ' + @DC_No + '.'              
            END              

            SET @_ImageName = CONVERT(VARCHAR(100), CONVERT(NUMERIC(38, 0), REPLACE(REPLACE(REPLACE(REPLACE(SYSUTCDATETIME(), '-', ''), ' ', ''), ':', ''), '.', '')) + @RetVal) + '.png'              

            UPDATE DC_Mst WITH (ROWLOCK) SET doc_img_name = @_ImageName WHERE DC_Id = @RetVal              

            UPDATE DC_Mst WITH (ROWLOCK) SET DC_No = @RetVal WHERE DC_Id = @RetVal AND CODC_Type = 'D'              

            IF @@ERROR <> 0              
            BEGIN              
                SET @RetVal = 0              
                SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.'              
            END              
            ELSE              
            BEGIN              
                DECLARE db_cursor CURSOR FOR              
                SELECT srno, Id, DCDtl_Id, DC_Id, dept_id, Item_Id, calc_area, running_feet, rate_feet, 
                       coating_value, qty, dc_qty, itemlength, total_weight, material_value, remark, 
                       Scrap_Qty, scrap_length, godown_id, [weight], MR_Item_Id,Coating_Rate              
                FROM @DtlPara              
                WHERE godown_id <> 0;              

                OPEN db_cursor              

                FETCH NEXT FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, 
                                               @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, 
                                               @_Coating_Value, @_Qty, @_DC_Qty, @_ItemLength, 
                                               @_Total_Weight, @_Material_Value, @_Remark, 
                                               @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight, @_MR_Item_Id,@_Coating_Rate              

                WHILE @@FETCH_STATUS = 0              
                BEGIN              
                    INSERT INTO [dbo].[DC_Dtl] WITH (ROWLOCK)              
                        ([DC_Id], dept_id, item_group_id, item_cate_id, Item_Id, qty, unit_id, itemlength, 
                         rate, running_feet, rate_feet, coating_value, total_weight, material_value, 
                         totalvalue, remark, dc_qty, Scrap_Qty, scrap_length, godown_id, stock_id, 
                         calc_area, weight_mtr, Pending_Qty, MR_Item_Id, is_revision,Coating_Rate)              
                    VALUES (@RetVal, @_Dept_ID, 0, 0, @_Item_Id, @_Qty, 0, @_ItemLength, 0, 
                            @_Running_Feet, @_Rate_Feet, @_Coating_Value, @_Total_Weight, 
                            @_Material_Value, 0, @_Remark, @_DC_Qty, @_Scrap_Qty, @_Scrap_Length, 
                            @_Godown_Id1, @_Id, @_Calc_Area, @_Weight, @_DC_Qty, @_MR_Item_Id,
                            (CASE WHEN @Revision = '1' THEN 1 ELSE 0 END),@_Coating_Rate)                        

                    SET @_DID = SCOPE_IDENTITY()              
					
					IF ( @_MR_Item_Id > 0 )
					BEGIN 
						UPDATE MR_Items SET MR_Items.Coating_Value = @_Material_Value WHERE MR_Items.MR_Items_Id = @_MR_Item_Id;
						UPDATE Coating_RequestDtl SET Is_Requested = 1 WHERE Coating_RequestDtl.BOM_Dtl_Id = @_MR_Item_Id;
					END
					
                    IF (@CODC_Type = 'F') /* Only Finally Save Then Stock Effect*/              
                    BEGIN  
                    
                    DECLARE @_Godown_Ids AS INT = 0,              
                                @_STypes     AS VARCHAR(5) = '',              
                                @_Scarpvals  AS NUMERIC(18, 2) = 0,              
                                @_Widths     AS NUMERIC(18, 3) = 0,              
                                @_Rack_Ids   AS INT = 0,
                                @_Lengths    AS numeric(18, 3) = 0

                        SELECT @_Godown_Ids = ISNULL(godown_id, 0),              
                               @_STypes = SType,              
                               @_Widths = ISNULL(Width, 0),              
                               @_Rack_Ids = ISNULL(Rack_Id, 0),
                               @_Lengths = [Length]
                        FROM StockView WITH (NOLOCK) WHERE Id = @_Id 

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
                                @_Godown_Ids,
                                @_Item_Id,
                                @_STypes,
                                @_Qty,
                                @_Lengths,       
                                @_Widths,
                                @_Rack_Ids,
                                dbo.Get_sysdate(),
                                'Co-DC(Save)',
                                'CO-DC',
                                'DC_Dtl',
                                'OUT',
                                1,
                                @_Id,               
                                @_DID
                            );


                        UPDATE StockView WITH (ROWLOCK)              
                        SET Sales_Qty = ISNULL(Sales_Qty, 0) + @_Qty,              
                            Pending_Qty = ISNULL(Pending_Qty, 0) - @_Qty,              
                            LastUpdate = dbo.Get_sysdate(),              
                            StockEntryPage = @DC_Type,              
                            StockEntryQty = @_Qty,  
                            Dtl_Id = @_DID,  
                            Tbl_Name = 'DC_Dtl'  
                        WHERE Id = @_Id AND @Revision = '0'              

                        DECLARE @_Godown_Id AS INT = 0,              
                                @_SType     AS VARCHAR(5) = '',              
                                @_Scarpval  AS NUMERIC(18, 2) = 0,              
                                @_Width     AS NUMERIC(18, 3) = 0,              
                                @_Rack_Id   AS INT = 0              

                        SELECT @_Godown_Id = ISNULL(godown_id, 0),              
                               @_SType = SType,              
                               @_Width = ISNULL(Width, 0),              
                               @_Rack_Id = ISNULL(Rack_Id, 0)              
                        FROM StockView WITH (NOLOCK) WHERE Id = @_Id              

                        UPDATE DC_Dtl WITH (ROWLOCK) SET DC_Width = @_Width, Scrap_Width = @_Width WHERE DC_Id = @_DID              

                        SELECT @_Scarpval = ISNULL(master_numvals, 0)              
                        FROM M_Master WITH (NOLOCK) WHERE M_Master.Master_Type = 'SCRAP' AND M_Master.Is_Active = 1              
                         --Is there already a stock row in StockView for this exact scrap piece?
                        IF EXISTS (SELECT 1 FROM StockView WITH (NOLOCK) 
                                   WHERE StockView.godown_id = @_Godown_Id              
                                   AND StockView.Item_Id = @_Item_Id              
                                   AND StockView.SType = @_SType              
                                   AND StockView.Length = @_Scrap_Length              
                                   AND StockView.Width = @_Width              
                                   AND StockView.Rack_Id = @_Rack_Id)              
                        BEGIN 
                        --Scrap is NOT usable (too small)
                            IF (@_Scarpval > 0 AND @_Scarpval > @_Scrap_Length)              
                            BEGIN   
                                IF (@_Scrap_Length <> 0)
                                begin
                                UPDATE StockView WITH (ROWLOCK)              
                                SET Scrap_Settle = ISNULL(Scrap_Settle, 0) + @_Scrap_Qty,              
                                    Scrap_Qty = ISNULL(Scrap_Qty, 0) + @_Scrap_Qty,              
                                    LastUpdate = dbo.Get_sysdate()              
                                WHERE StockView.godown_id = @_Godown_Id              
                                    AND StockView.Item_Id = @_Item_Id              
                                    AND StockView.SType = @_SType              
                                    AND StockView.Length = @_Scrap_Length              
                                    AND StockView.Width = @_Width              
                                    AND StockView.Rack_Id = @_Rack_Id 
                                    end
                            END              
                            ELSE              
                            BEGIN  
                            
                             --Scrap is USABLE
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
                                        @_Godown_Ids,
                                        @_Item_Id,
                                        @_STypes,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_Widths,
                                        @_Rack_Ids,
                                        dbo.Get_sysdate(),
                                        'Co-DC(Save)',
                                        'CO-DC-Scrap',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_DID
                                    );

                                UPDATE StockView WITH (ROWLOCK)              
                                SET Pending_Qty = ISNULL(Pending_Qty, 0) + @_Scrap_Qty,              
                                    Scrap_Qty = ISNULL(Scrap_Qty, 0) + @_Scrap_Qty,              
                                    LastUpdate = dbo.Get_sysdate()              
                                WHERE StockView.godown_id = @_Godown_Id              
                                    AND StockView.Item_Id = @_Item_Id              
                                    AND StockView.SType = @_SType              
                                    AND StockView.Length = @_Scrap_Length              
                                    AND StockView.Width = @_Width              
                                    AND StockView.Rack_Id = @_Rack_Id              
                            END              
                        END              
                        ELSE              
                        BEGIN   
                        --Insert NON-USABLE scrap
                        --ignore
                            IF (@_Scarpval > 0 AND @_Scarpval > @_Scrap_Length )              
                            BEGIN         
                            IF (@_Scrap_Length <> 0)
                                Begin
                                INSERT INTO [dbo].[StockView] WITH (ROWLOCK)              
                                    ([Godown_Id], Item_Id, SType, total_qty, Sales_Qty, Pending_Qty, 
                                     transfer_qty, adjust_qty, Length, Scrap_Qty, Scrap_Settle, 
                                     LastUpdate, ref_id, Width, Rack_Id, StockEntryPage, Dtl_Id, Tbl_Name)              
                                VALUES (@_Godown_Id, @_Item_Id, @_SType, 0, 0, 0, 0, 0, 
                                        @_Scrap_Length, @_Scrap_Qty, @_Scrap_Qty, dbo.Get_sysdate(), 
                                        @_Id, @_Width, @_Rack_Id, '', 0, '') 
                                        end
                            END              
                            ELSE              
                            BEGIN  
                            
                            --Insert USABLE scrap

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
                                        'Co-DC(Save)',
                                        'CO-DC-Scrap',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        NULL,               
                                        @_DID
                                    );
                                    Set @_History_Id  = NULL;
                                    SET @_History_Id = SCOPE_IDENTITY();

                                INSERT INTO [dbo].[StockView] WITH (ROWLOCK)              
                                    ([Godown_Id], Item_Id, SType, total_qty, Sales_Qty, Pending_Qty, 
                                     transfer_qty, adjust_qty, Length, Scrap_Qty, Scrap_Settle, 
                                     LastUpdate, ref_id, Width, Rack_Id, StockEntryPage, Dtl_Id, Tbl_Name)              
                                VALUES (@_Godown_Id, @_Item_Id, @_SType, 0, 0, @_Scrap_Qty, 0, 0, 
                                        @_Scrap_Length, @_Scrap_Qty, 0, dbo.Get_sysdate(), 
                                        @_Id, @_Width, @_Rack_Id, '', 0, '')   
                                UPDATE Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                            END              
                        END              
                    END              

                    FETCH NEXT FROM db_cursor INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, 
                                                   @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, 
                                                   @_Coating_Value, @_Qty, @_DC_Qty, @_ItemLength, 
                                                   @_Total_Weight, @_Material_Value, @_Remark, 
                                                   @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight, @_MR_Item_Id,@_Coating_Rate              
                END              

                CLOSE db_cursor              
                DEALLOCATE db_cursor              
                COMMIT              
            /************************************* COMMIT *************************************/              
            END              
        /************************************* TRANSACTION END (1) *************************************/              
        END TRY              
        BEGIN CATCH              
            ROLLBACK              
            /************************************* ROLLBACK *************************************/              
            SET @RetVal = -405              
            SET @RetMsg = 'Error Occurred ' + ERROR_MESSAGE() + '.'              
        END CATCH              
    END                   
    /*********** New Entry End ***********/                             
    ELSE                              
    /*********** Edit Entry Start ***********/                                
    BEGIN            
        /********************************* Minus Stock Check *********************************/        
        IF (@CODC_Type = 'F')      
        BEGIN      
            IF EXISTS (SELECT 1 FROM stockview WITH (NOLOCK) LEFT JOIN @DtlPara AS AA ON AA.id = stockview.id      
                       WHERE AA.Is_Delete = 0 AND (ISNULL(stockview.pending_qty, 0) - AA.qty) < 0)      
            BEGIN      
                SET @_ImageName = (SELECT STUFF((SELECT DISTINCT m_item.item_code      
                                                 FROM stockview WITH (NOLOCK)      
                                                 LEFT JOIN @DtlPara AS AA ON AA.id = stockview.id      
                                                 LEFT JOIN m_item ON m_item.item_id = stockview.item_id      
                                                 WHERE (ISNULL(stockview.pending_qty, 0) - AA.qty) < 0      
                                                 FOR XML PATH('')), 1, 1, ''))      
                SET @RetVal = -101      
                SET @RetMsg = 'The stock goes into the Minus , In this item ( ' + @_ImageName + ' ).'      
                RETURN      
            END      
        END      
        /********************************* Minus Stock Check *********************************/        

        BEGIN TRY              
            BEGIN TRANSACTION              
            IF NOT EXISTS (SELECT 1 FROM [DC_Mst] WITH (NOLOCK) WHERE DC_Id = @DC_Id)              
            BEGIN              
                SET @RetVal = -2              
                SET @RetMsg = @DC_No + ' This Coating DC is Not Exist.'              
                RETURN              
            END              

            SELECT @_Invoice_No = ISNULL(MAX(DC_Mst.invoice_no), 0) + 1              
            FROM DC_Mst WITH (NOLOCK)              
            WHERE DC_Mst.dc_type = @DC_Type AND DC_Mst.Year_Id = @Year_Id AND CODC_Type IN ('F', 'C')              

            DECLARE @DC_No1 AS VARCHAR(150) = ''              
            SELECT @DC_No1 = DC_No FROM DC_Mst WITH (NOLOCK) WHERE DC_Id = @DC_Id     
                         SET @_Req_Id = 0;

             SELECT @_Req_Id = Coating_Req_Id
             FROM DC_Mst WITH (NOLOCK)
             WHERE DC_Id = @DC_Id;

             IF (@_Req_Id > 0)
             BEGIN
                 UPDATE Coating_Request
                 SET Is_read =
                     CASE 
                         WHEN @CODC_Type = 'D' THEN 1   -- Draft
                         WHEN @CODC_Type = 'F' THEN 2   -- Final
                         ELSE Is_read
                     END
                 WHERE Coating_Req_Id = @_Req_Id;
                END
            IF (@CODC_Type = 'F')              
            BEGIN              
                SET @DC_No = 'HF/CODC/' + CONVERT(VARCHAR(20), FORMAT(@_Invoice_No, '0000')) + '/' + CONVERT(VARCHAR(20), @_Financial_Year)              
            END              
            ELSE              
            BEGIN              
                SET @DC_No = @DC_No1              
            END              

            BEGIN TRY
                IF EXISTS (SELECT 1 FROM [DC_Mst] WITH (NOLOCK) WHERE DC_Id = @DC_Id AND CODC_Type = 'F')
                BEGIN
                    SET @RetVal = -101      
                    SET @RetMsg = 'This Challan already saved by another User.'
                    ROLLBACK TRANSACTION;
                    RETURN   
                END
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0
                BEGIN
                    ROLLBACK TRANSACTION
                END
                SET @RetVal = ERROR_NUMBER()
                SET @RetMsg = ERROR_MESSAGE()
            END CATCH

            UPDATE [dbo].[DC_Mst] WITH (ROWLOCK)              
            SET Dept_ID = @Dept_ID,
                dc_date = (CASE WHEN (@Revision <> '1') THEN @DC_Date ELSE dc_date END),              
                invoice_no = (CASE WHEN (@Revision <> '1') THEN @_Invoice_No ELSE invoice_no END),              
                Year_Id = (CASE WHEN (@Revision <> '1') THEN @Year_Id ELSE Year_Id END),              
                DC_No = (CASE WHEN (@Revision <> '1') THEN @DC_No ELSE DC_No END),              
                supplier_id = @Supplier_Id,              
                siteenginner_id = @SiteEnginner_Id,              
                issue_byid = @Issue_ById,              
                project_id = @Project_Id,              
                Godown_Id = @Godown_Id,              
                quotationno = @QuotationNo,              
                coating_shadeid = @Coating_ShadeId,              
                projectdocument = @ProjectDocument,              
                transporttype = @TransportType,              
                vehicle_no = @Vehicle_No,              
                driver_name = @Driver_Name,              
                contact_of_driver = @Contact_of_Driver,              
                challantype = @ChallanType,              
                coating_shade = @Coating_Shade,              
                grossamount = @GrossAmount,              
                cgst_mv = @CGST_MV,              
                sgst_mv = @SGST_MV,              
                igst_mv = @IGST_MV,              
                cgst_mvtotal = @CGST_MVTotal,              
                sgst_mvtotal = @SGST_MVTotal,              
                igst_mvtotal = @IGST_MVTotal,              
                cgst = @CGST,              
                sgst = @SGST,              
                igst = @IGST,              
                cgsttotal = @CGSTTotal,              
                sgsttotal = @SGSTTotal,              
                igsttotal = @IGSTTotal,              
                netamount = @NetAmount,              
                remark = @Remark,              
                upd_user = @Upd_User,              
                upd_date = dbo.Get_sysdate()              
            WHERE DC_Id = @DC_Id              

            IF @@ERROR = 0              
            BEGIN              
                SET @RetVal = @DC_Id              
                SET @RetMsg = 'Coating DC Update Successfully And Update Coating DC No is : ' + @DC_No + '.'              

                /******************************* Splited DC Qty Plus In Stock*******************************/              
                BEGIN              
                    DECLARE db_curspl CURSOR FOR              
                    SELECT srno, Id, DCDtl_Id, DC_Id, dept_id, Item_Id, calc_area, running_feet, rate_feet, 
                           coating_value, qty, dc_qty, itemlength, total_weight, material_value, remark, 
                           Scrap_Qty, scrap_length, godown_id, [weight],Coating_Rate              
                    FROM @DtlPara              
                    WHERE godown_id <> 0 AND Is_Delete = 0;              

                    OPEN db_curspl              

                    FETCH NEXT FROM db_curspl INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, 
                                                   @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, 
                                                   @_Coating_Value, @_Qty, @_DC_Qty, @_ItemLength, 
                                                   @_Total_Weight, @_Material_Value, @_Remark, 
                                                   @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight,@_Coating_Rate              

                    WHILE @@FETCH_STATUS = 0              
                    BEGIN              
                        DECLARE @_DEID1 AS INT = 0              

                        IF (@_DCDtl_Id = 0) /* Draft Time New Item Add Save */              
                        BEGIN              
                            INSERT INTO [dbo].[DC_Dtl] WITH (ROWLOCK)              
                                ([DC_Id], dept_id, item_group_id, item_cate_id, Item_Id, qty, unit_id, itemlength, 
                                 rate, running_feet, rate_feet, coating_value, total_weight, material_value, 
                                 totalvalue, remark, dc_qty, Scrap_Qty, scrap_length, godown_id, stock_id, 
                                 calc_area, weight_mtr, Pending_Qty, is_revision, MR_Item_Id,Coating_Rate)              
                            VALUES (@RetVal, @_Dept_ID, 0, 0, @_Item_Id, @_Qty, 0, @_ItemLength, 0, 
                                    @_Running_Feet, @_Rate_Feet, @_Coating_Value, @_Total_Weight, 
                                    @_Material_Value, 0, @_Remark, @_DC_Qty, @_Scrap_Qty, @_Scrap_Length, 
                                    @_Godown_Id1, @_Id, @_Calc_Area, @_Weight, @_DC_Qty, 
                                    (CASE WHEN @Revision = '1' THEN 1 ELSE 0 END), @_MR_Item_Id,@_Coating_Rate)              

                            SET @_DEID1 = SCOPE_IDENTITY()              
                        END              
                        ELSE              
                        BEGIN              
                            SET @_DEID1 = @_DCDtl_Id              
                        END              

                        IF (@CODC_Type = 'F') /* Edit Time Final DC Select */              
                        BEGIN
                        DECLARE @_EdtGodown_Ids AS INT = 0,              
                                    @_EdtRack_Ids   AS INT = 0,              
                                    @_EdtSTypes     AS VARCHAR(5) = '',              
                                    @_EdtScarpvals  AS NUMERIC(18, 2) = 0,              
                                    @_EdtWidths     AS NUMERIC(18, 3) = 0,
                                    @_EdtLengths    AS NUMERIC(18,3) = 0

                            SELECT @_EdtGodown_Ids = ISNULL(godown_id, 0),              
                                   @_EdtSTypes = SType,              
                                   @_EdtWidths = Width,              
                                   @_EdtRack_Ids = Rack_Id,
                                   @_EdtLengths = [Length]
                            FROM StockView WITH (NOLOCK) WHERE Id = @_Id 

                        
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
                                    @_EdtGodown_Ids,
                                    @_Item_Id,
                                    @_EdtSTypes,
                                    @_Qty,
                                    @_EdtLengths,       
                                    @_EdtWidths,
                                    @_EdtRack_Ids,
                                    dbo.Get_sysdate(),
                                    'Co-DC(Edit)',
                                    'CO-DC',
                                    'DC_Dtl',
                                    'OUT',
                                    1,
                                    @_Id,               
                                    @_DEID1
                                );

                            UPDATE StockView WITH (ROWLOCK)              
                            SET Sales_Qty = ISNULL(Sales_Qty, 0) + @_Qty,              
                                Pending_Qty = ISNULL(Pending_Qty, 0) - @_Qty,              
                                LastUpdate = dbo.Get_sysdate(),              
                                StockEntryPage = @DC_Type,              
                                StockEntryQty = @_Qty,  
                                Dtl_Id = @_DEID1,  
                                Tbl_Name = 'DC_Dtl'  
                            WHERE Id = @_Id AND @Revision = '0'              

                            DECLARE @_EdtGodown_Id AS INT = 0,              
                                    @_EdtRack_Id   AS INT = 0,              
                                    @_EdtSType     AS VARCHAR(5) = '',              
                                    @_EdtScarpval  AS NUMERIC(18, 2) = 0,              
                                    @_EdtWidth     AS NUMERIC(18, 3) = 0              

                            SELECT @_EdtGodown_Id = ISNULL(godown_id, 0),              
                                   @_EdtSType = SType,              
                                   @_EdtWidth = Width,              
                                   @_EdtRack_Id = Rack_Id              
                            FROM StockView WITH (NOLOCK) WHERE Id = @_Id              

                            UPDATE DC_Dtl WITH (ROWLOCK) SET DC_Width = @_EdtWidth, Scrap_Width = @_EdtWidth WHERE DCDtl_Id = @_DEID1              

                            SELECT @_EdtScarpval = ISNULL(master_numvals, 0)              
                            FROM M_Master WITH (NOLOCK) WHERE M_Master.Master_Type = 'SCRAP' AND M_Master.Is_Active = 1              

                            IF EXISTS (SELECT 1 FROM StockView WITH (NOLOCK)              
                                       WHERE StockView.godown_id = @_EdtGodown_Id              
                                       AND StockView.Item_Id = @_Item_Id              
                                       AND StockView.SType = @_EdtSType              
                                       AND StockView.Rack_Id = @_EdtRack_Id              
                                       AND StockView.Length = @_Scrap_Length              
                                       AND StockView.Width = @_EdtWidth)              
                            BEGIN              
                                IF (@_EdtScarpval > 0 AND @_EdtScarpval > @_Scrap_Length)              
                                BEGIN   
                                    IF (@_Scrap_Length <> 0)
                                    Begin
                                    UPDATE StockView WITH (ROWLOCK)              
                                    SET Scrap_Settle = ISNULL(Scrap_Settle, 0) + @_Scrap_Qty,              
                                        Scrap_Qty = ISNULL(Scrap_Qty, 0) + @_Scrap_Qty,              
                                        LastUpdate = dbo.Get_sysdate(),              
                                        StockEntryPage = 'CO-DC-Scrap',              
                                        StockEntryQty = @_Scrap_Qty,  
                                        Dtl_Id = @_DEID1,  
                                        Tbl_Name = 'DC_Dtl'              
                                    WHERE StockView.godown_id = @_EdtGodown_Id              
                                        AND StockView.Item_Id = @_Item_Id              
                                        AND StockView.SType = @_EdtSType              
                                        AND StockView.Rack_Id = @_EdtRack_Id              
                                        AND StockView.Length = @_Scrap_Length              
                                        AND StockView.Width = @_EdtWidth  
                                        end
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
                                        @_EdtGodown_Ids,
                                        @_Item_Id,
                                        @_EdtSTypes,
                                        @_Scrap_Qty,
                                        @_Scrap_Length,       
                                        @_EdtWidths,
                                        @_EdtRack_Ids,
                                        dbo.Get_sysdate(),
                                        'Co-DC(Edit)',
                                        'CO-DC-Scrap',
                                        'DC_Dtl',
                                        'IN',
                                        0,
                                        @_Id,               
                                        @_DEID1
                                    );


                                    UPDATE StockView WITH (ROWLOCK)              
                                    SET Pending_Qty = ISNULL(Pending_Qty, 0) + @_Scrap_Qty,              
                                        Scrap_Qty = ISNULL(Scrap_Qty, 0) + @_Scrap_Qty,              
                                        LastUpdate = dbo.Get_sysdate(),              
                                        StockEntryPage = 'CO-DC-Scrap',              
                                        StockEntryQty = @_Scrap_Qty,  
                                        Dtl_Id = @_DEID1,  
                                        Tbl_Name = 'DC_Dtl'              
                                    WHERE StockView.godown_id = @_EdtGodown_Id              
                                        AND StockView.Item_Id = @_Item_Id              
                                        AND StockView.SType = @_EdtSType              
                                        AND StockView.Rack_Id = @_EdtRack_Id              
                                        AND StockView.Length = @_Scrap_Length              
                                        AND StockView.Width = @_EdtWidth              
                                END              
                            END              
                            ELSE              
                            BEGIN              
                                IF (@_EdtScarpval > 0 AND @_EdtScarpval > @_Scrap_Length)              
                                BEGIN    
                                IF (@_Scrap_Length <> 0)
                                begin
                                    INSERT INTO [dbo].[StockView] WITH (ROWLOCK)              
                                        ([Godown_Id], Item_Id, SType, Total_Qty, Sales_Qty, Pending_Qty, 
                                         Transfer_Qty, Adjust_Qty, Length, Scrap_Qty, Scrap_Settle, 
                                         LastUpdate, Ref_Id, Width, Rack_Id, StockEntryPage, 
                                         StockEntryQty, Dtl_Id, Tbl_Name)              
                                    VALUES (@_EdtGodown_Id, @_Item_Id, @_EdtSType, 0, 0, 0, 0, 0, 
                                            @_Scrap_Length, @_Scrap_Qty, @_Scrap_Qty, dbo.Get_sysdate(), 
                                            @_Id, @_EdtWidth, @_EdtRack_Id, 'CO-DC-Scrap', 
                                            @_Scrap_Qty, @_DEID1, 'DC_Dtl')  
                                            end
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
                                            @_EdtGodown_Id,
                                            @_Item_Id,
                                            @_EdtSType,
                                            @_Scrap_Qty,
                                            @_Scrap_Length,       
                                            @_EdtWidth,
                                            @_EdtRack_Id,
                                            dbo.Get_sysdate(),
                                            'Co-DC(Save)',
                                            'CO-DC-Scrap',
                                            'DC_Dtl',
                                            'IN',
                                            0,
                                            NULL,               
                                            @_DEID1
                                        );
                                   SET @_History_Id =NULL;
                                    SET @_History_Id = SCOPE_IDENTITY();


                                    INSERT INTO [dbo].[StockView] WITH (ROWLOCK)              
                                        ([Godown_Id], Item_Id, SType, Total_Qty, Sales_Qty, Pending_Qty, 
                                         Transfer_Qty, Adjust_Qty, Length, Scrap_Qty, Scrap_Settle, 
                                         LastUpdate, Ref_Id, Width, Rack_Id, StockEntryPage, 
                                         StockEntryQty, Dtl_Id, Tbl_Name)              
                                    VALUES (@_EdtGodown_Id, @_Item_Id, @_EdtSType, 0, 0, @_Scrap_Qty, 
                                            0, 0, @_Scrap_Length, @_Scrap_Qty, 0, dbo.Get_sysdate(), 
                                            @_Id, @_EdtWidth, @_EdtRack_Id, 'CO-DC-Scrap', 
                                            @_Scrap_Qty, @_DEID1, 'DC_Dtl')
                                   UPDATE Stock_Transfer_History SET Stock_Id = SCOPE_IDENTITY() WHERE ID = @_History_Id;
                                END              
                            END              
                        END              

                        FETCH NEXT FROM db_curspl INTO @_SrNo, @_Id, @_DCDtl_Id, @_DO_Id, @_Dept_ID, 
                                                       @_Item_Id, @_Calc_Area, @_Running_Feet, @_Rate_Feet, 
                                                       @_Coating_Value, @_Qty, @_DC_Qty, @_ItemLength, 
                                                       @_Total_Weight, @_Material_Value, @_Remark, 
                                                       @_Scrap_Qty, @_Scrap_Length, @_Godown_Id1, @_Weight,@_Coating_Rate              
                    END              

                    CLOSE db_curspl              
                    DEALLOCATE db_curspl              
                END              

                DELETE FROM DC_Dtl WITH (ROWLOCK) WHERE DC_Dtl.DCDtl_Id IN (SELECT DCDtl_Id FROM @DtlPara WHERE Is_Delete = 1) AND DC_Dtl.DC_Id = @DC_Id              

                UPDATE [dbo].[DC_Mst] WITH (ROWLOCK) SET [CODC_Type] = @CODC_Type WHERE DC_Id = @DC_Id   

            END              
            ELSE              
            BEGIN              
                SET @RetVal = 0              
                SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.'              
                RETURN              
            END              

            COMMIT              
        /************************************* COMMIT *************************************/              
        END TRY              
        BEGIN CATCH              
            ROLLBACK              
            /************************************* ROLLBACK *************************************/              
            SET @RetVal = -405              
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.'              
            RETURN              
        END CATCH                                
    END                               
    /*********** Edit Entry END ***********/                                
END
GO


