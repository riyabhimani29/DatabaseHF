USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_Publish]    Script Date: 27-04-2026 10:57:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[BOM_Publish]  
    @BOM_Id INT,  
    @Entry_User INT,      
    @Upd_User INT,      
    @DtlPara TBL_BOMDETAIL1 readonly,      
    @RetVal INT = 0 out,      
    @RetMsg VARCHAR(max) = '' out  
AS      
BEGIN
    SET NOCOUNT ON;
      
    DECLARE @_BOM_Dtl_Id INT = 0,      
            @_Item_Id INT = 0,      
            @_Stock_Id INT = 0,      
            @_Godown_Id INT = 0,      
            @_Qty NUMERIC(18, 3) = 0,      
            @_Length NUMERIC(18, 3) = 0,      
            @_Weight NUMERIC(18, 3) = 0,      
            @_Width NUMERIC(18, 3) = 0,      
            @_UnitCost NUMERIC(18, 3) = 0,    
            @_UnitBendingCost NUMERIC(18, 3) = 0,      
            @_TotalBendingCost NUMERIC(18, 3) = 0,
            @_TotalCost NUMERIC(18, 3) = 0,      
            @_coatingJson VARCHAR(5555) = '',
            @_Remark VARCHAR(500) = '';
      
    IF @BOM_Id != 0      
    BEGIN      
        BEGIN TRY      
            BEGIN TRANSACTION;       
            
            UPDATE BOM_MST 
            SET IsPublish = 1
            WHERE Bom_Id = @BOM_Id;
      			
            SET @RetVal = SCOPE_IDENTITY();      
            SET @RetMsg = 'Raise BOM Publish Successfully.';
      
            IF @@ERROR <> 0      
            BEGIN      
                SET @RetVal = 0; -- 0 IS FOR ERROR                                                                            
                SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';      
            END      
            ELSE     
            BEGIN      
                DECLARE bom_cur CURSOR FOR      
                SELECT BOM_Dtl_Id,
                       Item_Id,      
                       Stock_Id,      
                       Godown_Id,
                       Qty,      
                       CONVERT(NUMERIC(18, 3), Length),      
                       CONVERT(NUMERIC(18, 3), Weight),      
                       UnitCost,
                       UnitBendingCost,      
                       TotalBendingCost,      
                       TotalCost,      
                       Width,
                       coatingJson,
                       Remark
                FROM @DtlPara;      
      
                OPEN bom_cur;      
      
                FETCH NEXT FROM bom_cur INTO @_BOM_Dtl_Id, @_Item_Id, @_Stock_Id, @_Godown_Id, @_Qty, @_Length, @_Weight, 
                                            @_UnitCost, @_UnitBendingCost, @_TotalBendingCost, @_TotalCost, @_Width, @_coatingJson, @_Remark;
      
                WHILE @@FETCH_STATUS = 0      
                BEGIN
                    IF @_Stock_Id = 0 
                    BEGIN
                        SELECT @_Stock_Id = Id 
                        FROM StockView 
                        WHERE Godown_Id = @_Godown_Id
                          AND Item_Id = @_Item_Id 
                          AND [Length] = @_Length
                          AND Width = @_Width
                          and Pending_Qty <> 0;
                             
                        IF @_Stock_Id <> 0 
                        BEGIN
                            UPDATE StockView WITH (ROWLOCK)              
                            SET Sales_Qty = ISNULL(Sales_Qty, 0) + @_Qty,              
                                Pending_Qty = ISNULL(Pending_Qty, 0) - @_Qty,              
                                LastUpdate = dbo.Get_sysdate(),              
                                StockEntryPage = 'BOM',              
                                StockEntryQty = @_Qty,  
                                Dtl_Id = @_BOM_Dtl_Id,  
                                Tbl_Name = 'BOM_Dtl'  
                            WHERE Id = @_Stock_Id;
                        END
                    END
                    
                    ELSE IF @_Stock_Id <> 0
                    BEGIN
                        UPDATE StockView WITH (ROWLOCK)              
                        SET Sales_Qty = ISNULL(Sales_Qty, 0) + @_Qty,              
                            Pending_Qty = ISNULL(Pending_Qty, 0) - @_Qty,              
                            LastUpdate = dbo.Get_sysdate(),              
                            StockEntryPage = 'BOM',              
                            StockEntryQty = @_Qty,  
                            Dtl_Id = @_BOM_Dtl_Id,  
                            Tbl_Name = 'BOM_Dtl'  
                        WHERE Id = @_Stock_Id;
                    END
                    
                    FETCH NEXT FROM bom_cur INTO @_BOM_Dtl_Id, @_Item_Id, @_Stock_Id, @_Godown_Id, @_Qty, @_Length, @_Weight, 
                                                    @_UnitCost, @_UnitBendingCost, @_TotalBendingCost, @_TotalCost, @_Width, @_coatingJson, @_Remark;
                END;      
      
                CLOSE bom_cur;      
                DEALLOCATE bom_cur;      
            END;      
      
            COMMIT;      
        END TRY      
      
        BEGIN CATCH      
            ROLLBACK;      
      
            SET @RetVal = -405;      
            SET @RetMsg = 'Error Occurred - ' + ERROR_MESSAGE() + '.';      
        END CATCH;      
    END;      
END;
GO


