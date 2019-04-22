#NoTrayIcon
#include "Aut2Exe\Include\ButtonConstants.au3"
#include "Aut2Exe\Include\ComboConstants.au3"
#include "Aut2Exe\Include\GUIConstantsEx.au3"
#include "Aut2Exe\Include\WindowsConstants.au3"
#include "Aut2Exe\Include\GuiComboBox.au3"
#include "Aut2Exe\Include\EditConstants.au3"
#include "Aut2Exe\Include\GuiComboBoxEx.au3"


; Global vars.
Global $GUI_ENABLE_DEFBUTTON = 576
$IDNumber = ""
$ConnectionEstablished = False

; Read settings file.
$RepeaterAddress = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "Address", "")
If $RepeaterAddress = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "Address", "telem.fr")
	$RepeaterAddress = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "Address", "telem.fr")
EndIf
$RepeaterAddressLAN = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "AddressLAN", "")
If $RepeaterAddressLAN = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "AddressLAN", "192.168.0.12")
	$RepeaterAddressLAN = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "AddressLAN", "192.168.0.12")
EndIf
$RepeaterViewerPort = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", "")
If $RepeaterViewerPort = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", "443")
	$RepeaterViewerPort = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", "443")
EndIf

; Read messages in ini file.
; $Error = 					IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "ERROR" )
; $NotCompiled = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "Script must be compiled before running!" )
; $SwitchMode = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "Switch Mode" )
; $ClearHistory = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "Clear History" )
; $About = 					IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "About" )
; $ConnectingTo = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "Connecting to" )
; $Repeater = 				IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "Repeater" )
; $ConnectionFailed = 		IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", "connection failed!" )
; $StrConnectionEstablished = IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", "connection established!" )
; $HistoryCleared = 		IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", "History Cleared." )
; $CustomizedBy = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", "Customized by" )
$Error = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "")
$NotCompiled = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "")
$SwitchMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "")
$ClearHistory = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "")
$About = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "")
$ConnectingTo = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "")
$Repeater = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "")
$ConnectionFailed = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", "")
$StrConnectionEstablished = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", "")
$HistoryCleared = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", "")
$CustomizedBy = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", "")


; Create messages in ini file if they don't exist.
If $Error = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "ERREUR")
	$Error = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "ERREUR")
EndIf
If $NotCompiled = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "Ce script doit être compilé avant exécution !")
	$NotCompiled = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "Ce script doit être compilé avant exécution !")
EndIf
If $SwitchMode = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "Bascule mode DNS/mode IP")
	$SwitchMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "Bascule mode DNS/mode IP")
EndIf
If $ClearHistory = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "Supprimer l'historique")
	$ClearHistory = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "Supprimer l'historique")
EndIf
If $About = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "A propos")
	$About = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "A propos")
EndIf
If $ConnectingTo = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "Connexion à")
	$ConnectingTo = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "Connexion à")
EndIf
If $Repeater = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "Répèteur")
	$Repeater = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "Répèteur")
EndIf
If $ConnectionFailed = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", ", connexion échouée !")
	$ConnectionFailed = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", ", connexion échouée !")
EndIf
If $StrConnectionEstablished = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", ", connexion établie !")
	$StrConnectionEstablished = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", ", connexion établie !")
EndIf
If $HistoryCleared = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", "Historique éffacé.")
	$HistoryCleared = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", "Historique éffacé.")
EndIf
If $CustomizedBy = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", "Modifié par")
	$CustomizedBy = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", "Modifié par")
EndIf

; Exit if the script hasn't been compiled
If NOT @Compiled Then
	MsgBox(0, $Error, $NotCompiled, 1)
;	Exit
EndIf

$IDList = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")

$IDListMax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "")
$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "")
$Quality = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", "")

; AutoScale connect string
$AutoScale = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", "0")
If $AutoScale = 1 Then
	$StrAutoScale = " -autoscaling"
Else
	$StrAutoScale = ""
EndIf

; Password conect string
$Password = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Password", "")
If $Password <> "" Then
	$StrPassword = " -password " & $Password
Else
	$StrPassword = ""
EndIf

; If we are in LAN mode use the LAN IP.
If $LANMode = 1 Then $RepeaterAddress = $RepeaterAddressLAN

