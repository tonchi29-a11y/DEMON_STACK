#Requires AutoHotkey v2.0
#Include ..\src\DemonTime.ahk

try {
    f := DemonTime.Freq()
    t0 := DemonTime.NowQpc()
    Sleep 10
    ms := DemonTime.MsSince(t0)

    MsgBox "PASS`nQPC freq: " f "`nMsSince(10ms sleep): " Round(ms, 3)
} catch as e {
    MsgBox "FAIL`n" e.Message
}
