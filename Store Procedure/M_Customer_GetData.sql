USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Customer_GetData]    Script Date: 27-04-2026 11:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[M_Customer_GetData]              
 @Type Bit = 0    
AS        
    SET nocount ON        
        
         
SELECT M_Customer.Cust_Id,      
       M_Customer.Cust_Name,    
    M_Customer.Contact_Person,  
       M_Customer.Contact_No,       
       M_Customer.Cust_Address,      
       M_Customer.GST_No,        
       M_Customer.PAN_No,        
       M_Customer.Is_Active,      
       M_Customer.Remark ,
	   M_Customer.Email_Id
FROM   M_Customer WITH (nolock)       
where  M_Customer.Is_Active  = (case when @Type = 0  then M_Customer.Is_Active else 1 end )    
  ORDER BY M_Customer.Cust_Id DESC     
GO


