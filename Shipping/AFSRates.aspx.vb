
Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.Web.HttpRequest
Imports System.Net.WebRequest
Imports AFS_Logistics
Imports UseAPI.freight_API

Public Partial Class LTLRateSample
    Inherits System.Web.UI.Page

    Private conn As DBConnect = New DBConnect()
    Private rateService_v2 As RateService_v2 = New RateService_v2()
    Private carrierService_v2 As CarrierService_v2 = New CarrierService_v2
    Private strDate As String
    Private strSQL As String
    Private targetAPI As UseAPI.freight_API = New UseAPI.freight_API()

    Private IsServiceAvailable As Boolean = False
    Private ServiceUrl As String
    Private strPageReferrerUrl As String
    Private strReferrerUrl As String
    Private strPageUrl As String
    Private strUrl As String
    Private strReturnUrl As String
    'Private intCarrierCantDeliverSelected As Integer
    Private intCarrierCantDeliverSelected As String

    Public Event SelectedIndexChanged As EventHandler
    Public Event RowCreated As GridViewRowEventHandler
    Public Event RowDataBound As GridViewRowEventHandler
    Public Event DataBound As EventHandler


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)

        'Dim conn As New DBConnect()
        'Dim strSQL As String
        Dim strWhses As String
        Dim dtShipDate As Date
        Dim dtDeliveryDate As Date

        Master.Title = "AFS Rate Quote Service"
        Master.TitleBar = "AFS Rate Quote Service"

        strSQL = "EXEC AFS_WebServiceParam @OrderID"

        Dim cmd As New SqlCommand(strSQL, conn.Connection)
        cmd.Parameters.AddWithValue("@OrderID", Request.QueryString("orderid"))
        Dim rdr As SqlDataReader = cmd.ExecuteReader

        rdr.read()

        lMessage.Text = [String].Empty
        lStackTrace.Text = [String].Empty
        pResults.Controls.Clear()

        If Not IsPostBack Then

            Trace.Warn("http://intranet.refron.com/apps/order/reserve_target.asp?" + Request.QueryString.ToString() + "")

            If Request.UrlReferrer Is Nothing Then
                strPageReferrerUrl = "http://intranet.refron.com/apps/order/reserve_target.asp?" + Request.QueryString.ToString() + ""
            Else
                strPageReferrerUrl = Request.UrlReferrer.ToString()
            End If

            strPageUrl = Request.Url.ToString()

            strReferrerUrl = strPageReferrerUrl.Substring(0, strPageReferrerUrl.IndexOf("?"))
            strUrl = strPageUrl.Substring(0, strPageUrl.IndexOf("?"))
            strReturnUrl = strReferrerUrl + "?" + Request.QueryString.ToString()

            ViewState.Add("PageUrl", Request.Url.ToString())
            ViewState.Add("PageReferrerUrl", strPageReferrerUrl)
            ViewState.Add("ReturnUrl", strReturnUrl)

            trace.warn(strReturnUrl)

            strWhses = "6A1,99A,99D,99H,99M,99I,6AZ"
            tClient.Value = "1686"
            tCarrier.Value = "0"

            Select Case DirectCast(rdr.Item("DeliveryPickupOrder"), Integer)

                Case Is = 1

                    If strWhses.IndexOf(Request.QueryString("whse").ToString) > 0 Then

                        tTransMode.Value = "T"
                        lTransMode.Text = tTransMode.Value.ToString + " - Third Party"

                    Else

                        tTransMode.Value = "O"
                        lTransMode.Text = tTransMode.Value.ToString + " - Outbound"

                    End If

                Case Is = 2
                    tTransMode.Value = "I"
                    lTransMode.Text = tTransMode.Value.ToString + " - Inbound"

            End Select

            tShipDateAdv.Text = dtShipDate.Now.ToShortDateString()

            Select Case DatePart("w", Now)
                Case 1 'Sunday
                    tShipDateAdv.Text = DateAdd("d", 1, Now).ToShortDateString()
                Case 2 To 5 'Monday to Thursday
                    Select Case DatePart("h", Now) >= 13 'After 1pm
                        Case True 'Next Day
                            tShipDateAdv.Text = DateAdd("d", 1, Now).ToShortDateString()
                        Case Else 'Today 
                            tShipDateAdv.Text = Now.ToShortDateString()
                    End Select
                Case 6 'Friday
                    Select Case DatePart("h", Now) >= 13 'After 1pm
                        Case True 'Following Monday
                            tShipDateAdv.Text = DateAdd("d", 3, Now).ToShortDateString()
                        Case Else 'Today
                            tShipDateAdv.Text = Now.ToShortDateString()
                    End Select
                Case 7 'Saturday
                    tShipDateAdv.Text = DateAdd("d", 2, Now).ToShortDateString()
            End Select

            'Trace.Warn(Weekday(dtShipDate.Now).ToString)
            'Trace.Warn(Weekday(#9/11/2011#).ToString)

            If Len(rdr.Item("DeliverBy").ToString) = 6 Then

                strDate = Left(rdr.Item("DeliverBy").ToString, 2) + "/" + Mid(rdr.Item("DeliverBy").ToString, 3, 2) + "/20" + Right(rdr.Item("DeliverBy").ToString, 2)

                If IsDate(strDate) Then
                    lDeliveryDate.Text = strDate
                Else
                    'lDeliveryDate.Text = dtDeliveryDate.Now.ToShortDateString()
                End If

            Else
                lDeliveryDate.Text = dtDeliveryDate.Now.ToShortDateString()
            End If

            If tTransMode.Value = "I" Then
                tDestinationAdv.Value = Request.QueryString("origin").ToString()
                tOriginAdv.Value = rdr.Item("DestinationZip").ToString()

            Else
                tOriginAdv.Value = Request.QueryString("origin").ToString()
                tDestinationAdv.Value = rdr.Item("DestinationZip").ToString()

            End If

            lItemsAdv.Text = rdr.Item("freightClass").ToString() '= "70"

            If rdr.Item("EmptyGrossLbs").ToString = "" Then
                tItemsWght.Text = rdr.Item("GrossLbs").ToString()
            Else
                tItemsWght.Text = rdr.Item("EmptyGrossLbs").ToString()
            End If

            If (rdr.Item("freightClass").ToString() <> "77.5") Then
                tAccessorialsAdv.Value = "HAZ|"
                lAccessorialsAdv.Text = tAccessorialsAdv.Value
            End If

            'tAccessorialsAdv.Value = "HAZ|"
            'lAccessorialsAdv.Text = tAccessorialsAdv.Value

            tRateIncrease.Value = "0"
            tUserNameAdv.Value = "agrefrigweb"
            tPasswordAdv.Value = "service"

            Trace.Warn("Entering GetCarriers")
            GetCarriers(bCarrierList, New System.EventArgs)
            Trace.Warn("Back from GetCarriers")

        End If

        strPageReferrerUrl = ViewState("PageReferrerUrl").ToString()
        strPageUrl = ViewState("PageUrl").ToString()
        strReturnUrl = ViewState("ReturnUrl").ToString()
        intCarrierCantDeliverSelected = CType(ViewState("CarrierCantDeliverSelected"), String)

        Try
            ServiceUrl = rateService_v2.Url.ToString + "?wsdl"

            'MetadataExchangeClient(mexClient = New MetadataExchangeClient(New Uri(ServiceUri), MetadataExchangeClientMode.HttpGet))
            'MetadataSet(metadata = mexClient.GetMetadata())

            IsServiceAvailable = True

        Catch ex As Exception
            IsServiceAvailable = False

        End Try

        Trace.Warn(rateService_v2.Url.ToString)

        If ltlA.Visible = True And IsServiceAvailable = True Then

            Trace.Warn("Entering GetQuote")
            GetQuote(bAdvRate, New System.EventArgs)
            Trace.Warn("Back from GetQuote")
        End If

        pStatic.Controls.Add(New LiteralControl("<br />"))

        Dim dte As DataTable = New DataTable

        dte.Columns.Add("CarrierID").SetOrdinal(0)
        dte.Columns.Add("CarrierName").SetOrdinal(1)
        dte.Columns.Add("ShipmentDate").SetOrdinal(2)
        dte.Columns.Add("ServiceDays").SetOrdinal(3)
        dte.Columns.Add("DeliveryDate").SetOrdinal(4)
        dte.Columns.Add("Distance").SetOrdinal(5)
        dte.Columns.Add("FreightCost").SetOrdinal(6)
        dte.Columns.Add("FuelSurcharge").SetOrdinal(7)
        dte.Columns.Add("AccessorialCosts").SetOrdinal(8)
        dte.Columns.Add("EstimateCost").SetOrdinal(9)
        dte.Columns.Add("TrueCost").SetOrdinal(10)
        dte.Columns.Add("ServiceType").SetOrdinal(11)
        dte.Columns.Add("ShipmentMethod").SetOrdinal(12)

        Dim dtr As DataRow = dte.NewRow()
        dtr.Item("CarrierID") = -1
        dtr.Item("CarrierName") = "ARI Truck / Whse. Truck"

        dte.Rows.Add(dtr)

        dtr = dte.NewRow()
        dtr.Item("CarrierID") = -2
        dtr.Item("CarrierName") = "Customer Pickup"

        dte.Rows.Add(dtr)

        dtr = dte.NewRow()
        dtr.Item("CarrierID") = -3
        dtr.Item("CarrierName") = "Reserve ONLY - No Shipment"

        dte.Rows.Add(dtr)

        Dim gve As New GridView

        AddHandler gve.SelectedIndexChanged, AddressOf Me.gve_SelectedIndexChanged
        AddHandler gve.RowCreated, AddressOf Me.gve_RowCreated
        AddHandler gve.RowDataBound, AddressOf Me.gve_RowDataBound

        gve.DataSource = dte.DefaultView

        Dim cmdField2 As CommandField = New CommandField()
        cmdField2.HeaderText = "Click Link to Select a Carrier"
        cmdField2.ShowSelectButton = True
        gve.Columns.Add(cmdField2)
        gve.DataBind()

        pStatic.Controls.Add(gve)

        pStatic.Controls.Add(New LiteralControl("<br />"))

        pStatic.Controls.Add(New LiteralControl("<asp:Button ID=""bSubmitRate"" runat=""server"" Text=""Accept Rate Quote"" OnClick=""GetQuote"" />"))
        pStatic.Controls.Add(New LiteralControl("<asp:Button ID=""bCancelRate"" runat=""server"" Text=""Cancel"" OnClick=""GetQuote"" />"))

        rdr.Close()
        rdr.Dispose()
        cmd.Dispose()
        'conn.dispose()

    End Sub

    Protected Sub GetQuote(ByVal sender As Object, ByVal e As EventArgs)

        lMessage.Text = [String].Empty
        lStackTrace.Text = [String].Empty
        pResults.Controls.Clear()

        If Not IsDate(tShipDateAdv.Text) Then
            Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "AlertMessageBox", "alert('Shipment date is not valid');", True)
            Exit Sub
        Else

            Trace.Warn("In GetQuote")

        End If

        Try
            Dim rateQuoteResponse As String = [String].Empty
            Dim queryID As String
            Dim BOLFileName As String
            queryID = "0"

            tItemsAdv.Value = lItemsAdv.Text + "|" + tItemsWght.Text

            Trace.Warn("ClientID - " & tClient.Value.ToString & "")
            Trace.Warn("Carrier - " & tCarrier.Value.ToString & "")
            Trace.Warn("ShipDate - " & tShipDateAdv.Text.Trim() & "")
            Trace.Warn("Transport Mode - " & tTransMode.Value.ToString & "")
            Trace.Warn("Origin - " & tOriginAdv.Value.ToString & "")
            Trace.Warn("Dest - " & tDestinationAdv.Value.ToString & "")
            Trace.Warn("Items - " & tItemsAdv.Value.ToString & "")
            Trace.Warn("Accessory - " & tAccessorialsAdv.Value.ToString & "")
            Trace.Warn("Rate - " & tRateIncrease.Value.ToString & "")
            Trace.Warn("User - " & tUserNameAdv.Value.ToString & "")
            Trace.Warn("Pwd - " & tPasswordAdv.Value.ToString & "")

            'rateQuoteResponse = rateService_v2.GetLTLRateQuoteAdvanced(tClient.Value.ToString, tCarrier.Value.ToString, _
            '        tShipDateAdv.Text.Trim(), tTransMode.Value.ToString, tOriginAdv.Value.ToString, tDestinationAdv.Value.ToString, _
            '            tItemsAdv.Value.ToString, tAccessorialsAdv.Value.ToString, tRateIncrease.Value.ToString, _
            '                tUserNameAdv.Value.ToString, tPasswordAdv.Value.ToString)


            Dim TargetAPI_Carriers As DataTable
            targetAPI.shipperZip = tOriginAdv.Value.ToString
            targetAPI.consigneeZip = tDestinationAdv.Value.ToString
            targetAPI.weight = tItemsWght.Text.ToString
            targetAPI.freightClass = lItemsAdv.Text.ToString
            targetAPI.orderNumber = Request.QueryString("orderid")
            'TargetAPI_Carriers = targetAPI.GetTargetFreight(targetAPI)
            TargetAPI_Carriers = targetAPI.GetTargetFreightwithBOL(targetAPI)

            'If [String].IsNullOrEmpty(TargetAPI_Carriers) Then
            '    lMessage.Text = "Nothing was returned in the response!!!"
            '    lStackTrace.Text = [String].Empty
            '    pResults.Controls.Clear()
            '    Return
            'End If

            Dim ds As New System.Data.DataSet()
            'ds.ReadXml(New System.IO.MemoryStream(System.Text.ASCIIEncoding.[Default].GetBytes(rateQuoteResponse)))

            ds.Tables.Add(TargetAPI_Carriers)

            For Each dt As System.Data.DataTable In ds.Tables

                Dim dtDeliverBy As Date = CType(lDeliveryDate.Text, Date)
                Dim dtShipDate As Date = Convert.ToDateTime(tShipDateAdv.Text)
                Dim strShipDate As String = String.Format("{0:d}", Convert.ToDateTime(tShipDateAdv.Text))
                Dim dtDeliveryDate As Date = DateAdd(DateInterval.Day, CType(dt.Rows(0)("ServiceDays"), Integer), dtShipDate)
                Dim strDeliveryDate As String = String.Format("{0:d}", DateAdd(DateInterval.Day, CType(dt.Rows(0)("ServiceDays"), Integer), dtShipDate))
                Dim CarrierName As String = "None"

                dt.Columns("CarrierID").SetOrdinal(0)
                dt.Columns("CarrierName").SetOrdinal(1)
                dt.Columns("ShipmentDate").SetOrdinal(2)
                dt.Columns("ServiceDays").SetOrdinal(3)
                dt.Columns("DeliveryDate").SetOrdinal(4)
                dt.Columns("Distance").SetOrdinal(5)
                dt.Columns("FreightCost").SetOrdinal(6)
                dt.Columns("FuelSurcharge").SetOrdinal(7)
                dt.Columns("AccessorialCosts").SetOrdinal(8)
                dt.Columns("EstimateCost").SetOrdinal(9)
                dt.Columns("TrueCost").SetOrdinal(10)
                dt.Columns("ServiceType").SetOrdinal(11)
                dt.Columns("ShipmentMethod").SetOrdinal(12)
                dt.Columns("QueryID").SetOrdinal(13)

                Dim gv As New GridView
                Dim gv_SelectedIndexChanged As EventHandler
                Dim gv_RowCreated As EventHandler
                Dim gv_DataBound As EventHandler

                AddHandler gv.SelectedIndexChanged, AddressOf Me.gv_SelectedIndexChanged
                AddHandler gv.RowCreated, AddressOf Me.gv_RowCreated
                AddHandler gv.RowDataBound, AddressOf Me.gv_RowDataBound

                Dim cmdField As CommandField = New CommandField()
                cmdField.HeaderText = "Click Link to Select a Carrier"
                cmdField.ShowSelectButton = True
                gv.Columns.Add(cmdField)

                gv.ID = dt.TableName
                gv.DataSource = dt.DefaultView

                For Each dr As System.Data.DataRow In dt.Rows

                    For Each dc As System.Data.DataColumn In dt.Columns

                        Dim decimalTest As Decimal = 0D

                        If [Decimal].TryParse(dr(dc.ColumnName).ToString(), decimalTest) Then
                            If decimalTest = [Decimal].MinValue Then
                                dr(dc.ColumnName) = DBNull.Value
                            End If

                        End If

                    Next

                    dr.Item(2) = strShipDate
                    dr.Item(4) = strDeliveryDate

                    If dtDeliverBy >= dtDeliveryDate Then
                        Trace.Warn(dtDeliverBy.ToString)
                        Trace.Warn(dtDeliveryDate.ToString)

                        Dim m_conn As New DBConnect()
                        strSQL = "Target_Carriers_Insert"

                        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)

                        cmd.CommandType = CommandType.StoredProcedure

                        cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
                        cmd.Parameters.AddWithValue("@CarrierID", dr.Item("CarrierID"))
                        cmd.Parameters.AddWithValue("@CarrierName", dr.Item("CarrierName").ToString)
                        cmd.Parameters.AddWithValue("@Distance", dr.Item("Distance"))
                        cmd.Parameters.AddWithValue("@AccessorialCosts", dr.Item("AccessorialCosts"))
                        cmd.Parameters.AddWithValue("@EstimateCost", dr.Item("EstimateCost"))
                        cmd.Parameters.AddWithValue("@FreightCost", dr.Item("FreightCost"))
                        cmd.Parameters.AddWithValue("@FuelSurcharge", dr.Item("FuelSurcharge"))
                        cmd.Parameters.AddWithValue("@ServiceDays", dr.Item("ServiceDays"))
                        cmd.Parameters.AddWithValue("@ServiceType", dr.Item("ServiceType"))
                        cmd.Parameters.AddWithValue("@ShipmentDate", Convert.ToDateTime(tShipDateAdv.Text))
                        cmd.Parameters.AddWithValue("@ShipmentMethod", dr.Item("ShipmentMethod"))
                        cmd.Parameters.AddWithValue("@TrueCost", dr.Item("TrueCost"))
                        cmd.Parameters.AddWithValue("@CarrierChoice", False)
                        cmd.Parameters.AddWithValue("@CarrierPhone", DBNull.Value)
                        cmd.Parameters.AddWithValue("@DeliveryDate", dtDeliveryDate)
                        cmd.Parameters.AddWithValue("@QueryID", dr.Item("QueryID"))

                        cmd.CommandText = strSQL
                        cmd.ExecuteNonQuery()

                        cmd.Dispose()
                        m_conn.Dispose()

                    End If
                    cmdField.SelectText = dr.Item("CarrierName").ToString
                Next
                gv.DataBind()
                pResults.Controls.Add(gv)
            Next

            lMessage.Text = [String].Empty
            lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException

            If soapEx.Detail.ChildNodes(0).InnerText.Contains("Call AFS") Then
                GetForm(lb_CarrierForm, New System.EventArgs)
            End If

            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try

    End Sub


    Protected Sub gv_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs)

        Dim gv As Gridview
        Dim cmdField As CommandField

        gv = DirectCast(sender, GridView)

        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim rv As DataRowView = CType(e.Row.DataItem, DataRowView)

            Dim sb As LinkButton = CType(e.Row.Cells(0).Controls(0), LinkButton)
            Dim stCarrier As String = CType(rv("CarrierName"), String)

            sb.Text = stCarrier


            Dim rowView As DataRowView = CType(e.Row.DataItem, DataRowView)
            Dim dtShipDate As Date = CType(rowView("ShipmentDate"), Date)
            Dim strShipDate As String = String.Format("{0:d}", CType(rowView("ShipmentDate"), Date))
            Dim dtDeliveryDate As Date = DateAdd(DateInterval.Day, CType(rowView("ServiceDays"), Integer), CType(rowView("ShipmentDate"), Date))
            Dim strDeliveryDate As String = String.Format("{0:d}", DateAdd(DateInterval.Day, CType(rowView("ServiceDays"), Integer), CType(rowView("ShipmentDate"), Date)))
            Dim dtDeliverBy As Date = CType(lDeliveryDate.Text, Date)
            Dim strDeliverBy As String = lDeliveryDate.Text

            e.Row.Cells(3).Text = strShipDate
            e.Row.Height = Unit.Pixel(30)

            Trace.Warn(strDeliverBy + " - " + strDeliveryDate)
            Trace.Warn(Weekday(dtDeliveryDate).ToString)

            If dtDeliverBy < CType(dtDeliveryDate.ToShortDateString, Date) Then
                Trace.Warn(DateAdd(DateInterval.Day, CType(rowView("ServiceDays"), Integer), CType(rowView("ShipmentDate"), Date)).ToString)

                e.Row.BackColor = Drawing.Color.Tomato

                Dim SelectButton As LinkButton = CType(e.Row.Cells(0).Controls(0), LinkButton)
                Dim strCarrier As String = CType(rowView("CarrierName"), String)

                SelectButton.Text = strCarrier + "<br/>CANNOT DELIVER BY <strong>DELIVERY DATE!</strong>"

            End If

        End If

        gv.Columns(0).ItemStyle.Wrap = False

    End Sub

    Sub gv_RowCreated(ByVal sender As Object, ByVal e As GridViewRowEventArgs)

        Dim gv As Gridview

        gv = DirectCast(sender, GridView)
        e.Row.Cells(1).Visible = False
        e.Row.Cells(2).Visible = False
        'e.Row.Cells(12).Visible = False
        'e.Row.Cells(13).Visible = False

    End Sub

    Protected Sub gve_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs)

        Dim gv As Gridview

        gv = DirectCast(sender, GridView)

        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim SelectButton As LinkButton = CType(e.Row.Cells(0).Controls(0), LinkButton)
            Dim rowView As DataRowView = CType(e.Row.DataItem, DataRowView)
            Dim strCarrier As String = CType(rowView("CarrierName"), String)

            SelectButton.Text = strCarrier
            e.Row.Height = Unit.Pixel(30)
        End If

        gv.Columns(0).ItemStyle.Wrap = False

    End Sub

    Public Sub gve_RowCreated(ByVal sender As Object, ByVal e As GridViewRowEventArgs)

        Dim gv As Gridview

        gv = DirectCast(sender, GridView)
        e.Row.Cells(1).Visible = False
        e.Row.Cells(2).Visible = False
        e.Row.Cells(12).Visible = False
        e.Row.Cells(13).Visible = False

    End Sub

    Sub gv_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)

        Dim gv As Gridview
        Dim gvrow As GridViewRow
        Dim id As String
        Dim strCarrier As String
        Dim intDistance As Integer
        Dim decAccessorial As Decimal
        Dim decEstimateCost As Decimal
        Dim decFreightCost As Decimal
        Dim decFuelSurcharge As Decimal
        Dim intServiceDays As Integer
        Dim strServiceType As String
        Dim intShipmentMethod As Integer
        Dim decTrueCost As Decimal
        Dim dtDeliveryDate As Date
        Dim dtQueryID As Integer
        Dim BOLFileName As String

        gv = DirectCast(sender, GridView)
        gvrow = gv.SelectedRow

        'id = CInt(gvrow.Cells(1).Text)
        id = gvrow.Cells(1).Text
        strCarrier = Trim(gvrow.Cells(2).Text)
        'intDistance = CType(gvrow.Cells(6).Text, Integer)
        intDistance = 0
        decAccessorial = CType(gvrow.Cells(9).Text, Decimal)
        decEstimateCost = CType(gvrow.Cells(10).Text, Decimal)
        decFreightCost = CType(gvrow.Cells(7).Text, Decimal)
        decFuelSurcharge = CType(gvrow.Cells(8).Text, Decimal)
        intServiceDays = CType(gvrow.Cells(4).Text, Integer)
        strServiceType = Trim(gvrow.Cells(12).Text)
        intShipmentMethod = CType(gvrow.Cells(13).Text, Integer)
        decTrueCost = CType(gvrow.Cells(11).Text, Decimal)
        dtDeliveryDate = Convert.ToDateTime(gvrow.Cells(5).Text)
        dtQueryID = CType(gvrow.Cells(14).Text, Integer)

        'BOLFileName = targetAPI.ExecuteBillsOfLading(dtQueryID.ToString)

        If gv.SelectedRow.BackColor = Drawing.Color.Tomato Then
            intCarrierCantDeliverSelected = id
            ViewState.Add("CarrierCantDeliverSelected", id)
        End If

        'Dim conn As New DBConnect()
        'Dim strSQL As String

        'strSQL = "AFS_Carriers_Insert"
        strSQL = "Target_Carriers_Insert"

        Dim cmd As New SqlCommand(strSQL, conn.Connection)
        cmd.CommandType = CommandType.StoredProcedure

        cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
        cmd.Parameters.AddWithValue("@CarrierID", id)
        cmd.Parameters.AddWithValue("@CarrierName", strCarrier)
        cmd.Parameters.AddWithValue("@Distance", intDistance)
        cmd.Parameters.AddWithValue("@AccessorialCosts", decAccessorial)
        cmd.Parameters.AddWithValue("@EstimateCost", decEstimateCost)
        cmd.Parameters.AddWithValue("@FreightCost", decFreightCost)
        cmd.Parameters.AddWithValue("@FuelSurcharge", decFuelSurcharge)
        cmd.Parameters.AddWithValue("@ServiceDays", intServiceDays)
        cmd.Parameters.AddWithValue("@ServiceType", strServiceType)
        cmd.Parameters.AddWithValue("@ShipmentDate", Convert.ToDateTime(tShipDateAdv.Text))
        cmd.Parameters.AddWithValue("@ShipmentMethod", intShipmentMethod)
        cmd.Parameters.AddWithValue("@TrueCost", decTrueCost)
        cmd.Parameters.AddWithValue("@CarrierChoice", 1)
        cmd.Parameters.AddWithValue("@CarrierPhone", DBNull.Value)
        cmd.Parameters.AddWithValue("@DeliveryDate", dtDeliveryDate)
        cmd.Parameters.AddWithValue("@QueryID", dtQueryID)

        cmd.CommandText = strSQL
        cmd.ExecuteNonQuery()

        If intCarrierCantDeliverSelected <> id Then
            If (intCarrierCantDeliverSelected Is Nothing) Then
                intCarrierCantDeliverSelected = "0"
            End If
            strSQL = "DELETE FROM OrderCarrier WHERE OrderID = @OrderID And CarrierID = @CarrierID"

            cmd.Parameters.Clear()
            cmd.CommandType = CommandType.Text
            cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
            cmd.Parameters.AddWithValue("@CarrierID", intCarrierCantDeliverSelected)
            cmd.CommandText = strSQL
            cmd.ExecuteNonQuery()

        End If

        cmd.dispose()
        'conn.dispose()

        tCarrierChoice.value = id.ToString

        bSubmitRate.enabled = True

        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "AlertMessageBox", "alert('" + gvrow.Cells(3).Text + " - has been selected');", True)
        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "close", "window.close();", True)

    End Sub

    Sub gve_SelectedIndexChanged(ByVal sender As Object, ByVal e As EventArgs)

        Dim gv As Gridview
        Dim gvrow As GridViewRow
        Dim id As Integer
        Dim dtShipDate As Date
        Dim strCarrier As String

        gv = DirectCast(sender, GridView)

        gvrow = gv.SelectedRow
        id = CInt(gvrow.Cells(1).Text)
        strCarrier = gvrow.Cells(2).Text

        Trace.Warn("you selected " & gvrow.Cells(0).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(1).Text & "")
        Trace.Warn("you selected " & gvrow.Cells(2).Text & "")
        Trace.Warn("OrderID - " & Request.QueryString("orderid") & "")

        'Dim conn As New DBConnect()
        'Dim strSQL As String

        'strSQL = "AFS_Carriers_Insert"
        strSQL = "Target_Carriers_Insert"

        Dim cmd As New SqlCommand(strSQL, conn.Connection)
        cmd.CommandType = CommandType.StoredProcedure

        cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
        cmd.Parameters.AddWithValue("@CarrierID", id)
        cmd.Parameters.AddWithValue("@CarrierName", strCarrier)
        cmd.Parameters.AddWithValue("@Distance", 0)
        cmd.Parameters.AddWithValue("@AccessorialCosts", 0)
        cmd.Parameters.AddWithValue("@EstimateCost", 0)
        cmd.Parameters.AddWithValue("@FreightCost", 0)
        cmd.Parameters.AddWithValue("@FuelSurcharge", 0)
        cmd.Parameters.AddWithValue("@ServiceDays", DBNull.Value)
        cmd.Parameters.AddWithValue("@ServiceType", DBNull.Value)
        cmd.Parameters.AddWithValue("@ShipmentDate", DBNull.Value)
        cmd.Parameters.AddWithValue("@ShipmentMethod", DBNull.Value)
        cmd.Parameters.AddWithValue("@TrueCost", 0)
        cmd.Parameters.AddWithValue("@CarrierChoice", 0)
        cmd.Parameters.AddWithValue("@CarrierPhone", DBNull.Value)
        cmd.Parameters.AddWithValue("@DeliveryDate", DBNull.Value)
        cmd.Parameters.AddWithValue("@QueryID", 0)

        cmd.CommandText = strSQL
        cmd.ExecuteNonQuery()

        tCarrierChoice.value = id.ToString

        bSubmitRate.enabled = True

        cmd.dispose()
        'conn.dispose()

        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "AlertMessageBox", "alert('" + strCarrier + " - has been selected');", True)
        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "Refresh", "window.opener.parent.frames[2].location.reload();", True)
        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "OptionSet", strWhse.ToString, True)
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "OptionSet", strWhse.ToString)
        'Page.ClientScript.RegisterStartupScript(Me.GetType(), "OptionSet", "window.location.href='" + strUrl.ToString + "';", True)
        'Page.ClientScript.RegisterClientScriptBlock(Me.GetType(), "close", "window.close();", True)

    End Sub


    Protected Sub GetManualQuote(ByVal sender As Object, ByVal e As EventArgs)

        Dim strUrl As String
        Dim ddlValue As Integer
        Dim ddlText As String

        'strUrl = Request.Url.ToString()
        'strUrl = strUrl.Replace("apps.net/shipping/AFSRates.aspx", "apps/order/reserve_afs.asp")

        lMessage.Text = [String].Empty
        lStackTrace.Text = [String].Empty
        pResults.Controls.Clear()

        If approvedCarriers.Checked = True Then
            ddlValue = CType(ddlCarrier.SelectedValue, Integer)
            ddlText = ddlCarrier.SelectedItem.Text
        End If

        If alternateCarriers.Checked = True Then
            ddlValue = CType(ddlAltCarrier.SelectedValue, Integer)
            ddlText = ddlAltCarrier.SelectedItem.Text
        End If

        Try
            'Dim conn As New DBConnect()
            'Dim strSQL As String

            'strSQL = "AFS_Carriers_Insert"
            strSQL = "Target_Carriers_Insert"

            Dim cmd As New SqlCommand(strSQL, conn.Connection)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
            cmd.Parameters.AddWithValue("@CarrierID", ddlValue)
            cmd.Parameters.AddWithValue("@CarrierName", ddlText)
            cmd.Parameters.AddWithValue("@Distance", 0)
            cmd.Parameters.AddWithValue("@AccessorialCosts", 0)
            cmd.Parameters.AddWithValue("@EstimateCost", tEstimateCost.Text)
            cmd.Parameters.AddWithValue("@FreightCost", 0)
            cmd.Parameters.AddWithValue("@FuelSurcharge", 0)
            cmd.Parameters.AddWithValue("@ServiceDays", DBNull.Value)
            cmd.Parameters.AddWithValue("@ServiceType", DBNull.Value)
            cmd.Parameters.AddWithValue("@ShipmentDate", Convert.ToDateTime(tShipDateAdv.Text))
            cmd.Parameters.AddWithValue("@ShipmentMethod", DBNull.Value)
            cmd.Parameters.AddWithValue("@TrueCost", tEstimateCost.Text)
            cmd.Parameters.AddWithValue("@CarrierChoice", True)
            cmd.Parameters.AddWithValue("@CarrierPhone", tPhone.Text)
            cmd.Parameters.AddWithValue("@DeliveryDate", DBNull.Value)

            cmd.CommandText = strSQL
            cmd.ExecuteNonQuery()

            cmd.dispose()
            'conn.dispose()

            lMessage.Text = [String].Empty
            lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException
            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "SubmitManual", "window.location.href='" + strReturnUrl + "';", True)

    End Sub

    Protected Sub GetCarriers(ByVal sender As Object, ByVal e As EventArgs)

        Trace.Warn("In GetCarriers")

        Try
            Dim carrierListResponse As String = [String].Empty

            carrierListResponse = carrierService_v2.GetCarrierList(tClient.Value.ToString, tUserNameAdv.Value.ToString, tPasswordAdv.Value.ToString)

            If [String].IsNullOrEmpty(carrierListResponse) Then
                lMessage.Text = "Nothing was returned in the response!!!"
                lStackTrace.Text = [String].Empty
                pResults.Controls.Clear()
                Return
            End If

            Dim ds As New System.Data.DataSet()
            ds.ReadXml(New System.IO.MemoryStream(System.Text.ASCIIEncoding.[Default].GetBytes(carrierListResponse)))

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

                Dim li As ListItem = New Listitem

                li.Value = dt.rows(0)("CarrierID").ToString
                li.Text = dt.rows(0)("CarrierName").ToString

                ddlCarrier.items.Add(li)

            Next

            lMessage.Text = [String].Empty
            lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException
            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try

    End Sub

    Protected Sub GetForm(ByVal sender As Object, ByVal e As EventArgs)

        Trace.Warn("In GetForm")

        lMessage.Text = [String].Empty
        lStackTrace.Text = [String].Empty
        pResults.Controls.Clear()

        Dim lkbn As LinkButton

        lkbn = DirectCast(sender, LinkButton)

        Select Case lkbn.ID

            Case "lb_CarrierForm"
                ltlA.visible = False
                ltlB.visible = True

            Case "lb_RateForm"
                ltlA.visible = True
                ltlB.visible = False

        End Select

    End Sub


    Protected Sub SubmitChoice(ByVal sender As Object, ByVal e As EventArgs)

        'Dim conn As New DBConnect()
        'Dim strSQL As String
        Dim btn As Button
        Dim strUrl As String
        Dim id As String

        btn = DirectCast(sender, Button)
        'id = CType(tCarrierChoice.value, Integer)

        id = CType(tCarrierChoice.Value, String)

        Dim cmd As New SqlCommand(strSQL, conn.Connection)

        Select Case btn.ID

            Case "bSubmitRate"

                'strSQL = "AFS_Carriers_Update"
                strSQL = "Target_Carriers_Update"

                cmd.CommandType = CommandType.StoredProcedure
                cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
                cmd.Parameters.AddWithValue("@CarrierID", id)
                cmd.CommandText = strSQL
                cmd.ExecuteNonQuery()


                strSQL = "DELETE FROM OrderCarrier WHERE OrderID = @OrderID AND DeliveryDate > @DeliveryDate AND CarrierChoice = 0 "
                cmd.Parameters.Clear()
                cmd.CommandType = CommandType.Text
                cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
                'cmd.Parameters.AddWithValue("@CarrierID", intCarrierCantDeliverSelected)
                cmd.Parameters.AddWithValue("@DeliveryDate", CType(lDeliveryDate.Text, Date))
                cmd.CommandText = strSQL
                cmd.ExecuteNonQuery()


            Case "bCancelRate"

                strSQL = "DELETE FROM OrderCarrier WHERE OrderID = @orderID"

                cmd.CommandType = CommandType.Text
                cmd.Parameters.AddWithValue("@OrderID", CType(Request.QueryString("orderid"), Integer))
                'cmd.Parameters.AddWithValue("@CarrierID", id)
                cmd.CommandText = strSQL
                cmd.ExecuteNonQuery()

        End Select

        cmd.dispose()
        'conn.dispose()

        Page.ClientScript.RegisterStartupScript(Me.GetType(), "SubmitChoice", "window.location.href='" + strReturnUrl + "';", True)

    End Sub


    Private Function ConvertHtmlToPlainText(ByVal htmlText As String) As String

        Return Regex.Replace(htmlText, "<[^>]*>", String.Empty)

    End Function


    Protected Sub Carrier_CheckedChanged(ByVal sender As Object, ByVal e As EventArgs)

        Dim rdbn As RadioButton
        rdbn = DirectCast(sender, RadioButton)

        Select Case rdbn.ID

            Case "alternateCarriers"
                apvCarrier.visible = False
                altCarrier.visible = True

            Case "approvedCarriers"
                apvCarrier.visible = True
                altCarrier.visible = False
                ddlAltCarrier.items.clear()
                altCarrierResults.visible = False
                bAltCarrierList.Text = "Search for Carriers"
                tCarrierSearch.enabled = True
                tCarrierSearch.text = ""

        End Select

    End Sub


    Protected Sub GetAlternateCarriers(ByVal sender As Object, ByVal e As EventArgs)

        Try
            Dim carrierListResponse As String = [String].Empty
            Dim i As Integer = 0

            Trace.Warn("ClientID - " & tClient.Value.ToString & "")
            Trace.Warn("Search - " & tCarrierSearch.Text.Trim() & "")
            Trace.Warn("User - " & tUserNameAdv.Value.ToString & "")
            Trace.Warn("Pwd - " & tPasswordAdv.Value.ToString & "")

            carrierListResponse = carrierService_v2.GetCarriers(tCarrierSearch.Text.Trim(), tUserNameAdv.Value.ToString, tPasswordAdv.Value.ToString)

            trace.warn(carrierListResponse)

            If [String].IsNullOrEmpty(carrierListResponse) Then
                lMessage.Text = "Nothing was returned in the response!!!"
                lStackTrace.Text = [String].Empty
                pResults.Controls.Clear()
                Return
            End If

            Dim ds As New System.Data.DataSet()
            ds.ReadXml(New System.IO.MemoryStream(System.Text.ASCIIEncoding.[Default].GetBytes(carrierListResponse)))

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

                Dim li As ListItem = New Listitem

                li.Value = dt.rows(0)("CarrierID").ToString
                li.Text = dt.rows(0)("CarrierName").ToString
                i = i + 1

                ddlAltCarrier.items.Add(li)
                altCarrierResults.visible = True
                cntCarriers.Text = i.ToString
                altCarrier.visible = False

            Next

            lMessage.Text = [String].Empty
            lStackTrace.Text = [String].Empty
        Catch soapEx As System.Web.Services.Protocols.SoapException
            lMessage.Text = soapEx.Detail.ChildNodes(0).InnerText
            lStackTrace.Text = soapEx.Detail.ChildNodes(0).Attributes(0).Value
            pResults.Controls.Clear()
        Catch ex As Exception
            lMessage.Text = ex.Message
            lStackTrace.Text = ex.StackTrace
            pResults.Controls.Clear()
        End Try

    End Sub


    Protected Sub Clear_CarrierSearch(ByVal sender As Object, ByVal e As EventArgs)

        altCarrier.visible = True
        ddlAltCarrier.items.clear()
        altCarrierResults.visible = False
        tCarrierSearch.text = ""

    End Sub


End Class