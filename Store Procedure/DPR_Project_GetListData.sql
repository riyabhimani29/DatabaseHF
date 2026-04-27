USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_Project_GetListData]    Script Date: 27-04-2026 11:27:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_Project_GetListData] 
    @Type int = 1,
    @FDate date = '2022-12-23',
    @TDate date = '2023-01-23' 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DPR_Project.Project_Id,
        DPR_Project.Project_Name,
        DPR_Project.Site_Address,
        DPR_Project.Country_Id,
        Tbl_Country.Master_Vals AS CountryName,
        DPR_Project.State_Id,
        Tbl_State.Master_Vals AS StateName,
        DPR_Project.City_Id,
        Tbl_City.Master_Vals AS CityName,
        DPR_Project.Customer_Name,
        DPR_Project.Customer_Address,
        DPR_Project.Contact_Person,
        DPR_Project.Contact_Number,
        DPR_Project.PAN_No,
        DPR_Project.GST_No,
        DPR_Project.Project_Status,
        DPR_Project.Is_Active,
        DPR_Project.Remark,
        DPR_Project.MAC_Add,
        DPR_Project.Entry_User,
        DPR_Project.Entry_Date,
        DPR_Project.Upd_User,
        DPR_Project.Upd_Date,
        (
            SELECT 
                DPR_Project_PanelTypes.DPR_Panel_Id,
                DPR_Project_PanelTypes.Elevations,
                DPR_Project_PanelTypes.PanelType,
                DPR_Project_PanelTypes.Project_Id,
                DPR_Project_PanelTypes.ProjectType,
                (
                    SELECT * 
                    FROM Release_Panel 
                    WHERE Release_Panel.DPR_Panel_Id = DPR_Project_PanelTypes.DPR_Panel_Id 
                    FOR JSON PATH
                ) AS Release_Panel
            FROM DPR_Project_PanelTypes 
            WHERE DPR_Project_PanelTypes.Project_Id = DPR_Project.Project_Id 
            FOR JSON PATH
        ) AS Panels,
        M_Employee.Emp_Name AS Entry_UserName
    FROM
        DPR_Project WITH (NOLOCK)
        LEFT JOIN M_Employee WITH (NOLOCK) ON DPR_Project.Entry_User = M_Employee.Emp_Id        
        LEFT JOIN M_Master AS Tbl_Country WITH (NOLOCK) ON DPR_Project.Country_Id = Tbl_Country.Master_Id
        LEFT JOIN M_Master AS Tbl_State WITH (NOLOCK) ON DPR_Project.State_Id = Tbl_State.Master_Id
        LEFT JOIN M_Master AS Tbl_City WITH (NOLOCK) ON DPR_Project.City_Id = Tbl_City.Master_Id
        LEFT JOIN DPR ON DPR_Project.Project_Id = DPR.Project_Id
      --  LEFT JOIN Release_Panel ON DPR.Dpr_Id = Release_Panel.Dpr_Id
    WHERE
        DPR_Project.Is_Active = CASE
            WHEN @Type = 0 THEN DPR_Project.Is_Active
            ELSE 1
        END
        AND DPR_Project.Entry_Date BETWEEN @FDate AND DATEADD(day, 1, @TDate)
    GROUP BY
        DPR_Project.Project_Id,
        DPR_Project.Project_Name,
        DPR_Project.Site_Address,
        DPR_Project.Country_Id,
        Tbl_Country.Master_Vals,
        DPR_Project.State_Id,
        Tbl_State.Master_Vals,
        DPR_Project.City_Id,
        Tbl_City.Master_Vals,
        DPR_Project.Customer_Name,
        DPR_Project.Customer_Address,
        DPR_Project.Contact_Person,
        DPR_Project.Contact_Number,
        DPR_Project.PAN_No,
        DPR_Project.GST_No,
        DPR_Project.Project_Status,
        DPR_Project.Is_Active,
        DPR_Project.Remark,
        DPR_Project.MAC_Add,
        DPR_Project.Entry_User,
        DPR_Project.Entry_Date,
        DPR_Project.Upd_User,
        DPR_Project.Upd_Date,
        M_Employee.Emp_Name
    ORDER BY
        DPR_Project.Entry_Date DESC;
END;
GO


