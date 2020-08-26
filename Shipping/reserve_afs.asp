<!--#include virtual="/shared/global/server_includes/global.asp"-->
<!--#include virtual="/shared/global/server_includes/date_time.asp"-->
<!--#include virtual="/shared/global/server_includes/error_check.asp"-->
<!--#include virtual="/shared/global/server_includes/formatting.asp"-->
<!--#include virtual="/shared/global/server_includes/timer.asp"-->
<!--#include virtual="/shared/global/server_includes/fax.asp"-->
<!--#include virtual="/shared/global/server_includes/encryption.asp"-->

<script language="JavaScript" type="text/javascript" >
function GetSelectedItem(orgzip,whse) {

chosen = ""
len = document.frmResv.WarehouseCode.length
strUrl = window.location.href

//alert(strUrl)
//alert(len)


    for (i = 0; i <len; i++) {
        if (document.frmResv.WarehouseCode[i].checked) {

            chosen = document.frmResv.WarehouseCode[i].value

            strUrl = strUrl.replace("apps/order/reserve_afs.asp","targetAPI/shipping/AFSRates.aspx")           
            
            if (strUrl.indexOf("origin=")!=-1 || strUrl.indexOf("whse=")!=-1 || strUrl.indexOf("whseindx=")!=-1)   {
                               
                strUrlArray = strUrl.split("&");
                         
                for (j=0; j<strUrlArray.length; j++) {
                    
                    if (strUrlArray[j].indexOf("origin=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"origin="+orgzip+"")                                         
                    } 
              
                     if (strUrlArray[j].indexOf("whse=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"whse="+whse+"")                                         
                    } 
                    
                    if (strUrlArray[j].indexOf("whseindx=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"whseindx="+i+"")                                         
                    }                                        
                }
            }
            else {
                    
            strUrl = strUrl.concat("&origin="+orgzip+"","&whse="+whse+"", "&whseindx="+i+"")
            
            }
            
            window.location.href = strUrl           

            //window.location.href='../../apps.net/shipping/afsrates.aspx?ordid='+orderid+'&origin='+orgzip+'&whse='+whse+'&whseindx='+i+''
            //window.open("../../apps.net/shipping/afsrates.aspx?ordid="+orderid+"&origin="+orgzip+"&whse="+whse+"&whseindx="+i+"")
            //window.open("../../apps.net/shipping/afsrates.aspx?ordid="+orderid+"&origin="+orgzip+"&whse="+whse+"", "AFSRates", "scrollbars=1,width=950,height=700")
             
            }
        }

    if (chosen == "") {
    alert("No Location Chosen")
    }
    
//alert(chosen) 

}

function GetSelectedItem2(orgzip,whse) {

chosen = ""
len = document.frmResv.WarehouseCode.length
strUrl = window.location.href

    for (i = 0; i <len; i++) {
        if (document.frmResv.WarehouseCode[i].checked) {

            chosen = document.frmResv.WarehouseCode[i].value
            strUrl = strUrl.replace("apps/order/reserve_afs.asp","targetAPI/shipping/AFS_Rates.aspx")           
            
            if (strUrl.indexOf("origin=")!=-1 || strUrl.indexOf("whse=")!=-1 || strUrl.indexOf("whseindx=")!=-1)   {
                               
                strUrlArray = strUrl.split("&");
                         
                for (j=0; j<strUrlArray.length; j++) {
                    
                    if (strUrlArray[j].indexOf("origin=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"origin="+orgzip+"")                                         
                    } 
              
                     if (strUrlArray[j].indexOf("whse=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"whse="+whse+"")                                         
                    } 
                    
                    if (strUrlArray[j].indexOf("whseindx=")!=-1) {                        
                        strUrl = strUrl.replace(strUrlArray[j],"whseindx="+i+"")                                         
                    }                                        
                }  

            }
            else {
               
            strUrl = strUrl.concat("&origin="+orgzip+"","&whse="+whse+"", "&whseindx="+i+"")
            
            }
            //alert(strUrl)                 
            window.location.href = strUrl           

            }
        }

    if (chosen == "") {
    alert("No Location Chosen")
    }
 
}

</script>

<%
Dim Page
Set Page = Server.CreateObject("RefronIntranetPage.WSC")
Page.Title = "Refron Intranet: Reserve Order"
Page.Titlebar = "Reserve Order"
Page.AddHeader("<script language=""JavaScript"" type=""text/javascript"" src=""/shared/global/client_scripts/expand_retract.js""></script>")
Page.AddHeader("<script language=""JavaScript"">this.window.name = 'Reserve" & Request.QueryString("OrderID") & "';</script>")
Page.PermissionOptions = "1061=10142"
Debug.Enabled = False

SetTimer("After Header")

Dim strType, strValue, strWhereClause
If Trim(Request.QueryString("OrderID")) <> "" Then
	If Not IsNumeric(StripNonAlphaNumericCharacters(Trim(Request.QueryString("OrderID")))) Then
		AddError("Invalid order number provided")
	Else
		strType = "Order"
		strValue = CDbl(StripNonAlphaNumericCharacters(Trim(Request.QueryString("OrderID"))))
		If Trim(Request.QueryString("OrderDate")) = "" Then
			strWhereClause = "WHERE OHORNU = " & strValue & " "
		Else
			If Not IsDate(Trim(Request.QueryString("OrderDate"))) Then
				AddError("Invalid order date provided")
			Else
				strWhereClause = "WHERE OHORNU = " & strValue & " AND OHODT8 = " & ConvertDate(Trim(Request.QueryString("OrderDate")), "PC", "CCYYMMDD") & " "
			End If
		End If
	End If
Else
	AddError("No order number provided")
End If

If Session("NumErrors") = 0 Then
	Dim rsOrder
	Set rsOrder = Server.CreateObject("ADODB.Recordset")
	strSql = _
		"SELECT " & _
			"CASE " & _
				"WHEN OHORNU IS NULL THEN NULL " & _
				"WHEN OHORNU = 0 THEN NULL " & _
				"WHEN LEN(OHORNU) = 7 THEN CAST(OHORNU AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 6 THEN CAST('0' + CAST(OHORNU AS CHAR(6)) AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 5 THEN CAST('00' + CAST(OHORNU AS CHAR(5)) AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 4 THEN CAST('000' + CAST(OHORNU AS CHAR(4)) AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 3 THEN CAST('0000' + CAST(OHORNU AS CHAR(3)) AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 2 THEN CAST('00000' + CAST(OHORNU AS CHAR(2)) AS CHAR(7)) " & _
				"WHEN LEN(OHORNU) = 1 THEN CAST('000000' + CAST(OHORNU AS CHAR(1)) AS CHAR(7)) " & _
				"ELSE NULL " & _
				"END AS OrderNumber, " & _
			"CASE " & _
				"WHEN LEN(OHODT8) = 8 THEN CAST(SUBSTRING(CAST(OHODT8 AS CHAR(8)), 5, 2) + '/' + SUBSTRING(CAST(OHODT8 AS CHAR(8)), 7, 2) + '/' + SUBSTRING(CAST(OHODT8 AS CHAR(8)), 1, 4) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS OrderDate, " & _
			"OHSTAT AS OrderStatusCode, " & _
			"CASE " & _
				"WHEN OHSTAT = 'C' THEN 'Closed' " & _
				"WHEN OHSTAT = 'I' THEN 'Invoiced' " & _
				"WHEN OHSTAT = 'H' THEN 'Invoice On Hold' " & _
				"WHEN OHSTAT = 'F' THEN 'Complete' " & _
				"WHEN OHSTAT = 'O' AND OHSHDT <> 0 THEN 'Shipped' " & _
				"WHEN OHSTAT = 'O' AND OHWHS <> '' THEN 'Reserved' " & _
				"WHEN OHSTAT = 'O' THEN 'Open' " & _
				"ELSE 'Unknown Status (' + OHSTAT + ')' " & _
				"END AS OrderStatus, " & _
			"CASE " & _
				"WHEN OHIVNU IS NULL THEN NULL " & _
				"WHEN OHIVNU = 0 THEN NULL " & _
				"WHEN LEN(OHIVNU) = 7 THEN CAST(OHIVNU AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 6 THEN CAST('0' + CAST(OHIVNU AS CHAR(6)) AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 5 THEN CAST('00' + CAST(OHIVNU AS CHAR(5)) AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 4 THEN CAST('000' + CAST(OHIVNU AS CHAR(4)) AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 3 THEN CAST('0000' + CAST(OHIVNU AS CHAR(3)) AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 2 THEN CAST('00000' + CAST(OHIVNU AS CHAR(2)) AS CHAR(7)) " & _
				"WHEN LEN(OHIVNU) = 1 THEN CAST('000000' + CAST(OHIVNU AS CHAR(1)) AS CHAR(7)) " & _
				"ELSE NULL " & _
				"END AS InvoiceNumber, " & _
			"CASE " & _
				"WHEN LEN(OHIVDT) = 6 THEN CAST(SUBSTRING(CAST(OHIVDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(6)), 5, 2) AS DATETIME) " & _
				"WHEN LEN(OHIVDT) = 5 THEN CAST(SUBSTRING(CAST(OHIVDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(5)), 4, 2) AS DATETIME) " & _
				"WHEN LEN(OHIVDT) = 4 THEN CAST(SUBSTRING(CAST(OHIVDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(4)), 3, 2) AS DATETIME) " & _
				"WHEN LEN(OHIVDT) = 3 THEN CAST(SUBSTRING(CAST(OHIVDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(3)), 2, 1) + '/' + SUBSTRING(CAST(OHIVDT AS CHAR(3)), 3, 1) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS InvoiceDate, " & _
			"CASE OHCNFL " & _
				"WHEN 'Y' THEN 'Yes' " & _
				"WHEN 'C' THEN 'Sent' " & _
				"ELSE 'No' " & _
				"END AS FaxConfirmationFlag, " & _
			"CASE " & _
				"WHEN LEN(OHCNDT) = 6 THEN CAST(SUBSTRING(CAST(OHCNDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(6)), 5, 2) AS DATETIME) " & _
				"WHEN LEN(OHCNDT) = 5 THEN CAST(SUBSTRING(CAST(OHCNDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(5)), 4, 2) AS DATETIME) " & _
				"WHEN LEN(OHCNDT) = 4 THEN CAST(SUBSTRING(CAST(OHCNDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(4)), 3, 2) AS DATETIME) " & _
				"WHEN LEN(OHCNDT) = 3 THEN CAST(SUBSTRING(CAST(OHCNDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(3)), 2, 1) + '/' + SUBSTRING(CAST(OHCNDT AS CHAR(3)), 3, 1) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS FaxConfirmationDate, " & _
			"LTRIM(RTRIM(OHCNFR)) AS FaxConfirmationNumber, " & _
			"LTRIM(RTRIM(ISNULL(Customer.CMPOST, ''))) AS PostToCode, " & _
			"LTRIM(RTRIM(ISNULL(Customer.CMRFCD, ''))) AS ReferenceCode, " & _
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
				"END AS ShipZip, " & _
			"LTRIM(RTRIM(ISNULL(Ordrhdr.OHCSCD, ''))) AS ShipToCode, " & _
			"LTRIM(RTRIM(ISNULL(Ordrhdr.OHPOST, ''))) AS BillToCode, " & _
			"CAST(ISNULL(BillTo.CMCRLM, 0) AS MONEY) AS BillToCreditLimit, " & _
			"CAST(ISNULL(BillTo.CMARCU, 0) AS MONEY) AS BillToCurrentBalance, " & _
			"CAST(OHDISC/100 AS FLOAT) AS DiscountPercent, " & _
			"LTRIM(RTRIM(OHIVLN)) AS InvoiceFirstLine, " & _
			"LTRIM(RTRIM(OHLSLN)) AS InvoiceLastLine, " & _
			"LTRIM(RTRIM(OHCLBY)) AS CalledInByName, " & _
			"LTRIM(RTRIM(OHPHON)) AS CalledInByPhone, " & _
			"LTRIM(RTRIM(OHDLVY)) AS DeliverByDate, " & _
			"LTRIM(RTRIM(OHPO#)) AS PurchaseOrderNumber, " & _
			"LTRIM(RTRIM(OHRLS)) AS ReleaseNumber, " & _
			"LTRIM(RTRIM(OHSPIN)) AS ShippingInstructions, " & _
			"LTRIM(RTRIM(OHBLIN)) AS BillingInstructions, " & _
			"LTRIM(RTRIM(OHISTC)) AS InvoiceSubTransactionCode, " & _
			"CAST(OHTYP# AS INTEGER) AS InvoiceType, " & _
			"LTRIM(RTRIM(OHSLMN)) AS SalespersonCode, " & _
			"LTRIM(RTRIM(ISNULL(Salesperson.UMNAME, 'Unknown User'))) AS SalespersonName, " & _
			"LTRIM(RTRIM(OHENBY)) AS EnteredByCode, " & _
			"LTRIM(RTRIM(ISNULL(EnteredBy.UMNAME, 'Unknown User'))) AS EnteredByName, " & _
			"LTRIM(RTRIM(OHWHS)) AS ReserveWarehouseCode, " & _
			"LTRIM(RTRIM(ReserveWarehouse.CMCSNM)) AS ReserveWarehouseName, " & _
			"LTRIM(RTRIM(ReserveWarehouse.CMCITY)) AS ReserveWarehouseCity, " & _
			"LTRIM(RTRIM(ReserveWarehouse.CMST)) AS ReserveWarehouseState, " & _
			"LTRIM(RTRIM(OHTXWH)) AS TransmitWarehouseCode, " & _
			"LTRIM(RTRIM(TransmitWarehouse.CMCSNM)) AS TransmitWarehouseName, " & _
			"LTRIM(RTRIM(TransmitWarehouse.CMCITY)) AS TransmitWarehouseCity, " & _
			"LTRIM(RTRIM(TransmitWarehouse.CMST)) AS TransmitWarehouseState, " & _
			"CASE OHTXST " & _
				"WHEN 'F' THEN 'Faxed' " & _
				"WHEN '' THEN 'Not Faxed' " & _
				"ELSE OHTXST " & _
			"END AS TransmitStatus, " & _
			"LTRIM(RTRIM(OHTXBY)) AS TransmitByCode, " & _
			"LTRIM(RTRIM(ISNULL(TransmitBy.UMNAME, 'Unknown User'))) AS TransmitByName, " & _
			"CASE " & _
				"WHEN LEN(OHTXDT) = 6 THEN SUBSTRING(CAST(OHTXDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(6)), 5, 2) + ' ' + " & _
					"CASE LEN(OHTXTM) " & _
						"WHEN 3 THEN SUBSTRING(CAST(OHTXTM AS CHAR(3)), 1, 1) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(3)), 2, 2) " & _
						"WHEN 4 THEN SUBSTRING(CAST(OHTXTM AS CHAR(4)), 1, 2) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(4)), 3, 2) " & _
						"ELSE '' " & _
					"END " & _
				"WHEN LEN(OHTXDT) = 5 THEN CAST(SUBSTRING(CAST(OHTXDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(5)), 4, 2) + ' ' + " & _
					"CASE LEN(OHTXTM) " & _
						"WHEN 3 THEN SUBSTRING(CAST(OHTXTM AS CHAR(3)), 1, 1) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(3)), 2, 2) " & _
						"WHEN 4 THEN SUBSTRING(CAST(OHTXTM AS CHAR(4)), 1, 2) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(4)), 3, 2) " & _
						"ELSE '' " & _
					"END AS DATETIME) " & _
				"WHEN LEN(OHTXDT) = 4 THEN CAST(SUBSTRING(CAST(OHTXDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(4)), 3, 2) + ' ' + " & _
					"CASE LEN(OHTXTM) " & _
						"WHEN 3 THEN SUBSTRING(CAST(OHTXTM AS CHAR(3)), 1, 1) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(3)), 2, 2) " & _
						"WHEN 4 THEN SUBSTRING(CAST(OHTXTM AS CHAR(4)), 1, 2) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(4)), 3, 2) " & _
						"ELSE '' " & _
					"END AS DATETIME) " & _
				"WHEN LEN(OHTXDT) = 3 THEN CAST(SUBSTRING(CAST(OHTXDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(3)), 2, 1) + '/' + SUBSTRING(CAST(OHTXDT AS CHAR(3)), 3, 1) + ' ' + " & _
					"CASE LEN(OHTXTM) " & _
						"WHEN 3 THEN SUBSTRING(CAST(OHTXTM AS CHAR(3)), 1, 1) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(3)), 2, 2) " & _
						"WHEN 4 THEN SUBSTRING(CAST(OHTXTM AS CHAR(4)), 1, 2) + ':' + SUBSTRING(CAST(OHTXTM AS CHAR(4)), 3, 2) " & _
						"ELSE '' " & _
					"END AS DATETIME) " & _
				"ELSE NULL " & _
			"END AS TransmitDateTime, " & _
			"CASE " & _
				"WHEN LEN(OHRVDT) = 8 THEN CAST(SUBSTRING(CAST(OHRVDT AS CHAR(8)), 5, 2) + '/' + SUBSTRING(CAST(OHRVDT AS CHAR(8)), 7, 2) + '/' + SUBSTRING(CAST(OHRVDT AS CHAR(8)), 1, 4) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS ReserveDate, " & _
			"CASE " & _
				"WHEN LEN(OHFPDT) = 6 THEN CAST(SUBSTRING(CAST(OHFPDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(6)), 5, 2) AS DATETIME) " & _
				"WHEN LEN(OHFPDT) = 5 THEN CAST(SUBSTRING(CAST(OHFPDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(5)), 4, 2) AS DATETIME) " & _
				"WHEN LEN(OHFPDT) = 4 THEN CAST(SUBSTRING(CAST(OHFPDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(4)), 3, 2) AS DATETIME) " & _
				"WHEN LEN(OHFPDT) = 3 THEN CAST(SUBSTRING(CAST(OHFPDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(3)), 2, 1) + '/' + SUBSTRING(CAST(OHFPDT AS CHAR(3)), 3, 1) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS FinalProcessingDate, " & _
			"LTRIM(RTRIM(OHBLBY)) AS BilledByCode, " & _
			"LTRIM(RTRIM(ISNULL(BilledBy.UMNAME, 'Unknown User'))) AS BilledByName, " & _
			"CAST(OHTOT$ AS MONEY) AS OrderTotalAmount, " & _
			"CASE " & _
				"WHEN LEN(OHSHDT) = 6 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(6)), 1, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(6)), 5, 2) AS DATETIME) " & _
				"WHEN LEN(OHSHDT) = 5 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(5)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(5)), 4, 2) AS DATETIME) " & _
				"WHEN LEN(OHSHDT) = 4 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(4)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(4)), 2, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(4)), 3, 2) AS DATETIME) " & _
				"WHEN LEN(OHSHDT) = 3 THEN CAST(SUBSTRING(CAST(OHSHDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHSHDT AS CHAR(3)), 2, 1) + '/0' + SUBSTRING(CAST(OHSHDT AS CHAR(3)), 3, 1) AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS ShipDate, " & _
			"LTRIM(RTRIM(OHBL#)) AS BillOfLadingNumber, " & _
			"CASE " & _
				"WHEN LEN(OHBLDT) = 6 THEN CAST(SUBSTRING(CAST(OHBLDT AS CHAR(6)), 3, 2) + '/' + SUBSTRING(CAST(OHBLDT AS CHAR(6)), 5, 2) + '/' + SUBSTRING(CAST(OHBLDT AS CHAR(6)), 1, 2) AS DATETIME) " & _
				"WHEN LEN(OHBLDT) = 5 THEN CAST(SUBSTRING(CAST(OHBLDT AS CHAR(5)), 2, 2) + '/' + SUBSTRING(CAST(OHBLDT AS CHAR(5)), 4, 2) + '/0' + SUBSTRING(CAST(OHBLDT AS CHAR(5)), 1, 1) AS DATETIME) " & _
				"WHEN LEN(OHBLDT) = 4 THEN CAST(SUBSTRING(CAST(OHBLDT AS CHAR(4)), 1, 2) + '/' + SUBSTRING(CAST(OHBLDT AS CHAR(4)), 3, 2) + '/00' AS DATETIME) " & _
				"WHEN LEN(OHBLDT) = 3 THEN CAST(SUBSTRING(CAST(OHBLDT AS CHAR(3)), 1, 1) + '/' + SUBSTRING(CAST(OHBLDT AS CHAR(3)), 2, 2) + '/00' AS DATETIME) " & _
				"ELSE NULL " & _
				"END AS BillOfLadingDate, " & _
			"LTRIM(RTRIM(OHWHRC)) AS WarehouseReceipt, " & _
			"LTRIM(RTRIM(OHTERM)) AS InvoiceTermsCode, " & _
			"LTRIM(RTRIM(InvoiceTerms.TRDESC)) AS InvoiceTermsDescription, " & _
			"CAST(ISNULL(InvoiceTerms.TRDSDY, 0) AS INTEGER) AS InvoiceTermsDays, " & _
			"LTRIM(RTRIM(BillTo.CMTERM)) AS AccountTermsCode, " & _
			"LTRIM(RTRIM(AccountTerms.TRDESC)) AS AccountTermsDescription, " & _
			"CAST(ISNULL(AccountTerms.TRDSDY, 0) AS INTEGER) AS AccountTermsDays, " & _
			"LTRIM(RTRIM(OHNTXC)) AS TaxCode, " & _
			"LTRIM(RTRIM(TXDSCR)) AS TaxDescription, " & _
			"ISNULL(LTRIM(RTRIM(TechCert.CQCODE)), '') AS TechCertCode, " & _
			"ISNULL(LTRIM(RTRIM(TechCert.CQDESC)), '') AS TechCertDesc, " & _
			"ISNULL(LTRIM(RTRIM(OtherTechCertAccount.CMCSCD)), '') AS OtherTechCertAccountCode, " & _
			"ISNULL(LTRIM(RTRIM(OtherTechCertAccount.CMTCFL)), '') AS OtherTechCertCode, " & _
			"ISNULL(LTRIM(RTRIM(OtherTechCert.CQDESC)), '') AS OtherTechCertDesc, " & _
			"ISNULL(LTRIM(RTRIM(CreditStatus.CGDESC)), '') AS CreditStatusDesc, " & _
			"ISNULL(LTRIM(RTRIM(CreditStatus.CGTEXT)), '') AS CreditStatusAlertText, " & _
			"CAST(ISNULL((BillTo.CMARTO + (SELECT COALESCE(SUM(OHTOT$),0) AS OHOPOR FROM ORDRHDR WHERE (OHSTAT = 'I' OR OHSTAT = 'H') AND OHPOST = Customer.CMPOST) + OrderSum.OHESAM - BillTo.CMARCR), 0) AS INTEGER) AS BillARTotal, " & _
			"CAST(BillTo.CMCRLM AS INTEGER) AS CreditLimit " & _
		"FROM ORDRHDR AS Ordrhdr " & _
			"LEFT JOIN CUSTMST AS Customer ON OHCSCD = Customer.CMCSCD AND OHCSCD <> '' " & _
			"LEFT JOIN CUSTMST AS BillTo ON OHPOST = BillTo.CMCSCD AND OHPOST <> '' " & _
			"LEFT JOIN CUSTMST AS ReserveWarehouse ON OHWHS = ReserveWarehouse.CMCSCD AND OHWHS <> '' " & _
			"LEFT JOIN CUSTMST AS TransmitWarehouse ON OHTXWH = TransmitWarehouse.CMCSCD AND OHTXWH <> '' " & _
			"LEFT JOIN USERMST AS Salesperson ON OHSLMN = Salesperson.UMSLMN AND OHSLMN <> '' " & _
			"LEFT JOIN USERMST AS EnteredBy ON OHENBY = EnteredBy.UMUSCD AND OHENBY <> '' " & _
			"LEFT JOIN USERMST AS TransmitBy ON OHTXBY = TransmitBy.UMUSCD AND OHTXBY <> '' " & _
			"LEFT JOIN USERMST AS BilledBy ON OHBLBY = BilledBy.UMUSCD AND OHBLBY <> '' " & _
			"LEFT JOIN TERMSMST AS InvoiceTerms ON OHTERM = InvoiceTerms.TRCODE AND OHTERM <> '' " & _
			"LEFT JOIN TERMSMST AS AccountTerms ON BillTo.CMTERM = AccountTerms.TRCODE AND BillTo.CMTERM <> '' " & _
			"LEFT JOIN TAXCDMST ON OHNTXC = TXCD AND OHNTXC <> '' " & _
			"LEFT JOIN CERTPMST AS TechCert ON Customer.CMTCFL = TechCert.CQCODE " & _
			"LEFT JOIN CUSTMST AS OtherTechCertAccount ON Customer.CMTCCD = OtherTechCertAccount.CMCSCD " & _
				"AND Customer.CMTCCD <> Customer.CMCSCD " & _
				"AND Customer.CMTCCD <> '' " & _
				"AND Customer.CMTCFL <> OtherTechCertAccount.CMTCFL " & _
			"LEFT JOIN CERTPMST AS OtherTechCert ON OtherTechCertAccount.CMTCFL = OtherTechCert.CQCODE " & _
			"LEFT JOIN CREDTMST AS CreditStatus ON ISNULL(Customer.CMCRCD, BillTo.CMCRCD) = CreditStatus.CGCODE " & _
			"LEFT JOIN (" & _
				"SELECT " & _
					"OHPOST, " & _
					"SUM(OHESAM) AS OHESAM " & _
				"FROM ORDRHDR " & _
				"WHERE OHSTAT = 'O' "
			If strValue <> "" Then
				strSql = strSql & _
					"AND OHORNU <> " & strValue & " "
			End If
			strSql = strSql & _
				"GROUP BY OHPOST " & _
				") AS OrderSum ON Customer.CMPOST = OrderSum.OHPOST " & _
		strWhereClause
	'Response.Write strSql
	rsOrder.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	If rsOrder.EOF Then
		AddError("Order or invoice not found.")
		rsOrder.Close
		Set rsOrder = Nothing
	Else
		Dim ReadOnly
		If rsOrder("OrderStatus") = "Open" Then
			ReadOnly = False
		Else
			ReadOnly = True
		End If
		Debug.Print "ReadOnly", ReadOnly
	End If
End If

If Session("NumErrors") > 0 Then
	Response.Redirect("home.asp?SearchText=" & Request.QueryString("OrderID") & Request.QueryString("InvoiceID") & "&CheckOrderNumber=Yes&CheckInvoiceNumber=Yes&CheckAccountCode=Yes&CheckCompanyName=Yes&SearchType=BeginsWith&StatusOpen=Yes&StatusReserved=Yes&StatusShipped=Yes&StatusInvoiced=Yes&DateRange=12Months&Salesperson=&Warehouse=&SortBy=OrderNumber&SortDir=DESC&MoreOptions=N")
	Response.End
End If

SetTimer("After Main Query")

Page.PrintHeader()
Page.PrintFramework()
%>

<!--<%If Session("DisplayName")="Joshua Craig" Or Session("DisplayName")="Lisa Stanco" Then 

If Not ReadOnly Then
	%>
<div>	<br/>
	&nbsp;&nbsp;&nbsp;
 <a   style="color:blue; text-decoration:underline;" href="/apps/order_invoice_lookup/order.asp?OrderID=<%=rsOrder("OrderNumber")%>&no_afs=yes" <%If ReturnOption(1061) <> 10142 Or rsOrder("OrderStatusCode") <> "O" Then Response.Write "disabled"%> onclick="JavaScript: if(this.disabled==true){return false;}"> Turn Off AFS Rater </a>
	<br/></div>
	<% End If
End If
%>-->

<br>

<table>
	<col width="40%" style="text-align:left; vertical-align:middle;">
	<col width="20%" style="text-align:center; vertical-align:middle;">
	<col width="40%" style="text-align:right; vertical-align:middle;">
	<thead>
		<tr>
			<%
			Dim StatusStyle
			Select Case rsOrder("OrderStatus")
				Case "Open", "Reserved", "Shipped"
					StatusStyle = "style=""background-color:lightgreen;"""
				Case "Invoiced", "Invoice On Hold"
					StatusStyle = "style=""background-color:#e43117;"""
				Case "Closed", "Complete"
					StatusStyle = ""
				Case Else
					StatusStyle = ""
			End Select
			%>
			<th nowrap <%=StatusStyle%>>
				<%
				If Not IsNull(rsOrder("OrderNumber")) Then
					Response.Write "Order # <span style=""font-size:20px; vertical-align:middle;"">" & Left(rsOrder("OrderNumber"), 6) & "-" & Right(rsOrder("OrderNumber"), 1) & "</span>"
				End If
				If Not IsNull(rsOrder("OrderDate")) Then
					Response.Write " (" & ShortDate(rsOrder("OrderDate")) & ")"
				End If
				%>
			</th>
			<th <%=StatusStyle%>>
				<%
				Response.Write "<span style=""font-size:20px; vertical-align:middle;"">" & rsOrder("OrderStatus") & "</span>"
				If Not IsNull(rsOrder("FinalProcessingDate")) Then
					Response.Write "&nbsp;(" & ShortDate(rsOrder("FinalProcessingDate")) & ")"
				End If
				%>
			</th>
			<th nowrap <%=StatusStyle%>>
				<%
				If Not IsNull(rsOrder("InvoiceNumber")) Then
					Response.Write "Invoice # <span style=""font-size:20px; vertical-align:middle;"">" & Left(rsOrder("InvoiceNumber"), 6) & "-" & Right(rsOrder("InvoiceNumber"), 1) & "</span>"
				End If
				If Not IsNull(rsOrder("InvoiceDate")) Or rsOrder("InvoiceSubTransactionCode") <> "" Or rsOrder("InvoiceType") <> "0" Then
					If Not IsNull(rsOrder("InvoiceDate")) Then
						Response.Write " (" & ShortDate(rsOrder("InvoiceDate")) & ")"
					End If
						'If rsOrder("InvoiceSubTransactionCode") <> "" Or rsOrder("InvoiceType") <> "0" Then
						'	Response.Write " - "
						'End If
						'Response.Write rsOrder("InvoiceSubTransactionCode") & rsOrder("InvoiceType")
				End If
				%>
			</th>
		</tr>
	</thead>
	<!--	<tbody>		<tr>			<td colspan="3" style="padding:0px;">				<table style="margin:0px; width:100%; border:none;">					<tr>						<td style="border:none;">							<a href="move.asp?OrderNumber=<%=rsOrder("OrderNumber")%>&OrderDate=<%=Server.URLEncode(rsOrder("OrderDate"))%>&AccountCode=<%=Server.URLEncode(rsOrder("ShipToCode"))%>&Direction=Previous"><< Prev</a>						</td>						<td style="border:none; text-align:center;">							<a href="/apps/order/home.asp?Table=C&OrderNumber=<%=rsOrder("OrderNumber")%>&ReturnURL=<%=Server.URLEncode(Request.ServerVariables("URL") & "?" & Request.ServerVariables("QUERY_STRING"))%>" <%If rsOrder("OrderStatusCode") <> "O" Then Response.Write "disabled"%> onclick="JavaScript: if(this.disabled==true){return false;}">Edit</a>							| <a href="/apps/order/reserve.asp?OrderNumber=<%=rsOrder("OrderNumber")%>" <%If Session("UserCode") <> "BM" Then Response.Write "disabled"%> onclick="JavaScript: if(this.disabled==true){return false;}">Reserve</a>							| <a href="" disabled onclick="JavaScript: if(this.disabled==true){return false;}">Unreserve</a>							| <a href="" disabled onclick="JavaScript: if(this.disabled==true){return false;}">Copy</a>							| <a href="" disabled onclick="JavaScript: if(this.disabled==true){return false;}">Sequence</a>							| <a href="JavaScript: if(confirm('This feature is for use by the shipping department only.\nIf you did not mean to click on it, press the Cancel button.')){window.location.href='/apps/order/edit_order_number.asp?OldOrderNumber=<%=rsOrder("OrderNumber")%>';}else{};">Edit Order #</a>						</td>						<td style="border:none; text-align:right;">							<a href="move.asp?OrderNumber=<%=rsOrder("OrderNumber")%>&OrderDate=<%=Server.URLEncode(rsOrder("OrderDate"))%>&AccountCode=<%=Server.URLEncode(rsOrder("ShipToCode"))%>&Direction=Next">Next >></a>						</td>					</tr>				</table>			</td>		</tr>	</tbody>	-->
</table>

<br>

<table>
	<col style="width:115px;">
	<col width="50%">
	<col style="width:115px;">
	<col width="50%">
	<thead>
		<tr onclick="expandRetract('Address', Address_Image);" onmouseover="this.style.cursor='hand';">
			<th nowrap colspan="2"><img src="/shared/images/icons/retract.gif" id="Address_Image" align="absmiddle"> Shipping Information</th>
			<th nowrap colspan="2">Billing Information</th>
		</tr>
	</thead>
	<tbody id="Address">
		<tr>
			<td nowrap><b>Ship-To Code:</b></td>
			<td nowrap>
				<a target="_blank" href="/apps/company_info/customer_info.asp?CustomerCode=<%=Server.URLEncode(rsOrder("ShipToCode"))%>" style="color:blue; text-decoration:underline;"><%=Server.HTMLEncode(rsOrder("ShipToCode"))%></a>
			</td>
			<td nowrap><b>Bill-To Code:</b></td>
			<td nowrap><a target="_blank" href="/apps/company_info/customer_info.asp?CustomerCode=<%=Server.URLEncode(rsOrder("BillToCode"))%>" style="color:blue; text-decoration:underline;"><%=Server.HTMLEncode(rsOrder("BillToCode"))%></a></td>
		</tr>
		<tr>
			<td nowrap><b>Company Name:</b></td>
			<td nowrap><%=Server.HTMLEncode(rsOrder("ShipCompanyName"))%></td>
			<td nowrap><b>Company Name:</b></td>
			<td nowrap><%=Server.HTMLEncode(rsOrder("BillCompanyName"))%></td>
		</tr>
		<tr>
			<td nowrap valign="top"><b>Shipping Address:</b></td>
			<td nowrap valign="top">
				<%
				Response.Write Server.HTMLEncode(rsOrder("ShipAddress1"))
				If rsOrder("ShipAddress2") <> "" Then
					Response.Write "<br>" & Server.HTMLEncode(rsOrder("ShipAddress2"))
				End If
				If rsOrder("ShipCity") <> "" Or rsOrder("ShipState") <> "" Or rsOrder("ShipZip") <> "" Then
					Response.Write "<br>"
				End If
				If rsOrder("ShipCity") <> "" Then
					Response.Write Server.HTMLEncode(rsOrder("ShipCity"))
				End If
				If rsOrder("ShipState") <> "" Then
					Response.Write ", " & Server.HTMLEncode(rsOrder("ShipState"))
				End If
				If rsOrder("ShipZip") <> "" Then
					Response.Write " " & rsOrder("ShipZip")
				End If
				%>
			</td>
			<td nowrap valign="top"><b>Mail To Address:</b></td>
			<td nowrap valign="top">
				<%
				Response.Write Server.HTMLEncode(rsOrder("BillAddress1"))
				If rsOrder("BillAddress2") <> "" Then
					Response.Write "<br>" & Server.HTMLEncode(rsOrder("BillAddress2"))
				End If
				If rsOrder("BillCity") <> "" Or rsOrder("BillState") <> "" Or rsOrder("BillZip") <> "" Then
					Response.Write "<br>"
				End If
				If rsOrder("BillCity") <> "" Then
					Response.Write Server.HTMLEncode(rsOrder("BillCity"))
				End If
				If rsOrder("BillState") <> "" Then
					Response.Write ", " & Server.HTMLEncode(rsOrder("BillState"))
				End If
				If rsOrder("BillZip") <> "" Then
					Response.Write " " & rsOrder("BillZip")
				End If
				%>
			</td>
		</tr>
	</tbody>
</table>

<%="<script language=""JavaScript"">setMenus('Address');</script>"%>

<br>
	
<%
Dim rsCreditCards, TransactionTotal : TransactionTotal = 0
Set rsCreditCards = Server.CreateObject("ADODB.Recordset")
strSql = _
	"SELECT " & _
		"CreditCardID, " & _
		"CreditCardNumberEnc, " & _
		"CreditCardTypeName, " & _
		"CreditCardTransactionID, " & _
		"CreditCardTransactionAmount, " & _
		"CreditCardTransactionDateProcessed, " & _
		"CreditCardTransactionResponseCode, " & _
		"CreditCardResponseCodeName " & _
	"FROM CreditCardTransactions " & _
		"INNER JOIN CreditCards ON CreditCardTransactionCardID = CreditCardID " & _
		"INNER JOIN CreditCardTypes ON CreditCardType = CreditCardTypeID " & _
		"LEFT JOIN CreditCardResponseCodes ON CreditCardTransactionResponseCode = CreditCardResponseCodeID " & _
	"WHERE CreditCardTransactionOrderNumber = " & rsOrder("OrderNumber") & "; "
'Response.Write strSql
rsCreditCards.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
If Not rsCreditCards.EOF Then
	Response.Write "<div style=""margin-left:2.5%;"">Credit Card Transactions:<div style=""margin-left:15px;"">"
	Do While Not rsCreditCards.EOF
		If rsCreditCards("CreditCardTransactionResponseCode") = 1 Then
			TransactionTotal = TransactionTotal + rsCreditCards("CreditCardTransactionAmount")
		End If
		Select Case rsCreditCards("CreditCardTransactionResponseCode")
			Case 0
				Response.Write "<li><font color=""red"">" & FormatCurrency(rsCreditCards("CreditCardTransactionAmount"), 2, True, True, True) & " - " & rsCreditCards("CreditCardTypeName") & " ****" & Right(Decrypt(rsCreditCards("CreditCardNumberEnc")), 4) & " - " & rsCreditCards("CreditCardResponseCodeName") & "</font>"
			Case 1
				Response.Write "<li>" & rsCreditCards("CreditCardTransactionDateProcessed") & " - " & FormatCurrency(rsCreditCards("CreditCardTransactionAmount"), 2, True, True, True) & " - " & rsCreditCards("CreditCardTypeName") & " ****" & Right(Decrypt(rsCreditCards("CreditCardNumberEnc")), 4) & " - " & rsCreditCards("CreditCardResponseCodeName")
			Case Else
				Response.Write "<li><font color=""red"">" & rsCreditCards("CreditCardTransactionDateProcessed") & " - " & FormatCurrency(rsCreditCards("CreditCardTransactionAmount"), 2, True, True, True) & " - " & rsCreditCards("CreditCardTypeName") & " ****" & Right(Decrypt(rsCreditCards("CreditCardNumberEnc")), 4) & " - " & rsCreditCards("CreditCardResponseCodeName") & "</font>"
		End Select
		Response.Write " - <a href=""/apps/credit_cards/auth_form.asp?ID=" & rsCreditCards("CreditCardTransactionID") & """><img src=""/shared/images/icons/print.gif"" align=""absmiddle""></a> "
		rsCreditCards.MoveNext
	Loop
	If TransactionTotal > 0 And rsCreditCards.RecordCount > 1 Then
		Response.Write "<li>Total Approved Transactions: " & FormatCurrency(TransactionTotal, 2, True, True, True)
	End If
	Response.Write "</div></div><br>"
End If
rsCreditCards.Close
Set rsCreditCards = Nothing

If rsOrder("CreditStatusAlertText") <> "" Then
	AddError("Credit Status Alert: " & rsOrder("CreditStatusAlertText"))
End If

Dim ErrorMsg
ErrorMsg = ReturnErrorMsg()
If ErrorMsg <> "" Then
	%>
	<table style="border:none; margin-left:15px;">
		<tr>
			<td style="border:none; background-color:white;"><%=ErrorMsg%></td>
		</tr>
	</table>
	<br>
	<%
End If
%>

<table>
	<col style="width:115px;">
	<col width="50%">
	<col style="width:115px;">
	<col width="50%">
	<thead>
		<tr onclick="expandRetract('OtherInfo', OtherInfo_Image);" onmouseover="this.style.cursor='hand';">
			<th nowrap colspan="4"><img src="/shared/images/icons/retract.gif" id="OtherInfo_Image" align="absmiddle"> Other Information</th>
		</tr>
	</thead>
	<tbody id="OtherInfo">
		<tr>
			<td nowrap><b>Called In By:</b></td>
			<td nowrap><%=rsOrder("CalledInByName")%></td>
			<td nowrap><b>Phone Number:</b></td>
			<td nowrap><%=FormatPhone(rsOrder("CalledInByPhone"), "PPP-PPP-PPPP")%></td>
		</tr>
		<tr>
			<td nowrap><b>Purchase Order #:</b></td>
			<td nowrap><%=rsOrder("PurchaseOrderNumber")%></td>
			<td nowrap><b>Release Number:</b></td>
			<td nowrap><%=rsOrder("ReleaseNumber")%></td>
		</tr>
		<tr>
			<td nowrap><b>Deliver By Date:</b></td>
			<td nowrap><%=rsOrder("DeliverByDate")%></td>
			<td nowrap><b>Fax Confirmation?</b></td>
			<td nowrap>
				<%
				Response.Write rsOrder("FaxConfirmationFlag")
				If rsOrder("FaxConfirmationFlag") = "Sent" Then
					Response.Write " " & ShortDate(rsOrder("FaxConfirmationDate"))
				End If
				If rsOrder("FaxConfirmationFlag") <> "No" And rsOrder("FaxConfirmationNumber") <> "" Then
					Response.Write " - <b>Fax # </b>" & FormatPhone(rsOrder("FaxConfirmationNumber"), "PPP-PPP-PPPP")
				End If
				%>
			</td>
		</tr>
	</tbody>
</table>

<%="<script language=""JavaScript"">setMenus('OtherInfo');</script>"%>

<%
Dim SelectClause, FromClause
SelectClause = _
	"SELECT " & _
		"LTRIM(RTRIM(ODITEM)) AS ItemCode, " & _
		"CAST(ODQTOR AS FLOAT) AS ItemQuantity, " & _
		"LTRIM(RTRIM(ODWHS)) AS WarehouseCode, " & _
		"CASE " & _
			"WHEN ODALDS <> '' THEN LTRIM(RTRIM(ODALDS)) " & _
			"ELSE LTRIM(RTRIM(ITDSCR)) " & _
		"END AS ItemDescription, " & _
		"CAST(ITWGHT AS FLOAT) AS ItemWeight, " & _
		"CAST(ITGRWT AS FLOAT) AS ItemShipWeight, " & _
		"ITRQTC AS ItemTechCertReq, " & _
		"CASE " & _
			"WHEN NOT CustomerPrices.PRITEM IS NULL THEN " & _
				"CASE " & _
					"WHEN CustomerPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(ISNULL(CustomerPrices.PRPVPC, 0) AS FLOAT) " & _
					"WHEN CustomerPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(0 AS FLOAT) " & _
					"ELSE " & _
						"CAST(ISNULL(CustomerPrices.PRPRC1, 0) AS FLOAT) " & _
					"END " & _
			"WHEN NOT ReferencePrices.PRITEM IS NULL THEN " & _
				"CASE " & _
					"WHEN ReferencePrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(ISNULL(ReferencePrices.PRPVPC, 0) AS FLOAT) " & _
					"WHEN ReferencePrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(0 AS FLOAT) " & _
					"ELSE " & _
						"CAST(ISNULL(ReferencePrices.PRPRC1, 0) AS FLOAT) " & _
					"END " & _
			"WHEN NOT PostToPrices.PRITEM IS NULL THEN " & _
				"CASE " & _
					"WHEN PostToPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(ISNULL(PostToPrices.PRPVPC, 0) AS FLOAT) " & _
					"WHEN PostToPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
						"CAST(0 AS FLOAT) " & _
					"ELSE " & _
						"CAST(ISNULL(PostToPrices.PRPRC1, 0) AS FLOAT) " & _
					"END " & _
			"ELSE " & _
				"CAST(0 AS FLOAT) " & _
		"END AS ItemPrice, " & _
		"LTRIM(RTRIM(NetCostItemCode)) AS NetCostItemCode, " & _
		"CAST(ISNULL(NetCostAmount, 0) AS FLOAT) AS NetCostAmount, " & _
		"CASE NetCostUnitOfMeasure WHEN 'E' THEN 'each' ELSE 'lb.' END AS NetCostUnitOfMeasure, " & _
		"NetCostDate, " & _
		"CASE " & _
			"WHEN ODSTAT = 'O' THEN " & _
				"CASE " & _
					"WHEN NOT CustomerPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN CustomerPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE CustomerPrices.PRPVUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
							"WHEN CustomerPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"'/lb.' " & _
							"ELSE " & _
								"CASE CustomerPrices.PRCRUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
						"END " & _
					"WHEN NOT ReferencePrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN ReferencePrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE ReferencePrices.PRPVUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
							"WHEN ReferencePrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"'/lb.' " & _
							"ELSE " & _
								"CASE ReferencePrices.PRCRUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
						"END " & _
					"WHEN NOT PostToPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN PostToPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE PostToPrices.PRPVUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
							"WHEN PostToPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"'/lb.' " & _
							"ELSE " & _
								"CASE PostToPrices.PRCRUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
						"END " & _
					"ELSE " & _
						"'/lb.' " & _
				"END " & _
			"ELSE " & _
				"CASE ODPUM WHEN 'E' THEN ' each' ELSE '/lb.' END " & _
		"END AS UnitOfMeasure, " & _
		"CASE " & _
			"WHEN ODSTAT = 'O' THEN " & _
				"CASE " & _
					"WHEN NOT CustomerPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN CustomerPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(ISNULL(CustomerPrices.PRPVPC, 0) AS FLOAT) " & _
							"WHEN CustomerPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CAST(ISNULL(CustomerPrices.PRPRC1, 0) AS FLOAT) " & _
						"END " & _
					"WHEN NOT ReferencePrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN ReferencePrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(ISNULL(ReferencePrices.PRPVPC, 0) AS FLOAT) " & _
							"WHEN ReferencePrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CAST(ISNULL(ReferencePrices.PRPRC1, 0) AS FLOAT) " & _
						"END " & _
					"WHEN NOT PostToPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN PostToPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(ISNULL(PostToPrices.PRPVPC, 0) AS FLOAT) " & _
							"WHEN PostToPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CAST(ISNULL(PostToPrices.PRPRC1, 0) AS FLOAT) " & _
						"END " & _
					"ELSE " & _
						"CAST(0 AS FLOAT) " & _
				"END " & _
			"ELSE " & _
				"CAST(ISNULL(ODPRCU, 0) AS FLOAT) " & _
		"END AS PricePerUnitOfMeasure, " & _
		"CASE " & _
			"WHEN ODSTAT = 'O' THEN " & _
				"CASE " & _
					"WHEN NOT CustomerPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN CustomerPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE CustomerPrices.PRPVUM " & _
									"WHEN 'E' THEN CAST(ISNULL(CustomerPrices.PRPVPC, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(CustomerPrices.PRPVPC, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
							"WHEN CustomerPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CASE CustomerPrices.PRCRUM " & _
									"WHEN 'E' THEN CAST(ISNULL(CustomerPrices.PRPRC1, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(CustomerPrices.PRPRC1, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
						"END " & _
					"WHEN NOT ReferencePrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN ReferencePrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE ReferencePrices.PRPVUM " & _
									"WHEN 'E' THEN CAST(ISNULL(ReferencePrices.PRPVPC, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(ReferencePrices.PRPVPC, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
							"WHEN ReferencePrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CASE ReferencePrices.PRCRUM " & _
									"WHEN 'E' THEN CAST(ISNULL(ReferencePrices.PRPRC1, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(ReferencePrices.PRPRC1, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
						"END " & _
					"WHEN NOT PostToPrices.PRITEM IS NULL THEN " & _
						"CASE " & _
							"WHEN PostToPrices.PRCRD8 > " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CASE PostToPrices.PRPVUM " & _
									"WHEN 'E' THEN CAST(ISNULL(PostToPrices.PRPVPC, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(PostToPrices.PRPVPC, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
							"WHEN PostToPrices.PRCED8 < " & ConvertDate(Date(), "PC", "CCYYMMDD") & " THEN " & _
								"CAST(0 AS FLOAT) " & _
							"ELSE " & _
								"CASE PostToPrices.PRCRUM " & _
									"WHEN 'E' THEN CAST(ISNULL(PostToPrices.PRPRC1, 0) * ODQTOR AS FLOAT) " & _
									"ELSE CAST(ISNULL(PostToPrices.PRPRC1, 0) * ODQTOR * ITWGHT AS FLOAT) " & _
								"END "& _
						"END " & _
					"ELSE " & _
						"CAST(0 AS FLOAT) " & _
				"END " & _
			"ELSE " & _
				"CAST(ISNULL(ODEXT, 0) AS FLOAT) " & _
		"END AS ExtendedPrice "
FromClause = _
	"FROM ORDRDTL " & _
		"LEFT JOIN ITEMMST ON ODITEM = ITITEM " & _
		"LEFT JOIN PRCHIST AS CustomerPrices ON ITITEM = CustomerPrices.PRITEM " & _
			"AND CustomerPrices.PRRCTP <> 'C' " & _
			"AND CustomerPrices.PRCSCD = '" & Replace(rsOrder("ShipToCode"), "'", "''") & "' " & _
		"LEFT JOIN PRCHIST AS ReferencePrices ON ITITEM = ReferencePrices.PRITEM " & _
			"AND ReferencePrices.PRRCTP <> 'C' " & _
			"AND ReferencePrices.PRCSCD = '" & Replace(rsOrder("ReferenceCode"), "'", "''") & "' " & _
		"LEFT JOIN PRCHIST AS PostToPrices ON ITITEM = PostToPrices.PRITEM " & _
			"AND PostToPrices.PRRCTP <> 'C' " & _
			"AND PostToPrices.PRCSCD = '" & Replace(rsOrder("PostToCode"), "'", "''") & "' " & _
					"LEFT JOIN ( " & _
						"SELECT " & _
							"NCITEM AS NetCostItemCode, " & _
							"NCUM AS NetCostUnitOfMeasure, " & _
							"(NCNETT * 1.2) AS NetCostAmount, " & _
							"CASE WHEN LEN(CAST(NCYMD AS VARCHAR)) = 6 THEN CAST((CAST(NCCC AS VARCHAR) + CAST(NCYMD AS VARCHAR)) AS INTEGER) ELSE CAST((CAST(NCCC AS VARCHAR) + '0' + CAST(NCYMD AS VARCHAR)) AS INTEGER) END AS NetCostDate " & _
						"FROM NETCOST " & _
							"INNER JOIN ( " & _
								"SELECT " & _
									"NCITEM AS MaxItem, " & _
									"MAX(CASE WHEN LEN(CAST(NCYMD AS VARCHAR)) = 6 THEN CAST((CAST(NCCC AS VARCHAR) + CAST(NCYMD AS VARCHAR)) AS INTEGER) ELSE CAST((CAST(NCCC AS VARCHAR) + '0' + CAST(NCYMD AS VARCHAR)) AS INTEGER) END) AS MaxDate " & _
								"FROM NETCOST " & _
								"WHERE NCMFR = 'CO' " & _
								"GROUP BY NCITEM " & _
								") AS MaxNetCost ON NCITEM = MaxItem AND NCCC = CAST(SUBSTRING(CAST(MaxDate AS VARCHAR), 1, 2) AS INTEGER) AND NCYMD = CAST(SUBSTRING(CAST(MaxDate AS VARCHAR), 3, 6) AS INTEGER) " & _
						") AS NetCost ON ITITEM = NetCostItemCode " & _
		"LEFT JOIN CUSTMST AS Customer ON ODCSCD = Customer.CMCSCD AND ODCSCD <> '' " & _
		"LEFT JOIN ZCLATLON AS CustLoc ON CASE LEN(Customer.CMZIP) WHEN 5 THEN CAST(Customer.CMZIP AS CHAR) WHEN 4 THEN '0' + CAST(Customer.CMZIP AS CHAR) WHEN 3 THEN '00' + CAST(Customer.CMZIP AS CHAR) WHEN 2 THEN '000' + CAST(Customer.CMZIP AS CHAR) ELSE '' END = CustLoc.ZCODE "
Dim rsWarehouses
Set rsWarehouses = Server.CreateObject("ADODB.Recordset")

Dim WhsLat, WhsLon, CustLat, CustLon
WhsLat = "CAST(LEFT(WhsLoc.ZLAT, 2) + '.' + SUBSTRING(WhsLoc.ZLAT, 3, 4) AS FLOAT) * (PI() / 180)"
WhsLon = "CAST(LEFT(WhsLoc.ZLON, 3) + '.' + SUBSTRING(WhsLoc.ZLON, 4, 4) AS FLOAT) * -1 * (PI() / 180)"
CustLat = "CAST(LEFT(CustLoc.ZLAT, 2) + '.' + SUBSTRING(CustLoc.ZLAT, 3, 4) AS FLOAT) * (PI() / 180)"
CustLon = "CAST(LEFT(CustLoc.ZLON, 3) + '.' + SUBSTRING(CustLoc.ZLON, 4, 4) AS FLOAT) * -1 * (PI() / 180)"

strSql = _
	"SELECT " & _
		"LTRIM(RTRIM(WMWHS)) AS WarehouseCode, " & _
		"LTRIM(RTRIM(WMWHTR)) AS WarehouseTruck, " & _
		"CAST(WMRDUS AS FLOAT) AS WarehouseTruckRadius, " & _
		"LTRIM(RTRIM(CMCSNM)) AS WarehouseName, " & _
		"ISNULL(ACOS(COS(" & WhsLat & ") * COS(" & WhsLon & ") * COS(" & CustLat & ") * COS(" & CustLon & ") + COS(" & WhsLat & ") * SIN(" & WhsLon & ") * COS(" & CustLat & ") * SIN(" & CustLon & ") + SIN(" & WhsLat & ") * SIN(" & CustLat & ") * 0.999999999999999) * 3963.1, 0) AS WarehouseMiles, " & _
		"LTRIM(RTRIM(CMCSA1)) AS WarehouseAddress1, " & _
		"LTRIM(RTRIM(CMCSA2)) AS WarehouseAddress2, " & _
		"LTRIM(RTRIM(CMCITY)) AS WarehouseCity, " & _
		"LTRIM(RTRIM(CMST)) AS WarehouseState, " & _
		"CASE LEN(CMZIP) WHEN 5 THEN CAST(CMZIP AS CHAR) WHEN 4 THEN '0' + CAST(CMZIP AS CHAR) WHEN 3 THEN '00' + CAST(CMZIP AS CHAR) WHEN 2 THEN '000' + CAST(CMZIP AS CHAR) ELSE '' END AS WarehouseZip " & _
	"FROM WHSEMST " & _
		"LEFT JOIN CUSTMST ON WMWHS = CMCSCD " & _
		"LEFT JOIN ZCLATLON AS WhsLoc ON CASE LEN(CMZIP) WHEN 5 THEN CAST(CMZIP AS CHAR) WHEN 4 THEN '0' + CAST(CMZIP AS CHAR) WHEN 3 THEN '00' + CAST(CMZIP AS CHAR) WHEN 2 THEN '000' + CAST(CMZIP AS CHAR) ELSE '' END = WhsLoc.ZCODE " & _
		"LEFT JOIN ZCLATLON AS CustLoc ON '" & rsOrder("ShipZip") & "' = CustLoc.ZCODE " & _
	"WHERE WMWHS <> '' " & _
		"AND WMSTAT <> 'X' "

Dim strWhs
If rsOrder("ReserveWarehouseCode") <> "" Then
	strWhs = rsOrder("ReserveWarehouseCode") & ", " & Request.QueryString("Whs")
Else
	strWhs = Request.QueryString("Whs")
End If
If strWhs = "" Then
	strSql = "SELECT TOP 4 " & Mid(strSql, 8) & "ORDER BY WarehouseMiles "
Else
	Dim aryWhs, strExtraSql, strSql2, MaxWhs, i
	aryWhs = Split(strWhs, ", ")
	strExtraSql = "AND ("
	MaxWhs = 3
	If UBound(aryWhs) < 3 Then
		MaxWhs = UBound(aryWhs)
	End If
	For i = 0 To MaxWhs
		If i > 0 Then
			strExtraSql = strExtraSql & "OR "
		End If
		strExtraSql = strExtraSql & "WMWHS = '" & aryWhs(UBound(aryWhs) - i) & "' "
	Next
	strExtraSql = strExtraSql & ") "
	strSql = _
		"SELECT TOP 4 * FROM (" & _
		"SELECT 1 AS WarehouseSelected, " & _
		Mid(strSql, 8) & _
		Replace(Replace(strExtraSql, "=", "<>"), " OR ", " AND ") & _
		"UNION " & _
		"SELECT 0 AS WarehouseSelected, " & _
		Mid(strSql, 8) & _
		strExtraSql & _
		") AS Warehouses " & _
		"ORDER BY WarehouseSelected, WarehouseMiles "
End If

'Debug.Enabled = True
Debug.Print "SQL", strSql
'Debug.End
'Response.End

rsWarehouses.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
Dim NearestMiles : NearestMiles = 9999
Do While Not rsWarehouses.EOF
	If rsWarehouses("WarehouseMiles") < NearestMiles Then
		NearestMiles = rsWarehouses("WarehouseMiles")
	End If
	SelectClause = Trim(SelectClause) & ", " & _
		rsWarehouses("WarehouseMiles") & " AS Warehouse" & rsWarehouses("WarehouseCode") & "Miles, " & _
		"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "OnHand, " & _
		"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONOR AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "OnOrder, " & _
		"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICINTR AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "ToWarehouseInTransit, " & _
		"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthShipments, " & _
		"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthShipments, " & _
		"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 = 0 THEN 999 WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONOR) = 0 THEN 0 ELSE ((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12) END AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthPercent, " & _
		"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU = 0 THEN 999 WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONOR) = 0 THEN 0 ELSE ((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU) END AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthPercent, "
	If Trim(rsWarehouses("WarehouseCode")) = Trim(rsOrder("ReserveWarehouseCode")) Then
		SelectClause = SelectClause & _
			"(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + ODQTOR) AS Warehouse" & rsWarehouses("WarehouseCode") & "Available, " & _
			"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR AS INTEGER) - ODQTOR AS Warehouse" & rsWarehouses("WarehouseCode") & "CustomerOrders, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + ODQTOR) = 0 THEN 0 ELSE CAST(((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + ODQTOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12) * 365 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 * 365 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + ODQTOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR + ODQTOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU * 30 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysBefore, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU * 30 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysAfter "
	Else
		SelectClause = SelectClause & _
			"(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) AS Warehouse" & rsWarehouses("WarehouseCode") & "Available, " & _
			"CAST(Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR AS INTEGER) AS Warehouse" & rsWarehouses("WarehouseCode") & "CustomerOrders, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) = 0 THEN 0 ELSE CAST(((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12) * 365 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR - ODQTOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR - ODQTOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNW12 * 365 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU * 30 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysBefore, " & _
			"CASE WHEN Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU = 0 THEN NULL WHEN (Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR - ODQTOR) = 0 THEN 0 ELSE CAST((Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICONHN - Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICCSOR - ODQTOR) / Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICNWCU * 30 AS FLOAT) END AS Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysAfter "
	End If
	FromClause = FromClause & _
		"LEFT JOIN CUSTMST AS Warehouse" & rsWarehouses("WarehouseCode") & " ON Warehouse" & rsWarehouses("WarehouseCode") & ".CMCSCD = '" & rsWarehouses("WarehouseCode") & "' " & _
		"LEFT JOIN ZCLATLON AS Warehouse" & rsWarehouses("WarehouseCode") & "Location ON CASE LEN(Warehouse" & rsWarehouses("WarehouseCode") & ".CMZIP) WHEN 5 THEN CAST(Warehouse" & rsWarehouses("WarehouseCode") & ".CMZIP AS CHAR) WHEN 4 THEN '0' + CAST(Warehouse" & rsWarehouses("WarehouseCode") & ".CMZIP AS CHAR) WHEN 3 THEN '00' + CAST(Warehouse" & rsWarehouses("WarehouseCode") & ".CMZIP AS CHAR) WHEN 2 THEN '000' + CAST(Warehouse" & rsWarehouses("WarehouseCode") & ".CMZIP AS CHAR) ELSE '' END = Warehouse" & rsWarehouses("WarehouseCode") & "Location.ZCODE " & _
		"LEFT JOIN ITEMINV AS Warehouse" & rsWarehouses("WarehouseCode") & "Inventory ON Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICWHS = '" & rsWarehouses("WarehouseCode") & "' AND Warehouse" & rsWarehouses("WarehouseCode") & "Inventory.ICITEM = ODITEM "
	rsWarehouses.MoveNext
Loop
'rsWarehouses.Close
'Set rsWarehouses = Nothing
strSql = _
	SelectClause & _
	FromClause & _
	"WHERE ODORNU = " & rsOrder("OrderNumber") & " " & _
	"ORDER BY ODQTOR DESC, ODITEM "
    'response.Write("<br>" & strSQL & "<br>")
'Debug.Print "SQL", strSql
'Debug.End
Dim rsOrderDetails
Set rsOrderDetails = Server.CreateObject("ADODB.Recordset")

rsOrderDetails.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	
SetTimer("After Order Details Query")

			Dim ItemCost, ItemNetCost, ItemTotal
			Dim TechCertH : TechCertH = False
			Dim TechCertM : TechCertM = False
			Dim TechCertA : TechCertA = False
			Dim LastItemCode

Dim strItemList
Do While Not rsOrderDetails.EOF
	ItemCost = 0
	ItemNetCost = 0
	If rsOrderDetails("UnitOfMeasure") = " each" Then
		ItemCost = rsOrderDetails("ItemPrice")
	Else
		ItemCost = rsOrderDetails("ItemPrice") * rsOrderDetails("ItemWeight")
	End If
	If rsOrderDetails("NetCostUnitOfMeasure") = " each" Then
		ItemNetCost = rsOrderDetails("NetCostAmount")
	Else
		ItemNetCost = rsOrderDetails("NetCostAmount") * rsOrderDetails("ItemWeight")
	End If
	If ItemCost <> 0 Then
		ItemTotal = ItemTotal + (ItemCost * rsOrderDetails("ItemQuantity"))
	ElseIf ItemNetCost <> 0 Then
		ItemTotal = ItemTotal + (ItemNetCost * rsOrderDetails("ItemQuantity"))
	End If
	
	If rsOrderDetails("ItemQuantity") <> 0 Then
		Select Case rsOrderDetails("ItemTechCertReq")
			Case "H"
				TechCertH = True
				If rsOrder("BillToCode") <> "" _
					And rsOrder("TechCertCode") <> "H" _
					And rsOrder("TechCertCode") <> "B" _
					And rsOrder("OtherTechCertCode") <> "H" _
					And rsOrder("OtherTechCertCode") <> "B" Then
					AddError("A valid technician certification is required for " & rsOrderDetails("ItemCode"))
				End If
			Case "M"
				TechCertM = True
				If rsOrder("BillToCode") <> "" _
					And rsOrder("TechCertCode") <> "M" _
					And rsOrder("TechCertCode") <> "B" _
					And rsOrder("OtherTechCertCode") <> "M" _
					And rsOrder("OtherTechCertCode") <> "B" Then
					AddError("A valid technician certification is required for " & rsOrderDetails("ItemCode"))
				End If
			Case "A"
				TechCertA = True
				If rsOrder("BillToCode") <> "" _
					And rsOrder("TechCertCode") <> "H" _
					And rsOrder("TechCertCode") <> "M" _
					And rsOrder("TechCertCode") <> "B" _
					And rsOrder("OtherTechCertCode") <> "H" _
					And rsOrder("OtherTechCertCode") <> "M" _
					And rsOrder("OtherTechCertCode") <> "B" Then
					AddError("A valid technician certification is required for " & rsOrderDetails("ItemCode"))
				End If
			Case Else
				'Do nothing...no certification required?
		End Select
	End If
	strItemList = strItemList & " " & rsOrderDetails("ItemQuantity") & ":" & rsOrderDetails("ItemCode")
	rsOrderDetails.MoveNext
Loop
strItemList = Trim(strItemList)
rsOrderDetails.MoveFirst

Dim is_EmptyExist
Dim is_PalletExist

If InStr(strItemList,"EMPTY") > 0 Then
    is_EmptyExist = True
Else
    is_EmptyExist = false
End if     

If InStr(strItemList,"STPALLET") > 0 and InStr(strItemList,"-") > 0  Then
    is_PalletExist = True
Else
    is_PalletExist = false
End if 


If is_EmptyExist = True Or is_PalletExist = True Then 

    Dim rsEmptyDetails
    Dim strEmptySQL
    Dim is_EmptyLineItems
          
    strEmptySQL = " SELECT EmptyItem FROM ORDRDTL_Empty WHERE (EmptyItem IS NOT NULL OR EmptyItem <> ' ' OR ODITEM = 'STPALLET') AND ODORNU =" & Trim(Request.QueryString("OrderID")) & ""      
    
    Set rsEmptyDetails = Server.CreateObject("ADODB.Recordset")

    rsEmptyDetails.Open strEmptySQL, conRefron, adOpenStatic, adLockReadOnly, adCmdText    
    
   If rsEmptyDetails.recordcount > 0 Then 
        is_EmptyLineItems = True
   Else
        is_EmptyLineItems = false   
   End if 
  
End If

Dim TechCertRequirementFlag, TechCertRequirementCode
TechCertRequirementFlag = "Y"
TechCertRequirementCode = "N"

If TechCertH = True And TechCertM = True Then
	TechCertRequirementCode = "B"
	If rsOrder("TechCertCode") = "B" _
		Or rsOrder("OtherTechCertCode") = "B" Then
		TechCertRequirementFlag = "Y"
	Else
		TechCertRequirementFlag = "N"
	End If
ElseIf TechCertH = True And TechCertM = False Then
	TechCertRequirementCode = "H"
	If rsOrder("TechCertCode") = "H" Or rsOrder("TechCertCode") = "B" _
		Or rsOrder("OtherTechCertCode") = "H" Or rsOrder("OtherTechCertCode") = "B" Then
		TechCertRequirementFlag = "Y"
	Else
		TechCertRequirementFlag = "N"
	End If
ElseIf TechCertH = False And TechCertM = True Then
	TechCertRequirementCode = "M"
	If rsOrder("TechCertCode") = "M" Or rsOrder("TechCertCode") = "B" _
		Or rsOrder("OtherTechCertCode") = "M" Or rsOrder("OtherTechCertCode") = "B" Then
		TechCertRequirementFlag = "Y"
	Else
		TechCertRequirementFlag = "N"
	End If
ElseIf TechCertA = True Then
	TechCertRequirementCode = "A"
	If rsOrder("TechCertCode") = "H" Or rsOrder("TechCertCode") = "M" Or rsOrder("TechCertCode") = "B" _
		Or rsOrder("OtherTechCertCode") = "H" Or rsOrder("OtherTechCertCode") = "M" Or rsOrder("OtherTechCertCode") = "B" Then
		TechCertRequirementFlag = "Y"
	Else
		TechCertRequirementFlag = "N"
	End If
Else
	TechCertRequirementCode = "N"
	TechCertRequirementFlag = "Y"
End If
			
If rsOrder("CreditLimit") <> "" And rsOrder("CreditLimit") <> "0" Then
	If rsOrder("BillARTotal") > rsOrder("CreditLimit") Then
		AddError("Credit department approval is necessary.  With this order (estimated cost of approximately " & FormatCurrency(ItemTotal, 0, True, True, True) & ") the customer will exceed their credit limit by " & FormatCurrency(rsOrder("BillARTotal") + ItemTotal - rsOrder("CreditLimit"), 0, True, True, True))
	ElseIf (rsOrder("BillARTotal") + ItemTotal) > rsOrder("CreditLimit") Then
		AddError("Credit department approval is necessary.  With this order (" & FormatCurrency(ItemTotal, 0, True, True, True) & ") the customer will exceed their credit limit by " & FormatCurrency(rsOrder("BillARTotal") + ItemTotal - rsOrder("CreditLimit"), 0, True, True, True))
	End If
End If


'response.Write "is_EmptyExist " & is_EmptyExist & "<br/>"
'response.Write "is_PalletExist " & is_PalletExist & "<br/>"
'response.Write "is_EmptyLineItems " & is_EmptyLineItems & "<br/>"

If Not ReadOnly Then
	%>
	<br>
	&nbsp;&nbsp;&nbsp;
	<a target="_blank" href="/apps/check_inventory/home.asp?Zip=<%=rsOrder("ShipZip")%>&amp;Items=<%=strItemList%>&amp;ShowWhsLink=Y&amp;SortBy=WarehouseMiles&amp;SortDir=ASC" style="color:blue; text-decoration:underline;">Check Inventory - Find Alternate Warehouses</a>
	<br>
	
	<%  If is_EmptyExist or is_PalletExist Then %>
	
 	    <br>
	    &nbsp;&nbsp;&nbsp;
	    <a href="/apps.net/order/OrderEmptyItems.aspx?OrderID=<%=rsOrder("OrderNumber")%>&stat=<%=rsOrder("OrderStatus")%>" style="color:blue; text-decoration:underline;">Empties - Add/Edit Empties Information</a>
	
        <%  If is_EmptyExist and NOT is_EmptyLineItems Then %>
               
	            <div style="color:red; padding-left:15px;">
	            <li> There must be at least 1 "EMPTY" item description - before this order can be reserved </li>
	            </div>
                
         <%  ElseIf is_PalletExist and NOT is_EmptyExist and NOT is_EmptyLineItems Then %>
         
                <div style="color: red; padding-left: 15px;">
                    <li>The STPALLET item must be verified by clicking the "<strong>Empties - ...</strong>" link above - before this order can be reserved </li>
                </div>
                
            <% End If  %> 
  
        <% End If  %>       	
    <br>	
	<%
End If
%>

<br>
<table>
	<form name="frmResv" action="reserve_update.asp" method="post">
	<input type="hidden" name="OrderNumber" value="<%=rsOrder("OrderNumber")%>">
    <input type="hidden" name="DisplayName" value="<%=Session("DisplayName")%>">
	<thead>
		<tr>
			<th nowrap style="width:60px;">Quantity</th>
			<th nowrap style="width:80px;">Item Code</th>
			<%
			rsWarehouses.MoveFirst
			Dim WarehouseTitle
			Do While Not rsWarehouses.EOF
				WarehouseTitle = ""
				If rsWarehouses("WarehouseName") <> "" Then
					WarehouseTitle = rsWarehouses("WarehouseName")
				End If
				If rsWarehouses("WarehouseAddress1") <> "" Then
					WarehouseTitle = WarehouseTitle & vbNewLine & rsWarehouses("WarehouseAddress1")
				End If
				If rsWarehouses("WarehouseAddress2") <> "" Then
					WarehouseTitle = WarehouseTitle & vbNewLine & rsWarehouses("WarehouseAddress2")
				End If
				WarehouseTitle = WarehouseTitle & vbNewLine & rsWarehouses("WarehouseCity") & ", " & rsWarehouses("WarehouseState") & " " & rsWarehouses("WarehouseZip")
				%>
				<th nowrap align="left" title="<%=WarehouseTitle%>" onmouseover="this.style.cursor='hand';" style="border-left:1px solid black;">
					<%
					Dim StocksAllItems
					If rsOrderDetails.EOF Then
						StocksAllItems = False
					Else
						StocksAllItems = True
						Do While Not rsOrderDetails.EOF
							If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnHand")) And rsOrderDetails("ItemQuantity") > 0 Then
								StocksAllItems = False
							End If
							rsOrderDetails.MoveNext
						Loop
						rsOrderDetails.MoveFirst
					End If
					If ReadOnly Then
						Response.Write "<input type=""radio"" name=""WarehouseCode"" value=""" & rsWarehouses("WarehouseCode") & """"
						If rsWarehouses("WarehouseCode") = rsOrder("ReserveWarehouseCode") Then
							Response.Write " checked>"
						Else
							Response.Write " disabled>"
						End If
					ElseIf StocksAllItems Then
					
						Response.Write "<input type=""radio"" name=""WarehouseCode"" id=""" & rsWarehouses("WarehouseCode") & """ value=""" & rsWarehouses("WarehouseCode") & """"
						'If rsWarehouses.AbsolutePosition = 1 Then Response.Write " checked"
					If  Request.QueryString("whse") =  rsWarehouses("WarehouseCode") Then Response.Write " checked "
                        'If Session("DisplayName")<>"Joshua Craig" Then							
						    Response.Write " onClick ='GetSelectedItem(""" & trim(rsWarehouses("WarehouseZip")) & """,""" & rsWarehouses("WarehouseCode") & """)' >"

                        'ElseIf Session("DisplayName")="Joshua Craig" Then					    
						'    Response.Write " onClick ='GetSelectedItem2(""" & trim(rsWarehouses("WarehouseZip")) & """,""" & rsWarehouses("WarehouseCode") & """)' >"
                        'End if

					        Else 
						        Response.Write "<input disabled type=""radio"" name=""WarehouseCode"" value=""" & rsWarehouses("WarehouseCode") & """"
						        'If rsWarehouses.AbsolutePosition = 1 Then Response.Write " checked"
						        Response.Write ">"
					        End If
					        
                       'End if
					
					Response.Write "<a target=""_blank"" href=""/apps/company_info/customer_info.asp?CustomerCode=" & rsWarehouses("WarehouseCode") & """ style=""color:blue; text-decoration:underline;"">" & rsWarehouses("WarehouseCode") & "</a>&nbsp;&nbsp;("
					
					Dim GreenLimit, OrangeLimit
					If NearestMiles + 100 > NearestMiles * 1.25 Then
						GreenLimit = NearestMiles + 100
					Else
						GreenLimit = NearestMiles * 1.25
					End If
					If NearestMiles + 200 > NearestMiles * 1.5 Then
						OrangeLimit = NearestMiles + 200
					Else
						OrangeLimit = NearestMiles * 1.5
					End If
					If rsWarehouses("WarehouseMiles") > OrangeLimit Then
						Response.Write "<font color=""red"">" & FormatNumber(rsWarehouses("WarehouseMiles"), 0, True, True, True) & " miles</font>"
					ElseIf rsWarehouses("WarehouseMiles") > GreenLimit Then
						Response.Write "<font color=""orange"">" & FormatNumber(rsWarehouses("WarehouseMiles"), 0, True, True, True) & " miles</font>"
					Else
						Response.Write "<font color=""green"">" & FormatNumber(rsWarehouses("WarehouseMiles"), 0, True, True, True) & " miles</font>"
					End If
					Response.Write ")"
					%>
					<br>
				</th>
				<%
				rsWarehouses.MoveNext
			Loop
			'rsOrderDetails.MoveFirst
			%>
		</tr>
	</thead>
	<tbody name="ItemList">
		<%
		If rsOrderDetails.EOF Then
			Response.Write "<tr><td colspan=""8"">No items found in this order</td></tr>"
		Else
			Dim TotalAmt, TotalWeight, TotalShipWeight
			Do While Not rsOrderDetails.EOF
				TotalAmt = TotalAmt + rsOrderDetails("ExtendedPrice")
				If rsOrderDetails("ItemQuantity") > 0 Then
					TotalWeight = TotalWeight + (rsOrderDetails("ItemWeight") * rsOrderDetails("ItemQuantity"))
					TotalShipWeight = TotalShipWeight + (rsOrderDetails("ItemShipWeight") * rsOrderDetails("ItemQuantity"))
				End If
				%>
				<tr>
					<td nowrap valign="top"><%=rsOrderDetails("ItemQuantity")%></td>
					<!-- <td nowrap valign="top" style="border-top:5px solid white;"><a target="_blank" href="/apps/check_inventory/home.asp?Zip=<%=rsOrder("ShipZip")%>&Items=<%=strItemList%>&ShowWhsLink=Y&SortBy=WarehouseMiles&amp;SortDir=ASC" style="color:blue; text-decoration:underline;"><%=rsOrderDetails("ItemCode")%></a></td> -->
					<td nowrap valign="top"><%=rsOrderDetails("ItemCode")%></td>
					<%
					rsWarehouses.MoveFirst
					Do While Not rsWarehouses.EOF
						If Not IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter")) Then
							Debug.Print rsWarehouses("WarehouseCode") & "_" & rsOrderDetails("ItemCode"), CStr(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter"))
						End If
						%>
						<td nowrap align="left" valign="top" style="border-left:1px solid black;">
							<%
							If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnHand")) Then
								Response.Write "NA"
							Else
								Response.Write "<b>"
								Response.Write "<span style=""height:18px;"" title=""On Hand: " & FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnHand"), 0, True, False, True) & vbNewLine & "Customer Orders: " & FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CustomerOrders"), 0, True, False, True) & """ onmouseover=""this.style.cursor='hand';"">"
								If CDbl(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available")) <= 0 Then
									Response.Write "<font color=""red"">" & FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available"), 0, True, False, True) & "</font>"
								Else
									Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available"), 0, True, False, True)
								End If
								Response.Write " <img src=""/shared/images/icons/arrow_black_smRight.gif"" align=""absmiddle""> "
								If (CDbl(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available")) - rsOrderDetails("ItemQuantity")) <= 0 Then
									Response.Write "<font color=""red"">" & FormatNumber((CDbl(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available")) - rsOrderDetails("ItemQuantity")), 0, True, False, True) & "</font>"
								Else
									Response.Write FormatNumber((CDbl(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "Available")) - rsOrderDetails("ItemQuantity")), 0, True, False, True)
								End If
								Response.Write " Avail</b> "
    							Response.Write "(<a target=""_blank"" href=""/apps/check_inventory/history.asp?Whs=" & rsWarehouses("WarehouseCode") & "&Item=" & rsOrderDetails("ItemCode") & "&DateRange=1Year"" style=""color:blue; text-decoration:underline; cursor:hand;"">PO/RT History</a>)</span>"

								Response.Write "<br>"
								Response.Write "<span title=""Current Month Shipments: " & rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthShipments") & """ onmouseover=""this.style.cursor='hand';"">"
								If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysBefore")) Then
									Response.Write "NA"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysBefore") <= 0 Then
									Response.Write "<font color=""red"">0</font>"
								Else
									Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysBefore"), 0, True, False, True)
								End If
								Response.Write " <img src=""/shared/images/icons/arrow_black_smRight.gif"" align=""absmiddle""> "
								If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysAfter")) Then
									Response.Write "NA"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysAfter") <= 0 Then
									Response.Write "<font color=""red"">0</font>"
								Else
									Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "CurrentMonthDaysAfter"), 0, True, False, True)
								End If
								Response.Write " days (1m avg)"
								Response.Write "</span>"

								Response.Write "<br>"
								Response.Write "<span title=""12 Month Shipments: " & rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthShipments") & """ onmouseover=""this.style.cursor='hand';"">"
								If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore")) Then
									Response.Write "NA"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore") <= 0 Then
									Response.Write "<font color=""red"">0</font>"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore") > 999 Then
									Response.Write "<font color=""green"">&gt;999</font>"
								Else
									Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysBefore"), 0, True, False, True)
								End If
								Response.Write " <img src=""/shared/images/icons/arrow_black_smRight.gif"" align=""absmiddle""> "
								If IsNull(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter")) Then
									Response.Write "NA"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter") <= 0 Then
									Response.Write "<font color=""red"">0</font>"
								ElseIf rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter") > 999 Then
									Response.Write "<font color=""green"">&gt;999</font>"
								Else
									Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "12MonthDaysAfter"), 0, True, False, True)
								End If
								Response.Write " days (12m avg)"
								Response.Write "</span>"

								If rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnOrder") <> 0 _
									Or rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "ToWarehouseInTransit") <> 0 Then
									Response.Write "<br>"
									Response.Write "<span style=""height:18px; padding-top:2px;;"">"
									If rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnOrder") <> 0 Then
										Response.Write "On Order: "
										'Response.Write "<a target=""_blank"" href=""/apps/order_invoice_lookup/home.asp?CheckOrderNumber=Yes&CheckInvoiceNumber=Yes&CheckAccountCode=Yes&CheckCompanyName=Yes&Status=Open&DateRange=1Year&SearchType=BeginsWith&Warehouse=" & rsWarehouses("WarehouseCode") & "&Item=" & rsOrderDetails("ItemCode") & "&MoreOptions=Y"" style=""color:blue; text-decoration:underline;"">"
										Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnOrder"), 0, True, False, True)
										'Response.Write "</a>"
									End If
									If rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "OnOrder") <> 0 _
										And rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "ToWarehouseInTransit") <> 0 Then
										Response.Write " / "
									End If
									If rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "ToWarehouseInTransit") <> 0 Then
										Response.Write "Whs Xfer: "
										'Response.Write "<a target=""_blank"" href=""/apps/order_invoice_lookup/home.asp?CheckOrderNumber=Yes&CheckInvoiceNumber=Yes&CheckAccountCode=Yes&CheckCompanyName=Yes&Status=Open&DateRange=1Year&SearchType=BeginsWith&Warehouse=" & rsWarehouses("WarehouseCode") & "&Item=" & rsOrderDetails("ItemCode") & "&MoreOptions=Y"" style=""color:blue; text-decoration:underline;"">"
										Response.Write FormatNumber(rsOrderDetails("Warehouse" & rsWarehouses("WarehouseCode") & "ToWarehouseInTransit"), 0, True, False, True)
										'Response.Write "</a>"
									End If
									Response.Write "</span>"
								End If
							End If
							%>
						</td>
						<%
						rsWarehouses.MoveNext
					Loop
					%>
				</tr>
				<%
				rsOrderDetails.MoveNext
			Loop
			Response.Write "<input type=""hidden"" name=""TotalWeight"" value=""" & TotalWeight & """>"
			Response.Write "<input type=""hidden"" name=""TotalShipWeight"" value=""" & TotalShipWeight & """>"
			rsOrder.MoveFirst
		End If
		%>
	</tbody>
	<%
	If True = True Then
		Dim objCzar, Level
		'Set objCzar = Server.CreateObject("CzarCOM.czardll")
		'objCzar.InitializeCzar
		'objCzar.Tariff_Name = "LITECZ02"
		'objCzar.Intra_State = "N"
		'objCzar.Shipment_Date = "08-05-2002"
		'objCzar.OrgCity_State = "**"
		'objCzar.DstCity_State = "**"
		'objCzar.Use_Dscnts = "Y"
		'objCzar.Discount_Type = "C"
		'For Level = 0 To 9
			'objCzar.WbDisc_In(Level) = 51.5
			'objCzar.Indir_In(Level) = 51.5
		'Next
		'objCzar.Cls(0) = "70"
		'objCzar.Detail_Lines = "1"
		'objCzar.DstZip = rsOrder("ShipZip")
		'objCzar.Wgt(0) = TotalShipWeight

		Response.Write "<tfoot>"
		Response.Write "<tr>"
		Response.Write "<th nowrap valign=""top"" colspan=""2"">Shipping Charges<br>(" & FormatNumber(TotalWeight, 0, True, False, True) & " / " & FormatNumber(TotalShipWeight, 0, True, False, True) & " lbs)</th>"
		rsWarehouses.MoveFirst
		
        Dim rsCarrier
        Dim strCarrierFlag
        Dim outSentEmail : outSentEmail = 0 
        dim oraComm
        dim orderNumber
        dim rs
        dim checkType
        
        orderNumber = Request.QueryString("OrderID")
        checkType = "CU_CustomerChk"
        'checkType = "Reserve"
        set oraComm = Server.CreateObject("ADODB.Command")
        with oraComm
            with oraComm
	            .activeconnection = conRefron
	            .CommandType = 4 'adCmdStoredProc            
	            .CommandText = "dbo.BondedWarehouse_OrderDetail_RecoveryCylinderCheck "
	            .Parameters.Append oraComm.CreateParameter("@inOrderID",200,&H0001,8000, orderNumber)
	            .Parameters.Append oraComm.CreateParameter("@outSendMail",200,adParamOutput,8000,"")
	            .Parameters.Append oraComm.CreateParameter("@inCheckType",200,&H0001,8000, checkType)
            end with
            set rs = oraComm.execute			
            outSentEmail = .parameters("@outSendMail")
        end with
        strCarrierFlag = "disabled" 
        'strCarrierFlag = "enabled"		

        if(outSentEmail = 1)then
            Session("NumErrors") = Session("NumErrors") + 1
            Session("ErrorMsg" & (Session("NumErrors")) ) = "Your order is missing a CU customer code. Please submit a request for a CU customer code or new account form if needed. Please note : order cannot be shiped until CU code has been entered and linked to the RIS account."		    
        end if	
		
		Do While Not rsWarehouses.EOF and outSentEmail = 0
'			objCzar.OrgZip = rsWarehouses("WarehouseZip")
'			objCzar.RateShipment
			Response.Write "<th id=""th_" & rsWarehouses("WarehouseCode") & """ nowrap valign=""top"">"	
			
            If Trim(rsWarehouses("WarehouseCode")) = Trim(Request.QueryString("whse")) OR Trim(rsWarehouses("WarehouseCode")) = rsOrder("ReserveWarehouseCode") Then			
    	
	            Set rsCarrier = Server.CreateObject("ADODB.Recordset")
	            strSql = " SELECT CarrierName, TrueCost, Distance FROM OrderCarrier " 
	            strSQL = strSQL & " WHERE OrderID = " & Trim(Request.QueryString("OrderID")) & " "
	            strSql = strSql & " AND CarrierChoice =1 ORDER BY OrderCarrierId DESC "            
                        
	            rsCarrier.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
    	
	            If Not rsCarrier.EOF Then 
	                strCarrierFlag = ""
				    Response.Write ""
                    Response.Write "<li>Carrier: " & rsCarrier("CarrierName") & "</li>"
                    Response.Write "<li>Cost: " & FormatCurrency(rsCarrier("TrueCost"), 2, True, False, True) & "</li>"
                    Response.Write "<li>Distance: " & FormatNumber(rsCarrier("Distance"), 0, True, False, True) & "</li>"
		        End if
		    End if			
