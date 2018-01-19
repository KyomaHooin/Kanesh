
#include <Misc.au3>
#include <GDIPlus.au3>
#include <GUIStatusBar.au3>
#include <GUIConstantsEx.au3>

local $f, $parts[3] = [50,100,-1],$cal[3][2],$dat[6][2]

$gui = GUICreate("ArtaxCross v 1.0",900,600)
$file = GUICtrlCreateMenu("&Soubor")
$open = GUICtrlCreateMenuItem("&Otevřít",$file)
$exit = GUICtrlCreateMenuItem("&Konec",$file)
$calibration = GUICtrlCreateMenu("&Kalibrace")
$setup = GUICtrlCreateMenuItem("&Nastavení",$calibration)
$record = GUICtrlCreateMenu("&Záznam")
$new = GUICtrlCreateMenuItem("&Nový",$record)
$save = GUICtrlCreateMenuItem("&Uložit",$record)
$status = _GUICtrlStatusBar_Create($gui)

_GUICtrlStatusBar_SetParts($status,$parts)
_GUICtrlStatusBar_SetText($status,"x:",0)
_GUICtrlStatusBar_SetText($status,"y:",1)

GUISetState(@SW_SHOW,$gui)

_GDIPlus_Startup()

While 1
	switch GUIGetMsg()
	case $open
		$f = FileOpenDialog("Tablet Image",@HomeDrive,'Images (*.jpg;*.jpeg;*.png;*.bmp)')
		if $f then
			_GUICtrlStatusBar_SetText($status,"Soubor: " & StringRegExpReplace($f, ".*\\(.*)$", "$1"),2)
			$bitmap = _GDIPlus_BitmapCreateFromFile($f)
			$graphic = _GDIPlus_GraphicsCreateFromHWND($gui)
			_GDIPlus_GraphicsDrawImageRect($graphic,$bitmap,1,1,898,562)
		endif
	case $setup
		local $cal[3][2], $i = 0
		do
			if _IsPressed("01") then
				$pos = MouseGetPos()
				_GUICtrlStatusBar_SetText($status,"x: " & $pos[0],0)
				$cal[$i][0] = $pos[0]
				_GUICtrlStatusBar_SetText($status,"y: " & $pos[1],1)
				$cal[$i][1] = $pos[1]
				sleep(450)
				$i+=1
			endif
		until $i = 3
		_GUICtrlStatusBar_SetText($status,"Kalibrace: Ok.",2)
	case $new
		local $dat[6][2], $j = 0
		do
			if _IsPressed("01") then
				$pos = MouseGetPos()
				_GUICtrlStatusBar_SetText($status,"x: " & $pos[0],0)
				$dat[$j][0] = $pos[0]
				_GUICtrlStatusBar_SetText($status,"y: " & $pos[1],1)
				$dat[$j][1] = $pos[1]
				sleep(450)
				$j+=1
			endif
		until $j = 6
		_GUICtrlStatusBar_SetText($status,"Záznam: Ok.",2)
	case $save
		if $f and check_data($dat) then
			$out = FileSaveDialog("Tablet Data",@HomeDrive,'CSV (*.csv)',0,StringRegExpReplace($f, ".*\\(.*)\..*$","$1") & '.csv')
			if $out then
				write_data($out,$dat)
			endif
		endif
	case $exit,$GUI_EVENT_CLOSE
		if $f then
			_GDIPlus_GraphicsDispose($graphic)
			_GDIPlus_ImageDispose($bitmap)
		endif
		_GDIPlus_Shutdown()
		exit
	endswitch
wend

func check_data($data)
	for $i = 0 to 5
		if not($data[$i][0] or $data[$i][1]) then return 0
	next
	return 1
endfunc

func write_data($file,$data)
	for $k = 0 to 5
		FileWriteLine($file,StringRegExpReplace($file, ".*\\(.*)\..*$","$1") & ';' & $k+1 & ';' & $data[$k][0] & ';' & $data[$k][1])
	next
endfunc

