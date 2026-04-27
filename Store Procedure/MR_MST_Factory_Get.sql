USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[MR_MST_Factory_Get]    Script Date: 27-04-2026 12:52:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[MR_MST_Factory_Get]    
     @fr_date date ='2022-04-24',          
     @Tr_date date ='2022-06-24'
AS                                      
SET NOCOUNT ON;

SELECT
(
    SELECT 
        MaterialRequirement.MR_Id,
        MaterialRequirement.Pd_Ref_No,
        MaterialRequirement.Quotation_No,
        MaterialRequirement.Project_Id,
        MaterialRequirement.Entry_User,
        MaterialRequirement.Entry_Date,
        MaterialRequirement.MR_Type,
        MaterialRequirement.MR_Code,
        M_Project.Project_Name,
        MaterialRequirement.Quotation_Attchment,
        MaterialRequirement.Mat_Delivery_At,
        mda.Master_Vals AS Mat_Delivery_At_Name,
        MaterialRequirement.Department_Id,
        dpt.Master_Vals AS Department_Name,
        MaterialRequirement.Delivery_Address,
        MaterialRequirement.Tentative_Mat_Expected,
        MaterialRequirement.Prepared_By,
        prepared_emp.Emp_Name AS Prepared_By_Name,
        prepared_emp.Personal_No AS Prepared_By_Phone,
        MaterialRequirement.Project_Manager,
        prm_emp.Emp_Name AS Project_Manager_Name,
        prm_emp.Personal_No AS Project_Manager_Phone,
        MaterialRequirement.Site_Engineer,
        ste_emp.Emp_Name AS Site_Engineer_Name,
        ste_emp.Personal_No AS Site_Engineer_Phone,
        MaterialRequirement.Checked_By,
        checked_emp.Emp_Id AS Checked_By_Id,
        checked_emp.Emp_Name AS Checked_By_Name,
        checked_emp.Personal_No AS Checked_By_Phone,
        MaterialRequirement.Authorised_By,
        authorize_emp.Emp_Id AS Authorised_By_Id,
        authorize_emp.Emp_Name AS Authorised_By_Name,    
        authorize_emp.Personal_No AS Authorised_By_Phone,
        MaterialRequirement.Checked_Date,
        MaterialRequirement.Authorised_Date,

        (
            SELECT
                MR_Items.MR_Items_Id,
                M_Item.Item_Rate AS Amount,
                M_Master.Master_Vals AS Unit_Name,
                MR_Items.TotalCost,
                MR_Items.[Length],
                MR_Items.Width,
                MR_Items.Weight,
                MR_Items.Item_Id,
                MR_Items.Stock_Id,
                MR_Items.Material_Value,
                MR_Items.Coating_Value,
                M_Item.Item_Cate_Id,
                M_Item_Category.Item_Cate_Name as Item_Category_Name,
                M_Item.Item_Group_Id,
                M_Item_Group.Item_Group_Name,
                M_Item.Item_Name as Item_Description,
                M_Item.Item_Code,
                M_Item.HSN_Code,
                M_Item.ImageName,
                MR_Items.Qty,
                MR_Items.Release_Qty,
                MR_Items.Request_Qty,
                MR_Items.Coating_Request_Qty,
                MR_Items.IsPORequested,
                MR_Items.IsFreeze,
                MaterialRequirement.IsPublish,
                MR_Items.Is_Job_Work,
                MR_Items.Cmp_Job_Work,
                MR_Items.Reject_Reason,
                MR_Items.IsRejected,
                MR_Items.Freeze_Qty,
                MR_Items.Issue_Qty,
                MR_Items.RecievedQty,

                -- HasRequest
                CASE 
                    WHEN EXISTS (
                        SELECT 1 
                        FROM BOM_PO_RequestDtl 
                        WHERE BOM_Dtl_Id = MR_Items.MR_Items_Id
                    )
                    THEN 1 ELSE 0
                END AS HasRequest,

                -- Available Qty
                (
                    SELECT SUM(SV.Pending_Qty) 
                    FROM StockView AS SV 
                    WHERE SV.Item_Id = MR_Items.Item_Id 
                      AND SV.[Length] = MR_Items.[Length]
                      AND (MR_Items.Stock_Id = 0 OR SV.Id = MR_Items.Stock_Id)
                ) AS Available_Qty,

                MR_Items.Godown_Id,
                M_Godown.Godown_Name,
                MR_Items.Godown_Rack_Id,
                M_Godown_Rack.Rack_Name

            FROM MR_Items
            LEFT JOIN M_Item ON MR_Items.Item_Id = M_Item.Item_Id
            LEFT JOIN M_Master ON M_Master.Master_Id = M_Item.Unit_Id
            LEFT JOIN M_Item_Category ON M_Item.Item_Cate_Id = M_Item_Category.Item_Cate_Id
            LEFT JOIN M_Item_Group ON M_Item.Item_Group_Id = M_Item_Group.Item_Group_Id
            LEFT JOIN M_Godown ON MR_Items.Godown_Id = M_Godown.Godown_Id
            LEFT JOIN M_Godown_Rack ON MR_Items.Godown_Rack_Id = M_Godown_Rack.Rack_Id
            WHERE MR_Items.MR_Id = MaterialRequirement.MR_Id
            FOR JSON PATH
        ) AS Dt_Detail
        -----------------------------------------------

    FROM MaterialRequirement
    LEFT OUTER JOIN M_Project ON MaterialRequirement.Project_Id = M_Project.Project_Id
    LEFT OUTER JOIN M_Master AS mda ON MaterialRequirement.Mat_Delivery_At = mda.Master_Id
    LEFT OUTER JOIN M_Master AS dpt ON MaterialRequirement.Department_Id = dpt.Master_Id

    LEFT OUTER JOIN M_Employee_Role AS prepared ON MaterialRequirement.Prepared_By = prepared.Id
    LEFT OUTER JOIN M_Employee AS prepared_emp ON prepared.Emp_Id = prepared_emp.Emp_Id

    LEFT OUTER JOIN M_Employee_Role AS prm ON MaterialRequirement.Project_Manager = prm.Id
    LEFT OUTER JOIN M_Employee AS prm_emp ON prm.Emp_Id = prm_emp.Emp_Id

    LEFT OUTER JOIN M_Employee_Role AS ste ON MaterialRequirement.Site_Engineer = ste.Id
    LEFT OUTER JOIN M_Employee AS ste_emp ON ste.Emp_Id = ste_emp.Emp_Id

    LEFT OUTER JOIN M_Employee_Role AS checked ON MaterialRequirement.Checked_By = checked.Id
    LEFT OUTER JOIN M_Employee AS checked_emp ON checked.Emp_Id = checked_emp.Emp_Id

    LEFT OUTER JOIN M_Employee_Role AS authorize ON MaterialRequirement.Authorised_By = authorize.Id
    LEFT OUTER JOIN M_Employee AS authorize_emp ON authorize.Emp_Id = authorize_emp.Emp_Id

    WHERE MaterialRequirement.MR_Type = 'A'
    ORDER BY MaterialRequirement.MR_Id DESC
    FOR JSON PATH
) AS json;



     
GO


