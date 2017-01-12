
#include <Clipboard.au3>
#include <WinAPISys.au3>
#include <WinAPIGdi.au3>
#include <GDIPlus.au3>

Func _Artax_GetTableEx($spectrum,$export)
	if not _ClipBoard_IsFormatAvailable(1) then MsgBox(Default,'err',"Table clip format err." & $spectrum); CF_DIBV5

	$TEXT = ClipGet()
	if @error then return SetError(1,0,"Table get err: " & $spectrum)
	$tab = FileOpen($export & '\' & $spectrum & '.csv', 258); UTF-8 no BOM overwrite
	if @error then return SetError(1,0,"Table file open err: " & $spectrum)
	FileWrite($tab, $TEXT)
	if @error then return SetError(1,0,"Table file write err: " & $spectrum)
	FileClose($tab)

	_ClipBoard_Close()
EndFunc

Func _Artax_GetPictureEx($spectrum,$export)
	if not _ClipBoard_IsFormatAvailable(8) then return SetError(1,0,"Picture clip format err: " & $spectrum); CF_DIBV5

	_ClipBoard_Open(0); hook clipboard

	$HDIB = _ClipBoard_GetDataEx(8); DIB handle
	if $HDIB = 0 then return SetError(1,0,"Picture DIB handle err: " & $spectrum)
	local $PDIB = _MemGlobalLock($HDIB);  DIB ptr
	if $PDIB = 0 then return SetError(1,0,"Picture DIB pointer err: " & $spectrum)
	local $DIBSIZE = _MemGlobalSize($PDIB); DIB size
	if $DIBSIZE = 0 then return SetError(1,0,"Picture DIB size err: " & $spectrum)

	$BITMAPINFOHEADER = DllStructCreate("DWORD;LONG;LONG;WORD;WORD;DWORD;DWORD;LONG;LONG;DWORD;DWORD",$HDIB);BITMAPINFOHEADER(40)
	if @error then return SetError(1,0,"Picture BITMAPINFO struct err: " & $spectrum)

	$HEADER = DllStructCreate("byte[2];byte[4];byte[4];byte[4]"); BITMAP HEADER(14)
	if @error then return SetError(1,0,"Picture HEADER struct err: " & $spectrum)

	DllStructSetData($HEADER,1, 0x4d42); "BM"
	DllStructSetData($HEADER,2, 54 + DllStructGetData($BITMAPINFOHEADER,7)); BITMAP header(40) + BITMAPINFOHEADER(14) + SizeImage
	DllStructSetData($HEADER,3, 0)
	DllStructSetData($HEADER,4, 54); BITMAP header(14) + BITMAPINFOHEADER(40)

	$DIB = DllStructCreate("byte[" & $DIBSIZE & "]", $PDIB); $ DB struct
	if @error then return SetError(1,0,"Picture DIB struct err: " & $spectrum)

	_MemGlobalUnlock($PDIB)

	$BMP = FileOpen(@ScriptDir & '\tmp.bmp',18); binary overwrite
	if @error then return SetError(1,0,"Picture BMP file open err: " & $spectrum)
	FileWrite($BMP,DllStructGetData($HEADER,1))
	if @error then return SetError(1,0,"Picture BMP file write err: " & $spectrum)
	FileWrite($BMP,DllStructGetData($HEADER,2))
	if @error then return SetError(1,0,"Picture BMP file write err: " & $spectrum)
	FileWrite($BMP,DllStructGetData($HEADER,3))
	if @error then return SetError(1,0,"Picture BMP file write err: " & $spectrum)
	FileWrite($BMP,DllStructGetData($HEADER,4))
	if @error then return SetError(1,0,"Picture BMP file write err: " & $spectrum)
	FileWrite($BMP,DllStructGetData($DIB,1))
	if @error then return SetError(1,0,"Picture BMP file write err: " & $spectrum)
	FileClose($BMP)

	_GDIPlus_Startup()
	$bitmap = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\tmp.bmp')
	if @error then return SetError(1,0,"Picture Image read err: " & $spectrum)
	$encoder = _GDIPlus_EncodersGetCLSID("PNG")
	if @error then return SetError(1,0,"Picture PNG encoder err: " & $spectrum)
	_GDIPlus_ImageSaveToFileEx($bitmap, $export & '\' & $spectrum & '_picture.png', $encoder)
	if @error then return SetError(1,0,"Picture PNG write err: " & $spectrum)
	_GDIPlus_ImageDispose($bitmap)
	_GDIPlus_Shutdown()

	_ClipBoard_Close()
EndFunc

Func _Artax_GetGraphEx($spectrum,$export)
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
;	$FEMF = _WinAPI_CopyEnhMetaFile($EMF,''); Copy EMF to memory
	if $FEMF = 0 then SetError(1,0,"Graph EMF write err: " & $spectrum)

	_WinAPI_FreeMemory($PEMF)
	_WinAPI_DeleteEnhMetaFile($EMF)

	_GDIPlus_Startup()
	$image = _GDIPlus_ImageLoadFromFile(@ScriptDir & '\tmp.emf')
;	$image = _GDIPlus_BitmapCreateFromMemory(FileOpen($FEMF))
	if $image = 0 then SetError(1,0,"Graph Image read err: " & $spectrum)
	$encoder = _GDIPlus_EncodersGetCLSID("PNG")
	if @error then SetError(1,0,"Graph PNG encoder err: " & $spectrum)
	_GDIPlus_ImageSaveToFileEx($image, $export & '\' & $spectrum & '_graph.png', $encoder)
	if @error then SetError(1,0,"Graph PNG write err: " & $spectrum)
	_GDIPlus_ImageDispose($image)
	_GDIPlus_Shutdown()

	_ClipBoard_Close()
EndFunc