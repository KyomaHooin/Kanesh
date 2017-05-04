;
; Calculate Mean / Standard Deviation from ArtaxExport CSV output
;

#AutoIt3Wrapper_Icon=artax.ico
#NoTrayIcon

;INCLUDE
#include <GUIConstantsEx.au3>
#include <File.au3>

;VAR

$runtime = @YEAR & @MON & @MDAY & 'T' & @HOUR & @MIN & @SEC
$mapping = @ScriptDir & '\spectra.txt'

;CONTROL
;already running
If UBound(ProcessList(@ScriptName)) > 2 Then Exit

;GUI
$gui = GUICreate("ArtaxCalc v 1.4", 351, 91)
$gui_path = GUICtrlCreateInput("", 6, 8, 255, 21)
$button_path = GUICtrlCreateButton("Prochazet", 270, 8, 75, 21)
$gui_progress = GUICtrlCreateProgress(6, 38, 338, 16)
$gui_error = GUICtrlCreateLabel("", 8, 66, 172, 15)
$button_enum = GUICtrlCreateButton("Start", 188, 63, 75, 21)
$button_exit = GUICtrlCreateButton("Konec", 270, 63, 75, 21)

;GUI INIT
GUICtrlSetState($button_path, $GUI_FOCUS)
GUISetState(@SW_SHOW)

While 1
	$event = GUIGetMsg() ; catch event
	If $event = $button_path Then ; data path
		$export_path = FileSelectFolder("Artax/CSV Directory", @HomeDrive, Default)
		If Not @error Then
			GUICtrlSetData($gui_path, $export_path)
		EndIf
	EndIf
	If $event = $button_enum Then ; rename
		local $map
		_FileReadToArray($mapping, $map,0,';')
		If @error Then
			GUICtrlSetData($gui_error, "Chyba: Nacteni seznamu selhalo.")
		ElseIf GUICtrlRead($gui_path) == '' Then
			GUICtrlSetData($gui_error, "Chyba: Prazdna cesta.")
		ElseIf Not FileExists(GUICtrlRead($gui_path)) Then
			GUICtrlSetData($gui_error, "Chyba: Adresar neexistuje.")
		Else
			$filelist = _FileListToArrayRec(GUICtrlRead($gui_path), '*.csv', 1, 1, 1, 2) ; recursion, files only, sorted, fullpath..
			If UBound($filelist) < 2 Then
				GUICtrlSetData($gui_error, "Chyba: Adresar neobsahuje data.")
			Else
				;crete spectra fixed name array
				for $i = 0 to UBound($map) - 1
					$map[$i][0] = StringRegExpReplace($map[$i][0],".*_(.*)","$1")
					$map[$i][1] = StringRegExpReplace($map[$i][1],"(.*)_.*","$1")
				next
				local $csv, $raw, $data[0][11]
				for $i = 1 To UBound($filelist) - 1
					;get SID
					if StringRegExp($filelist[$i],".*\\tabl_\d+@.*$") = 1 Then
						$sid = sid_by_id(StringRegExpReplace($filelist[$i],".*\\tabl_(\d+)@.*$","$1"),$map)
					else
						$sid = StringRegExpReplace($filelist[$i],".*\\(.*)_.*$","$1")
					endif
					;read CSV by spectra
					if $sid then
						local $fill[1][11]; name + 10 element
						_FileReadToArray($filelist[$i], $raw,2,';')
						if UBound($raw) = 12 then; check CSV compat
							$fill[0][0] = $sid;
							for $j = 2 to UBound($raw) - 1; skip 2, move 0,1,10 col.. [number,element,conc.]
								$fill[0][$j-1] = StringRegExpReplace(($raw[$j])[9],',','.')
							next
						EndIf
						_ArrayAdd($data, $fill); populate
					endif
					GUICtrlSetData($gui_progress, Round($i / (UBound($filelist) - 1) * 100)) ; update progress
					GUICtrlSetData($gui_error, StringRegExpReplace($filelist[$i], ".*\\(.*)$", "$1"))
				next
				_ArraySort($data); array sort
				$out = FileOpen(@ScriptDir & '\artax_calc_' & $runtime & ".csv", 258); UTF-8 no BOM overwrite
				if not @error then
					FileWriteLine($out, 'sep=;' & @CRLF & "ID;Na;Mg;Al;Si;P;K;Ca;Ti;Mn;Fe")
					calc($out,$data); calculate
				endif
				FileClose($out)
				GUICtrlSetData($gui_progress, 0) ; clear progress
				GUICtrlSetData($gui_error, "Hotovo!")
			endif
		Endif
	EndIf
	If $event = $GUI_EVENT_CLOSE Or $event = $button_exit Then
		Exit; exit
	EndIf
WEnd

func sid_by_id($id,$map)
	$index = _ArraySearch($map,$id)
	if not @error then return $map[$index][1]
EndFunc

func calc($out,$data)
	local $begin = 0, $end, $line[11]
	for $i = 0 to UBound($data) - 1
		if $i + 1 <= UBound($data) - 1 then; overflow
			if $data[$i][0] <> $data[$i+1][0] or $i + 1 = UBound($data) - 1 then; last or last total
				;mean
				$line[0]=$data[$begin][0] & "(avg)"
				for $j = 1 to 10
					if $end + 1 = UBound($data) - 1 then $end+=1; last value
					for $k = $begin to $end
						$line[$j]+=$data[$k][$j]
					next
					$line[$j] = round($line[$j]/($end - $begin + 1),4); 0-array => +1
				next
				FileWriteLine($out,_ArrayToString($line,";"))
				$mean = $line; copy mean..
				for $j = 1 to 10; zero-ize array
					$line[$j] = 0
				next
				;deviation
				$line[0]=$data[$begin][0] & "(sd)"
				for $j = 1 to 10
					if $end + 1 = UBound($data) - 1 then $end+=1; last value
					for $k = $begin to $end
						$line[$j]+=($data[$k][$j]-$mean[$j])^2
					next
					$line[$j] = round(sqrt($line[$j]/($end - $begin + 1)),4); 0-array => +1
				next
				FileWriteLine($out,_ArrayToString($line,";"))
				for $j = 1 to 10; zero-ize array
					$line[$j] = 0
				next
				$begin = $end + 1; update start index
			Endif
			$end+=1; update end index
		EndIf
	next
EndFunc