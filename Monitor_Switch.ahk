; Version v.1.0.23.01.13
; by GothicIII
; Monitor-Switch
; Toggle between 2nd Monitor only and Extended Monitor
#NoTrayIcon
#SingleInstance Force
#include StreamDecklib.ahk
; Parse through arguments
try
{
	port := A_Args[2]
	pluginUUID := A_Args[4]
	registerevent := A_Args[6]
}
catch
{
	Msgbox("Please do not run this program directly!")
	ExitApp
}

Monitor:=WebSocketEx("ws://127.0.0.1:" . port)
class WebSocketEx extends basic_WebSocket
{
	; qualifies as a Main() loop while the websocket is active.
	OnMessage(Event)
	{
		jsonobj := JsonToMap(Event.data)
		if jsonobj["event"]="keyDown" or jsonobj["event"]="willAppear"
		{
			if CheckMonitor(jsonobj["context"])=1
				Option:=0x00000084
			else
				Option:=0x00000088
			if jsonobj["event"]="keyDown"
				DllCall("user32\SetDisplayConfig", "uint", 0, "ptr", 0, "uint", 0, "ptr", 0, "uint", Option)
			CheckMonitor(jsonobj["context"])
		}
	}
}

CheckMonitor(context)
{
	if ret:=SysGet(80)=1
	{
		File:="SingleMonitor.png"
		monmode:="Single Monitor"
	}
	else
	{
		File:="DualMonitor.png"
		monmode:="Dual Monitor"
	}
	sendmap := Map("event","setTitle","context",context,"payload",Map("title","_str_" . monmode,"target",0))
	Monitor.Send(MapToJSONStr(sendmap))
	sendmap := Map("event","setImage","context",context,"payload",Map("image","data:image/png;base64," . FileTob64(File),"target",0))
	Monitor.Send(MapToJSONStr(sendmap))
	return ret
}