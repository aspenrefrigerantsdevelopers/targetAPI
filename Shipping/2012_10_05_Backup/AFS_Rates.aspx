<%@ Page Title="" Language="VB" Trace="false" MasterPageFile="~/Default.master" AutoEventWireup="true" CodeFile="AFS_Rates.aspx.vb" Inherits="LTLRateSample"  %>
<%@ MasterType  typename="_DefaultMaster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">

    <style type="text/css">/* Customize your modal window here, you can add background image too */
/* Z-index of #mask must lower than #boxes .window */
    #mask { 
        position:absolute; 
        z-index:9000;
        background-color:#DCD8D8; 
        display:none; 
    }
     
    #boxes .window { 
        position:absolute; 
        width:440px; 
        height:200px; 
        display:none; 
        z-index:9999; 
        padding:20px; 
    }
     
/* Customize your modal window here, you can add background image too */
    #boxes #dialog { 
        width:270px; 
        height:80px;
        background-color:#FFFFFF;
        border-width:thin;
        border-style:solid;
        border-color:#000000;
        border-radius:15px;
                  
    }
         
    </style> 

    <script language="javascript" type="text/javascript" src="/shared/global/client_scripts/jquery-1.6.4.min.js"></script>
    <script language="javascript" type="text/javascript">
//        function showDiv(div) {
//            var el = document.getElementById(div);
//            if (el.style.display == 'none')
//                {
//                el.style.display = 'block';
//                
//                if (el == 'ltlA')
//                    {
//                  document.getElementById('ltlB').style.display = 'none';
//                    }
//                else
//                    {
//                  document.getElementById('ltlA').style.display = 'none';                      
//                    }
//                }
//            else
//                }
//                el.style.display = 'none';
//                
//                if (el == 'ltlA')
//                    {
//                  document.getElementById('ltlB').style.display = 'display';
//                    }
//                else
//                    {
//                  document.getElementById('ltlA').style.display = 'display';                   
//                    }
//                }
//        }
 
 
 //jquery asp.net popup modal form
 //http://beckelman.net/demos/jQueryModalConfirmTB/Default.aspx
 //http://yensdesign.com/2008/09/how-to-create-a-stunning-and-smooth-popup-using-jquery/
 //http://forums.asp.net/p/1509962/3594576.aspx
 //http://www.misfitgeek.com/2011/03/jquery-modal-dialog-in-an-asp-net-page/
 //http://stackoverflow.com/questions/867109/jquery-login-modal-popup-for-asp-net-2-o-page
 //

$(document).ready(function() { 
    //select all the a tag with name equal to modal 
    $('a[name=modal]').click(function(e) { 
        //Cancel the link behavior 
        e.preventDefault(); 
        //Get the A tag 
        var id = $(this).attr('href'); 

        //Get the screen height and width 
        var maskHeight = $(document).height(); 
        var maskWidth = $(document).width(); 

        //Set height and width to mask to fill up the whole screen 
        $('#mask').css({'width':maskWidth,'height':maskHeight}); 

        //transition effect 
        $('#mask').fadeIn(200); 
        $('#mask').fadeTo("fast",0.8); 

        //Get the window height and width 
        var winH = $(window).height(); 
        var winW = $(window).width(); 

        //Set the popup window to center 
        $(id).css('top', winH/2-$(id).height()/2); 
        $(id).css('left', winW/2-$(id).width()/2); 

        //transition effect 
        $(id).fadeIn(2000); 
    }); 

    //if close button is clicked 
    $('.window .close').click(function (e) { 
        //Cancel the link behavior 
        e.preventDefault(); 
        $('#mask, .window').hide(); 
    }); 

    //if mask is clicked 
    $('#mask').click(function () { 
        $(this).hide(); 
        $('.window').hide(); 
    }); 
});

 
/*
$(document).ready(function () { 
    //id is the ID for the DIV you want to display it as modal window 
     launchWindow(id); 
});	 
*/
 
