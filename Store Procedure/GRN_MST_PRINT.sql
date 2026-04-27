USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[GRN_MST_PRINT]    Script Date: 27-04-2026 11:40:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                                                      

ALTER    PROCEDURE [dbo].[GRN_MST_PRINT]                                                      

@GRN_Id int  = 0  ,                            

@Dept_ID  int  = 0 ,                            

@GRNType  varchar(50)  = 'PO-GRN'                  

AS                                                      

SET NOCOUNT ON                                                      


SELECT  GRN_Mst.GRN_Id,                                    

     GRN_Mst.GRN_Type,                                    

     GRN_Mst.GRN_No,                                    

     --GRN_Mst.PO_Id,                                    

    ( case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT','GLPO-GRN','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')   then   PO_MST.OrderNo                        

when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_No

--when GRN_Mst.GRN_Type = 'GRN- OUT' then PO_MST.OrderNo 

else '' end )  AS PO_No ,                  

     --GRN_Mst.Dept_ID,                                        

     M_Department.Dept_Name,                                          

     GRN_Mst.Invoice_No,                                    

     GRN_Mst.Challan_No,                                    

     GRN_Mst.GRN_Date,                                    

     --GRN_Mst.Challan_Date,                                    

    ( case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT','GLPO-GRN','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')   then   PO_MST.PO_Date                        

when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_Date

-- when GRN_Mst.GRN_Type = 'GRN- OUT' then PO_MST.PO_Date 

else '' end )  AS Challan_Date ,        

    -- GRN_Mst.ReqRaisedBy_Id,                                    

  ( case when GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT','GLPO-GRN','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')   then   Tbl_ReqRaisedBy.Emp_Name    else '-' end )  as ReqRaisedBy,                                     

     --GRN_Mst.Supplier_Id,                                                   

     M_Supplier.Supplier_Name,                                                

     --GRN_Mst.Godown_Id,                                       

     M_Godown.Godown_Name,                                   

     GRN_Mst.EwayBill_No,                                    

     GRN_Mst.GrossAmount,                                    

     GRN_Mst.AdvanceAmount,                                    

     GRN_Mst.OtherAmount,
     
     GRN_Mst.Insurance,

     GRN_Mst.NetAmount,

     GRN_Mst.DiscountAmountOverall,

     GRN_Mst.DiscountPercentageOverall,

     Tbl_ReceiveBy.Emp_Name AS ReceiveBy,                                    

     Tbl_CheckBy.Emp_Name AS CheckBy,                                

     --GRN_Mst.ReceiveBy_Id ,                              

     --GRN_Mst.CheckBy_Id ,                              

     GRN_Mst.Remark  ,                  

  M_Project.Project_Name   ,          

   CONVERT( numeric(18,3), GRN_Mst.CGSTTotal ) AS CGSTTotal,                                                

            CONVERT( numeric(18,3), GRN_Mst.SGSTTotal ) AS SGSTTotal,                                                

            CONVERT( numeric(18,3), GRN_Mst.IGSTTotal ) AS IGSTTotal,              


   Tbl_CGST.Master_NumVals      AS CGSTPer,                                                

           Tbl_SGST.Master_NumVals      AS SGSTPer,                                                

           Tbl_IGST.Master_NumVals      AS IGSTPer,

       Tbl_Shade.master_vals                        coating_shade,

	   ( case when GRN_Mst.GRN_Type ='PO-GRN'   then    ''                        

when GRN_Mst.GRN_Type ='DC-GRN'   then  DC_Mst.ProjectDocument  else '' end )  Reference_No ,

  ( case when GRN_Mst.GRN_Type ='PO-GRN'   then    ''                        

when GRN_Mst.GRN_Type ='DC-GRN'   then  DC_Mst.Vehicle_No  else '' end ) Vehicle_No



From GRN_Mst With (NOLOCK)            

  LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)    ON GRN_Mst.CGST = Tbl_CGST. master_id                                                

           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)     ON GRN_Mst.SGST = Tbl_SGST. master_id                                                

           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)  ON GRN_Mst.IGST = Tbl_IGST.master_id              

left join M_Employee AS Tbl_ReceiveBy With (NOLOCK)  On GRN_Mst.ReceiveBy_Id  = Tbl_ReceiveBy.Emp_Id                               

left join M_Employee AS Tbl_CheckBy With (NOLOCK)  On GRN_Mst.CheckBy_Id  = Tbl_CheckBy.Emp_Id                                 

left join M_Godown With (NOLOCK)  On GRN_Mst.Godown_Id  = M_Godown.Godown_Id                              

left join M_Department  With (NOLOCK)  On GRN_Mst.Dept_ID  = M_Department.Dept_ID                                                      

left join M_Employee AS Tbl_ReqRaisedBy  With (NOLOCK)  On GRN_Mst.ReqRaisedBy_Id  = Tbl_ReqRaisedBy.Emp_Id           

left join PO_MST  With (NOLOCK)  On GRN_Mst.PO_Id  = PO_MST.PO_Id   and GRN_Mst.GRN_Type IN ('PO-GRN','GRN-OUT','GLPO-GRN','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')                                   

left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'  

          LEFT JOIN m_master AS Tbl_Shade WITH (nolock) ON dc_mst.coating_shadeid = Tbl_Shade.master_id  

