Imports AjaxControlToolkit
Partial Class Shipping_EditFreightCharge
    Inherits System.Web.UI.Page
    Private m_FreightChargeID As Integer
    Private m_PageMode As Refron_Global.PageMode
    Private m_conn As DBConnect
    Private p_ConvertedShipDateSQL As New Text.StringBuilder
    Private m_GrossWeight As Integer
    '    Private m_OrderNumbers As New Collections.ArrayList()

  
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        'Trace.Warn("begin function", "PageLoad")
        Master.Title = "Add/Edit Freight Charges"
        Master.TitleBar = "Add/Edit Freight Charges"



        'todo---  

        p_ConvertedShipDateSQL.Append("CASE ")
        p_ConvertedShipDateSQL.Append("WHEN LEN(OHSHDT) = 6 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(6)), 5, 2) AS DATETIME) ")
        p_ConvertedShipDateSQL.Append("WHEN LEN(OHSHDT) = 5 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(5)), 4, 2) AS DATETIME) ")
        p_ConvertedShipDateSQL.Append("WHEN LEN(OHSHDT) = 4 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(4)), 3, 2) AS DATETIME) ")
        p_ConvertedShipDateSQL.Append("WHEN LEN(OHSHDT) = 3 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(3)), 2, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(3)), 3, 1) AS DATETIME) ")
        p_ConvertedShipDateSQL.Append("ELSE NULL ")
        p_ConvertedShipDateSQL.Append("END")

        'Trace.Warn("Before DBConnect")
        m_conn = New DBConnect()



        _TxtFreightChargeAmount.Attributes.Add("onChange", "calculateCzarLite()")
        _TxtVendorCode.Attributes.Add("onBlur", "checkVendor()")
        _SdsOrders.SelectCommand = _
            "SELECT " & _
                "OHORNU AS OrderNumber, " & _
                p_ConvertedShipDateSQL.ToString & " as ShipDate, " & _
                "OHBL# as BLNumber, " & _
                "OHSAD1 as CustomerName, " & _
                "OHSCTY + ', ' + OHSSTE + ' ' + OHSZIP  as CustomerAddress, " & _
                "Case When ItemTotal < 0 Then 'In' Else 'Out' end as InOut, " & _
                "LineItemCount, " & _
                "TotalGrossWeight, " & _
                "OHWHS + '(' +  Cast(wmvndr as varchar(7)) + ')/' + Cast(WMZIP as varchar(5)) as FromWhsZip, " & _
                "Cast(WMZIP as varchar(5)) as FromZip, " & _
                "OHSZIP as toZip, " & _
                "OHWHS as FromWhs, " & _
                "VNVNNM as VendorName, " & _
                "wmvndr as VendorCode " & _
            "From ordrhdr " & _
                "Left Join " & _
                    "(Select " & _
                        "ODORNU as OrderNumber, " & _
                        "SUM(ODQTOR) as ItemTotal, " & _
                        "Count(ODORNU) as LineItemCount, " & _
                        "Sum((ITGRWT * ODQTOR)) as TotalGrossWeight " & _
                    "From ordrdtl " & _
                        "Left Join itemmst on oditem = ititem " & _
                    "Group By ODORNU) " & _
                    "as GrossWeightTable on ordrhdr.ohornu = GrossWeightTable.Ordernumber " & _
                "Left Join WHSEMST on ORDRHDR.OHWHS = WHSEMST.WMWHS " & _
                "Left Join APVNDR on WHSEMST.WMVNDR = APVNDR.VNVNNU " & _
            "Where OHFCID = @FreightChargeID"
        'Trace.Warn("Orders SQL", _SdsOrders.SelectCommand)
        _SdsVerifyOrderLink.SelectCommand = _
            "Select " & _
                "OHORNU, " & _
                "OHSTAT, " & _
                "OHBL# as BillOfLadingNumber, " & _
                "OHWHS as WarehouseCode, " & _
                "OHSTAT as Status, " & _
                "OHFCID as FreightChargeID, " & _
                "Case When ItemTotal < 0 Then 'I' Else 'O' end as InOut, " & _
                p_ConvertedShipDateSQL.ToString & " AS ShipDate " & _
            "From ordrhdr " & _
                "Left Join (" & _
                    "Select " & _
                        "ODORNU as OrderNumber, " & _
                        "SUM(ODQTOR) as ItemTotal  " & _
                    "From ordrdtl " & _
                    "WHERE ODORNU >= @OrderNumberMin AND ODORNU < @OrdernumberMax " & _
                    "Group By ODORNU ) as details on ordrhdr.ohornu = details.OrderNumber " & _
            "where OHORNU >= @OrderNumberMin2 AND OHORNU < @OrdernumberMax2 " & _
            "ORDER By " & p_ConvertedShipDateSQL.ToString & " Desc"



        

        '    p_ConvertedShipDateSQL.ToString & " AS ShipDate " & _
        '"From ordrhdr " & _
        '    "Left Join (" & _
        '        "Select " & _
        '            "ODORNU as OrderNumber, " & _
        '            "SUM(ODQTOR) as ItemTotal  " & _
        '        "From ordrdtl " & _
        '        "Group By ODORNU) as details on ordrhdr.ohornu = details.OrderNumber " & _
        '    "LEFT JOIN testORDRHDR on TestORDRHDR.TestORDRHDRID = ORDRHDR.OHORNU " & _
        '"where OHORNU like @OrderNumber + '%'" & _
        '"ORDER By " & p_ConvertedShipDateSQL.ToString & " Desc"
        'Trace.Warn("VerifySQL", _SdsVerifyOrderLink.SelectCommand)
        _SdsCompareShipments.SelectCommand = _
                               "select top 10 " & _
                                   "FreightChargeID, " & _
                                   "WarehouseCode, " & _
                                   "ShipDate, " & _
                                   "OHSAD1 as CustomerName, " & _
                                   "OHSCTY + ', ' + OHSSTE + ' ' + OHSZIP  as CustomerAddress, " & _
                                   "miles, GrossWeight, " & _
                                   "FreightChargeAmount, " & _
                                   "VNVNNM as VendorName " & _
                               "From FreightCharges " & _
                                   "Left Join ORDRHDR on cast(ORDRHDR.OHFCID as integer) = FreightCharges.FreightChargeID " & _
                                   "LEFT Join APVNDR on FreightCharges.Vendorcode = cast(APVNDR.VNVNNU as integer) " & _
                               "where (FreightChargeAmount > 0 OR FreightChargeID = @FreightChargeID) " & _
                                   "AND ToZip = @toZip " & _
                                   "and ShipDate >= @2yrsAgo " & _
                               "order by abs(@GrossWeight - GrossWeight) Asc, " & _
                                   "ShipDate Desc"

        If Page.IsPostBack Then

            m_PageMode = CType(ViewState("PageMode"), Refron_Global.PageMode)
            m_FreightChargeID = CType(ViewState("FreightChargeID"), Integer)
            _LblUpdated.Text = ""
        Else
            _RV_TxtProDate.MaximumValue = DateTime.Now().ToShortDateString
            _RV_TxtProDate.MinimumValue = DateTime.Now().AddYears(-1).ToShortDateString

            _SdsVerifyOrderLink.SelectParameters.Add("OrderNumberMin", TypeCode.Int32, "0")
            _SdsVerifyOrderLink.SelectParameters.Add("OrderNumberMax", TypeCode.Int32, "0")
            _SdsVerifyOrderLink.SelectParameters.Add("OrderNumberMin2", TypeCode.Int32, "0")
            _SdsVerifyOrderLink.SelectParameters.Add("OrderNumberMax2", TypeCode.Int32, "0")

            'Trace.Warn("xxcx", _SdsCompareShipments.SelectCommand)
            Dim li As New ListItem(" ", "")
            _DdlAdditionalChargeReason.DataBind()
            _DdlAdditionalChargeReason.Items.Insert(0, li)

            Dim li2 As New ListItem(" ", "")
            _DdlPaymentCode.DataBind()
            _DdlPaymentCode.Items.Insert(0, li2)
            _DdlPaymentCode.Items.FindByText("Paid").Enabled = False


            If Request.QueryString("fid") IsNot Nothing Then
                If Request.QueryString("fid").ToString = "0" Then
                    m_PageMode = Refron_Global.PageMode.AddNew
                    m_FreightChargeID = 0
                Else
                    m_PageMode = Refron_Global.PageMode.Edit
                    m_FreightChargeID = CType(Request.QueryString("fid"), Integer)
                End If
            Else
                m_FreightChargeID = 0
                m_PageMode = Refron_Global.PageMode.AddNew
            End If
            ViewState("PageMode") = m_PageMode
            ViewState("FreightChargeID") = m_FreightChargeID
            'Trace.Warn("Before FillForm")

            FillFreightChargeForm(m_PageMode)
            'Trace.Warn("After FillForm")
            _LnkUseWhsCode.Attributes.Add("onclick", "javascript:document.all." & _
                _LblVendorName.ClientID & _
                ".innerText = document.all." & _
                _HdnVendorName.ClientID & _
                ".value;" & _
                "document.all." & _
                _TxtVendorCode.ClientID & _
                ".value = document.all." & _
                _HdnVendorCode.ClientID & _
                ".value;")
            'Trace.Warn("Before Bind_RptVendorQuickLookup")
            Bind_RptVendorQuickLookup()
            'Trace.Warn("After Bind_RptVendorQuickLookup")
            _SdsCompareShipments.SelectParameters.Add("2yrsAgo", TypeCode.DateTime, DateTime.Now.AddYears(-2).ToShortDateString)
            _SdsCompareShipments.SelectParameters.Add("FreightChargeID", TypeCode.Int32, m_FreightChargeID.ToString)


        End If

        'Trace.Warn(_SdsOrders.SelectCommand & "xxx")

    End Sub
    

    Public Sub _TxtVendorCode_onChange(ByVal sender As Object, ByVal e As EventArgs) Handles _TxtVendorCode.TextChanged
        'Trace.Warn("begin function", "_TxtVendorCode_OnChange")
        Dim strSQL As String
        strSQL = "Select rtrim(cast(VNVNNM as varchar(10))) + ' - ' + cast(vnornu as varchar(10)) as vnmnm from APVNDR where VNVNNU = @VendorCode AND VNORNU > 0"
        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
        cmd.Parameters.Add("@VendorCode", SqlDbType.Decimal, 7)
        If IsNumeric(_TxtVendorCode.Text) Then

            cmd.Parameters("@VendorCode").Value = CType(_TxtVendorCode.Text, Double)
        Else
            cmd.Parameters("@VendorCode").Value = 0
        End If

        Dim strVendorName As String
        Try
            strVendorName = cmd.ExecuteScalar.ToString

        Catch ex As NullReferenceException
            strVendorName = String.Empty
        End Try
        cmd.Dispose()

        _LblVendorName.Text = strVendorName

    End Sub

    Public Sub _TxtFromWarehouse_TextChanged(ByVal sender As Object, ByVal e As EventArgs) Handles _TxtFromWarehouse.TextChanged
        'Trace.Warn("begin function", "_TxtFRromWarehouse_TextChanged")
        Dim strSQL As String
        strSQL = "Select wmvndr, rtrim(cast(VNVNNM as varchar(10))) + ' - ' + cast(vnornu as varchar(10)) from WHSEMST Left Join APVNDR on wmvndr = VNVNNU  where WMWHS = @WarehouseCode"
        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
        cmd.Parameters.Add("@WarehouseCode", SqlDbType.Char, 3)
        cmd.Parameters("@WarehouseCode").Value = _TxtFromWarehouse.Text
        '        strSQL = "Select VNVNNM from APVNDR where VNVNNU = @VendorCode"


        Dim dr As SqlDataReader
        dr = cmd.ExecuteReader
        Dim WarehouseExists As Boolean

        While dr.Read
            WarehouseExists = True
            _HdnVendorCode.Value = dr(0).ToString
            _HdnVendorName.Value = dr(1).ToString
        End While
        dr.Close()

        cmd.Dispose()
        If Not WarehouseExists Then
            _HdnVendorCode.Value = String.Empty
            _HdnVendorName.Value = String.Empty
        End If
        Bind_RptVendorQuickLookup()


    End Sub

    Private Sub CalculateCzarLite()
        'Trace.Warn("begin function", "CalculateCzarlite")
        If Trim(_TxtFromZip.Text) > "" And Trim(_TxtToZip.Text) > "" And Trim(_TxtGrossWeight.Text) > "" Then
            If IsNumeric(_TxtGrossWeight.Text) Then
                If CDbl(_TxtGrossWeight.Text) > 0 Then
                    Try
                        Dim clc As New Refron_Global.CzarLiteCalulator(_TxtFromZip.Text, _TxtToZip.Text, _TxtGrossWeight.Text)
                        _LblCzarLiteAmount.Text = String.Format("{0:c}", clc.CzarliteAmount)
                        _HdnCzarLiteAmount.Value = clc.CzarliteAmount.ToString
                        If IsNumeric(_TxtFreightChargeAmount.Text) And IsNumeric(_LblCzarLiteAmount.Text) Then

                            _LblCzarLitePercent.Text = String.Format("{0:p}", (CType(_TxtFreightChargeAmount.Text, Double) / CType(_LblCzarLiteAmount.Text, Double)) - 1)
                        Else
                            _LblCzarLitePercent.Text = ""
                        End If

                        '_LblCzarLiteMinimumCharge.Text = String.Format("{0:p}", (CType(_TxtFreightChargeAmount.Text, Double) / CType(_LblCzarLite.Text, Double)) - 1)
                        '_lbl()
                        If clc.IsCzarLiteMinimumCharge Then
                            _LblCzarLiteMinimumCharge.Text = "Y"
                        Else
                            _LblCzarLiteMinimumCharge.Text = ""
                        End If

                    Catch ex As Exception
                        _LblCzarLiteAmount.Text = ""
                        _HdnCzarLiteAmount.Value = ""
                        _LblCzarLitePercent.Text = ""
                        _LblCzarLiteMinimumCharge.Text = ""


                    End Try

                Else
                    _LblCzarLiteAmount.Text = ""
                    _HdnCzarLiteAmount.Value = ""
                    _LblCzarLitePercent.Text = ""
                    _LblCzarLiteMinimumCharge.Text = ""

                End If
            Else
                _LblCzarLiteAmount.Text = ""
                _HdnCzarLiteAmount.Value = ""
                _LblCzarLitePercent.Text = ""
                _LblCzarLiteMinimumCharge.Text = ""

            End If
        Else
            _LblCzarLiteAmount.Text = ""
            _HdnCzarLiteAmount.Value = ""
            _LblCzarLitePercent.Text = ""
            _LblCzarLiteMinimumCharge.Text = ""

        End If
        'Trace.Warn("CalculateCzarlite End")


    End Sub

    Private Sub FillFreightChargeForm(ByVal pageMode As Refron_Global.PageMode)

        'Trace.Warn("begin function", "FillFreightChargeFormstart")
        If pageMode = Refron_Global.PageMode.AddNew Then
            _PnlLinkedOrders.Visible = False
            'Fill with Defaults for new freight charge
        ElseIf pageMode = Refron_Global.PageMode.Edit Then

            Dim strSQL As String

            _HdnFreightChargeId.Value = m_FreightChargeID.ToString

            strSQL = "Select AdditionalCharge, " & _
                        "OrderNumber1, " & _
                        "OrderNumber2, " & _
                        "OrderNumber3, " & _
                        "AdditionalChargeReason, " & _
                        "ShipDate, " & _
                        "BillOfLadingNumber, " & _
                        "WarehouseCode, " & _
                        "BatchNumber, " & _
                        "Comments, " & _
                        "FreightChargeAmount, " & _
                        "FreightChargeID, " & _
                        "PaymentCode, " & _
                        "ProDate, " & _
                        "ProNumber, " & _
                        "RefronMinimumCharge, " & _
                        "VNVNNM as VendorName, " & _
                        "VNORNU, " & _
                        "VendorCode, " & _
                        "VoucherNumber, " & _
                        "InboundOutbound, " & _
                        "Miles, " & _
                        "FromZip, " & _
                        "ToZip, " & _
                        "GrossWeight " & _
                        "from FreightCharges " & _
                        "Left join APVNDR on FreightCharges.Vendorcode = cast(APVNDR.VNVNNU as integer) Where FreightChargeID = @FreightChargeID"

            Dim dt As New DataTable
            Dim da As New SqlDataAdapter(strSQL, m_conn.Connection)

            da.SelectCommand.Parameters.Add("@FreightChargeID", SqlDbType.Int, 4)
            da.SelectCommand.Parameters("@FreightChargeID").Value = m_FreightChargeID
            da.Fill(dt)
            'Trace.Warn("FillFreightChargeForm After da.fill")
            'Trace.Warn(strSQL)
            Dim dr As DataRow
            dr = dt.Rows(0)
            _TxtBLNumber.Text = dr("BillOfLadingNumber").ToString
            If IsDate(dr("ShipDate").ToString) Then
                _TxtShipDate.Text = String.Format("{0:M/dd/yy}", CDate(dr("ShipDate").ToString))
            Else
                _TxtShipDate.Text = String.Empty
            End If
            _TxtMiles.Text = dr("Miles").ToString
            _TxtFromWarehouse.Text = dr("WarehouseCode").ToString
            'Trace.Warn("whs", "fillFreightChargeForm")
            _TxtFromZip.Text = dr("FromZip").ToString
            _TxtToZip.Text = dr("ToZip").ToString
            'Trace.Warn("to zip set by db")
            _TxtGrossWeight.Text = dr("GrossWeight").ToString

            _HdnVendorName.Value = dr("VendorName").ToString & " - " & dr("VNORNU").ToString
            _HdnVendorCode.Value = dr("VendorCode").ToString
            _TxtVendorCode.Text = dr("VendorCode").ToString
            _HdnOriginalVendorCode.Value = dr("VendorCode").ToString

            If IsDBNull(dr("VendorName")) Then
                _LblVendorName.Text = String.Empty
            Else
                _LblVendorName.Text = dr("VendorName").ToString & " - " & dr("VNORNU").ToString
            End If

            _DdlInboundOutbound.SelectedValue = dr("InboundOutbound").ToString
            _TxtProNumber.Text = dr("ProNumber").ToString
            If IsDBNull(dr("ProDate")) Then
                _TxtProDate.Text = ""
            Else
                _TxtProDate.Text = String.Format("{0:M/dd/yy}", CType(dr("ProDate"), Date))
            End If
            If Not IsDBNull(dr("FreightChargeAmount")) Then

                If CType(dr("FreightChargeAmount"), Decimal) > 0 Then
                    _TxtFreightChargeAmount.Text = CType(dr("FreightChargeAmount"), Decimal).ToString("F")
                Else
                    _TxtFreightChargeAmount.Text = ""
                End If

            End If
            If Not IsDBNull(dr("RefronMinimumCharge")) Then
                If CType(dr("RefronMinimumCharge"), Boolean) Then
                    _ChkMinimumCharge.Checked = True
                End If
            End If
            If Not IsDBNull(dr("AdditionalCharge")) Then
                If CType(dr("AdditionalCharge"), Decimal) > 0 Then
                    _TxtAdditionalCharge.Text = CType(dr("AdditionalCharge"), Decimal).ToString("F")
                Else
                    _TxtAdditionalCharge.Text = ""
                End If
            End If
            If IsDBNull(dr("AdditionalChargeREason")) Then
                _DdlAdditionalChargeReason.SelectedIndex = 0
            Else
                _DdlAdditionalChargeReason.SelectedValue = CType(dr("AdditionalChargeReason"), Integer).ToString
            End If
            'Trace.Warn("add charge reason", dr("AdditionalChargeReason").ToString)
            If IsDBNull(dr("PaymentCode")) Then
                _DdlPaymentCode.SelectedIndex = 0
            Else
                _DdlPaymentCode.SelectedValue = CType(dr("PaymentCode"), Integer).ToString
            End If
            If _DdlPaymentCode.SelectedItem.Text = "Paid" Then
                
                Dim PaymentItem As ListItem
                For Each PaymentItem In _DdlPaymentCode.Items
                    If PaymentItem.Text = "Paid" Then
                        PaymentItem.Enabled = True
                    Else
                        PaymentItem.Enabled = False
                    End If
                Next
            Else

            End If

            _LblBatchNumber.Text = dr("BatchNumber").ToString
            _LblVoucherNumber.Text = dr("VoucherNumber").ToString

            _TxtComments.Text = dr("Comments").ToString

            dt.Dispose()
            da.Dispose()

        Else
            Throw New InvalidOperationException("Unable to determine Page Add/Edit Mode")
        End If
    End Sub
    Private m_OrdersExist As Boolean
    Protected Sub _GVOrders_RowCreated(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles _GVOrders.RowCreated

        'Trace.Warn("begin function", "GVorders_RowCreated" & e.Row.RowType.ToString)
        If e.Row.RowType = DataControlRowType.DataRow Then

            If e.Row.DataItemIndex = 0 And e.Row.DataItem IsNot Nothing Then
                m_OrdersExist = True
                m_GrossWeight = 0
                _HdnVendorName.Value = DataBinder.Eval(e.Row.DataItem, "VendorName").ToString
                If IsNumeric(DataBinder.Eval(e.Row.DataItem, "VendorCode").ToString) Then
                    _HdnVendorCode.Value = CType(DataBinder.Eval(e.Row.DataItem, "VendorCode"), Double).ToString
                Else
                    _HdnVendorCode.Value = ""
                End If

                _TxtFromZip.Text = DataBinder.Eval(e.Row.DataItem, "FromZip").ToString
                _TxtToZip.Text = DataBinder.Eval(e.Row.DataItem, "ToZip").ToString
                'Trace.Warn("to zip set by gvorders onrowcreated")
                _TxtFromWarehouse.Text = DataBinder.Eval(e.Row.DataItem, "FromWhs").ToString
                'Trace.Warn("whs", "gvorders_RowCreated")
                _TxtBLNumber.Text = DataBinder.Eval(e.Row.DataItem, "BLNumber").ToString
                If IsDBNull(DataBinder.Eval(e.Row.DataItem, "ShipDate")) Then
                    _TxtShipDate.Text = String.Empty
                Else
                    _TxtShipDate.Text = String.Format("{0:M/dd/yy}", CType(DataBinder.Eval(e.Row.DataItem, "ShipDate"), Date))
                End If
                _TxtFromZip.Enabled = False
                _TxtToZip.Enabled = False
                _TxtFromWarehouse.Enabled = False
                _TxtBLNumber.Enabled = False
                _TxtShipDate.Enabled = False
                _BtnUpdateManualEntry.Visible = False
                If CType(DataBinder.Eval(e.Row.DataItem, "InOut"), String) = "Out" Then
                    _DdlInboundOutbound.SelectedValue = "O"
                Else
                    _DdlInboundOutbound.SelectedValue = "I"
                End If
                _DdlInboundOutbound.Enabled = False
            End If
            m_GrossWeight += CType(DataBinder.Eval(e.Row.DataItem, "TotalGrossWeight"), Integer)
        End If
    End Sub
    Protected Sub _GVOrders_Databound(ByVal sender As Object, ByVal e As EventArgs) Handles _GVOrders.DataBound
        'Trace.Warn("begin function", "GVOrdersDatabound")
        If m_OrdersExist Then
            _TxtGrossWeight.Text = m_GrossWeight.ToString
            _TxtGrossWeight.Enabled = False
        Else
            _TxtFromZip.Enabled = True
            _TxtToZip.Enabled = True
            _TxtFromWarehouse.Enabled = True
            _TxtBLNumber.Enabled = True
            _TxtShipDate.Enabled = True
            _BtnUpdateManualEntry.Visible = True
            _TxtGrossWeight.Enabled = True
            _DdlInboundOutbound.Enabled = True
        End If
        CalculateCzarLite()
        'Trace.Warn("calculate CzarLite in gvorders_databound")
    End Sub


    Private Sub SaveFreightCharge()
        'Trace.Warn("begin function", "SaveFreightCharge")
        Dim strSQl As String

        If Page.IsValid Then
            If m_PageMode = Refron_Global.PageMode.AddNew Then
                strSQl = "Insert into FreightCharges (" & _
                               "OrderNumber1, " & _
                               "OrderNumber2, " & _
                               "OrderNumber3, " & _
                               "OldShpMstID, " & _
                               "WarehouseCode, " & _
                               "BillOfLadingNumber, " & _
                               "ShipDate, " & _
                               "InboundOutbound, " & _
                               "Miles, " & _
                               "GrossWeight, " & _
                               "CzarliteAmount, " & _
                               "CzarLiteMinimumCharge, " & _
                               "CzarLitePercent, " & _
                               "ProNumber, " & _
                               "ProDate, " & _
                               "FreightChargeAmount, " & _
                               "AdditionalCharge, " & _
                               "AdditionalChargeReason, " & _
                               "VendorCode, " & _
                               "Comments, " & _
                               "RefronMinimumCharge, " & _
                               "PaymentCode, " & _
                               "FromZip, " & _
                               "ToZip, " & _
                               "Tempconverted)" & _
                               " Values (" & _
                               "NULL, " & _
                               "0, " & _
                               "0, " & _
                               "0, " & _
                               "@WarehouseCode, " & _
                               "@BLNumber, " & _
                               "@ShipDate, " & _
                               "@InboundOutbound, " & _
                               "@Miles, " & _
                               "@GrossWeight, " & _
                               "@CzarliteAmount, " & _
                               "@CzarLiteMinimumCharge, " & _
                               "@CzarLitePercent, " & _
                               "@ProNumber, " & _
                               "@ProDate, " & _
                               "@FreightChargeAmount, " & _
                               "@AdditionalCharge, " & _
                               "@AdditionalChargeReason, " & _
                               "@VendorCode, " & _
                               "@Comments, " & _
                               "@RefronMinimumCharge, " & _
                               "@PaymentCode, " & _
                               "@FromZip, " & _
                               "@ToZip, " & _
                               "1);Select Scope_Identity()"
            ElseIf m_PageMode = Refron_Global.PageMode.Edit Then
                strSQl = "Update FreightCharges set " & _
                                "AdditionalCharge = @AdditionalCharge, " & _
                                "AdditionalChargeReason = @AdditionalChargeReason, " & _
                                "Comments = @Comments, " & _
                                "FreightChargeAmount = @FreightChargeAmount, " & _
                                "PaymentCode = @PaymentCode, " & _
                                "ProDate = @ProDate, " & _
                                "ProNumber = @ProNumber, " & _
                                "RefronMinimumCharge = @RefronMinimumCharge, " & _
                                "VendorCode = @VendorCode, " & _
                                "BillOfLadingNumber = @BLNumber, " & _
                                "ShipDate = @ShipDate, " & _
                                "WarehouseCode = @WarehouseCode, " & _
                                "Miles= @Miles, " & _
                                "FromZip= @FromZip, " & _
                                "ToZip= @ToZip, " & _
                                "GrossWeight= @GrossWeight, " & _
                                "CzarliteAmount = @CzarLiteAmount, " & _
                                "CzarlitePercent = @CzarlitePercent, " & _
                                "CzarLiteMinimumCharge= @CzarLiteMinimumCharge, " & _
                                "InboundOutbound= @InboundOutbound " & _
                                "where  FreightChargeID = @FreightChargeID"
            Else
                Throw New InvalidOperationException("Unable to determine Page Add/Edit Mode")
            End If

            Dim cmd As New SqlCommand(strSQl, m_conn.Connection)

            'Set common parameters between add and update
            cmd.Parameters.Add("@WarehouseCode", SqlDbType.Char, 3)
            cmd.Parameters("@WarehouseCode").Value = _TxtFromWarehouse.Text

            cmd.Parameters.Add("@BLNumber", SqlDbType.VarChar, 10)
            cmd.Parameters("@BLNumber").Value = _TxtBLNumber.Text

            cmd.Parameters.Add("@ShipDate", SqlDbType.SmallDateTime, 4)
            If IsDate(_TxtShipDate.Text) Then
                cmd.Parameters("@ShipDate").Value = CDate(_TxtShipDate.Text)
            Else
                cmd.Parameters("@ShipDate").Value = DBNull.Value
            End If

            cmd.Parameters.Add("@InboundOutbound", SqlDbType.Char, 1)
            cmd.Parameters("@InboundOutbound").Value = _DdlInboundOutbound.SelectedValue

            cmd.Parameters.Add("@Miles", SqlDbType.Int, 4)
            If IsNumeric(_TxtMiles.Text) Then
                cmd.Parameters("@Miles").Value = CType(_TxtMiles.Text, Integer)
            Else
                cmd.Parameters("@Miles").Value = DBNull.Value
            End If

            cmd.Parameters.Add("@GrossWeight", SqlDbType.Int, 4)
            If IsNumeric(_TxtGrossWeight.Text) Then
                cmd.Parameters("@GrossWeight").Value = CInt(_TxtGrossWeight.Text)
            Else
                cmd.Parameters("@GrossWeight").Value = DBNull.Value
            End If
            cmd.Parameters.Add("@CzarliteAmount", SqlDbType.Money, 8)
            If IsNumeric(_LblCzarLiteAmount.Text) Then
                cmd.Parameters("@CzarliteAmount").Value = CDbl(_LblCzarLiteAmount.Text)
            Else
                cmd.Parameters("@CzarliteAmount").Value = DBNull.Value
                'cmd.Parameters.Add("@CzarliteAmount", SqlDbType.Money, 8)
                'cmd.Parameters("@CzarLiteAmount").Value = DBNull.Value
            End If

            cmd.Parameters.Add("@CzarLiteMinimumCharge", SqlDbType.Bit, 1)
            If _LblCzarLiteMinimumCharge.Text = "Y" Then
                cmd.Parameters("@CzarLiteMinimumCharge").Value = True
            Else
                cmd.Parameters("@CzarLiteMinimumCharge").Value = False
            End If


            cmd.Parameters.Add("@CzarLitePercent", SqlDbType.Float, 8)
            If IsNumeric(_LblCzarLitePercent.Text) Then
                cmd.Parameters("@CzarLitePercent").Value = CDbl(_LblCzarLitePercent.Text)
            Else
                cmd.Parameters("@CzarLitePercent").Value = DBNull.Value
            End If
            '2062803
            cmd.Parameters.Add("@ProNumber", SqlDbType.VarChar, 12)
            cmd.Parameters("@ProNumber").Value = _TxtProNumber.Text


            cmd.Parameters.Add("@ProDate", SqlDbType.SmallDateTime, 4)
            If IsDate(_TxtProDate.Text) Then
                cmd.Parameters("@ProDate").Value = _TxtProDate.Text
            Else
                Throw New InvalidOperationException("Pro Date is not a valid date")
            End If



            cmd.Parameters.Add("@FreightChargeAmount", SqlDbType.Money, 8)
            If IsNumeric(_TxtFreightChargeAmount.Text) Then
                cmd.Parameters("@FreightChargeAmount").Value = CDbl(_TxtFreightChargeAmount.Text)
            Else
                cmd.Parameters("@FreightChargeAmount").Value = 0
            End If

            cmd.Parameters.Add("@AdditionalCharge", SqlDbType.Money, 8)
            If IsNumeric(_TxtAdditionalCharge.Text) Then
                cmd.Parameters("@AdditionalCharge").Value = CDbl(_TxtAdditionalCharge.Text)
            Else
                cmd.Parameters("@AdditionalCharge").Value = 0
            End If


            cmd.Parameters.Add("@AdditionalChargeReason", SqlDbType.Int, 4)
            If _DdlAdditionalChargeReason.SelectedIndex = 0 Then
                cmd.Parameters("@AdditionalChargeReason").Value = DBNull.Value
            Else
                cmd.Parameters("@AdditionalChargeReason").Value = _DdlAdditionalChargeReason.SelectedValue
            End If

            cmd.Parameters.Add("@VendorCode", SqlDbType.Int, 4)
            If IsNumeric(_TxtVendorCode.Text) Then
                cmd.Parameters("@VendorCode").Value = CType(_TxtVendorCode.Text, Integer)
            Else
                cmd.Parameters("@VendorCode").Value = DBNull.Value
            End If

            cmd.Parameters.Add("@Comments", SqlDbType.VarChar, 500)
            cmd.Parameters("@Comments").Value = _TxtComments.Text

            cmd.Parameters.Add("@RefronMinimumCharge", SqlDbType.Bit, 1)
            cmd.Parameters("@RefronMinimumCharge").Value = _ChkMinimumCharge.Checked

            cmd.Parameters.Add("@PaymentCode", SqlDbType.Int, 4)
            If _DdlPaymentCode.SelectedIndex = 0 Then
                cmd.Parameters("@PaymentCode").Value = DBNull.Value
            Else
                cmd.Parameters("@PaymentCode").Value = CType(_DdlPaymentCode.SelectedValue, Integer)
            End If

            cmd.Parameters.Add("@FromZip", SqlDbType.VarChar, 10)
            cmd.Parameters("@FromZip").Value = _TxtFromZip.Text

            cmd.Parameters.Add("@ToZip", SqlDbType.VarChar, 10)
            cmd.Parameters("@ToZip").Value = _TxtToZip.Text





            If m_PageMode = Refron_Global.PageMode.AddNew Then



                m_FreightChargeID = CType(cmd.ExecuteScalar, Int32)
                m_PageMode = Refron_Global.PageMode.Edit
                ViewState("PageMode") = m_PageMode
                ViewState("FreightChargeID") = m_FreightChargeID
                _HdnFreightChargeId.Value = m_FreightChargeID.ToString

                _PnlLinkedOrders.Visible = True



            ElseIf m_PageMode = Refron_Global.PageMode.Edit Then

                cmd.Parameters.Add("@FreightChargeID", SqlDbType.Int, 4)
                cmd.Parameters("@FreightChargeID").Value = m_FreightChargeID




                cmd.ExecuteNonQuery()
                UpdateSalesAnalysis()
            End If
            cmd.Dispose()

        End If
    End Sub
    Private Sub UpdateSalesAnalysis()
        Dim GrossWeight As Integer
        Dim FreightChargeAmount As Decimal
        Dim PricePerLb As Decimal

        If IsNumeric(_TxtFreightChargeAmount.Text) And IsNumeric(_TxtGrossWeight.Text) Then
            FreightChargeAmount = CType(_TxtFreightChargeAmount.Text, Decimal)

            GrossWeight = CType(_TxtGrossWeight.Text, Integer)

            PricePerLb = FreightChargeAmount / Math.Abs(GrossWeight)
        End If
        If PricePerLb <> 0 Then

            Trace.Warn(String.Format("{0:f4}", PricePerLb))
            Dim strSQL As String
            'strSQL = "Update SAFile set SAFTLB = ROUND(@FreightPerLb1,4), " & _
            ' "SAFTIT =  " & _
            '     "CASE SAGRLB  " & _
            '      "WHEN 0 THEN CAST(0 AS MONEY)  " & _
            '      "ELSE  " & _
            '       "CAST( " & _
            '         "ROUND((@FreightPerLb2 * ABS(SAGRLB)), 2)  " & _
            '       "AS MONEY)  " & _
            '      "END, " & _
            ' "SAGMWF =  " & _
            '     "CASE  " & _
            '      "WHEN SATCST = 0 THEN CAST(0 AS MONEY)  " & _
            '      "ELSE CAST(ROUND(SATOT$ - SATCST - SATRM$ - ROUND((@FreightPerLb3 * ABS(SAGRLB)), 2), 2) AS MONEY) " & _
            '     "END,  " & _
            ' "SAWTGM =  " & _
            '     "CASE  " & _
            '      "WHEN SATCST = 0 THEN CAST(0 AS MONEY)  " & _
            '      "ELSE CAST(ROUND((SATOT$ - SATCST - SATRM$ - ROUND((@FreightPerLb4 * ABS(SAGRLB)), 2)) * SAGMWT, 2) AS MONEY)  " & _
            '     "END,  " & _
            ' "SAPLBF =  " & _
            '     "CASE  " & _
            '      "WHEN SATCST = 0 THEN 0  " & _
            '      "WHEN (SATOT$ - SATRM$) = 0 THEN 0  " & _
            '      "ELSE ROUND(((SATOT$ - SATCST - SATRM$) / (SATOT$ - SATRM$)) * 100,2,1) " & _
            '     "END ,  " & _
            ' "SAPLWF =  " & _
            '     "CASE  " & _
            '      "WHEN SATCST = 0 THEN 0  " & _
            '      "WHEN (SATOT$ - SATRM$) = 0 THEN 0  " & _
            '      "ELSE round(((SATOT$ - SATCST - SATRM$ - ROUND((@FreightPerLb5 * ABS(SAGRLB)), 2)) / (SATOT$ - SATRM$)) * 100,2,1) " & _
            '     "END  "


            Dim strSQLTotalCostSQL As String 'this segment of the query is re-used in a few places
            strSQLTotalCostSQL = "CASE SAGRLB  " & _
                              "WHEN 0 THEN 0  " & _
                              "ELSE  " & _
                                 "ROUND((@FreightPerLb{0} * ABS(SAGRLB)), 2)  " & _
                              "END"

            strSQL = "Update SAFile set " & _
             "SAFTLB = ROUND(@FreightPerLb1,4), " & _
             "SAFTIT = " & String.Format(strSQLTotalCostSQL, 2) & ", " & _
             "SAGMWF = " & _
                 "CASE  " & _
                  "WHEN SATCST = 0 THEN 0  " & _
                  "ELSE ROUND(SATOT$ - SATCST - SATRM$ - " & String.Format(strSQLTotalCostSQL, 3) & ", 2) " & _
                 "END,  " & _
             "SAWTGM =  " & _
                 "CASE  " & _
                  "WHEN SATCST = 0 THEN 0  " & _
                  "ELSE ROUND((SATOT$ - SATCST - SATRM$ - " & String.Format(strSQLTotalCostSQL, 4) & ") * SAGMWT, 2) " & _
                 "END,  " & _
             "SAPLBF = " & _
                "ROUND(" & _
                    "CAST(" & _
                        "CASE " & _
                            "WHEN SATOT$ = 0 THEN 0 " & _
                            "WHEN (SATOT$ - SATRM$) = 0 THEN 0 " & _
                            "ELSE (" & _
                                "CAST(SATOT$ - SATCST - SATRM$ AS FLOAT) / CAST(SATOT$ - SATRM$ AS FLOAT)" & _
                                ")" & _
                "END AS FLOAT" & _
            "), 4) * 100,  " & _
             "SAPLWF =  " & _
                 "ROUND(" & _
                    "CAST(" & _
                        "CASE " & _
                            "WHEN SATOT$ = 0 THEN 0 " & _
                            "WHEN (SATOT$ - SATRM$) = 0 THEN 0 " & _
                            "ELSE (" & _
                                "CAST(SATOT$ - SATCST - SATRM$ - " & String.Format(strSQLTotalCostSQL, 5) & " AS FLOAT) / CAST(SATOT$ - SATRM$ AS FLOAT)" & _
                                ")" & _
                    "END AS FLOAT" & _
                 "), 4) * 100 "
            Trace.Warn(strSQL)
            Dim cmd As New SqlCommand(strSQL, m_conn.Connection)

            


            For i As Integer = 1 To 5
                cmd.Parameters.Add("FreightPerLb" & i, SqlDbType.Decimal)
                cmd.Parameters("FreightPerLb" & i).Precision = 7
                cmd.Parameters("FreightPerLb" & i).Scale = 6
                cmd.Parameters("FreightPerLb" & i).Value = PricePerLb

               
            Next

            'Trace.Warn(_GVOrders.DataKeys)
            Dim strSQLWhereClause As String

            Dim arrOrderNumbers As New ArrayList
            Dim strOrderNumber As String

            '    Dim strOrderNumber(_GVOrders.DataKeys.Count) As String
            For Each dk As Web.UI.WebControls.DataKey In _GVOrders.DataKeys

                strOrderNumber = CType(dk.Value, Integer).ToString
                arrOrderNumbers.Add("@Order" & strOrderNumber)
                cmd.Parameters.Add("Order" & strOrderNumber, SqlDbType.Int)
                cmd.Parameters("Order" & strOrderNumber).Value = CInt(strOrderNumber)
                '        Trace.Warn(CType(dk.Value, Integer).ToString)

                If String.IsNullOrEmpty(strSQLWhereClause) Then
                    strSQLWhereClause = "WHERE ("
                Else
                    strSQLWhereClause &= " OR "
                End If
                strSQLWhereClause &= "SAORD# = ?"

                Trace.Warn(strOrderNumber)
            Next
            strSQLWhereClause &= ")"
            Dim strOrdernumberList() As String = CType(arrOrderNumbers.ToArray(GetType(String)), String())
            cmd.CommandText &= "where SAORD# In (" & String.Join(",", strOrdernumberList) & ")"
            Trace.Warn(cmd.CommandText)

            cmd.ExecuteNonQuery()
            '    String.Join()
            Trace.Warn(String.Join(",", strOrdernumberList))


            'dim 
        End If



        '        Update SAFile set SAFTLB = ROUND(case?,4), 
        'SAFTIT =  CASE SAGRLB  
        'WHEN 0 THEN CAST(0 AS MONEY)  
        'ELSE  CAST( ROUND((? * ABS(SAGRLB)), 2)  AS MONEY)  END, 
        'SAGMWF =  CASE  WHEN SATCST = 0 THEN CAST(0 AS MONEY)  
        'ELSE CAST(ROUND(SATOT$ - SATCST - SATRM$ - 
        'ROUND((? * ABS(SAGRLB)), 2), 2) AS MONEY) END,  SAWTGM =  CASE  
        'WHEN SATCST = 0 THEN CAST(0 AS MONEY)  ELSE 
        'CAST(ROUND((SATOT$ - SATCST - SATRM$ - 
        'ROUND((? * ABS(SAGRLB)), 2)) * SAGMWT, 2) AS MONEY)  END,  
        'SAPLBF =  CASE  WHEN SATCST = 0 THEN 0  WHEN (SATOT$ - SATRM$) = 0 
        'THEN 0  ELSE ROUND(((SATOT$ - SATCST - SATRM$) / (SATOT$ - SATRM$)) * 100,2,1) END , 
        ' SAPLWF =  CASE  WHEN SATCST = 0 THEN 0  
        'WHEN (SATOT$ - SATRM$) = 0 THEN 0  ELSE 
        'round(((SATOT$ - SATCST - SATRM$ - ROUND((? * ABS(SAGRLB)), 2)) / (SATOT$ - SATRM$)) * 100,2,1) 
        'END  WHERE (SAORD# = ?)
        'todo -- only do if freight per pound is valid and not 0
        'CType(e.Row.FindControl("_LblFreightChargeAmount"), Label).Text = FreightChargeAmount.ToString("F")
        'If IsNumeric(strGrossWeight) Then
        '    If GrossWeight <> 0 Then
        '        CType(e.Row.FindControl("_LblPricePer100"), Label).Text = ((FreightChargeAmount / GrossWeight) * 100).ToString("F")
        '    End If

        'End If
        'End If


        'Dim FreightCharge as NumericUpDownExtender.
        '        Dim PricePerLb As Decimal
        '        PricePerLb = 
        '        Trace.Warn(_GVOrders.DataKeys(0).Value.ToString)
        '        'Dim dk As Web.UI.WebControls.DataKey
        '        For Each dk As Web.UI.WebControls.DataKey In _GVOrders.DataKeys
        '            Trace.Warn(CType(dk.Value, Integer).ToString)
        '        Next
        '        Trace.Warn("HEre")
    End Sub

    Public Sub _GVOrders_RowDataBound(ByVal sender As Object, ByVal e As GridViewRowEventArgs) Handles _GVOrders.RowDataBound
        'Trace.Warn("begin function", "_GVOrders_RowDatabound")
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim strSQL As String
            Dim strOrderDetails As New Text.StringBuilder
            strSQL = "Select " & _
                "ODQTOR, " & _
                "ODITEM " & _
                "FROM ORDRDTL WHERE Cast(ODORNU as integer) = @OrderNumber"
            Dim dr As SqlDataReader
            Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
            cmd.Parameters.Add("@OrderNumber", SqlDbType.Int)
            cmd.Parameters("@OrderNumber").Value = CType(DataBinder.Eval(e.Row.DataItem, "OrderNumber"), Integer)
            dr = cmd.ExecuteReader

            cmd.Dispose()
            While dr.Read
                If strOrderDetails.Length > 0 Then
                    strOrderDetails.Append("<br/>")
                End If
                strOrderDetails.Append(dr(0).ToString & " " & dr(1).ToString)

            End While

            dr.Close()

            CType(e.Row.FindControl("_LblOrderDetails"), Label).Text = strOrderDetails.ToString

            'Format Ship Date
            'Dim strShipDate As String
            'strShipDate = DataBinder.Eval(e.Row.DataItem, "ShipDate")
            'If DataBinder.Eval(e.Row.DataItem, "ShipDate") isnot nothing Then
            CType(e.Row.FindControl("ViewAddNotesLink"), HyperLink).NavigateUrl = "/apps/notes/addedit.asp?NoteTypeID=101&NoteOrderNumber=" & DataBinder.Eval(e.Row.DataItem, "OrderNumber").ToString

            CType(e.Row.FindControl("ShipDateLabel"), Label).Text = String.Format("{0:M/dd/yy}", DataBinder.Eval(e.Row.DataItem, "ShipDate"))
            '  CType(e.Row.FindControl("ShipDateLabel"), Label).Text = String.Format("{0:M/dd/yy}", Ctype(strShipDate, dateTime, Refron_Global.DateTimeUtilities.DateFormat.MMDDYY))
            'Else
            '    CType(e.Row.FindControl("ShipDateLabel"), Label).Text = ""
            'End If
            CType(e.Row.FindControl("ViewAddNotesLink"), HyperLink).Attributes.Add("onclick", "NoteWindow=window.open(this.href, 'NoteWindow', 'height=180, width=450, channelmode=no, directories=no, fullscreen=no, location=no, menubar=no, resizeable=no, scrollbars=no, status=no, titlebar=yes, toolbar=no'); NoteWindow.focus();return false;")
            CType(e.Row.FindControl("RemoveOrdersLinkButton"), LinkButton).Attributes.Add("onclick", "return confirm('Are you sure you want to remove this Order from this Freight Charge?');")
            'Set up View/Add Note Link

            'ViewAddNotesLink()
            'Dim strSQL As String
            'strSQL = "SELECT NoteStanding, " & _
            '    "NoteDate, " & _
            '    "NoteText, " & _
            '    "UMNAME, " & _
            '    "NoteAuthor " & _
            '    "FROM Notes LEFT JOIN USERMST On " & _
            '    "NoteAuthor = UMUSCD " & _
            '    "WHERE NoteOrderNumber = " & Left(DataBinder.Eval(e.Row.DataItem, "OrderNumber"), 6) & " " & _
            '    "ORDER BY NoteStanding DESC, NoteDate DESC"

            'Dim cmd As New SqlCommand(strSQL, m_conn.Connection)

        End If


    End Sub




    <Microsoft.Web.Script.Services.ScriptMethod()> _
    Public Function GetOrderNotesx(ByVal contextKey As Integer) As String
        'Trace.Warn("begin function", "GetOrderNotes")
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

        Dim da As New SqlDataAdapter(strSQL, m_conn.Connection)
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

        Return strOutput.ToString
    End Function

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        'Trace.Warn("begin function", "prerender1")
        CalculateCzarLite()
        'Trace.Warn("prerender2")

        _TxtMiles.Text = Refron_Global.MileageCalculator.CalculateMiles(_TxtFromZip.Text, _TxtToZip.Text).ToString
        'Trace.Warn("prerender3")

    End Sub


    Sub Page_Unload(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Unload
        'Trace.Warn("begin function", "PAge_Unload")
        If m_conn IsNot Nothing Then
            m_conn.Dispose()
            m_conn = Nothing
        End If
    End Sub
    Protected Sub _BtnAddOrder_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles _BtnAddOrder.Click
        'Trace.Warn("begin function", "_BtnAddOrder_Click")
        Dim strMinOrderNumber, strMaxOrderNumber As String

        If IsNumeric(_TxtLookupOrders.Text) And Len(_TxtLookupOrders.Text) <= 7 Then
            '  Dim strOrderNumber As String
            ' strOrderNumber = _TxtOrderNumber.Text
            ' strOrderNumber.PadRight(7 - Len(_TxtOrderNumber.Text), CType("0", Char))
            ' Dim tempOrderNumber As Integer = CInt(_TxtOrderNumber.Text)


            strMinOrderNumber = _TxtLookupOrders.Text.PadRight(7, CType("0", Char))
            strMaxOrderNumber = CStr(CInt(_TxtLookupOrders.Text) + 1) & "".PadRight(7 - Len(_TxtLookupOrders.Text), CType("0", Char))
            'Trace.Warn("MinOrderNumber", strMinOrderNumber)
            'Trace.Warn("MaxOrderNumber", strMaxOrderNumber)


            _SdsVerifyOrderLink.SelectParameters("OrderNumberMin").DefaultValue = strMinOrderNumber
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMax").DefaultValue = strMaxOrderNumber
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMin2").DefaultValue = strMinOrderNumber
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMax2").DefaultValue = strMaxOrderNumber


            ' _SdsFreightCharges.SelectParameters.("OrderNumberMin")..Type = , TypeCode.Int32, "0")
            ' _SdsFreightCharges.SelectParameters.Add("OrderNumberMax", TypeCode.Int32, "0")
            'strminordernumber.
        Else

            _SdsVerifyOrderLink.SelectParameters("OrderNumberMin").DefaultValue = "0"
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMax").DefaultValue = "0"
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMin2").DefaultValue = "0"
            _SdsVerifyOrderLink.SelectParameters("OrderNumberMax2").DefaultValue = "0"
        End If


        If Trim(_TxtLookupOrders.Text) = String.Empty Then
            _GVVerifyOrderLink.Visible = False
        Else
            _GVVerifyOrderLink.Visible = True
        End If

    End Sub


    Protected Sub LinkOrderLinkButton_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
        'Trace.Warn("begin function", "LinkOrderLinkButton_Command")
        Dim strSQL As String = "Select OHORNU from ORDRHDR where OHORNU = @OrderNumber"


        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
        cmd.Parameters.Add("@OrderNumber", SqlDbType.Decimal, 7)

        cmd.Parameters("@OrderNumber").Value = CType(e.CommandArgument, Int32)
        Dim dr As SqlDataReader
        dr = cmd.ExecuteReader
        Dim Ordernumber As Decimal = 0

        While dr.Read
            Ordernumber = dr.GetDecimal(0)
        End While
        dr.Close()

        If Ordernumber = 0 Then
            'Order does not exist as typed - add error
            _LblLookupOrdersError.Text = "Order Number not found"
        Else
            'check to see if it exists
            strSQL = "Select OHFCID from ORDRHDR where OHORNU = @Ordernumber"
            cmd.CommandText = strSQL
            Dim recordexists As Boolean = False
            Dim FreightChargeExists As Boolean = False
            dr = cmd.ExecuteReader
            While dr.Read
                If IsDBNull(dr(0)) Then
                    FreightChargeExists = False
                ElseIf dr.GetDecimal(0) = 0 Or dr.GetDecimal(0) = 1 Then
                    FreightChargeExists = False
                Else
                    If CType(dr(0), Integer) = m_FreightChargeID Then
                        FreightChargeExists = False
                    Else
                        FreightChargeExists = True
                    End If
                End If

            End While
            dr.Close()

            If FreightChargeExists Then
                _LblLookupOrdersError.Text = "Order is already linked to another freight charge"
            Else

                strSQL = "Update ORDRHDR set OHFCID = @FreightChargeID where OHORNU = @OrderNumber"
                cmd.CommandText = strSQL
                cmd.Parameters.Add("@FreightChargeID", SqlDbType.Int, 4)
                cmd.Parameters("@FreightChargeID").Value = m_FreightChargeID
                cmd.ExecuteNonQuery()
                _LblLookupOrdersError.Text = ""
            End If



            _PnlLinkedOrders.Visible = True
            _GVOrders.DataBind()



            _GVVerifyOrderLink.Visible = False

        End If
        cmd.Dispose()

    End Sub

    Private Sub Bind_RptVendorQuickLookup()
        'Trace.Warn("begin function", "Bind_RptVendorQuickLookup")
        If _TxtFromWarehouse.Text <> String.Empty Then
            Dim strSQL As String
            strSQL = "select top 3 " & _
                   "VendorCode, " & _
                    "VNVNNM as VendorName " & _
                "from (" & _
                    "select " & _
                        "MAX(FreightChargeID) as FreightChargeID, " & _
                        "VendorCode " & _
                     "from freightcharges " & _
                    "where " & _
                    "VendorCode <> 0 " & _
                    "AND warehousecode = @WarehouseCode " & _
                    "group by " & _
                        "VendorCode) as tbl1 " & _
                "INNER Join APVNDR on VendorCode = Cast(VNVNNU as integer) " & _
                "order by freightchargeid desc"
            Dim da As New SqlDataAdapter(strSQL, m_conn.Connection)
            Dim dt As New DataTable
            'Trace.Warn(strSQL)
            da.SelectCommand.Parameters.Add("@WarehouseCode", SqlDbType.Char, 3)
            da.SelectCommand.Parameters("@WarehouseCode").Value = _TxtFromWarehouse.Text
            da.Fill(dt)
            _RptVendorQuickLookup.DataSource = dt
            _RptVendorQuickLookup.DataBind()
            dt.Dispose()
            da.Dispose()

        End If
    End Sub

    'Private Sub CreateOrdersSQLString()
    '    Dim strSQL As String
    '    strSQL = "SELECT " & _
    '        "OHORNU AS OrderNumber,  " & _
    '        "OHSHDT as ShipDate,  " & _
    '        "OHBL# as BLNumber, " & _
    '        "OHSAD1 as CustomerName,  " & _
    '        "OHSCTY as CustomerCity, " & _
    '        "OHSSTE as CustomerState, " & _
    '        "OHSZIP  as CustomerZip, " & _
    '        "LineItemCount, " & _
    '        "ItemTotal, " & _
    '        "TotalGrossWeight " & _
    '        "From ordrhdr " & _
    '            "Left Join (" & _
    '             "Select " & _
    '                 "ODORNU as OrderNumber, " & _
    '                 "SUM(ODQTOR) as ItemTotal, " & _
    '                 "Count(ODORNU) as LineItemCount, " & _
    '                 "Sum((ITGRWT * ODQTOR)) as TotalGrossWeight " & _
    '                 "From ordrdtl Left Join " & _
    '                     "itemmst on oditem = ititem Group By ODORNU" & _
    '             ") as GrossWeightTable " & _
    '             "on ordrhdr.ohornu = GrossWeightTable.Ordernumber" & _
    '        "Where OHORNU = " & ViewState("OrderNumber") ' (4006450,4004980, 3980592)"
    'End Sub

    'Private Sub FillForm()

    'End Sub
    'Protected Sub Calendar1_SelectionChanged(ByVal sender As Object, ByVal e As EventArgs) Handles Calendar1.SelectionChanged
    '    AjaxControlToolkit.PopupControlExtender.GetProxyForCurrentPopup(Me.Page).Commit(Calendar1.SelectedDate.Date.ToShortDateString())


    'End Sub
    Protected Sub RemoveOrdersLinkButton_Command(ByVal sender As Object, ByVal e As CommandEventArgs)
        'Trace.Warn("begin function", "RemoveOrdersLinkButton_Command")

        


        Dim strSQL As String = "Update ordrHDR set OHFCID = 0 where OHORNU = @OrderNumber"
        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
        cmd.Parameters.Add("@OrderNumber", SqlDbType.Int, 4)
        cmd.Parameters("@OrderNumber").Value = CType(e.CommandArgument, Int32)
        cmd.ExecuteNonQuery()
        cmd.Dispose()
        _GVOrders.DataBind()

    End Sub

    'Protected Sub _GVOrders_RowCommand(ByVal sender As Object, ByVal e As GridViewCommandEventArgs) Handles _GVOrders.RowCommand
    '    Dim strSQL As String
    '    If e.CommandName = "RemoveOrder" Then
    '        strSQL = "Update testordrHDR set FreightChargeID = Null where testOrdrHdrID = @OrderNumber"
    '        Dim row As GridViewRow = CType(CType(e.CommandSource, Control).NamingContainer, GridViewRow)
    '        Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
    '        cmd.Parameters.AddWithValue("@OrderNumber", _GVOrders.DataKeys(row.RowIndex).Value)
    '        cmd.ExecuteNonQuery()
    '        cmd.Dispose()
    '    End If  
    'End Sub

    Protected Sub _BtnUpdateManualEntry_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles _BtnUpdateManualEntry.Click
        'Trace.Warn("begin function", "_BtnUpdateManualEntry_Click")
        _TxtMiles.Text = Refron_Global.MileageCalculator.CalculateMiles(_TxtFromZip.Text, _TxtToZip.Text).ToString
        CalculateCzarLite()
        'Trace.Warn("calculate CzarLite in _BtnUpdateManualEntry_Click")

        '_GVOrders.DataBind()

    End Sub

    Protected Sub _GVVerifyOrderLink_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles _GVVerifyOrderLink.DataBound
        ''todo - remove this sub - only used for trace info
        'Trace.Warn("begin function", "_GVVerifyOrderLink_DataBound")

    End Sub



    Protected Sub _GVVerifyOrderLink_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles _GVVerifyOrderLink.RowDataBound
        'Trace.Warn("begin function", "_GVVerifyOrderLink_RowDatabound")
        Dim ShowLink As Boolean = True

        If e.Row.RowType = DataControlRowType.DataRow Then
            'Dim _LblConfirmOrderError As Label = CType(e.Row.FindControl("_LblConfirmOrderError"), Label)

            If Not IsDBNull(DataBinder.Eval(e.Row.DataItem, "OHORNU")) Then
                CType(e.Row.FindControl("_LnkOrderGridOrderDetails"), HyperLink).ToolTip = GetOrderDetails(CType(DataBinder.Eval(e.Row.DataItem, "OHORNU"), Integer))
            End If

            'ShipDate, bl, whs
            'todo - add bl and warehouse to this check

            If Not IsDBNull(DataBinder.Eval(e.Row.DataItem, "ShipDate")) And IsDate(_TxtShipDate.Text) Then
                If CType(_TxtShipDate.Text, Date) <> CType(DataBinder.Eval(e.Row.DataItem, "ShipDate"), Date) Then
                    ShowLink = False
                End If
            End If

            'If _TxtBLNumber.Text <> String.Empty And CType(DataBinder.Eval(e.Row.DataItem, "BillOfLadingNumber"), String) <> String.Empty Then
            '    If _TxtBLNumber.Text <> CType(DataBinder.Eval(e.Row.DataItem, "BillOfLadingNumber"), String) Then
            '        ShowLink = False
            '    End If
            'End If

            If _TxtFromWarehouse.Text <> String.Empty And CType(DataBinder.Eval(e.Row.DataItem, "WarehouseCode"), String) <> String.Empty Then
                If _TxtFromWarehouse.Text <> CType(DataBinder.Eval(e.Row.DataItem, "WarehouseCode"), String) Then
                    ShowLink = False
                End If

            End If
            If CType(DataBinder.Eval(e.Row.DataItem, "FreightChargeID"), Integer) = m_FreightChargeID Then
                ShowLink = False
            End If
            If ShowLink = False Then
                CType(e.Row.FindControl("_LnkConfirmOrderLink"), LinkButton).Visible = False
                CType(e.Row.FindControl("_LblConfirmOrderError"), Label).Visible = True
            End If
            'Dim strShipDate As String
            'strShipDate = DataBinder.Eval(e.Row.DataItem, "ShipDate")
            'If Len(strShipDate) = 4 Or Len(strShipDate) = 5 Then
            If IsDBNull(DataBinder.Eval(e.Row.DataItem, "ShipDate")) Then
                CType(e.Row.FindControl("ShipDateLabel"), Label).Text = String.Empty
            Else
                CType(e.Row.FindControl("ShipDateLabel"), Label).Text = String.Format("{0:M/dd/yy}", DataBinder.Eval(e.Row.DataItem, "ShipDate"))
            End If
            'Else
            '    CType(e.Row.FindControl("ShipDateLabel"), Label).Text = ""
            'End If
            'CType(e.Row.FindControl("ViewAddNotesLink"), HyperLink).Attributes.Add("onclick", "NoteWindow=window.open(this.href, 'NoteWindow', 'height=180, width=450, channelmode=no, directories=no, fullscreen=no, location=no, menubar=no, resizeable=no, scrollbars=no, status=no, titlebar=yes, toolbar=no'); NoteWindow.focus();return false;")
            'CType(e.Row.FindControl("RemoveOrdersLinkButton"), LinkButton).Attributes.Add("onclick", "return confirm('Are you sure you want to remove this Order from this Freight Charge?');")

        End If

    End Sub

    Public Function GetOrderDetails(ByVal contextKey As Integer) As String
        'Trace.Warn("begin function", "GetOrderDetails")
        Dim OrderNumber As Integer = contextKey

        Dim strOrderDetails As New Text.StringBuilder

        Dim strSQL As String
        strSQL = "SELECT " & _
           "OHORNU, " & _
           "OHCSCD, " & _
           "OHSAD1, " & _
           "OHSAD2, " & _
           "OHSAD3, " & _
           "OHSCTY, " & _
           "OHSSTE, " & _
           "OHODT8, " & _
           "OHSHDT, " & _
           "OHBL#, " & _
           "OHWHRC, " & _
           "OHWHS, " & _
           "OHPO#, " & _
           "OHDLVY, " & _
           "OHPHON, " & _
           "OHCLBY, " & _
           "OHSTAT " & _
           " FROM ORDRHDR Where OHORNU = @OrderNumber" ' & _
        '"LEFT JOIN ORDRDTL ON ODORNU = OHORNU "

        '  strSQL = " Where OHORNU = @OrderNumber"
        Dim ds As New DataSet
        Dim da As New SqlDataAdapter(strSQL, m_conn.Connection)

        da.SelectCommand.Parameters.Add("@OrderNumber", SqlDbType.Decimal, 7)
        da.SelectCommand.Parameters("@OrderNumber").Value = CType(OrderNumber, Decimal)
        da.Fill(ds, "OrderHeader")

        strSQL = "Select " & _
            "ODITEM, " & _
            "ODQTOR " & _
            "FROM ORDRDTL WHERE ODORNU = @OrderNumber"
        da.SelectCommand.CommandText = strSQL
        da.Fill(ds, "OrderDetails")
        Dim dr, drItem As DataRow
        If ds.Tables("OrderHeader").Rows.Count > 0 Then

            dr = ds.Tables("OrderHeader").Rows(0)

            If Trim(dr("OHSAD1").ToString) <> String.Empty Then
                strOrderDetails.Append(dr("OHSAD1").ToString)
                strOrderDetails.Append(vbNewLine)
            End If
            If Trim(dr("OHSAD2").ToString) <> "" Or Trim(dr("OHSAD3").ToString) <> "" Then
                strOrderDetails.Append("Address: ")
                If Trim(dr("OHSAD2").ToString) <> "" Then
                    strOrderDetails.Append(Trim(dr("OHSAD2").ToString))
                    If Trim(dr("OHSAD3").ToString) <> "" Then
                        strOrderDetails.Append(",  ")
                    End If
                End If
                If Trim(dr("OHSAD3").ToString) <> "" Then
                    strOrderDetails.Append(dr("OHSAD3").ToString)
                End If
                strOrderDetails.Append(vbNewLine)
            End If

            If Trim(dr("OHDLVY").ToString) <> "" Then
                strOrderDetails.Append("Deliver By:  ")
                strOrderDetails.Append(Trim(dr("OHDLVY").ToString))
                strOrderDetails.Append(vbNewLine)
            End If
            If Trim(dr("OHPO#").ToString) <> "" Then
                strOrderDetails.Append("P.O.Number: ")
                strOrderDetails.Append(Trim(dr("OHPO#").ToString))
                strOrderDetails.Append(vbNewLine)
            End If
            If Trim(dr("OHCLBY").ToString) <> "" Then
                strOrderDetails.Append("Called in by: ")
                strOrderDetails.Append(Trim(dr("OHCLBY").ToString))
                strOrderDetails.Append("  ")
            End If
            If Trim(dr("OHPHON").ToString) <> "" Then
                Dim strPhone As String
                strPhone = Trim(Mid(dr("OHPHON").ToString, 1, 3))
                strPhone = strPhone & "-"
                strPhone = strPhone & Trim(Mid(dr("OHPHON").ToString, 4, 3))
                strPhone = strPhone & "-"
                strPhone = strPhone & Trim(Mid(dr("OHPHON").ToString, 7, 4))
                strOrderDetails.Append(Trim(strPhone))
            End If


            For Each drItem In ds.Tables("OrderDetails").Rows
                strOrderDetails.Append(vbNewLine)
                strOrderDetails.Append("ITEM:  ")
                strOrderDetails.Append(drItem("ODQTOR").ToString())
                strOrderDetails.Append("  ")
                strOrderDetails.Append(drItem("ODITEM").ToString())
            Next
        End If
        ds.Dispose()
        da.Dispose()

        Return strOrderDetails.ToString
    End Function

    Protected Sub _BtnSave_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles _BtnSave.Click
        'Trace.Warn("begin function", "Before calculate CzarLite in _BtnSave_Click")
        CalculateCzarLite()
        'Trace.Warn("after calculate CzarLite in _BtnSave_Click")

        If Page.IsValid Then
            SaveFreightCharge()
            'Trace.Warn("COmpare", _SdsCompareShipments.SelectCommand)
            'Trace.Warn(_SdsCompareShipments.SelectParameters("2yrsAgo").ToString)
            _GVCompareShipments.DataBind()
            'Trace.Warn("After _GVCompareShipments.DataBind()")
            _LblUpdated.Text = "Updated"
        Else
            _LblUpdated.Text = ""
        End If
    End Sub

    Protected Sub _BtnSaveAndExit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles _BtnSaveAndExit.Click
        'Trace.Warn("begin function", "before calculate CzarLite in _BtnSaveAndExit_Click")
        CalculateCzarLite()
        'Trace.Warn("after calculate CzarLite in _BtnSaveAndExit_Click")

        If Page.IsValid Then
            SaveFreightCharge()
            Response.Redirect("~/shipping/SearchFreightCharges.aspx")

        End If

    End Sub

    Protected Sub _BtnExit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles _BtnExit.Click
        Response.Redirect("~/shipping/SearchFreightCharges.aspx")
    End Sub
    
    Protected Sub _RptVendorQuickLookup_ItemCreated(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.RepeaterItemEventArgs) Handles _RptVendorQuickLookup.ItemCreated
        'Trace.Warn("begin function", "_rptVendorQuickLookup_ItemCreated")
        If e.Item.ItemType = ListItemType.Item Or e.Item.ItemType = ListItemType.AlternatingItem Then
            Dim VendorCode, VendorName As String
            VendorCode = CType(DataBinder.Eval(e.Item.DataItem, "VendorCode"), String)
            VendorName = CType(DataBinder.Eval(e.Item.DataItem, "VendorName"), String)

            CType(e.Item.FindControl("_LnkVendorQuickLookup"), HyperLink).Attributes.Add("onClick", "updateVendorCode('" & VendorCode & "', '" & Replace(VendorName, "'", "\'") & "');")
            CType(e.Item.FindControl("_LnkVendorQuickLookup"), HyperLink).Text = Left(VendorName, 14)
        End If
    End Sub

    Protected Sub _Cuv_DdlPaymentCode_ServerValidate(ByVal source As Object, ByVal args As System.Web.UI.WebControls.ServerValidateEventArgs) Handles _Cuv_DdlPaymentCode.ServerValidate
        'Trace.Warn("begin function", "_Cuv_DdlPaymentCode_ServerValidate")
        If _DdlPaymentCode.SelectedItem.Text = "Pay Now" Then
            If IsNumeric(_TxtVendorCode.Text) Then
                Dim strSQL As String
                strSQL = "Select Count(VNVNNM) from APVNDR where VNVNNU = @VendorCode  AND VNORNU > 0"
                Dim cmd As New SqlCommand(strSQL, m_conn.Connection)
                cmd.Parameters.Add("@VendorCode", SqlDbType.Decimal, 7)
                cmd.Parameters("@VendorCode").Value = CType(_TxtVendorCode.Text, Double)
                'Trace.Warn("xx")
                If CType(cmd.ExecuteScalar, Integer) = 1 Then
                    args.IsValid = True
                Else
                    args.IsValid = False
                End If
                cmd.Dispose()
            Else
                args.IsValid = True
            End If
        Else
            args.IsValid = True
        End If
        'Trace.Warn(args.IsValid.ToString)
    End Sub
    Private p_LastGrossWeight As Integer

    Protected Sub _GVCompareShipments_DataBinding(ByVal sender As Object, ByVal e As System.EventArgs) Handles _GVCompareShipments.DataBinding
        ''todo - remove this sub - only used for trace info
        'Trace.Warn("begin function", "_GVCompareShipments_DataBinding")
    End Sub



    Protected Sub _GVCompareShipments_DataBound(ByVal sender As Object, ByVal e As System.EventArgs) Handles _GVCompareShipments.DataBound
        ''todo - remove this sub - only used for trace info
        'Trace.Warn("begin function", "_GVCompareShipments_DataBound")
    End Sub
    Protected Sub _GVCompareShipments_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles _GVCompareShipments.RowDataBound
        'Trace.Warn("begin function", "_GVCompareShipments_RowDataBound")
        If e.Row.RowType = DataControlRowType.DataRow Then
            If CType(DataBinder.Eval(e.Row.DataItem, "FreightChargeID"), Integer) = m_FreightChargeID Then
                Dim strJava As String
                strJava = "document.all." & CType(e.Row.FindControl("_LblFreightChargeAmount"), Label).ClientID & ".innerText = document.all." & _TxtFreightChargeAmount.ClientID & ".value;calculateCzarLite();"
                _TxtFreightChargeAmount.Attributes.Add("onChange", strJava)
                e.Row.BackColor = Drawing.Color.LightGreen
            End If
            CType(e.Row.FindControl("ShipDateLabel"), Label).Text = String.Format("{0:M/dd/yy}", DataBinder.Eval(e.Row.DataItem, "ShipDate"))
            Dim strFreightChargeAmount, strGrossWeight As String
            Dim FreightChargeAmount As Decimal
            Dim GrossWeight As Integer
            '"(FreightChargeAmount / GrossWeight)*100 as PricePer100," & _

            strFreightChargeAmount = DataBinder.Eval(e.Row.DataItem, "FreightChargeAmount").ToString
            strGrossWeight = DataBinder.Eval(e.Row.DataItem, "GrossWeight").ToString

            If IsNumeric(strGrossWeight) Then
                GrossWeight = CType(strGrossWeight, Integer)
            End If
            If p_LastGrossWeight <> GrossWeight Then
                p_LastGrossWeight = GrossWeight
                'e.Row.Style("") = "solid yellow"
            End If
            If IsNumeric(strFreightChargeAmount) Then
                FreightChargeAmount = CType(strFreightChargeAmount, Decimal)
                strGrossWeight = DataBinder.Eval(e.Row.DataItem, "GrossWeight").ToString
                CType(e.Row.FindControl("_LblFreightChargeAmount"), Label).Text = FreightChargeAmount.ToString("F")
                If IsNumeric(strGrossWeight) Then
                    If GrossWeight <> 0 Then
                        CType(e.Row.FindControl("_LblPricePer100"), Label).Text = ((FreightChargeAmount / GrossWeight) * 100).ToString("F")
                    End If

                End If
            End If

            '            _LblCzarLitePercent.Text = String.Format("{0:p}", (CType(_TxtFreightChargeAmount.Text, Double) / CType(_LblCzarLiteAmount.Text, Double)) - 1)

        End If
    End Sub
End Class
