USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Inquiry_GetMasterData]    Script Date: 27-04-2026 11:49:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[Inquiry_GetMasterData]                
@SearchParam  VARCHAR(8000)  = ''                
                
AS                
                
SET NOCOUNT ON                
    
     
    
    
select Master_Id,Master_Vals from M_Master with (nolock) where Master_Type ='INQUIRY BRANCH' AND Is_Active = 1    
select Project_Id,Project_Name from M_Project with (nolock) where Is_Active = 1    
select Emp_Id,Emp_Name from M_Employee  with (nolock)  where Is_Active = 1    
select Cust_Id,Cust_Name from M_Customer  with (nolock) where Is_Active = 1     
select Master_Id,Master_Vals,DropDownNo from  M_Master  with (nolock)  where Master_Type ='INQUIRY STATUS' AND Is_Active = 1  order by Master_NumVals asc
  
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='INQUIRY SOURCE' AND Is_Active = 1  
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='PROJECT TYPE' AND Is_Active = 1  
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='ARCHITECT DETAIL' AND Is_Active = 1

select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='COLOR' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='FLYMESH' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='GLASS OR PANEL' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='INQUIRY FOR' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='SHOWROOM VISIT' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='PURPOSE OF VISIT' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='INQUIRY DOCUMENTATION' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='FOLLOW-UP TYPE' AND Is_Active = 1
select Master_Id,Master_Vals from  M_Master  with (nolock)  where Master_Type ='SYSTEM/SERIES' AND Is_Active = 1

SELECT * FROM Inquiry_Sites

SELECT Visitors.VisitorsId,Visitors.VisitorsNo,Visitors.VisitorsDate,Visitors.VisitorsName,Visitors.VisitorsContact,
Visitors.VisitorsMail,Visitors.VisitorsAddress,Visitors.Remark,Visitors.Enter_By,Visitors.Enter_By,
M_Employee.Emp_Name AS Attended_By  ,Visitors.Is_Flg    ,Visitors.Inquiry_Id  ,case when Visitors.Inquiry_Id > 1 then 'Move to Inquiry' else  'Open' end AS Visitors_Status FROM [dbo].[Visitors]  WITH(NOLOCK) left join M_Employee  WITH(NOLOCK)  on M_Employee.Emp_Id  = Visitors.Enter_By order by Visitors.VisitorsId desc 

SELECT M_Employee.Emp_Id,  
       M_Employee.Emp_Name  
FROM   M_Employee WHERE M_Employee.Is_Active = 1
GO