'			If objCzar.Min_Charge > objCzar.Total_Charges Then
'				Response.Write "CZL " & FormatCurrency(objCzar.Min_Charge, 2, True, False, True) & " (min)"
'			Else
'				Response.Write "CZL " & FormatCurrency(objCzar.Total_Charges, 2, True, False, True) & ""
'			End If
'			If Trim(rsWarehouses("WarehouseTruck")) = "Y" Then
'				Response.Write "<br>WT (" & FormatNumber(rsWarehouses("WarehouseTruckRadius"), 0, True, False, True) & " miles)"
'			End If
			Response.Write "</th>"
			rsWarehouses.MoveNext
		Loop
		Response.Write "</tr>"
		Response.Write "</tfoot>"

		'objCzar.EndCzar
		'Set objCzar = Nothing
		rsOrderDetails.Close
		Set rsOrderDetails = Nothing
	End If
	%>
</table>

<br>

<% 

'	Dim rsCarrier
'	Dim strCarrierFlag
	
'	strCarrierFlag = "disabled" 
	
'	Set rsCarrier = Server.CreateObject("ADODB.Recordset")
'	strSql = " SELECT CarrierName, TrueCost FROM OrderCarrier WHERE OrderID = " & Trim(Request.QueryString("OrderID")) & ""
'	strSql = strSql & " AND CarrierChoice =1 ORDER BY OrderCarrierId DESC "            
                    
