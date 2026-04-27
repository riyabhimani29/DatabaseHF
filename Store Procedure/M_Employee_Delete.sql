USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Employee_Delete]    Script Date: 27-04-2026 11:55:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[M_Employee_Delete]
@Emp_Id int ,
@RetVal	INT = 0	OUT,        
@RetMsg varchar(max) = '' OUT  

AS

SET NOCOUNT ON

	IF NOT EXISTS(Select 1 from M_Employee With (NOLOCK) WHERE Emp_Id=@Emp_Id)
	BEGIN
	   SET @RetVal = 2 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.       
	   SET @RetMsg ='Record is Already been deleted by another user.'         
	   Return
	END
	IF EXISTS ( SELECT  1  FROM dbo.DC_Mst WITH ( NOLOCK ) WHERE   SiteEnginner_Id = @Emp_Id )     
        BEGIN        
            SET @RetVal = -101 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Delivery Challan Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Project WITH ( NOLOCK ) WHERE   Pro_InchargeId = @Emp_Id )     
        BEGIN        
            SET @RetVal = -102 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Project Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.GRN_Mst WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -103 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On GRN Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.GRN_Mst WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -104 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On GRN Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Department WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -105 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Department Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Department WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -106 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Department Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Godown WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -107 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Godown Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Godown WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -108 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Godown Table.'              
            RETURN        
        END 

	IF EXISTS ( SELECT  1  FROM dbo.M_Item WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -109 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Item WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -110 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Table.'              
            RETURN        
        END 

	IF EXISTS ( SELECT  1  FROM dbo.M_Item_Category WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -111 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Item_Category WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -112 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Category Table.'              
            RETURN        
        END
		
	IF EXISTS ( SELECT  1  FROM dbo.M_Item_Group WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -113 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Group Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Item_Group WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -114 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Item Group Table.'              
            RETURN        
        END
	IF EXISTS ( SELECT  1  FROM dbo.M_Master WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -115 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Master Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Master WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -116 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Master Table.'              
            RETURN        
        END
	IF EXISTS ( SELECT  1  FROM dbo.M_Project WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -117 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Project Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Project WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -118 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Project Table.'              
            RETURN        
        END
	IF EXISTS ( SELECT  1  FROM dbo.M_Supplier WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -119 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Supplier Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.M_Supplier WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -120 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Supplier Table.'              
            RETURN        
        END
	IF EXISTS ( SELECT  1  FROM dbo.PO_MST WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -121 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On PO Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.PO_MST WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -122 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On PO Table.'              
            RETURN        
        END
	IF EXISTS ( SELECT  1  FROM dbo.StockTrans_Mst WITH ( NOLOCK ) WHERE   Entry_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -123 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Stock Transfer Table.'              
            RETURN        
        END 
	IF EXISTS ( SELECT  1  FROM dbo.StockTrans_Mst WITH ( NOLOCK ) WHERE   Upd_User = @Emp_Id )     
        BEGIN        
            SET @RetVal = -124 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.         
			SET @RetMsg ='Can Not delete because record Exist On Stock Transfer Table.'              
            RETURN        
        END


       DELETE FROM M_Employee
       WHERE Emp_Id = @Emp_Id


IF @@ERROR =  0
BEGIN
   SET @RetVal = 1 -- 1 IS FOR SUCCESSFULLY EXECUTED
End
ELSE
BEGIN
   SET @RetVal = 0	-- 0 WHEN AN ERROR HAS OCCURED
End
GO


