Dim WSHShell
Dim oProgramfiles
Set WSHShell = WScript.CreateObject("WScript.Shell")
WSHShell.Environment.item("ExtraPuTTY_MODE") = "REG_MODE"
oProgramfiles = Chr(34) & WSHShell.ExpandEnvironmentStrings("%ExtraPuTTY%")
Set WSHShell = Nothing 
Set wshell=CreateObject("WScript.Shell")
intAnswer = MsgBox("Be careful you should made a backup of your putty registry sessions before running this script, continue ?" ,vbYesNo, "ExtraPuTTY") 
If intAnswer = vbYes Then
wshell.Run oProgramfiles & "\putty.exe" & Chr(34) & "-sessions-file-to-reg" 
MsgBox "End" ,, "ExtraPuTTY" 
End If
WScript.Quit(0)