
#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <GUIComboBox.au3>
#include <GUIEdit.au3>
#include <File.au3>
;#include <ScreenCapture.au3>
;#include <Clipboard.au3>

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
if UBound(ProcessList(@ScriptName)) > 2 then exit; already running

;GUI

$gui = GUICreate("ArtaxExport v 1.2", 351, 91)
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
GUICtrlSetState($button_export,$GUI_FOCUS)

GUISetState(@SW_SHOW)

While 1
	global $atx,$pass,$err,$atx_child
	$event = GUIGetMsg(); catch event
	if $event = $button_path Then; data path
		$project_path = FileOpenDialog("ArtaxExport / Project file", @HomeDrive, "Artax Project (*.rtx)")
		if not @error then
				GUICtrlSetData($gui_path, $project_path)
				$path_history = $project_path; update last..
		endif
	EndIf
	if $event = $button_exec Then; data path
		$exec_path = FileOpenDialog("ArtaxExport/ Program file", @HomeDrive, "Artax program (*.exe)")
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
			GUICtrlSetData($gui_error, "Chyba: Ukoncete bezici program.")
		else
			if not FileExists(GUICtrlRead($gui_path)) then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			else
				BlockInput(1); block input
				run(GUICtrlRead($gui_exec)); run artax executable
				$atx = WinWait('ARTAX','',5); ATX handle
				WinSetState($atx,'',@SW_HIDE)
				$pass = WinWait('Password','',5); password handle
				WinSetState($pass,'',@SW_HIDE)
				WinActivate($pass)
				Send('{ENTER}')
				$err = WinWait('Error','',5); conn error handle
				WinSetState($err,'',@SW_HIDE)
				WinActivate($err)
				Send('{ENTER}')
				$atx_child = WinWait('ARTAX -','',5); get ATX child handle
;				WinSetState($atx_child,'',@SW_HIDE)
;				WinActivate($atx_child)
				Send('!fo')
				Send(GuiCtrlRead($gui_path))
				Send('!o')
				Send('{TAB}{DOWN}')
				sleep(5000); hold on a second!
				Send('!{F4}')
				Send('{DOWN}'); project
				;loop
				Send('{DOWN}')
				sleep(3000); Hold on a second!
				$tab = StringRegExpReplace(WinGetTitle($atx_child),"^.*\[(.*)\]$","$1")
				ClipPut(''); clear buffer

				Send('^d'); table ControlSend($atx_child,'','','^d')
				$table = ClipGet()
				FileWrite(@ScriptDir & '\export\' & $tab & '.csv', $table)

				;Send('^c'); table
;				ControlSend($atx_child,'','','^c')
				;$graph = ClipGet()
;				$graph = _ClipBoard_GetData($CF_BITMAP)
;				if $graph then GUICtrlSetData($gui_error, "Got graph buff!")
				;FileWrite(@ScriptDir & '\export\' & $tab & '.jpg', $graph)
;				ControlSend("ARTAX",'','','{^c}'); graph
;				$graph_buff = _ClipBoard_GetDataEx($CF_BITMAP)
;				_ScreenCapture_SaveImage(@ScriptDir & '\export\test.png',$graph_buff)
					; send picture [shift] + C -> getclip -> save buff
			;	until

				WinClose($atx_child)
				BlockInput(0); unblock input
				GUICtrlSetData($gui_error, "Hotovo!")
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
