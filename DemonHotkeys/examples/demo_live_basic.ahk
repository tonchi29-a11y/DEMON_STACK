#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
#Include ..\src\DemonHotkeys.ahk

GetPid() {
	return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

IsAdmin() {
	return !!DllCall("shell32.dll\IsUserAnAdmin", "Int")
}

pid := GetPid()
adm := IsAdmin()

; Tray Exit (može biti mrtav ako je admin/UIPI, zato imamo timer exit)
A_TrayMenu.Delete()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Exit"
A_TrayMenu.ClickCount := 1

hk := DemonHotkeys()
showing := true
last := "boot"
ticks := 0

ShowTip() {
	global showing, last, pid, adm, ticks
	if !showing {
		ToolTip ""
		return
	}
	ToolTip "DemonHotkeys live (PANIC SAFE)"
		. "`npid=" pid " admin=" adm
		. "`nEsc/F12: quit (polled timer)"
		. "`nCtrl+Alt+H show"
		. "`nCtrl+Alt+C hide/show"
		. "`nCtrl+Alt+Q quit"
		. "`nticks=" ticks " last=" last
		. (adm ? "`nNOTE: admin=1 can break tray exit" : "")
}

; DemonHotkeys actions (nice-to-have)
hk.Add("^!h", (*) => (showing := true, last := "^!h", ShowTip()))
hk.Add("^!c", (*) => (showing := !showing, last := "^!c", ShowTip()))
hk.Add("^!q", (*) => ExitApp())
hk.Enable()

; Timer proves the script is alive and gives us exit even if hotkeys are dead.
SetTimer(Heartbeat, 250)
Heartbeat(*) {
	global ticks
	ticks += 1
	ShowTip()
}

; PANIC EXIT: poll physical key state (does NOT require hotkey hook)
SetTimer(PollExit, 30)
PollExit(*) {
	; "P" = physical state
	if GetKeyState("Esc", "P") || GetKeyState("F12", "P") {
		ExitApp
	}
}

; Absolute safety: never force Task Manager again
SetTimer(AutoExit, -300000) ; 5 minutes
AutoExit(*) => ExitApp

OnExit((*) => hk.Disable())

ShowTip()