USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Item_InsUpd]    Script Date: 27-04-2026 12:25:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Item_InsUpd] @Item_Group_Id   INT,          
                                      @Item_Cate_Id    INT,          
                                      @Item_Id         INT,          
                                      @Item_Code       VARCHAR(500),          
                                      @Item_Name       VARCHAR(500),          
                                      @Barcode         VARCHAR(500),          
                                      @HSN_Code        VARCHAR(500),          
                                      @Total_Parameter NUMERIC(18, 3),          
                                      @Coated_Area     NUMERIC(18, 3),          
                                      @NonCoated_Area  NUMERIC(18, 3),          
                                      @Calc_Area       NUMERIC(18, 3),          
                                      @Thickness       NUMERIC(18, 3),          
                                      @Weight_Mtr      NUMERIC(18, 3),          
                                      @Item_Rate       NUMERIC(18, 3),          
                                      @Unit_Id         INT,
                                      @Alternate_Unit_Id INT,
                                      @AlternateUnitValue NUMERIC(18,3),
									  @AlternateUnitPrice NUMERIC(18,3),
                                      @UnitValue       NUMERIC(18, 3),          
                                      @Is_Active       BIT,          
                                      @Remark          VARCHAR(500),          
                                      @StockAlert      NUMERIC(18, 3),          
                                      @AlertDay        INT,          
                                      @MAC_Add         VARCHAR(500),          
                                      @Entry_User      INT,          
                                      @Upd_User        INT,          
                                      @Year_Id         INT,          
                                      @Branch_ID       INT,          
                                      @RevisionItem_Id INT,          
                                      @RetVal          INT = 0 out,          
                                      @RetMsg          VARCHAR(max) = '' out   ,          
                                      @_ImageName          VARCHAR(max) = '' out    ,          
                                      @_CadName          VARCHAR(max) = '' out        
