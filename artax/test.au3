

;MsgBox(Default,"test",StringRegExpReplace("ARTAX - [tabl_0@190916_145648]","^.*\[(.*)\]$","$1"))
#include <Array.au3>
#include <Clipboard.au3>
#include <GDIPlus.au3>
#include <WinAPIGDI.au3>
#include <WinAPIDiag.au3>
#include <Memory.au3>

_ClipBoard_Empty()
_ClipBoard_Close()

;_ClipBoard_GetDataEx
WinActivate("ARTAX -")
;Send('^d')
;sleep(5000)
;$text = _ClipBoard_GetData($CF_TEXT)
Send('^c')
$map = _ClipBoard_GetData($CF_METAFILEPICT)

;MsgBox(Default,"map",$map)

;if $map = 0 then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Empty ptr. " & $map)
;	Exit
;endif

$buff = _MemGlobalLock($map)
if $buff = 0 Then
	_ClipBoard_Close()
	MsgBox(Default,"mem","Empty buff.")
	Exit
endif

$buffsize = _MemGlobalSize($map)
if $buff = 0 Then
	_MemGlobalUnlock($map)
	_ClipBoard_Close()
	MsgBox(Default,"mem","Zero buff size.")
	Exit
endif

$data = DllStructCreate("byte[" & $buffsize & "]", $buff)
$ret = DllStructGetData($data, 1)

_MemGlobalUnlock($map)
_ClipBoard_Close()

MsgBox(Default,"data",$ret)

;_MemRead($map)

;$type = _GDIPlus_ImageGetType($map)

;$struct = _WinAPI_DisplayStruct($type)

;MsgBox(Default,"meta", $struct)

;$map = _ClipBoard_GetData($CF_ENHMETAFILE)
;_WinAPI_CopyEnhMetaFile($map, @ScriptDir & '\foo.jpg')

;global $arr[9] = [0x0080,0x0081,0x0082,0x0083,0x008E,0x0200,0x02FF,0x0300,0x03FF]

;for $i = 0 to UBound($arr) - 1
;for $i = 1 to 17
;	if _ClipBoard_IsFormatAvailable($arr[$i]) then MsgBox(Default,"form", "Got format: " & $arr[$i])
;	if _ClipBoard_IsFormatAvailable($i) then MsgBox(Default,"form", "Got format: " & $i)
;next; 3: METAFILEPICT, 14: EHNMETAFILE

;MsgBox(Default,"meta",$map)

;if @error then MsgBox(Default,"foo","err: " & @error & "ext: " & @extended)
;$text = DllCall("user32.dll", "handle", "GetClipboardData", "uint", 1)
;$text = ClipGet()
;_ArrayDisplay($text)
;run("mspaint")
;sleep(3000)
;$paint = WinWait('Paint','',5); conn error handle
;WinActivate($paint)
;Send('^v')

;Send('{ENTER}')


;_ArrayDisplay(WinList())

