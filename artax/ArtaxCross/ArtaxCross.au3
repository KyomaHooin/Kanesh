
#include <GDIPlus.au3>
#include <GUIStatusBar.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

local $f,$parts[3] = [50,100,-1]

$gui = GUICreate("ArtaxCross v 1.0",900,600)
$file = GUICtrlCreateMenu("&Soubor")
$open = GUICtrlCreateMenuItem("&Otevrit",$file)
$exit = GUICtrlCreateMenuItem("&Konec",$file)
$calibration = GUICtrlCreateMenu("&Kalibrace")
$setup = GUICtrlCreateMenuItem("&Nastaveni",$calibration)
$record = GUICtrlCreateMenu("&Zaznam")
$new = GUICtrlCreateMenuItem("&Novy",$record)
$save = GUICtrlCreateMenuItem("&Uložit",$record)
$status = _GUICtrlStatusBar_Create($gui)

_GUICtrlStatusBar_SetParts($status,$parts)
_GUICtrlStatusBar_SetText($status,"x: 15.8",0)
_GUICtrlStatusBar_SetText($status,"y: 25.4",1)

GUISetState(@SW_SHOW,$gui)

_GDIPlus_Startup()

While 1
	switch GUIGetMsg()
	case $open
		$f = FileOpenDialog("Tablet Image",@HomeDrive,'Images (*.jpg;*.jpeg;*.png;*.bmp)')
		if $f then
			_GUICtrlStatusBar_SetText($status,StringRegExpReplace($f, ".*\\(.*)$", "$1"),2)
			$bitmap = _GDIPlus_BitmapCreateFromFile($file)
			$graphic = _GDIPlus_GraphicsCreateFromHWND($gui)
			_GDIPlus_GraphicsDrawImageRect($graphic,$bitmap,1,1,898,562)
		endif
	;case $setup
	;case $new
	;case $save
	case $exit,$GUI_EVENT_CLOSE
		if $f then
			_GDIPlus_GraphicsDispose($graphic)
			_GDIPlus_ImageDispose($bitmap)
			_GDIPlus_Shutdown()
		endif
		exit
	endswitch
wend

