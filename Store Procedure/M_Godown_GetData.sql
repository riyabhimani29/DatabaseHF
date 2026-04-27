USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Godown_GetData]    Script Date: 27-04-2026 12:04:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Godown_GetData]      
 @SearchParam VARCHAR(8000) = ''
AS
    SET nocount ON

    DECLARE @SqlString NVARCHAR(max)

    SET @SqlString ='
			SELECT m_godown.godown_id,
				   m_godown.godown_typeid,
				   m_godown.godown_name,
				   Tbl_Godown_Type.master_vals AS Godown_Type,
				   m_godown.godown_address,
				   m_godown.state_id,
				   Tbl_State.master_vals       AS StateName,
				   m_godown.city_id,
				   Tbl_City.master_vals        AS CityName,
				   m_godown.is_active,
				   m_godown.remark,
				   m_godown.mac_add,
				   m_godown.entry_user,
				   m_godown.entry_date,
				   m_godown.upd_user,
				   m_godown.upd_date,
				   m_godown.year_id,
				   m_godown.branch_id
			FROM   m_godown WITH (nolock)
				   LEFT JOIN m_master AS Tbl_State WITH (nolock)
						  ON m_godown.state_id = Tbl_State.master_id
				   LEFT JOIN m_master AS Tbl_City WITH (nolock)
						  ON m_godown.city_id = Tbl_City.master_id
				   LEFT JOIN m_master AS Tbl_Godown_Type WITH (nolock)
						  ON m_godown.godown_typeid = Tbl_Godown_Type.master_id  
			  '

    IF Ltrim (Rtrim (@SearchParam)) <> ''
      BEGIN
          SET @SqlString = @SqlString + ' WHERE ' + @SearchParam
      END

    SET @SqlString = @SqlString
                     + ' ORDER BY M_Godown.Entry_Date DESC '

    EXECUTE Sp_executesql
      @SqlString 
GO


