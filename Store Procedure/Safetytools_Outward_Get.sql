USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Safetytools_Outward_Get]    Script Date: 27-04-2026 14:40:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Safetytools_Outward_Get]                                                
    @Outward_Id INT = 0                
AS                                                
BEGIN
    SET NOCOUNT ON;                                                

    -----------------------------------------
    -- HEADER DATA
    -----------------------------------------
    SELECT  
        so.Id,
        so.Outward_No,
        so.ShippingGodown_Address,
        so.ShippingGodown_Id,
        so.Issue_to,
        g.Godown_Name,
        CASE 
        WHEN so.issue_type = 1 THEN 'To Project'
        WHEN so.issue_type = 0 THEN 'To Person'
        ELSE 'Unknown'
        END AS Issue_Type,
        so.entry_date AS Issue_date,
        so.Project_Id,
        so.Remark
    FROM safetytools_outward so WITH (NOLOCK)                                                            
    LEFT JOIN M_Godown g WITH (NOLOCK)  
        ON so.ShippingGodown_Id = g.Godown_Id    
    WHERE (@Outward_Id = 0 OR so.Id = @Outward_Id)


    -----------------------------------------
    -- DETAIL DATA
    -----------------------------------------
    SELECT  
        ROW_NUMBER() OVER (ORDER BY sod.Id) AS SrNo, 
        sod.StOutward_Id,
        sod.[ItemId ] as ItemId,
        sod.Item_Code,
        sod.Item_Name,
        sod.Unit_Name,
        sod.OutwardQty,
        sod.Stock_Id,
        ig.Item_Group_Name,
        ig.Item_Group_Id,
        gr.Rack_Name,
        gr.Rack_Id,
        ic.Item_Cate_Name,
        ic.Item_Cate_Id,
        g.Godown_Id,
        g.Godown_Name,
        sod.Project_Id AS Project_Id,
        sod.Issue_date AS GRN_Date,
         CASE 
        WHEN sod.issue_type = 1 THEN 'To Project'
        WHEN sod.issue_type = 0 THEN 'To Person'
        ELSE 'Unknown'
        END AS IsProject,
        sod.Issue_to AS IssueTo,
        sod.Remark,
        P.Project_Name
    FROM safetytools_outward_Dtl sod WITH (NOLOCK)     
    LEFT JOIN StockView sv WITH (NOLOCK)  
        ON sv.Id = sod.Stock_Id  
    LEFT JOIN M_Item mi WITH (NOLOCK)  
        ON sod.[ItemId ] = mi.Item_Id
    LEFT JOIN M_Item_Group ig WITH (NOLOCK)  
        ON mi.Item_Group_Id = ig.Item_Group_Id                                              
    LEFT JOIN M_Item_Category ic WITH (NOLOCK)  
        ON mi.Item_Cate_Id = ic.Item_Cate_Id          
    LEFT JOIN M_Godown g WITH (NOLOCK)  
        ON sv.Godown_Id = g.Godown_Id     
    LEFT JOIN M_Godown_Rack gr WITH (NOLOCK)  
        ON sv.Rack_Id = gr.Rack_Id 
    LEFT JOIN M_Project P WITH (NOLOCK)
        ON P.Project_Id = sod.Project_Id
    WHERE (@Outward_Id = 0 OR sod.StOutward_Id = @Outward_Id)

END
GO


