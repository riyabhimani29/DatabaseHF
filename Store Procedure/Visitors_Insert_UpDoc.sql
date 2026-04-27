USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Visitors_Insert_UpDoc]    Script Date: 27-04-2026 15:08:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Visitors_Insert_UpDoc] @VisitorsId   INT,     
                                      @MAC_Add         VARCHAR(500),            
                                      @Entry_User      INT,            
                                      @Upd_User        INT,            
                                      @Year_Id         INT,            
                                      @Branch_ID       INT,            
                                      @RetVal          INT = 0 out,            
                                      @RetMsg          VARCHAR(max) = '' out   ,            
                                      @_ImageName          VARCHAR(max) = '' out         
AS            
    SET nocount ON            
            
    BEGIN    
	
   set @_ImageName = CONVERT(varchar(100), CONVERT(numeric(38,0),  REPLACE(REPLACE(REPLACE(REPLACE( SYSUTCDATETIME(),'-',''),' ',''),':',''),'.',''))   ) +'.png'           
 
		 INSERT INTO [dbo].[Visitors_Digital] WITH(rowlock)       
           ( [VisitorsId]
           ,[FileName]
           ,[Is_Active]
           ,[Entry_User]
           ,[Entry_Date])
     VALUES
           (@VisitorsId
           ,@_ImageName
           ,1
           ,@Upd_User
           ,dbo.Get_sysdate())
		 
                 
            
          SET @RetMsg = 'Description Create Sucessfully , Generate Hifab Code is "' + (select top 1 VisitorsNo from Visitors  WITH(nolock)  where VisitorsId = @VisitorsId) + '" !!!'            
          SET @RetVal = Scope_identity()            
 
     
    IF @@ERROR <> 0            
            BEGIN            
                SET @RetVal = 0 -- 0 IS FOR ERROR                                      
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'            
            END            
      END            
 
GO


