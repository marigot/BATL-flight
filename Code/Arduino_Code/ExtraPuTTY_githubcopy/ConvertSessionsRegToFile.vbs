Dim WSHShell
Dim oProgramfiles
Set WSHShell = WScript.CreateObject("WScript.Shell")
WSHShell.Environment.item("ExtraPuTTY_MODE") = "DIR_MODE"
oProgramfiles = Chr(34) & WSHShell.ExpandEnvironmentStrings("%ExtraPuTTY%")
Set WSHShell = Nothing 
Set wshell=CreateObject("WScript.Shell")
wshell.Run oProgramfiles & "\putty.exe" & Chr(34) & "-sessions-reg-to-file"  
MsgBox "End" ,, "ExtraPuTTY"
WScript.Quit(0)