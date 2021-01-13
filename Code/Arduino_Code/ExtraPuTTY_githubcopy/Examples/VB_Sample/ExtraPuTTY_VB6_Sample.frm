VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "ExtraPuTTY"
   ClientHeight    =   9270
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   12465
   Icon            =   "ExtraPuTTY_VB6_Sample.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9270
   ScaleWidth      =   12465
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton SendFct 
      Caption         =   "SendRcvData"
      Enabled         =   0   'False
      Height          =   375
      Left            =   10920
      TabIndex        =   20
      Top             =   3600
      Width           =   1215
   End
   Begin VB.TextBox Text2 
      Height          =   375
      Left            =   5640
      TabIndex        =   19
      Top             =   3600
      Width           =   5175
   End
   Begin VB.Frame Frame2 
      Caption         =   "Data received, Timeout 1 second "
      Height          =   3975
      Left            =   5520
      TabIndex        =   17
      Top             =   120
      Width           =   6735
      Begin VB.Frame Frame4 
         Caption         =   "Frame4"
         Height          =   15
         Left            =   2040
         TabIndex        =   21
         Top             =   1680
         Width           =   135
      End
      Begin VB.TextBox Text3 
         BackColor       =   &H00F0F0F0&
         Height          =   3135
         Left            =   120
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   18
         Top             =   240
         Width           =   6495
      End
   End
   Begin VB.CommandButton SendCmd 
      Caption         =   "Send"
      Enabled         =   0   'False
      Height          =   375
      Left            =   11160
      TabIndex        =   16
      Top             =   8640
      Width           =   975
   End
   Begin VB.TextBox Login 
      Height          =   375
      Left            =   2040
      TabIndex        =   8
      Top             =   1080
      Width           =   3135
   End
   Begin VB.Timer Timer3 
      Left            =   5520
      Top             =   720
   End
   Begin VB.Timer Timer1 
      Left            =   5520
      Top             =   120
   End
   Begin VB.CommandButton close_ 
      Caption         =   "Close"
      Enabled         =   0   'False
      Height          =   495
      Left            =   3600
      TabIndex        =   4
      Top             =   1920
      Width           =   1455
   End
   Begin VB.Frame Frame3 
      Caption         =   "Connection Settings"
      Height          =   4095
      Left            =   240
      TabIndex        =   2
      Top             =   0
      Width           =   5175
      Begin VB.Timer Timer2 
         Left            =   5040
         Top             =   2520
      End
      Begin VB.TextBox Text4 
         BackColor       =   &H00F0F0F0&
         Enabled         =   0   'False
         Height          =   1215
         Left            =   120
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         TabIndex        =   22
         Top             =   2760
         Width           =   4935
      End
      Begin VB.TextBox Pass 
         Height          =   375
         Left            =   1800
         TabIndex        =   13
         Top             =   1440
         Width           =   3135
      End
      Begin VB.TextBox TgtName 
         Height          =   375
         Left            =   1800
         TabIndex        =   7
         Top             =   720
         Width           =   3135
      End
      Begin VB.ComboBox Protocol 
         Height          =   315
         ItemData        =   "ExtraPuTTY_VB6_Sample.frx":0442
         Left            =   1800
         List            =   "ExtraPuTTY_VB6_Sample.frx":045B
         TabIndex        =   6
         Top             =   360
         Width           =   3135
      End
      Begin VB.CheckBox Check1 
         Caption         =   "Display Extraputty"
         Height          =   375
         Left            =   240
         TabIndex        =   5
         Top             =   1920
         Width           =   1575
      End
      Begin VB.CommandButton Connection 
         Caption         =   "Connection"
         Height          =   495
         Left            =   1920
         TabIndex        =   3
         Top             =   1920
         Width           =   1455
      End
      Begin VB.Label Label7 
         Caption         =   "Logs"
         Height          =   255
         Left            =   120
         TabIndex        =   23
         Top             =   2520
         Width           =   735
      End
      Begin VB.Label Label6 
         Alignment       =   1  'Right Justify
         Caption         =   "Password :"
         Height          =   255
         Left            =   600
         TabIndex        =   14
         Top             =   1560
         Width           =   1095
      End
      Begin VB.Label Label5 
         Alignment       =   1  'Right Justify
         Caption         =   "Login :"
         Height          =   255
         Left            =   600
         TabIndex        =   12
         Top             =   1200
         Width           =   1095
      End
      Begin VB.Label Label3 
         Alignment       =   1  'Right Justify
         Caption         =   "IP or HostName :"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   840
         Width           =   1455
      End
      Begin VB.Label Label1 
         Alignment       =   1  'Right Justify
         Caption         =   "Protocol :"
         Height          =   255
         Left            =   600
         TabIndex        =   9
         Top             =   360
         Width           =   1095
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Data received on PuTTY Terminal"
      Height          =   4935
      Left            =   240
      TabIndex        =   0
      Top             =   4200
      Width           =   12015
      Begin VB.TextBox Text6 
         Height          =   375
         Left            =   120
         TabIndex        =   15
         Top             =   4440
         Width           =   10695
      End
      Begin VB.TextBox Text1 
         BackColor       =   &H00F0F0F0&
         Height          =   4095
         Left            =   120
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   1
         Top             =   240
         Width           =   11775
      End
   End
   Begin VB.Label Label2 
      Caption         =   "Protocol :"
      Height          =   375
      Left            =   480
      TabIndex        =   10
      Top             =   840
      Width           =   1095
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Dim ConnexionId As Long
Dim Buf As Long
Dim Sizedata As Long
Dim Datarcv As String
'kernel32 dll
Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (ByVal Destination As String, ByVal _
    Source As Long, ByVal Length As Integer)
