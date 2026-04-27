USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetStockView]    Script Date: 27-04-2026 11:33:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[GetStockView] @Dept_ID       INT = 1,  
                                         @Item_Group_Id INT =0,  
                                         @Item_Cate_Id  INT =0,  
  
                                         --@Supplier_Id int =0,                                                                           
                                         @Godown_Id     INT =0,  
                                         @Type          INT = 0,  
                                         @SType         CHAR='N',
                                         @ViewType VARCHAR(10) = 'D',
                                         @FilterDate    DATE = '9999-12-31' 

AS  
    SET nocount ON  
IF ( @ViewType = 'S' )
BEGIN

     if ( @Type = 1 )
BEGIN
 SELECT
        MIN(StockView.id) AS id,  
        StockView.item_id,
        m_item.item_name AS [Description],
        MIN(StockView.Godown_Id) AS Godown_Id,
        MIN(m_godown.godown_name) AS godown_name,
        MIN(m_item.item_group_id) AS item_group_id,
        MIN(m_item_group.item_group_name) AS item_group_name,
        MIN(m_item.item_cate_id) AS item_cate_id,
        MIN(m_item_category.item_cate_name) AS item_cate_name,
        MIN(m_item.item_code) AS item_code,
        MIN(m_item.hsn_code) AS hsn_code,
        SUM(StockView.total_qty) AS total_qty,
        SUM(StockView.sales_qty) AS sales_qty,
        SUM(StockView.pending_qty) AS pending_qty,
        MIN(StockView.[length]) AS [length],
        MIN(Tbl_Unit.master_vals) AS UnitName,
        MIN(m_item.unit_id) AS unit_id,
        MIN(CASE WHEN StockView.stype = 'C' THEN 'Coated' ELSE 'Non-Coated' END) AS SType,
        MIN(m_item.total_parameter) AS total_parameter,
        MIN(m_item.coated_area) AS coated_area,
        MIN(m_item.noncoated_area) AS noncoated_area,
        MIN(m_item.calc_area) AS calc_area,
        MIN(m_item.weight_mtr) AS weight_mtr,
        MIN(lastupdate) AS lastupdate,
        MIN(ISNULL(m_item.thickness,0)) AS thickness,
        MIN(KK.field_id) AS field_id,
        CONVERT(NUMERIC(18,2),
            CASE
                WHEN MIN(KK.field_id) IS NOT NULL THEN 
                    SUM(ISNULL(m_item.weight_mtr,0) * ISNULL(StockView.[length],0) * ISNULL(StockView.pending_qty,0) * ISNULL(m_item.thickness,0))/1000
                ELSE
                    SUM(ISNULL(m_item.weight_mtr,0) * ISNULL(StockView.[length],0) * ISNULL(StockView.pending_qty,0))/1000
            END
        ) AS TotalWeight,
        MIN(StockView.Width) AS Width,
        MIN(StockView.RackNo) AS RackNo,
        MIN(StockView.Remark) AS Remark,
        MIN(M_Godown_Rack.Rack_Name) AS Rack_Name,
        MIN(StockView.Rack_Id) AS Rack_Id,
        CASE 
            WHEN @Dept_ID = 3 THEN CONVERT(NUMERIC(18,2), SUM(ISNULL(StockView.Width,0)*ISNULL(StockView.[length],0)*ISNULL(StockView.pending_qty,0))/1000000)
            ELSE 0
        END AS Area,
        '' AS Project_Name,
        MIN(M_Item.Alternate_Unit_Id) AS Alternate_Unit_Id,
        MIN(M_Item.AlternateUnitValue) AS AlternateUnitValue,
        MIN(unit.Master_Vals) AS unit,
        MIN(alternate_unit.Master_Vals) AS alternate_unit,
        MIN(Stk_Limit) AS Stk_Limit
    FROM StockView WITH (NOLOCK)
    LEFT JOIN m_godown WITH (NOLOCK) ON StockView.godown_id = m_godown.godown_id
    LEFT JOIN M_Godown_Rack WITH (NOLOCK) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id
    LEFT JOIN m_item WITH (NOLOCK) ON StockView.item_id = m_item.item_id
    LEFT JOIN M_Master AS unit ON m_item.unit_id = unit.Master_Id
    LEFT JOIN M_Master AS alternate_unit ON m_item.Alternate_Unit_Id = alternate_unit.Master_Id
    LEFT JOIN m_item_group WITH (NOLOCK) ON m_item.item_group_id = m_item_group.item_group_id
    OUTER APPLY (
        SELECT m_group_field_setting.field_id
        FROM m_group_field_setting WITH (NOLOCK)
        WHERE m_group_field_setting.field_id = 1
        AND m_item.item_group_id = m_group_field_setting.item_group_id
    ) AS KK
    LEFT JOIN m_item_category WITH (NOLOCK) ON m_item.item_cate_id = m_item_category.item_cate_id
    LEFT JOIN m_master AS Tbl_Unit WITH (NOLOCK) ON m_item.unit_id = Tbl_Unit.master_id
    WHERE StockView.item_id <> 0
        AND StockView.pending_qty <= 0
        AND m_item_group.dept_id = (CASE WHEN @Dept_ID = 0 THEN m_item_group.dept_id ELSE @Dept_ID END)
        AND StockView.godown_id = (CASE WHEN @Godown_Id = 0 THEN StockView.godown_id ELSE @Godown_Id END)
        AND StockView.stype = (CASE WHEN @SType = 'A' THEN StockView.stype ELSE @SType END)
        AND StockView.LastUpdate <= @FilterDate
    GROUP BY StockView.item_id, m_item.item_name
