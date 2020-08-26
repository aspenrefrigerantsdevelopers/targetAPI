<%@ page trace="false" language="VB" masterpagefile="~/Default.master" autoeventwireup="true" inherits="Shipping_EditWarehouseReceipt, App_Web_uis0etrg" theme="Theme1" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ MasterType  typename="_DefaultMaster" %>
<script runat="server">
    <System.Web.Services.WebMethod()> _
    <Microsoft.Web.Script.Services.ScriptMethod()> _
    Public Shared Function GetOrderNotes(ByVal contextKey As Integer) As String
        'todo - beta version of ajax requires this not to be in code behind - move back to code behind
        Dim conn As New DBConnect()
        
        ' Trace.Warn("GetOrderNotes")
        Dim strSQL As String
        strSQL = "SELECT NoteStanding, " & _
            "NoteDate, " & _
            "NoteText, " & _
            "UMNAME, " & _
            "NoteAuthor " & _
            "FROM Notes LEFT JOIN USERMST On " & _
            "NoteAuthor = UMUSCD " & _
            "WHERE NoteOrderNumber = @OrderNumber " & _
            "ORDER BY NoteStanding DESC, NoteDate DESC"

        Dim da As New SqlDataAdapter(strSQL, conn.Connection)
        da.SelectCommand.Parameters.Add("@OrderNumber", SqlDbType.Int, 4)
        da.SelectCommand.Parameters("@OrderNumber").Value = CInt(CType(Left(contextKey.ToString, 6), String))
        Dim strOutput As New Text.StringBuilder
        Dim dt As New DataTable
        Dim dr As DataRow
        da.Fill(dt)
        If dt.Rows.Count = 0 Then
            strOutput.Append("None")
        Else
            For Each dr In dt.Rows

                If CType(dr("NoteStanding"), Boolean) Then
                    strOutput.Append("<font color=""red"" style=""font-size:11pt""><b>")
                End If
                If CType(dr("NoteDate"), Date) = CDate("01-01-1900") Then
                    'Response.Write "<b>0/0/00</b> - "
                Else
                    strOutput.Append("<b>" & String.Format("{0:M/dd/yy}", dr("NoteDate")) & "</b> - ")
                End If
                strOutput.Append(Replace(dr("NoteText").ToString, vbNewLine, "<br>"))
                If Trim(dr("UMNAME").ToString) <> "" Then
                    strOutput.Append(" <i>by&nbsp;" & Replace(Trim(dr("UMNAME").ToString), " ", "&nbsp;") & "&nbsp;(" & dr("NoteAuthor").ToString & ")</i>")
                ElseIf Trim(dr("NoteAuthor").ToString) <> "" Then
                    strOutput.Append(" <i>by&nbsp;" & dr("NoteAuthor").ToString & "</i>")
                End If
                If CType(dr("NoteDate"), Date) <> CDate("01-01-1900") Then
                    strOutput.Append("<i>&nbsp;at&nbsp;" & Replace(String.Format("{0:M/dd/yy}", dr("NoteDate")), " ", "&nbsp;") & "</i>")
                End If
                If CType(dr("NoteStanding"), Boolean) Then
                    strOutput.Append("</b></font>")
                End If
                'strOutput.Append(" - <a href=""/apps/notes/addedit.asp?NoteID=" & dr("NoteID") & """ onclick=""NoteWindow" & dr("NoteID") & "=window.open(this.href, 'NoteWindow" & dr("NoteID") & "', 'height=180, width=450, channelmode=no, directories=no, fullscreen=no, location=no, menubar=no, resizeable=no, scrollbars=no, status=no, titlebar=yes, toolbar=no'); NoteWindow" & dr("NoteID") & ".focus(); return false;"" style=""color:blue; text-decoration:underline;"">Edit</a>")
                'strOutput.Append(" | <a href=""/apps/notes/delete.asp?NoteID=" & dr("NoteID") & """ onclick=""JavaScript: if(confirm('Are you sure you want to delete this note?')){DeleteWindow" & dr("NoteID") & "=window.open(this.href, 'DeleteWindow" & dr("NoteID") & "', 'height=1, width=1, channelmode=no, directories=no, fullscreen=no, location=no, menubar=no, resizeable=no, scrollbars=no, status=no, titlebar=no, toolbar=no');}; return false;"" style=""color:blue; text-decoration:underline;"">Delete</a>")
                strOutput.Append("<br><br>")
            Next
        End If
        dt.Dispose()
        da.Dispose()
        conn.Dispose()
        
        Return strOutput.ToString
    End Function

    </script>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

