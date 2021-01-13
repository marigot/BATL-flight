Imports System.Runtime.InteropServices
Imports System.Security.Permissions

Public Class Form1
    <UnmanagedFunctionPointer(CallingConvention.StdCall)> _    
    Public Delegate Function CallbackProc(ByVal ConnectionId As UInteger, ByVal Data As IntPtr, ByVal size As UInteger, ByVal Status As UInteger) As Integer

    'used to display text on form from a different thread that create this control
    Delegate Sub SetTextCallback(ByVal Data As String)

    'Prototype of DLL functions
    <DllImport("ExtraPuTTY.dll", CallingConvention:=CallingConvention.StdCall)> _
    Private Shared Function CloseConnexion(ByVal ConnexionId As UInteger) As Integer
    End Function
    <DllImport("ExtraPuTTY.dll", CallingConvention:=CallingConvention.StdCall)> _
    Private Shared Sub CloseAllConnexion()
    End Sub
    <DllImport("ExtraPuTTY.dll", CallingConvention:=CallingConvention.StdCall)> _
    Private Shared Function SendRcvData(ByVal ConnexionId As UInteger, ByVal Command As String, ByVal title As String, ByVal comment As String, ByVal capt As Integer, ByRef bufdata As IntPtr, ByVal Sizedata As Integer, ByVal Settings As Integer) As Integer
    End Function
    <DllImport("ExtraPuTTY.dll", CallingConvention:=CallingConvention.StdCall)> _
    Private Shared Function Connexion(ByVal TragetName As String, ByRef ConnexionId As UInteger, ByVal Log As String, ByVal Pass As String, ByVal Display As Byte, ByVal proto As UInteger, ByVal nbport As UInteger, ByVal rapport As UInteger, ByVal rcvFct As CallbackProc, ByVal SpecSettings As UInteger) As Integer
    End Function

    'set data received on putty terminal on textbox control
    Public Sub SetText(ByVal Data As String)
        If Me.EditResult.InvokeRequired Then
            Dim d As New SetTextCallback(AddressOf SetText)
            Me.Invoke(d, New Object() {Data})
        Else
            Me.EditResult.AppendText(Data)
            Me.EditResult.SelectionStart = EditResult.TextLength
            Me.EditResult.SelectionLength = 0
            Me.EditResult.Focus()
            Me.TextBox3.Focus()
        End If
    End Sub

    'Callback function to getback data received on putty terminal
    Public Function DisplayData(ByVal ConnectionId As UInteger, ByVal Data As IntPtr, ByVal size As UInteger, ByVal Status As UInteger) As Integer
        If (size > 0) And (Status = 0) Then
            SetText(Marshal.PtrToStringAnsi(Data))
        Else
            MsgBox("Connection closed by remote host", MsgBoxStyle.Critical, "ERROR")
            CloseAllConnexion()
        End If
    End Function
    Dim ConnexionID As Integer
    Dim Protocol As UInteger
    Dim Fctptr As CallbackProc = Nothing

    'Open connection
    Private Sub test_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles test.Click
        Dim result As Integer
        Dim ShowPutty As Byte
        Dim PortNb As UInteger
        Dim Rapport As UInteger

        'init
        PortNb = 0
        Rapport = 0
        ShowPutty = 0
        EditResult.Text = ""
        TextBox4.Text = ""
        ListBox1.Items.Clear()

        If CheckBox1.Checked = True Then
            ShowPutty = 1
        End If

        'definition of callback
        Fctptr = New CallbackProc(AddressOf DisplayData)

        'made connection with server
        result = Connexion(Serveur.Text, ConnexionID, TextBox2.Text, password.Text, ShowPutty, Protocol, PortNb, Rapport, Fctptr, 0)
            If result = 0 Then
                ListBox1.Items.Add("Connection on device : " & Serveur.Text & " : OK")
                Button1.Enabled = True
                Button2.Enabled = True
                TextBox1.Enabled = True
                TextBox3.Enabled = True
                CheckBox1.Enabled = False
                test.Enabled = False
                Serveur.Enabled = False
                TextBox2.Enabled = False
                password.Enabled = False
                Button4.Enabled = True
                ComboBox1.Enabled = False
                EditResult.Enabled = True
                TextBox3.Focus()
            Else
                ListBox1.Items.Add("Connection fails, Erreur : " & result)
                Serveur.Text = ""
                TextBox2.Text = ""
                password.Text = ""
            End If
    End Sub

    Private Sub Button1_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button1.Click
        Dim DataRcv As IntPtr = Marshal.AllocHGlobal(10000000)
        'Dim DataRcv As String = "                                                                                                                             "
        Dim result As Integer
        Dim sReturned As String

        TextBox1.Enabled = False
        TextBox4.Text = ""
            'Send command, timecapture is set to 15 seconds.
            result = SendRcvData(ConnexionID, TextBox1.Text, "", "", 15000, DataRcv, 10000000, 0)
            If result = 0 Then
                sReturned = Marshal.PtrToStringAnsi(DataRcv)
                TextBox4.Text = sReturned
                ListBox1.Items.Add("Sucess to send command : " & TextBox1.Text & " ,on serveur : " & Serveur.Text)
            Else
                ListBox1.Items.Add("Impossible to send data to serveur : " & Serveur.Text & " Erreur : " & result)
            End If

            If DataRcv <> IntPtr.Zero Then
                Marshal.FreeCoTaskMem(DataRcv)
            End If
            TextBox1.Enabled = True
            TextBox1.Text = ""
    End Sub

    Private Sub Button2_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button2.Click
        CloseConnection_()
    End Sub

    Private Sub Form1_FormClosed(ByVal sender As Object, ByVal e As System.Windows.Forms.FormClosedEventArgs) Handles Me.FormClosed
            'Closed all connexions
            CloseAllConnexion()
    End Sub

    Private Sub ComboBox1_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ComboBox1.SelectedIndexChanged
        Protocol = ComboBox1.SelectedIndex
        If Protocol = 3 Then
            Serveur.Text = "-"
            password.Text = ""
            TextBox2.Text = ""
            Label1.Text = "Command"
            password.Enabled = False
            TextBox2.Enabled = False
            Protocol = 6
        Else
            password.Enabled = True
            TextBox2.Enabled = True
            Label1.Text = "Ip or HostName"
            If Protocol = 2 Then
                Label1.Text = "Session Name"
                Protocol = 4
            End If
        End If
    End Sub

    Private Sub Button4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Button4.Click
            SendCmdSST()
    End Sub

    Private Sub TextBox3_KeyPress(ByVal sender As Object, ByVal e As System.Windows.Forms.KeyPressEventArgs) Handles TextBox3.KeyPress
        If e.KeyChar = Chr(Keys.Enter) Then
                SendCmdSST()
        End If
    End Sub

    'close connection
    Private Sub CloseConnection_()
        'Closed all connections
        CloseAllConnexion()
        ListBox1.Items.Add("Connection closed")
        Button1.Enabled = False
        Button2.Enabled = False
        Button4.Enabled = False
        TextBox1.Enabled = False
        TextBox3.Enabled = False
        ComboBox1.Enabled = True
        CheckBox1.Enabled = True
        EditResult.Enabled = True
        test.Enabled = True
        Serveur.Enabled = True
        TextBox2.Enabled = True
        password.Enabled = True
    End Sub

    'send command
    Private Sub SendCmdSST()
        Dim DataRcv As IntPtr = Nothing
        Dim result As Integer

        TextBox3.Enabled = False
        'Send command
        result = SendRcvData(ConnexionID, TextBox3.Text, "", "", 0, DataRcv, 0, 2)
        If result = 0 Then
            ListBox1.Items.Add("Sucess to send command : " & TextBox3.Text & " ,on Device : " & Serveur.Text)
        Else
            ListBox1.Items.Add("Impossible to send data to Device: " & Serveur.Text & " Erreur : " & result)
        End If

        TextBox3.Enabled = True
        TextBox3.Text = ""
        TextBox3.Focus()
    End Sub
End Class
