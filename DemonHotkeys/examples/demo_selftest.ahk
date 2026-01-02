#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()

ok := true
try {
    idx := hk.Add("^!h", (name) => 0)
    hk.Enable()
    hk.Disable()
    ok := ok && hk.Remove(idx)
    hk.Clear()
} catch {
    ok := false
}

MsgBox(ok ? "PASS" : "FAIL", "DemonHotkeys selftest", "T1")
ExitApp(ok ? 0 : 1)
