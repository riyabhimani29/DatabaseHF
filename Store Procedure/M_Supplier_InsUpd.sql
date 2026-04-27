USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Supplier_InsUpd]    Script Date: 27-04-2026 12:47:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure          
          
 ALTER PROCEDURE [dbo].[M_Supplier_InsUpd]            
@Supplier_Id int,          
@Supplier_Name varchar(500),          
@Contact_Person varchar(500),          
@Email_ID varchar(500),          
@Contact_No varchar(500),          
@Mobile varchar(500),          
@PAN_No varchar(500),          
@GST_No varchar(500),          
@Address varchar(500),          
@Pin_Code varchar(500),        
@Country_Id int,            
@State_Id int,          
@City_Id int,          
@Is_Active bit,          
@Remark varchar(500),          
@Bank_Id int,          
@ACNo varchar(500),          
@IFSCCode varchar(500),          
--@Dept_ID int,       
@Dept_IDs varchar(500),   
@Year_Id int,          
@Branch_ID int,          
@MAC_Add varchar(500),          
@Entry_User int,           
@Upd_User int,                          
@DT Tbl_SuppItemDetail READONLY ,           
@RetVal INT = 0 OUT   ,            
@RetMsg varchar(max) = '' OUT             
          
AS            
          
SET NOCOUNT ON            
          
if (@Supplier_Id=0)            
begin            
          
    IF   EXISTS(select 1 from M_Supplier With (NOLOCK) WHERE Supplier_Name = UPPER( @Supplier_Name))              
    BEGIN              
    SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.              
    SET @RetMsg ='Same Supplier Name Alredy Exist.'            
   Return              
    End             
          
  INSERT INTO M_Supplier WITH(ROWLOCK) (          
   Supplier_Name,Contact_Person   ,Email_ID   ,Contact_No   ,Mobile   ,PAN_No   ,GST_No   ,[Address] ,Pin_Code ,Country_Id  ,State_Id   ,City_Id   ,Is_Active          
   ,Remark   ,Bank_Id  ,ACNo  ,IFSCCode  , Dept_IDs  ,Year_Id  ,Branch_ID  ,MAC_Add   ,Entry_User   ,Entry_Date   )          
  VALUES( @Supplier_Name  ,@Contact_Person   ,@Email_ID   ,@Contact_No   ,@Mobile   ,@PAN_No   ,@GST_No   ,@Address   ,@Pin_Code ,@Country_Id  ,@State_Id   ,@City_Id   ,@Is_Active          
   ,@Remark   ,@Bank_Id   ,@ACNo   ,@IFSCCode   , @Dept_IDs   ,@Year_Id   ,@Branch_ID   ,@MAC_Add   ,@Entry_User   ,dbo.Get_Sysdate()  )          
          
 SET @RetMsg ='Supplier Create Sucessfully.'           
 SET @RetVal = SCOPE_IDENTITY()           
         
 IF @@ERROR <>  0            
   BEGIN            
     SET @RetVal = 0 -- 0 IS FOR ERROR            
     SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'               
   End            
 else           
  begin          
   DECLARE @_Item_Id AS INT= 0 ,  @_Is_Active AS BIT= 0 ,  @_SupItem_Code AS VARCHAR(500)= '' , @_ItemRemark AS VARCHAR(500)= ''           
    --DECLARE @_Item_Cate_Id AS INT= 0 ,  @_Item_Group_Id AS INT= 0           
            DECLARE Purchase_CUR CURSOR FOR                           
            SELECT  SupItem_Code,Item_Id,Is_Active,ItemRemark  FROM @DT ;                                             
          
            OPEN Purchase_CUR                                      
            FETCH NEXT FROM Purchase_CUR INTO @_SupItem_Code ,@_Item_Id, @_Is_Active , @_ItemRemark                           
          
            WHILE @@FETCH_STATUS = 0                                           
                BEGIN                                   
           
       --select @_Item_Group_Id = isnull (Item_Group_Id ,0) ,          
       --@_Item_Cate_Id = isnull (Item_Cate_Id,0)          
       --from M_Item where Item_Id = @_Item_Id          
          
      INSERT INTO [dbo].[M_SupplierDtl]          
      ([Supplier_Id]          
      ,[SupItem_Code]          
      ,[Item_Id]          
      ,[Is_Active]          
      ,[ItemRemark],          
      Entry_Date )          
      VALUES          
      (@RetVal          
      ,@_SupItem_Code          
      ,@_Item_Id          
      ,@_Is_Active          
      ,@_ItemRemark,          
      dbo.Get_Sysdate()         
      )          
          
                    FETCH NEXT FROM Purchase_CUR INTO  @_SupItem_Code ,@_Item_Id,@_Is_Active , @_ItemRemark                          
          
                END                               
            CLOSE Purchase_CUR ;                                              
            DEALLOCATE Purchase_CUR ;           
  end           
          
