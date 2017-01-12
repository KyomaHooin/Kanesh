
#include <Clipboard.au3>
#include <GDIplus.au3>

$artax = WinGetHandle("ARTAX -")
if @error then MsgBox(Default,"whnd","Failed.")

WinActivate("ARTAX -")
Send('{RIGHT}{DOWN}')
$picture = WinWait("Picture",'',5)
WinActivate($picture)
WinWaitActive($picture,'',5)
MouseClick('right')
Send('c')
sleep(1000);Hold on a second!

if not _ClipBoard_IsFormatAvailable(8) then MsgBox(Default,'err',"Picture clip format err."); CF_DIBV5

_ClipBoard_Open(0); hook clipboard

$HDIB = _ClipBoard_GetDataEx(8); DIB handle
if $HDIB = 0 then MsgBox (Default,"err","DIB get fail.")
local $PDIB = _MemGlobalLock($HDIB);  DIB ptr
if $PDIB = 0 then MsgBox(Default,"err","Failed to lock mem.")
local $DIBSIZE = _MemGlobalSize($PDIB); DIB size
if $DIBSIZE = 0 then MsgBox(Default,"err","Failed to get  DIB size.")

$BITMAPINFOHEADER = DllStructCreate("DWORD;LONG;LONG;WORD;WORD;DWORD;DWORD;LONG;LONG;DWORD;DWORD",$HDIB);BITMAPINFOHEADER(40)
if @error then MsgBox(Default,"struct","BITMAPINFO failed.")

$HEADER = DllStructCreate("byte[2];byte[4];byte[4];byte[4]"); BITMAP HEADER(14)
DllStructSetData($HEADER,1, 0x4d42); "BM"
DllStructSetData($HEADER,2, 54 + DllStructGetData($BITMAPINFOHEADER,7)); BITMAP header(40) + BITMAPINFOHEADER(14) + SizeImage
DllStructSetData($HEADER,3, 0)
DllStructSetData($HEADER,4, 54); BITMAP header(14) + BITMAPINFOHEADER(40)

$DIB = DllStructCreate("byte[" & $DIBSIZE & "]", $PDIB); $ DB struct
if @error then MsgBox(Default,"err","DIP buff fail.")

_MemGlobalUnlock($PDIB)

$BMP = FileOpen(@ScriptDir & '\tmp.bmp',18); binary overwrite
FileWrite($BMP,DllStructGetData($HEADER,1))
FileWrite($BMP,DllStructGetData($HEADER,2))
FileWrite($BMP,DllStructGetData($HEADER,3))
FileWrite($BMP,DllStructGetData($HEADER,4))
FileWrite($BMP,DllStructGetData($DIB,1))
FileClose($BMP)

_GDIPlus_Startup()
$bitmap = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\tmp.bmp')
if @error then MsgBox(Default,"image","Load failed.")
$encoder = _GDIPlus_EncodersGetCLSID("PNG")
if @error then MsgBox(Default,"Encoder","Got encoder failed ID.")
_GDIPlus_ImageSaveToFileEx($bitmap, @ScriptDir & '\foo.png', $encoder)
if @error then MsgBox(Default,"PNG","write PNG. failed.")
_GDIPlus_ImageSaveToFile($bitmap, @ScriptDir & '\foo.png')
if @error then MsgBox(Default,"PNG","write PNG failed.")
_GDIPlus_ImageDispose($bitmap)
_GDIPlus_Shutdown()

