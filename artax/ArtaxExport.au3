
;
; TODO:
;
; Win7/XP spectra name
; table write clip error ignored
; '.csv' no spectra err
; WMT to EMF metafile.au3
; ATX child maximize
; EMF buffer to Image
; -excel test
; -icon
; -remove tmp.emf (?)
; -_artax_getpicture
; -get project files + loop
; -spectra loop
;

#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

#include <GUIConstantsEx.au3>
#include <GUIComboBox.au3>
#include <Clipboard.au3>
#include <WinAPISys.au3>
#include <WinAPIGdi.au3>
#include <GDIPlus.au3>

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

$gui = GUICreate("ArtaxExport v 1.3", 351, 91)
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
		elseif not FileExists(GUICtrlRead($gui_exec)) Then
			GUICtrlSetData($gui_error, "Chyba: Program neexistuje.")
		elseif UBound(ProcessList('ARTAX.exe')) >= 2 then
			GUICtrlSetData($gui_error, "Chyba: Ukoncete bezici program.")
		else
			if not FileExists(GUICtrlRead($gui_path)) then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			else
;				BlockInput(1); block input
				run(GUICtrlRead($gui_exec)); run artax executable
				$atx = WinWait('ARTAX','',5); ATX handle
				WinSetState($atx,'',@SW_HIDE)
				$pass = WinWait('Password','',5); password handle
				WinSetState($pass,'',@SW_HIDE)
				WinActivate($pass)
				WinWaitActive($pass,'',5)
				Send('{ENTER}')
				$err = WinWait('Error','',5); conn error handle
				WinSetState($err,'',@SW_HIDE)
				WinActivate($err)
				WinWaitActive($err,'',5)
				WinClose($err)
				$atx_list = WinList("ARTAX")
				for $i = 0 to UBound($atx_list) - 1
					if $atx_list[$i][0] == 'ARTAX' and $atx_list[$i][1] <> $atx then $atx_child = $atx_list[$i][1]
				next
				;$atx_child = WinWait('ARTAX -','',5); get ATX child handle
				; ---- project ----
				WinActivate($atx_child)
				Send('!fo')
				WinWaitActive("Open Project",'',5)
				Send(GuiCtrlRead($gui_path))
				Send('!o')
				Send('{TAB}{DOWN}')
				$project = WinWait('Project Information','',5); get ATX child handle
				WinSetState($project,'',@SW_HIDE)
				WinActivate($project)
				WinWaitActive($project,'',5)
				WinClose($project)
				Send('{DOWN}{DOWN}'); project
				sleep(3000); Hold on a second!
