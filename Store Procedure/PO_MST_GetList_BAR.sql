USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[PO_MST_GetList_BAR]    Script Date: 27-04-2026 13:15:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[PO_MST_GetList_BAR] @PO_Id       INT = 0,                

         @Dept_ID int = 0,                  

                                    @Supplier_Id INT =0,                                        

                                    @PO_Type     VARCHAR(1)=''  ,                                        

                                    @Order_Type     VARCHAR(100)=''                                       

AS                                        

    SET nocount ON                                        

    SELECT PO_MST.PO_Id,                                        

           PO_MST.PO_Type,                                        

           Order_Type,                                           

           case when Order_Type ='PO-GL' then  'Glass PO'        

    when Order_Type ='PO-HW' then  'Hardware PO'        

     else         

     Order_Type        

     end        

     AS Order_Type2,                                         

           PO_MST.Dept_ID,                                        

           m_department.Dept_Name,                                        

           PO_MST.Invoice_No,                                        

           PO_MST.OrderNo,                                        

           PO_MST.PO_Date,                                        

           --PO_MST.ReqRaisedBy_Id,                                        

           --Tbl_ReqRaisedBy.Emp_Name     AS ReqRaisedBy,                                        

           --PO_MST.BillingAddress,                                        

           PO_MST.Supplier_Id,                                        

           M_Supplier.Supplier_Name,                                        

           --M_Supplier.Address           AS SupplierAddress,                                        

           --M_Supplier.GST_No            AS SupplierGSTNO,                                        

           --Tbl_State.Master_Vals        AS SupplierState,                                        

           PO_MST.Godown_Id,                                        

           M_Godown.Godown_Name,                                        

           --M_Godown.Godown_Address      AS ShippingAddress,                                        

           CONVERT( numeric(18,0), PO_MST.GrossAmount) AS grossamount,                                        

           --PO_MST.AdvanceAmount,                                        

           --PO_MST.NetAmount,                                        

           --PO_MST.PaymentTerms,                                        

           --PO_MST.DeliveryTerms,                                        

           --PO_MST.AdditionalTerms,                                        

           --PO_MST.AuthorisePerson_Id,                                        

           --Tbl_AuthorisePerson.Emp_Name AS AuthorisePerson,                                        

           --PO_MST.ApproveDate,                                        

           PO_MST.Remark,                                        

           CASE                                        

             WHEN Tbl.PendingQty <= 0 THEN 'Close'                                        

             ELSE ( CASE WHEN PO_MST.PO_Type = 'D' THEN 'Draft'                                        

                      ELSE ( CASE WHEN PO_MST.PO_Type = 'C' THEN 'Cancel'                                

          WHEN PO_MST.PO_Type = 'Q' THEN 'Force Close'                               

          WHEN PO_MST.PO_Type = 'X' THEN 'Delete'                               

                               ELSE 'Open'                                        

                             END )                                        

                    END )                                        

           END                          AS POStatus,                                        

           Tbl.OrderQty,                                        

           Tbl.PendingQty,                                    

           CASE                                        

             WHEN Tbl.PendingQty = Tbl.OrderQty                               

                  AND PO_MST.PO_Type != 'C' THEN 'Cancel'            

             ELSE ''                                        

           END                          AS IsCancel,                                      

   --        Tbl_CGST.Master_NumVals      AS CGSTPer,                                        

   --        Tbl_SGST.Master_NumVals      AS SGSTPer,                                        

   --        Tbl_IGST.Master_NumVals      AS IGSTPer,                                        

   --        PO_MST.CGST,                              

   --        PO_MST.SGST,                                        

   --        PO_MST.IGST,                      

   --         CONVERT( numeric(18,0), PO_MST.CGSTTotal ) AS cgsttotal,                                        

   --         CONVERT( numeric(18,0), PO_MST.SGSTTotal ) AS sgsttotal,                                        

   --         CONVERT( numeric(18,0), PO_MST.IGSTTotal ) AS igsttotal,                                 

   --case when PO_MST.IGST = 0  then convert(bit,0) else convert(bit,1) end AS  Is_IGST,                              

        --   Tbl_User.Emp_Name            AS EntryUserName,                               

          -- Tbl_User.Personal_No         AS EntryUserNo ,               

     Doc_Img_Name --  ,                    

   --PO_MST.Revision  ,              

   --PO_MST.Admin_Charges,              

   --PO_MST.Insurance,              

   --PO_MST.Other_Charges  ,            

   --PO_MST.Freight_Charges            

