
Imports System
Imports System.Web
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.IO
Imports System.Data
Imports System.Data.OleDb
Imports System.Data.SqlClient
Imports System.Configuration
'-----
Imports System.Web.Extensions
Imports System.Design
Imports System.Web.Extensions.Design
'Imports System.Windows.Forms
Imports System.Drawing
Imports System.Xml
Imports System.Web.Services
Imports System.DirectoryServices
Imports System.DirectoryServices.Protocols
Imports System.EnterpriseServices
Imports System.ServiceProcess
Imports System.Web.RegularExpressions


Partial Public Class AFS_FrieghtBills_Sandbox

	Inherits System.Web.UI.Page
	'Private strDate As String
	'Private IsServiceAvailable As Boolean = False
	'Private ServiceUrl As String
	'Private strPageReferrerUrl As String
	'Private strReferrerUrl As String
	'Private strPageUrl As String
	'Private strUrl As String
	'Private strReturnUrl As String
	'Private intCarrierCantDeliverSelected As Integer
	Private conn As DBConnect = New DBConnect()
	Private strSQL As StringBuilder = New StringBuilder
	Private strFolder As String = Server.MapPath("AFS_Bills\")
	Private strPath As StringBuilder = New StringBuilder
	Private cmd As SqlCommand = New SqlCommand
	Private strOutput As Object = New Object

	'Private strXLSconn As String = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + strPath.ToString + ";Extended Properties=""Excel 8.0"""
	'Private strXLSXconn As String = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + strPath.ToString + ";Extended Properties=""Excel 12.0"""


	Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)

		Master.Title = "AFS Bills-SB"
		Master.TitleBar = "AFS Billing-SB"

		If Not isPostback Or ddl_Invoices.Selectedvalue = "" Then

			btn_Download.visible = False

			strSQL.Append("SELECT distinct AFS_Invoice FROM Freight_AFS_Bills WHERE IsNull(process_complete,0) = 0 and IsNull(not_toBePaid,0) = 0")

			cmd.Parameters.AddWithValue("@AFS_Invoice", ddl_Invoices.Selectedvalue.tostring)

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			Dim sqlrdr As SqlDataReader = cmd.ExecuteReader

			ddl_Invoices.Items.Clear()
			ddl_Invoices.AppendDataBoundItems = True
			ddl_Invoices.Items.Add(New ListItem(" --- All Invoices --- ", ""))

			While sqlrdr.read()

				ddl_Invoices.Items.Add(New ListItem(CType(sqlrdr("AFS_Invoice"), String), CType(sqlrdr("AFS_Invoice"), String)))

			End While

			ddl_Invoices.SelectedValue = ""

			sqlrdr.Close()
			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE NO_OrderNumber = 1 ")
			strSQL.Append(" AND ISNULL(Process_Complete,0) = 0 and Not_ToBePaid = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_NoOrderNumber_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Has_FreightCharge = 1 ")
			strSQL.Append(" AND ISNULL(Process_Complete,0) = 0 and Not_ToBePaid = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_FreightCharge_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Process_Error_Found = 1 ")
			strSQL.Append(" AND ISNULL(Process_Complete,0) = 0 and Not_ToBePaid = 0 and No_OrderNumber = 0 ")
			strSQL.Append(" AND Has_FreightCharge = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_OtherErrors_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Push_ToFreightCharge = 1 ")
			strSQL.Append(" AND ISNULL(Process_Complete,0) = 1 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_PushTo_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Not_ToBePaid = 1 ")
			'strSQL.Append(" AND ISNULL(Process_Complete,0) = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_NotToBePaid_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

		Else

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE NO_OrderNumber = 1 and Push_ToFreightCharge = 0  ")
			strSQL.Append(" AND AFS_Invoice = @Invoice ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = ddl_Invoices.SelectedItem.Text
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_NOOrderNumber_Count.Text = strOutput.ToString
				If Convert.ToInt32(strOutput) > 0 Then btn_Download.visible = True

			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Has_FreightCharge = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = ddl_Invoices.SelectedItem.Text
			strOutput = cmd.ExecuteScalar()


			If Not IsNothing(strOutput) Then
				lbl_FreightCharge_Count.Text = strOutput.ToString
				If Convert.ToInt32(strOutput) > 0 Then btn_Download.visible = True

			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Process_Error_Found = 1 ")
			strSQL.Append(" AND ISNULL(Process_Complete,0) = 0 and Not_ToBePaid = 0 and No_OrderNumber = 0 ")
			strSQL.Append(" AND Has_FreightCharge = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_OtherErrors_Count.Text = strOutput.ToString
				btn_Download.Visible = True
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Push_ToFreightCharge = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = ddl_Invoices.SelectedItem.Text
			strOutput = cmd.ExecuteScalar()

			If Not IsNothing(strOutput) Then
				lbl_PushTo_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Not_ToBePaid = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = ddl_Invoices.SelectedItem.Text
			strOutput = cmd.ExecuteScalar()

			If Not IsNothing(strOutput) Then
				lbl_NotToBePaid_Count.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

		End If

		lbl_Total_Count.Text = Convert.ToString(Convert.ToInt32(lbl_NoOrderNumber_Count.Text) + Convert.ToInt32(lbl_FreightCharge_Count.Text) + Convert.ToInt32(lbl_OtherErrors_Count.Text) + Convert.ToInt32(lbl_NotToBePaid_Count.Text))


	End Sub


	Protected Sub btn_Upload_Click(ByVal sender As Object, ByVal e As System.EventArgs)

		If FileUpload1.HasFile Then

			Dim FileName As String = Path.GetFileName(FileUpload1.PostedFile.FileName)
			Dim Extension As String = Path.GetExtension(FileUpload1.PostedFile.FileName)
			Dim FolderPath As String = strFolder

			Dim FilePath As String = strFolder + FileName
			FileUpload1.SaveAs(FilePath)

			lbl_FileName.Text = Path.GetFileName(FilePath)

			trace.warn(FileName)

			strSQL.Append("SELECT DISTINCT CHARINDEX('" + FileName + "',[DataFile],1) FROM Freight_AFS_Bills ")
			strSQL.Append(" WHERE CHARINDEX('" + FileName + "',[DataFile],1) > 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			strOutput = cmd.ExecuteScalar()

			strSQL.Length = 0
			cmd.Parameters.Clear()

			If Not IsNothing(strOutput) Then

				lbl_FileError_msg.Visible = True
				lbl_FileError.visible = True

				lbl_FileError_msg.Text = "This file has been loaded before and you cannot load twice"

			Else

				lbl_FileError_msg.Visible = False
				lbl_FileError.visible = False

				lbl_FileError_msg.Text = ""

				pnl_UploadDetail.Visible = True

				pnl_Upload.Visible = False

				Dim strArry_Invoice As String() = lbl_FileName.Text.Split(Char.Parse("-"))

				If strArry_Invoice.GetUpperBound(0) = 0 Then
					strArry_Invoice = lbl_FileName.Text.Split(Char.Parse("."))
					txt_AFS_Invoice.Text = strArry_Invoice(0)

				Else
					txt_AFS_Invoice.Text = strArry_Invoice(0) + strArry_Invoice(2)
				End If

				lbl_AFS_Invoice.Text = txt_AFS_Invoice.Text


				strSQL.Append("SELECT AFS_Invoice FROM Freight_AFS_Bills WHERE AFS_Invoice = @Invoice ")
				strSQL.Append(" AND IsNull(Process_Complete,0) = 0 GROUP BY AFS_Invoice")

				cmd.CommandType = CommandType.Text
				cmd.Connection = conn.Connection
				cmd.CommandText = strSQL.ToString
				cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = txt_AFS_Invoice.Text
				strOutput = cmd.ExecuteScalar()

				strSQL.Length = 0
				cmd.Parameters.Clear()


				If Not IsNothing(strOutput) Then

					txt_AFS_Invoice.visible = False
					lbl_AFS_Invoice.visible = True
					lbl_LoadVersion.visible = True

					strSQL.Append("SELECT COALESCE(CHAR(ASCII(MAX(LoadVersion))+1),'A') FROM Freight_AFS_Bills ")
					strSQL.Append(" WHERE AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 0 GROUP BY AFS_Invoice ")

					cmd.CommandType = CommandType.Text
					cmd.Connection = conn.Connection
					cmd.CommandText = strSQL.ToString
					cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = txt_AFS_Invoice.Text
					strOutput = cmd.ExecuteScalar()

					trace.warn(strOutput.ToString)

					If Not IsNothing(strOutput) Then
						lbl_LoadVersion.Text = strOutput.ToString
					End If

					strSQL.Length = 0
					cmd.Parameters.Clear()

				End If

			End If

		End If


	End Sub


	Protected Sub btn_Load_Click(ByVal sender As Object, ByVal e As EventArgs)

		Dim strFileName As String = lbl_FileName.Text
		Dim strInvoice As String = lbl_AFS_Invoice.Text
		Dim strLoadVersion As String = lbl_LoadVersion.Text

		'this.Cursor = Cursors.WaitCursor
		'btn_Load.Enabled = False
		'btn_Load.Visible = False
		' lshtemp test code

		Label10.Text = "File Processing Complete!"

		' lshtemp end test code

		If strLoadVersion.Contains("New") Then

			strSQL.Append("AFS_Bill_Load2")

			cmd.CommandType = CommandType.StoredProcedure
			cmd.CommandText = strSQL.ToString
			cmd.COmmandTimeout = 3000

			cmd.Parameters.Add("@FileName", SqlDbType.VarChar).Value = strFileName
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			cmd.Parameters.Add("@LoadVersion", SqlDbType.VarChar).Value = strLoadVersion

			cmd.ExecuteNonQuery()

			strSQL.Length = 0
			cmd.Parameters.Clear()

		Else

			strSQL.Append("AFS_Bill_Load")

			cmd.CommandType = CommandType.StoredProcedure
			cmd.CommandText = strSQL.ToString
			cmd.CommandTimeout = 3000

			cmd.Parameters.Add("@FileName", SqlDbType.VarChar).Value = strFileName
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			cmd.Parameters.Add("@LoadVersion", SqlDbType.VarChar).Value = strLoadVersion

			cmd.ExecuteNonQuery()

			strSQL.Length = 0
			cmd.Parameters.Clear()

		End If

		strSQL.Append("AFS_Bill_Process_Batch")

		cmd.CommandType = CommandType.StoredProcedure
		cmd.CommandText = strSQL.ToString
		cmd.CommandTimeout = 3000
		cmd.ExecuteNonQuery()

		strSQL.Length = 0
		cmd.Parameters.Clear()



		strSQL.Append("SELECT COUNT([Pro #]) FROM Freight_AFS_Bills_RawImport")

		cmd.CommandType = CommandType.Text
		cmd.CommandText = strSQL.ToString

		strOutput = cmd.ExecuteScalar()

		strSQL.Length = 0
		cmd.Parameters.Clear()

		If Not IsNothing(strOutput) And Convert.ToInt32(strOutput) > 0 Then

			tbl_Results.visible = True
			tbl_FileInfo.visible = False
			btn_Load.visible = False
			btn_Cancel.Enabled = True
			btn_Cancel.text = "Clear & Reset Form"


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE NO_OrderNumber = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 0 and Not_ToBePaid = 0")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			strOutput = cmd.ExecuteScalar()


			If Not IsNothing(strOutput) Then
				lbl_NoOrderNumber_Results.Text = strOutput.ToString
				'If Convert.ToInt32(strOutput) > 0 Then btn_Download.visible = True

			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Has_FreightCharge = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 0 and Not_ToBePaid = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_FreightCharge_Results.Text = strOutput.ToString
				'If Convert.ToInt32(strOutput) > 0 Then btn_Download.visible = True

			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Process_Error_Found = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 0 and IsNull(Not_ToBePaid,0) = 0 ")
			strSQL.Append(" AND No_OrderNumber = 0 and Has_FreightCharge = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_OtherErrors_Results.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Not_ToBePaid = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 0 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_Not_ToBePaid_Results.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()


			strSQL.Append("SELECT COUNT(AFS_Invoice) FROM [Freight_AFS_Bills] WHERE Push_ToFreightCharge = 1 ")
			strSQL.Append(" AND AFS_Invoice = @Invoice AND IsNull(Process_Complete,0) = 1 ")

			cmd.CommandType = CommandType.Text
			cmd.Connection = conn.Connection
			cmd.CommandText = strSQL.ToString
			cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice
			strOutput = cmd.ExecuteScalar()

			trace.warn(strOutput.ToString)

			If Not IsNothing(strOutput) Then
				lbl_PushTo_Results.Text = strOutput.ToString
			End If

			strSQL.Length = 0
			cmd.Parameters.Clear()

			lbl_Invoice_Results.Text = strInvoice

			lbl_Total_Results.Text = Convert.ToString(Convert.ToInt32(lbl_NoOrderNumber_Results.Text) + Convert.ToInt32(lbl_FreightCharge_Results.Text) + Convert.ToInt32(lbl_OtherErrors_Results.Text) + Convert.ToInt32(lbl_Not_ToBePaid_Results.Text) + Convert.ToInt32(lbl_PushTo_Results.Text))


		Else

			lbl_Error_msg.Visible = True
			lbl_Error.visible = True

			lbl_Error_msg.Text = "File could not load data"


		End If

		'btn_Load.Enabled = True
		'this.Cursor = Cursors.Default


	End Sub


	Protected Sub btn_Cancel_Click(ByVal sender As Object, ByVal e As EventArgs)

		pnl_Upload.Visible = True
		pnl_UploadDetail.Visible = False

		If btn_Cancel.Text = "Clear & Reset Form" Then
			btn_Cancel.text = "Cancel"
			btn_Cancel.Enabled = False
		End If

		Response.Redirect("AFS_FreightBills.aspx")

	End Sub


	Protected Sub btn_Download_Click(ByVal sender As Object, ByVal e As EventArgs)

		Dim strInvoice As String = ddl_Invoices.Selectedvalue.tostring

		strSQL.Append("AFS_Exception_Download")

		cmd.CommandType = CommandType.StoredProcedure
		cmd.CommandText = strSQL.ToString

		cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = strInvoice

		cmd.ExecuteNonQuery()

		strSQL.Length = 0
		cmd.Parameters.Clear()

		Response.ContentType = "Application/x-msexcel"
		Response.Appendheader("content-disposition", "attachment; filename=" + strInvoice + ".XLS")
		Response.TransmitFile(strFolder + "Downloads\" + strInvoice + ".XLS")
		Response.End()


	End Sub

End Class