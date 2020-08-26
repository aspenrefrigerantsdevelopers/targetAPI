<%@ Page Title="" Language="VB" Trace="false" MasterPageFile="~/Default.master" AutoEventWireup="true"
    CodeFile="AFSRates.aspx.vb" Inherits="LTLRateSample" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <script language="javascript" type="text/javascript">
        function showDiv(div) {
            var el = document.getElementById(div);
            if (el.style.display == 'none')
                el.style.display = 'block';
            else
                el.style.display = 'none';
        }
    </script>
    
  
    <div style="width: 800px;">
        <h2>
            AFS Rate Quote Service</h2>
        <br />

        <table>
            <tr>
                <td>
<!--                    <a href="" onclick="showDiv('ltlA'); return false;">Edit Freight Info </a> -->
                    <br />
                    <br />
                    <div id="ltlA" style="display: none;">
                        <table>
                            <tr>
                                <td align="center" colspan="2">
                                    <hr />
                                    <b>AFS Rate Quote</b>
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    Shipment Date:
                                </td>
                                <td>
                                    <asp:TextBox ID="tShipDateAdv" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    Transportation Mode<sup>1</sup>:
                                </td>
                                <td>
                                    <asp:DropDownList ID="tTransMode" runat="server">
                                        <asp:ListItem Selected="True" Value="O">Outbound</asp:ListItem>
                                        <asp:ListItem Value="I">Inbound</asp:ListItem>
                                        <asp:ListItem Value="T">Third Party</asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    Origin:
                                </td>
                                <td>
                                    <asp:TextBox ID="tOriginAdv" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="height: 26px">
                                    Destination:
                                </td>
                                <td style="height: 26px">
                                    <asp:TextBox ID="tDestinationAdv" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    Items<sup>2</sup>:
                                </td>
                                <td>
                                    <asp:TextBox ID="tItemsAdv" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right">
                                    Accessorials<sup>3</sup>:
                                </td>
                                <td>
                                    <asp:TextBox ID="tAccessorialsAdv" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" colspan="2">
                                    <hr />
                                    <asp:HiddenField ID="tClient" runat="server" Value="1686" />
                                    <asp:HiddenField ID="tCarrier" runat="server" Value="0" />                                   
                                    <asp:HiddenField ID="tRateIncrease" runat="server" Value="0" />    
                                    <asp:HiddenField ID="tUserNameAdv" runat="server" Value="agrefrigweb" />                                      
                                    <asp:HiddenField ID="tPasswordAdv" runat="server" Value="service" />                                    
                                    <asp:Button ID="bAdvRate" runat="server" Text="Refresh Quote" OnClick="GetQuote" />
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div style="font-size: x-small;">
                                        1. Transportation Mode to be entered as either "I", "O" or "T" ("I" means Inbound,
                                        "O" means Outbound and "T" means Third Party)
                                        <br />
                                        2. Items are to be entered in the following format: "50|500,55|400,65|320" (classification|weight,classification|weight,classification|weight)
                                        <br />
                                        3. Accessorials are to be entered in the following format: "HAZ|NOD" (accessorial
                                        code|accessorial code)
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <asp:Panel ID="pResults" runat="server">
        </asp:Panel>

        <asp:Label ID="lMessage" runat="server"></asp:Label>
        <br />
        <br />
        <asp:Label ID="lStackTrace" runat="server"></asp:Label>
    </div>
</asp:Content>
