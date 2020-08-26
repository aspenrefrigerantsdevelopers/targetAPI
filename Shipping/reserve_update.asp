<!--#include virtual="/shared/global/server_includes/global.asp"-->
<!--#include virtual="/shared/global/server_includes/error_check.asp"-->
<!--#include virtual="/shared/global/server_includes/date_time.asp"-->
<!--#include virtual="/shared/global/server_includes/formatting.asp"-->
<!--#include virtual="/shared/global/server_includes/fax.asp"-->

<%
Dim Page
Set Page = Server.CreateObject("RefronIntranetPage.WSC")
Page.Title = "Refron Intranet: Reserve Order"
Page.PermissionOptions = "1061=10142"
Page.CheckPermissions()



Dim OrderNumber
Dim ShipZip
Dim WarehouseCode
Dim WarehouseZip
Dim CurrentDateTime
Dim outSentEmail : outSentEmail = 0 
dim oraComm
dim rs
dim checkType

If Len(StripPhone(Request.Form("OrderNumber"))) = 7 And IsNumeric(StripPhone(Request.Form("OrderNumber"))) Then
	Dim rsOrder
	Set rsOrder = Server.CreateObject("ADODB.Recordset")
	strSql = _
		"SELECT " & _
			"LTRIM(RTRIM(OHCSCD)) AS ShipAccountCode, " & _
			"CAST(OHORNU AS VARCHAR(7)) AS OrderNumber, " & _
			"OHODT8 AS OrderDate, " & _
			"LTRIM(RTRIM(OHWHS)) AS WarehouseCode, " & _
			"LTRIM(RTRIM(OHTXWH)) AS TransmitWarehouseCode, " & _
			"LTRIM(RTRIM(OHSAD1)) AS ShipCompanyName, " & _
			"LTRIM(RTRIM(OHCLBY)) AS CalledInBy, " & _
			"OHPHON AS PhoneNumber, " & _
			"LTRIM(RTRIM(OHCNFL)) AS ConfirmationFlag, " & _
			"OHCNFR AS ConfirmationFaxNumber, " & _
			"OHEmail AS ConfirmationEmail, " & _
			"OHEmailFlag AS ConfirmationEmailFlag, " & _
			"LTRIM(RTRIM(OHPO#)) AS PurchaseOrderNumber, " & _
			"LTRIM(RTRIM(OHRLS)) AS ReleaseNumber, " & _
			"OHRVDT AS ReserveDate, " & _
			"LTRIM(RTRIM(OHTXST)) AS TransmitStatus, " & _
			"OHTXWH AS TransmitDate, " & _
			"OHTXTM AS TransmitTime, " & _
			"OHTXBY AS TransmitBy, " & _
			"LTRIM(RTRIM(OHDLVY)) AS DeliverByDate, " & _
			"LTRIM(RTRIM(OHSPIN)) AS ShippingInstructions, " & _
			"LTRIM(RTRIM(OHBAD1)) AS BillCompanyName, " & _
			"LTRIM(RTRIM(OHBAD2)) AS BillAddress1, " & _
			"LTRIM(RTRIM(OHBAD3)) AS BillAddress2, " & _
			"LTRIM(RTRIM(OHBCTY)) AS BillCity, " & _
			"LTRIM(RTRIM(OHBSTE)) AS BillState, " & _
			"CASE LEN(OHBZIP) " & _
				"WHEN 5 THEN CAST(OHBZIP AS CHAR(5)) " & _
				"WHEN 4 THEN '0' + CAST(OHBZIP AS CHAR(4)) " & _
				"WHEN 3 THEN '00' + CAST(OHBZIP AS CHAR(3)) " & _
				"WHEN 2 THEN '000' + CAST(OHBZIP AS CHAR(2)) " & _
				"WHEN 1 THEN '' " & _
				"ELSE '' " & _
				"END AS BillZip, " & _
			"LTRIM(RTRIM(OHSAD1)) AS ShipCompanyName, " & _
			"LTRIM(RTRIM(OHSAD2)) AS ShipAddress1, " & _
			"LTRIM(RTRIM(OHSAD3)) AS ShipAddress2, " & _
			"LTRIM(RTRIM(OHSCTY)) AS ShipCity, " & _
			"LTRIM(RTRIM(OHSSTE)) AS ShipState, " & _
			"CASE LEN(OHSZIP) " & _
				"WHEN 5 THEN CAST(OHSZIP AS CHAR(5)) " & _
				"WHEN 4 THEN '0' + CAST(OHSZIP AS CHAR(4)) " & _
				"WHEN 3 THEN '00' + CAST(OHSZIP AS CHAR(3)) " & _
				"WHEN 2 THEN '000' + CAST(OHSZIP AS CHAR(2)) " & _
				"WHEN 1 THEN '' " & _
				"ELSE '' " & _
				"END AS ShipZip " & _
		"FROM ORDRHDR " & _
		"WHERE OHORNU = " & StripPhone(Request.Form("OrderNumber"))
	
	rsOrder.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	If rsOrder.EOF Then
		AddError("Order not found")
	Else
		OrderNumber = rsOrder("OrderNumber")
		ShipZip = rsOrder("ShipZip")
		Dim ReadOnly
		If Trim(rsOrder("WarehouseCode")) = Trim(Request.Form("WarehouseCode")) Then
			ReadOnly = True
		ElseIf Trim(rsOrder("WarehouseCode")) <> "" Then
			AddError("Order already reserved")
		Else
			ReadOnly = False
		End If
	End If
