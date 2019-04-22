#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=InstantSupport_Files\icon1.ico
#AutoIt3Wrapper_Outfile=InstantViewer.exe
#AutoIt3Wrapper_Res_Description=Ouvre un VNC sur le canal Instant Support
#AutoIt3Wrapper_Res_LegalCopyright=BigBod
#AutoIt3Wrapper_Res_Language=1036
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version : 3.3.6.1
 Auteur:         BigBod

 Fonction du Script :
	Permet d'ouvrir une session VNCviewer sur un canal Instant Support.
	- Stock la configuration dans un fichier ini
	- Recrée le sous-répertoire de configuration et d'outils "Bin" de manière autonome
	- Prendre en charge les anciens fichiers ini
	- si c'était un ancien fichier ini, faire un rebuildini automatiquement
	- Mise en fonction du check de la connection TCP/IP
	- Basculer automatiquement en Mode IP si en DNS on a pas eu d'accès à telem.fr au départ
	- Basculer automatiquement en Mode IP si en DNS on a pas eu d'accès à telem.fr, et inversement quand on manipule le switch "Bascule mode DNS/mode IP"

A faire :
	- Mémorisation de la dernière position de la fenêtre Instant Support Viewer
	- Faire une bascule entre affichage liste longue et liste courte
	- Modification de liste pour que les doublons entre listview et listmax ne s'affichent pas
	- permettre de forcer un rebuildini avec un lancement spécifique avec commutateur
	- permettre de changer de langue peut-être un autre programme qui irai modifier la source

#ce ----------------------------------------------------------------------------

; Début du script - Ajouter votre code ci-dessous.
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
$OldIni = False

; Extract files if necessary.
If FileExists(@ScriptDir & "\Bin")=0 Then
;	MsgBox(0, $BinPath, "true", 10)
	DirCreate(@ScriptDir & "\Bin")
; Else
;	MsgBox(0, $BinPath, "false", 10)
EndIf
If FileExists(@ScriptDir & "\Bin\vncviewer.exe")=0 Then
	FileInstall( "Bin\vncviewer.exe", @ScriptDir & "\Bin\vncviewer.exe", 1 )
EndIf
If FileExists(@ScriptDir & "\Bin\SecureVNCPlugin.dsm")=0 Then
	FileInstall( "Bin\SecureVNCPlugin.dsm", @ScriptDir & "\Bin\SecureVNCPlugin.dsm", 1 )
EndIf
If FileExists(@ScriptDir & "\Bin\instantviewer.ini")=0 Then
	FileInstall( "Bin\instantviewer.ini", @ScriptDir & "\Bin\instantviewer.ini", 1 )
EndIf

; Read settings file, create and/or repair settings if necessary.
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
	$OldRepeaterViewerPort = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "ViewerPort", "")
	If $OldRepeaterViewerPort = "" Then
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", "443")
	Else
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", $OldRepeaterViewerPort)
		$OldIni = True
	EndIf
	$RepeaterViewerPort = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", "443")
EndIf
$Password = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Password", "")
If $Password = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Password", "password")
	$Password = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Password", "password")
EndIf
$IDList = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")
If $IDList = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")
	$IDList = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")
EndIf
$Listview = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", "")
If $Listview = "" Then
;	MsgBox(0, "Listview", "true $Listview : " & $Listview, 10)
	$Listmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "")
	If $Listmax = "" Then
		$OldListmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ListMax", "")
		If $OldListmax = "" Then
			IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "10")
		Else
			IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", $OldListmax)
			$OldIni = True
		EndIf
		$Listmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "10")
	EndIf
	$nb = $Listmax + 10
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", $nb)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", $Listmax)
	$Listview = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", "10")
EndIf
$Listmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "")
If $Listmax = "" Then
	$OldListmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ListMax", "")
	If $OldListmax = "" Then
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "10")
	Else
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", $OldListmax)
		$OldIni = True
	EndIf
	$Listmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "10")
EndIf
; MsgBox(0, "Listview", "$Listview : " & $Listview, 10)
; MsgBox(0, "Listmax", "$Listmax : " & $Listmax, 10)
If Number($Listmax) < Number($Listview) Then
;	MsgBox(0, "$Listmax < $Listview", "true $Listview : " & $Listview & " $Listmax : " & $Listmax, 10)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", $Listview)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", $Listmax)
	$Listview = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", "10")
	$Listmax = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", "11")
;	MsgBox(0, "$Listmax < $Listview", "END $Listview : " & $Listview & " $Listmax : " & $Listmax, 10)
EndIf
; MsgBox(0, "after $Listmax < $Listview", "$Listview : " & $Listview & " $Listmax : " & $Listmax)
$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "")
If $LANMode = "" Then
	$OldLANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "LANMode", "0")
	If $OldLANMode = "" Then
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
	Else
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", $OldLANMode)
		$OldIni = True
	EndIf
	$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
EndIf
$Quality = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", "")
If $Quality = "" Then
	$OldQuality = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Quality", "")
	If $OldQuality = "" Then
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", "3")
	Else
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", $OldQuality)
		$OldIni = True
	EndIf
	$Quality = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", "3")
