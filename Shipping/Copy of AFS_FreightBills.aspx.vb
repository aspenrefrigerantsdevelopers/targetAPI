
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


Partial Public Class AFS_FrieghtBills

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
    'Private strXLSconn As String = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + strPath.ToString + ";Extended Properties=""Excel 8.0"""
    'Private strXLSXconn As String = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + strPath.ToString + ";Extended Properties=""Excel 12.0"""


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)

        Master.Title = "AFS Bills"
        Master.TitleBar = "AFS Billing"


    End Sub


    Protected Sub btnUpload_Click(ByVal sender As Object, ByVal e As System.EventArgs)

        If FileUpload1.HasFile Then

            Dim FileName As String = Path.GetFileName(FileUpload1.PostedFile.FileName)
            Dim Extension As String = Path.GetExtension(FileUpload1.PostedFile.FileName)
            Dim FolderPath As String = strFolder

            Dim FilePath As String = strFolder + FileName
            FileUpload1.SaveAs(FilePath)
            GetExcelSheets(FilePath, Extension, "Yes")

        End If

    End Sub


    Private Sub GetExcelSheets(ByVal FilePath As String, ByVal Extension As String, ByVal isHDR As String)

        Dim conStr As String = ""

        Select Case Extension.ToLower

            Case ".xls"
                'Excel 97-03 
                conStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties='Excel 8.0;HDR={1}'"
                Exit Select

            Case ".xlsx"
                'Excel 07 
                conStr = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties='Excel 8.0;HDR={1}'"
                Exit Select

        End Select

        'Get the Sheets in Excel WorkBoo 
        conStr = String.Format(conStr, FilePath, isHDR)

        trace.warn(conStr)
        trace.warn(FilePath)

        Dim connExcel As New OleDbConnection(conStr)
        Dim cmdExcel As New OleDbCommand()
        Dim oda As New OleDbDataAdapter()
        cmdExcel.Connection = connExcel
        connExcel.Open()

        'Bind the Sheets to DropDownList 
        ddlSheets.Items.Clear()
        'ddlSheets.Items.Add(New ListItem("-- Select AFS Invoice --", ""))
        ddlSheets.DataSource = connExcel.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, Nothing)

        ddlSheets.DataTextField = "TABLE_NAME"
        ddlSheets.DataValueField = "TABLE_NAME"
        ddlSheets.DataBind()
        connExcel.Close()

        lblFileName.Text = Path.GetFileName(FilePath)

        Dim strSheet As String = ddlSheets.SelectedItem.Text.Replace("'", "")
        Trace.Warn(strSheet)
        Dim strArry_Invoice As String() = strSheet.Split(Char.Parse("-"))
        lblAFS_Invoice.Text = strArry_Invoice(0) + strArry_Invoice(2)

        pnl_UploadDetail.Visible = True

        pnl_Upload.Visible = False
        pnl_ByOrderNum.visible = False
        pnl_ByPaidFreight.visible = False
        pnl_ByBOLNum.visible = False

    End Sub


    Protected Sub btnSaveAlt_Click(ByVal sender As Object, ByVal e As EventArgs)

        Dim FileName As String = lblFileName.Text
        Dim Extension As String = Path.GetExtension(FileName)
        Dim FolderPath As String = strFolder + FileName

        Dim conStr As String = ""
        conStr = "Provider=Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties='Excel 8.0;HDR={1}'"
        conStr = String.Format(conStr, FolderPath, "Yes")

        trace.warn(conStr)
        ' Create the connection object 
        Dim oledbConn As OleDbConnection = New OleDbConnection(conStr)
        Try
            ' Open connection
            oledbConn.Open()

            trace.warn("SELECT * FROM [" + ddlSheets.SelectedItem.Text + "]")

            ' Create OleDbCommand object and select data from worksheet Sheet1
            Dim cmd As OleDbCommand = New OleDbCommand("SELECT * FROM [" + ddlSheets.SelectedItem.Text + "]", oledbConn)

            ' Create new OleDbDataAdapter 
            Dim oleda As OleDbDataAdapter = New OleDbDataAdapter()

            oleda.SelectCommand = cmd

            ' Create a DataSet which will hold the data extracted from the worksheet.
            Dim ds As DataSet = New DataSet()

            ' Fill the DataSet from the data extracted from the worksheet.
            oleda.Fill(ds, "Invoices")

            ' Bind the data to the GridView
            GridView4.DataSource = ds.Tables(0).DefaultView
            GridView4.DataBind()
        Catch ex As Exception

            lblMessage.ForeColor = System.Drawing.Color.Red
            lblMessage.Text = ex.Message
            trace.warn(ex.Message)

        Finally
            ' Close connection
            oledbConn.Close()
        End Try

    End Sub


    Protected Sub btnSave_Click(ByVal sender As Object, ByVal e As EventArgs)

        Dim FileName As String = lblFileName.Text
        Dim Extension As String = Path.GetExtension(FileName)
        Dim FolderPath As String = strFolder + FileName

        Dim conStr As String = ""
        conStr = "Provider=Provider=Microsoft.ACE.OLEDB.12.0;Data Source='{0}';Extended Properties='Excel 8.0;HDR={1}'"
        conStr = String.Format(conStr, FolderPath, "Yes")

        Dim CommandText As String = ""
        Select Case Extension
            Case ".xls"
                'Excel 97-03 
                CommandText = "AFS_Bill_Load"
                Exit Select
            Case ".xlsx"
                'Excel 07 
                CommandText = "spx_ImportFromExcel07"
                Exit Select
        End Select

        'Read Excel Sheet using Stored Procedure 
        'And import the data into Database Table 

        'Dim con As New SqlConnection(conStr)
        'Dim cmd As New SqlCommand()
        Dim cmd As New SqlCommand(strSQL.ToString, conn.Connection)
        cmd.CommandType = CommandType.StoredProcedure
        cmd.CommandText = CommandText
        cmd.Parameters.Add("@SheetName", SqlDbType.VarChar).Value = ddlSheets.SelectedItem.Text
        cmd.Parameters.Add("@FileName", SqlDbType.VarChar).Value = FileName
        cmd.Parameters.Add("@Invoice", SqlDbType.VarChar).Value = lblAFS_Invoice.Text
        'cmd.Connection = con
        'cmd.Connection = conn

        Try
            'con.Open()
            'conn.Open()
            Dim count As Object = cmd.ExecuteNonQuery()
            lblMessage.ForeColor = System.Drawing.Color.Green
            lblMessage.Text = count.ToString() & " records inserted."

        Catch ex As Exception

            lblMessage.ForeColor = System.Drawing.Color.Red
            lblMessage.Text = ex.Message
            trace.warn(ex.Message)

        Finally

            'con.Close()
            'con.Dispose()
            cmd.dispose()
            conn.dispose()

            pnl_Upload.Visible = True
            pnl_UploadDetail.Visible = False

        End Try

    End Sub


    Protected Sub btnCancel_Click(ByVal sender As Object, ByVal e As EventArgs)

        pnl_Upload.Visible = True
        pnl_UploadDetail.Visible = False

        pnl_ByOrderNum.visible = False
        pnl_ByPaidFreight.visible = False
        pnl_ByBOLNum.visible = False

    End Sub


    Protected Sub rdo_Exceptions_CheckChanged(ByVal sender As Object, ByVal e As EventArgs)

        Dim rdo As RadioButton = CType(sender, RadioButton)
        Dim str As String = rdo.id.ToString


        Select Case str

            Case "rdo_ByOrderNum"
                pnl_ByOrderNum.visible = True
                pnl_ByPaidFreight.visible = False
                pnl_ByBOLNum.visible = False

            Case "rdo_ByPaidFreight"
                pnl_ByOrderNum.visible = False
                pnl_ByPaidFreight.visible = True
                pnl_ByBOLNum.visible = False

            Case "rdo_ByBOLNum"
                pnl_ByOrderNum.visible = False
                pnl_ByPaidFreight.visible = False
                pnl_ByBOLNum.visible = True


        End Select

    End Sub


    Protected Function DisplayAudit(ByVal booAudit As Boolean) As String

        If booAudit Then

            Return "Yes"

        Else

            Return "No"

        End If

    End Function

End Class