END
ELSE
BEGIN
    SELECT
        MIN(StockView.id) AS id,  
        StockView.item_id,
        m_item.item_name AS [Description],
        MIN(StockView.Godown_Id) AS Godown_Id,
        MIN(m_godown.godown_name) AS godown_name,
        MIN(m_item.item_group_id) AS item_group_id,
        MIN(m_item_group.item_group_name) AS item_group_name,
        MIN(m_item.item_cate_id) AS item_cate_id,
        MIN(m_item_category.item_cate_name) AS item_cate_name,
        MIN(m_item.item_code) AS item_code,
        MIN(m_item.hsn_code) AS hsn_code,
        SUM(StockView.total_qty) AS total_qty,
        SUM(StockView.sales_qty) AS sales_qty,
        SUM(StockView.pending_qty) AS pending_qty,
        MIN(StockView.[length]) AS [length],
        MIN(Tbl_Unit.master_vals) AS UnitName,
        MIN(m_item.unit_id) AS unit_id,
        MIN(CASE WHEN StockView.stype = 'C' THEN 'Coated' ELSE 'Non-Coated' END) AS SType,
        MIN(m_item.total_parameter) AS total_parameter,
        MIN(m_item.coated_area) AS coated_area,
        MIN(m_item.noncoated_area) AS noncoated_area,
        MIN(m_item.calc_area) AS calc_area,
        MIN(m_item.weight_mtr) AS weight_mtr,
        MIN(lastupdate) AS lastupdate,
        MIN(ISNULL(m_item.thickness,0)) AS thickness,
        MIN(KK.field_id) AS field_id,
        CONVERT(NUMERIC(18,2),
            CASE
                WHEN MIN(KK.field_id) IS NOT NULL THEN 
                    SUM(ISNULL(m_item.weight_mtr,0) * ISNULL(StockView.[length],0) * ISNULL(StockView.pending_qty,0) * ISNULL(m_item.thickness,0))/1000
                ELSE
                    SUM(ISNULL(m_item.weight_mtr,0) * ISNULL(StockView.[length],0) * ISNULL(StockView.pending_qty,0))/1000
            END
        ) AS TotalWeight,
        MIN(StockView.Width) AS Width,
        MIN(StockView.RackNo) AS RackNo,
        MIN(StockView.Remark) AS Remark,
        MIN(M_Godown_Rack.Rack_Name) AS Rack_Name,
        MIN(StockView.Rack_Id) AS Rack_Id,
        CASE 
            WHEN @Dept_ID = 3 THEN CONVERT(NUMERIC(18,2), SUM(ISNULL(StockView.Width,0)*ISNULL(StockView.[length],0)*ISNULL(StockView.pending_qty,0))/1000000)
            ELSE 0
        END AS Area,
        '' AS Project_Name,
        MIN(M_Item.Alternate_Unit_Id) AS Alternate_Unit_Id,
        MIN(M_Item.AlternateUnitValue) AS AlternateUnitValue,
        MIN(unit.Master_Vals) AS unit,
        MIN(alternate_unit.Master_Vals) AS alternate_unit,
        MIN(Stk_Limit) AS Stk_Limit
    FROM StockView WITH (NOLOCK)
    LEFT JOIN m_godown WITH (NOLOCK) ON StockView.godown_id = m_godown.godown_id
    LEFT JOIN M_Godown_Rack WITH (NOLOCK) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id
    LEFT JOIN m_item WITH (NOLOCK) ON StockView.item_id = m_item.item_id
    LEFT JOIN M_Master AS unit ON m_item.unit_id = unit.Master_Id
    LEFT JOIN M_Master AS alternate_unit ON m_item.Alternate_Unit_Id = alternate_unit.Master_Id
    LEFT JOIN m_item_group WITH (NOLOCK) ON m_item.item_group_id = m_item_group.item_group_id
    OUTER APPLY (
        SELECT m_group_field_setting.field_id
        FROM m_group_field_setting WITH (NOLOCK)
        WHERE m_group_field_setting.field_id = 1
        AND m_item.item_group_id = m_group_field_setting.item_group_id
    ) AS KK
    LEFT JOIN m_item_category WITH (NOLOCK) ON m_item.item_cate_id = m_item_category.item_cate_id
    LEFT JOIN m_master AS Tbl_Unit WITH (NOLOCK) ON m_item.unit_id = Tbl_Unit.master_id
    WHERE StockView.item_id <> 0
        AND StockView.pending_qty > 0
        AND m_item_group.dept_id = (CASE WHEN @Dept_ID = 0 THEN m_item_group.dept_id ELSE @Dept_ID END)
        AND StockView.godown_id = (CASE WHEN @Godown_Id = 0 THEN StockView.godown_id ELSE @Godown_Id END)
        AND StockView.stype = (CASE WHEN @SType = 'A' THEN StockView.stype ELSE @SType END)
        AND StockView.LastUpdate <= @FilterDate
    GROUP BY StockView.item_id, m_item.item_name
    END