'	rsCarrier.Open strSql, conRefron, adOpenStatic, adLockReadOnly, adCmdText
	
'	If Not rsCarrier.EOF Then 
'	    strCarrierFlag = ""
		%>
<!--	<table style="border:none; margin-left:15px;">
		<tr>
			<td style="border:none; background-color:white;">
				<%
'				Response.Write "<div style=""padding-top:4px; padding-bottom:4px;"">Current Freight Carrier:</DIV>"
 '               Response.Write "<div style=""padding-left:15px; padding-bottom:4px;""><Strong><li>" & rsCarrier("CarrierName") &""
  '              Response.Write " - " & FormatCurrency(rsCarrier("TrueCost"), 2, True, False, True) & "</Strong></div>"
				%>
			</td>
		</tr>
	</table>
	<br>-->

    <% 'End if %>



<%
If Session("NumErrors") > 0 Then
	%>
	<table style="border:none; margin-left:15px;">
		<tr>
			<td style="border:none; background-color:white;">
				<%
				Response.Write "<div style=""color:red; padding-top:4px; padding-bottom:4px;"">Order Deficiencies:</DIV>"
				Dim ErrNum
				For ErrNum = 1 To Session("NumErrors")
					Response.Write "<div style=""color:red; padding-left:15px; padding-bottom:4px;""><li>" & Session("ErrorMsg" & ErrNum) & "</div>"
				Next
				Call ClearErrors()
				%>
			</td>
		</tr>
	</table>
	<br>
	<%
