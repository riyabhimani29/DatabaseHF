USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Coatdc_mst_EditCoater]    Script Date: 27-04-2026 11:05:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                     
                    
ALTER  PROCEDURE [dbo].[Coatdc_mst_EditCoater]                                  
                                           @DC_Id           INT,    
                                               @Supplier_Id     INT,    
                                               @Coating_ShadeId INT,    
                                               @Coating_Rate numeric(18,3),    
                                               @Remark          VARCHAR(500),    
                                               @MAC_Add         VARCHAR(500),    
                                               @Entry_User      INT,    
                                               @Upd_User        INT,    
                                               @Year_Id         INT,    
                                               @Branch_ID       INT,    
                                               @RetVal          INT = 0 out,    
                                               @RetMsg          VARCHAR(max) = ''out    
AS    
    SET nocount ON    
    
  BEGIN    
      BEGIN try    
      IF NOT EXISTS(SELECT 1    
                        FROM   [DC_Mst] WITH (nolock)    
                        WHERE  DC_Id = @DC_Id)    
            BEGIN    
                SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                               
                SET @RetMsg = ' This Coating DC is Not Exist.'    
                RETURN    
            END    
    
    
        BEGIN TRANSACTION    
    
          /************************************* TRANSACTION *************************************/    
    /***************************************************************************************/  
     
			--Declare the variables for holding data.    
		   DECLARE @_ItemLength  numeric(18,3)   =0, @_DC_Qty  numeric(18,3)   =0, @_Calc_Area numeric(18,3)   = 0, @_DCDtl_Id int = 0  
      
		   --Declare a cursor    
		   DECLARE PrintCustomers CURSOR    
		   FOR    
     
			select ItemLength,DC_Qty,Calc_Area,DCDtl_Id from DC_Dtl  with(nolock) where DC_Id = @DC_Id   
    
		   --Open cursor    
		   OPEN PrintCustomers    
     
		   --Fetch the record into the variables.    
		   FETCH NEXT FROM PrintCustomers INTO    
			@_ItemLength, @_DC_Qty, @_Calc_Area  ,@_DCDtl_Id  
    
		   --LOOP UNTIL RECORDS ARE AVAILABLE.    
		   WHILE @@FETCH_STATUS = 0    
			BEGIN    
    
			declare @_Running_Feet numeric(18,3)   =0  , @_Rate_Feet  numeric(18,3)   =0,  @_Coating_Value  numeric(18,3)   =0            
			set @_Running_Feet  = ((@_ItemLength / 304.8) * @_DC_Qty)           
			set @_Rate_Feet = ((@_Calc_Area / 304.8) * @Coating_Rate)          
			Set @_Coating_Value  = convert(numeric(18,0), (@_Running_Feet * @_Rate_Feet) )  
  
		  update DC_Dtl with(rowlock) set   Rate_Feet = @_Rate_Feet , Coating_Value = @_Coating_Value where DCDtl_Id =   @_DCDtl_Id   
    
			 FETCH NEXT FROM PrintCustomers INTO    
			   @_ItemLength, @_DC_Qty, @_Calc_Area  ,@_DCDtl_Id  
			END    
     
		   --Close the cursor    
		   CLOSE PrintCustomers    
    
		   --Deallocate the cursor    
		   DEALLOCATE PrintCustomers  
  
   /***************************************************************************************/  
   
          Declare @_Coating_Valuea as numeric(18,3) =0   
          select @_Coating_Valuea = isnull(sum(Coating_Value),0) from  DC_Dtl with(nolock) where DC_Id = @DC_Id  
   
  -- (@_Coating_Valuea  * GSTPer )/ 100  
  
		  declare @_CGST as int = 0 , @_SGST as int = 0 , @_IGST as int = 0  ,
					@_CGSTPer as numeric(18,3) = 0 , @_SGSTPer as numeric(18,3)  = 0 , @_IGSTPer as  numeric(18,3)  = 0 ,
					@_CGST_Total as numeric(18,2) = 0 , @_SGST_Total as numeric(18,2)  = 0 , @_IGST_Total as  numeric(18,2)  = 0 

		  select @_CGST = isnull(CGST,0) , @_SGST =  isnull(SGST,0) , @_IGST =  isnull(IGST,0)  from DC_Mst where DC_Id =   @DC_Id  

		  select @_CGSTPer = isnull(Master_NumVals,0) from M_Master where  Master_Id = @_CGST
		  select @_SGSTPer = isnull(Master_NumVals,0) from M_Master where  Master_Id = @_SGST
		  select @_IGSTPer = isnull(Master_NumVals,0) from M_Master where  Master_Id = @_IGST
  
          set @_CGST_Total = (@_Coating_Valuea * @_CGSTPer )--/100  
          set @_SGST_Total = (@_Coating_Valuea * @_SGSTPer )--/100
          set @_IGST_Total = (@_Coating_Valuea * @_IGSTPer )--/100 

          UPDATE [dbo].[DC_Mst] WITH (rowlock)    
          SET    [Supplier_Id] = @Supplier_Id,    
                 Coating_ShadeId = @Coating_ShadeId,   
				 Coating_Rate = @Coating_Rate ,  
				 GrossAmount = @_Coating_Valuea,  
				 CGSTTotal = @_CGST_Total,   
				 SGSTTotal = @_SGST_Total,  
				 IGSTTotal = @_IGST_Total,  
				 NetAmount = (@_Coating_Valuea + @_CGST_Total + @_SGST_Total + @_IGST_Total ) ,    
                 [Upd_User] = @Upd_User,    
                 [Upd_Date] = dbo.Get_sysdate()    
          WHERE  DC_Id = @DC_Id    
    
          /********************************/    
          IF @@ERROR = 0    
            BEGIN    
                SET @RetVal = @DC_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                                                
                SET @RetMsg = 'Coating DC Coater & coating Shade  Update Successfully  .'    
            END    
          ELSE    
            BEGIN    
                SET @RetVal = -404 -- 0 WHEN AN ERROR HAS OCCURED                                                
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


