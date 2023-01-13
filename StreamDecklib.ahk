;Version 1.0.23.01.13
; Basic libraries to communicate with the StreamDeck Software
; Implemented: Base64 encoding for sending an image, websocket creation/communication, JSON<=>Map converter functions.
; 
; ToDo:
; - Better Error handling
; - Send Icon function
; - more robust function especially for JSON=>Map

; must be used with an OnMessage() function. Please use class WebSocketEx extends basic_WebSocket{} to write the function
class basic_WebSocket
{
	; creates invisible GUI, runs the webbrowser 'Edge' and points to a local generated website to run JS code.
	__New(WS_URL)
	{	
		EmptyWindow := Gui("+Owner")
		EmptyWindow.Show()
		Webbrowser := Gui("+Parent" EmptyWindow.Hwnd)
		webpage := Webbrowser.Add("ActiveX",, "Shell.Explorer").value
		webpage.navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible' content='IE=edge'><body></body>")
		Webbrowser.Show()	
		this.document:=webpage.document
		this.document.parentWindow.ahk_event := this._Event.Bind(this)
		this.document.parentWindow.ahk_ws_url := WS_URL
		
		; creates a new element with JS code to connect to a websocket. Notifies ahk about events.
		Script := this.document.createElement("script")
		Script.text := "ws = new WebSocket(ahk_ws_url);`n"
		. "ws.onopen = function(event){ahk_event('Open', event);};`n"
		. "ws.onclose = function(event){ahk_event('Close', event);};`n"
		. "ws.onerror = function(event){ahk_event('Error', event);};`n"
		. "ws.onmessage = function(event){ahk_event('Message', event);};`n"
		loop
			try
			{
				this.document.body.appendChild(Script)
				break
			}
			catch
			{
				if A_Index>20
					{
						Msgbox("Webbrowser could not be spawned in time! Execution impossible!")
						ExitApp
					}
				sleep 50
			}
	}
	
	; Passes all websocket events further
	_Event(EventName, Event)
	{
	; uncomment for debugging MassageEvents
		;try 
		;	Msgbox("Event: " EventName "`n" Event.data)
		;catch 
		;	Msgbox("Event: " EventName)
		this.%"On" . EventName%(Event)
	}
	
	; not yet implemented
	OnError(Event)
	{
		Msgbox("Error:`n" Event.data)
		Return
	}
	
	; not yet implemented
	OnClose(Event)
	{
		Msgbox("Event: Disconnect:`n" Event.data)
		Return
	}
	
	; not yet implemented
	OnOpen(Event)
	{
		this.Send('{"event":"' . registerevent . '","uuid":"' . pluginUUID . '"}')
	}
	
	; sends a String to the websocket
	Send(Data)
	{
		this.document.parentWindow.ws.send(Data)
	}	
}

; Creates a Map object from a json String, so objects can be set/get.
; Should fail on String attributes containing ":" or "{" or "}"
JSONToMap(jsonstring)
{
	jsonstring := strreplace(jsonstring,chr(34))
	;empty variables
	jsonstring := strreplace(jsonstring,"{}")
	;remove leading '{' and trailng '}'
	Return hCreateMap(strsplit(substr(jsonstring,2,-1),[",",":"],""))
}

; recursive helper function to create a Map object from a JSON-String
hCreateMap(StrArr, reset:=1)
{
	static pos
	if reset=1
		pos:=1
	mapobj:=Map()
	loop StrArr.length-1
	{
		if A_Index<pos
			continue
		;Msgbox(StrArr[A_Index] ":" StrArr[A_Index+1] "`n pos: " pos)
		;if '}' is detected
		if SubStr(StrArr[A_Index+1],-1,1)=chr(125)
		{
			mapobj.Set(StrArr[A_Index],SubStr(StrArr[A_Index+1],1,-1))
			pos+=2
			break
		}
		;if '{' is detected
		if SubStr(StrArr[A_Index+1],1,1)=chr(123)
		{
			StrArr[A_Index+1] := SubStr(StrArr[A_Index+1],2)
			pos++
			mapobj.Set(StrArr[A_Index],hCreateMap(StrArr,0))
			continue
		}
		;normal variable
		mapobj.Set(StrArr[A_Index],StrArr[A_Index+1])
		pos+=2
	}
	Return mapobj
}

; Converts a Map-Object containing a JSON-Like structure. 
; use '_str_' as prefix for a value to force a String when converting back to JSON-String
; Currently detecting String, Map, Boolean, Int
MapToJSONStr(jsonmap)
{
	;Msgbox("{" strreplace(hMapToJSONStr(jsonmap),chr(34) chr(34),chr(123) chr(125)) "}")
	Return "{" strreplace(hMapToJSONStr(jsonmap),chr(34) chr(34),chr(123) chr(125)) "}"
}

; Recursive helper Function to convert a Map object back to a JSON-String 
hMaptoJSONStr(mapobj)
{
	for nam,val in mapobj
		if type(val)="Map"
			stringchain .= chr(34) nam chr(34) ":{" hMapToJSONStr(val) "},"
		else
		{
			try 
				val := val+0
			catch
				if val!="false" and val!="true"
					val := chr(34) val chr(34)
			stringchain .=  chr(34) nam chr(34) ":" (substr(val,2,5)="_str_"? chr(34) substr(val,7) : val) ","
		}
	Return substr(stringchain,1,-1)
}

; Converts a binary file to an base64-encoded String.
FileTob64(File)
{
	str:=FileRead(File, "RAW")
	size:=0
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", str, "uint", str.size, "uint", 0x40000001, "ptr", 0, "uint*", &size))
        throw Error("conversion failed", -1)
    buf := Buffer(size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", str, "uint", str.size, "uint", 0x40000001, "ptr", buf, "uint*", &size))
        throw Error("conversion failed", -1)
    return StrGet(buf)
}