Else
	AddError("Invalid order number")
End If
If Len(Trim(Request.Form("WarehouseCode"))) = 3 Then
	Dim rsWarehouse
	Set rsWarehouse = Server.CreateObject("ADODB.Recordset")
	strSql = _
		"SELECT " & _
			"LTRIM(RTRIM(CMCSCD)) AS WarehouseCode, " & _
			"LTRIM(RTRIM(CMCSNM)) AS WarehouseName, " & _
			"CMTEL# AS WarehousePhoneNumber, " & _
			"CMEMAL as WarehouseEmail, " & _
			"CMFAX# AS WarehouseFaxNumber, " & _
			"WMSTAT AS WarehouseStatus, " & _
			"WMZIP AS WarehouseZip, " & _
			"WMORPM as WarehousePreferred, " & _
			"CASE " & _
				"WHEN COFNM IS NULL THEN 'Shipping Department' " & _
				"ELSE LTRIM(RTRIM(COFNM)) + ' ' + LTRIM(RTRIM(COLNM)) " & _
				"END AS WarehouseContact " & _
		"FROM CUSTMST " & _
			"LEFT JOIN WHSEMST ON CMCSCD = WMWHS " & _
			"LEFT JOIN CONTACTS ON CMCSCD = COCSCD " & _
		"WHERE CMCSCD = '" & Trim(Request.Form("WarehouseCode")) & "' " & _
		"ORDER BY COPRIM DESC"
	
	rsWarehouse.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	If rsWarehouse.EOF Then
		AddError("Warehouse not found")
	Else
		If IsNull(rsWarehouse("WarehouseStatus")) Then
			AddError("Warehouse not found in warehouse master")
		ElseIf rsWarehouse("WarehouseStatus") = "X" Then
			AddError("Warehouse not active")
		Else
			WarehouseCode = rsWarehouse("WarehouseCode")
			WarehouseZip = rsWarehouse("WarehouseZip")
		End If
	End If
Else
	AddError("Invalid warehouse code")
End If

CurrentDateTime = Now()

If Session("NumErrors") > 0 Then
	Response.Write ReturnErrorMsg()
