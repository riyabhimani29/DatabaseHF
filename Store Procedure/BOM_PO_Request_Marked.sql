USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[BOM_PO_Request_Marked]    Script Date: 27-04-2026 10:56:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	ALTER PROCEDURE [dbo].[BOM_PO_Request_Marked]
    @Id INT,
    @RetVal         INT = 0 out,
    @RetMsg         VARCHAR(max) = '' out
AS
BEGIN
    SET NOCOUNT ON;
    
    	  UPDATE BOM_PO_Request SET Is_read = 1 WHERE BOM_PO_Req_Id = @Id
        SET @RetVal = 201;
        SET @RetMsg = 'Successfully remarked.';
END;
GO