EndIf
$AutoScale = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", "")
If $AutoScale = "" Then
	$OldAutoScale = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "AutoScale", "")
	If $OldAutoScale = "" Then
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", "0")
	Else
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", $OldAutoScale)
		$OldIni = True
	EndIf
	$AutoScale = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", "0")
EndIf

; Read messages in ini file.
; $Error = 					IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "ERROR" )
; $NotCompiled = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "Script must be compiled before running!" )
; $SwitchMode = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "Switch Mode" )
; $RebuildIni = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "RebuildIni", "Rebuild Ini")
; $ClearHistory = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "Clear History" )
; $About = 					IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "About" )
; $ConnectingTo = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "Connecting to" )
; $Repeater = 				IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "Repeater" )
; $ConnectionFailed = 		IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", "connection failed!" )
; $StrConnectionEstablished = IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", "connection established!" )
; $FileRebuild = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "FileRebuild", "File rebuild.")
; $HistoryCleared = 		IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", "History Cleared." )
; $CustomizedBy = 			IniRead( @ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", "Customized by" )
$Error = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", "")
$NotCompiled = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", "")
$SwitchMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", "")
$RebuildIni = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "RebuildIni", "")
$ClearHistory = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", "")
$About = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "About", "")
$ConnectingTo = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", "")
$Repeater = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", "")
$ConnectionFailed = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", "")
$strConnectionEstablished = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", "")
$FileRebuild = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "FileRebuild", "")
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
If $RebuildIni = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "RebuildIni", "Refaire le fichier")
	$RebuildIni = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "RebuildIni", "Refaire le fichier")
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
If $strConnectionEstablished = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", ", connexion établie !")
	$strConnectionEstablished = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", ", connexion établie !")
EndIf
If $FileRebuild = "" Then
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "FileRebuild", "Le fichier Ini a été reconstruit.")
	$FileRebuild = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Message", "FileRebuild", "Le fichier a été reconstruit.")
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
	Exit
EndIf

; Rebuild Ini if necessary
If $OldIni = True Then
	RebuildConf()
EndIf

; Password connect string
If $Password <> "" Then
	$strPassword = " -password " & $Password
Else
	$strPassword = ""
EndIf

; Prepare List in instantviewer.ini, $IDListmax and $IDListview
$IDListmax = StringTrimRight($IDList, StringLen($IDList) - ($Listmax * 6 + ($Listmax - 1)))
IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", $IDListmax)
$IDList = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", "")
$IDListview = StringTrimRight($IDListmax, StringLen($IDListmax) - ($Listview * 6 + ($Listview - 1)))

; If we are in LAN mode use the LAN IP.
If $LANMode = 1 Then $RepeaterAddress = $RepeaterAddressLAN

; AutoScale connect string
If $AutoScale = 1 Then
	$strAutoScale = " -autoscaling"
Else
	$strAutoScale = ""
EndIf

; Create String for RebuildIni
$strRebuildIni = $RebuildIni & " Ini"

; Create the GUI.
$Form1 = GUICreate("Instant Support Viewer", 300, 80, -1, -1)
GUISetBkColor(16777215)
$Button1 = GUICtrlCreateButton("Connect", 185, 10, 100, 39)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
GUICtrlSetState($Button1, $GUI_DISABLE)
$Combo1 = GUICtrlCreateCombo("", 15, 11, 155, 25)
GUICtrlSetFont(-1, 20, 800, 0, "MS Sans Serif")
_guictrlcombobox_limittext($Combo1, 6)	; Limit the number of characters to 6 for input.
$Line1 = GUICtrlCreateLabel("", 0, 60, 300, 1)
GUICtrlSetBkColor(-1, 0)
$Label1 = GUICtrlCreateLabel("", 5, 65, 300, 15)
GUICtrlSetFont($Label1, 8, 400, 0, "MS Sans Serif")

; Create right-click context menu for Combo1.
$ContextMenu1 = GUICtrlCreateContextMenu($Combo1)
$ContextMenuMode1 = GUICtrlCreateMenuItem($SwitchMode, $ContextMenu1)
$ContextMenuRebuild1 = GUICtrlCreateMenuItem($strRebuildIni, $ContextMenu1)
$ContextMenuHistory1 = GUICtrlCreateMenuItem($ClearHistory, $ContextMenu1)
$ContextMenuBlank1 = GUICtrlCreateMenuItem("", $ContextMenu1)
$ContextMenuAbout1 = GUICtrlCreateMenuItem($About, $ContextMenu1)

; Fill Combo1 and show current repeater address.
GUICtrlSetData($Combo1, $IDListview)
GUISetState(@SW_SHOW, $Form1)

; Affiche le message file rebuild si OldIni
If $OldIni = True Then
	GUICtrlSetData($Label1, $FileRebuild)
	Sleep(1000)
EndIf

; Check to see if the repeater exists.
; MsgBox(0, "$ConnectionEstablished init 1", "$ConnectionEstablished : " & $ConnectionEstablished)
CheckSocket()
; MsgBox(0, "$ConnectionEstablished init 2", "$ConnectionEstablished : " & $ConnectionEstablished)
If NOT $ConnectionEstablished Then
	If $LANMode = 0 Then
