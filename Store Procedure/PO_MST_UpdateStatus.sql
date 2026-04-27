USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_UpdateStatus]    Script Date: 27-04-2026 14:28:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                 
ALTER PROCEDURE [dbo].[PO_MST_UpdateStatus] @PO_Id    INT,
                                            @PO_Type  VARCHAR(50),
                                            @Remark   VARCHAR(500),
                                            @Upd_User INT,
                                            @RetVal   INT = 0 out,
                                            @RetMsg   VARCHAR(max) = '' out
AS
    SET nocount ON

    UPDATE po_mst WITH (rowlock)
    SET    po_type = @PO_Type,
           upd_user = @Upd_User,
           upd_date = dbo.Get_sysdate(),
           remark = remark + ' | ' + @Remark
    WHERE  po_id = @PO_Id
           AND po_type <> 'C'

    IF @@ERROR = 0
      BEGIN
          SET @RetMsg ='Raise PO Status Update Successfully.'
          SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED  
      END
    ELSE
      BEGIN
          SET @RetMsg ='Error Occurred - ' + Error_message() + '.'
          SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED  
      END 
GO