</script>	 

    <div id="boxes"> 
    
        <!-- #customize your modal window here -->
        <div id="dialog" class="window"> 
            <b>Enter New Carrier</b> 
            <!-- close button is defined as close class -->
            <!-- <a href="#" class="close">Close it</a> -->
            <br/>
            <asp:TextBox ID="TextBox1" runat="server" columns="35"></asp:TextBox><br />
            <asp:Button ID="Button1" runat="server" Text="Add New Carrier" OnClick="GetForm" />
            <input type="button" name="Submit" value="Cancel" class="close" />
         
        </div> 
        
        <!-- Do not remove div#mask, because you'll need it to fill the whole screen --> 
        <div id="mask"></div> 
    
    </div>

    <div style="width: 800px;">
    <!--
        <h2>
            AFS Rate Quote Service</h2>
    -->        
    <br />

        <table>
            <tr>
                <td>

                    <div id="ltlA" runat="server" visible="true">
                        <asp:LinkButton ID="lb_CarrierForm" runat="server" Text="Enter Manual Rate Quote" OnClick="GetForm" />
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
                                    <asp:TextBox ID="tShipDateAdv" runat="server" columns="12"></asp:TextBox>
                                </td>
                            </tr>
                             <tr>
                                <td align="right">
                                    Delivery Date:
                                </td>
                                <td>
                                    <asp:Label ID="lDeliveryDate" runat="server" text=""></asp:Label>
                                </td>
                            </tr> 
                            
                             <tr>
                                <td align="right">
                                    Transportation Mode<sup>1</sup>:
                                </td>
                                <td>
                                    <asp:Label ID="lTransMode" runat="server" text=""></asp:Label>
                                </td>
                            </tr>                                                     
<!--                            
                            <tr>
                                <td align="right">
                                    Origin:
                                </td>
                                <td>
                                    <%-- <asp:TextBox ID="tOriginAdv" runat="server"></asp:TextBox> --%>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="height: 26px">
                                    Destination:
                                </td>
                                <td style="height: 26px">
                                    <%-- <asp:TextBox ID="tDestinationAdv" runat="server"></asp:TextBox> --%>
                                </td>
                            </tr>
