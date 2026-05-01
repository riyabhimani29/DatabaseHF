USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_Close]    Script Date: 01-05-2026 10:43:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


                                 
ALTER PROCEDURE [dbo].[PO_MST_Close] @PO_Id    INT,
                                            @Remark   VARCHAR(500),
                                            @Upd_User INT,
                                            @RetVal   INT = 0 out,
                                            @RetMsg   VARCHAR(max) = '' out
AS
    SET nocount ON

    UPDATE po_mst WITH (rowlock)
    SET   upd_user = @Upd_User,
           upd_date = dbo.Get_sysdate()
    WHERE  po_id = @PO_Id
           AND po_type <> 'C' AND PO_Type <> 'D'

    UPDATE PO_DTL WITH (rowlock)
    SET PendingQty = 0 
    WHERE PO_Id = @PO_Id

    IF @@ERROR = 0
      BEGIN
          SET @RetMsg ='Raise PO Closed Successfully.'
          SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED  
      END
    ELSE
      BEGIN
          SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
          SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED  
      END
GO


