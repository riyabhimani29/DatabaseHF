USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_GetGfamilyList]    Script Date: 27-04-2026 10:50:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                         
 ALTER PROCEDURE [dbo].[API_PROAPP_GetGfamilyList]   
												  @PROUser_Ids VARCHAR(500)='',
                                                  @CategoryIds VARCHAR(500)='',
                                                  @AyojanIds   VARCHAR(500)='',
                                                  @F_Date      DATE,
                                                  @T_Date      DATE
AS
    SET nocount ON

    SELECT m_ayojan.ayojanname,
           m_santonulist.santoname,
           --M_SantoNuList.MobileNo,
           m_santonulist.remark     Branch,  
           Tbl_RELATION.master_name AS Relation,
           TBL_CATEGORY.master_name AS Category,
           gurukulfamily_dtl.gf_id,
           --GurukulFamily_Dtl.AyojanId,
           gurukulfamily_dtl.firstname,
           gurukulfamily_dtl.middlename,
           gurukulfamily_dtl.lastname,
           gurukulfamily_dtl.mobileno,
           gurukulfamily_dtl.birthdate,
           gurukulfamily_dtl.area,
           gurukulfamily_dtl.city,
           -- GurukulFamily_Dtl.FamilyMemberId,
           gurukulfamily_dtl.membername,
           gurukulfamily_dtl.membernos,
           gurukulfamily_dtl.prouser_id,
           gurukulfamily_dtl.entrydate,
           gurukulfamily_dtl.device_id,
           gurukulfamily_dtl.remarks,
           gurukulfamily_dtl.categoryid
    FROM   gurukulfamily_dtl WITH(nolock)
           LEFT JOIN m_ayojan WITH(nolock) ON m_ayojan.ayojanid = gurukulfamily_dtl.ayojanid
           LEFT JOIN m_pro_masters AS Tbl_RELATION WITH(nolock) ON Tbl_RELATION.pro_master_id = gurukulfamily_dtl.familymemberid
           LEFT JOIN m_santonulist WITH(nolock) ON m_santonulist.santid = gurukulfamily_dtl.prouser_id
           LEFT JOIN m_pro_masters AS TBL_CATEGORY WITH(nolock) ON TBL_CATEGORY.pro_master_id = gurukulfamily_dtl.categoryid
    WHERE  gurukulfamily_dtl.is_active = 1
           AND ( ( @PROUser_Ids = '' )
                  OR ( @PROUser_Ids <> ''
                       AND gurukulfamily_dtl.prouser_id IN (SELECT items FROM dbo.Stsplit(@PROUser_Ids)) ) )
           AND ( ( @CategoryIds = '' )
                  OR ( @CategoryIds <> ''
                       AND gurukulfamily_dtl.categoryid IN (SELECT items FROM dbo.Stsplit(@CategoryIds)) ) )
           AND ( ( @AyojanIds = '' )
                  OR ( @AyojanIds <> ''
                       AND gurukulfamily_dtl.ayojanid IN (SELECT items FROM dbo.Stsplit(@AyojanIds)) )
               )
			   And  gurukulfamily_dtl.entrydate between @F_Date and @T_Date
    ORDER  BY m_santonulist.remark,
              m_santonulist.santid 
GO


