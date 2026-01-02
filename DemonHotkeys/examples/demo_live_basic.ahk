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

; --- Emergency EXIT window (mouse kill, always works) ---
exitGui := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -MaximizeBox", "DemonHotkeys Exit")
exitGui.SetFont("s10", "Segoe UI")
exitGui.AddText("", "pid=" pid " admin=" adm)
btn := exitGui.AddButton("w160 h40", "EXIT NOW")
btn.OnEvent("Click", (*) => ExitApp())
exitGui.Show("NoActivate x20 y20")

; Tray menu (može biti mrtav kad je admin=1, zato imamo GUI)
A_TrayMenu.Delete()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Exit"
A_TrayMenu.ClickCount := 1

hk := DemonHotkeys()
showing := true
last := "boot"

ShowTip() {
	global showing, last, pid, adm
	if !showing {
		ToolTip ""
		return
	}
	ToolTip "DemonHotkeys live"
		. "`npid=" pid " admin=" adm
		. "`nCtrl+Alt+H show"
		. "`nCtrl+Alt+C hide/show"
		. "`nCtrl+Alt+Q quit"
		. "`n(last=" last ")"
		. (adm ? "`nNOTE: admin=1 can break tray exit" : "")
}

hk.Add("^!h", (*) => (showing := true, last := "^!h", ShowTip()))
hk.Add("^!c", (*) => (showing := !showing, last := "^!c", ShowTip()))
hk.Add("^!q", (*) => ExitApp())
hk.Enable()
ShowTip()

; Safety: auto-exit after 5 minutes so nikad ne mora Task Manager
SetTimer((*) => ExitApp(), -300000)

OnExit((*) => hk.Disable())