<%@ page language="VB" trace="false" masterpagefile="~/Default.master" autoeventwireup="false" inherits="Shipping_SearchFreightCharges, App_Web_uis0etrg" theme="Theme1" %>
<%@ MasterType  typename="_DefaultMaster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">


<br />
     <asp:ValidationSummary ID="_ValidationSummary"  runat="server" />
    <asp:Table ID="TblSearchFreightCharges" runat="server">
    <asp:TableHeaderRow >
        <asp:TableCell ColumnSpan="2" >
            Search for Freight Charges 
        </asp:TableCell>
        <asp:TableCell HorizontalAlign="Right">
            <asp:HyperLink runat="server"
                Text="Add Frt Charge"  
                NavigateUrl="~/Shipping/EditFreightCharge3.aspx?fid=0" 
                />
        </asp:TableCell>
    </asp:TableHeaderRow>
   <asp:TableRow>
        <asp:TableCell Width="15%" >
            B/L Number:   
        </asp:TableCell>
        <asp:TableCell  ColumnSpan="2" >
            <asp:Textbox Width="60px" MaxLength="7" ID="_TxtBLNumber" runat="server" />
                <asp:RadioButton  runat="server" 
                    Text="1 Month" 
                    GroupName="_RdoGroupBLNumberDateRange" 
                    ID="_RdoBLNumberDateRange1Month"
                    Checked="true"
                    />
                <asp:RadioButton  runat="server" 
                    Text="6 Months" 
                    GroupName="_RdoGroupBLNumberDateRange" 
                    ID="_RdoBLNumberDateRange6Months"
                    />
                <asp:RadioButton  runat="server" 
                    Text="All Records" 
                    GroupName="_RdoGroupBLNumberDateRange" 
                    ID="_RdoBLNumberDateRangeAll"
                    />
                
        </asp:TableCell>
    </asp:TableRow>
    <asp:TableRow>
        <asp:TableCell>
            Order Number:
        </asp:TableCell>
        <asp:TableCell ColumnSpan="2" >
            <asp:Textbox Width="60px" ID="_TxtOrderNumber" runat="server" />
        </asp:TableCell>
    </asp:TableRow> 
    <asp:TableRow>
        <asp:TableCell>
            Warehouse:
        </asp:TableCell>
        <asp:TableCell ColumnSpan="2" >
            <asp:Textbox Width="60px" ID="_TxtWarehouse" runat="server" />
            &nbsp;&nbsp;&nbsp;&nbsp;From Ship Date: <asp:TextBox runat="server" width="60px" ID="_TxtWarehouseDateRange" /><i>(default year is <%=DateTime.Now().Year.ToString%>)</i>
        </asp:TableCell>
    </asp:TableRow> 
 
    </asp:Table>
    <asp:Button runat="server" ID="_BtnSearchFreightCharges" Text="Search" />
    <br /><br />
    <asp:Table runat="server" 
        id="_TblFreghtChargeResultsHeader"
        visible="false"
        SkinID="GreyGridviewHeader"
        >
        <asp:TableHeaderRow>
            <asp:TableHeaderCell>
                Results - Existing Freight Charges
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
    </asp:Table>
    <asp:GridView  runat="server"
        ID="_GVFreightCharges" 
        DataKeyNames="FreightChargeID"
        SkinID="GreyColumnHeaders"
        
        >
        <Columns>
            <asp:TemplateField ItemStyle-Width="12%">
                <ItemTemplate><!--
                    <a href='editfreightcharge.aspx?fid=<%# Eval("FreightChargeID").tostring%>'>Go To</a>
                    <br />
                    <a href='editfreightcharge2.aspx?fid=<%# Eval("FreightChargeID").tostring%>'>Go To Testing</a>
                    <br /><br /><br /> -->
                    <a href='editfreightcharge3.aspx?fid=<%# Eval("FreightChargeID").tostring%>'>Go To</a>
                
                
                </ItemTemplate>
            
            </asp:TemplateField>
            <asp:TemplateField ItemStyle-Width="12%" HeaderText="Order #s">
                <ItemTemplate>
                <asp:hyperlink runat="server" 
                        ID="_LnkFreightChargesGridOrderDetails" 
                        NavigateUrl='javascript:void(0)' 
                        text='<%# Eval("FirstOrderNumber").tostring%>'
                         
                        />
                <asp:Label runat="server" 
                    ID="_LblFreightChargesGridOrderStatus" 
                    Text='<%# " " & Eval("OHSTAT").ToString.replace("F","") %>' />
                 
                    
                <asp:HyperLink runat="server" 
                        ID="_LnkFreightChargesGridOrderNumbers" 
                        NavigateUrl="javascript:void(0)"
                        Text="+" 
                        Visible='<%# (ctype(Eval("OrderCount"),integer) > 1) %>'
                        ToolTip='<%# AdditionalOrderNumbers(ctype(Eval("OrderCount"),integer),ctype(Eval("FreightChargeID"),integer)) %>'
                        />
                    
                        
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField ItemStyle-Width="0%" DataField="FreightChargeID" HeaderText="FreightChargeID" Visible="false" InsertVisible="False"
                ReadOnly="True" SortExpression="FreightChargeID"  />
            <asp:BoundField  ItemStyle-Width="12%" DataField="BillOfLadingNumber" HeaderText="B/L #" SortExpression="BillOfLadingNumber" />
            <asp:TemplateField ItemStyle-Width="12%" 
                    HeaderText="ShipDate" 
                    SortExpression="ShipDate" 
                    >
                <ItemTemplate>        
                    <asp:Label runat="server" ID="ShipDateLabel" /> 
                </ItemTemplate>   
            </asp:TemplateField>           
            <asp:BoundField ItemStyle-Width="12%" DataField="WarehouseCode" HeaderText="Whs Code" SortExpression="WarehouseCode" />
            <asp:BoundField ItemStyle-Width="12%" DataField="InboundOutbound" HeaderText="I/O" SortExpression="InboundOutbound" />
            <asp:BoundField ItemStyle-Width="12%" DataField="CustomerName" HeaderText="Customer" SortExpression="CustomerName" />
            <%--<asp:TemplateField">
                
                
                <ItemTemplate>
                    <asp:textbox runat="server" 
                    ID="_LblFreightChargeOrderNumbers" Text="12345+"
                    />a
                </ItemTemplate>
            </asp:TemplateField>--%>
            <asp:TemplateField  ItemStyle-Width="12%">
                <ItemTemplate>
                    <asp:HyperLink runat="server" 
                        ID="_LnkFreightChargeCommentsHover" 
                        NavigateUrl="javascript:void(0)"
                         
                        ToolTip='<%# Eval("Comments").toString %>'
                        Visible='<%# (len(Eval("Comments").toString) > 0) %>'
                        Text="Comments"/>
                        
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="_SdsFreightCharges"  CancelSelectOnNullParameter="false"   runat="server" 
    ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>" 
    SelectCommand="Select FreightChargeID, BillOfLadingNumber, WarehouseCode, ShipDate FROM FreightCharges">
        <SelectParameters>
            <asp:ControlParameter ControlID="_TxtBLNumber"  Name="BLNumber" Type="String" PropertyName="Text" />
           <asp:ControlParameter ControlID="_TxtWarehouse" Name="WarehouseCode" PropertyName="Text" />
           <asp:ControlParameter ControlID="_TxtWarehouseDateRange" Name="WarehouseDateRange" PropertyName="Text" />
        </SelectParameters>

    </asp:SqlDataSource>
    &nbsp;&nbsp;&nbsp;<asp:Label ID="_LblNoFreightRecords" runat="server" Text="There are no Freight Records that match your criteria"
        Visible="False"></asp:Label>
    <br /><br />
    <asp:Table runat="server" 
        id="_TblOrdersResultsHeader"
        SkinID="GreyGridviewHeader"
        
        visible="false"
        >
        <asp:TableHeaderRow>
            <asp:TableHeaderCell>
                Results - Orders with no Freight Charges
            </asp:TableHeaderCell>
        </asp:TableHeaderRow>
    </asp:Table>

    <asp:GridView ID="_GVOrders" runat="server"  AutoGenerateColumns="False" DataKeyNames="OHORNU"
        DataSourceID="_SdsOrders" Visible="false"         SkinID="GreyColumnHeaders">
        <Columns>
            <asp:TemplateField ItemStyle-Width="12%">
                <ItemTemplate>
                    <asp:LinkButton ID="_LnkCreateFreightRecord"  CausesValidation="false"
                        CommandArgument='<%# Eval("OHORNU") %>' Text="Create Frt Charge"
                        runat="server" OnCommand="CreateFreightRecordLinkButton_Command" />
              </ItemTemplate>
            </asp:TemplateField>              
            <asp:TemplateField ItemStyle-Width="12%" HeaderText="Order #" SortExpression="OHORNU">
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
   
            <asp:BoundField ItemStyle-Width="12%" DataField="BillOfLadingNumber" HeaderText="B/L #" SortExpression="BillOfLadingNumber" />
             <asp:TemplateField  ItemStyle-Width="12%"
                    HeaderText="ShipDate" 
                    SortExpression="ShipDate" 
                    >
                <ItemTemplate>         
                    <asp:Label runat="server" ID="ShipDateLabel" /> 
                </ItemTemplate>   
            </asp:TemplateField>           
            <asp:BoundField ItemStyle-Width="12%" DataField="WarehouseCode" HeaderText="Whs Code" SortExpression="WarehouseCode" />
            <asp:BoundField ItemStyle-Width="12%" DataField="InOut" HeaderText="I/O" SortExpression="InOut" />
            <asp:BoundField ItemStyle-Width="12%" DataField="CustomerName" HeaderText="Customer" SortExpression="CustomerName" />
 
 
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="_SdsOrders" CancelSelectOnNullParameter="false" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        SelectCommand="">
        <SelectParameters>
           <asp:ControlParameter ControlID="_TxtWarehouse" Name="WarehouseCode" PropertyName="Text" />
           <asp:ControlParameter ControlID="_TxtWarehouseDateRange" Name="WarehouseDateRange" PropertyName="Text" />
             <asp:ControlParameter ControlID="_TxtBLNumber" Name="BLNumber" PropertyName="Text" />
       </SelectParameters>
    </asp:SqlDataSource>
    <asp:CompareValidator runat="server" 
        ID="_CV_TxtOrderNumber" 
        Display="None" 
        ControlToValidate="_TxtOrderNumber" 
        Operator="DataTypeCheck" 
        Type="Integer"
        ErrorMessage="Order Number should be numeric" 
        />
   
</asp:Content>