AS          
    SET nocount ON          
          
    IF ( @Item_Id = 0 )          
      BEGIN                             
          
          --IF EXISTS(SELECT 1          
          --          FROM   m_item WITH (nolock)          
          --          WHERE  item_name = @Item_Name          
          --                 AND item_group_id = @Item_Group_Id          
          --                 AND item_cate_id = @Item_Cate_Id AND @RevisionItem_Id = 0)          
          --  BEGIN          
          --      SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                     
          --      SET @RetMsg = 'Same Description Exist In Selected Group & Category !!!'                  
          --      RETURN          
          --  END          
          IF ( @Item_Code = '')
          BEGIN
          SET @Item_Code = dbo.Get_hifabcode(@Item_Group_Id, @Item_Cate_Id, @RevisionItem_Id)          
			END
			IF EXISTS(SELECT 1          
                    FROM   m_item WITH (nolock)          
                    WHERE  item_code = @Item_Code          
                           AND item_group_id = @Item_Group_Id          
                           AND item_cate_id = @Item_Cate_Id)          
            BEGIN          
                SET @RetVal = -101          
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                      
                SET @RetMsg =          
                'Same HiFab_Code Exist In Selected Group & Category.'          
          
                RETURN          
            END
			
          DECLARE @_Item_No AS INT =0          
          
          IF @RevisionItem_Id = 0          
            BEGIN          
                SELECT @_Item_No = Isnull(Max(m_item.item_no), 0) + 1          
                FROM   m_item WITH(nolock)          
                WHERE  m_item.item_group_id = @Item_Group_Id          
                       AND m_item.item_cate_id = @Item_Cate_Id          
                       AND revisionitem_id = 0          
            END          
          ELSE          
            BEGIN          
    SELECT @_Item_No = Isnull(Max(m_item.item_no), 0)          
                FROM   m_item WITH(nolock)          
                WHERE  m_item.item_group_id = @Item_Group_Id          
                       AND m_item.item_cate_id = @Item_Cate_Id          
                 AND Item_Id = @RevisionItem_Id          
            END          
          
          IF ( @RevisionItem_Id > 0 )          
            BEGIN          
                DECLARE @_RevisionCnt AS INT =0          
          
                SELECT @_RevisionCnt = Isnull(Count(*), 0)          
                FROM   m_item WITH(nolock)          
                WHERE  revisionitem_id = @RevisionItem_Id          
          
                SET @Item_Code=@Item_Code + '-' + Char( 65 + @_RevisionCnt)          
            END          
          
          INSERT INTO m_item WITH(rowlock)          
                      (item_group_id, item_cate_id,item_code,item_no,item_name,barcode,hsn_code,total_parameter,coated_area,noncoated_area,calc_area,          
                       weight_mtr,item_rate,unit_id,unitvalue,is_active,remark,stockalert,alertday,/* OpeningStock , OpeningStockDate,    */mac_add,          
                       entry_user,entry_date,year_id,branch_id,thickness,revisionitem_id,Alternate_Unit_Id,AlternateUnitValue,AlternateUnitPrice)          
          VALUES      ( @Item_Group_Id,@Item_Cate_Id,@Item_Code,@_Item_No,@Item_Name,@Barcode,@HSN_Code,@Total_Parameter,@Coated_Area,@NonCoated_Area,@Calc_Area,          
                        @Weight_Mtr,@Item_Rate,@Unit_Id,@UnitValue,@Is_Active,@Remark,@StockAlert,@AlertDay,/*@OpeningStock , @OpeningStockDate,    */@MAC_Add,          
                        @Entry_User,dbo.Get_sysdate(),@Year_Id,@Branch_ID,@Thickness,@RevisionItem_Id,@Alternate_Unit_Id,@AlternateUnitValue,@AlternateUnitPrice)          
          
          SET @RetMsg = 'Description Create Sucessfully , Generate Hifab Code is "' + @Item_Code + '".'          
          SET @RetVal = Scope_identity()          
    --DECLARE @_ImageName AS varchar(100)=''      
         
			set @_ImageName = CONVERT(varchar(100), CONVERT(numeric(38,0),  REPLACE(REPLACE(REPLACE(REPLACE( SYSUTCDATETIME(),'-',''),' ',''),':',''),'.','')) + @RetVal) +'.png'      
			set @_CadName =  @Item_Code +'_'+(CONVERT(varchar(100), CONVERT(numeric(38,0),  REPLACE(REPLACE(REPLACE(REPLACE( SYSUTCDATETIME(),'-',''),' ',''),':',''),'.','')) )) +'.dwg'     
                
    update M_Item set ImageName = @_ImageName , CadFileName = @_CadName where Item_Id = @RetVal      
      
    IF @@ERROR <> 0          
            BEGIN          
                SET @RetVal = 0 -- 0 IS FOR ERROR                                    
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
            END          
      END          
    ELSE ---------------- Edit                                    
      BEGIN          
          IF NOT EXISTS(SELECT 1          
                        FROM   m_item WITH (nolock)          
                        WHERE  item_id = @Item_Id)          
            BEGIN          
                SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                       
                SET @RetMsg = 'This Description Is Already Been Deleted By Another User.'          
                RETURN          
            END          
         
          set @_ImageName = '';      
      
          IF EXISTS(SELECT 1          
                    FROM   m_item WITH (nolock)          
                    WHERE  item_code = @Item_Code          
                           AND item_group_id = @Item_Group_Id          
                           AND item_cate_id = @Item_Cate_Id          
         AND RevisionItem_Id = 0          
                           AND item_id <> @Item_Id)          
            BEGIN          
                SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                    
                SET @RetMsg = 'Same HiFab_Code Exist In Selected Group & Category.'          
                RETURN          
            END          
          
       --   IF EXISTS(SELECT 1          
       --             FROM   m_item WITH (nolock)          
       --             WHERE  item_name = @Item_Name          
       --AND item_group_id = @Item_Group_Id          
       --                    AND item_cate_id = @Item_Cate_Id          
       --AND @RevisionItem_Id = 0          
       --                    AND item_id <> @Item_Id)          
       --     BEGIN          
       --         SET @RetVal = -103  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                                      
       --         SET @RetMsg =  'Same Description Exist In Selected Group & Category.'                
       --         RETURN          
       --     END          
          
          UPDATE m_item WITH (rowlock)          
          SET    --Item_Code = @Item_Code ,
                    Item_Group_Id = @Item_Group_Id,
                  Item_Cate_Id = @Item_Cate_Id,
				  item_name = @Item_Name,          
				  hsn_code = @HSN_Code,          
				  total_parameter = @Total_Parameter,          
				  coated_area = @Coated_Area,          
				  noncoated_area = @NonCoated_Area,          
				  calc_area = @Calc_Area,          
				  weight_mtr = @Weight_Mtr,          
				  item_rate = @Item_Rate,          
				  unit_id = @Unit_Id,          
				  unitvalue = @UnitValue,          
				  is_active = @Is_Active,          
				  thickness = @Thickness,          
				  remark = @Remark,          
				  stockalert = @StockAlert,          
				  alertday = @AlertDay,          
				  upd_user = @Upd_User,          
				  upd_date = dbo.Get_sysdate(),
				  Alternate_Unit_Id = @Alternate_Unit_Id,
				  AlternateUnitValue = @AlternateUnitValue,
				  AlternateUnitPrice= @AlternateUnitPrice
          WHERE  item_id = @Item_Id          
          
          IF @@ERROR = 0          
            BEGIN          
                SET @RetVal = 1          
                -- 1 IS FOR SUCCESSFULLY EXECUTED                                    
                SET @RetMsg ='Description Details Update Successfully.'          
            END          
          ELSE          
            BEGIN          
                SET @RetVal = 0          
                -- 0 WHEN AN ERROR HAS OCCURED                                   
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'          
            END          
      END 
GO


