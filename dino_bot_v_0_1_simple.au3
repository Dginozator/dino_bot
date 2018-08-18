#include <MsgBoxConstants.au3>

Opt("WinTitleMatchMode", 2)

HotKeySet ('{F10}', 'saveCoords') ; Target

TraySetToolTip("F10 - сохранение координат для чтения препятствий\" & @CRLF & "сохранение координат контрольной точки")

Global $g_timeout_traytip = 5

Global $title_search = "[REGEXPTITLE:(?s)([^-]+- Google Chrome)]"

Global $pointType = 0

Global $x1 = 0
Global $y1 = 0

Global $x_audit = 0
Global $y_audit = 0

; HotKeySet ('{SPACE}', 'start') ; autostart. if activate window
; HotKeySet ('{S}', 'stop') ; autostop. If no moves more 3 seconds

Global $play_flag = False

Global $area_wall_search_old = 0
Global $area_wall_search_new = 0

Global $is_wall = False

main ()

Func main ()
   Local $result = 1

   Local $flag_window_active_old = 0
   Local $flag_window_active_new = 0

   While(1)
	  $flag_window_active_new = WinActive($title_search)

	  If $flag_window_active_new <> $flag_window_active_old Then
		 $flag_window_active_old = $flag_window_active_new

		 If $flag_window_active_new Then
			ConsoleWrite("for test 730 active " & $flag_window_active_new & @CRLF)
			If $play_flag == False Then
			   Send('{SPACE}')
			   $play_flag = True
			   TrayTip ("Старт", "Старт", $g_timeout_traytip)
			EndIf
		 Else
			ConsoleWrite("for test 731 non-active " & $flag_window_active_new & @CRLF)
		 EndIf
	  EndIf

	  If $flag_window_active_old <> 0 Then
		 ;ConsoleWrite("for test 2005: actions" & @CRLF)
		 actions()
	  EndIf

	  $flag_window_active_old = $flag_window_active_new
	  Sleep(5)
   WEnd

   Return $result
EndFunc

Func actions ()
   If $play_flag == True Then
	  If isWallTrigger() Then
		 Send('{SPACE}')
	  EndIf
   EndIf
EndFunc

Func isWallTrigger()
   Local $result = False

   Local $delta = 5

   Local $left = $x1 - $delta
   Local $top = $y1 - $delta
   Local $right = $x1 + $delta
   Local $bottom = $y1 + $delta

   $area_wall_search_new = PixelChecksum($left, $top, $right, $bottom)
   If $area_wall_search_new <> $area_wall_search_old Then
	  $left = $x_audit - $delta
	  $top = $y_audit - $delta
	  $right = $x_audit + $delta
	  $bottom = $y_audit + $delta

	  Local $area_control = PixelChecksum($left, $top, $right, $bottom)

	  If $area_control <> $area_wall_search_new Then
		 If $is_wall == False Then
			$is_wall = True
			$result = True
		 EndIf
	  EndIf

	  $area_wall_search_old = $area_wall_search_new
   Else
	  $is_wall = False
   EndIf

   ; $is_wall
   Return $result
EndFunc

Func saveCoords()
   Local $aArr = MouseGetPos ()

   Switch $pointType
	  Case 0
		 $x1 = $aArr[0]
		 $y1 = $aArr[1]
		 TrayTip ("Точка обнаружения препятствий установлена", "Координаты: " & $aArr[0] & ", " & $aArr[1], $g_timeout_traytip)
	  Case 1
		 $x_audit = $aArr[0]
		 $y_audit = $aArr[1]
		 TrayTip ("Контрольная точка установлена", "Координаты: " & $aArr[0] & ", " & $aArr[1], $g_timeout_traytip)
   EndSwitch

   If $pointType >= 1 Then
	  $pointType = 0
   Else
	  $pointType += 1
   EndIf
EndFunc