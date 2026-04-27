USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_ChkDtl]    Script Date: 27-04-2026 13:10:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[PO_MST_ChkDtl]                  
 @DtlPara            Tbl_PODetail_Glass readonly ,  
 @Supplier_Id int  
            
AS                                      
    SET nocount ON                                      
    
     DECLARE @_SrNo      AS   Int = 0 ,   
			@_Item_Group_Name      AS  VARCHAR(500)= '' ,                    
            @_Item_Cate_Name AS  VARCHAR(500)= '' ,                    
            @_Description  AS  VARCHAR(500)= '' ,                    
            @_Project_Name       AS  VARCHAR(500)= ''      
     
BEGIN
    CREATE TABLE #mytable
      (
         SrNo          INT,
         Item_Group_Id INT,
         Item_Cate_Id  INT,
         Item_Id       INT,
         SupDetail_Id  INT,
         Project_Id  INT,
         Weight_Mtr  numeric(18,3),
         Thickness  numeric(18,3),
         NAME          NVARCHAR(20)
      )

    DECLARE purchase_cur CURSOR FOR
      SELECT srno,
             item_group_name,
             item_cate_name,
             description,
             project_name
      FROM   @DtlPara;

    OPEN purchase_cur

    FETCH next FROM purchase_cur INTO @_SrNo, @_Item_Group_Name,
    @_Item_Cate_Name, @_Description, @_Project_Name

    WHILE @@FETCH_STATUS = 0
      BEGIN
          DECLARE @_Item_Id       AS INT = 0,
                  @_SupDetail_Id  AS INT = 0,
                  @_Item_Group_Id AS INT = 0,
                  @_Item_Cate_Id  AS INT = 0,
                  @_Project_Id  AS INT = 0,
                  @_Weight_Mtr  AS numeric(18,3) = 0,
                  @_Thickness  AS numeric(18,3) = 0

          SELECT @_Project_Id = Isnull(Project_Id, 0) 
          FROM   M_Project WITH (nolock)
          WHERE  M_Project.Project_Name = @_Project_Name

          SELECT @_Item_Id = Isnull(Item_Id, 0),
                 @_Item_Group_Id = Isnull(Item_Group_Id, 0),
                 @_Item_Cate_Id = Isnull(Item_Cate_Id, 0) ,
				 @_Weight_Mtr = Isnull(Weight_Mtr, 0),
				 @_Thickness = Isnull(Thickness, 0)
          FROM   M_Item WITH (nolock)
          WHERE  M_Item.Item_Name = @_Description

          IF ( @_Item_Id > 0 )
            BEGIN
                SELECT @_SupDetail_Id = Isnull(supdetail_id, 0)
                FROM   M_SupplierDtl WITH (nolock)
                WHERE  Supplier_Id = @Supplier_Id
                       AND Item_Id = @_Item_Id
            END
          ELSE
            BEGIN
                SET @_SupDetail_Id = 0
            END

          INSERT INTO #mytable
          VALUES      (@_SrNo,
                       @_Item_Group_Id,
                       @_Item_Cate_Id,
                       @_Item_Id,
                       @_SupDetail_Id,
					   @_Project_Id,
					   @_Weight_Mtr,
					   @_Thickness,
                       'Saurabh');

          FETCH next FROM purchase_cur INTO @_SrNo, @_Item_Group_Name,
          @_Item_Cate_Name, @_Description, @_Project_Name
      END

    CLOSE purchase_cur;

    DEALLOCATE purchase_cur;

    SELECT *
    FROM   #mytable
END 
GO


