USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[QR_Mst_GetList]    Script Date: 27-04-2026 14:33:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                  
ALTER   PROCEDURE [dbo].[QR_Mst_GetList]                                  
@Dept_ID  int  = 1  ,  
@Typ varchar(10)='OUT'  
                                  
AS                                  
                                  
SET NOCOUNT ON                                  
                      
      
if ( @Typ = 'GRN' )  
  begin  
      select a.PO_Id AS QR_Id,  
             PO_MST.OrderNo Challan_no  
      from   (select distinct QR_Dtl.PO_Id  
              from   QR_Dtl with (nolock)  
              LEFT OUTER join QR_Mst on QR_Dtl.QR_Id = QR_Mst.QR_Id
              where  Is_GRN = 0
              AND QR_Mst.Dept_ID = @Dept_ID
			  and QR_Typedtl = '') a  
             left join PO_MST with (nolock) On a.PO_Id = PO_MST.PO_Id  
      order  by PO_MST.OrderNo desc  
  end  
else  
  begin  
      select a.PO_Id AS QR_Id,  
             PO_MST.OrderNo Challan_no  
        from   (select distinct QR_Dtl.PO_Id  
              from   QR_Dtl with (nolock)  
              LEFT OUTER join QR_Mst on QR_Dtl.QR_Id = QR_Mst.QR_Id
              where  Is_GRN = 0
              AND QR_Mst.Dept_ID = @Dept_ID 
			  and QR_Typedtl = 'OUT') a  
             left join PO_MST with (nolock) On a.PO_Id = PO_MST.PO_Id  
      order  by PO_MST.OrderNo desc  
  end   
  
  
--select GlassQR_Mst.Glass_QR_Id,        
--  GlassQR_Mst.Challan_no        
--  from GlassQR_Mst with (nolock) where Dept_ID = @Dept_ID and Glass_QR_Id IN (select GlassQR_Dtl.Glass_QR_Id from  GlassQR_Dtl with (nolock) where Is_GRN = 0 ) 
GO


