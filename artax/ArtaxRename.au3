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

$mapping = @ScriptDir & '\artax_nazvy.txt'
local $map; mapping array

;CONTROL
;already running
if UBound(ProcessList(@ScriptName)) > 2 then Exit

;GUI
$gui = GUICreate("ArtaxRename v 1.0", 356, 91)
$gui_path = GUICtrlCreateInput("", 8, 8, 260, 21)
$button_path = GUICtrlCreateButton("Prochazet", 275, 8, 75, 21)
$gui_progress = GUICtrlCreateProgress(6, 38, 343, 16)
$gui_error = GUICtrlCreateLabel("", 8, 65, 178, 15)
$button_export = GUICtrlCreateButton("Oprava", 193, 63, 75, 21)
$button_exit = GUICtrlCreateButton("Konec", 275, 63, 75, 21)

;GUI INIT
GUICtrlSetState($button_path,$GUI_FOCUS)
GUISetState(@SW_SHOW)

While 1
	$event = GUIGetMsg(); catch event
	if $event = $button_path Then; data path
		$export_path = FileSelectFolder("Artax/Export Directory", @HomeDrive, Default)
		if not @error then
				GUICtrlSetData($gui_path, $export_path)
		endif
	EndIf
	if $event = $button_export Then; rename
		if GUICtrlRead($gui_path) == '' then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		Elseif not FileExists(GUICtrlRead($gui_path)) Then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		else
			_FileReadToArray($mapping, $map, 0)
			if @error then
				GUICtrlSetData($gui_error, "Chyba: Nacteni mapy selhalo.")
			else
				$filelist = _FileListToArrayRec(GUICtrlRead($gui_path), 'tab*.*',1,1,1,2); recursion, files only, sorted, fullpath..
				if ubound($filelist) < 2 then
					GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
				else
					for $i=1 to UBound($filelist) - 1
						GUICtrlSetData($gui_progress, round( $i / (UBound($filelist) - 1) * 100)); update progress
						GUICtrlSetData($gui_error, StringRegExpReplace($filelist[$i], ".*\\(.*)$", "$1"))
						sleep(50)
					next
					GUICtrlSetData($gui_progress,0); clear progress
					GUICtrlSetData($gui_error, "Hotovo!")
				endif
			endif
		endif
	endif
	If $event = $GUI_EVENT_CLOSE or $event = $button_exit then
		Exit; exit
	endif
WEnd

func get_map()
	;load file
	;test data
EndFunc