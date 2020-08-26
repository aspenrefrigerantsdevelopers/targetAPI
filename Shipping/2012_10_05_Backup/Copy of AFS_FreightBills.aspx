<%@ Page Title="" Language="VB" Trace="false" MasterPageFile="~/Default.master" AutoEventWireup="true" CodeFile="Copy of AFS_FreightBills.aspx.vb" Inherits="AFS_FrieghtBills"  %>
<%@ MasterType  typename="_DefaultMaster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

<asp:Panel ID="pnl_Upload" runat="server">

<br />
     <asp:ValidationSummary ID="_ValidationSummary"  runat="server" />
    <asp:Table ID="tbl_AuditFreightCharges" runat="server">
    <asp:TableHeaderRow >
        <asp:TableCell ColumnSpan="2" >
            Upload AFS Bill File 
        </asp:TableCell>
        <asp:TableCell HorizontalAlign="Right">
<%--            <asp:HyperLink ID="HyperLink1" runat="server"
                Text="Add Frt Charge"  
                NavigateUrl="~/Shipping/EditFreightCharge3.aspx?fid=0" 
                />--%>
        </asp:TableCell>
    </asp:TableHeaderRow>
   <asp:TableRow>
        <asp:TableCell Width="25%" >
            <asp:Label ID="Label4" runat="server" Text="Upload New Excel File :"></asp:Label>    
        </asp:TableCell>
        <asp:TableCell  ColumnSpan="2" >
       
      <asp:FileUpload ID="FileUpload1" runat="server" />
    <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
    <br />
    <asp:Label ID="lblMessage" runat="server" Text="" /> <br/>         
               
        </asp:TableCell>
    </asp:TableRow>

     </asp:Table>

    <br /><br />
    
    
    <asp:Table runat="server" 
        id="_TblFreghtChargeResultsHeader"
        SkinID="GreyGridviewHeader"
        >
        <asp:TableHeaderRow>
            <asp:TableHeaderCell>
                Current Exceptions 
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
        
 
         <asp:TableRow>    
          <asp:TableCell>&nbsp;
         </asp:TableCell>
        </asp:TableRow>   
           
       <asp:TableRow>
        <asp:TableCell>
        
            <asp:Label ID="lbl_NoOrderNum" runat="server" Text=""><Strong>Exceptions Without Order Numbers: </Strong></asp:Label>
 
        </asp:TableCell>
    </asp:TableRow>
    
        <asp:TableRow>    
          <asp:TableCell>

            <asp:Label ID="lbl_FreightPaid" runat="server" Text=""><Strong>Exception Orders with Paid Freight: </Strong></asp:Label>        
 
        </asp:TableCell>
    </asp:TableRow>   
    
        <asp:TableRow>    
          <asp:TableCell>&nbsp;
         </asp:TableCell>
    </asp:TableRow>   
       
        
        
   <asp:TableRow>
        <asp:TableCell>

 <asp:RadioButton  runat="server" 
                    Text="Unmatched Order Numbers" 
                    GroupName="rdo_Exceptions" 
                    ID="rdo_ByOrderNum"
                    Checked="true"
                    AutoPostBack = "True"
                    OnCheckedChanged = "rdo_Exceptions_CheckChanged"                    
                    /> 
                    
                    &nbsp;
                <asp:RadioButton  runat="server" 
                    Text="Orders w/ Paid Freight" 
                    GroupName="rdo_Exceptions" 
                    ID="rdo_ByPaidFreight"
                    AutoPostBack = "True"
                    OnCheckedChanged = "rdo_Exceptions_CheckChanged"
                    />
                    
                    
<%--                <asp:RadioButton  runat="server" 
                    Text="Bill of Lading Number" 
                    GroupName="rdo_Exceptions" 
                    ID="rdo_ByBOLNum"
                    AutoPostBack = "True"
                    OnCheckedChanged = "rdo_Exceptions_CheckChanged"                    
                    />--%>
 
        </asp:TableCell>
    </asp:TableRow>
        
    </asp:Table>
    


</asp:Panel>



<asp:Panel ID="pnl_UploadDetail" runat="server" Visible = "false" >

