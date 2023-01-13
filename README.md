# AHK_StreamDeck_lib
AHK-Library to use with StreamDeck from Elgato.
Implemented: 
- Base64 encoding for sending an image, 
- websocket creation/communication,
- JSON<=>Map converter functions

How it works:
Creates an invisible Edge browser session which loads a local webpage with JS elements injected.
Connects to a websocket with parameters provided from StreamDeck Software though the Edge browser session.
JS Code is used for a websocket connection, sending and receiving Strings.
All Websocket events are send from the Edge browser session directly to AHK.
AHK converts the JSON-String to a Map-Object so objects can be get/set easily by programming logic.
After the received event data is processed, AHK creates a JSON-like Map object (which is currently created manually) and
converts it back to a JSON-String to be send back again through the Edge browser session to the StreamDeck Software.

Example Program (more coming in future) to switch between Monitor states (2nd Monitor only and Extended Screen).
- Loads custom icon depending on state (Single or Extended monitor) to the StreamDeck button
- Changes Title String of the button

Usage: 
1. Terminate the StreamDeck Application
2. Copy the "com.gothiciii.monitorswitch.sdPlugin" folder to %AppData%\Roaming\Elgato\StreamDeck\Plugins
3. Compile Monitor_Switch.ahk to Monitor_Switch.exe and put it inside the com.gothiciii.monitorswitch.sdPlugin
4. Run StreamDeck Application. The plugin should be loaded and available as Drag&Drop Item from Custom-Group


Requirements:
-StreamDeck
-AHK2Exe

Tested on Windows 11. Should work for Windows 8 onwards.
