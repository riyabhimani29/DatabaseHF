USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Master_Insert]    Script Date: 27-04-2026 12:38:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  
ALTER PROCEDURE [dbo].[M_Master_Insert]  
 @Master_Id int,  
 @Ref_Id int,  
 @Master_Type varchar(500),  
 @Master_Vals varchar(500),  
 @Master_NumVals numeric(18,3),  
 @Is_Active bit,  
 @Remark varchar(500),  
 @MAC_Add varchar(500),  
 @Entry_User int,   
 @Upd_User int,   
 @Year_Id int,  
 @Branch_ID int,  
 @RetVal INT = 0 OUT,    
 @RetMsg varchar(max) = '' OUT   
  
  
AS  
  
SET NOCOUNT ON  
  
 IF (@Master_Id = 0)  
 begin  
    
   IF   EXISTS(select 1 from M_Master With (NOLOCK) WHERE Master_Vals =   @Master_Vals  AND Master_Type = @Master_Type)  
   BEGIN  
      SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.     
      SET @RetMsg ='Same Master Name Exist , Please Enter Other Name.'    
      Return  
   End  
    
   INSERT INTO M_Master WITH(ROWLOCK) (  
   Ref_Id ,Master_Type ,Master_Vals ,Master_NumVals ,Is_Active ,Remark ,MAC_Add ,Entry_User ,Entry_Date ,Year_Id ,Branch_ID )  
   VALUES(  
   @Ref_Id ,@Master_Type ,@Master_Vals ,@Master_NumVals ,@Is_Active ,@Remark ,@MAC_Add ,@Entry_User ,dbo.Get_Sysdate() ,@Year_Id ,@Branch_ID )  
  
  SET @RetMsg ='Master Create Sucessfully.'   
  SET @RetVal = SCOPE_IDENTITY()  
  IF @@ERROR <>  0  
   BEGIN  
    SET @RetVal = 0 -- 0 IS FOR ERROR  
      SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'      
      Return  
   End  
   Return  
 end    
 begin     
  IF NOT EXISTS(select 1 from M_Master With (NOLOCK) WHERE   Master_Id = @Master_Id)  
   BEGIN  
    SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.    
      SET @RetMsg ='Entry Not Exist , .'    
    Return  
   End  
  
  IF   EXISTS(select 1 from M_Master With (NOLOCK) WHERE  Master_Vals =   @Master_Vals  AND Master_Type = @Master_Type and  Master_Id <> @Master_Id )  
   BEGIN  
    SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.    
      SET @RetMsg ='Same Master Name Exist , Please Enter Other Name.'    
    Return  
   End   
  
  UPDATE M_Master WITH (ROWLOCK)  
  SET Ref_Id = @Ref_Id  
   ,Master_Type = @Master_Type  
   ,Master_Vals = @Master_Vals  
   ,Master_NumVals = @Master_NumVals  
   ,Is_Active = @Is_Active  
   ,Remark = @Remark   
   ,Upd_User = @Upd_User  
   ,Upd_Date = dbo.Get_Sysdate()   
  WHERE Master_Id = @Master_Id  
  
  IF @@ERROR =  0  
  BEGIN  
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED  
   SET @RetMsg ='Master Details Update Successfully.'   
  End  
  ELSE  
  BEGIN  
   SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED      
    SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'       
  End  
  
 end   
GO


