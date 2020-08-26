<%@ page language="VB" masterpagefile="~/Default.master" autoeventwireup="true" inherits="Shipping_PaymentCodes, App_Web_uis0etrg" title="Untitled Page" theme="Theme1" %>
<%@ MasterType  typename="_DefaultMaster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

             <asp:Label ID="_LblError" SkinID="ErrorLabel" runat="server"></asp:Label>
    &nbsp;&nbsp;
    <asp:DetailsView ID="_DtvPaymentCode" runat="server"
        DataKeyNames="PaymentCodeID" DataSourceID="_SdsPaymentCodeDetailsView" 
        HeaderText="New Payment Code"
        OnItemInserting="Validate_Insert_Data" >
        <Fields>
            <asp:BoundField DataField="PaymentCodeID" HeaderText="PaymentCodeID"
                InsertVisible="False"
                ReadOnly="True" SortExpression="PaymentCodeID" Visible="False" />
            <asp:BoundField DataField="PaymentCodeName"  HeaderText="Name" 
                SortExpression="PaymentCodeName" />
            <asp:BoundField DataField="PaymentCodeDescription" HeaderText="Description"
                SortExpression="PaymentCodeDescription" />
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
    <asp:SqlDataSource ID="_SdsPaymentCodeDetailsView" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        DeleteCommand="DELETE FROM [PaymentCodes] WHERE [PaymentCodeID] = @PaymentCodeID"
        InsertCommand="INSERT INTO [PaymentCodes] ([PaymentCodeName], [PaymentCodeDescription]) VALUES (@PaymentCodeName, @PaymentCodeDescription)"
        SelectCommand="SELECT [PaymentCodeName], [PaymentCodeDescription], [PaymentCodeID] FROM [PaymentCodes] WHERE ([PaymentCodeID] = @PaymentCodeID)"
        UpdateCommand="UPDATE [PaymentCodes] SET [PaymentCodeName] = @PaymentCodeName, [PaymentCodeDescription] = @PaymentCodeDescription WHERE [PaymentCodeID] = @PaymentCodeID">
        <DeleteParameters>
            <asp:Parameter Name="PaymentCodeID" Type="Int32" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="PaymentCodeName" Type="String" />
            <asp:Parameter Name="PaymentCodeDescription" Type="String" />
            <asp:Parameter Name="PaymentCodeID" Type="Int32" />
        </UpdateParameters>
        <SelectParameters>
            <asp:ControlParameter ControlID="_GVPaymentCode" Name="PaymentCodeID" PropertyName="SelectedValue"
                Type="Int32" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="PaymentCodeName" Type="String" />
            <asp:Parameter Name="PaymentCodeDescription" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource><br />
   
    <asp:Button ID="_BtnAddNew" runat="server" Text="Add New Payment Code" />&nbsp;<br />
    <br />
    
    <asp:GridView ID="_GVPaymentCode" runat="server"
         CssClass="GridView" DataKeyNames="PaymentCodeID" 
         DataSourceID="_SdsPaymentCodesGridView">
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
            <asp:BoundField DataField="PaymentCodeID" HeaderText="Payment Code ID" InsertVisible="False"
                ReadOnly="True" SortExpression="PaymentCodeID" Visible="False" />
            <asp:BoundField  DataField="PaymentCodeName" HeaderText="Payment Code Name" SortExpression="PaymentCodeName" />
            <asp:BoundField  DataField="PaymentCodeDescription" HeaderText="Payment Code Description"
                SortExpression="PaymentCodeDescription" />
            <asp:TemplateField  HeaderStyle-Width="100%"/>
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="_SdsPaymentCodesGridView" runat="server" ConnectionString="<%$ ConnectionStrings:RefronConnectionString %>"
        DeleteCommand="DELETE FROM [PaymentCodes] WHERE [PaymentCodeID] = @PaymentCodeID"
        InsertCommand="INSERT INTO [PaymentCodes] ([PaymentCodeName], [PaymentCodeDescription]) VALUES (@PaymentCodeName, @PaymentCodeDescription)"
        SelectCommand="SELECT [PaymentCodeID], [PaymentCodeName], [PaymentCodeDescription] FROM [PaymentCodes]"
        UpdateCommand="UPDATE [PaymentCodes] SET [PaymentCodeName] = @PaymentCodeName, [PaymentCodeDescription] = @PaymentCodeDescription WHERE [PaymentCodeID] = @PaymentCodeID">
        <DeleteParameters>
            <asp:Parameter Name="PaymentCodeID" Type="Int32" />
        </DeleteParameters>
        <UpdateParameters>
            <asp:Parameter Name="PaymentCodeName" Type="String" />
            <asp:Parameter Name="PaymentCodeDescription" Type="String" />
            <asp:Parameter Name="PaymentCodeID" Type="Int32" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="PaymentCodeName" Type="String" />
            <asp:Parameter Name="PaymentCodeDescription" Type="String" />
        </InsertParameters>
    </asp:SqlDataSource>

</asp:Content>
