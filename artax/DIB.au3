
#include <Clipboard.au3>
#include <GDIplus.au3>

$artax = WinGetHandle("ARTAX -")
if @error then MsgBox(Default,"whnd","Failed.")

;convert DIB* into sytem.drawing.bitmap
;how to read bitmap from windows clipboard
;paste an image from clipboard (bug in Clipboard.GetImage)

WinActivate("ARTAX -")
Send('{RIGHT}{DOWN}')
$picture = WinWait("Picture",'',5)
;WinSetState($picture,'',@SW_HIDE)
WinActivate($picture)
WinWaitActive($picture,'',5)
MouseClick('right')
Send('c')
sleep(1000);Hold on a second!

;for $i = 1 to 17
;	if _ClipBoard_IsFormatAvailable($i) then MsgBox(Default,'format',$i); CF_BITMAP 2,8,17 BITMAP,DIB,DIBV5
;next

if not _ClipBoard_IsFormatAvailable(8) then MsgBox(Default,'err',"Picture clip format err."); CF_DIBV5

_ClipBoard_Open(0); hook clipboard

$HDIB = _ClipBoard_GetDataEx(8); DIB handle
if $HDIB = 0 then MsgBox (Default,"err","DIB get fail.")
local $PDIB = _MemGlobalLock($DIB);  DIB ptr
if $PDIB = 0 then MsgBox(Default,"err","Failed to lock mem.")
local $DIBSIZE = _MemGlobalSize($PDIB); DIB size
if $DIBSIZE = 0 then MsgBox(Default,"err","Failed to get size.")

$BITMAPINFOHEADER = DllStructCreate("DWORD;LONG;LONG;WORD;WORD;DWORD;DWORD;LONG;LONG;DWORD;DWORD", $DIB); DIB strcuct
if @error then MsgBox(Default,"err","BITMAPINFOHEADER struct fail.")

;local $strdata = ''
;for $i = 1 to 11
;	$strdata &= '  ' & DllStructGetData($BITMAPINFOHEADER,$i)
;Next
;MsgBox(Default,"str",$strdata)

;$BITMAPINFO = DllStructCreate("PTR;PTR", $DIB);BITMAPINFO struct -> BITMAPINFOHEADER + RGBQUAD
;if @error then MsgBox(Default,"err","BITMAPINFO struct failed.")

$HEADER = DllStructCreate("WORD;UINT;UINT:UINT");BMP HEADER
if @error then MsgBox(Default,"err","BITMAPINFO struct failed.")

DllStructSetData($HEADER,1,0x4d42)
DllStructSetData($HEADER,2, 54 + DllStructGetData($BITMAPINFOHEADER,7)); SizeImage
DllStructSetData($HEADER,3, 0)
DllStructSetData($HEADER,4, 54); 14(BMP HEADER) + 40(BITMAPINFOHEADER)

$DIB = DllStructCreate("byte[" & $DIBSIZE & "]", $PDIB)
if @error then MsgBox(Default,"err","DIP buff fail.")

;$buff = DllStructGetData($data,1)
;if @error then MsgBox(Default,"err","Struct data strem err.")
;_MemGlobalUnlock($block)

$BMP = FileOpen(@ScriptDir & '\tmp.bmp',17); binary append
FileWrite($BMP,DllStructGetData($HEADER,1))
FileWrite($BMP,DllStructGetData($HEADER,2))
FileWrite($BMP,DllStructGetData($HEADER,3))
FileWrite($BMP,DllStructGetData($HEADER,4))
FileWrite($BMP,DllStructGetData($DIB,1))
FileClose($BMP)

;_GDIPlus_Startup()
;Read EMF to image object
;$type = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\tmp.dib')
;if @error then MsgBox(Default,"Ehmf","DIB fail.")

;_GDIPlus_Startup()
;_GDIPlus_BitmapCreateFrom
;$bitmap = _GDIPlus_BitmapCreateFromMemory($buff)
;if @error then MsgBox(Default,"gdi","Hbitmap failed.")
;_GDIPlus_BitmapDispose($type)
;_GDIPlus_Shutdown()


;MsgBox(Default,"buff",$buff)

;_MemGlobalUnlock($block)

;$BMP = _ClipBoard_GetData(8); bitmap handle
;if $BMP = 0 then MsgBox (Default,"err", "func err." & @error)

;$DIB = DllStructCreate("uint;int;int;uint;uint;uint;uint;int;int;uint;uint", $BMP); DIB strcuct
;if @error then MsgBox(Default,"str","DIB struct fail.")

;MsgBox(Default,'str',"DIB struct ptr: " & $DIB)

;local $strdata = ''

;for $i = 1 to 11
;	$strdata &= '  ' & DllStructGetData($DIB,$i)
;Next
;MsgBox(Default,"str",$strdata)

;_GDIPlus_Startup()
;_GDIPlus_BitmapCreateFrom
;$bitmap = _GDIPlus_BitmapCreateFromMemory($buff)
;if @error then MsgBox(Default,"gdi","Hbitmap failed.")
;_GDIPlus_BitmapDispose($bitmap)
;_GDIPlus_Shutdown()

;WinClose($picture)
;WinActivate($artax)
;Send('{LEFT}{LEFT}')
;exit

;if not _ClipBoard_IsFormatAvailable(2) then return SetError(1,0,"Picture clip format err: " & $spectrum); CF_BITMAP
;if not _ClipBoard_IsFormatAvailable(2) then MsgBox(Default,'err',"Picture clip format err."); CF_BITMAP
;_ClipBoard_Open(0); hook clipboard
;$BMP = _ClipBoard_GetData(2); bitmap handle
;if $BMP = 0 then MsgBox(Default,'err',"Picture bitmap handle err.")
;_GDIPlus_Startup()
;$encoder = _GDIPlus_EncodersGetCLSID("PNG")
;if @error then MsgBox(Default,"err","Graph PNG encoder err.")
;_GDIPlus_ImageSaveToFileEx($BMP, @ScriptDir & '\test.png', $encoder)
;if @error then MsgBox(Default,'err',"Graph PNG write err.")
;_GDIPlus_ImageDispose($)
;_GDIPlus_Shutdown()
