#Requires AutoHotkey v2.0
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()

id := hk.Add("^!+F24", (name) => 0)

ok := true
try {
    hk.Enable()
    hk.Disable()
    ok := ok && hk.Remove(id)
    hk.Clear()
} catch {
    ok := false
}

; Selftest runner can treat exit code 0 as PASS.
ExitApp(ok ? 0 : 1)