;		MsgBox(0, "$LANMode=0 init", "true $LANMode : " & $LANMode)
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "1")
	Else
;		MsgBox(0, "$LANMode=0 init", "false $LANMode : " & $LANMode)
		IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
	EndIf
	$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
;	MsgBox(0, "$LANMode init", "$LANMode : " & $LANMode)
;	MsgBox(0, "$ConnectionEstablished avant deuxième Check", "$ConnectionEstablished : " & $ConnectionEstablished)
	CheckSocket()
;	MsgBox(0, "$ConnectionEstablished après deuxième Check", "$ConnectionEstablished : " & $ConnectionEstablished)
EndIf

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
;				MsgBox(0, "$LANMode=0", "true $LANMode : " & $LANMode)
				IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "1")
			Else
;				MsgBox(0, "$LANMode=0", "false $LANMode : " & $LANMode)
				IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
			EndIf
			$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
;			MsgBox(0, "$LANMode", "$LANMode : " & $LANMode)
;			MsgBox(0, "$ConnectionEstablished avant Check", "$ConnectionEstablished : " & $ConnectionEstablished)
			CheckSocket()
;			MsgBox(0, "$ConnectionEstablished après Check", "$ConnectionEstablished : " & $ConnectionEstablished)
			If NOT $ConnectionEstablished Then
				If $LANMode = 0 Then
;					MsgBox(0, "$LANMode=0 deuxième", "true $LANMode : " & $LANMode)
					IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "1")
				Else
;					MsgBox(0, "$LANMode=0 deuxième", "false $LANMode : " & $LANMode)
					IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
				EndIf
				$LANMode = IniRead(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", "0")
;				MsgBox(0, "$LANMode deuxième", "$LANMode : " & $LANMode)
;				MsgBox(0, "$ConnectionEstablished deuxième avant Check", "$ConnectionEstablished : " & $ConnectionEstablished)
				CheckSocket()
;				MsgBox(0, "$ConnectionEstablished deuxième après Check", "$ConnectionEstablished : " & $ConnectionEstablished)
			EndIf
;			Run(@ScriptFullPath)
;			Exit
		; Rebuild Ini file.
		Case $ContextMenuRebuild1
			RebuildConf()
			GUICtrlSetData($Label1, $FileRebuild)
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
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddress & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $strAutoScale & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $strPassword)
				Else
					ShellExecute(@ScriptDir & "\Bin\vncviewer.exe", "-proxy " & $RepeaterAddressLAN & ":" & $RepeaterViewerPort & " ID:" & $IDNumber & " -quickoption " & $Quality & $strAutoScale & " -keepalive 1 -dsmplugin SecureVNCPlugin.dsm" & $strPassword)
				EndIf
			EndIf
			; Don't save more than ListMax, keep in mind we assume a 6 digit number.
			If StringLen($IDList) >= ($Listmax * 6 + ($Listmax - 1)) Then
				; Maximum ID's in list, add for futher treatment
				$IDList = $IDNumber & "|" & $IDList
			Else
				; Maximum ID's not yet reached.
				If $IDList = "" Then
					$IDList = $IDNumber
				Else
					$IDList = $IDNumber & "|" & $IDList
				EndIf
			EndIf
			; Save IDList in instantviewer.ini
			$IDListmax = StringTrimRight($IDList, StringLen($IDList) - ($Listmax * 6 + ($Listmax - 1)))
			IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", $IDListmax)
			Exit
	EndSwitch
WEnd

Func CheckSocket()
	$ConnectionEstablished = False
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
		GUICtrlSetData($Label1, $Repeater & " " & $TestAddress & " " & $strConnectionEstablished)
		$ConnectionEstablished = True
	EndIf
	TCPShutdown()
EndFunc

Func RebuildConf()
	FileInstall( "Bin\instantviewer.ini", @ScriptDir & "\Bin\instantviewer.ini", 1 )
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "Address", $RepeaterAddress)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Repeater", "AddressLAN", $RepeaterAddressLAN)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "ViewerPort", $RepeaterViewerPort)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "Password", $Password)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "InstantViewer", "List", $IDList)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListView", $Listview)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "ListMax", $Listmax)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Viewer", "LANMode", $LANMode)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "Quality", $Quality)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "VncViewer", "AutoScale", $AutoScale)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Error", $Error)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "NotCompiled", $NotCompiled)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "SwitchMode", $SwitchMode)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "RebuildIni", $RebuildIni)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ClearHistory", $ClearHistory)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "About", $About)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectingTo", $ConnectingTo)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "Repeater", $Repeater)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionFailed", $ConnectionFailed)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "ConnectionEstablished", $strConnectionEstablished)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "FileRebuild", $FileRebuild)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "HistoryCleared", $HistoryCleared)
	IniWrite(@ScriptDir & "\Bin\instantviewer.ini", "Message", "CustomizedBy", $CustomizedBy)
EndFunc