END




    if ( @Type = 1 ) /* Zero Stock SHow*/  
      begin   
    SELECT StockView.id,  
        StockView.Godown_Id,  
        m_godown.godown_name,  
        m_item.item_group_id,  
        m_item_group.item_group_name,  
        m_item.item_cate_id,  
        m_item_category.item_cate_name,  
        StockView.item_id,  
        m_item.item_name                    AS [Description],  
        m_item.item_code,  
        m_item.hsn_code,  
        StockView.total_qty,  
        StockView.sales_qty,  
        StockView.pending_qty,  
        StockView.[length],  
        Tbl_Unit.master_vals                AS UnitName,  
        m_item.unit_id,  
        CASE  
       WHEN StockView.stype = 'C' THEN 'Coated'  
       ELSE 'Non-Coated'  
        END                                 SType,  
        m_item.[total_parameter],  
        m_item.[coated_area],  
        m_item.[noncoated_area],  
        m_item.[calc_area],  
        m_item.[weight_mtr],  
         m_item.ImageName,
        lastupdate,  
        --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *                                     
        --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                                    
        Isnull(m_item.thickness, 0)         thickness,  
        KK.field_id,  
        convert (NUMERIC(18, 2), (( CASE  
              WHEN KK.field_id IS NOT NULL THEN ( (  
              Isnull(m_item.[weight_mtr], 0) * Isnull (StockView.[length], 0) * Isnull( StockView.pending_qty, 0) *  
              Isnull(m_item.thickness, 0) ) / 1000 )  
              /* Is Width */  
              ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
                 Isnull( StockView.[length], 0) *  
                 Isnull( StockView.pending_qty, 0)  
               ) / 1000 )  
               END ))) AS TotalWeight,  
        m_item.item_group_id,  
        StockView.Width,  
        StockView.RackNo,  
        StockView.Remark,  
        M_Godown_Rack.Rack_Name,  
        StockView.Rack_Id,  
        case  
       when @Dept_ID = 3 then convert (NUMERIC(18, 2),  
            ( Isnull(StockView.Width, 0) * Isnull(StockView.[length], 0) *  
            Isnull( StockView.pending_qty, 0) ) / 1000000)  
       /* --width * heigth * quantity  */  
       else 0  
        end                                 Area,  
        Tbl_Stk.Project_Name  ,
        M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        M_Item.Item_Rate as Rate
    FROM   StockView WITH (nolock)  
        outer apply (select distinct GRN_Dtl.Stock_Id,  
             M_Project.Project_Name  
         from   GRN_Dtl  
             left join PO_DTL WITH (nolock) On GRN_Dtl.PODtl_Id = PO_DTL.PODtl_Id  
             left join PO_MST WITH (nolock) On PO_DTL.PO_Id = PO_MST.PO_Id  
             left join M_Project WITH (nolock) On PO_DTL.Project_Id = M_Project.Project_Id  
         where  GRN_Dtl.Stock_Id = StockView.Id  
             and PO_MST.Dept_ID = 3  
           /* Only glass  Dept */  
           )as Tbl_Stk  
        LEFT JOIN m_godown WITH (nolock) ON StockView.godown_id = m_godown.godown_id  
        LEFT JOIN M_Godown_Rack WITH (nolock) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id  
        LEFT JOIN m_item WITH (nolock) ON StockView.item_id = m_item.item_id 
             LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
        LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
        OUTER apply (SELECT m_group_field_setting.field_id  
         FROM   m_group_field_setting WITH (nolock)  
         WHERE  m_group_field_setting.field_id = 1  
             --  Only 'Width' Entry                       
             AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK  
        LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
        LEFT JOIN m_master AS Tbl_Unit WITH (nolock) ON m_item.unit_id = Tbl_Unit.master_id  
    WHERE  StockView.pending_qty <= 0  
        AND StockView.item_id <> 0  
        --  StockView.pending_qty <> 0                             
        and m_item_group.dept_id = ( CASE  
               WHEN @Dept_ID = 0 THEN  m_item_group.dept_id  
               ELSE @Dept_ID  
             END )  
        AND StockView.godown_id = ( CASE  
              WHEN @Godown_Id = 0 THEN StockView.godown_id  
              ELSE @Godown_Id  
               END )  
        AND StockView.stype = ( CASE  
             WHEN @SType = 'A' THEN StockView.stype  
             ELSE @SType  
              END )   
      --  ORDER  BY LastUpdate DESC--m_item.item_code           
      end  
    else if ( @Type = -1 ) /* All Stock SHow*/  
      begin   
   SELECT StockView.id,  
     StockView.Godown_Id,  
     m_godown.godown_name,  
     m_item.item_group_id,  
     m_item_group.item_group_name,  
     m_item.item_cate_id,  
     m_item_category.item_cate_name,  
     StockView.item_id,  
     m_item.item_name                    AS [Description],  
     m_item.item_code,  
     m_item.hsn_code,  
     StockView.total_qty,  
     StockView.sales_qty,  
     StockView.pending_qty,  
     StockView.[length],  
     Tbl_Unit.master_vals                AS UnitName,  
     m_item.unit_id,  
     CASE  
      WHEN StockView.stype = 'C' THEN 'Coated'  
      ELSE 'Non-Coated'  
     END                                 SType,  
     m_item.[total_parameter],  
     m_item.[coated_area],  
     m_item.[noncoated_area],  
     m_item.[calc_area],  
     m_item.[weight_mtr],
     m_item.ImageName,
     lastupdate,  
     --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *                                     
     --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,                                    
     Isnull(m_item.thickness, 0)         thickness,  
     KK.field_id,  
     convert (NUMERIC(18, 2), (( CASE  
             WHEN KK.field_id IS NOT NULL THEN ( (  
             Isnull(m_item.[weight_mtr], 0) * Isnull  
             (StockView.[length], 0) * Isnull (  
             StockView.pending_qty, 0) *  
             Isnull(m_item.thickness, 0) ) / 1000 )  
             /* Is Width */  
             ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
               Isnull( StockView.[length], 0) *  
               Isnull( StockView.pending_qty, 0)  
              ) /  
              1000 )  
            END ))) AS TotalWeight,  
     m_item.item_group_id,  
     StockView.Width,  
     StockView.RackNo,  
     StockView.Remark,  
     M_Godown_Rack.Rack_Name,  
     StockView.Rack_Id,  
     case  
      when @Dept_ID = 3 then convert (NUMERIC(18, 2),  
           ( Isnull(StockView.Width, 0) * Isnull(StockView.[length], 0) *  
            Isnull( StockView.pending_qty, 0) ) / 1000000)  
      /* --width * heigth * quantity */  
      else 0  
     end                                 AS Area,  
     ''                                  AS Project_Name  ,
     M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        M_Item.Item_Rate as Rate
   --Tbl_Stk.Project_Name    
   FROM   StockView WITH (nolock)   
     LEFT JOIN m_godown WITH (nolock) ON StockView.godown_id = m_godown.godown_id  
     LEFT JOIN M_Godown_Rack WITH (nolock) ON StockView.Rack_Id = M_Godown_Rack.Rack_Id  
     LEFT JOIN m_item WITH (nolock) ON StockView.item_id = m_item.item_id  
          LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
     LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
     OUTER apply (SELECT m_group_field_setting.field_id  
        FROM   m_group_field_setting WITH (nolock)  
        WHERE  m_group_field_setting.field_id = 1  
          /*--  Only 'Width' Entry */  
          AND m_item.item_group_id = m_group_field_setting.item_group_id) AS KK  
     LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
     LEFT JOIN m_master AS Tbl_Unit WITH (nolock) ON m_item.unit_id = Tbl_Unit.master_id  
   WHERE   StockView.item_id <> 0  
     AND StockView.pending_qty >= 0                             
     and m_item_group.dept_id = ( CASE  
             WHEN @Dept_ID = 0 THEN m_item_group.dept_id  
             ELSE @Dept_ID  
            END )  
     AND StockView.godown_id = ( CASE  
             WHEN @Godown_Id = 0 THEN StockView.godown_id  
             ELSE @Godown_Id  
            END )  
     AND StockView.stype = ( CASE  
            WHEN @SType = 'A' THEN StockView.stype  
            ELSE @SType  
           END )         
      end  
    else  
      begin  
          if ( @Dept_ID = 3 ) /* Glass Department */  
            begin  
    SELECT stockview.id,  
        stockview.godown_id,  
        m_godown.godown_name,  
        m_item.item_group_id,  
        m_item_group.item_group_name,  
        m_item.item_cate_id,  
        m_item_category.item_cate_name,  
        stockview.item_id,  
        m_item.item_name                    AS [Description],  
        m_item.item_code,  
        m_item.hsn_code,  
        stockview.total_qty,  
        stockview.sales_qty,  
        stockview.pending_qty,  
        stockview.[length],  
        tbl_unit.master_vals                AS unitname,  
        m_item.unit_id,  
        CASE  
       WHEN stockview.stype = 'C' THEN 'Coated'  
       ELSE 'Non-Coated'  
        END                                 stype,  
        m_item.[total_parameter],  
        m_item.[coated_area],  
        m_item.[noncoated_area],  
        m_item.[calc_area],  
        m_item.[weight_mtr], 
        m_item.ImageName,
        lastupdate,  
        --( Isnull(m_item.[weight_mtr], 0) * Isnull(StockView.[length], 0) *  
        --    Isnull (StockView.pending_qty, 0) * Isnull(m_item.thickness, 0) ) / 1000 AS TotalWeight,  
        Isnull(m_item.thickness, 0)         thickness,  
        kk.field_id,  
        CONVERT (NUMERIC(18, 2), (( CASE  
              WHEN kk.field_id IS NOT NULL THEN ( (  
              Isnull(m_item.[weight_mtr], 0) * Isnull  
              (stockview.[length], 0) * Isnull (  
                stockview.pending_qty, 0) *  
              Isnull(m_item.thickness, 0) ) / 1000 )  
              /* Is Width */  
              ELSE ( ( Isnull(m_item.[weight_mtr], 0) *  
                 Isnull(  
                 stockview.[length], 0) *  
                 Isnull(  
                    stockview.pending_qty, 0)  
               ) /  
               1000 )  
               END ))) AS totalweight,  
        m_item.item_group_id,  
        stockview.width,  
        stockview.rackno,  
        stockview.remark,  
        m_godown_rack.rack_name,  
        stockview.rack_id,  
        CASE  
       WHEN @Dept_ID = 3 THEN CONVERT (NUMERIC(18, 2),  
            (  
            Isnull(stockview.width, 0) *  
            Isnull(stockview.[length], 0)  
            *  
            Isnull(  
                    stockview.pending_qty, 0)  
            )  
            /  
                    1000000)  
       /*--width * heigth * quantity           */  
       ELSE 0  
        END                                 AS area,  
        tbl_stk.project_name  ,
        M_Item.Alternate_Unit_Id,
        M_Item.AlternateUnitValue,
        unit.Master_Vals as unit,
        alternate_unit.Master_Vals as alternate_unit,
		Stk_Limit,
        M_Item.Item_Rate as Rate
    FROM   stockview WITH (nolock)  
        OUTER apply (SELECT DISTINCT grn_dtl.stock_id,  
             m_project.project_name  
         FROM   grn_dtl WITH (nolock)  
             LEFT JOIN po_dtl WITH (nolock)  ON grn_dtl.podtl_id = po_dtl.podtl_id  
             LEFT JOIN po_mst WITH (nolock) ON po_dtl.po_id = po_mst.po_id  
             LEFT JOIN m_project WITH (nolock) ON po_dtl.project_id = m_project.project_id  
         WHERE  grn_dtl.stock_id = stockview.id  
             AND po_mst.dept_id = 3  
           /* Only glass  Dept */  
           )AS tbl_stk  
        LEFT JOIN m_godown WITH (nolock) ON stockview.godown_id = m_godown.godown_id  
        LEFT JOIN m_godown_rack WITH (nolock) ON stockview.rack_id = m_godown_rack.rack_id  
        LEFT JOIN m_item WITH (nolock)  ON stockview.item_id = m_item.item_id  
             LEFT JOIN M_Master as unit ON M_Item.Unit_Id = unit.Master_Id
        LEFT JOIN M_Master as alternate_unit ON M_Item.Alternate_Unit_Id = alternate_unit.Master_Id
   
        LEFT JOIN m_item_group WITH (nolock) ON m_item.item_group_id = m_item_group.item_group_id  
        OUTER apply (SELECT m_group_field_setting.field_id  
         FROM   m_group_field_setting WITH (nolock)  
         WHERE  m_group_field_setting.field_id = 1  
             /*--  Only 'Width' Entry */  
             AND m_item.item_group_id = m_group_field_setting.item_group_id) AS kk  
        LEFT JOIN m_item_category WITH (nolock) ON m_item.item_cate_id = m_item_category.item_cate_id  
        LEFT JOIN m_master AS tbl_unit WITH (nolock) ON m_item.unit_id = tbl_unit.master_id  
    WHERE  stockview.pending_qty > 0  
        AND stockview.item_id <> 0  
        --  StockView.pending_qty <> 0  
        AND m_item_group.dept_id = ( CASE  
               WHEN @Dept_ID = 0 THEN m_item_group.dept_id  
               ELSE @Dept_ID  
             END )  
        AND stockview.godown_id = ( CASE  
              WHEN @Godown_Id = 0 THEN stockview.godown_id  
              ELSE @Godown_Id  
               END )  
        AND stockview.stype = ( CASE  
             WHEN @SType = 'A' THEN stockview.stype  
             ELSE @SType  
              END )   
            end  
          else /*************/  
            begin  
  SELECT
    StockView.id,
    StockView.Godown_Id,
    m_godown.godown_name,
    m_item.item_group_id,
    m_item_group.item_group_name,
    m_item.item_cate_id,
    m_item_category.item_cate_name,
    StockView.item_id,
    m_item.item_name AS [Description],
    m_item.item_code,
    m_item.hsn_code,
    StockView.total_qty,
    StockView.sales_qty,

    /* Adjusted Pending Qty */
    CASE
        WHEN @FilterDate <> '9999-12-31'
        THEN
            CASE
                WHEN ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0) < 0
                THEN 0
                ELSE ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0)
            END
        ELSE StockView.pending_qty
    END AS pending_qty,

    StockView.[length],
    Tbl_Unit.master_vals AS UnitName,
    m_item.unit_id,

    CASE
        WHEN StockView.stype = 'C' THEN 'Coated'
        ELSE 'Non-Coated'
    END AS SType,

    m_item.total_parameter,
    m_item.coated_area,
    m_item.noncoated_area,
    m_item.calc_area,
    m_item.weight_mtr,
    m_item.ImageName,
    StockView.lastupdate,
    ISNULL(m_item.thickness,0) AS thickness,
    KK.field_id,

    /* Total Weight */
    CONVERT(NUMERIC(18,2),
    (
        CASE
            WHEN KK.field_id IS NOT NULL
            THEN
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                            WHEN @FilterDate <> '9999-12-31'
                            THEN ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                    * ISNULL(m_item.thickness,0)
                ) / 1000
            ELSE
                (
                    ISNULL(m_item.weight_mtr,0)
                    * ISNULL(StockView.[length],0)
                    * ISNULL(
                        CASE
                            WHEN @FilterDate <> '9999-12-31'
                            THEN ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0)
                            ELSE StockView.pending_qty
                        END,0
                    )
                ) / 1000
        END
    )) AS TotalWeight,

    m_item.item_group_id,
    StockView.Width,
    StockView.RackNo,
    StockView.Remark,
    M_Godown_Rack.Rack_Name,
    StockView.Rack_Id,

    /* Area */
    CASE
        WHEN @Dept_ID = 3
        THEN CONVERT(NUMERIC(18,2),
            (
                ISNULL(StockView.Width,0)
                * ISNULL(StockView.[length],0)
                * ISNULL(
                    CASE
                        WHEN @FilterDate <> '9999-12-31'
                        THEN ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0)
                        ELSE StockView.pending_qty
                    END,0
                )
            ) / 1000000
        )
        ELSE 0
    END AS Area,

    '' AS Project_Name,
    M_Item.Alternate_Unit_Id,
    M_Item.AlternateUnitValue,
    unit.Master_Vals AS unit,
    alternate_unit.Master_Vals AS alternate_unit,
    Stk_Limit,
    M_Item.Item_Rate AS Rate

