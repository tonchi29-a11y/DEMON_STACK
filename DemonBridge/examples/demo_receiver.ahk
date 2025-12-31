#Requires AutoHotkey v2.0
#Include ..\src\DemonBridge.ahk

br := DemonBridge("Local\DemonBridgeDemo", 64, 3, true)
out := Buffer(64, 0)

SetTimer(UpdateTip, 100)

UpdateTip() {
    global br, out
    if br.ReadLatest(&out) {
        t := NumGet(out, 0, "UInt")
        x := NumGet(out, 4, "Float")
        y := NumGet(out, 8, "Float")
        ToolTip "t=" t "`nx=" Round(x, 2) " y=" Round(y, 2)
    } else {
        ToolTip "no data"
    }
}

Esc::ExitApp
