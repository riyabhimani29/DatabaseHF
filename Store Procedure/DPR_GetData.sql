USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_GetData]    Script Date: 27-04-2026 11:24:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[DPR_GetData] @Type INT = 0,
@FDate date = '2022-12-23',
@TDate date = '2028-01-23',
@Project_Id INT = 0 AS BEGIN
SET
    NOCOUNT ON;
IF @Project_Id IS NOT NULL
    AND @Project_Id != 0 BEGIN
SELECT
    (
        SELECT
            DPR.Dpr_Id,
            DPR.Project_Id,
            DPR_Project.Project_Name,
            DPR.Entry_User,
            DPR.Entry_Date,
            M_Employee.Emp_Name AS Entry_UserName,
            DPR.Date,
            DPR.Remarks AS Remark,
                (SELECT 
           DPR_Project_PanelTypes.DPR_Panel_Id,
           DPR_Project_PanelTypes.Elevations,
           DPR_Project_PanelTypes.ProjectType,
           DPR_Project_PanelTypes.PanelType,
           --DPR_Project_PanelTypes.Project_Id,
           DPR_PanelTypes.[Name] as PanelTypeName
           from DPR_Project_PanelTypes
           join DPR_PanelTypes on DPR_Project_PanelTypes.PanelType =
           DPR_PanelTypes.PanelType_Id
           WHERE 
    DPR_Project_PanelTypes.Project_Id = DPR.Project_Id FOR JSON PATH) as Panels,
            (
                SELECT
                    Release_Id,
                    PanelElevationDetails,
                    DPR_Panel_Id,
                    Remarks,
                       M_Employee.Emp_Name as Entry_User,
                    Release_Panel.Entry_Date,
                    Release_Panel.Upd_Date,
                          (
                SELECT
                    Fab_Id,
                    Dpr_Id,
                    Man_Power,
                    Male_Female,
                    Gutter,
                    Bottom,
                    Mid_Transfom,
                    Adaptor,
                    Edge_Guard,
                    Running_Meter,
                    Frame,
                    Shutter,
                    Remarks,
                    Elevation,
                    BatchNo,
                    Area,
                     M_Employee.Emp_Name as Entry_User,
                    Fabrication_Panel.Entry_Date,
                    Fabrication_Panel.Upd_Date
                FROM
                    Fabrication_Panel
                    JOIN M_Employee on Fabrication_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Fabrication_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Fabrication_Panel,
            (
                SELECT
                    Asmbl_Id,
                    Dpr_Id,
                    Man_Power,
                    Panel_Assemble,
                    Hook_Bracket_Assemble,
                    GI_Trey_Assemble,
                    Frame_Assemble,
                    Shutter_Assemble,
                    Hardware_Assemble,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                     M_Employee.Emp_Name as Entry_User,
                    Assemble_Panel.Entry_Date,
                    Assemble_Panel.Upd_Date
                FROM
                    Assemble_Panel
                    JOIN M_Employee on Assemble_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Assemble_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Assemble_Panel,
            (
                SELECT
                    Glaz_Id,
                    Dpr_Id,
                    Glass_Pesting,
                    Panel_Glazing,
                    Weather_Silicon,
                    Man_Power,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                     M_Employee.Emp_Name as Entry_User,
                    Glazing_Panel.Entry_Date,
                    Glazing_Panel.Upd_Date
                FROM
                    Glazing_Panel
                    JOIN M_Employee on Glazing_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Glazing_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Glazing_Panel,
            (
                SELECT
                    Instl_Id,
                    Dpr_Id,
                    Man_Power,
                    Panel_Installation,
                    Running_Meter,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                     M_Employee.Emp_Name as Entry_User,
                    Installation_Panel.Entry_Date,
                    Installation_Panel.Upd_Date
                FROM
                    Installation_Panel
                    JOIN M_Employee on Installation_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Installation_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Installation_Panel,
            (
                SELECT
                    Dis_Id,
                    Dpr_Id,
                    Dispatch,
                    Running_Meter,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                     M_Employee.Emp_Name as Entry_User,
                    Panel_Dispatch.Entry_Date,
                    Panel_Dispatch.Upd_Date
                FROM
                    Panel_Dispatch
                    JOIN M_Employee on Panel_Dispatch.Entry_User = M_Employee.Emp_Id
                WHERE
                    Panel_Dispatch.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Panel_Dispatch
                FROM
                    Release_Panel
                    JOIN M_Employee on Release_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Release_Panel.Dpr_Id = DPR.Dpr_Id FOR JSON PATH
            ) AS Release_Panels
        FROM
            DPR
            JOIN DPR_Project ON DPR.Project_Id = DPR_Project.Project_Id
            LEFT OUTER JOIN M_Employee ON M_Employee.Emp_Id = DPR.Entry_User
                LEFT outer JOIN Release_Panel ON DPR.Dpr_Id = Release_Panel.Dpr_Id
        WHERE
            DPR.Project_Id = @Project_Id
            and DPR.Date between @FDate
    and DATEADD(day, 1, @TDate)
             GROUP BY
    DPR.Dpr_Id,
    DPR.Project_Id,
    DPR_Project.Project_Name,
    DPR.Entry_User,
    DPR.Entry_Date,
    M_Employee.Emp_Name,
    DPR.Remarks,
    DPR.Date
             FOR JSON PATH
    ) AS json;
END
ELSE BEGIN
SELECT
    (
        SELECT
            DPR.Dpr_Id,
            DPR.Project_Id,
            DPR_Project.Project_Name,
            DPR.Entry_User,
            DPR.Entry_Date,
            M_Employee.Emp_Name AS Entry_UserName,
            DPR.Date,
            DPR.Remarks AS Remark,
            (SELECT 
           DPR_Project_PanelTypes.DPR_Panel_Id,
           DPR_Project_PanelTypes.Elevations,
           DPR_Project_PanelTypes.ProjectType,
           DPR_Project_PanelTypes.PanelType,
           DPR_Project_PanelTypes.Project_Id,
           DPR_PanelTypes.[Name] as PanelTypeName
           from DPR_Project_PanelTypes
           join DPR_PanelTypes on DPR_Project_PanelTypes.PanelType =
           DPR_PanelTypes.PanelType_Id
           WHERE 
    DPR_Project_PanelTypes.Project_Id = DPR.Project_Id FOR JSON PATH) as Panels,
            (
                SELECT
                        Release_Id,
                    PanelElevationDetails,
                    DPR_Panel_Id,
                    Remarks,
                    
                       M_Employee.Emp_Name as Entry_User,
                    Release_Panel.Entry_Date,
                    Release_Panel.Upd_Date,
                                           (
                SELECT
                    Fab_Id,
                    Dpr_Id,
                    Man_Power,
                    Male_Female,
                    Gutter,
                    Bottom,
                    Mid_Transfom,
                    Adaptor,
                    Edge_Guard,
                    Running_Meter,
                    Frame,
                    Shutter,
                    Remarks,
                    Elevation,
                    BatchNo,
                    Area,
                      M_Employee.Emp_Name as Entry_User,
                    Fabrication_Panel.Entry_Date,
                    Fabrication_Panel.Upd_Date
                FROM
                    Fabrication_Panel
                    JOIN M_Employee on Fabrication_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Fabrication_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Fabrication_Panel,
            (
                SELECT
                    Asmbl_Id,
                    Dpr_Id,
                    Man_Power,
                    Panel_Assemble,
                    Hook_Bracket_Assemble,
                    GI_Trey_Assemble,
                    Frame_Assemble,
                    Shutter_Assemble,
                    Hardware_Assemble,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,  
                    M_Employee.Emp_Name as Entry_User,
                    Assemble_Panel.Entry_Date,
                    Assemble_Panel.Upd_Date
                FROM
                    Assemble_Panel
                    JOIN M_Employee on Assemble_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Assemble_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Assemble_Panel,
            (
                SELECT
                    Glaz_Id,
                    Dpr_Id,
                    Glass_Pesting,
                    Panel_Glazing,
                    Weather_Silicon,
                    Man_Power,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                      M_Employee.Emp_Name as Entry_User,
                    Glazing_Panel.Entry_Date,
                    Glazing_Panel.Upd_Date
                FROM
                    Glazing_Panel
                    JOIN M_Employee on Glazing_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Glazing_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Glazing_Panel,
            (
                SELECT
                    Instl_Id,
                    Dpr_Id,
                    Man_Power,
                    Panel_Installation,
                    Running_Meter,
                    Elevation,
                    BatchNo,
                    Remarks,
                    Area,
                    M_Employee.Emp_Name as Entry_User,
                    Installation_Panel.Entry_Date,
                    Installation_Panel.Upd_Date
                FROM
                    Installation_Panel
                    JOIN M_Employee on Installation_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Installation_Panel.Release_Id = Release_Panel.Release_Id FOR JSON PATH
            ) AS Installation_Panel,
            (
                SELECT
                    Dis_Id,
                    Dpr_Id,
                    Dispatch,
                    Running_Meter,
                    Elevation,
                    BatchNo,
                    Remarks,
                    M_Employee.Emp_Name as Entry_User,
                    Panel_Dispatch.Entry_Date,
                    Panel_Dispatch.Upd_Date
                    Area
                FROM
                    Panel_Dispatch
                    JOIN M_Employee on Panel_Dispatch.Entry_User = M_Employee.Emp_Id
                WHERE
                    Panel_Dispatch.Release_Id = Release_Panel.Release_Id 
                    FOR JSON PATH
            ) AS Panel_Dispatch
                FROM
                    Release_Panel
                    JOIN M_Employee on Release_Panel.Entry_User = M_Employee.Emp_Id
                WHERE
                    Release_Panel.Dpr_Id = DPR.Dpr_Id FOR JSON PATH
            ) AS Release_Panels
        FROM
            DPR
            JOIN DPR_Project ON DPR.Project_Id = DPR_Project.Project_Id
            LEFT OUTER JOIN M_Employee ON M_Employee.Emp_Id = DPR.Entry_User 
                     LEFT outer JOIN Release_Panel ON DPR.Dpr_Id = Release_Panel.Dpr_Id
                      where DPR.Date between @FDate
    and DATEADD(day, 1, @TDate)
                         GROUP BY
    DPR.Dpr_Id,
    DPR.Project_Id,
    DPR_Project.Project_Name,
    DPR.Entry_User,
    DPR.Entry_Date,
    M_Employee.Emp_Name,
    DPR.Remarks,
    DPR.Date
            FOR JSON PATH
    ) AS json;
END
END;
GO