Else

	Dim cmd
	Set cmd = Server.CreateObject("ADODB.Command")
	
	If Not ReadOnly Then
		strSql = _
			"UPDATE ORDRHDR SET " & _
				"OHWHS = ?, " & _
				"OHRVDT = ? " & _
			"WHERE OHORNU = ? "
		Call DeleteAllParameters(cmd)
		cmd.Parameters.Append cmd.CreateParameter("ReserveWarehouseCode", adChar, adParamInput, 3, WarehouseCode)
		cmd.Parameters.Append cmd.CreateParameter("ReserveDate", adInteger, adParamInput, , ConvertDate(CurrentDateTime, "PC", "CCYYMMDD"))
		cmd.Parameters.Append cmd.CreateParameter("OrderNumber", adInteger, adParamInput, , OrderNumber)

		cmd.CommandText = strSql
		cmd.ActiveConnection = conRefron
		cmd.Execute , , adExecuteNoRecords
			
        checkType = "reservE"
        set oraComm = Server.CreateObject("ADODB.Command")
        with oraComm
            with oraComm
                .activeconnection = conRefron
                .CommandType = 4 'adCmdStoredProc            
                .CommandText = "dbo.BondedWarehouse_OrderDetail_RecoveryCylinderCheck"
                .Parameters.Append oraComm.CreateParameter("@inOrderID",200,&H0001,8000, OrderNumber)
                .Parameters.Append oraComm.CreateParameter("@outSendMail",200,adParamOutput,8000,"")
                .Parameters.Append oraComm.CreateParameter("@inCheckType",200,&H0001,8000, checkType)
            end with
            set rs = oraComm.execute			
            outSentEmail = .parameters("@outSendMail")
        end with
	response.Write ("debug 175 <br>")	
	response.Write (OrderNumber & "<br>")
	response.Write(checkType & "<br>")
	response.Write(WarehouseCode & "<br>")
	response.Write("end")
' Added by Joshua Craig on Feb 8th, 2012 to lock BOL number to order


		strSql = _
			" EXEC get_BOL_Number ? "
		Call DeleteAllParameters(cmd)
		cmd.Parameters.Append cmd.CreateParameter("OrderNumber", adInteger, adParamInput, , OrderNumber)
       
		cmd.CommandText = strSql
		cmd.ActiveConnection = conRefron
		cmd.Execute , , adExecuteNoRecords


