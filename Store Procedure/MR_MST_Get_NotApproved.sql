USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MR_MST_Get_NotApproved]    Script Date: 27-04-2026 12:54:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER  PROCEDURE [dbo].[MR_MST_Get_NotApproved]    
         @fr_date date ='2022-04-24',          
         @Tr_date date ='2022-06-24',
         @Type NVARCHAR(50),
         @SessionUser AS INT = 0,
         @Project_Id AS INT = 0,
         @Dept_ID AS INT = 0,
         @MR_Id AS INT = 0
AS                                        
    SET nocount ON                                        
    
    select (SELECT 
    MaterialRequirement.MR_Id,
    color.Master_Vals as Coating_Colour_Name,
    MaterialRequirement.Pd_Ref_No,
   -- MaterialRequirement.Coating_Colour,
    MaterialRequirement.Quotation_No,
    MaterialRequirement.Project_Id,
    MaterialRequirement.Dept_ID,
    MaterialRequirement.MR_Data_Type,
    M_Department.Dept_Name,
    MaterialRequirement.MR_Department,
    MaterialRequirement.Entry_User,
    MaterialRequirement.Entry_Date,
    MaterialRequirement.MR_Type,
    MaterialRequirement.MR_Code,
    M_Project.Project_Name,
    MaterialRequirement.Quotation_Attchment,
    MaterialRequirement.Mat_Delivery_At,
    mda.Master_Vals as Mat_Delivery_At_Name,
    MaterialRequirement.Department_Id,
    dpt.Master_Vals as Department_Name,
    MaterialRequirement.Delivery_Address,
    MaterialRequirement.MR_Reason,
    --addres.Master_Vals as Delivery_Address_Name,
    MaterialRequirement.Tentative_Mat_Expected,
    MaterialRequirement.Prepared_By,
    prepared_emp.Emp_Name as Prepared_By_Name,
    prepared_emp.Company_No AS Prepared_By_Phone,
    MaterialRequirement.Project_Manager,
    prm_emp.Emp_Name as Project_Manager_Name,
    prm_emp.Company_No as Project_Manager_Phone,
    MaterialRequirement.Site_Engineer,
    ste_emp.Emp_Name as Site_Engineer_Name,
    ste_emp.Company_No as Site_Engineer_Phone,
    MaterialRequirement.Checked_By,
    checked_emp.Emp_Id as Checked_By_Id,
    checked_emp.Emp_Name as Checked_By_Name,
    checked_emp.Company_No as Checked_By_Phone,
    MaterialRequirement.Authorised_By,
    authorize_emp.Emp_Id as Authorised_By_Id,
    authorize_emp.Emp_Name as Authorised_By_Name,    
    authorize_emp.Company_No as Authorised_By_Phone,
    MaterialRequirement.Checked_Date,
    MaterialRequirement.Authorised_Date,
    (SELECT
MR_Items_Id,
   MR_Items.UnitCost AS UnitCost,
                color.Master_Vals as Coating_Name,
                M_Master.Master_Vals AS Unit_Name,
                MR_Items.TotalCost,
                MR_Items.[Length],
                MR_Items.[Stock_Length],
                MR_Items.[IsChecked] AS Is_Split,
                MR_Items.Width,
                MR_Items.Weight,
                MR_Items.Item_Id,
                MR_Items.Stock_Id,
                MR_Items.Material_Value,
                MR_Items.Coating_Value,
                M_Item.Item_Cate_Id,
                M_Item_Category.Item_Cate_Name,
                M_Item.Item_Group_Id,
                M_Item_Group.Item_Group_Name,
                M_Item.Item_Name,
                M_Item.Item_Code,
                M_Item.HSN_Code,
                M_Item.Weight_Mtr,
                M_Item.ImageName,
                MR_Items.Qty,
                MR_Items.Release_Qty,
                MR_Items.Request_Qty,
                MR_Items.Coating_Request_Qty,
                MR_Items.IsPORequested,
                MR_Items.IsFreeze,
                MR_Items.Remarks,
                    MaterialRequirement.IsPublish,
                    MR_Items.Is_Job_Work,
                    MR_Items.Cmp_Job_Work,
                    MR_Items.Reject_Reason,
                    MR_Items.IsRejected,
                    MR_Items.Freeze_Qty,
                    MR_Items.Issue_Qty,
                    MR_Items.RecievedQty,
                 CASE 
    WHEN EXISTS (
      SELECT 1 
      FROM BOM_PO_RequestDtl 
      WHERE BOM_Dtl_Id = MR_Items.MR_Items_Id
    )
    THEN 1
    ELSE 0
  END AS HasRequest,
                 (SELECT SUM(SV.Pending_Qty) FROM StockView as SV WHERE 
  SV.Item_Id = MR_Items.Item_Id AND SV.[Length] = MR_Items.[Length]
  --AND SV.Godown_Id = MR_Items.Godown_Id AND SV.Rack_Id = MR_Items.Godown_Rack_Id
  and (MR_Items.Stock_Id = 0 OR SV.Id = MR_Items.Stock_Id)
  )
  AS Available_Qty,
                MR_Items.Godown_Id,
                   M_Godown.Godown_Name,
                MR_Items.Godown_Rack_Id,
                M_Godown_Rack.Rack_Name
            FROM MR_Items 
            LEFT JOIN M_Item ON MR_Items.Item_Id = M_Item.Item_Id
             LEFT JOIN M_Master ON M_Item.Unit_Id = M_Master.Master_Id
            LEFT JOIN M_Item_Category ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
            LEFT JOIN M_Item_Group ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id
            LEFT JOIN M_Godown ON MR_Items.Godown_Id = M_Godown.Godown_Id
            LEFT JOIN M_Godown_Rack ON MR_Items.Godown_Rack_Id = M_Godown_Rack.Rack_Id
--LEFT OUTER JOIN M_Master as ic ON MR_Items.Item_Category = ic.Master_Id
--LEFT OUTER JOIN M_Master as st ON MR_Items.Size_Type = st.Master_Id
--LEFT OUTER JOIN M_Master as unit ON MR_Items.Unit = unit.Master_Id
--LEFT OUTER JOIN M_Master as mf ON MR_Items.Material_Finish = mf.Master_Id
--LEFT OUTER JOIN M_Master as mc ON MR_Items.MR_Category = mc.Master_Id
--LEFT OUTER JOIN M_Master as mr ON MR_Items.MR_Reason = mr.Master_Id 
WHERE MR_Items.MR_Id = MaterialRequirement.MR_Id
FOR JSON PATH) as Dt_Detail
    FROM 
    MaterialRequirement 
    LEFT OUTER JOIN M_Project ON MaterialRequirement.Project_Id = M_Project.Project_Id
    LEFT OUTER JOIN M_Master as mda ON MaterialRequirement.Mat_Delivery_At = mda.Master_Id
    LEFT OUTER JOIN M_Master as dpt ON MaterialRequirement.Department_Id = dpt.Master_Id
    LEFT OUTER JOIN M_Master as color ON MaterialRequirement.Coating_Colour = color.Master_Id
   -- LEFT OUTER JOIN M_Master as addres ON MaterialRequirement.Delivery_Address = addres.Master_Id
    LEFT OUTER JOIN M_Department on MaterialRequirement.Dept_ID = M_Department.Dept_ID
    LEFT OUTER JOIN M_Employee_Role as prepared ON MaterialRequirement.Prepared_By = prepared.Id
    	LEFT OUTER JOIN M_Employee as prepared_emp ON prepared.Emp_Id = prepared_emp.Emp_Id
    
    --LEFT OUTER JOIN M_Employee_Role as prm ON MaterialRequirement.Project_Manager = prm.Id
    	LEFT OUTER JOIN M_Employee as prm_emp ON MaterialRequirement.Project_Manager = prm_emp.Emp_Id
    
    --LEFT OUTER JOIN M_Employee_Role as ste ON MaterialRequirement.Site_Engineer = ste.Id
        LEFT OUTER JOIN M_Employee as ste_emp ON MaterialRequirement.Site_Engineer = ste_emp.Emp_Id
        
    LEFT OUTER JOIN M_Employee_Role as checked ON MaterialRequirement.Checked_By = checked.Id
        LEFT OUTER JOIN M_Employee as checked_emp ON checked.Emp_Id = checked_emp.Emp_Id
        
    LEFT OUTER JOIN M_Employee_Role as authorize ON MaterialRequirement.Authorised_By = authorize.Id
        LEFT OUTER JOIN M_Employee as authorize_emp ON authorize.Emp_Id = authorize_emp.Emp_Id
        WHERE 
         ((
    -- Case 1: If type is 'approval'
    @Type = 'approval' AND 
    (
        (checked_emp.Emp_Id = @SessionUser AND MaterialRequirement.MR_Type = 'S') OR
        (authorize_emp.Emp_Id = @SessionUser AND MaterialRequirement.MR_Type = 'C')
    )
)
OR
(
    -- Case 2: For all other types
    @Type NOT IN ('approval')
))
    AND MaterialRequirement.MR_Type <> 'A' 
    AND (@Project_Id = 0 OR MaterialRequirement.Project_Id = @Project_Id)
    AND (@Dept_ID = 0 OR MaterialRequirement.Dept_ID = @Dept_ID)
    AND (@MR_Id = 0 OR MaterialRequirement.MR_Id = @MR_Id)
  --  AND MaterialRequirement.MR_Type = 'A'
ORDER BY MaterialRequirement.MR_Id DESC

        FOR JSON PATH) as json
GO