;				$spectrum = StringRegExpReplace(WinGetTitle($atx_child),"^.*\[(.*)\]$","$1")
				$spectrum = 'test'
				DirCreate(@ScriptDir & '\export\' & $spectrum)
				;---- table ----
				$table = _Artax_GetTable($spectrum)
				if @error then logger($table)
				;------- graph -----
				$graph = _Artax_GetGraph($spectrum)
				if @error then logger($graph)
				;---- picture ----
				_Artax_GetPicture($spectrum)
;				BlockInput(0); unblock input
				WinClose($atx_child)
				WinClose($atx)
				WinActivate($gui)
				GUICtrlSetData($gui_error, "Hotovo!")
				GUICtrlSetState($button_exit,$GUI_FOCUS)
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

func _Artax_GetTable($spectrum)
	Send('^d')
	$t = ClipGet()
	if @error then return SetError(1,0,"Table get err: " & $spectrum)
	$t_file = FileOpen(@ScriptDir & '\export\' & $spectrum & '\' & $spectrum & '.csv', 258); UTF-8 no BOM overwrite
	FileWrite($t_file, $t)
	if @error then return SetError(1,0,"Table write err: " & $spectrum)
	FileClose($t_file)
EndFunc

func _Artax_GetGraph($spectrum)
	Send('^c')
	sleep(1000);Hold on a second!
	if not _ClipBoard_IsFormatAvailable(3) then return SetError(1,0,"Graph clip format err: " & $spectrum); CF_METAFILEPICT
	_ClipBoard_Open(0); hook clipboard
	if @error then return SetError(1,0,"Graph clip lock err: " & $spectrum)
	$MFP = _ClipBoard_GetDataEx(3); clipboard METAFILEPICT struct ptr
	if $MFP = 0 then return SetError(1,0,"Graph METAFILEPICT struct ptr err: " & $spectrum)
	$SMFP = DllStructCreate("LONG;LONG;LONG;HANDLE", $MFP); clipboard METAFILEPICT struct
	if @error then return SetError(1,0,"Graph METAFILE struct err: " & $spectrum)
	$HWMF = DllStructGetData($SMFP, 4);METAFILE handle ptr
	if $HWMF = 0 then return SetError(1,0,"Graph METAFILE handle ptr err: " & $spectrum)
	$WMFBUFFSIZE = DllCall('gdi32.dll', "uint", "GetMetaFileBitsEx", "handle", $HWMF, "int", 0, "ptr", null); buffer size in bytes
	if $WMFBUFFSIZE = 0 then return SetError(1,0,"Graph WMF buffer size err: " & $spectrum)
	$WMF = DllStructCreate('byte[' & $WMFBUFFSIZE[0] & ']')
	if @error then return SetError(1,0,"Graph WMF struct err: " & $spectrum)
	$PWMF = DllStructGetPtr($WMF)
	if @error then return SetError(1,0,"Graph WMF struct ptr err: " & $spectrum)
	$WMFBYTES = DllCall('gdi32.dll', "uint", "GetMetaFileBitsEx", "handle", $HWMF, "int", $WMFBUFFSIZE[0], "ptr", $PWMF)
	if $WMFBYTES = 0 then SetError(1,0,"Graph WMF buffer err: " & $spectrum)
	$HEMF = DllCall('gdi32.dll', "handle", "SetWinMetaFileBits", "int", $WMFBUFFSIZE[0], "ptr", $PWMF, "handle", null, "handle", null)
	if $HEMF = Null then SetError(1,0,"Graph WMF buffer to HEMF handle err: " & $spectrum)
	$PEMF = _WinAPI_CreateBuffer($WMFBUFFSIZE[0])
	if $PEMF = 0 then SetError(1,0,"Graph EMF buffer pointer err: " & $spectrum)
	$EMFBYTES = _WinAPI_GetEnhMetaFileBits($HEMF[0],$PEMF)
	if $EMFBYTES = 0 then SetError(1,0,"Graph EMF buffer size err: " & $spectrum)
	$EMF = _WinAPI_SetEnhMetaFileBits($PEMF,$EMFBYTES)
	if $EMF then SetError(1,0,"Graph EMF err: " & $spectrum)
	$FEMF = _WinAPI_CopyEnhMetaFile($EMF, @ScriptDir & '\tmp.emf')
	if $FEMF = 0 then SetError(1,0,"Graph EMF write err: " & $spectrum)
	_WinAPI_FreeMemory($PEMF)
	_WinAPI_DeleteEnhMetaFile($EMF)
	_GDIPlus_Startup()
	$image = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\tmp.emf')
	if $image = 0 then SetError(1,0,"Graph Image read err: " & $spectrum)
	$encoder = _GDIPlus_EncodersGetCLSID("PNG")
	if @error then SetError(1,0,"Graph PNG encoder err: " & $spectrum)
	_GDIPlus_ImageSaveToFileEx($image, @ScriptDir & '\export\' & $spectrum & '\' & $spectrum & '.png', $encoder)
	if @error then SetError(1,0,"Graph PNG write err: " & $spectrum)
	_GDIPlus_ImageDispose($image)
	_GDIPlus_Shutdown()
	FileDelete(@ScriptDir & '\tmp.emf')
EndFunc

func _Artax_GetPicture($spectrum)
	;Send('{RIGHT}')
	;Send('{DOWN}')
	;sleep(1000);Hold on a sec.!
	;$pic = WinGetHandle("Picture")
	;WinActivate($pic)
	;MouseClick("right")
	;Send('c')
	;$map = _ClipBoard_GetData($CF_BTIMAP)
	return
EndFunc