' End 

		strSql = _
			"UPDATE ORDRDTL SET " & _
				"ODWHS = ?, " & _
				"ODIVFL = ? " & _
			"WHERE ODORNU = ? " & _
				"AND ODQTOR > 0 " 'Added 8/7/06 by Ben - Only update field when quantity ordered > 0
		Call DeleteAllParameters(cmd)
		cmd.Parameters.Append cmd.CreateParameter("WarehouseCode", adChar, adParamInput, 3, WarehouseCode)
		cmd.Parameters.Append cmd.CreateParameter("InventoryFlag", adChar, adParamInput, 1, "R")
		cmd.Parameters.Append cmd.CreateParameter("OrderNumber", adInteger, adParamInput, , OrderNumber)

		
		cmd.CommandText = strSql
		cmd.ActiveConnection = conRefron
		cmd.Execute , , adExecuteNoRecords

	End If
	
	Dim rsOrderDetails
	Set rsOrderDetails = Server.CreateObject("ADODB.Recordset")
	strSql = _
		"SELECT " & _
			"LTRIM(RTRIM(ODITEM)) AS ItemCode, " & _
			"CAST(ODQTOR AS INTEGER) AS QuantityOrdered, " & _
			"LTRIM(RTRIM(ITDSCR)) AS ItemDescription " & _
		"FROM ORDRDTL " & _
			"LEFT JOIN ITEMMST ON ODITEM = ITITEM " & _
		"WHERE ODORNU = " & OrderNumber & " " & _
		"ORDER BY ODQTOR DESC"
	
	rsOrderDetails.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	
	Dim IncludesPickups, IncludesDeliveries
	IncludesPickups = False
	IncludesDeliveries = False
	
	Do While Not rsOrderDetails.EOF
		If rsOrderDetails("QuantityOrdered") > 0 Then
			If Not ReadOnly Then
	'			--- For the time being we will assume that there is a record since we do not allow it ---
	'			--- to be reserved on the previous screen unless there is one (saves us 1 call to DB) ---
	'			If conRefron.Execute("SELECT COUNT(*) AS InventoryCount FROM ITEMINV WHERE ICITEM = '" & rsOrderDetails("ItemCode") & "' AND ICWHS = '" & WarehouseCode & "'")("InventoryCount") > 0 Then
				strSql = _
					"UPDATE QS36F.ITEMINV SET " & _
						"ICCSOR = ICCSOR + ? " & _
					"WHERE ICITEM = ? " & _
						"AND ICWHS = ?"
				Call DeleteAllParameters(cmd)
				cmd.Parameters.Append cmd.CreateParameter("QuantityOrdered", adInteger, adParamInput, , rsOrderDetails("QuantityOrdered"))
				cmd.Parameters.Append cmd.CreateParameter("ItemCode", adChar, adParamInput, 9, rsOrderDetails("ItemCode"))
				cmd.Parameters.Append cmd.CreateParameter("WarehouseCode", adChar, adParamInput, 3, WarehouseCode)

				
				cmd.CommandText = FixSQL(strSql)
				cmd.ActiveConnection = conRefron
				cmd.Execute , , adExecuteNoRecords
				
				
				
			End If
			IncludesDeliveries = True
		Else
			IncludesPickups = True
		End If
			
		rsOrderDetails.MoveNext
	Loop

	If Request.QueryString("FaxWhse") = "Y" Then

		'Call FaxPDF("WarehouseOrder")

		strSql = _
			"UPDATE ORDRHDR SET " & _
				"OHTXST = ?, " & _
				"OHTXWH = ?, " & _
				"OHTXDT = ?, " & _
				"OHTXTM = ?, " & _
				"OHTXBY = ? " & _
			"WHERE OHORNU = ? "
		Call DeleteAllParameters(cmd)
		
		if RTrim(ToPreferred) = "Fax" then
			cmd.Parameters.Append cmd.CreateParameter("TransmitStatus", adChar, adParamInput, 1, "F")
		else
			cmd.Parameters.Append cmd.CreateParameter("TransmitStatus", adChar, adParamInput, 1, "E")
		end if

		cmd.Parameters.Append cmd.CreateParameter("TransmitWarehouseCode", adChar, adParamInput, 3, WarehouseCode)
		cmd.Parameters.Append cmd.CreateParameter("TransmitDate", adInteger, adParamInput, , ConvertDate(CurrentDateTime, "PC", "MMDDYY"))
		cmd.Parameters.Append cmd.CreateParameter("TransmitTime", adInteger, adParamInput, , ConvertDate(CurrentDateTime, "PCTIME", "HHMM"))
		cmd.Parameters.Append cmd.CreateParameter("TransmitBy", adChar, adParamInput, 2, Session("UserCode"))
		cmd.Parameters.Append cmd.CreateParameter("OrderNumber", adInteger, adParamInput, , OrderNumber)

		
		cmd.CommandText = strSql
		cmd.ActiveConnection = conRefron
		cmd.Execute , , adExecuteNoRecords

        

        dim strEmail
         strEmail = trim(rsWarehouse("WarehouseEmail"))
        
        if strEmail = "" Then
            strEmail = "NONE"
        End If

        if trim(WarehouseCode) = "MO7" Then
            'strEmail = trim(FixFaxNumber("8164834995")) & "@fax.refron.com"  
        End If
       

       ' if trim(WarehouseCode) <> "GA4" and trim(WarehouseCode) <> "NY4" then

            dim url1 
            url1 = "http://intranet.refron.com/Print_Processing/email.aspx?&reportName=Bill+Of+Lading&reportFolder=Refron+Reports&NumberOfCopies=1&LinesPerPage=6&OrderNum=" & OrderNumber & "&ToEmail=" & strEmail
