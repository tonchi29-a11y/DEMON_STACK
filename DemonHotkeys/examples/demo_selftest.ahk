#Requires AutoHotkey v2.0
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()

; Use an unlikely key to avoid conflicts.
idx := hk.Add("^!+F24", (name) => 0)

ok := true
try {
    hk.Enable()
    hk.Disable()
    ok := ok && hk.Remove(idx)
    hk.Clear()
} catch {
    ok := false
}

ExitApp(ok ? 0 : 1)
