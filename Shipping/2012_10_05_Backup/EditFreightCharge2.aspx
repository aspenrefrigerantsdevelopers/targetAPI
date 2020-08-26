<%@ page language="VB" trace="false" masterpagefile="~/Default.master" autoeventwireup="true" inherits="Shipping_EditFreightCharge, App_Web_uis0etrg" theme="Theme1" %>
<%@ MasterType  typename="_DefaultMaster" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%--<%@ Register Assembly="AtlasControlToolkit" Namespace="AtlasControlToolkit" TagPrefix="atlasToolkit" %>
--%>
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
    
		
	Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

      Dim conn As New DBConnect()
  		Dim strSQL As String

			strSQL = "SELECT [ShipDate] FROM [FreightCharges] WHERE [FreightChargeID]=@FreightChargeID"

			Dim cmd As New SqlCommand(strSQL, conn.Connection)
			cmd.Parameters.AddWithValue("@FreightChargeID", _HdnFreightChargeId.value)
			Dim objOutput As Object = cmd.ExecuteScalar()
						
			If Not IsNothing(objOutput) and Not IsPostBack() Then
			
					Dim strOutput as String = objOutput.ToString
			
					'If System.Convert.ToDateTime(strOutput) < 09/01/2010 then
					If Date.Parse(strOutput) < Date.Parse("09/01/2010") then 
		
						Me._LblGLAccount.Text = strOutput.ToString
						Me._DdlFreightType.Visible = False
						Me._LblGLAccount.Visible = False
						Me._TxtProNumber2.Text = Me._TxtProNumber.Text					
						conn.Dispose()	
										
						Exit Sub
					
					Else
						conn.Dispose()
						
					End if 

			End If

	End Sub
	
	Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles MyBase.PreRender
	
		If Not IsPostBack() Then
			        
				Dim conn As New DBConnect()        
        Dim strSQL As String
        
        strSQL = "SELECT [xFreightChargeID],[FreightType],[FreightTypeName], [ProNumber2], [FreightGL]" & _
										" FROM [FreightChargesExt] LEFT OUTER JOIN FreightType ON FreightTypeID =FreightType " & _
											" WHERE [xFreightChargeID] = @xFreightChargeID" 

				Dim cmd As New SqlCommand(strSQL, conn.Connection)
				cmd.Parameters.AddWithValue("@xFreightChargeID", _HdnFreightChargeId.value)
				Dim rdr As SqlDataReader = cmd.ExecuteReader
		
					If rdr.hasrows = true then
						rdr.read()
						If NOT ISDBNULL(rdr.Item("FreightType")) Then  
							Me._DdlFreightType.SelectedValue = CInt(rdr.Item("FreightType")).ToString()
						Else
							Me._DdlFreightType.SelectedValue = "0"
						End if						
						
						Me._TxtProNumber2.Text = rdr.Item("ProNumber2").ToString()												
						Me._LblGLAccount.Text = rdr.Item("FreightGL").ToString()
						rdr.close
					Else
						rdr.close
						cmd.Parameters.AddWithValue("@FreightType", 0)
						cmd.Parameters.AddWithValue("@ProNumber2", _TxtProNumber2.Text)
									        
						strSQL = "INSERT FreightChargesExt(xFreightChargeID, FreightType, ProNumber2) " & _
												"VALUES(@xFreightChargeID,@FreightType, @ProNumber2 )"
						cmd.CommandText = strSQL						
						cmd.ExecuteNonQuery()
						
						Me._TxtProNumber2.Text = _TxtProNumber.Text					
	        
					End If
					
					 conn.Dispose()
        
      End if	
	
	End Sub
	
	
	Sub _DdlFreightType_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles _DdlFreightType.SelectedIndexChanged
		
		If IsPostBack() Then
		  
			Dim conn As New DBConnect()

			Dim strSQL As String
			strSQL = "SELECT [FreightGL] FROM [FreightType] WHERE [FreightTypeID]=@FreightType"

			Dim cmd As New SqlCommand(strSQL, conn.Connection)
			cmd.Parameters.AddWithValue("FreightType", _DdlFreightType.SelectedValue)
			Dim strOutput As Object = cmd.ExecuteScalar()
			
			If Not IsNothing(strOutput) Then
				Me._LblGLAccount.Text = strOutput.ToString
				_SdsFreightType.Update			
				_DdlFreightType.SelectedValue = _DdlFreightType.SelectedValue	
				
			Else
				
				
			End If
			
			conn.Dispose()			
			
		End if
			
	End Sub
	
	
	
	Sub _TxtProNumber2_TextChanged(ByVal sender As Object, ByVal e As System.EventArgs)
		
		'If len(Me._TxtProNumber.Text)= 0 or Me._TxtProNumber.Text <> Me._TxtProNumber2.Text Then
				Me._TxtProNumber.Text = Left(Me._TxtProNumber2.Text,12)	
			
		'End if			
		
		If IsPostBack() Then

				_SdsFreightChargesExt.Update				
			
		End if
		
	End Sub	