<br />
    <asp:Table ID="Table1" runat="server">
    <asp:TableHeaderRow >
        <asp:TableCell ColumnSpan="2" >
            AFS Bill File Information
        </asp:TableCell>
        <asp:TableCell HorizontalAlign="Right">

        </asp:TableCell>
    </asp:TableHeaderRow>
   <asp:TableRow>
        <asp:TableCell Width="25%" >
            <asp:Label ID="Label1" runat="server" Text="Excel File Name:"/>    
        </asp:TableCell>
        <asp:TableCell  ColumnSpan="2" >
       
        <asp:Label ID="lblFileName" runat="server" Text=""/>
    <br />
      
               
        </asp:TableCell>
    </asp:TableRow>
    
    
    
    <asp:TableRow>
        <asp:TableCell Width="25%" >
            <asp:Label ID="Label3" runat="server" Text="AFS Invoice Number:"/>    
        </asp:TableCell>
        <asp:TableCell  ColumnSpan="2" >
       <asp:Label ID="lblAFS_Invoice" runat="server" Text=""/> 
    <asp:DropDownList ID="ddlSheets" runat="server" AppendDataBoundItems = "true" Visible="false">
    </asp:DropDownList>
    <br />
      
               
        </asp:TableCell>
    </asp:TableRow>   
    
    

     </asp:Table>

        <br /><br />

    <br />
    
<%--    <asp:Label ID="Label3" runat="server" Text="Enter Source Table Name"/>
    <asp:TextBox ID="txtTable" runat="server"></asp:TextBox>
    
    <br />
    
    <asp:Label ID="Label1" runat="server" Text="Has Header Row?" />
    
    <br />
    
    <asp:RadioButtonList ID="rbHDR" runat="server">
    
        <asp:ListItem Text = "Yes" Value = "Yes" Selected = "True" ></asp:ListItem>
        <asp:ListItem Text = "No" Value = "No"></asp:ListItem>
    
    </asp:RadioButtonList>--%>
    
    <br />
    
    <asp:Button ID="btnSave" runat="server" Text="Load AFS Bills" OnClick="btnSave_Click" />
    
    <asp:Button ID="btnCancel" runat="server" Text="Cancel" OnClick="btnCancel_Click" />
