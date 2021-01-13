Attribute VB_Name = "Callback"


Public Function setCallBack(ByVal ConnexionId As Long, ByVal Buf As Long, ByVal size As Integer, ByVal status As Integer) As Integer
   'data received and status of connection ok
   If (size > 0) And (status = 0) Then
     Form1.RcvData Buf, size
  ElseIf (status <> 0) Then
   MsgBox "Connection closed by remote host", vbCritical, "Error"
   End If
End Function

