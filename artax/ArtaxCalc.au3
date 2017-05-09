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
$gui = GUICreate("ArtaxCalc v 1.5", 351, 91)
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
					FileWriteLine($out, 'sep=;' & @CRLF & "ID;Num.;Na;Na;Mg;Mg;Al;Al;Si;Si;P;P;K;K;Ca;Ca;Ti;Ti;Mn;Mn;Fe;Fe" & @CRLF & _
					";;(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd);(avg);(sd)")
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
	local $begin = 0, $end, $line[22]; ID,Num. + 20
;	_ArrayDisplay($data)
	for $i = 0 to UBound($data) - 1
		if $i + 1 <= UBound($data) - 1 then; overflow
			if $data[$i][0] <> $data[$i+1][0] or $i + 1 = UBound($data) - 1 then; last or last total
				if $end + 1 = UBound($data) - 1 then $end+=1; last value
				$line[0]=$data[$begin][0]; ID
				$line[1]=$end - $begin + 1; Num.
				;mean
				for $j = 1 to 10
					for $k = $begin to $end
						$line[$j*2]+=$data[$k][$j]
					next
					$line[$j*2] = $line[$j*2]/($end - $begin + 1); odd
				next
				;deviation
				for $j = 1 to 10
					for $k = $begin to $end
						$line[$j*2+1]+=($data[$k][$j]-$line[$j*2])^2
					next
					$line[$j*2+1] = sqrt($line[$j*2+1]/($end - $begin + 1)); even
				next
				;round/format output
				for $j = 1 to 10; zero-ize array
					$line[$j*2] = StringFormat("%.02f",round($line[$j*2],2))
					$line[$j*2+1] = StringFormat("%.03f",round($line[$j*2+1],3))
				next
				;write & reinit
				FileWriteLine($out,_ArrayToString($line,";"))
				for $j = 2 to 21; zero-ize array
					$line[$j] = 0
				next
				$begin = $end + 1; update start index
			Endif
			$end+=1; update end index
		EndIf
	next
EndFunc