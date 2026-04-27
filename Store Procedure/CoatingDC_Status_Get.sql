USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[CoatingDC_Status_Get]    Script Date: 27-04-2026 11:12:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER PROCEDURE [dbo].[CoatingDC_Status_Get]                               
    @DC_Id INT = 0         
AS                                                  
    SET nocount ON                                              
     
  
 select 'All' AS DCStatus  
     Union All   
select    distinct      CASE                 
             WHEN DC_Mst.CODC_Type = 'D' THEN 'Draft'                        
    WHEN DC_Mst.CODC_Type = 'C' THEN 'Cancel'                        
    WHEN DC_Mst.CODC_Type = 'F' THEN 'Open'                        
             ELSE DC_Mst.CODC_Type             
           END  AS DCStatus   from DC_Mst  
   
GO


