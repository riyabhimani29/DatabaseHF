USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[API_PROAPP_GetList]    Script Date: 27-04-2026 10:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                         
 ALTER PROCEDURE [dbo].[API_PROAPP_GetList]                        
 @PROUser_Id  int = 0   
 AS                         
    SET NOCOUNT ON       
     
  
SELECT dbo.gurukulfamily_dtl.gf_id,  
       dbo.gurukulfamily_dtl.ayojanid,  
       m_ayojan.ayojanname,  
       dbo.gurukulfamily_dtl.firstname,  
       dbo.gurukulfamily_dtl.middlename,  
       dbo.gurukulfamily_dtl.lastname,  
       dbo.gurukulfamily_dtl.mobileno,  
       dbo.gurukulfamily_dtl.birthdate,  
       dbo.gurukulfamily_dtl.area,  
       dbo.gurukulfamily_dtl.city,  
       dbo.gurukulfamily_dtl.familymemberid,  
       Tbl_Family.master_name          FamilyName,  
       dbo.gurukulfamily_dtl.membername,  
       dbo.gurukulfamily_dtl.membernos AS MemberNo1 ,  
       --,dbo.GurukulFamily_Dtl.MemberNos AS MemberNo2   
       dbo.gurukulfamily_dtl.prouser_id,  
       dbo.gurukulfamily_dtl.entrydate,  
       dbo.gurukulfamily_dtl.device_id,  
       dbo.gurukulfamily_dtl.remarks,  
       dbo.gurukulfamily_dtl.categoryid,  
       Tbl_Category.master_name        AS CategoryName  
FROM   dbo.gurukulfamily_dtl WITH (nolock)  
       LEFT JOIN m_ayojan WITH (nolock) ON gurukulfamily_dtl.ayojanid = m_ayojan.ayojanid  
       LEFT JOIN m_pro_masters AS Tbl_Family WITH (nolock)  ON gurukulfamily_dtl.familymemberid = Tbl_Family.pro_master_id  
       LEFT JOIN m_pro_masters AS Tbl_Category WITH (nolock)  ON gurukulfamily_dtl.categoryid = Tbl_Category.pro_master_id   
    where dbo.gurukulfamily_dtl.prouser_id = @PROUser_Id
	and dbo.gurukulfamily_dtl.Is_Active = 1
GO


