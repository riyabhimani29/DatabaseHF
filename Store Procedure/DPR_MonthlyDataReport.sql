USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[DPR_MonthlyDataReport]    Script Date: 27-04-2026 11:25:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[DPR_MonthlyDataReport]
    @Year INT,
    @Project_Id INT = NULL,
    @Month INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Month = 0
    BEGIN
        ;WITH Months AS (
            SELECT 1 AS MonthNumber, 'January' AS MonthName UNION ALL
            SELECT 2, 'February' UNION ALL
            SELECT 3, 'March' UNION ALL
            SELECT 4, 'April' UNION ALL
            SELECT 5, 'May' UNION ALL
            SELECT 6, 'June' UNION ALL
            SELECT 7, 'July' UNION ALL
            SELECT 8, 'August' UNION ALL
            SELECT 9, 'September' UNION ALL
            SELECT 10, 'October' UNION ALL
            SELECT 11, 'November' UNION ALL
            SELECT 12, 'December'
        )
        SELECT (
            SELECT
                Months.MonthName AS Month,
                (
                    SELECT DPR_Project_PanelTypes.Elevations,
                    DPR_Project_PanelTypes.PanelType,
                    DPR_Project_PanelTypes.ProjectType,
                    DPR_Project_PanelTypes.Project_Id,
                    DPR_Project_PanelTypes.DPR_Panel_Id
                    FROM DPR_Project_PanelTypes 
                    join DPR_Project on DPR_Project_PanelTypes.Project_Id = DPR_Project.Project_Id
                    WHERE MONTH(DPR_Project.Entry_Date) = Months.MonthNumber AND YEAR(DPR_Project.Entry_Date) = @Year
                    AND (@Project_Id = 0 OR DPR_Project.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalElevation,
                (
                    SELECT    
                    Release_Panel.[Date],
                    Release_Panel.PanelElevationDetails,
                    DPR_Project_PanelTypes.Elevations
                    FROM Release_Panel  
                    join DPR_Project_PanelTypes ON
                    Release_Panel.DPR_Panel_Id = DPR_Project_PanelTypes.DPR_Panel_Id
                    WHERE MONTH(Release_Panel.[Date]) = Months.MonthNumber AND YEAR(Release_Panel.[Date]) = @Year
                    AND (@Project_Id = 0 OR DPR_Project_PanelTypes.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalReleaseElevation,
                (
                    SELECT 
                    Installation_Panel.Area,
                    Installation_Panel.[Date],
                    Installation_Panel.Elevation,
                    Installation_Panel.Panel_Installation,
                    Installation_Panel.Running_Meter
                    FROM Installation_Panel 
                    join DPR on Installation_Panel.Dpr_Id = DPR.Dpr_Id
                    WHERE MONTH(Installation_Panel.[Date]) = Months.MonthNumber AND YEAR(Installation_Panel.[Date]) = @Year
                    AND (@Project_Id = 0 OR DPR.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalInstallationElevation
            FROM
                Months
            --LEFT JOIN DPR ON MONTH(DPR.[Date]) = Months.MonthNumber
            --LEFT OUTER JOIN DPR_Project ON DPR_Project.Project_Id = DPR.Project_Id
            FOR JSON PATH
        ) AS json
    END
    ELSE
    BEGIN
        ;WITH numbers AS (
            SELECT 1 AS value
            UNION ALL
            SELECT value + 1
            FROM numbers
            WHERE value + 1 <= DAY(EOMONTH(DATEFROMPARTS(@Year, @Month, 1)))
        )
        SELECT (
            SELECT
                numbers.value AS Day,
                (
                    SELECT 
                    DPR_Project_PanelTypes.Elevations,
                    DPR_Project_PanelTypes.PanelType,
                    DPR_Project_PanelTypes.ProjectType,
                    DPR_Project_PanelTypes.Project_Id,
                    DPR_Project_PanelTypes.DPR_Panel_Id
                    FROM DPR_Project_PanelTypes 
                    join DPR_Project on DPR_Project_PanelTypes.Project_Id = DPR_Project.Project_Id
                    WHERE DATEFROMPARTS(YEAR(DPR_Project.Entry_Date), MONTH(DPR_Project.Entry_Date), DAY(DPR_Project.Entry_Date)) = DATEFROMPARTS(@Year, @Month, numbers.value)
                                        AND (@Project_Id = 0 OR DPR_Project.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalElevation,
                (
                    SELECT 
                  --  Release_Panel.Area,
                    Release_Panel.[Date],
                    Release_Panel.PanelElevationDetails,
                    DPR_Project_PanelTypes.Elevations
                    FROM Release_Panel  
                    join DPR_Project_PanelTypes ON
                    Release_Panel.DPR_Panel_Id = DPR_Project_PanelTypes.DPR_Panel_Id
                    WHERE DATEFROMPARTS(YEAR(Release_Panel.[Date]), MONTH(Release_Panel.[Date]), DAY(Release_Panel.[Date])) = DATEFROMPARTS(@Year, @Month, numbers.value)
                                        AND (@Project_Id = 0 OR DPR_Project_PanelTypes.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalReleaseElevation,
                (
                    SELECT 
                           Installation_Panel.Area,
                    Installation_Panel.[Date],
                    Installation_Panel.Elevation,
                    Installation_Panel.Panel_Installation,
                    Installation_Panel.Running_Meter
                    FROM Installation_Panel  
                                        join DPR on Installation_Panel.Dpr_Id = DPR.Dpr_Id
                    WHERE DATEFROMPARTS(YEAR(Installation_Panel.[Date]), MONTH(Installation_Panel.[Date]), DAY(Installation_Panel.[Date])) = DATEFROMPARTS(@Year, @Month, numbers.value)
                                        AND (@Project_Id = 0 OR DPR.Project_Id = @Project_Id)
                    FOR JSON PATH
                ) AS totalInstallationElevation
            FROM
                numbers
        --    LEFT JOIN DPR ON DATEFROMPARTS(YEAR(DPR.[Date]), MONTH(DPR.[Date]), DAY(DPR.[Date])) = DATEFROMPARTS(@Year, @Month, numbers.value)
         --   LEFT OUTER JOIN DPR_Project ON DPR_Project.Project_Id = DPR.Project_Id
            FOR JSON PATH
        ) AS json
    END
END;
GO