</script>
    



<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">


<script language="javascript" type="text/javascript">
function calculateCzarLite(){
    var freightChargeAmount = document.all.<%=_TxtFreightChargeAmount.ClientID %>.value
    var czarLiteAmount = document.all.<%=_HdnCzarLiteAmount.ClientID %>.value
    var percentage
    
    //alert(czarLiteAmount);
    //alert(isNaN(czarLiteAmount) || isNaN(freightChargeAmount) || czarLiteAmount.replace(/^\s*|\s*$/g,"") == '' || freightChargeAmount.replace(/^\s*|\s*$/g,"") == '')
    
     if(isNaN(czarLiteAmount) || isNaN(freightChargeAmount) || czarLiteAmount.replace(/^\s*|\s*$/g,"") == '' || freightChargeAmount.replace(/^\s*|\s*$/g,"") == ''){
        document.all.<%=_LblCzarLitePercent.ClientID %>.innerText = ""
    }else{  
        percentage = ((freightChargeAmount/czarLiteAmount)-1) * 100
        percentage = Math.round(percentage*100)/100
        document.all.<%=_LblCzarLitePercent.ClientID %>.innerText = "%" + percentage;
    }    
}

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
                <b>Orders associated with this freight charge:</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Lookup Order: <asp:Textbox ID="_TxtLookupOrders" runat="server" />
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
                    <asp:Label ID="_LblConfirmOrderError" Visible="false" Text="Cannot Link Order" runat="server" />
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
            
        </asp:SqlDataSource>
     
    <asp:GridView runat="server" 
        EmptyDataText="There are no Orders Linked to this Freight Charge" 
        ID="_GVOrders" 
        DataSourceID="_SdsOrders" 
         DataKeyNames="OrderNumber"
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
                    <ajaxToolkit:HoverMenuExtender id="NotesHoverExtender" 
                        runat="server"
                         PopupPosition="Bottom"                            
                            TargetControlID="ViewAddNotesLink"    
                            PopupControlID="OrderNotesPanel" 
                            DynamicControlID="OrderNotesPanelLabel"   
                            DynamicContextKey='<%# Eval("OrderNumber") %>' 
                            DynamicServiceMethod="GetOrderNotes"
                            OffsetX="-12" 
                            />
                        <br />
                    <asp:LinkButton runat="server" 
                        ID="RemoveOrdersLinkButton"  
                        CausesValidation="false"
                        CommandArgument='<%# Eval("OrderNumber") %>' 
                        Text="Remove"
                        OnCommand="RemoveOrdersLinkButton_Command" />
                  
                    <%--<atlasToolkit:ModalPopupExtender ID="ModalPopupExtender" runat="server">
                        <atlasToolkit:ModalPopupProperties 
                            TargetControlID="ViewAddNotesLink" 
                            PopupControlID="TestPanel" 
                            OkControlID="Button1"
                            DynamicControlID="TestPanelLabel"
                            DynamicContextKey='<%# Eval("OrderNumber") %>' 
                            DynamicServiceMethod="GetOrderNotes" />
                    </atlasToolkit:ModalPopupExtender>--%>
                </ItemTemplate>
                
            </asp:TemplateField>
                    
        </Columns>
    </asp:GridView>
    
     <br />
     
     <asp:SqlDataSource runat="server" 
        ID="_SdsFreightChargesExt" 
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        SelectCommand="SELECT xFreightChargeID,FreightType, ProNumber2 FROM FreightChargesExt WHERE xFreightChargeID=@xFreightChargeID"
        UpdateCommand="UPDATE FreightChargesExt SET ProNumber2=@ProNumber2 WHERE xFreightChargeID=@xFreightChargeID"
        
        >
         <UpdateParameters>
            <asp:ControlParameter 
                ControlID="_HdnFreightChargeID" 
                Type="Int32" 
                Name="xFreightChargeID" 
                PropertyName="Value" 
                />
            <asp:ControlParameter 
                ControlID="_TxtProNumber2" 
                Type="String" 
                Name="ProNumber2" 
                PropertyName="Text" 
                />   
        </UpdateParameters>  
        
        <SelectParameters>
            <asp:ControlParameter 
                ControlID="_HdnFreightChargeID" 
                Type="Int32" 
                Name="xFreightChargeID" 
                PropertyName="Value" 
                />
        </SelectParameters>       
      </asp:SqlDataSource> 
     
      
      <asp:SqlDataSource runat="server" 
        ID="_SdsFreightType" 
        SelectCommand="SELECT 0 AS [FreightTypeID], '-- Select FreightType --' AS [FreightTypeName], NULL AS [FreightGL] UNION SELECT [FreightTypeID],[FreightTypeName],[FreightGL] FROM [Refron].[dbo].[FreightType]"
        UpdateCommand="UPDATE  FreightChargesExt SET FreightType=@FreightType WHERE xFreightChargeID=@xFreightChargeID"
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        >
        <UpdateParameters>
            <asp:ControlParameter 
                ControlID="_HdnFreightChargeID" 
                Type="Int32" 
                Name="xFreightChargeID" 
                PropertyName="Value" 
                />
            <asp:ControlParameter 
                ControlID="_DdlFreightType" 
                Type="Int16" 
                Name="FreightType" 
                PropertyName="SelectedValue" 
                />   
        </UpdateParameters>         
               
      </asp:SqlDataSource>    
           
        <%--SelectCommand="SELECT 1 as PlaceOHORNU AS OrderNumber, OHSHDT as ShipDate, OHBL# as BLNumber, OHSAD1 as CustomerName, OHSCTY + ', ' + OHSSTE + ' ' + OHSZIP  as CustomerAddress, Case When ItemTotal < 0 Then 'In' Else 'Out' end as InOut, LineItemCount, TotalGrossWeight, OHWHS + '(' +  Cast(wmvndr as varchar(7)) + ')/' + Cast(WMZIP as varchar(5)) as FromWhsZip, Cast(WMZIP as varchar(5)) as FromZip, OHSZIP as toZip, OHWHS as FromWhs, wmwhnm as VendorName, wmvndr as VendorCode From ordrhdr Left Join (Select ODORNU as OrderNumber, SUM(ODQTOR) as ItemTotal, Count(ODORNU) as LineItemCount, Sum((ITGRWT * ODQTOR)) as TotalGrossWeight From ordrdtl Left Join itemmst on oditem = ititem Group By ODORNU  ) as GrossWeightTable on ordrhdr.ohornu = GrossWeightTable.Ordernumber Left Join WHSEMST on ORDRHDR.OHWHS = WHSEMST.WMWHS Where OHORNU in (select testordrhdrid from testordrhdr where freightchargeid = @FreightChargeID) "--%>
     <asp:SqlDataSource runat="server" 
        ID="_SdsOrders" 
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        >
        <SelectParameters>
            <asp:ControlParameter 
                ControlID="_HdnFreightChargeID" 
                Type="Int32" 
                Name="FreightChargeID" 
                PropertyName="Value" 
                />
        </SelectParameters>
        
    </asp:SqlDataSource>
      <%--  <atlas:AutoCompleteExtender runat="server" 
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
    <asp:HiddenField ID="_HdnFreightChargeId" runat="server" />
    <asp:HiddenField ID="_HdnVendorName" runat="server" />
    <asp:HiddenField ID="_HdnVendorCode" runat="server" />
    
    <asp:Table runat="server" ID="ManualOrderTable">
        <asp:TableRow>
            <asp:TableCell>
                <span style="text-decoration:underline;font-weight:bold;">Manual Entry:</span><br />
                B/L #: <asp:TextBox  runat="server" ID="_TxtBLNumber" Width="50px" />
                Ship Date: <asp:TextBox runat="server" ID="_TxtShipDate" Width="60px" />
                From Whs: <asp:TextBox runat="server" ID="_TxtFromWarehouse" Width="39px" />&nbsp;&nbsp;&nbsp;
                From Zip:<asp:TextBox runat="server" ID="_TxtFromZip" Width="45px" /> &nbsp;&nbsp;&nbsp;
                To Zip:<asp:TextBox runat="server" ID="_TxtToZip" Width="48px" /> 
                Gross wgt: <asp:TextBox runat="server" ID="_TxtGrossWeight" Width="59px" />
                Miles: <asp:TextBox runat="server" Enabled="false" ID="_TxtMiles" Width="59px" />
                In/Out:
                <asp:DropDownList runat="server"  ID="_DdlInboundOutbound">
                    <asp:ListItem Text="" Value=""/>
                    <asp:ListItem Text="In" Value="I" />
                    <asp:ListItem Text="Out" Value="O" />
                </asp:DropDownList><br />
                <asp:Button runat="server" CausesValidation="false"   ID="_BtnUpdateManualEntry" Text="Update Mileage and Czarlite" />
                
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
                Freight Charge
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
        <asp:TableRow>
            <asp:TableCell>
                Pro#:&nbsp;<asp:TextBox runat="server" ID="_TxtProNumber" Width="0px" BackColor="Transparent" ForeColor="White" BorderStyle="None" MaxLength="12" />
               
                <asp:TextBox runat="server" ID="_TxtProNumber2" MaxLength="50" Text='<%# Eval("ProNumber2") %>'
                                    AutoPostBack="true"
                    OnTextChanged ="_TxtProNumber2_TextChanged"
                    EnableViewState = "true" />
                Pro Date:&nbsp;<asp:TextBox runat="server" ID="_TxtProDate" />
                Freight Charge:&nbsp;<asp:TextBox runat="server" Width="75px" ID="_TxtFreightChargeAmount" />
                <asp:Checkbox runat="server" ID="_ChkMinimumCharge" />Minimum&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

                Freight Type: 
                <asp:DropDownList 
                    ID="_DdlFreightType" 
                    runat="server" 
                    DataSourceID="_SdsFreightType"
                    DataTextField="FreightTypeName" 
                    DataValueField="FreightTypeID"
                    AutoPostBack="true"
                    OnSelectedIndexChanged ="_DdlFreightType_SelectedIndexChanged"
                    
                    EnableViewState = "true"                                   
                    /> 
                    
                    &nbsp;&nbsp;&nbsp;GL Account : &nbsp;<asp:Label runat="server" ID="_LblGLAccount"  Text="" style="font-weight:bold;"/>               
                
                <br /><span style="text-decoration:underline;font-weight:bold;">Czarlite:</span>&nbsp;&nbsp;&nbsp;
                <asp:Label runat="server" ID="_LblCzarLiteAmount" />&nbsp;&nbsp;&nbsp;
                <asp:HiddenField runat="server" ID="_HdnCzarLiteAmount" />
                Percent: <asp:Label runat="server" ID="_LblCzarLitePercent" />&nbsp;&nbsp;&nbsp;
                Minimum: <asp:Label runat="server" ID="_LblCzarLiteMinimumCharge" />
                
            </asp:TableCell> 
       </asp:TableRow>     
       <asp:TableRow>
           <asp:TableCell>
                Additional Charge:&nbsp;<asp:TextBox runat="server" ID="_TxtAdditionalCharge" />
                Reason: 
                <asp:DropDownList 
                    ID="_DdlAdditionalChargeReason" 
                    runat="server" 
                    DataSourceID="_SdsAdditionalChargeReason"
                    DataTextField="AdditionalChargeCode" 
                    DataValueField="AdditionalChargeCodeID"
                    />
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
                <br />
                Vendor#:&nbsp;<asp:TextBox Width="60px" runat="server" ID="_TxtVendorCode" SkinID="SearchableInput" />
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
    <asp:Button runat="server" Text="Search" ID="_BtnExit" CausesValidation="false" />
    <br />
    <asp:Label runat="server" ID="_LblUpdated" /><br />
    <asp:Table runat="server"
        id="_TblOrderCompareHeader"
        SkinID="GreyGridviewHeader"
        >
        <asp:TableHeaderRow>    
            <asp:TableHeaderCell>
                <b>Similar Freight Charges</b>
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
    </asp:Table>
    <asp:GridView ID="_GVCompareShipments" SkinID="GreyColumnHeaders" runat="server" DataSourceID="_SdsCompareShipments" AllowPaging="True" AllowSorting="True">
         
         <Columns>
             
            <asp:BoundField 
                DataField="WarehouseCode" 
                HeaderText="Whs" 
                SortExpression="WarehouseCode" 
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
                DataField="CustomerName" 
                HeaderText="Customer" 
                SortExpression="CustomerName" 
                />
            <asp:BoundField 
                DataField="CustomerAddress" 
                HeaderText="Address" 
                SortExpression="CustomerAddress" 
                />
           
            <asp:BoundField 
                DataField="GrossWeight" 
                HeaderText="Gr-Wgt." 
                SortExpression="GrossWeight" 
                />
            <asp:TemplateField
                HeaderText="Freight Amt." 
                SortExpression="FreightChargeAmount" 
                >
                <ItemTemplate>
                    <asp:Label runat="server"
                        ID="_LblFreightChargeAmount"
                        />
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField
                HeaderText="$/cwt" 
                SortExpression="PricePer100" 
                >
                <ItemTemplate>
                    <asp:Label runat="server"
                        ID="_LblPricePer100"
                        />
                </ItemTemplate>
            </asp:TemplateField>
            
            <asp:BoundField 
                DataField="VendorName" 
                HeaderText="Carrier" 
                SortExpression="VendorName" 
                />
                
            
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource runat="server"
        CancelSelectOnNullParameter="false"
        ID="_SdsCompareShipments" 
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        >
        <SelectParameters>
            <asp:ControlParameter ControlID="_TxtToZip"  Name="ToZip" Type="String" PropertyName="Text" />
           <asp:ControlParameter ControlID="_TxtGrossWeight" Name="GrossWeight" PropertyName="Text" />
        </SelectParameters>
    </asp:SqlDataSource>
    <br />
    <asp:SqlDataSource runat="server"
        ID="_SdsAdditionalChargeReason"    
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>" 
        SelectCommand="SELECT [AdditionalChargeCodeID], [AdditionalChargeCode] FROM [FreightAdditionalChargeCodes]">
    </asp:SqlDataSource>
    <asp:SqlDataSource runat="server" 
        ID="_SdsPayentCodes"       
        ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        SelectCommand="SELECT [PaymentCodeID], [PaymentCodeName] FROM [PaymentCodes]"/>
 
    <asp:Panel runat="server" 
        ID="OrderNotesPanel" 
        Width="40%" 
        style="visibility:hidden;" 
        CssClass="popupHover" 
        >
        <%--<iframe src="about:blank" scrolling="no" frameborder="0"
            style="background-color:black;position:absolute;width:50%;height:100%;top:0px;left:0px;border:none;display:block;z-index:0"></iframe>
        --%>&nbsp;
        <div style="position:absolute;width:100%;height:100%;top:0px;left:0px;z-index:0;background-color:blue;">
            <asp:Label ID="OrderNotesPanelLabel" BackColor="white" BorderColor="black" BorderWidth="1px" Width="100%" runat="server" />
        </div>
    </asp:Panel>
    <%--<asp:Panel ID="Panel1" runat="server" CssClass="popupControl">
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
    </asp:Panel>--%>