'Prototype of ExtraPuTTY DLL functions
'close function
Private Declare Function CloseConnexion Lib "ExtraPuTTY.dll" (ByVal ConnexionId As Long) As Integer
'send function :SendRcvData_O for VBA
Private Declare Function SendRcvData_O Lib "ExtraPuTTY.dll" (ByVal ConnexionId As Long, ByVal Command As String, _
ByVal title As String, ByVal comment As String, ByVal capt As Long, ByRef data As Any, ByVal Sizedata As Long, _
ByVal Settings As Long) As Integer
'Connection function
Private Declare Function Connexion Lib "ExtraPuTTY.dll" (ByVal TragetName As String, ByRef ConnexionId As Long, _
ByVal log As String, ByVal Pass As String, ByVal Display As Byte, ByVal proto As Long, ByVal portnumber As Long, _
ByVal rapport As Long, ByVal CallBackRcvData As Any, ByVal SpeSettings As Long) As Integer



'Close Connection
Private Sub close__Click()
Dim result As Integer

result = CloseConnexion(ConnexionId)
If (result <> 0) Then
    Text4.Text = "Failed to close Connection"
Else
    Text4.Text = "Connection closed"
    Protocol.Enabled = True
    Login.Enabled = True
    Pass.Enabled = True
    TgtName.Enabled = True
    Connection.Enabled = True
    Check1.Enabled = True
    close_.Enabled = False
    SendFct.Enabled = False
    SendCmd.Enabled = False

   Login.BackColor = &H80000005
   Pass.BackColor = &H80000005
   TgtName.BackColor = &H80000005
   
End If
End Sub

Private Sub Connection_Click()
Text4.Text = "Waiting , connection in progress ..."
Timer1.Interval = 100
Check1.Enabled = False
End Sub

'Connection to device @
Private Sub Connect()

Dim result As Integer
Dim ShowPuTTY As Byte

'check if putty terminal shall be display
ShowPuTTY = 0
If Check1.Value = 1 Then
   ShowPuTTY = 1
