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

GetPid() {
    return DllCall("kernel32.dll\GetCurrentProcessId", "UInt")
}

hk := DemonHotkeys()
showing := true
last := "boot"

ShowTip() {
	global showing, last
	if !showing {
		ToolTip ""
		return
	}
	pid := GetPid()
	ToolTip "DemonHotkeys live"
		. "`npid=" pid
		. "`nCtrl+Alt+H  show"
		. "`nCtrl+Alt+C  hide/show"
		. "`nCtrl+Alt+Q  quit"
		. "`nEsc / F12   quit (hard)"
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