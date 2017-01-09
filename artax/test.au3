
;"how to get image from clipboard without loss quality? -> @"

;MsgBox(Default,"test",StringRegExpReplace("ARTAX - [tabl_0@190916_145648]","^.*\[(.*)\]$","$1"))
#include <Array.au3>
#include <Clipboard.au3>
#include <GDIPlus.au3>
#include <WinAPIGDI.au3>
#include <WinAPIDiag.au3>
#include <Memory.au3>

;_ClipBoard_GetDataEx
$hwndartax = WinGetHandle("ARTAX -")
if @error then MsgBox(Default,"whnd","Failed.")
WinActivate("ARTAX -")
Send('^d')
;sleep(5000)
;$text = _ClipBoard_GetData($CF_TEXT)

;------

;Send('{RIGHT}')
;Send('{DOWN}')
;sleep(1000);Hold on a sec.!
;$pic = WinGetHandle("Picture")
;WinActivate($pic)
;MouseClick("right")
;Send('c')

;------
;
;!
;
;$map = _ClipBoard_GetDataEx(3)
;
; GetMetaFileBitsEx($map,size,ptrout) -> SetWinMetaFileBits(mapsize,bitssize,) -> ENHMETA
; 


;MsgBox(Default,"buff","Got buff!")
;sleep(1000)
;$map = _ClipBoard_GetData($CF_METAFILEPICT)