End If



Dim strPopup
If Not FaxEnabled Then
	strPopup = "if(confirm('Refron\'s fax server is not working!\n\nIf this order needs to be faxed to the warehouse or customer\na copy will be sent to your e-mail inbox and you will have to\nprint it out and fax it manually.\n\nAfter reserving this order please check your inbox for a copy\nof the fax(s) that you will have to print out.')){}else{return false};"
End If
Response.Write "<span style=""margin-left:2%;"">"
If ReadOnly Then
	%>
	<input type="button" name="Submit" value="<%If Trim(rsOrder("TransmitStatus")) = "Faxed" Then Response.Write "Refax" Else Response.Write "Fax"%> to Warehouse" onclick="JavaScript: <%=strPopup%> this.form.action=this.form.action + '?FaxWhse=Y'; this.form.submit(); this.disabled = true;">
	<%
	If rsOrder("FaxConfirmationFlag") <> "No" And rsOrder("FaxConfirmationNumber") <> "" Then
		%>
		<!--<input type="button" name="Submit" value="<%If rsOrder("FaxConfirmationFlag") = "Sent" Then Response.Write "Refax" Else Response.Write "Fax"%> to Customer" onclick="JavaScript: <%=strPopup%> this.form.action=this.form.action + '?FaxCust=Y'; this.form.submit(); this.disabled = true;">-->
		<%
	End If
Else
	%>
	<input type="button" name="Submit" value="Reserve &amp; Send"  <%=strCarrierFlag%> onclick="JavaScript: <%=strPopup%> this.form.action=this.form.action + '?FaxWhse=Y&amp;FaxCust=Y'; this.form.submit(); this.disabled = true;">
	<input type="button" name="Submit" value="Reserve (No Send)" <%=strCarrierFlag%> onclick="JavaScript: <%=strPopup%> this.form.action=this.form.action + '?FaxCust=Y'; this.form.submit(); this.disabled = true;">
	<%
End If
%>
<input type="button" value="Cancel" onclick="window.location.href='/apps/order_invoice_lookup/order.asp?OrderID=<%=rsOrder("OrderNumber")%>';" id="button1" name="button1">
<input type="checkbox" name="SendCopyToSelf" value="Y"> Send me a copy via e-mail
</span>
</form>


<%


rsOrder.Close
Set rsOrder = Nothing

'WriteTimers()
%>

<!--#include virtual="/global/footer.asp"-->