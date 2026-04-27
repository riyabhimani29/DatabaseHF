USE [db_a8637c_hifaberp]
GO

/****** Object:  StoredProcedure [dbo].[Complains_InsUpd]    Script Date: 27-04-2026 11:13:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[Complains_InsUpd]  @Complain_Id       INT,  
                                       @Complain_Title_Id   int,  
                                       @Cust_Name         VARCHAR(500),  
                                       @Cust_Address      VARCHAR(500),  
                                       @Area              VARCHAR(500),  
                                       @Pin_Code          VARCHAR(500),  
                                       @Contact_Person    VARCHAR(500),  
                                       @Contact_Person_No VARCHAR(500),  
                                       @Contact_No        VARCHAR(500),  
                                       @Project_Type_Id   INT,  
                                       @Year_of_Site      INT,  
                                       @Complaint_Type_Id INT,  
                                       @Payment_Type_Id   INT,  
                                       @Complain_Details  VARCHAR(500),  
                                       @Remark            VARCHAR(500),  
                                       @MAC_Add           VARCHAR(500), 
                                       @Complain_Paid_Unpain INT,  
                                       @Complain_Status_Id   INT,  
                                       @Complain_Closure  VARCHAR(500),  
                                       @MR_OR_Glass_Order_Date            VARCHAR(500),  
                                       @MR_OR_Glass_Order_No           VARCHAR(500),
                                       @Quotation_No  VARCHAR(500),  
                                       @Owner_No            VARCHAR(500),  
                                       @Owner_Name           VARCHAR(500),
                                       @Complain_Registration_date  VARCHAR(500),
                                       @Complain_Closing_date VARCHAR(500),
                                       @Entry_User        INT,  
                                       @Upd_User          INT,  
                                       @Year_Id           INT,  
                                       @Branch_ID         INT,   
                                       @RetVal            INT = 0 out,  
                                       @RetMsg            VARCHAR(max) = '' out ,  
                                       @Complain_No            VARCHAR(max) = '' out   
AS  
    SET nocount ON  
    set @Year_Id = dbo.Get_financial_yearid(CONVERT (DATE, dbo.Get_sysdate()))  
  
    declare @_Current_Year as INT = 0,  
            @_Invoice_No   as INT = 0  
  
    Set @_Current_Year = RIGHT(Year(dbo.Get_sysdate()), 2)  
  
    IF ( @Complain_Id = 0 )  
      BEGIN  
          declare @ComplainNo AS VARCHAR(50) =''  
  
          SELECT @_Invoice_No = Isnull(Max(Complains.invoice_no), 0) + 1  
          FROM   Complains WITH(nolock)  
          WHERE  Complains.year_id = @Year_Id  
  
          SET @ComplainNo = 'HF' + CONVERT(VARCHAR(20), @_Current_Year)  
                            + CONVERT(VARCHAR(20), Month(dbo.Get_sysdate() ))  
                            + CONVERT(VARCHAR(20), Format(@_Invoice_No, '00000'))  
  
          if ( Isnull(@ComplainNo, '') = '' )  
            begin  
                SET @RetMsg = 'Please Enter New Complain No.'  
                SET @RetVal = -102  
				set @Complain_No = ''
  
                return  
            END  
  
          If Exists (select 1  
                     from   Complains with(rowlock)  
                     where  Complain_No = @ComplainNo)  
            begin  
                SET @RetMsg = 'Complain No [' + convert(VARCHAR(50), @ComplainNo) + ' ] Already Exists , Please Enter New Complain No.'  
                SET @RetVal = -101  
				set @Complain_No = ''
                return  
            end  
  
          BEGIN try  
              BEGIN TRANSACTION  
  
              /************************************* TRANSACTION *************************************/  
              INSERT INTO [dbo].[Complains] WITH ( rowlock )  
                          ([Complain_No],  
                           [Complain_Title_Id],  
                           [Cust_Name],  
                           [Cust_Address],  
                           [Area],  
                           [Pin_Code],  
                           [Contact_Person],  
                           [Contact_Person_No],  
                           [Contact_No],  
                           [Project_Type_Id],  
                           [Year_of_Site],  
                           [Complaint_Type_Id],  
                           [Payment_Type_Id],  
                           [Complain_Details],  
                           [Remark],  
                           [MAC_Add],  
                           [Entry_User],  
                           [Entry_Date],  
                           [Upd_User],  
                           [Upd_Date],  
                           [Year_Id],  
                           [Branch_ID],  
                           [Complain_Date],  
                           [Invoice_No],
                           [Complain_Paid_Unpain],  
						   [Complain_Status_Id],  
						   [Complain_Closure],  
						   [MR_OR_Glass_Order_Date],  
						   [MR_OR_Glass_Order_No],
						   [Quotation_No],  
						   [Owner_No],  
						   [Owner_Name],
						   [Complain_Registration_date])  
              VALUES      (@ComplainNo,  
                           @Complain_Title_Id,  
                           @Cust_Name,  
                           @Cust_Address,  
                           @Area,  
                           @Pin_Code,  
                           @Contact_Person,  
                           @Contact_Person_No,  
                           @Contact_No,  
                           @Project_Type_Id,  
                           @Year_of_Site,  
                           @Complaint_Type_Id,  
                           @Payment_Type_Id,  
                           @Complain_Details,  
                           @Remark,  
                           @MAC_Add,  
                           @Entry_User,  
                           dbo.Get_sysdate(),  
                           0,  
                           '1900-01-01',  
                           @Year_Id,  
                           @Branch_ID,  
                           dbo.Get_sysdate(),  
                           @_Invoice_No,
                           @Complain_Paid_Unpain,  
						   @Complain_Status_Id,  
						   @Complain_Closure,  
						   @MR_OR_Glass_Order_Date,  
						   @MR_OR_Glass_Order_No,
						   @Quotation_No,  
						   @Owner_No,  
						   @Owner_Name,
						   @Complain_Registration_date)  
  
              SET @RetVal = Scope_identity()  
              SET @RetMsg = 'Complain No [' + convert(VARCHAR(50), @ComplainNo) + ' ] Generate Successfully.'  
  			  set @Complain_No = @ComplainNo
              IF @@ERROR <> 0  
                BEGIN  
                    SET @RetVal = 0 -- 0 IS FOR ERROR                      
                    SET @RetMsg ='Error Occurred - ' + Error_message() + '.' 
					set @Complain_No = ''
                END  
  
              COMMIT  
          /************************************* COMMIT *************************************/  
          END try  
  
          BEGIN catch  
              ROLLBACK  
  
              /************************************* ROLLBACK *************************************/  
              SET @RetVal = -405 -- 0 IS FOR ERROR                      
              SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
				set @Complain_No = ''
          END catch  
      END  
    ELSE  
      BEGIN  
          IF NOT EXISTS(SELECT 1  
                        FROM   Complains WITH (nolock)  
                        WHERE  Complain_Id = @Complain_Id)  
            BEGIN  
                SET @RetVal = -120 -- 2 MEANS RECORD IS ALREADY BEEN DELETED BY ANOTHER USER.                            
                SET @RetMsg = 'This Complains Is Already Been Deleted By Another User.'  
                RETURN  
            END  
  
          UPDATE [dbo].[Complains] WITH (rowlock)  
          SET    [Complain_Title_Id] = @Complain_Title_Id,  
                 [Cust_Name] = @Cust_Name,  
                 [Cust_Address] = @Cust_Address,  
                 [Area] = @Area,  
                 [Pin_Code] = @Pin_Code,  
                 [Contact_Person] = @Contact_Person,  
                 [Contact_Person_No] = @Contact_Person_No,  
                 [Contact_No] = @Contact_No,  
                 [Project_Type_Id] = @Project_Type_Id,  
                 [Year_of_Site] = @Year_of_Site,  
                 [Complaint_Type_Id] = @Complaint_Type_Id,  
                 [Payment_Type_Id] = @Payment_Type_Id,  
                 [Complain_Details] = @Complain_Details,  
                 [Remark] = @Remark,  
                   [Complain_Paid_Unpain] = @Complain_Paid_Unpain,  
				   [Complain_Status_Id] = @Complain_Status_Id,  
				   [Complain_Closure] = @Complain_Closure,  
				   [MR_OR_Glass_Order_Date] = @MR_OR_Glass_Order_Date,  
				   [MR_OR_Glass_Order_No] = @MR_OR_Glass_Order_No,
				   [Quotation_No] = @Quotation_No,  
				   [Owner_No] = @Owner_No,  
				   [Owner_Name] = @Owner_Name,
				   [Complain_Registration_date] = @Complain_Registration_date,
				   [Complain_Closing_date] = @Complain_Closing_date,
                 [Upd_User] = @Upd_User,  
                 [Upd_Date] = dbo.Get_sysdate()  
          WHERE  Complain_Id = @Complain_Id  
  
          IF @@ERROR = 0  
           BEGIN  
    SET @RetVal = @Complain_Id -- 1 IS FOR SUCCESSFULLY EXECUTED                                 
    SET @RetMsg = 'Complain Details Update Successfully.' 
    SET @Complain_No = (SELECT Complain_No  
                        FROM   Complains WITH (nolock)  
                        WHERE  Complain_Id = @Complain_Id)
END
          ELSE  
            BEGIN  
                SET @RetVal = -1 -- 0 WHEN AN ERROR HAS OCCURED                              
                SET @RetMsg ='Error Occurred - ' + Error_message() + '.'  
				set @Complain_No = ''
            END  
      END 
GO


