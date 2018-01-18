
#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <GUIStatusBar.au3>
#include <WindowsConstants.au3>

#include<array.au3>

local $parts[3] = [50,100,-1]

$gui = GUICreate("Map",900,600)
$kalibrace = GUICtrlCreateMenu("&Soubor")
$kalibrace = GUICtrlCreateMenu("&Kalibrace")
$record = GUICtrlCreateMenu("&Záznam")
$record = GUICtrlCreateMenu("&Uložit")
$status = _GUICtrlStatusBar_Create($gui)

_GUICtrlStatusBar_SetParts($status,$parts)
_GUICtrlStatusBar_SetText($status,"x: 15.8",0)
_GUICtrlStatusBar_SetText($status,"y: 25.4",1)
_GUICtrlStatusBar_SetText($status,"J433_front.jpeg",2)

;-------------------

GUISetState(@SW_SHOW,$gui)

_GDIPlus_Startup()

$bitmap = _GDIPlus_BitmapCreateFromFile(@ScriptDir & "\test.jpeg")
$graphic = _GDIPlus_GraphicsCreateFromHWND($gui)

_GDIPlus_GraphicsDrawImageRect($graphic,$bitmap,1,1,898,562)

;-------------------

While 1
    $msg = GUIGetMsg()
    If $msg = $GUI_EVENT_CLOSE Then
        _GDIPlus_GraphicsDispose($graphic)
        _GDIPlus_ImageDispose($bitmap)
        _GDIPlus_Shutdown()
        Exit
    EndIf
WEnd
