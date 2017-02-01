;
; Bruker Artax 400 spectrometer data export wrapper by Richard Bruna
;

#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <_XMLDomWrapper.au3>
#include <GUIComboBox.au3>
#include <ArtaxHelper.au3>
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
if UBound(ProcessList(@ScriptName)) > 2 then exit; already running

;GUI
$gui = GUICreate("ArtaxExport v 1.5", 351, 91)
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
	$event = GUIGetMsg(); catch event
	if $event = $button_path Then; data path
		$project_path = FileSelectFolder("ArtaxExport / Project directory", @HomeDrive)
		if $project_path then
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
		$project_list = _FileListToArray(GUICtrlRead($gui_path), "*.rtx", 1, True)
		if GUICtrlRead($gui_path) == '' or GUICtrlRead($gui_exec) == '' then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		elseif not FileExists(GUICtrlRead($gui_exec)) Then
			GUICtrlSetData($gui_error, "Chyba: Program neexistuje.")
		elseif UBound(ProcessList('ARTAX.exe')) >= 2 then
			GUICtrlSetData($gui_error, "Chyba: Ukoncete bezici program.")
		elseif not FileExists(GUICtrlRead($gui_path)) then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		elseif UBound($project_list) < 2 then
			GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
		else
			; ---- cleanup ----
			_Artax_GetClean()
			; ---- ATX ----
			run(GUICtrlRead($gui_exec)); run artax executable
			$atx = WinWait('ARTAX','',10); ATX handle
			if not $atx then
				logger("ATX program err.")
			else
				BlockInput(1); block user input
				WinSetState($atx,'',@SW_HIDE)
				$pass = WinWait('Password','',10); password handle
				WinSetState($pass,'',@SW_HIDE)
				WinActivate($pass)
				WinWaitActive($pass,'',5)
				Send('{ENTER}')
				$err = WinWait('Error','',15); conn error handle
				if not $err then
					logger("DSP err.")
				else
					WinSetState($err,'',@SW_HIDE)
					WinActivate($err)
					WinWaitActive($err,'',5)
					WinClose($err)
					$atx_list = WinList("ARTAX")
					for $i = 0 to UBound($atx_list) - 1;get ATX child
						if $atx_list[$i][0] == 'ARTAX' and $atx_list[$i][1] <> $atx then $atx_child = $atx_list[$i][1]
					next
					if not $atx_child then
						logger("ATX program child err.")
					else
						for $i = 1 to UBound($project_list) - 1
							; ---- get spectra names ----
							$spectra_name = _Artax_GetSpectra($project_list[$i])
							if @error then
								logger("Spectra name err.")
								ContinueLoop
							endif
							; ---- open project ----
							WinSetState($atx_child,'',@SW_MAXIMIZE)
							WinActivate($atx_child)
							WinWaitActive($atx_child,'',15)
							Send('!fo')
							WinWaitActive("Open Project",'',5)
							Send($project_list[$i])
							Send('!o')
							; ---- project ----
							$project = StringRegExpReplace($project_list[$i],".*\\(.*).rtx$","$1")
							DirCreate(@ScriptDir & '\export\' & $project)
							Send('{TAB}{DOWN}')
							$project_info = WinWait('Project Information','',5); get ATX child handle
							WinSetState($project_info,'',@SW_HIDE)
							WinActivate($project_info)
							WinWaitActive($project_info,'',5)
							WinClose($project_info)
							Send('{DOWN}')
							;---- spectra ----
							for $k = 0 to UBound($spectra_name) - 1
								Send('{DOWN}')
								;---- table ----
								Send('^d')
								sleep(500)
								Send('^d')
								sleep(500); internal bug..
								$table = _Artax_GetTableEx($spectra_name[$k], @ScriptDir & '\export\' & $project)
								if @error then
									logger($table)
									ContinueLoop
								endif
								;------- graph -----
								Send('^c')
								sleep(1000);Hold on a second!
								$graph = _Artax_GetGraphEx($spectra_name[$k], @ScriptDir & '\export\' & $project)
								if @error then logger($graph)
								;---- picture ----
								Send('{RIGHT}{DOWN}')
								$atx_picture = WinWait("Picture",'',10)
								WinActivate($atx_picture)
								WinWaitActive($atx_picture,'',5)
								$atx_picture_pos = WinGetPos($atx_picture)
								if not @error then MouseMove($atx_picture_pos[0] + 50,$atx_picture_pos[1] + 50,0)
								MouseClick('right')
								Send('c')
								sleep(1000);Hold on a second!
								$picture = _Artax_GetPictureEx($spectra_name[$k], @ScriptDir & '\export\' & $project)
								if @error then logger($picture)
								WinClose($atx_picture)
							next
						next
					EndIf
				endif
				WinClose($atx_child)
				WinClose($atx)
				GUICtrlSetData($gui_error, "Hotovo.")
				BlockInput(0); unblock user input
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

func _Artax_GetSpectra($file)
	_XMLLoadXML(FileRead($file))
	if @error then return SetError(1,0,"XML instance error.")
	$count = _XMLGetNodeCount('/TRTProject/ClassInstance/ChildClassInstances/ClassInstance')
	if @error then return SetError(1,0,"XML node count error.")
	local $name[$count]
	for $i = 1 to $count
		$name[$i-1] = _XMLGetAttrib('/TRTProject/ClassInstance/ChildClassInstances/ClassInstance[' & $i & ']', 'Name')
	next
	return $name
endfunc

func logger($text)
	FileWriteLine($logfile, $text)
endfunc
