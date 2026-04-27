USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Supplier_GetMstDtlList]    Script Date: 27-04-2026 12:46:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Supplier_GetMstDtlList]    
    @Dept_ID       INT = 0,         
    @Type          INT = 0,    
    @SearchParam   VARCHAR(8000) = ''             
AS             
BEGIN
    SET NOCOUNT ON;

    -- Master supplier list with department names from comma-separated Dept_IDs
    SELECT 
        S.supplier_id,  
        S.supplier_name,  
        S.contact_person,  
        S.email_id,  
        S.contact_no,  
        S.pan_no,  
        S.gst_no,  
        S.address,  
        S.pin_code,  
        S.country_id,  
        C.master_vals AS CountryName,  
        S.state_id,  
        St.master_vals AS StateName,  
        S.city_id,  
        Ct.master_vals AS CityName,  
        S.is_active,  
        S.remark,  
        S.dept_id,  
        D.dept_name,
        S.Dept_IDs,
        -- Concatenated department names from Dept_IDs
        Dept_Names = STUFF((
            SELECT ', ' + D2.dept_name
            FROM STRING_SPLIT(S.Dept_IDs, ',') AS x
            JOIN m_department D2 ON TRY_CAST(x.value AS INT) = D2.dept_id
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
    FROM dbo.m_supplier S WITH (NOLOCK)
    LEFT JOIN m_department D WITH (NOLOCK) ON D.dept_id = S.dept_id
    LEFT JOIN m_master C WITH (NOLOCK) ON S.country_id = C.master_id
    LEFT JOIN m_master St WITH (NOLOCK) ON S.state_id = St.master_id
    LEFT JOIN m_master Ct WITH (NOLOCK) ON S.city_id = Ct.master_id
    WHERE 
        (@Dept_ID = 0 OR ',' + S.Dept_IDs + ',' LIKE '%,' + CAST(@Dept_ID AS VARCHAR) + ',%')
        AND S.Is_Active = CASE WHEN @Type = 0 THEN S.Is_Active ELSE 1 END
    ORDER BY S.entry_date DESC;

    -- Detail list
    SELECT 
        ROW_NUMBER() OVER (PARTITION BY SD.supplier_id ORDER BY SD.supplier_id) AS SrNo,  
        SD.supdetail_id,  
        SD.supplier_id,  
        SD.supitem_code,  
        SD.item_id,  
        I.item_name,  
        I.hsn_code,  
        I.item_code,  
        IC.item_cate_name,  
        IG.item_group_name,  
        I.item_cate_id,  
        I.item_group_id,  
        SD.is_active,  
        SD.itemremark  
    FROM M_SupplierDtl SD WITH (NOLOCK)  
    LEFT JOIN M_Item I WITH (NOLOCK) ON SD.item_id = I.item_id  
    LEFT JOIN M_Supplier S WITH (NOLOCK) ON SD.supplier_id = S.supplier_id
    LEFT JOIN m_item_group IG WITH (NOLOCK) ON I.item_group_id = IG.item_group_id  
    LEFT JOIN m_item_category IC WITH (NOLOCK) ON I.item_cate_id = IC.item_cate_id  
    WHERE 
        (@Dept_ID = 0 OR ',' + S.Dept_IDs + ',' LIKE '%,' + CAST(@Dept_ID AS VARCHAR) + ',%')
        AND S.Is_Active = CASE WHEN @Type = 0 THEN S.Is_Active ELSE 1 END
END
GO


