USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Rigths_Ins]    Script Date: 27-04-2026 11:28:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Rigths_Ins]                                          
@DT Tbl_DprRightDetail READONLY,                                                 
@Emp_Id INT,               
@RetVal INT = 0 OUT,                
@RetMsg VARCHAR(MAX) = '' OUT                 
              
AS                
              
SET NOCOUNT ON                
              
DELETE FROM [dbo].M_DPR_Rigths  
WHERE [dbo].[M_DPR_Rigths].Emp_Id = @Emp_Id  
      
DECLARE @Project_Id INT = 0, @Fabrication BIT = 0, @Panel_Dispatch BIT = 0, @Assemble BIT = 0, @Glazing BIT = 0, @Installation BIT = 0 ,@ReleasePanel  BIT = 0
           
DECLARE Purchase_CUR CURSOR FOR                               
    SELECT Project_Id,Fabrication, Panel_Dispatch, Assemble, Glazing, Installation, ReleasePanel FROM @DT;                                                 
              
OPEN Purchase_CUR                                          
FETCH NEXT FROM Purchase_CUR INTO @Project_Id, @Fabrication, @Panel_Dispatch, @Assemble, @Glazing, @Installation, @ReleasePanel   
              
WHILE @@FETCH_STATUS = 0                                               
BEGIN                                       
    INSERT INTO [dbo].[M_DPR_Rigths]  
        ([Project_Id], [Emp_Id], [Fabrication], [Panel_Dispatch], [Assemble], [Glazing], [Installation], [ReleasePanel])  
    VALUES  
        (@Project_Id, @Emp_Id, @Fabrication, @Panel_Dispatch, @Assemble, @Glazing, @Installation, @ReleasePanel)  
              
    FETCH NEXT FROM Purchase_CUR INTO @Project_Id, @Fabrication, @Panel_Dispatch, @Assemble, @Glazing, @Installation, @ReleasePanel
END                                   
CLOSE Purchase_CUR;                                                  
DEALLOCATE Purchase_CUR;   
      
SET @RetMsg = 'Menu Rights Assigned Successfully.';               
SET @RetVal = SCOPE_IDENTITY();

GO