left join M_Project  With (NOLOCK)  On DC_Mst.Project_Id  =  M_Project.Project_Id                  

left join M_Supplier   With (NOLOCK)  On GRN_Mst.Supplier_Id  = M_Supplier.Supplier_Id                                    

where GRN_Mst.GRN_Id = @GRN_Id           

--AND GRN_Mst.Dept_ID = (case when @Dept_ID = 0 then GRN_Mst.Dept_ID else @Dept_ID end )                             

--AND GRN_Mst.GRN_Type = @GRNType                  

order by GRN_Mst.GRN_Id DESC                                


SELECT  ROW_NUMBER() OVER( ORDER BY GRN_Dtl.PODtl_Id) AS SrNo,                                     

   GRN_Dtl.GrnDtl_Id,                                    

   GRN_Dtl.GRN_Id,                                           

   GRN_Mst.GRN_No,                  

  -- GRN_Dtl.PODtl_Id,                                    

   --M_Item.Item_Group_Id,                                        

   M_Item_Group.Item_Group_Name,                                         

   --M_Item.Item_Cate_Id,                                       

   M_Item_Category.Item_Cate_Name,                            

  -- GRN_Dtl.Item_Id,                                            

   M_Item.Item_Name,                                              

   M_Item.Item_Code ,                                     

   M_Item.HSN_Code,                            

  -- GRN_Dtl.SupDetail_Id,                               

    (case when GRN_Mst.GRN_Type  IN ('PO-GRN', 'GLPO-GRN','GRN-OUT','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')    then   M_SupplierDtl.SupItem_Code                        

   else '-' end ) SupItem_Code,                      

   GRN_Dtl.SType,                                    

   GRN_Dtl.OrderQty,                                    

   GRN_Dtl.ReceiveQty,                                    

   --GRN_Dtl.Unit_Id,                                    

   Tbl_Unit.Master_Vals as Unit,                                      

   GRN_Dtl.[Length],  

   GRN_Dtl.[Length_Meter],

   GRN_Dtl.[Weight],                                   

   GRN_Dtl.TotalWeight,                                    

   GRN_Dtl.UnitCost,                                    

   GRN_Dtl.ReceiveCost,                                    

   GRN_Dtl.TotalCost,                                  

   GRN_Dtl.Remark ,   

   GRN_Dtl.Discount_Percentage,

   GRN_Dtl.Discount_Amount,

   (case when GRN_Mst.GRN_Type  IN ('PO-GRN', 'GLPO-GRN','GRN-OUT','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')    then  PO_MST.OrderNo                        

  when GRN_Mst.GRN_Type ='DC-GRN'   then DC_Mst.DC_No  else '' end )   AS OrderNo ,                    

  GRN_Dtl.Material_Value,                    

GRN_Dtl.Coating_Value  ,            

M_Project.Project_Name,            

PO_DTL.Ref_Code,            

M_Godown_Rack.Rack_Name  ,          

PO_MST.OrderNo  AS PO_No,          

PO_DTL.Width  ,        

GRN_Mst.Challan_Date  ,  

    M_Item.ImageName   ,

    M_Item.Height


From GRN_Dtl With (NOLOCK)                                     

left join GRN_Mst With (NOLOCK) On GRN_Mst.GRN_Id  = GRN_Dtl.GRN_Id                             

left join PO_DTL With (NOLOCK) On PO_DTL.PODtl_Id  = GRN_Dtl.PODtl_Id                                  

left join PO_MST  With (NOLOCK) On PO_DTL.PO_Id  = PO_MST.PO_Id and GRN_Mst.GRN_Type  IN ('PO-GRN', 'GLPO-GRN','GRN-OUT','HWPO-GRN','UPVCPO-GRN','SHPO-GRN','RFPO-GRN','MSIPO-GRN')                        

left join DC_Mst  With (NOLOCK)  On GRN_Mst.PO_Id  = DC_Mst.DC_Id  and GRN_Mst.GRN_Type ='DC-GRN'                           

left join M_Master as Tbl_Unit with (nolock) On GRN_Dtl.Unit_Id =   Tbl_Unit.Master_Id                

left join M_SupplierDtl with (nolock) On GRN_Dtl.SupDetail_Id =   M_SupplierDtl.SupDetail_Id                                                         

left join M_Item  with (nolock) On GRN_Dtl.Item_Id =   M_Item.Item_Id                                                 

left join M_Item_Group  with (nolock) On M_Item.Item_Group_Id =   M_Item_Group.Item_Group_Id                                                    

left join M_Item_Category  with (nolock) On M_Item.Item_Cate_Id =   M_Item_Category.Item_Cate_Id                

left join M_Project  With (NOLOCK) On PO_DTL.Project_Id = M_Project.Project_Id            

left join M_Godown_Rack  With (NOLOCK) On GRN_Dtl.Rack_Id = M_Godown_Rack.Rack_Id            

where GRN_Dtl.GRN_Id = @GRN_Id           

--AND GRN_Mst.Dept_ID = (case when @Dept_ID = 0 then GRN_Mst.Dept_ID else @Dept_ID end )                      

--AND GRN_Mst.GRN_Type = @GRNType
GO