<%--     <asp:Panel ID="Panel2" runat="server" CssClass="popupControl">
        <atlas:UpdatePanel ID="_UPLookupOrders" runat="server">
            <ContentTemplate>
               <center>
                    <asp:LinkButton ID="lnkTest" runat="server" OnClick="lnkTest_Click" /> 
                </center>

            </ContentTemplate>
        </atlas:UpdatePanel>
    </asp:Panel>--%>
    
    <%--<ajaxToolkit:PopupControlExtender runat="server"
        ID="_PceProDate"
        TargetControlID="_TxtProDate" 
        PopupControlID="Panel1" 
        Position="Right" 
        />
    <ajaxToolkit:PopupControlExtender runat="server"
        ID="_PceShipDate"
        TargetControlID="_TxtShipDate" 
        PopupControlID="Panel1" 
        Position="Right" 
         
        />--%>

    
<%-- <atlasToolkit:PopupControlExtender ID="_PceLookupOrders" runat="server">
        <atlasToolkit:PopupControlProperties  
            TargetControlID="_TxtLookupOrders" 
            PopupControlID="_UPLookupOrders" 
            Position="Bottom"
            DynamicControlID="_TxtLookupOrders"
            DynamicContextKey="a"
            DynamicServiceMethod="WMLookupOrders"/>
    </atlasToolkit:PopupControlExtender>--%>
    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtProNumber" 
        Display="None" 
        ErrorMessage="Pro # is a required field"  
        ControlToValidate="_TxtProNumber" 
        />
    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtProDate" 
        Display="None" 
        ErrorMessage="Pro Date is a required field"  
        ControlToValidate="_TxtProDate" 
        />
    <asp:RangeValidator runat="server" 
        ID="_RV_TxtProDate" 
        Display="None" 
        ControlToValidate="_TxtProDate" 
        Type="Date" 
        ErrorMessage="Pro Date must be a valid date within the last 12 months"
        />
    <asp:RequiredFieldValidator runat="server" 
        ID="_Rfv_TxtFreightChargeAmount" 
        Display="None" 
        ErrorMessage="Freight Charge is a required field"  
        ControlToValidate="_TxtFreightChargeAmount" 
        />
    <asp:CompareValidator runat="server" 
        ID="_CV_TxtFreightChargeAmount" 
        Display="None" 
        ControlToValidate="_TxtFreightChargeAmount" 
        Operator="DataTypeCheck" 
        Type="Currency" 
        ErrorMessage="Freight charge is not a valid amount" 
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

     