-->
                            <tr>
                                <td align="right">
                                    Items<sup>2</sup>:
                                </td>
                                <td>
                                    <asp:Label ID="lItemsAdv" runat="server" text=""></asp:Label>|                                    
                                    <asp:TextBox ID="tItemsWght" runat="server" Text="" columns="8"></asp:TextBox>
                                </td>
                            </tr>
                            
                            <tr>
                                <td align="right">
                                    Accessorials<sup>3</sup>:
                                </td>
                                <td>
                                    <asp:Label ID="lAccessorialsAdv" runat="server" text=""></asp:Label>
                                </td>
                            </tr>
                           
                            
                            <tr>
                                <td align="right" colspan="2">
                                    <hr />
                                    <asp:HiddenField ID="tClient" runat="server" Value="1686" />
                                    <asp:HiddenField ID="tCarrier" runat="server" Value="0" />
                                    
                                    <asp:HiddenField ID="tOriginAdv" runat="server" Value="" />
                                    <asp:HiddenField ID="tDestinationAdv" runat="server" Value="" />
                                    <asp:HiddenField ID="tTransMode" runat="server" Value="O" />
                                    <asp:HiddenField ID="tItemsAdv" runat="server" Value="" />
                                    <asp:HiddenField ID="tAccessorialsAdv" runat="server" Value="" />                                  
                                    
                                    <asp:HiddenField ID="tRateIncrease" runat="server" Value="0" />    
                                    <asp:HiddenField ID="tUserNameAdv" runat="server" Value="agrefrigweb" />                                      
                                    <asp:HiddenField ID="tPasswordAdv" runat="server" Value="service" />                                                                       
                                    <asp:Button ID="bAdvRate" runat="server" Text="Refresh Quote" OnClick="GetQuote" />
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <br />
                                    <div style="font-size: x-small;">
                                        1. Transportation Mode to be entered as either "I", "O" or "T" ("I" means Inbound,
                                        "O" means Outbound and "T" means Third Party)
                                        <br />
                                        2. Items are to be entered in the following format: "50|500,55|400,65|320" (classification|weight,classification|weight,classification|weight)
                                        <br />
                                        3. Accessorials are to be entered in the following format: "HAZ|NOD" (accessorial
                                        code|accessorial code)<br />
                                    </div>
                                    <br />
                                </td>
                            </tr>
                        </table>
                        
                         <!--<a href="" onclick="showDiv('ltlB'); return false;">Enter Manual AFS Rate Quote </a> -->
                    </div>
                      <div id="ltlB" runat="server" visible="False">
                        <asp:LinkButton ID="lb_RateForm" OnClick="GetForm" Text="Update AFS Rate Quote" runat="server"></asp:LinkButton>  
                        
                        <table>
                            <tr>
                                <td align="center" colspan="2">
                                    <hr />
                                    <b>Manual Rate Quote</b>
                                    <hr />
                                </td>
                            </tr>
                            
                              <tr>
                                <td align="left" style="height: 24px">                                
                                </td>
                                <td style="height: 24px">
                              <asp:RadioButton id="approvedCarriers" Text="Approved AFS Carriers" Checked="True" OnCheckedChanged="Carrier_CheckedChanged" GroupName="colors" runat="server" AutoPostBack="True"/>
                              <br />
                              <asp:RadioButton id="alternateCarriers" Text="Search for Alternate Carriers"  OnCheckedChanged="Carrier_CheckedChanged" GroupName="colors" runat="server" AutoPostBack="True"/>
                                    <br /> &nbsp;
                                </td>
                            </tr>                          
 
                           <tr id="apvCarrier" runat="server" visible="True" >
                                <td align="right" style="height: 24px">
                               
                                    Approved AFS Carriers:
                                </td>
                                <td style="height: 24px"><asp:DropDownList ID="ddlCarrier" runat="server">
                                    </asp:DropDownList>
                                    <!--<a href="#dialog" name="modal">Add a New Carrier</a> -->
                                    </td>
                            </tr>

                            <tr id="altCarrier" runat="server" visible="False" >
                                <td align="right" style="height: 24px">
                                    Search in Carrier Name:
                                </td>
                                <td style="height: 24px">
                                <asp:TextBox ID="tCarrierSearch" runat="server"></asp:TextBox> 
                                <asp:Button ID="bAltCarrierList" runat="server" Text="Search for Carriers" OnClick="GetAlternateCarriers" />

                                    </td>
                            </tr>


                            <tr id="altCarrierResults" runat="server" visible="False" >
                                <td align="right" style="height: 24px">
                                    <asp:Label ID="cntCarriers" runat="server" ForeColor="Maroon" Font-Bold="True"></asp:Label>
                                    Alternate Carriers:
                                </td>
                                <td style="height: 24px">
                                        <asp:DropDownList ID="ddlAltCarrier" runat="server" >
                                        </asp:DropDownList>
                                        
                                        <asp:Button ID="bClear" runat="server" Text="Clear Search" OnClick="Clear_CarrierSearch" />
                                    </td>
                            </tr>


                            <tr>
                                <td align="right">
                                    Phone Number:
                                </td>
                                <td>
                                    <asp:TextBox ID="tPhone" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td align="right" style="height: 26px">
                                    Estimated Cost:
                                </td>
                                <td style="height: 26px">
                                    <asp:TextBox ID="tEstimateCost" runat="server"></asp:TextBox>
                                </td>
                            </tr>

                            <tr>
                                <td align="right" colspan="2">
                                    <hr />
                                    <asp:Button ID="bCarrierList" runat="server" Text="Get Carriers" OnClick="GetCarriers" visible="false" />                                   
                                    <asp:Button ID="bManRate" runat="server" Text="Save Manual  Quote" OnClick="GetManualQuote" />
                                    <hr />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="2">
                                    <div style="font-size: x-small;color:#FFFFFF;">
                                        2. Items are to be entered in the following format: "50|500,55|400,65|320" (classification|weight,classification|weight,classification|weight)
                                    </div>
                                    <br />
                                </td>
                            </tr>
                        </table>
                    </div>                                        
                </td>
            </tr>
        </table>
        
        <asp:Panel ID="pResults" runat="server">
        </asp:Panel>
        
        <asp:Label ID="lMessage" runat="server" Font-Bold="True" ForeColor="#C00000"></asp:Label>        
        
        <asp:Panel ID="pStatic" runat="server">
        </asp:Panel>
 
        <asp:HiddenField ID="tCarrierChoice" runat="server" Value="0" />
        <asp:Button ID="bSubmitRate" runat="server" Text="Accept Rate Quote" OnClick="SubmitChoice" enabled="false" />

        <asp:Button ID="bCancelRate" runat="server" Text="Cancel" OnClick="SubmitChoice"/>
        <br />
        <asp:Label ID="lStackTrace" runat="server" Font-Bold="True" ForeColor="#C00000" ></asp:Label>
    </div>
</asp:Content>
