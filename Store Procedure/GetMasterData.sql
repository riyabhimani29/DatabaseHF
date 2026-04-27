USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GetMasterData]    Script Date: 27-04-2026 11:32:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

   
ALTER PROCEDURE [dbo].[GetMasterData] @SearchParam VARCHAR(500)='',
                                       @Ref_Id      INT = 0
AS
    SET nocount ON

    IF ( @SearchParam = '' )
      BEGIN
          SELECT master_id,
                 ref_id,
                 master_type,
                 master_vals,
                 master_numvals,
                 is_active,
                 remark
          FROM   m_master WITH (nolock)
          WHERE
            -- Master_Type IN ( select items from  dbo.STSplit (@SearchParam) )    
            master_type = CASE
                            WHEN @SearchParam = '' THEN master_type
                            ELSE @SearchParam
                          END
            AND ref_id = CASE
                           WHEN @Ref_Id = 0 THEN ref_id
                           ELSE @Ref_Id
                         END
          ORDER  BY m_master.entry_date DESC
      END
    ELSE
      BEGIN
          SELECT master_id,
                 ref_id,
                 master_type,
                 master_vals,
                 master_numvals,
                 is_active,
                 remark
          FROM   m_master WITH (nolock)
          WHERE  master_type IN (SELECT items
                                 FROM   dbo.Stsplit (@SearchParam))
                 --Master_Type = case when @SearchParam ='' then Master_Type else  @SearchParam end                
                 AND ref_id = CASE
                                WHEN @Ref_Id = 0 THEN ref_id
                                ELSE @Ref_Id
                              END
          ORDER  BY m_master.entry_date DESC
      END 
GO


