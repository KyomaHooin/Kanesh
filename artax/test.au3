
;"how to get image from clipboard without loss quality? -> @"

;MsgBox(Default,"test",StringRegExpReplace("ARTAX - [tabl_0@190916_145648]","^.*\[(.*)\]$","$1"))
#include <Array.au3>
#include <Clipboard.au3>
#include <GDIPlus.au3>
#include <WinAPISys.au3>

;_ClipBoard_GetDataEx
$hwndartax = WinGetHandle("ARTAX -")
if @error then MsgBox(Default,"whnd","Failed.")
WinActivate("ARTAX -")
Send('^c')
sleep(1000);holdon a second
if not _ClipBoard_IsFormatAvailable(3) then MsgBox(Default,"clip","Clipboard is no available.")
_ClipBoard_Open(0); hook clipboard
$map = _ClipBoard_GetDataEx(3); clip WMF struct pointer
MsgBox(Default,"struct buff ptr", $map)
$dstr = DllStructCreate("LONG;LONG;LONG;HANDLE", $map); clipboard WMF struct
if IsDllStruct($map) Then MsgBox(Default,"struct","got ptr struct: " & $map)
if IsPtr(DllStructGetData($dstr,4)) Then MsgBox(Default,"ptr","got metafile ptr: " & DllStructGetData($dstr,4))

$hmf = DllStructGetData($dstr,4); metafile handle pointer

;Get WMF metafile to buffer size
$mbuffsize = DllCall('gdi32.dll', "int", "GetMetaFileBitsEx", "handle",$hmf, "int", 0, "ptr", null); buffer size in bytes
if @error then MsgBox(Default,"DLL call", "fail")
MsgBox(Default,"buff size", "Buff size: "& $mbuffsize[0])

;Create WMF metafile buffer pointer
$istr = DllStructCreate('byte[' & $mbuffsize[0] & ']')
if @error then MsgBox(Default,"malloc","Failed to allocate buffer.")
$iptr = DllStructGetPtr($istr)

if IsPtr($iptr) then MsgBox(Default,"ptr","set EMF ptr: " & $iptr)

;Get WMF metafile buffer
$wmfbits = DllCall('gdi32.dll', "int", "GetMetaFileBitsEx", "handle", $hmf, "int", $mbuffsize[0], "ptr", $iptr)
if @error then MsgBox(Default,"DLL call", "fail")

_ArrayDisplay($wmfbits)

;Convert WMF buffer to EMF buffer handle
$ehmf = DllCall('gdi32.dll', "handle", "SetWinMetaFileBits", "int", $mbuffsize[0], "ptr", $iptr, "handle", null, "handle", null)
if @error then MsgBox(Default,"DLL call", "fail")

_ArrayDisplay($ehmf)

;Create EMF buffer
$eptr = _WinAPI_CreateBuffer($mbuffsize[0])
if not @error then MsgBox(Default,"Win malloc","Malloc ok.")
;Get EMF buffer size
$buffsize = _WinAPI_GetEnhMetaFileBits($ehmf[0],$eptr)
if not @error then MsgBox(Default,"Win buff.","Got ehf ptr size " & $buffsize)
;Get EMF buffer
$emf = _WinAPI_SetEnhMetaFileBits($eptr,$buffsize)
if not @error then MsgBox(Default,"Win buff.","Got ehf buffer handle. " & $emf)
;Write EMF to file.
$emffile = _WinAPI_CopyEnhMetaFile($emf, @ScriptDir & '\foo.emf')
if not @error then MsgBox(Default,"EMF","file Write ok." & $emffile)

_WinAPI_FreeMemory($eptr)
_WinAPI_DeleteEnhMetaFile($emf)

_GDIPlus_Startup()
;Read EMF to image object
$type = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\foo.emf')
if not @error then MsgBox(Default,"Ehmf","Got EHMF. " & $type )
;Get PNG encoder ID.
$encoder = _GDIPlus_EncodersGetCLSID("PNG")
if not @error then MsgBox(Default,"Encoder","Got encoder ID.")
;Write image object to PNG file.
_GDIPlus_ImageSaveToFileEx($type, @ScriptDir & '\foo.png', $encoder)
if not @error then MsgBox(Default,"PNG","got PNG.")

_GDIPlus_Shutdown()