FROM StockView WITH (NOLOCK)

LEFT JOIN m_godown WITH (NOLOCK)
    ON StockView.godown_id = m_godown.godown_id

LEFT JOIN M_Godown_Rack WITH (NOLOCK)
    ON StockView.Rack_Id = M_Godown_Rack.Rack_Id

LEFT JOIN m_item WITH (NOLOCK)
    ON StockView.item_id = m_item.item_id

LEFT JOIN M_Master AS unit
    ON m_item.Unit_Id = unit.Master_Id

LEFT JOIN M_Master AS alternate_unit
    ON m_item.Alternate_Unit_Id = alternate_unit.Master_Id

LEFT JOIN m_item_group WITH (NOLOCK)
    ON m_item.item_group_id = m_item_group.item_group_id

OUTER APPLY
(
    SELECT m_group_field_setting.field_id
    FROM m_group_field_setting WITH (NOLOCK)
    WHERE m_group_field_setting.field_id = 1
      AND m_item.item_group_id = m_group_field_setting.item_group_id
) AS KK

LEFT JOIN m_item_category WITH (NOLOCK)
    ON m_item.item_cate_id = m_item_category.item_cate_id

LEFT JOIN m_master AS Tbl_Unit WITH (NOLOCK)
    ON m_item.unit_id = Tbl_Unit.master_id