<asp:Button ID="btnSaveAlt" runat="server" OnClick="btnSaveAlt_Click" Text="Alt. Load AFS Bills" /> 
    

 </asp:Panel>
       
        <asp:Panel ID="pnl_ByOrderNum" runat="server">
            &nbsp;<asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="sds_ExceptnByOrderNum" PageSize="20" AllowPaging="True">
                <Columns>
                    <asp:CommandField InsertVisible="False" ShowEditButton="True" />
                    <asp:BoundField DataField="AFS_Bill_id" HeaderText="AFS_Bill_id" SortExpression="AFS_Bill_id"
                        Visible="False" />
                
                      <asp:TemplateField HeaderText="Audited" SortExpression="Audit">
                        <EditItemTemplate>
                            <asp:TextBox ID="txt_Audit" runat="server" Text='<%# Bind("Audit") %>' Visible="False"></asp:TextBox>
                            <asp:CheckBox ID="chk_Audit" runat="server" Checked='<%# Bind("Audit") %>' />
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lbl_Audit" runat="server" Text='<%# DisplayAudit(System.Convert.ToBoolean(Eval("Audit"))) %>' ></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                  
                    <asp:BoundField DataField="RIS_Order" HeaderText="RIS_Order" SortExpression="RIS_Order" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier #" HeaderText="Carrier #" SortExpression="Carrier #" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier Name" HeaderText="Carrier Name" SortExpression="Carrier Name" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Code" HeaderText="Trans Code" SortExpression="Trans Code" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Mode" HeaderText="Trans Mode" SortExpression="Trans Mode" ReadOnly="True" />
                    <asp:BoundField DataField="AFS_Invoice" HeaderText="AFS_Invoice" SortExpression="AFS_Invoice" ReadOnly="True" />
                    <asp:BoundField DataField="Pro #" HeaderText="Pro #" SortExpression="Pro #" ReadOnly="True" />
                    <asp:BoundField DataField="InvoiceProNumber" HeaderText="InvoiceProNumber" ReadOnly="True"
                        SortExpression="InvoiceProNumber" />
                    <asp:BoundField DataField="Bill Date" HeaderText="Bill Date" SortExpression="Bill Date" DataFormatString="{0:d}" ReadOnly="True" />
                    <asp:BoundField DataField="I/O" HeaderText="I/O" SortExpression="I/O" ReadOnly="True" />
                    <asp:BoundField DataField="Origin Zip" HeaderText="Origin Zip" SortExpression="Origin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Origin City" HeaderText="Origin City" SortExpression="Origin City" ReadOnly="True" />
                    <asp:BoundField DataField="Origin St" HeaderText="Origin St" SortExpression="Origin St" ReadOnly="True" />
                    <asp:BoundField DataField="Destin Zip" HeaderText="Destin Zip" SortExpression="Destin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Destin City" HeaderText="Destin City" SortExpression="Destin City" ReadOnly="True" />
                    <asp:BoundField DataField="Destin St" HeaderText="Destin St" SortExpression="Destin St" ReadOnly="True" />
                    <asp:BoundField DataField="Expense Code" HeaderText="Expense Code" SortExpression="Expense Code" ReadOnly="True" />
                    <asp:BoundField DataField="Weight" HeaderText="Weight" SortExpression="Weight" ReadOnly="True" />
                    <asp:BoundField DataField="Gross Charge" HeaderText="Gross Charge" SortExpression="Gross Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Actual Charge" HeaderText="Actual Charge" SortExpression="Actual Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Disc Comm" HeaderText="Disc Comm" SortExpression="Disc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Ovc Comm" HeaderText="Ovc Comm" SortExpression="Ovc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Cons Comm" HeaderText="Cons Comm" SortExpression="Cons Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Total_Amount" HeaderText="Total_Amount" SortExpression="Total_Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Division" HeaderText="Division" SortExpression="Division" ReadOnly="True" />
                    <asp:BoundField DataField="Discount Variance" HeaderText="Discount Variance" SortExpression="Discount Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Overcharge Variance" HeaderText="Overcharge Variance"
                        SortExpression="Overcharge Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Consulting Variance" HeaderText="Consulting Variance"
                        SortExpression="Consulting Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Check Amount" HeaderText="Check Amount" SortExpression="Check Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Check Number" HeaderText="Check Number" SortExpression="Check Number" ReadOnly="True" />
                    <asp:BoundField DataField="Check Date" HeaderText="Check Date" SortExpression="Check Date" ReadOnly="True" />
                    <asp:BoundField DataField="Bill of Lading" HeaderText="Bill of Lading" SortExpression="Bill of Lading" ReadOnly="True" />
                    <asp:BoundField DataField="Cust/Vend" HeaderText="Cust/Vend" SortExpression="Cust/Vend" ReadOnly="True" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="sds_ExceptnByOrderNum" runat="server" ConnectionString="Data Source=argedsrefsql001;Initial Catalog=Refron;Persist Security Info=True;User ID=intranet;Password=Temp123"
                ProviderName="System.Data.SqlClient" SelectCommand="AFS_Exceptions_Orders_Unknown" SelectCommandType="StoredProcedure">
            </asp:SqlDataSource>
        </asp:Panel>
        
 
        <asp:Panel ID="pnl_ByPaidFreight" runat="server" visible="false">
            &nbsp;<asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" DataSourceID="sds_ExceptnByPaidFreight" PageSize="20" AllowPaging="True">
                <Columns>
                
                    <asp:CommandField InsertVisible="False" ShowEditButton="True" />
                    <asp:BoundField DataField="AFS_Bill_id" HeaderText="AFS_Bill_id" SortExpression="AFS_Bill_id"
                        Visible="False" />
                
                      <asp:TemplateField HeaderText="Audited" SortExpression="Audit">
                        <EditItemTemplate>
                            <asp:TextBox ID="txt_Audit" runat="server" Text='<%# Bind("Audit") %>' Visible="False"></asp:TextBox>
                            <asp:CheckBox ID="chk_Audit" runat="server" Checked='<%# Bind("Audit") %>' />
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lbl_Audit" runat="server" Text='<%# DisplayAudit(System.Convert.ToBoolean(Eval("Audit"))) %>' ></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                  
                    <asp:BoundField DataField="RIS_Order" HeaderText="RIS_Order" SortExpression="RIS_Order" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier #" HeaderText="Carrier #" SortExpression="Carrier #" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier Name" HeaderText="Carrier Name" SortExpression="Carrier Name" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Code" HeaderText="Trans Code" SortExpression="Trans Code" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Mode" HeaderText="Trans Mode" SortExpression="Trans Mode" ReadOnly="True" />
                    <asp:BoundField DataField="AFS_Invoice" HeaderText="AFS_Invoice" SortExpression="AFS_Invoice" ReadOnly="True" />
                    <asp:BoundField DataField="Pro #" HeaderText="Pro #" SortExpression="Pro #" ReadOnly="True" />
                    <asp:BoundField DataField="InvoiceProNumber" HeaderText="InvoiceProNumber" ReadOnly="True"
                        SortExpression="InvoiceProNumber" />
                    <asp:BoundField DataField="Bill Date" HeaderText="Bill Date" SortExpression="Bill Date" DataFormatString="{0:d}" ReadOnly="True" />
                    <asp:BoundField DataField="I/O" HeaderText="I/O" SortExpression="I/O" ReadOnly="True" />
                    <asp:BoundField DataField="Origin Zip" HeaderText="Origin Zip" SortExpression="Origin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Origin City" HeaderText="Origin City" SortExpression="Origin City" ReadOnly="True" />
                    <asp:BoundField DataField="Origin St" HeaderText="Origin St" SortExpression="Origin St" ReadOnly="True" />
                    <asp:BoundField DataField="Destin Zip" HeaderText="Destin Zip" SortExpression="Destin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Destin City" HeaderText="Destin City" SortExpression="Destin City" ReadOnly="True" />
                    <asp:BoundField DataField="Destin St" HeaderText="Destin St" SortExpression="Destin St" ReadOnly="True" />
                    <asp:BoundField DataField="Expense Code" HeaderText="Expense Code" SortExpression="Expense Code" ReadOnly="True" />
                    <asp:BoundField DataField="Weight" HeaderText="Weight" SortExpression="Weight" ReadOnly="True" />
                    <asp:BoundField DataField="Gross Charge" HeaderText="Gross Charge" SortExpression="Gross Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Actual Charge" HeaderText="Actual Charge" SortExpression="Actual Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Disc Comm" HeaderText="Disc Comm" SortExpression="Disc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Ovc Comm" HeaderText="Ovc Comm" SortExpression="Ovc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Cons Comm" HeaderText="Cons Comm" SortExpression="Cons Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Total_Amount" HeaderText="Total_Amount" SortExpression="Total_Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Division" HeaderText="Division" SortExpression="Division" ReadOnly="True" />
                    <asp:BoundField DataField="Discount Variance" HeaderText="Discount Variance" SortExpression="Discount Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Overcharge Variance" HeaderText="Overcharge Variance"
                        SortExpression="Overcharge Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Consulting Variance" HeaderText="Consulting Variance"
                        SortExpression="Consulting Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Check Amount" HeaderText="Check Amount" SortExpression="Check Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Check Number" HeaderText="Check Number" SortExpression="Check Number" ReadOnly="True" />
                    <asp:BoundField DataField="Check Date" HeaderText="Check Date" SortExpression="Check Date" ReadOnly="True" />
                    <asp:BoundField DataField="Bill of Lading" HeaderText="Bill of Lading" SortExpression="Bill of Lading" ReadOnly="True" />
                    <asp:BoundField DataField="Cust/Vend" HeaderText="Cust/Vend" SortExpression="Cust/Vend" ReadOnly="True" />
                    
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="sds_ExceptnByPaidFreight" runat="server" ConnectionString="Data Source=argedsrefsql001;Initial Catalog=Refron;Persist Security Info=True;User ID=intranet;Password=Temp123"
                ProviderName="System.Data.SqlClient" SelectCommand="AFS_Exceptions_Orders_WithPaidFreight" SelectCommandType="StoredProcedure">
            </asp:SqlDataSource>
        </asp:Panel>


        <asp:Panel ID="pnl_ByBOLNum" runat="server" visible="false">
            &nbsp;<asp:GridView ID="GridView3" runat="server" AutoGenerateColumns="False" DataSourceID="sds_ExceptnByBOLNum" PageSize="20" AllowPaging="True">
                <Columns>
                
                    <asp:CommandField InsertVisible="False" ShowEditButton="True" />
                    <asp:BoundField DataField="AFS_Bill_id" HeaderText="AFS_Bill_id" SortExpression="AFS_Bill_id"
                        Visible="False" />
                
                      <asp:TemplateField HeaderText="Audited" SortExpression="Audit">
                        <EditItemTemplate>
                            <asp:TextBox ID="txt_Audit" runat="server" Text='<%# Bind("Audit") %>' Visible="False"></asp:TextBox>
                            <asp:CheckBox ID="chk_Audit" runat="server" Checked='<%# Bind("Audit") %>' />
                        </EditItemTemplate>
                        <ItemTemplate>
                            <asp:Label ID="lbl_Audit" runat="server" Text='<%# DisplayAudit(System.Convert.ToBoolean(Eval("Audit"))) %>' ></asp:Label>
                        </ItemTemplate>
                    </asp:TemplateField>
                  
                    <asp:BoundField DataField="OrderNumber" HeaderText="OrderNumber" SortExpression="OrderNumber" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier #" HeaderText="Carrier #" SortExpression="Carrier #" ReadOnly="True" />
                    <asp:BoundField DataField="Carrier Name" HeaderText="Carrier Name" SortExpression="Carrier Name" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Code" HeaderText="Trans Code" SortExpression="Trans Code" ReadOnly="True" />
                    <asp:BoundField DataField="Trans Mode" HeaderText="Trans Mode" SortExpression="Trans Mode" ReadOnly="True" />
                    <asp:BoundField DataField="AFS_Invoice" HeaderText="AFS_Invoice"  SortExpression="AFS_Invoice" ReadOnly="True" />
                    <asp:BoundField DataField="Pro #" HeaderText="Pro #" SortExpression="Pro #" ReadOnly="True" />
                    <asp:BoundField DataField="InvoiceProNumber" HeaderText="InvoiceProNumber" ReadOnly="True"
                        SortExpression="InvoiceProNumber" />
                    <asp:BoundField DataField="Bill Date" HeaderText="Bill Date" SortExpression="Bill Date" DataFormatString="{0:d}" ReadOnly="True" />
                    <asp:BoundField DataField="I/O" HeaderText="I/O" SortExpression="I/O" ReadOnly="True" />
                    <asp:BoundField DataField="Origin Zip" HeaderText="Origin Zip" SortExpression="Origin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Origin City" HeaderText="Origin City" SortExpression="Origin City" ReadOnly="True" />
                    <asp:BoundField DataField="Origin St" HeaderText="Origin St" SortExpression="Origin St" ReadOnly="True" />
                    <asp:BoundField DataField="Destin Zip" HeaderText="Destin Zip" SortExpression="Destin Zip" ReadOnly="True" />
                    <asp:BoundField DataField="Destin City" HeaderText="Destin City" SortExpression="Destin City" ReadOnly="True" />
                    <asp:BoundField DataField="Destin St" HeaderText="Destin St" SortExpression="Destin St" ReadOnly="True" />
                    <asp:BoundField DataField="Expense Code" HeaderText="Expense Code" SortExpression="Expense Code" ReadOnly="True" />
                    <asp:BoundField DataField="Weight" HeaderText="Weight" SortExpression="Weight" ReadOnly="True" />
                    <asp:BoundField DataField="Gross Charge" HeaderText="Gross Charge" SortExpression="Gross Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Actual Charge" HeaderText="Actual Charge" SortExpression="Actual Charge" ReadOnly="True" />
                    <asp:BoundField DataField="Disc Comm" HeaderText="Disc Comm" SortExpression="Disc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Ovc Comm" HeaderText="Ovc Comm" SortExpression="Ovc Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Cons Comm" HeaderText="Cons Comm" SortExpression="Cons Comm" ReadOnly="True" />
                    <asp:BoundField DataField="Total_Amount" HeaderText="Total_Amount" SortExpression="Total_Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Division" HeaderText="Division" SortExpression="Division" ReadOnly="True" />
                    <asp:BoundField DataField="Discount Variance" HeaderText="Discount Variance" SortExpression="Discount Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Overcharge Variance" HeaderText="Overcharge Variance"
                        SortExpression="Overcharge Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Consulting Variance" HeaderText="Consulting Variance"
                        SortExpression="Consulting Variance" ReadOnly="True" />
                    <asp:BoundField DataField="Check Amount" HeaderText="Check Amount" SortExpression="Check Amount" ReadOnly="True" />
                    <asp:BoundField DataField="Check Number" HeaderText="Check Number" SortExpression="Check Number" ReadOnly="True" />
                    <asp:BoundField DataField="Check Date" HeaderText="Check Date" SortExpression="Check Date" ReadOnly="True" />
                    <asp:BoundField DataField="Bill of Lading" HeaderText="Bill of Lading" SortExpression="Bill of Lading" ReadOnly="True" />
                    <asp:BoundField DataField="Cust/Vend" HeaderText="Cust/Vend" SortExpression="Cust/Vend" ReadOnly="True" />
                    
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="sds_ExceptnByBOLNum" runat="server" ConnectionString="Data Source=argedsrefsql001;Initial Catalog=Refron;Persist Security Info=True;User ID=intranet;Password=Temp123"
                ProviderName="System.Data.SqlClient" SelectCommand="SELECT&#13;&#10;[AFS_Bill_id]&#13;&#10;,COALESCE([Audited],0) AS Audit&#13;&#10;,xOHORNU As OrderNumber&#13;&#10;,[Carrier #]&#13;&#10;,[Carrier Name]&#13;&#10;,[Trans Code]&#13;&#10;,[Trans Mode]&#13;&#10;,'0'+[AFS_Invoice] AS [AFS_Invoice]&#13;&#10;,[Pro #]&#13;&#10;,'0'+[AFS_Invoice]+'-'+CAST(CAST([Pro #] AS DECIMAL(12,0)) AS VARCHAR(50)) AS InvoiceProNumber&#13;&#10;,[Bill Date]&#13;&#10;,[I/O]&#13;&#10;,[Origin Zip]&#13;&#10;,[Origin City]&#13;&#10;,[Origin St]&#13;&#10;,[Destin Zip]&#13;&#10;,[Destin City]&#13;&#10;,[Destin St]&#13;&#10;,[Expense Code]&#13;&#10;,[Weight]&#13;&#10;,[Gross Charge]&#13;&#10;,[Actual Charge]&#13;&#10;,[Disc Comm]&#13;&#10;,[Ovc Comm]&#13;&#10;,[Cons Comm]&#13;&#10;,[Total_Amount]&#13;&#10;,[Division]&#13;&#10;,[Discount Variance]&#13;&#10;,[Overcharge Variance]&#13;&#10;,[Consulting Variance]&#13;&#10;,[Check Amount]&#13;&#10;,[Check Number]&#13;&#10;,[Check Date]&#13;&#10;,[Bill of Lading]&#13;&#10;,[Cust/Vend]&#13;&#10;FROM [Refron].[dbo].[Freight_AFS_Bills] afs&#13;&#10;LEFT OUTER JOIN FreightCharges fc ON&#13;&#10;[Bill of Lading] = BillOfLadingNumber&#13;&#10;LEFT OUTER JOIN FreightChargesExt fcx ON&#13;&#10;FreightChargeID = xFreightChargeID&#13;&#10;LEFT OUTER JOIN &#13;&#10;(SELECT * FROM OrderCarrier WHERE CarrierChoice = 1 ) oc ON&#13;&#10;ORDERID = xOHORNU&#13;&#10;LEFT OUTER JOIN Freight_AFS_Bills_Audit au ON&#13;&#10;AFS_Bill_id = xAFS_Bill_id&#13;&#10;WHERE (xFreightChargeID IS NOT NULL OR FreightChargeID <> 0)&#13;&#10;AND (COALESCE(FreightChargeAmount,0)+COALESCE(AdditionalCharge,0)<>CAST([Total_Amount] AS MONEY)&#13;&#10;OR COALESCE(TrueCost,0) <> CAST([Total_Amount] AS NUMERIC(10,2)))&#13;&#10;AND (COALESCE([Audited],0) = 0) &#13;&#10;ORDER BY xOHORNU">
            </asp:SqlDataSource>
        </asp:Panel>

    <asp:GridView ID="GridView4" runat="server">
    </asp:GridView>

</asp:Content>
