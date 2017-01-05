
#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <GUIComboBox.au3>
#include <GUIEdit.au3>
#include <File.au3>

$artax = 'c:\artax\program\Artax\ARTAX.exe'
$runtime = @YEAR & @MON & @MDAY & 'T' & @HOUR & @MIN & @SEC
$log = @scriptdir & '\ArtaxExport.log'

;LOGGING

$logfile = FileOpen($log, 1); append..
if @error then exit; silent exit..
$history = StringRegExpReplace(FileReadLine($log, -1), "(.*)\|.*", "$1")
logger(@CRLF & "Program start: " & $runtime)

;CONTROL

;already running
if UBound(ProcessList(@ScriptName)) > 2 then exit

;GUI

$gui = GUICreate("ArtaxExport v 1.0", 351, 91)
$gui_path = GUICtrlCreateInput($history, 6, 8, 255, 21)
$button_path = GUICtrlCreateButton("Prochazet", 270, 8, 75, 21)
$gui_progress = GUICtrlCreateProgress(6, 38, 338, 16)
$gui_error = GUICtrlCreateLabel("", 8, 65, 168, 15)
$button_export = GUICtrlCreateButton("Export", 188, 63, 75, 21)
$button_exit = GUICtrlCreateButton("Konec", 270, 63, 75, 21)

;GUI INIT
GUICtrlSetState($gui_path,$GUI_FOCUS)
_GUICtrlEdit_SetSel($gui_path,-1,-1)

GUISetState(@SW_SHOW)

While 1
	$event = GUIGetMsg(); catch event
	if $event = $button_path Then; data path
		$project_path = FileSelectFolder("ArtaxHelper / Project directory", @HomeDrive, Default, $history)
		if not @error then
				GUICtrlSetData($gui_path, $project_path)
				$history = $project_path; update last..
		endif
	EndIf
	if $event = $button_export Then; export
		if GUICtrlRead($gui_path) == '' then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		elseif not FileExists(GUICtrlRead($gui_path)) Then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		elseif UBound(ProcessList('ARTAX.exe')) >= 2 then
			GUICtrlSetData($gui_error, "Program Artax byl spusten.")
		else
			$project_list = _FileListToArray(GUICtrlRead($gui_path), '*.rtx', 1); files only..
			if ubound($project_list) < 2 then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			else
				GUICtrlSetData($gui_error, "Running!")
				;run($artax & ' ' & $file)
			endif
		endif
	endif
	If $event = $GUI_EVENT_CLOSE or $event = $button_exit then
		logger("Program end.")
		FileWrite($logfile, GUICtrlRead($gui_path) & '|'); history..
		FileClose($logfile)
		Exit; exit
	endif
WEnd


;picture [shift] + C
;graph    [crtl] + C
;table    [crtl] + D

func logger($text)
	FileWriteLine($logfile, $text)
endfunc