; Create the GUI.
$Form1 = GUICreate("Instant Support Viewer", 300, 80, -1, -1)
GUISetBkColor(0xFFFFFF)
$Button1 = GUICtrlCreateButton("Connect", 185, 10, 100, 39)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
GUICtrlSetState($Button1, $GUI_DISABLE)
$Combo1 = GUICtrlCreateCombo("", 15, 11, 155, 25)
GUICtrlSetFont(-1, 20, 800, 0, "MS Sans Serif")
_GUICtrlComboBox_LimitText( $Combo1, 6 )	; Limit the number of characters to 6 for input.
$Line1 = GUICtrlCreateLabel("", 0, 60, 300, 1)
GUICtrlSetBkColor( -1, 0x000000 )
$Label1 = GUICtrlCreateLabel("", 5, 65, 300, 15)
GUICtrlSetFont($Label1, 8, 400, 0, "MS Sans Serif")

; Create right-click context menu for Combo1.
$ContextMenu1 = GUICtrlCreateContextMenu($Combo1)
$ContextMenuMode1 = GUICtrlCreateMenuItem($SwitchMode, $ContextMenu1)
$ContextMenuHistory1 = GUICtrlCreateMenuItem($ClearHistory, $ContextMenu1)
$ContextMenuBlank1 = GUICtrlCreateMenuItem("", $ContextMenu1)
$ContextMenuAbout1 = GUICtrlCreateMenuItem($About, $ContextMenu1)

; Fill Combo1 and show current repeater address.
GUICtrlSetData($Combo1, $IDList)
GUISetState(@SW_SHOW, $Form1)

; Check to see if the repeater exists.
TCPStartup()

If $LANMode = 0 Then
	$TestAddress = $RepeaterAddress
	GUICtrlSetData($Label1, $ConnectingTo & " : " & $RepeaterAddress & ":" & $RepeaterViewerPort)
Else
	$TestAddress = $RepeaterAddressLAN
	GUICtrlSetData($Label1, $ConnectingTo & " : " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort)
EndIf

$socket = TCPConnect(TCPNameToIP($TestAddress), $RepeaterViewerPort)

If $socket = -1 Then
	GUICtrlSetData($Label1, $Repeater & " " & $TestAddress & " " & $ConnectionFailed)
Else
	GUICtrlSetData($Label1, $Repeater & " " & $TestAddress & " " & $StrConnectionEstablished)
	$ConnectionEstablished = True
EndIf

TCPShutdown()

; Main loop.
While 1
	; Disable the Connect button if empty, alphabetic characters or incorrect ID format or if connection to the repeater failed.
	If $IDNumber <> GUICtrlRead($Combo1) Then
		$IDNumber = GUICtrlRead($Combo1)
		If $IDNumber <> "" AND StringIsDigit($IDNumber) = 1 AND $IDNumber >= 100000 AND $IDNumber <= 999999 AND $ConnectionEstablished = True Then
			GUICtrlSetState($Button1, $GUI_ENABLE_DEFBUTTON)
		Else
			GUICtrlSetState($Button1, $GUI_DISABLE)
		EndIf
	EndIf
	
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		; Switch between LAN and WAN Mode.
		Case $ContextMenuMode1
			If $LANMode = 0 Then
				IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "1")
			Else
				IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
			EndIf
			Run(@ScriptFullPath)
			Exit
		; Clear history.
		Case $ContextMenuHistory1
			GUICtrlSetData($Label1, $HistoryCleared)
			GUICtrlSetData($Combo1, "")
			IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")
		; About
		Case $ContextMenuAbout1
			GUICtrlSetData($Label1, "Instant Support Viewer - " & $CustomizedBy & " BigBod.")
		; Connect
		Case $Button1
			; Mac InstantSupport values are 100000 to 200000, higher values are for Windows
			If $IDNumber < 200000 Then
				; Start Viewer without encryption for Mac
				If $LANMode = 0 Then
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddress & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & " -keepalive 1")
				Else
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & " -keepalive 1")
				EndIf
			Else
				; Start Viewer with encryption for Windows
				If $LANMode = 0 Then
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddress & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $StrAutoScale & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $StrPassword)
				Else
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $StrAutoScale & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $StrPassword)
				EndIf
			EndIf
			; Don't save more than ListMax, keep in mind we assume a 6 digit number.
			If StringLen($IDList) >= ($IDListMax * 6 + ($IDListMax - 1)) Then
				; Maximum ID's in list, trim
				$IDList = $IDNumber & "|" & StringTrimRight($IDList, 7)
			Else
				; Maximum ID's not yet reached.
				If $IDList = "" Then
					$IDList = $IDNumber
				Else
					$IDList = $IDNumber & "|" & $IDList
				EndIf
			EndIf
			; Save IDList in instantviewer.ini
			IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", $IDList)
			Exit
	EndSwitch
WEnd
