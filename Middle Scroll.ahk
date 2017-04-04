;Menu MButton Scroll
#NoTrayIcon
#SingleInstance,Force

/*
	Written by Runar "RUNIE" Borge
	Plugin for AHK Studio by maestrith
	Forum topic: https://autohotkey.com/boards/viewtopic.php?f=62&t=300
	
	Desc: Implements the scrolling up/down functionality via the middle mouse button
*/

Key := "RButton" ; key to toggle the scrolling
DeadZone := 60 ; deadzone in pixels
MaxDiff := 300 ; maximum up/down movement in pixels
MaxSleep := 55 ; maximum time between scroll calls in ms

; get studio object
x:=ComObjActive("AHK-Studio")

; close this script when studio closes
x.AutoClose(A_ScriptHwnd)

; get sc control handle
sc := x.sc()

; get hwnd of ahk studio window
hwnd := x.hwnd()

; bind key
Hotkey, IfWinActive, % "ahk_id" hwnd
Hotkey, % Key, ScrollToggle
return

ScrollToggle:
Hotkey, % Key, Off
MouseGetPos,, StartY

Loop {
	MouseGetPos,, CurrentY
	if (CurrentY > StartY + DeadZone) ; scroll up
		sc.2342
	else if (CurrentY < StartY - DeadZone) ; scroll down
		sc.2343
	Sleep % Abs(Limit(Abs(StartY-CurrentY)/MaxDiff, 0, 1) - 1) * MaxSleep
} until GetKeyState(Key, "P") || GetKeyState("Escape", "P")

Hotkey, % Key, On
return

Limit(Var, Min, Max) {
	return (Var>Max?Max:(Var<Min?Min:Var))
}