FROM   PO_MST WITH (nolock)                                        

           LEFT JOIN M_Master AS Tbl_CGST WITH (nolock)    ON PO_MST.cgst = Tbl_CGST. master_id                                        

           LEFT JOIN M_Master AS Tbl_SGST WITH (nolock)     ON PO_MST.sgst = Tbl_SGST. master_id                                        

           LEFT JOIN M_Master AS Tbl_IGST WITH (nolock)  ON PO_MST.igst = Tbl_IGST.master_id                                        

           LEFT JOIN m_employee AS Tbl_User WITH(nolock)      ON PO_MST.entry_user = Tbl_User.emp_id                                        

           OUTER apply (SELECT Sum(Isnull(PO_DTL.orderqty, 0))   AS OrderQty,                                 

     Sum( case when  Isnull(PO_DTL.pendingqty, 0) > 0 then Isnull(PO_DTL.pendingqty, 0) else 0 end  ) AS PendingQty                                        

                               /*Sum(Isnull(PO_DTL.pendingqty, 0)) AS PendingQty        */                                

                        FROM   PO_DTL WITH (nolock)                                        

                        WHERE  PO_DTL.PO_Id = PO_MST.PO_Id) AS Tbl                                        

           LEFT JOIN m_godown WITH (nolock)  ON PO_MST.godown_id = m_godown.godown_id                                        

           LEFT JOIN m_department WITH (nolock)      ON PO_MST.dept_id = m_department.dept_id                                        

           LEFT JOIN m_employee AS Tbl_ReqRaisedBy WITH (nolock)  ON PO_MST.reqraisedby_id = Tbl_ReqRaisedBy.emp_id                                        

           LEFT JOIN m_employee AS Tbl_AuthorisePerson WITH (nolock) ON PO_MST.authoriseperson_id = Tbl_AuthorisePerson.emp_id                                        

           LEFT JOIN M_Supplier WITH (nolock) ON PO_MST.supplier_id = M_Supplier.supplier_id                                        

           LEFT JOIN M_Master AS Tbl_State WITH (nolock) ON M_Supplier.state_id = Tbl_State.master_id                                        

    WHERE  /*PO_MST.Order_Type = case when   @Order_Type = '' then PO_MST.Order_Type else @Order_Type end  -- @Order_Type /*'PO'*/        

   AND*/ PO_MST.PO_Type <> 'X'                     

   and  PO_MST.Dept_ID  = case when   @Dept_ID = 0 then PO_MST.Dept_ID else @Dept_ID end           

           AND PO_MST.PO_Id = CASE                                        

                              WHEN @PO_Id = 0 THEN PO_MST.PO_Id                                        

                                ELSE @PO_Id          

                              END                                        

           AND PO_MST.supplier_id = CASE                                        

                  WHEN @Supplier_Id = 0 THEN                                        

                                     PO_MST.supplier_id                                        

                                      ELSE @Supplier_Id                                        

            END                                        

           AND PO_MST.PO_Type = CASE                                        

                                  WHEN @PO_Type = '' THEN PO_MST.PO_Type                                        

                                  ELSE @PO_Type                                        

                                END 

           AND  EXISTS (

                        SELECT 1 

                        FROM GRN_MST GM WITH (NOLOCK)

                        WHERE GM.PO_Id = PO_MST.PO_Id AND GRN_Type = 'GLPO-GRN'

                    )

    ORDER  BY PO_MST.PO_Id DESC
 
GO