End If

'Initialise connection
result = Connexion(TgtName.Text, ConnexionId, Login.Text, Pass.Text, ShowPuTTY, Protocol.ListIndex, 0, 0, AddressOf setCallBack, 0)
'Check the result of command
If (result <> 0) Then
   'fail
   Text4.Text = "Failed to connect error : " & result
Else
    'sucess
    'Set the buffer with Null characters and send space data
    Datarcv = String(10000, vbNullChar)
    Text1.Text = ""
    Text4.Text = "Connection establish"
    Protocol.Locked = True
    Login.Enabled = False
    Pass.Enabled = False
    TgtName.Enabled = False
    Connection.Enabled = False
    Protocol.Enabled = False
    close_.Enabled = True
    SendFct.Enabled = True
    SendCmd.Enabled = True
    Text6.SetFocus

   Login.BackColor = &H8000000F
   Pass.BackColor = &H8000000F
   TgtName.BackColor = &H8000000F
End If

End Sub

Private Sub Form_Load()
TgtName.Text = ""
Login.Text = ""
Pass.Text = ""
End Sub

'Selection of protocol of connection
Private Sub Protocol_Click()

'cygterm specific case
If Protocol.ListIndex = 6 Then
   Label3.Caption = "Command :"
   TgtName.Text = "-"
   Login.Enabled = False
   Login.BackColor = &H8000000F
   Pass.Enabled = False
   Pass.BackColor = &H8000000F
   Login.Text = ""
Else
   Label3.Caption = "IP or HostName :"
   If Protocol.ListIndex = 5 Then
     Label3.Caption = "COM :"
   ElseIf Protocol.ListIndex = 4 Then
     Label3.Caption = "Session Name :"
   End If
   Login.Enabled = True
   Login.BackColor = &H80000005
   Pass.Enabled = True
   Pass.BackColor = &H80000005
End If
End Sub

'send command to device @
Private Sub SendCmd_Click()
Dim Rcv As String
Dim result As Integer

'Send command
result = SendRcvData_O(ConnexionId, Text6.Text, "", "", 0, Rcv, 0, 2)
'Check result of command
If (result <> 0) Then
    Text4.Text = "Failed to send data"
Else
    Text4.Text = Datarcv
End If
Text6.Text = ""
End Sub

Private Sub SendFct_Click()
Timer3.Interval = 100
Text4.Text = "Waiting ,TimeCapture == 1 second"
End Sub

'Send Data and wait reply during 1 second
Private Sub SendWait()

Dim result As Integer

result = SendRcvData_O(ConnexionId, Text2.Text, "", "", 1000, Datarcv, 10000, 0)
'Check result of command
If (result <> 0) Then
    Text3.Text = "Failed to send data"
Else
    Text3.Text = Datarcv
End If
Text2.Text = ""
End Sub

Private Sub Text6_KeyPress(KeyAscii As Integer)
If KeyAscii = 13 Then
  SendCmd_Click
End If
End Sub

Private Sub Timer1_Timer()
Connect
Timer1.Interval = 0
End Sub
Private Sub Timer2_Timer()
UpdateData
Timer2.Interval = 0
End Sub

Private Sub Timer3_Timer()
SendWait
Timer3.Interval = 0
End Sub

'Data are received through Callback function : update data and size
Public Sub RcvData(ByVal BufA As Long, ByVal size As Long)
  Buf = BufA
  Sizedata = size
  Timer2.Interval = 1
End Sub

'Display data received through Callback function
Private Sub UpdateData()
  Dim VbBuf As String
   
    VbBuf = String(Sizedata + 5, vbNullChar)
    CopyMemory VbBuf, Buf, Sizedata
    Text1.Text = Text1.Text & VbBuf
    Text1.SelStart = Len(Form1.Text1.Text)
    Text1.SelText = ""
    VbBuf = ""
    Text6.SetFocus
End Sub
