USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Department_Insert]    Script Date: 27-04-2026 11:54:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Department_Insert]  
 @Dept_ID int,  
 @Dept_Name varchar(500),  
 @Dept_Short_Name varchar(500),  
 @Is_Active bit,  
 @Remark varchar(500),  
 @Dis_Order int,  
 @MAC_Add varchar(500),  
 @Entry_User int,   
 @Upd_User int,   
 @Year_Id int,  
 @Branch_ID int,  
@RetVal INT = 0 OUT,    
@RetMsg varchar(max) = '' OUT   
  
AS  
  
SET NOCOUNT ON  
   
 IF (@Dept_ID = 0)  
 begin  
    
   IF   EXISTS(select 1 from M_Department With (NOLOCK) WHERE Dept_Name = UPPER( @Dept_Name) )  
   BEGIN  
      SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.     
      SET @RetMsg ='Same Department Name Exist ,Please Enter Other Name.'    
      Return  
   End  
  
   IF   EXISTS(select 1 from M_Department With (NOLOCK) WHERE Dept_Short_Name = UPPER(@Dept_Short_Name))  
   BEGIN  
      SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.  
      SET @RetMsg ='Same Department Short Name Exist ,Please Enter Other Short Name.'    
      Return  
   End  
  
   INSERT INTO M_Department WITH(ROWLOCK) (  
    Dept_Name ,Dept_Short_Name ,Is_Active ,Remark ,Dis_Order ,MAC_Add ,Entry_User ,Entry_Date  ,Year_Id ,Branch_ID )  
   VALUES(  
       UPPER( @Dept_Name) ,UPPER(@Dept_Short_Name) ,@Is_Active ,@Remark ,@Dis_Order ,@MAC_Add ,@Entry_User ,dbo.Get_Sysdate()   ,@Year_Id ,@Branch_ID  
   )  
     
  SET @RetMsg ='Department Create Sucessfully.'   
  SET @RetVal = SCOPE_IDENTITY()  
  IF @@ERROR <>  0  
   BEGIN  
    SET @RetVal = 0 -- 0 IS FOR ERROR  
      SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'      
   End  
 end   
 else   
 begin     
  IF NOT EXISTS(select 1 from M_Department With (NOLOCK) WHERE   Dept_ID = @Dept_ID)  
   BEGIN  
    SET @RetVal = -2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.  
      SET @RetMsg ='Entry Not Exist , .'    
    Return  
   End  
  
  IF   EXISTS(select 1 from M_Department With (NOLOCK) WHERE Dept_Name = UPPER( @Dept_Name) and  Dept_ID <> @Dept_ID )  
   BEGIN  
    SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.    
      SET @RetMsg ='Same Department Name Exist ,Please Enter Other Name.'    
    Return  
   End  
  
   IF   EXISTS(select 1 from M_Department With (NOLOCK) WHERE Dept_Short_Name = UPPER(@Dept_Short_Name)  and  Dept_ID <> @Dept_ID )  
   BEGIN  
    SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.  
      SET @RetMsg ='Same Department Short Name Exist ,Please Enter Other Short Name.'   
    Return  
   End  
       
  UPDATE M_Department WITH (ROWLOCK)  
  SET  
    Dept_Name = @Dept_Name  
   ,Dept_Short_Name = @Dept_Short_Name  
   ,Is_Active = @Is_Active  
   ,Remark = @Remark  
   ,Dis_Order = @Dis_Order   
   ,Upd_User = @Upd_User  
   ,Upd_Date =dbo.Get_Sysdate()  
  WHERE Dept_ID = @Dept_ID  
  
  IF @@ERROR =  0  
  BEGIN  
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED  
   SET @RetMsg ='Department Details Update Successfully.'   
  End  
  ELSE  
  BEGIN  
   SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED      
     SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'        
  End  
  
 end   
GO