<script language="javascript" type="text/javascript">

function updateVendorCode(vendorCode, vendorName){
    document.all.<%=_TxtVendorCode.ClientID %>.value = vendorCode;
     document.all.<%=_HdnOriginalVendorCode.ClientID %>.value = vendorCode;
   document.all.<%=_LblVendorName.ClientID %>.innerText = vendorName;
    
    return true;
}

var searchVendorParent = true;

function checkVendor(){
    var vendorCode = document.all.<%= _TxtVendorCode.ClientID %>.value;
    var origVendorCode = document.all.<%= _HdnOriginalVendorCode.ClientID %>.value;
   // alert(1)
    if(vendorCode != ''){
       // alert(2)
        if(vendorCode != origVendorCode){
        //    alert(3)
            window.open('searchVendor.aspx?SearchText=' + escape(vendorCode), 'new_vendor_search', 'toolbar=no, width=750, height=400, dependant=yes, alwaysRaised=yes, menubar=no, resizable=yes, scrollbars=yes, status=yes, location=no', true);
        }
    }
}
</script>
    <ajax:ScriptManager runat="server"
        ID="ScriptManager1" 
        EnablePartialRendering="true" />  
   
    <asp:ValidationSummary ID="_ValidationSummary"  runat="server" />
    <br />  
    
    <asp:Panel ID="_PnlLinkedOrders" runat="server" >
    <asp:Table runat="server"
        id="_TblLookupOrder"
        SkinID="GreyGridviewHeader"
        >
        <asp:TableHeaderRow>    
            <asp:TableHeaderCell>
                <b>Orders associated with this warehouse receipt:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lookup Order: <asp:Textbox ID="_TxtLookupOrders" runat="server" />
                <asp:Button ID="_BtnAddOrder" CausesValidation="false" runat="server" Text="Search" />
                <asp:Label ID="_LblLookupOrdersError" runat="server" />
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
    </asp:Table>
        <asp:GridView ID="_GVVerifyOrderLink" SkinID="GreyColumnHeaders" runat="server" visible="false" DataSourceID="_SdsVerifyOrderLink">
        <Columns>
            <asp:TemplateField>    
                <ItemTemplate>
                    <asp:LinkButton ID="_LnkConfirmOrderLink"  CausesValidation="false"
                        CommandArgument='<%# Eval("OHORNU") %>' Text="Link Order"
                        runat="server" OnCommand="LinkOrderLinkButton_Command" />
                    <asp:Label ID="_LblConfirmOrderError" Visible="false" runat="server" />
              </ItemTemplate>
            </asp:TemplateField>              
            <asp:BoundField DataField="BillOfLadingNumber" HeaderText="B/L #" SortExpression="BillOfLadingNumber" />
             <asp:TemplateField 
                    HeaderText="Ship Date" 
                    SortExpression="ShipDate" 
                    >
                <ItemTemplate>        
                    <asp:Label runat="server" ID="ShipDateLabel" /> 
                </ItemTemplate>   
            </asp:TemplateField>           
             <asp:BoundField DataField="WarehouseCode" HeaderText="Whs Code" SortExpression="WarehouseCode" />
            <asp:BoundField DataField="InOut" HeaderText="I/O" SortExpression="InOut" />
 
            <asp:TemplateField HeaderText="Order #" SortExpression="OHORNU">
                <ItemTemplate>
                    <asp:hyperlink runat="server" 
                        ID="_LnkOrderGridOrderDetails" 
                        NavigateUrl='javascript:void(0)' 
                        text='<%# Eval("OHORNU") %>'
                         
                        />
                   <asp:Label runat="server" 
                        ID="_LblOrderGridOrderStatus" 
                        Text='<%# " " & Eval("OHSTAT").ToString.replace("F","") %>' />
                  
                    
                </ItemTemplate>
                
            </asp:TemplateField>
   
 
        </Columns>

        </asp:GridView>
        <asp:SqlDataSource ID="_SdsVerifyOrderLink" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
            SelectCommand="Select 1 as placeholder">
            <SelectParameters>
                <asp:ControlParameter ControlID="_TxtLookupOrders" Name="OrderNumber" PropertyName="Text" />
            </SelectParameters>
        </asp:SqlDataSource>
        
     
    <asp:GridView runat="server" 
        EmptyDataText="There are no Orders Linked to this Warehouse Receipt" 
        ID="_GVOrders" 
        DataSourceID="_SdsOrders" 
        AutoGenerateColumns="False"    
        SkinID="GreyColumnHeaders">
        
            <Columns>    
                <asp:BoundField 
                    DataField="OrderNumber" 
                    HeaderText="Order#" 
                    ReadOnly="True"
                    SortExpression="OrderNumber" 
                    />       
                <asp:TemplateField 
                    HeaderText="ShipDate" 
                    SortExpression="ShipDate" 
                    >
                    <ItemTemplate>        
                        <asp:Label runat="server" ID="ShipDateLabel" /> 
                    </ItemTemplate>   
                </asp:TemplateField>   
                <asp:BoundField 
                    DataField="BLNumber" 
                    HeaderText="B/L#" SortExpression="BLNumber" 
                    />
            <asp:TemplateField
                 
                HeaderText="Customer" 
                SortExpression="CustomerName">
                
                <ItemTemplate>
                    <%# Eval("CustomerName") %><br />
                    <%#Eval("CustomerAddress")%>
                
                </ItemTemplate>
                
                </asp:TemplateField>
            <asp:BoundField 
                DataField="TotalGrossWeight" 
                HeaderText="Gross Wgt." 
                SortExpression="TotalGrossWeight" 
                />
            <asp:BoundField 
                DataField="FromWhsZip" 
                HeaderText="From Whs/Zip" 
                SortExpression="FromWhsZip" 
                />
           <asp:TemplateField HeaderText="Details">
                <ItemTemplate>  
                    <asp:Label runat="server"
                        id="_LblOrderDetails"
                        />
                </ItemTemplate>
             
             </asp:TemplateField>
            <asp:TemplateField>
            
                <ItemTemplate>
                    <asp:hyperlink runat="server" 
                        ID="ViewAddNotesLink" 
                        text="View/Add Notes" 
                        />
                    <ajaxToolkit:HoverMenuExtender runat="server"
                        id="NotesHoverExtender"
                        PopupPosition="Bottom"                            
                        TargetControlID="ViewAddNotesLink"    
                        PopupControlID="OrderNotesPanel" 
                        DynamicControlID="OrderNotesPanelLabel"   
                        DynamicContextKey='<%# Eval("OrderNumber") %>' 
                        DynamicServiceMethod="GetOrderNotes"
                        OffsetX="-12" 
                            />
                    <br />
                 <asp:LinkButton ID="RemoveOrdersLinkButton"  CausesValidation="false"
                                     CommandArgument='<%# Eval("OrderNumber") %>' Text="Remove"
                                     runat="server" OnCommand="RemoveOrdersLinkButton_Command" />
              </ItemTemplate>
                
            </asp:TemplateField>
            
        </Columns>
    </asp:GridView>
    
     <br />
     <asp:SqlDataSource runat="server" 
        ID="_SdsOrders" 
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        >
        <SelectParameters>
            <asp:ControlParameter 
                ControlID="_HdnWarehouseReceiptID" 
                Type="Int32" 
                Name="WarehouseReceiptID" 
                PropertyName="Value" 
                />
        </SelectParameters>
    </asp:SqlDataSource>
       <%-- <atlas:AutoCompleteExtender runat="server" 
        ID="AtlasOrderLookupExtender" 
        MinimumPrefixLength="1" 
        ServiceMethod="LookupOrders" 
        >
        <atlas:AutoCompleteProperties 
            Enabled="true"
            TargetControlID="_TxtLookupOrders" 
            ServicePath="~/WebServices/AtlasWS.asmx" 
            />
    </atlas:AutoCompleteExtender>--%>

    </asp:Panel>
    <asp:HiddenField ID="_HdnWarehouseReceiptId" runat="server" />
    <asp:HiddenField ID="_HdnVendorName" runat="server" />
    <asp:HiddenField ID="_HdnVendorCode" runat="server" />
    
    <asp:Table runat="server" ID="ManualOrderTable">
        <asp:TableRow>
            <asp:TableCell>
                <span style="text-decoration:underline;font-weight:bold;">Manual Entry:</span><br />
                B/L #: <asp:TextBox runat="server" ID="_TxtBLNumber" Width="50px" />
                Ship Date: <asp:TextBox runat="server" ID="_TxtShipDate" Width="60px" />
                From Whs: <asp:TextBox runat="server" ID="_TxtFromWarehouse" Width="39px" />&nbsp;&nbsp;&nbsp;
                From Zip:<asp:TextBox runat="server" ID="_TxtFromZip" Width="45px" /> &nbsp;&nbsp;&nbsp;
                To Zip:<asp:TextBox runat="server" ID="_TxtToZip" Width="48px" /> 
                Gross wgt: <asp:TextBox runat="server" ID="_TxtGrossWeight" Width="59px" />
                # of Items: <asp:TextBox runat="server" ID="_TxtItemCount" Width="59px" />
                Miles: <asp:TextBox runat="server" Enabled="false" ID="_TxtMiles" Width="59px" />
                <br />
                <asp:Button runat="server" CausesValidation="false"  ID="_BtnUpdateManualEntry" Text="Update Mileage" />
            </asp:TableCell>
         </asp:TableRow>
         <asp:TableRow>
            <asp:TableCell />
        </asp:TableRow>
    </asp:Table>

    
    <br />
    
    <asp:Table ID="Table1" runat="server">
        <asp:TableHeaderRow>
            <asp:TableHeaderCell>
                Warehouse Receipt
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
        <asp:TableRow>
            <asp:TableCell>
                Receipt #:&nbsp;<asp:TextBox runat="server" ID="_TxtReceiptNumber" MaxLength="12" />
                Receipt Date:&nbsp;<asp:TextBox runat="server" ID="_TxtReceiptInvoiceDate" />
                Receipt Charge:&nbsp;<asp:TextBox runat="server" Width="75px" ID="_TxtReceiptAmount" />
            </asp:TableCell> 
       </asp:TableRow>   
       
       <asp:TableRow>
            <asp:TableCell>
            <asp:HiddenField runat="server"
                    id="_HdnOriginalVendorCode"
                    />
                <asp:HyperLink runat="server"
                    ID="_LnkUseWhsCode"    
                    NavigateUrl="javascript:void(0);" 
                    Text="Use Whse Code"
                    />&nbsp;&nbsp;
                <asp:Repeater runat="server"
                    id="_RptVendorQuickLookup"
                    >
                    <ItemTemplate>
                        <asp:HyperLink runat="server"
                             NavigateUrl="javascript:void(0)"
                            id="_LnkVendorQuickLookup"
                             />
                    </ItemTemplate>
                    <SeparatorTemplate>&nbsp;&nbsp;</SeparatorTemplate>
                </asp:Repeater>&nbsp;&nbsp;
                <br />Vendor#:&nbsp;<asp:TextBox runat="server" ID="_TxtVendorCode"  SkinID="SearchableInput"/>
                Vendor Name:&nbsp;<asp:Label runat="server" ID="_LblVendorName" Text=""/>
                &nbsp;&nbsp;&nbsp;
                Payment Code:
                <asp:DropDownList runat="server"
                    ID="_DdlPaymentCode" 
                    DataSourceID="_SdsPayentCodes" 
                    DataTextField="PaymentCodeName" 
                    DataValueField="PaymentCodeID"
                    />
                <br />
                Batch#: <asp:Label runat="server" ID="_LblBatchNumber" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                Voucher#:&nbsp;<asp:Label runat="server" ID="_LblVoucherNumber" />
                
            </asp:TableCell>
       </asp:TableRow>
       <asp:TableRow>
            <asp:TableCell>
                <div style="float:left;">Comments:</div>
                <asp:TextBox runat="server" 
                    Width="40%" 
                    Rows="3" 
                    TextMode="MultiLine" 
                    ID="_TxtComments" 
                    />
            </asp:TableCell>
        </asp:TableRow> 
    </asp:Table>
    <asp:Button runat="server" Text="Save And Search Again" ID="_BtnSaveAndExit" />
    <asp:Button runat="server" Text="Save" ID="_BtnSave" />
    <asp:Button runat="server" Text="Search" CausesValidation="false" ID="_BtnExit" />
    <br />
    <asp:Label runat="server" ID="_LblUpdated" />
    
    <asp:SqlDataSource runat="server" 
        ID="_SdsPayentCodes"   
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        SelectCommand="SELECT [PaymentCodeID], [PaymentCodeName] FROM [PaymentCodes]"/>
 
    <asp:Panel runat="server"   
        ID="OrderNotesPanel" 
        Width="40%"   
        style="visibility:hidden;" 
        CssClass="popupHover" 
        >&nbsp;
        <div style="position:absolute;width:100%;height:100%;top:0px;left:0px;border:solid 1px black;z-index:0;background-color:white;">
            <asp:Label ID="OrderNotesPanelLabel" Height="100%" Width="100%" runat="server" />
        </div>
    </asp:Panel>
    <asp:Panel ID="Panel1" runat="server" CssClass="popupControl">
        <ajax:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <iframe 
                    src="about:blank" 
                    scrolling="no" 
                    frameborder="0"
                    style="background-color:black;position:absolute;width:162px;height:125px;top:0px;left:0px;border:none;display:block;z-index:0" ></iframe>
                <div 
                    style="position:absolute;width:1px;height:125px;top:0px;left:0px;border:solid 1px black;z-index:0"
                    >
                    <center>
                        <asp:Calendar runat="server" 
                            ID="Calendar1" 
                            OnSelectionChanged="Calendar1_SelectionChanged"
                            />
                            
                    </center>
                </div>
            </ContentTemplate>
        </ajax:UpdatePanel>
    </asp:Panel>

 <%--   <ajaxToolkit:PopupControlExtender runat="server" 
        ID="_PceReceiptInvoiceDate"
            TargetControlID="_TxtReceiptInvoiceDate" 
            PopupControlID="Panel1" 
            Position="Right" 
            />
        <ajaxToolkit:PopupControlExtender runat="server"
            ID="_PceShipDate"
            TargetControlID="_TxtShipDate" 
            PopupControlID="Panel1" 
            Position="Right" 
            />--%>


    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtReceiptNumber" 
        Display="None" 
        ErrorMessage="Receipt # is a required field"  
        ControlToValidate="_TxtReceiptNumber" 
        />
    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtReceiptInvoiceDate" 
        Display="None" 
        ErrorMessage="Receipt Date is a required field"  
        ControlToValidate="_TxtReceiptInvoiceDate" 
        />
    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtReceiptAmount" 
        Display="None" 
        ErrorMessage="Receipt Charge is a required field"  
        ControlToValidate="_TxtReceiptAmount" 
        />
    <asp:RangeValidator runat="server" 
        ID="_RV_TxtReceiptInvoiceDate" 
        Display="None" 
        ControlToValidate="_TxtReceiptInvoiceDate" 
        Type="Date" 
        ErrorMessage="Receipt Date must be a valid date within the last 12 months"
        />

    <asp:CompareValidator runat="server" 
        ID="_CV_TxtReceiptAmount" 
        Display="None" 
        ControlToValidate="_TxtReceiptAmount" 
        Operator="DataTypeCheck" 
        Type="Currency" 
        ErrorMessage="Receipt Charge is not a valid amount" 
        />
            <asp:CompareValidator runat="server" 
        ID="_CV_TxtVendorCode" 
        Display="None" 
        ControlToValidate="_TxtVendorCode" 
        Operator="DataTypeCheck" 
        Type="Integer"
        ErrorMessage="Vendor Number should be numeric" 
        />
        <asp:CustomValidator runat="server" 
        ID="_Cuv_DdlPaymentCode"
        Display="none"
        ControlToValidate="_DdlPaymentCode"
         ErrorMessage='Vendor# must be valid to assign a Payment Code of ""Pay Now""'
        />
</asp:Content>

     