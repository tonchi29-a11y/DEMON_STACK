#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()

ok := true
try {
    hk.Add("^!+F24", (name) => 0)
    hk.Enable()
    hk.Disable()
} catch {
    ok := false
}

; AHK v2: MsgBox timeout preko "T1"
MsgBox(ok ? "PASS" : "FAIL", "DemonHotkeys selftest", "T1")
ExitApp(ok ? 0 : 1)
