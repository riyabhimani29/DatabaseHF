USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[M_Project_GetData]    Script Date: 27-04-2026 12:40:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[M_Project_GetData]                

    @Type INT = 0,

    @Inquiry_StatusId INT = 0

AS

BEGIN

    SET NOCOUNT ON;
 
    SELECT

        P.Project_Id,                

        P.Pro_InchargeId,                

        ICH.Emp_Name AS Incharge,                

        P.Project_Name,                

        P.Project_Type_Id,                

        PT.Master_Vals AS Project_Type,                

        P.Site_Address,                

        P.Country_Id,                

        CN.Master_Vals AS CountryName,                

        P.State_Id,                

        ST.Master_Vals AS StateName,                

        P.City_Id,

        P.PD_Numbers,

        CT.Master_Vals AS CityName,                

        P.Customer_Name,                

        P.Customer_Address,                

        P.Contact_Person,                

        P.Contact_Number,                

        P.PAN_No,                

        P.GST_No,                

        P.SiteEngineer_Id,                

        ENG.Emp_Name AS Engineer, 

        --P.ProjectManager_Id,

        --PM.Emp_Name AS ProjectManager,

        P.Quatation_Amt,                

        P.Project_Start_Date,                

        P.Expected_End_Date,                

        P.Project_Status,                

        P.Is_Active,                

        P.Remark,                

        P.MAC_Add,                

        P.Entry_User,                

        P.Entry_Date,                

        P.Upd_User,                

        P.Upd_Date,                

        P.Year_Id,                

        P.Branch_ID,      

        ISNULL(G.Godown_Id, 0) AS Godown_Id,    

        CASE 

            WHEN ISNULL(G.Godown_Id, 0) = 0 THEN CONVERT(BIT, 0) 

            ELSE CONVERT(BIT, 1)  

        END AS Is_Godown,  

        E.Emp_Name AS Entry_UserName,

        Q.Inquiry_No,

        G.Godown_Name

    FROM 

        M_Project P WITH (NOLOCK)

        LEFT JOIN Inquiry Q WITH (NOLOCK) ON P.Inquiry_Id = Q.Inquiry_Id

        LEFT JOIN M_Employee E WITH (NOLOCK) ON P.Entry_User = E.Emp_Id    

        LEFT JOIN M_Godown G WITH (NOLOCK) ON P.Project_Id = G.Project_Id

        LEFT JOIN M_Master PT WITH (NOLOCK) ON P.Project_Type_Id = PT.Master_Id

        LEFT JOIN M_Employee ICH WITH (NOLOCK) ON P.Pro_InchargeId = ICH.Emp_Id

        LEFT JOIN M_Employee ENG WITH (NOLOCK) ON P.SiteEngineer_Id = ENG.Emp_Id

        --LEFT JOIN M_Employee PM WITH (NOLOCK) ON P.SiteEngineer_Id = PM.Emp_Id

        LEFT JOIN M_Master CN WITH (NOLOCK) ON P.Country_Id = CN.Master_Id

        LEFT JOIN M_Master ST WITH (NOLOCK) ON P.State_Id = ST.Master_Id

        LEFT JOIN M_Master CT WITH (NOLOCK) ON P.City_Id = CT.Master_Id

    WHERE 

        P.Is_Active = CASE WHEN @Type = 0 THEN P.Is_Active ELSE 1 END

        AND (

            @Inquiry_StatusId = 0 

            OR Q.Inquiry_StatusId = @Inquiry_StatusId

        )

    ORDER BY 

        P.Entry_Date DESC;

END;
 
GO


