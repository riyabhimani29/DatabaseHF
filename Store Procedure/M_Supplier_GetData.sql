USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Supplier_GetData]    Script Date: 27-04-2026 12:46:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    
ALTER PROCEDURE [dbo].[M_Supplier_GetData]     
@Dept_ID int = 0 ,  
  @Is_Active int = 0  
AS     
SET    
   NOCOUNT     
   ON     
   
 SELECT    
     dbo.M_Supplier.Supplier_Id,    
     dbo.M_Supplier.Supplier_Name,    
    -- Contact_Person,    
     dbo.M_Supplier.Email_ID,    
     dbo.M_Supplier.Contact_No,    
    -- Mobile,    
     dbo.M_Supplier.PAN_No,    
     dbo.M_Supplier.GST_No,    
     dbo.M_Supplier.Address,    
     dbo.M_Supplier.Pin_Code,    
     dbo.M_Supplier.State_Id,    
     Tbl_State.Master_Vals as StateName,    
     dbo.M_Supplier.City_Id,    
     Tbl_City.Master_Vals as CityName,    
     dbo.M_Supplier.Is_Active,    
     dbo.M_Supplier.Remark,    
   --  Bank_Id,    
    -- ACNo,    
    -- IFSCCode,    
     dbo.M_Supplier.Dept_ID,    
     dbo.M_Supplier.Year_Id,    
     dbo.M_Supplier.Branch_ID,    
     dbo.M_Supplier.MAC_Add,    
     dbo.M_Supplier.Entry_User,    
     dbo.M_Supplier.Entry_Date,    
     dbo.M_Supplier.Upd_User,    
     dbo.M_Supplier.Upd_Date     
  From    
     dbo.M_Supplier With (NOLOCK)    
     left join M_Master as Tbl_State  With (NOLOCK) On M_Supplier.State_Id = Tbl_State.Master_Id    
     left join M_Master as Tbl_City  With (NOLOCK) On M_Supplier.City_Id = Tbl_City.Master_Id    
    where  
    --dbo.M_Supplier.Dept_ID = (case when @Dept_ID = 0 then dbo.M_Supplier.Dept_ID   else @Dept_ID end   )  
    (@Dept_ID = 0 OR ',' + dbo.M_Supplier.Dept_IDs + ',' LIKE '%,' + CAST(@Dept_ID AS VARCHAR) + ',%')
 and M_Supplier.Is_Active  = (case when @Is_Active = 0 then dbo.M_Supplier.Is_Active   else @Is_Active end   )
 
 Order BY dbo.M_Supplier.Supplier_Name
GO