response.Write(url1)
     
            response.write("<script>")
            response.write("window.open('" & url1 & "','bol2123');")
            response.write("</script>")

       ' End If

	End If

	If (rsOrder("ConfirmationEmailFlag") = "Y" Or rsOrder("ConfirmationEmailFlag") = "C") Then
		Call DeleteAllParameters(cmd)
		with cmd
			.activeconnection = conRefron
			.CommandType = 4 'adCmdStoredProc
			.CommandText = "dbo.NotifyQueue_AddOrderConfirmationEmail"
			.Parameters.Append cmd.CreateParameter("@inOrderID",200,&H0001,8000, OrderNumber)
			.NamedParameters = True
			.Execute , , adExecuteNoRecords
		end with
	End If

	If Request.QueryString("FaxCust") = "Y" And (rsOrder("ConfirmationFlag") = "Y" Or rsOrder("ConfirmationFlag") = "C") Then
		strSql = _
			"UPDATE ORDRHDR SET " & _
				"OHCNFL = ?, " & _
				"OHCNDT = ? " & _
			"WHERE OHORNU = ? "
		Call DeleteAllParameters(cmd)
		cmd.ActiveConnection = conRefron
		cmd.CommandText = strSql
		cmd.NamedParameters = False
		cmd.Parameters.Append cmd.CreateParameter("ConfirmStatus", adChar, adParamInput, 1, "C")
		cmd.Parameters.Append cmd.CreateParameter("ConfirmDate", adInteger, adParamInput, , ConvertDate(CurrentDateTime, "PC", "MMDDYY"))
		cmd.Parameters.Append cmd.CreateParameter("OrderNumber", adInteger, adParamInput, , OrderNumber)
		
		On Error Resume Next
			cmd.Execute , , adExecuteNoRecords
		On Error GoTo 0

        dim strEmail1

        strEmail1 = trim(FixFaxNumber(trim(rsOrder("ConfirmationFaxNumber")))) & "@efaxsend.com"        
        if strEmail1 = "" Then
            strEmail1 = "NONE"
        End If

        dim url 
        url = "http://intranet.refron.com/Print_Processing/email.aspx?&reportName=Order+Confirmation&reportFolder=RIS+Website+Reports&OrderNum=" & OrderNumber & "&ToEmail=" & strEmail1
      
        response.write("<script>")
        response.write("window.open('" & url & "','OC1232');")
        response.write("</script>")
	End If

	rsOrderDetails.Close
	Set rsOrderDetails = Nothing

	If Not Session("DisplayName")="Joshua Craig" Then
        dim url3 
        url3 = "/apps/order_invoice_lookup/order.asp?ord=2&OrderID=" & OrderNumber
            
        response.write("<script>")
        response.write("window.open('" & url3 & "','_self');")
        response.write("</script>")
        ' response.write("<script>")
     '   response.write("window.open('" & url3 & "','TC9564');")
      '  response.write("</script>")


     ''   Dim dteWait
     '   dteWait = DateAdd("s", 10, Now())
     '   Do Until (Now() > dteWait)
     '   Loop


     '   response.write("<script>")
     '   response.write("window.close();")
      ' response.write("</script>")
	   ' Response.Redirect "/apps/order_invoice_lookup/order.asp?ord=2&OrderID=" & OrderNumber
	
	Else
	    Response.Write "<br>"
	    Response.Write " <a  href='/apps/order_invoice_lookup/order.asp?OrderID=" & OrderNumber & "'> Back to Order </a>"
	    Response.Write "<br>"
	
	End if 
End If
%>

<!--#include file="fax_routines.asp"-->