if _ClipBoard_IsFormatAvailable(1) then MsgBox(Default,"clip","Clipboard bitmap is available.")
;if not _ClipBoard_IsFormatAvailable(3) then MsgBox(Default,"clip","Clipboard is available.")
;if not _ClipBoard_IsFormatAvailable(14) then MsgBox(Default,"clip","Clipboard is not available.")
;_ClipBoard_Open($hwndartax); hook clipboard
;_ClipBoard_GetFormatName(
;_ClipBoard_Open(0); hook clipboard
;if @error then MsgBox(Default,"clip hook","Failed. " & @error)
;$map = DllCall("user32.dll", "handle", "GetClipboardData", "uint", 3)
;$map = DllCall("user32.dll", "handle", "GetClipboagrdData", "uint",14)

;$map = _ClipBoard_GetDataEx(3)
;$map = _ClipBoard_GetData(14)
;if @error Then MsgBox(Default,"map","Failed. " & @error)
;MsgBox(Default,"map ptr",$map)

;$buff = _MemGlobalLock($map)
;if $buff = 0 Then
;    _ClipBoard_Close()
;	MsgBox(Default,"mem","Empty buff.")
;endif
;MsgBox(Default,"map ptr",$buff)

;$buffsize = _MemGlobalSize($map)
;if $buffsize = 0 Then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Zero buff size.")
;endif
;MsgBox(Default,"map ptr",$buffsize)

;_ClipBoard_Close()

;$dstr = DllStructCreate("LONG;LONG;LONG;HANDLE", $buff)
;$dstr = DllStructCreate("LONG;LONG;LONG;HANDLE", $buff)
;If @error Then MsgBox(Default,"err","data error " & @error)
;$buff = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", $map)
;If @error Then MsgBox(Default,"mem lock error", @error)

;$x = DllStructGetData($dstr, 2)
;If @error Then MsgBox(Default,"err","data error " & @error)
;$y = DllStructGetData($dstr, 3)
;If @error Then MsgBox(Default,"err","data error " & @error)
;$data = DllStructGetData($dstr, 4)
;If @error Then MsgBox(Default,"err","data error " & @error)

;if IsPtr($data) then MsgBox(Default,"hmf","Got file, x: " & $x & " y: " & $y & " ptr: " & $data )

;_GDIPlus_Startup()
;$type = _GDIPlus_ImageGetType($data)
;if not @error then MsgBox(Default,"type",$type)
;_GDIPlus_Shutdown()


;$res = DllCall("kernel32.dll", "ptr", "GlobalLock", "handle", DllStructGetData($dstr, 4))
;if not @error then _ArrayDisplay($res)
;$databuff = _MemGlobalLock(DllStructGetData($dstr, 4))
;if $databuff = 0 Then
;    _ClipBoard_Close()
;	MsgBox(Default,"mem","Empty buff.")
;endif

;$buffsize = _MemGlobalSize($data)
;if not @error then MsgBox(Default,"data size", $buffsize)
;$buff = DllStructCreate("LONG;LONG;LONG;HANDLE", $map)
;_GDIPlus_ImageGetType($map)
;if @error then MsgBox(Default,"err","img type fail.")

;$b = FileOpen(@ScriptDir & '\data.bin',16)
;If @error Then MsgBox(Default,"fail","file open fail")
;FileWrite($b,$data)
;If @error Then MsgBox(Default,"fail","write fail")
;FileClose($b)

;_MemGlobalUnlock($buff)
;_ClipBoard_Close()

;if $map = 0 then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Empty ptr. " & $map)
;	Exit
;endif

;$buffsize = _MemGlobalSize($map)
;if $buffsize = 0 Then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Zero buff size.")
;endif


;$buff = _MemGlobalLock($map)
;if $buff = 0 Then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Empty buff.")
;	Exit
;endif

;_GDIPlus_Startup()
;_GDIPlus_ImageGetWidth($map)
;if @error then MsgBox(Default,"bbmp","Failed..: " & @error & " ext: " & @extended)

;$hbitmap = _GDIPlus_BitmapCreateFromHBITMAP($map)
;if @error then MsgBox(Default,"bbmp","Failed..: " & @error & " ext: " & @extended)

;_GDIPlus_Shutdown()

;$type = _GDIPlus_ImageGetType($map)
;if @error then MsgBox(Default,"err","err: " & @extended)

;$meta = DllStructCreate("LONG;LONG;LONG;ptr")
;if @error then MsgBox(Default,"str","Failed to create struct!")

;DllCall("user32.dll", "handle", "GetClipboardData", "uint",14)
;if @error then MsgBox(Default,"str","Failed to get struct!")

;$mm = DllStructGetData($meta,1)
;if @error then MsgBox(Default,"str","Failed to get struct data!")

;MsgBox(Default,"mm", $mm)

;DllStructSetData($meta,$map)

;if IsPtr($map[0]) then MsgBox(Default,"ptr", "Got ptr!: " & $map[0])

;_WinAPI_GetEnhMetaFileBits( $mhf, $map[0])
;if @error then MsgBox(Default,"emf","Failed!")

;MsgBox(Default,"type",_GDIPlus_ImageGetType($map[0]))

;_GDIPlus_Startup()
;$hbitmap = _GDIPlus_BitmapCreateFromHBITMAP($map[0])
;$hbitmap = _GDIPlus_BitmapCreateFromStream($map[0])
;if @error then
;	_ClipBoard_Close()
;	_WinAPI_DeleteObject($hbitmap)
;	_GDIPlus_Shutdown()
;else
;	MsgBox(Default,"bmp","Got bitmap!")
;endif


;$bmap = _GDIPlus_BitmapCreateFromStream
;$bmap = _GDIPlus_

;MsgBox(Default,"mem",$bmap)


;if $map[0] = 0 then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Empty ptr. " & $map)
;	Exit
;endif

;$buff = _MemGlobalLock($map[0])

;if $buff = 0 Then
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Empty buff.")
;	Exit
;endif

; _WinAPI_S

;$mm = DllStructGetData($map[0],"mm")
;if @error then MsgBox (Default,"Struct","Failed")

;$buffsize = _MemGlobalSize($map[0])
;if $buff = 0 Then
;	_MemGlobalUnlock($map[0])
;	_ClipBoard_Close()
;	MsgBox(Default,"mem","Zero buff size.")
;	Exit
;endif

;MsgBox(Default,"buff size", $buffsize)

;$data = DllStructCreate("byte[" & $buffsize & "]", $buff)
;$ret = DllStructGetData($data, 1)

;_MemGlobalUnlock($map)
;_ClipBoard_Close()

;MsgBox(Default,"data",$ret)

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