end             
else             
begin     
          
          
IF NOT EXISTS(select 1 from M_Supplier With (NOLOCK) WHERE   Supplier_Id = @Supplier_Id)          
     BEGIN          
          SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.              
   SET @RetMsg ='This Supplier Is Already Been Deleted By Another User.'            
          Return          
     End          
          
          
    IF   EXISTS(select 1 from M_Supplier With (NOLOCK) WHERE Supplier_Name = UPPER( @Supplier_Name) AND Supplier_Id <> @Supplier_Id   )              
    BEGIN              
  SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.              
  SET @RetMsg ='Same Supplier Name Alredy Exist.'            
      Return              
    End           
          
   UPDATE M_Supplier WITH (ROWLOCK)          
   SET          
		Supplier_Name = @Supplier_Name          
		,Contact_Person = @Contact_Person          
		,Email_ID = @Email_ID          
		,Contact_No = @Contact_No          
		,Mobile = @Mobile          
		,PAN_No = @PAN_No          
		,GST_No = @GST_No          
		,Address = @Address          
		,Pin_Code = @Pin_Code         
		,Country_Id = @Country_Id          
		,State_Id = @State_Id          
		,City_Id = @City_Id          
		,Is_Active = @Is_Active          
		,Remark = @Remark          
		,Bank_Id = @Bank_Id          
		,ACNo = @ACNo          
		,IFSCCode = @IFSCCode      ,    
		Dept_IDs = @Dept_IDs ,
   Upd_User = @Upd_User          
    ,Upd_Date = dbo.Get_Sysdate()          
   WHERE          
   Supplier_Id = @Supplier_Id            
          
          
IF @@ERROR =  0            
BEGIN            
SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED            
  SET @RetMsg ='Supplier Details Update Successfully.'            
          
  begin          
   DECLARE @_SupDetail_Id AS INT= 0 , @_Item_Id1 AS INT= 0 ,  @_Is_Active1 AS BIT= 0 ,  @_SupItem_Code1 AS VARCHAR(500)= '' , @_ItemRemark1 AS VARCHAR(500)= ''           
   -- DECLARE @_Item_Group_Id1 AS INT= 0 , @_Item_Cate_Id1 AS INT= 0           
          
            DECLARE Purchase_CUR CURSOR FOR                           
            SELECT  SupDetail_Id,SupItem_Code,Item_Id,Is_Active,ItemRemark  FROM @DT ;                                             
          
            OPEN Purchase_CUR                                      
            FETCH NEXT FROM Purchase_CUR INTO @_SupDetail_Id,@_SupItem_Code1 ,@_Item_Id1, @_Is_Active1 , @_ItemRemark1                           
          
            WHILE @@FETCH_STATUS = 0                                           
                BEGIN            
					  if (@_SupDetail_Id =0 )          
					  begin                          
						--select @_Item_Group_Id1 = isnull (Item_Group_Id ,0) ,          
						--@_Item_Cate_Id1 = isnull (Item_Cate_Id,0)          
						--from M_Item where Item_Id = @_Item_Id          
          
						  INSERT INTO [dbo].[M_SupplierDtl]          
							  ([Supplier_Id]          
							  ,[SupItem_Code]          
							  ,[Item_Id]          
							  ,[Is_Active]          
							  ,[ItemRemark],          
							  Entry_Date  )          
						  VALUES          
							  (@Supplier_Id          
							  ,@_SupItem_Code1          
							  ,@_Item_Id1          
							  ,@_Is_Active1          
							  ,@_ItemRemark1,          
							  dbo.Get_Sysdate()           
						  )               
					  END   
					  else 
					  begin
						update M_SupplierDtl set SupItem_Code = @_SupItem_Code1 , ItemRemark = @_ItemRemark1 where M_SupplierDtl.SupDetail_Id = @_SupDetail_Id
					 END
					  
                    FETCH NEXT FROM Purchase_CUR INTO  @_SupDetail_Id,@_SupItem_Code1 ,@_Item_Id1, @_Is_Active1 , @_ItemRemark1                                    
                END                                      
            CLOSE Purchase_CUR ;                                              
            DEALLOCATE Purchase_CUR ;           
  end           
End            
ELSE   
BEGIN            
SET @RetVal = 0 -- 0 WHEN AN ERROR HAS OCCURED            
   SET @RetMsg ='Error Occurred - '+ ERROR_MESSAGE()+'.'            
End            
End 
GO


