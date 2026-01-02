#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook
#Warn All, Off
#Include ..\src\DemonHotkeys.ahk

; Tray uvijek ima Exit
A_TrayMenu.Delete()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Exit"
A_TrayMenu.ClickCount := 1

hk := DemonHotkeys()
showing := true
last := "boot"

GetPid() {
	return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

IsAdmin() {
	; simple admin check
	return !!DllCall("shell32.dll\IsUserAnAdmin", "Int")
}

ShowTip() {
	global showing, last
	if !showing {
		ToolTip ""
		return
	}
	pid := GetPid()
	adm := IsAdmin()
	ToolTip "DemonHotkeys live"
		. "`npid=" pid " admin=" adm
		. "`nCtrl+Alt+H  show"
		. "`nCtrl+Alt+C  hide/show"
		. "`nCtrl+Alt+Q  quit"
		. "`nEsc / F12   quit"
		. "`nlast=" last
}

hk.Add("^!h", (*) => (showing := true, last := "^!h", ShowTip()))
hk.Add("^!c", (*) => (showing := !showing, last := "^!c", ShowTip()))
hk.Add("^!q", (*) => ExitApp())

hk.Enable()
ShowTip()

; HARD exits (ne ovise o DemonHotkeys ni tray)
*Esc::ExitApp
*F12::ExitApp

OnExit((*) => hk.Disable())