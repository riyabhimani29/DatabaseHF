USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Group_Category_InsUpd]    Script Date: 27-04-2026 12:09:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
ALTER PROCEDURE [dbo].[M_Group_Category_InsUpd]  
           @Category_Id int,  
           @Category_Name varchar(500),  
           @FrSrno int,  
           @ToSrno int,  
           @Is_Active bit,  
           @Dept_ID int,  
           @Remark varchar(500),  
            @MAC_Add        VARCHAR(500),  
            @Entry_User     INT,  
            @Upd_User       INT,  
            @Year_Id        INT,  
            @Branch_ID      INT,  
           @RetVal INT = 0 OUT,  
                                           @RetMsg      VARCHAR(max) = '' out  
AS  
   
SET NOCOUNT ON  
    IF ( @Category_Id = 0 )  
      BEGIN  

          IF EXISTS(SELECT 1  
                    FROM   M_Group_Category WITH (nolock)  
                    WHERE  Category_Name = @Category_Name)  
            BEGIN  
                SET @RetVal = -101  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg = 'Same Item Head Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  
       
          IF EXISTS(SELECT 1   FROM   M_Group_Category WITH (nolock)   WHERE   @FrSrno between FrSrno and ToSrno)  
            BEGIN  
                SET @RetVal = -102  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg = 'From Sr.No Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  

          IF EXISTS(SELECT 1  
                    FROM   M_Group_Category WITH (nolock)  
                    WHERE   @ToSrno between FrSrno and ToSrno)  
            BEGIN  
                SET @RetVal = -103  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg = 'To Sr.No Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  


	  INSERT INTO M_Group_Category WITH(ROWLOCK) (  
	   Category_Name  
	   ,FrSrno  
	   ,ToSrno  
	   ,Is_Active  
	   ,Dept_ID  
	   ,Remark  
	   ,MAC_Add  
	   ,Entry_User  
	   ,Entry_Date   
	   ,Year_Id  
	   ,Branch_ID  
	   )  
	   VALUES(  
	   @Category_Name  
	   ,@FrSrno  
	   ,@ToSrno  
	   ,@Is_Active  
	   ,@Dept_ID  
	   ,@Remark  
	   ,@MAC_Add  
	   ,@Entry_User  
	   , dbo.Get_sysdate()  
	   ,@Year_Id  
	   ,@Branch_ID  
	   )  
      
  SET @RetMsg ='Item Head Create Sucessfully.'  
        SET @RetVal = Scope_identity()  
  
   IF @@ERROR <>  0  
   BEGIN  
    SET @RetVal = 0 -- 0 IS FOR ERROR  
     SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
   End  
      END  
    ELSE  
      BEGIN  
          IF NOT EXISTS(SELECT 1  
                        FROM   M_Group_Category WITH (nolock)  
                        WHERE  Category_Id = @Category_Id)  
            BEGIN  
                SET @RetVal = -12  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.        
                SET @RetMsg =  
                'This Item Head Is Already Been Deleted By Another User.'  
  
                RETURN  
            END  
  
          IF EXISTS(SELECT 1  
                    FROM   M_Group_Category WITH (nolock)  
                    WHERE  Category_Name = @Category_Name  
                           AND Category_Id <> @Category_Id)  
            BEGIN  
                SET @RetVal = -101  
                -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg =  
                'Same Item Head Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  

          IF EXISTS(SELECT 1   FROM   M_Group_Category WITH (nolock)   WHERE   @FrSrno between FrSrno and ToSrno  AND Category_Id <> @Category_Id)  
            BEGIN  
                SET @RetVal = -102  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg = 'From Sr.No Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  

          IF EXISTS(SELECT 1  
                    FROM   M_Group_Category WITH (nolock)  
                    WHERE   @ToSrno between FrSrno and ToSrno  AND Category_Id <> @Category_Id)  
            BEGIN  
                SET @RetVal = -103  -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.            
                SET @RetMsg = 'To Sr.No Exist ,Please Enter Other Item Head.'  
  
                RETURN  
            END  

      
		   UPDATE M_Group_Category WITH (ROWLOCK)  
		   SET  
			   Category_Name = @Category_Name  
			   ,FrSrno = @FrSrno  
			   ,ToSrno = @ToSrno  
			   ,Is_Active = @Is_Active  
		   --,Dept_ID = @Dept_ID  
				,Remark = @Remark,  
				 upd_user = @Upd_User,  
			  upd_date = dbo.Get_sysdate()  
			WHERE   Category_Id = @Category_Id  
  
  
          IF @@ERROR = 0  
            BEGIN  
                SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED             
                SET @RetMsg ='Item Head Update Successfully.'  
            END  
          ELSE  
            BEGIN  
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED          
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
            END  
      END 
GO


