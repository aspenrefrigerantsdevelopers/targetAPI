
Imports System
Imports System.Collections.Generic
'Imports System.Linq
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports AFS_Logistics

Public Partial Class LTLRateSample
    Inherits System.Web.UI.Page

    Private rateService_v2 As RateService_v2 = New RateService_v2()
    Public Event SelectedIndexChanged As EventHandler
    'Public gv As GridView

	Protected Sub Page_Load(sender As Object, e As EventArgs)


        Dim conn As New DBConnect()
        Dim strSQL As String
        Dim dtShipDate As Date

        strSQL = "EXEC ASF_WebServiceParam @OrderID"

        Dim cmd As New SqlCommand(strSQL, conn.Connection)
        cmd.Parameters.AddWithValue("@OrderID", Request.QueryString("ordid"))
        Dim rdr As SqlDataReader = cmd.ExecuteReader

        rdr.read()

        If Not IsPostBack Then
            lMessage.Text = [String].Empty
            lStackTrace.Text = [String].Empty
            pResults.Controls.Clear()
            tClient.Value = "1686"
            tCarrier.Value = "0"
            tTransMode.SelectedItem.value = "O"
            If IsDate(rdr.Item("DeliverBy")) = False Then
                tShipDateAdv.Text = dtShipDate.Now.ToShortDateString()
            End If
            tOriginAdv.Text = Request.QueryString("origin").ToString()
            tDestinationAdv.Text = rdr.Item("DestinationZip").ToString()
            tItemsAdv.Text = "50|" + rdr.Item("GrossLbs").ToString()
            tAccessorialsAdv.Text = ""
            tRateIncrease.Value = "0"
            tUserNameAdv.Value = "agrefrigweb"
            tPasswordAdv.Value = "service"

        End If

        Try
            Dim rateQuoteResponse As String = [String].Empty

            rateQuoteResponse = rateService_v2.GetLTLRateQuoteAdvanced(tClient.Value.ToString, tCarrier.Value.ToString, _
                    tShipDateAdv.Text.Trim(), tTransMode.Text.Trim(), tOriginAdv.Text.Trim(), tDestinationAdv.Text.Trim(), tItemsAdv.Text.Trim(), _
                            tAccessorialsAdv.Text.Trim(), tRateIncrease.Value.ToString, tUserNameAdv.Value.ToString, tPasswordAdv.Value.ToString)


            'rateQuoteResponse = rateService_v2.GetLTLRateQuoteAdvanced("1686", "0", dtShipDate.Now.ToShortDateString, "O", _
            '            Request.QueryString("origin").ToString, rdr.Item("DestinationZip").ToString(), _
            '                    "50|100", "", "0", "agrefrigweb", "service")

            If [String].IsNullOrEmpty(rateQuoteResponse) Then
                lMessage.Text = "Nothing was returned in the response!!!"
                lStackTrace.Text = [String].Empty
                pResults.Controls.Clear()
                Return
            End If

            Dim ds As New System.Data.DataSet()
            ds.ReadXml(New System.IO.MemoryStream(System.Text.ASCIIEncoding.[Default].GetBytes(rateQuoteResponse)))

            For Each dt As System.Data.DataTable In ds.Tables

                For Each dr As System.Data.DataRow In dt.Rows

                    For Each dc As System.Data.DataColumn In dt.Columns

                        Dim decimalTest As Decimal = 0D

                        If [Decimal].TryParse(dr(dc.ColumnName).ToString(), decimalTest) Then
                            If decimalTest = [Decimal].MinValue Then
                                dr(dc.ColumnName) = DBNull.Value
                            End If
                        End If

                    Next

                Next

                If dt.Columns.Contains("Accessorial1") Then
                    dt.Columns.Remove("Accessorial1")
                    dt.Columns.Remove("AccessorialCost1")
                End If

                If dt.Columns.Contains("Accessorial2") Then
                    dt.Columns.Remove("Accessorial2")
                    dt.Columns.Remove("AccessorialCost2")
                End If

                If dt.Columns.Contains("Accessorial3") Then
                    dt.Columns.Remove("Accessorial3")
                    dt.Columns.Remove("AccessorialCost3")
                End If

                If dt.Columns.Contains("Accessorial4") Then
                    dt.Columns.Remove("Accessorial4")
                    dt.Columns.Remove("AccessorialCost4")
                End If

                If dt.Columns.Contains("OriginTerminal") Then
                    dt.Columns.Remove("OriginTerminal")
                    dt.Columns.Remove("OriginTerminalAddressLine1")
                    dt.Columns.Remove("OriginTerminalAddressLine2")
                    dt.Columns.Remove("OriginTerminalCity")
                    dt.Columns.Remove("OriginTerminalCode")
                    dt.Columns.Remove("OriginTerminalStateProvince")
                    dt.Columns.Remove("OriginTerminalPostalCode")
                    dt.Columns.Remove("OriginTerminalPhone")
                    dt.Columns.Remove("OriginTerminalFax")
                    dt.Columns.Remove("OriginTerminalTollFreePhone")
                    dt.Columns.Remove("OriginTerminalContactName")
                    dt.Columns.Remove("OriginTerminalContactTitle")
                    dt.Columns.Remove("OriginTerminalEmail")
                End If

                If dt.Columns.Contains("DestinationTerminal") Then
                    dt.Columns.Remove("DestinationTerminal")
                    dt.Columns.Remove("DestinationTerminalAddressLine1")
                    dt.Columns.Remove("DestinationTerminalAddressLine2")
                    dt.Columns.Remove("DestinationTerminalCity")
                    dt.Columns.Remove("DestinationTerminalCode")
                    dt.Columns.Remove("DestinationTerminalStateProvince")
                    dt.Columns.Remove("DestinationTerminalPostalCode")
                    dt.Columns.Remove("DestinationTerminalPhone")
                    dt.Columns.Remove("DestinationTerminalFax")
                    dt.Columns.Remove("DestinationTerminalTollFreePhone")
                    dt.Columns.Remove("DestinationTerminalContactName")
                    dt.Columns.Remove("DestinationTerminalContactTitle")
                    dt.Columns.Remove("DestinationTerminalEmail")
                End If


                dt.Columns.Remove("AccessorialCosts")
                dt.Columns.Remove("CarrierID")
                dt.Columns.Remove("CarrierSCAC")
                dt.Columns.Remove("DestinationCity")
                dt.Columns.Remove("DestinationStateProvince")
                dt.Columns.Remove("DestinationPostalCode")

                dt.Columns.Remove("OriginalCost")
                dt.Columns.Remove("OriginalFreightCost")
                dt.Columns.Remove("OriginalFuelSurcharge")

                dt.Columns.Remove("OriginCity")
                dt.Columns.Remove("OriginStateProvince")
                dt.Columns.Remove("OriginPostalCode")

                dt.Columns.Remove("ServiceGuide")
                'dt.Columns.Add("CarrierSelect", Type.GetType("System.String")).SetOrdinal(0)

                Dim gv As New GridView
                Dim gv_SelectedIndexChanged As EventHandler

                AddHandler gv.SelectedIndexChanged, AddressOf Me.gv_SelectedIndexChanged

                'gv.AutoGenerateColumns = False

                gv.id = dt.tablename
                gv.DataSource = dt.DefaultView
                'gv.DataKeyNames = "CarrierID"

                'If gv.id <> "RateQuote1" Then gv.ShowHeader = False

                Dim cmdField As CommandField = New CommandField()
                'cmdField.HeaderText = "Select Carrier"
                cmdField.ShowSelectButton = True
                cmdField.SelectText = "Select Carrier"
                gv.Columns.Add(cmdField)

                gv.DataBind()

                pResults.Controls.Add(gv)

                'pResults.Controls.Add(New LiteralControl("<br />"))
            Next

            lMessage.Text = [String].Empty
            'lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException
            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            'lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            'lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try

        Me.tShipDateAdv.Text = dtShipDate.Now.ToShortDateString
        Me.tTransMode.Text = "O"
        Me.tOriginAdv.Text = Request.QueryString("origin")
        Me.tDestinationAdv.Text = rdr.Item("DestinationZip").ToString()
        'Me.tItemsAdv.Text = rdr.Item("Quantity").ToString() + "|" + rdr.Item("GrossLbs").ToString()
        Me.tItemsAdv.Text = "50|100"
        Me.tOriginAdv.Text = Request.QueryString("origin")


        'If len(rdr.Item("DeliverBy").ToString()) > 0 Then
        'Me.tShipDateAdv.Text = rdr.Item("DeliverBy").ToString()
        'Else
        'End If

        Me.tShipDateAdv.Text = dtShipDate.Now.ToShortDateString
        Me.tTransMode.Text = "O"
        Me.tOriginAdv.Text = Request.QueryString("origin")
        Me.tDestinationAdv.Text = rdr.Item("DestinationZip").ToString()
        'Me.tItemsAdv.Text = rdr.Item("Quantity").ToString() + "|" + rdr.Item("GrossLbs").ToString()
        Me.tItemsAdv.Text = "50|100"
        Me.tOriginAdv.Text = Request.QueryString("origin")




    End Sub

    Protected Sub GetQuote(ByVal sender As Object, ByVal e As EventArgs)

        'If Not IsPostBack Then
        lMessage.Text = [String].Empty
        lStackTrace.Text = [String].Empty
        pResults.Controls.Clear()
        'End if

        Try
            Dim rateQuoteResponse As String = [String].Empty
            If sender.Equals(bAdvRate) Then
                rateQuoteResponse = rateService_v2.GetLTLRateQuoteAdvanced(tClient.Value.ToString, tCarrier.Value.ToString, tShipDateAdv.Text.Trim(), tTransMode.Text.Trim(), tOriginAdv.Text.Trim(), tDestinationAdv.Text.Trim(), _
     tItemsAdv.Text.Trim(), tAccessorialsAdv.Text.Trim(), tRateIncrease.Value.ToString, tUserNameAdv.Value.ToString, tPasswordAdv.Value.ToString)

            End If

            If [String].IsNullOrEmpty(rateQuoteResponse) Then
                lMessage.Text = "Nothing was returned in the response!!!"
                lStackTrace.Text = [String].Empty
                pResults.Controls.Clear()
                Return
            End If

            Dim ds As New System.Data.DataSet()
            ds.ReadXml(New System.IO.MemoryStream(System.Text.ASCIIEncoding.[Default].GetBytes(rateQuoteResponse)))

            'For Each dt As System.Data.DataTable In ds.Tables
            '	For Each dr As System.Data.DataRow In dt.Rows
            '		For Each dc As System.Data.DataColumn In dt.Columns
            '			Dim decimalTest As Decimal = 0D
            '			If [Decimal].TryParse(dr(dc.ColumnName).ToString(), decimalTest) Then
            '				If decimalTest = [Decimal].MinValue Then
            '					dr(dc.ColumnName) = DBNull.Value
            '				End If
            '			End If
            '		Next
            '	Next

            For Each dt As System.Data.DataTable In ds.Tables
                For Each dr As System.Data.DataRow In dt.Rows
                    For Each dc As System.Data.DataColumn In dt.Columns
                        Dim decimalTest As Decimal = 0D
                        If [Decimal].TryParse(dr(dc.ColumnName).ToString(), decimalTest) Then
                            If decimalTest = [Decimal].MinValue Then
                                dr(dc.ColumnName) = DBNull.Value
                            End If
                        End If
                    Next

                Next

                dt.Columns.Add("CarrierSelect", Type.GetType("System.String")).SetOrdinal(0)

                'dt.Columns.Remove("AccessorialCosts")
                dt.Columns.Remove("CarrierID")
                dt.Columns.Remove("CarrierSCAC")
                dt.Columns.Remove("DestinationCity")
                dt.Columns.Remove("DestinationStateProvince")
                dt.Columns.Remove("DestinationPostalCode")
                dt.Columns.Remove("DestinationTerminal")
                dt.Columns.Remove("DestinationTerminalAddressLine1")
                dt.Columns.Remove("DestinationTerminalAddressLine2")

                dt.Columns.Remove("DestinationTerminalCity")
                dt.Columns.Remove("DestinationTerminalCode")
                dt.Columns.Remove("DestinationTerminalStateProvince")
                dt.Columns.Remove("DestinationTerminalPostalCode")
                dt.Columns.Remove("DestinationTerminalPhone")
                dt.Columns.Remove("DestinationTerminalFax")
                dt.Columns.Remove("DestinationTerminalTollFreePhone")

                dt.Columns.Remove("DestinationTerminalContactName")
                dt.Columns.Remove("DestinationTerminalContactTitle")
                dt.Columns.Remove("DestinationTerminalEmail")
                'dt.Columns.Remove("Distance")
                'dt.Columns.Remove("EstimateCost")
                'dt.Columns.Remove("FreightCost")
                'dt.Columns.Remove("FuelSurcharge")
                dt.Columns.Remove("OriginalCost")

                dt.Columns.Remove("OriginalFreightCost")
                dt.Columns.Remove("OriginalFuelSurcharge")
                dt.Columns.Remove("OriginCity")
                dt.Columns.Remove("OriginStateProvince")
                dt.Columns.Remove("OriginPostalCode")
                dt.Columns.Remove("OriginTerminal")
                dt.Columns.Remove("OriginTerminalAddressLine1")
                dt.Columns.Remove("OriginTerminalAddressLine2")
                dt.Columns.Remove("OriginTerminalCity")

                dt.Columns.Remove("OriginTerminalCode")
                dt.Columns.Remove("OriginTerminalStateProvince")
                dt.Columns.Remove("OriginTerminalPostalCode")
                'dt.Columns.Remove("OriginTerminalPhone")
                'dt.Columns.Remove("OriginTerminalFax")
                'dt.Columns.Remove("OriginTerminalTollFreePhone")
                'dt.Columns.Remove("OriginTerminalContactName")
                'dt.Columns.Remove("OriginTerminalContactTitle")
                'dt.Columns.Remove("OriginTerminalEmail")

                'dt.Columns.Remove("ServiceDays")
                dt.Columns.Remove("ServiceGuide")
                'dt.Columns.Remove("ServiceType")
                'dt.Columns.Remove("ShipmentDate")
                'dt.Columns.Remove("ShipmentMethod")
                'dt.Columns.Remove("TrueCost")
                'dt.Columns.Remove("Accessorial1")
                'dt.Columns.Remove("AccessorialCost1")
                'dt.Columns.Remove("Accessorial2")
                'dt.Columns.Remove("AccessorialCost2")
                'dt.Columns.Remove("Accessorial3")
                'dt.Columns.Remove("AccessorialCost3")
                'dt.Columns.Remove("Accessorial4")
                'dt.Columns.Remove("AccessorialCost4")

                Dim gv As New GridView()
                gv.DataSource = dt.DefaultView
                gv.DataBind()

                pResults.Controls.Add(gv)
                'pResults.Controls.Add(New LiteralControl("<br />"))
            Next

            lMessage.Text = [String].Empty
            'lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException
            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            'lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            'lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try
    End Sub


    Sub gv_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)

        Dim gv As Gridview
        Dim gvrow As GridViewRow

        gv = DirectCast(sender, GridView)

        gvrow = gv.SelectedRow

        Trace.Warn("you selected " & gvrow.Cells(1).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(2).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(3).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(4).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(5).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(6).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(7).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(8).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(9).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(10).Text & "")


        Dim conn As New DBConnect()
        Dim strSQL As String
        Dim dtShipDate As Date

        strSQL = "INSERT INTO OrderCarrier (OrderID,CarrierName,CarrierChoice) " & _
                    " VALUES(@OrderID,@CarrierName,@CarrierChoice) "

        Dim cmd As New SqlCommand(strSQL, conn.Connection)
        cmd.Parameters.AddWithValue("@CarrierName", gvrow.Cells(1).Text)
        cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("ordid"), Integer))
        'cmd.Parameters.AddWithValue("@CarrierID", CType(gvrow.Cells(2).Text, Integer)
        cmd.Parameters.AddWithValue("@CarrierChoice", 1)

        cmd.CommandText = strSQL
        cmd.ExecuteNonQuery()

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "close", "window.close();", True)

    End Sub

End Class



