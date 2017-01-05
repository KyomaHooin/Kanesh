
#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <GUIComboBox.au3>
#include <GUIEdit.au3>
#include <File.au3>

$runtime = @YEAR & @MON & @MDAY & 'T' & @HOUR & @MIN & @SEC
$log = @scriptdir & '\ArtaxExport.log'

;LOGGING

$logfile = FileOpen($log, 1); append..
if @error then exit; silent exit..
$path_history = StringRegExpReplace(FileReadLine($log, -1), "(.*)\|.*", "$1")
$exec_history = StringRegExpReplace(FileReadLine($log, -1), ".*\|(.*)", "$1")
logger(@CRLF & "Program start: " & $runtime)

;DIR
DirCreate(@scriptdir & '\export')

;CONTROL

;already running
if UBound(ProcessList(@ScriptName)) > 2 then exit

;GUI

$gui = GUICreate("ArtaxExport v 1.1", 351, 91)
$label_path = GUICtrlCreateLabel("Projekt:", 6, 10, 35, 21)
$gui_path = GUICtrlCreateInput($path_history, 46, 8, 217, 21)
$button_path = GUICtrlCreateButton("Prochazet", 270, 8, 75, 21)
$label_exec = GUICtrlCreateLabel("Artax:", 15, 35, 32, 21)
$gui_exec = GUICtrlCreateInput($exec_history, 46, 33, 217, 21)
$button_exec = GUICtrlCreateButton("Prochazet", 270, 33, 75, 21)
$gui_error = GUICtrlCreateLabel("", 8, 65, 168, 15)
$button_export = GUICtrlCreateButton("Export", 188, 63, 75, 21)
$button_exit = GUICtrlCreateButton("Konec", 270, 63, 75, 21)

;GUI INIT
GUICtrlSetState($gui_path,$GUI_FOCUS)
_GUICtrlEdit_SetSel($gui_path,-1,-1)

GUISetState(@SW_SHOW)

While 1
	global $atx,$pass,$err
	$event = GUIGetMsg(); catch event
	if $event = $button_path Then; data path
		$project_path = FileSelectFolder("ArtaxExport / Project directory", @HomeDrive, Default, $path_history)
		if not @error then
				GUICtrlSetData($gui_path, $project_path)
				$path_history = $project_path; update last..
		endif
	EndIf
	if $event = $button_exec Then; data path
		$exec_path = FileOpenDialog("ArtaxExport / Program file", @HomeDrive, "Artax program (*.exe)")
		if not @error then
				GUICtrlSetData($gui_exec, $exec_path)
				$exec_history = $exec_path; update last..
		endif
	EndIf
	if $event = $button_export Then; export
		if GUICtrlRead($gui_path) == '' or GUICtrlRead($gui_exec) == '' then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		elseif not FileExists(GUICtrlRead($gui_path)) Then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		elseif not FileExists(GUICtrlRead($gui_exec)) Then
			GUICtrlSetData($gui_error, "Chyba: Program neexistuje.")
		elseif UBound(ProcessList('ARTAX.exe')) >= 2 then
			GUICtrlSetData($gui_error, "Chyba: Ukoncete bezici program Artax.")
		else
			$project_list = _FileListToArray(GUICtrlRead($gui_path), '*.rtx', 1); files only..
			if ubound($project_list) < 2 then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			else
				run(GUICtrlRead($gui_exec)); run artax executable
				$atx = WinWait('ARTAX','',5); ATX master
				$pass = WinWait('Password','',5); Password prompt
				WinSetState($pass,'',@SW_HIDE)
				WinActivate($pass)
				Send('{ENTER}')
				$err = WinWait('Error','',5); Error prompt
				WinActivate($err)
				Send('{ENTER}')
				;_ArrayDisplay(WinList())

				;hide ATX master & child
				;open project file
				; send open -> get win -> pass file -> send open -> check win
				;loop measurement
					;send skip info -> check name
					; send picture [shift] + C -> getclip -> save buff
					; send graph    [crtl] + C -> getclip -> save buff
					; send table    [crtl] + D -> getclip -> save buff
				;exit program
			endif
		endif
	endif
	If $event = $GUI_EVENT_CLOSE or $event = $button_exit then
		logger("Program end.")
		FileWrite($logfile, GUICtrlRead($gui_path) & '|' & GUICtrlRead($gui_exec)); history..
		FileClose($logfile)
		Exit; exit
	endif
WEnd

func logger($text)
	FileWriteLine($logfile, $text)
endfunc
