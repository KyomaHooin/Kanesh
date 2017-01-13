;
; Helper clipboard data extraction function for Bruker Artax 400 binary program.
;
; _Artax_GetTableEx ......... Clipboard CF_TEXT to CSV file.
; _Artax_GetPictureEx ....... Convert clipboard CF_DIB to BITMAP, encoded to PNG file.
; _Artax_GetGraphEx ......... Convert clipboard CF_METAFILEPICT WMF to EMF, encoded to PNG file.
;
;----------------------------

#include <Clipboard.au3>
#include <GDIPlus.au3>

;
; Get CSV from TEXT clipboard.
;

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

;
; Get PNG image from DIB clipboard.
;

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

	$buffer = 	DllStructGetData($HEADER,1) & _
				DllStructGetData($HEADER,2) & _
				DllStructGetData($HEADER,3) & _
				DllStructGetData($HEADER,4) & _
				DllStructGetData($DIB,1)
	if @error then return SetError(1,0,"Picture MBF buffer err: " & $spectrum)

	_MemGlobalUnlock($PDIB)
	_MemGlobalFree($PDIB)

	$DIB = 0;free DIB struct

	_GDIPlus_Startup()
	$bitmap = _GDIPlus_BitmapCreateFromMemory($buffer)
	if @error then return SetError(1,0,"Picture Image read err: " & $spectrum)
	$encoder = _GDIPlus_EncodersGetCLSID("PNG")
	if @error then return SetError(1,0,"Picture PNG encoder err: " & $spectrum)
	_GDIPlus_ImageSaveToFileEx($bitmap, $export & '\' & $spectrum & '_picture.png', $encoder)
	if @error then return SetError(1,0,"Picture PNG write err: " & $spectrum)
	_GDIPlus_ImageDispose($bitmap)
	_GDIPlus_Shutdown()

	_ClipBoard_Close()
EndFunc

;
; Get PNG image from WMF clipboard.
;

Func _Artax_GetGraphEx($spectrum,$export)
	if not _ClipBoard_IsFormatAvailable(3) then return SetError(1,0,"Graph clip format err: " & $spectrum); CF_METAFILEPICT

	_ClipBoard_Open(0); hook clipboard
	if @error then return SetError(1,0,"Graph clip lock err: " & $spectrum)

	$MFP = _ClipBoard_GetDataEx(3); clipboard METAFILEPICT struct ptr
	if $MFP = 0 then return SetError(1,0,"Graph METAFILEPICT struct ptr err: " & $spectrum)

	$MFP = DllStructCreate("LONG;LONG;LONG;HANDLE", $MFP); clipboard METAFILEPICT struct
	if @error then return SetError(1,0,"Graph METAFILE struct err: " & $spectrum)

	$HWMF = DllStructGetData($MFP, 4);METAFILE handle ptr
	if $HWMF = 0 then return SetError(1,0,"Graph METAFILE handle ptr err: " & $spectrum)

	$MFP = 0;free MFP struct

	$WMFBUFFSIZE = DllCall('gdi32.dll', "uint", "GetMetaFileBitsEx", "handle", $HWMF, "int", 0, "ptr", null); WMF buffer size in bytes
	if $WMFBUFFSIZE = 0 then return SetError(1,0,"Graph WMF buffer size err: " & $spectrum)

	$WMF = DllStructCreate('byte[' & $WMFBUFFSIZE[0] & ']'); WMF buffer struct
	if @error then return SetError(1,0,"Graph WMF struct err: " & $spectrum)
	$PWMF = DllStructGetPtr($WMF); WMF buffer ptr
	if @error then return SetError(1,0,"Graph WMF struct ptr err: " & $spectrum)

	$WMFBYTES = DllCall('gdi32.dll', "uint", "GetMetaFileBitsEx", "handle", $HWMF, "int", $WMFBUFFSIZE[0], "ptr", $PWMF); fill WMF buffer ptr
	if $WMFBYTES = 0 then SetError(1,0,"Graph WMF buffer err: " & $spectrum)

	$HEHMF = DllCall('gdi32.dll', "handle", "SetWinMetaFileBits", "int", $WMFBUFFSIZE[0], "ptr", $PWMF, "handle", null, "handle", null); convert WMF buffer ptr to EMF handle
	if $HEHMF = Null then SetError(1,0,"Graph WMF buffer to EHMF handle err: " & $spectrum)

	$WMF = 0; free WMF struct

	$EHMFBUFFSIZE = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileBits', 'handle', $HEHMF[0], 'uint', 0, 'ptr', 0)
	if $EHMFBUFFSIZE = 0 then return SetError(1,0,"Graph EHMF buffer size err: " & $spectrum)

	$EHMF = DllStructCreate('byte[' & $EHMFBUFFSIZE[0] & ']'); EMF buffer struct
	if @error then return SetError(1,0,"Graph EHMF struct err: " & $spectrum)
	$PEHMF = DllStructGetPtr($EHMF); EHMF buffer ptr
	if @error then return SetError(1,0,"Graph EHMF struct ptr err: " & $spectrum)

	$EHMFBYTES = DllCall('gdi32.dll', 'uint', 'GetEnhMetaFileBits', 'handle', $HEHMF[0], 'uint', $EHMFBUFFSIZE[0], 'ptr', $PEHMF); fill EHMF buffer ptr
	if $EHMFBYTES = 0 then SetError(1,0,"Graph EHMF buffer ptr err: " & $spectrum)

	$buffer = DllStructGetData($EHMF,1)
	if @error then return SetError(1,0,"Graph EHMF buffer err: " & $spectrum)

	$EHMF = 0;free EHMF struct

	_GDIPlus_Startup()
	$image = _GDIPlus_BitmapCreateFromMemory($buffer)
	if $image = 0 then SetError(1,0,"Graph Image memory read err: " & $spectrum)
	$encoder = _GDIPlus_EncodersGetCLSID("PNG")
	if @error then SetError(1,0,"Graph PNG encoder err: " & $spectrum)
	_GDIPlus_ImageSaveToFileEx($image, $export & '\' & $spectrum & '_graph.png', $encoder)
	if @error then SetError(1,0,"Graph PNG write err: " & $spectrum)
	_GDIPlus_ImageDispose($image)
	_GDIPlus_Shutdown()

	_ClipBoard_Close()
EndFunc
