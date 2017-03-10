;
; Repair Bruker Artax 400 export names
;

#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

;INCLUDE
#include <GUIConstantsEx.au3>
#include <GUIComboBox.au3>
#include <GUIEdit.au3>
#include <File.au3>

;VAR

$mapping = @ScriptDir & '\spectra.txt'

;CONTROL
;already running
If UBound(ProcessList(@ScriptName)) > 2 Then Exit

;GUI
$gui = GUICreate("ArtaxRename v 1.0", 356, 91)
$gui_path = GUICtrlCreateInput("", 8, 8, 260, 21)
$button_path = GUICtrlCreateButton("Prochazet", 275, 8, 75, 21)
$gui_progress = GUICtrlCreateProgress(6, 38, 343, 16)
$gui_error = GUICtrlCreateLabel("", 8, 65, 178, 15)
$button_export = GUICtrlCreateButton("Oprava", 193, 63, 75, 21)
$button_exit = GUICtrlCreateButton("Konec", 275, 63, 75, 21)

;GUI INIT
GUICtrlSetState($button_path, $GUI_FOCUS)
GUISetState(@SW_SHOW)

While 1
	$event = GUIGetMsg() ; catch event
	If $event = $button_path Then ; data path
		$export_path = FileSelectFolder("Artax/Export Directory", @HomeDrive, Default)
		If Not @error Then
			GUICtrlSetData($gui_path, $export_path)
		EndIf
	EndIf
	If $event = $button_export Then ; rename
		Local $map
		_FileReadToArray($mapping, $map, 0)
		If @error Then
			GUICtrlSetData($gui_error, "Chyba: Nacteni seznamu selhalo.")
		ElseIf GUICtrlRead($gui_path) == '' Then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		ElseIf Not FileExists(GUICtrlRead($gui_path)) Then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		Else
			;			_ArrayDisplay($map)
			$filelist = _FileListToArrayRec(GUICtrlRead($gui_path), 'tab*.*', 1, 1, 1, 2) ; recursion, files only, sorted, fullpath..
			If UBound($filelist) < 2 Then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			Else
				;				_ArrayDisplay($filelist)
				For $i = 1 To UBound($filelist) - 1
					GUICtrlSetData($gui_progress, Round($i / (UBound($filelist) - 1) * 100)) ; update progress
					GUICtrlSetData($gui_error, StringRegExpReplace($filelist[$i], ".*\\(.*)$", "$1"))
					MsgBox(Default, "orig", StringRegExpReplace($filelist[$i], ".*\\(.*)(_graph)?\..*$", "$1"))
					$name = get_spectra(StringRegExpReplace($filelist[$i], ".*\\(.*)(_graph)?\..*$", "$1"), $map)
					MsgBox(Default, "name", $name)
					If $name Then
						MsgBox(Default, "ren", $filelist[$i] & " to " & StringRegExpReplace($filelist[$i], "(.*\\)(.*)(_.*)$", "$1" & $name & "$3"))
						;FileMove($filelist[$i],StringRegExpReplace($filelist[$i], "(.*\\)(.*)(_.*)$", "$1" & $name & "$2"))
					Else
						ContinueLoop
					EndIf
					Sleep(50)
				Next
				GUICtrlSetData($gui_progress, 0) ; clear progress
				GUICtrlSetData($gui_error, "Hotovo!")
			EndIf
		EndIf
	EndIf
	If $event = $GUI_EVENT_CLOSE Or $event = $button_exit Then
		Exit ; exit
	EndIf
WEnd

Func get_spectra($sid, $map)
	For $i = 0 To UBound($map) - 1
		If $sid == StringSplit($map[$i], ';', 2)[0] Then Return StringSplit($map[$i], ';', 2)[1]
	Next
EndFunc

