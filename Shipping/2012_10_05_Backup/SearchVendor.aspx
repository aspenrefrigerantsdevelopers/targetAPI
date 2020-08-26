<%@ page language="VB" masterpagefile="~/Default.master" autoeventwireup="false" inherits="Shipping_SearchVendor, App_Web_uis0etrg" title="Untitled Page" theme="Theme1" %>
<%@ MasterType TypeName="_DefaultMaster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
<script language="javascript" type="text/javascript">
function ReturnResponse(VendorCode, VendorName){
    if(opener.searchVendorParent){
        opener.updateVendorCode(VendorCode, VendorName);
    }
    window.close();
    return true;
}
</script>
    <br />
    <asp:GridView ID="_GVVendors" runat="server" AutoGenerateColumns="False" DataSourceID="_SdsVendors">
        <AlternatingRowStyle  CssClass="highlightrow" />
        <Columns>
            <asp:BoundField DataField="VendorNumber" HeaderText="Vendor#" SortExpression="VNVNNU" />
            <asp:BoundField DataField="VendorName" HeaderText="Vendor Name" SortExpression="VNVNNU" />
            <asp:BoundField DataField="City" HeaderText="Vendor#" SortExpression="VNVNNU" />
            <asp:BoundField DataField="State" HeaderText="Vendor#" SortExpression="VNVNNU" />
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Label runat="Server" ID="_LblFullZip" Text='<%# Refron_GLobal.FormatUtilities.FullZip(Eval("Zip").ToString,Eval("Zip4").ToString)%>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Label runat="Server" ID="_LblPhone" Text='<%# Refron_GLobal.FormatUtilities.FormatPhone(Eval("Phone").ToString,"PPP-PPP-PPPP")%>' />
                </ItemTemplate>
            </asp:TemplateField>
            
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="_SdsVendors" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        SelectCommand="Select VNVNNU from APVndr  WHERE VNORNU > 0"></asp:SqlDataSource>

</asp:Content>