/* Opening Stock History Adjustment */
OUTER APPLY
(
    SELECT
        SUM(ISNULL(OSH.Total_Qty,0)) AS OpeningQtyAfterDate
    FROM OpeningStock_History OSH WITH (NOLOCK)
    WHERE OSH.Item_Id   = StockView.item_id
      AND OSH.Godown_Id = StockView.godown_id
      AND OSH.SType     = StockView.stype
      AND ISNULL(OSH.Length,0) = ISNULL(StockView.[length],0)
      AND ISNULL(OSH.Width,0)  = ISNULL(StockView.Width,0)
      AND ISNULL(OSH.Rack_Id,0)= ISNULL(StockView.Rack_Id,0)
      AND CAST(OSH.Entry_Date AS DATE) > @FilterDate
) AS OS

WHERE
    StockView.item_id <> 0
    AND
    (
        CASE
            WHEN @FilterDate <> '9999-12-31'
            THEN ISNULL(StockView.pending_qty,0) - ISNULL(OS.OpeningQtyAfterDate,0)
            ELSE StockView.pending_qty
        END
    ) > 0
    AND m_item_group.dept_id =
        CASE
            WHEN @Dept_ID = 0 THEN m_item_group.dept_id
            ELSE @Dept_ID
        END
    AND StockView.godown_id =
        CASE
            WHEN @Godown_Id = 0 THEN StockView.godown_id
            ELSE @Godown_Id
        END
    AND StockView.stype =
        CASE
            WHEN @SType = 'A' THEN StockView.stype
            ELSE @SType
        END;
 
            end  
      -- ORDER  BY LastUpdate DESC--m_item.item_code           
      end
GO


