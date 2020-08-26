<%@ page language="VB" masterpagefile="~/Default.master" autoeventwireup="false" inherits="Shipping_AdditionalChargeCodes, App_Web_uis0etrg" title="Untitled Page" theme="Theme1" %>
<%@ MasterType  typename="_DefaultMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
             <asp:Label ID="_LblError" SkinID="ErrorLabel" runat="server"></asp:Label>
    &nbsp;&nbsp;
    <asp:DetailsView ID="_DtvAdditionalChargeCode" runat="server"
        DataKeyNames="AdditionalChargeCodeID" DataSourceID="_sdsAdditionalChargeCodeDetailsView" 
        HeaderText="New Additional Charges Code"
        OnItemInserting="Validate_Insert_Data" >
        <Fields>
            <asp:BoundField DataField="AdditionalChargeCodeID" HeaderText="AdditionalChargeCodeID"
                InsertVisible="False"
                ReadOnly="True" SortExpression="AdditionalChargeCodeID" Visible="False" />
            <asp:BoundField DataField="AdditionalChargeCode"  HeaderText="Name" 
                SortExpression="AdditionalChargeCode" />
            <asp:BoundField DataField="AdditionalChargeCodeDescription" HeaderText="Description"
                SortExpression="AdditionalChargeCodeDescription" />
           <asp:TemplateField>
            <ItemTemplate>
              <asp:Button ID="_BtnDtvNew" CommandName="New" Text="New" runat="Server"/>
            </ItemTemplate>
            <InsertItemTemplate>
              <asp:Button ID="_BtnDtvInsert" CommandName="Insert" 
                    Text="Insert" Runat="Server"/>
              <asp:Button ID="_BtnDtvCancel" CommandName="Cancel" 
                    Text="Cancel" Runat="Server"/>
            </InsertItemTemplate>
          </asp:TemplateField>
     </Fields>
      
    </asp:DetailsView>
    <asp:SqlDataSource ID="_SdsAdditionalChargeCodeDetailsView" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        DeleteCommand="DELETE FROM [FreightAdditionalChargeCodes] WHERE [AdditionalChargeCodeID] = @AdditionalChargeCodeID"
        InsertCommand="INSERT INTO [FreightAdditionalChargeCodes] ([AdditionalChargeCode], [AdditionalChargeCodeDescription]) VALUES (@AdditionalChargeCode, @AdditionalChargeCodeDescription)"
        SelectCommand="SELECT [AdditionalChargeCode], [AdditionalChargeCodeDescription], [AdditionalChargeCodeID] FROM [FreightAdditionalChargeCodes] WHERE ([AdditionalChargeCodeID] = @AdditionalChargeCodeID)"
        UpdateCommand="UPDATE [FreightAdditionalChargeCodes] SET [AdditionalChargeCode] = @AdditionalChargeCode, [AdditionalChargeCodeDescription] = @AdditionalChargeCodeDescription WHERE [AdditionalChargeCodeID] = @AdditionalChargeCodeID">
        <DeleteParameters>
            <asp:Parameter Name="AdditionalChargeCodeID" Type="Int32" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="AdditionalChargeCode" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeDescription" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeID" Type="Int32" />
        </UpdateParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="_GVAdditionalChargeCode" Name="AdditionalChargeCodeID" PropertyName="SelectedValue"
                Type="Int32" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="AdditionalChargeCode" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeDescription" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource><br />
   
    <asp:Button ID="_BtnAddNew" runat="server" Text="Add New Additional Charges Code" />&nbsp;<br />
    <br />
    
    <asp:GridView ID="_GVAdditionalChargeCode" runat="server"
         CssClass="GridView" DataKeyNames="AdditionalChargeCodeID" 
         DataSourceID="_sdsAdditionalChargeCodesGridView">
        <Columns>
            <asp:CommandField ShowDeleteButton="false" ShowCancelButton="False" ControlStyle-CssClass="GridViewButton"  ShowEditButton="True" ButtonType="Button" />
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:Button ID="LinkButton1" Runat="server" 
                        OnClientClick="return confirm('Are you sure you want to delete this record?');"
                        CommandName="Delete" Text="Delete"></asp:Button>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Button Id="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="AdditionalChargeCodeID" HeaderText="Additional Charges Code ID" InsertVisible="False"
                ReadOnly="True" SortExpression="AdditionalChargeCodeID" Visible="False" />
            <asp:BoundField  DataField="AdditionalChargeCode" HeaderText="Additional Charges Code Name" SortExpression="AdditionalChargeCode" />
            <asp:BoundField  DataField="AdditionalChargeCodeDescription" HeaderText="Additional Charges Code Description"
                SortExpression="AdditionalChargeCodeDescription" />
            <asp:TemplateField  HeaderStyle-Width="100%"/>
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="_SdsAdditionalChargeCodesGridView" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        DeleteCommand="DELETE FROM [FreightAdditionalChargeCodes] WHERE [AdditionalChargeCodeID] = @AdditionalChargeCodeID"
        InsertCommand="INSERT INTO [FreightAdditionalChargeCodes] ([AdditionalChargeCode], [AdditionalChargeCodeDescription]) VALUES (@AdditionalChargeCode, @AdditionalChargeCodeDescription)"
        SelectCommand="SELECT [AdditionalChargeCodeID], [AdditionalChargeCode], [AdditionalChargeCodeDescription] FROM [FreightAdditionalChargeCodes]"
        UpdateCommand="UPDATE [FreightAdditionalChargeCodes] SET [AdditionalChargeCode] = @AdditionalChargeCode, [AdditionalChargeCodeDescription] = @AdditionalChargeCodeDescription WHERE [AdditionalChargeCodeID] = @AdditionalChargeCodeID">
        <DeleteParameters>
            <asp:Parameter Name="AdditionalChargeCodeID" Type="Int32" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="AdditionalChargeCode" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeDescription" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeID" Type="Int32" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="AdditionalChargeCode" Type="String" />
            <asp:Parameter Name="AdditionalChargeCodeDescription" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource>

</asp:Content>
