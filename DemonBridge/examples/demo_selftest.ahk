#Requires AutoHotkey v2.0
#Include ..\src\DemonBridge.ahk

name := "Local\DemonBridgeSelfTest"
br := DemonBridge(name, 64, 3, true)

; write known payload
buf := Buffer(64, 0)
NumPut("UInt", 0x12345678, buf, 0)
NumPut("Float", 1.5, buf, 4)
NumPut("Float", -2.5, buf, 8)
br.Write(buf)

; read it back
out := Buffer(64, 0)
ok := br.ReadLatest(&out)

t := NumGet(out, 0, "UInt")
x := NumGet(out, 4, "Float")
y := NumGet(out, 8, "Float")

MsgBox "PASS=" (ok && t=0x12345678 ? "YES" : "NO")
    . "`nreadOk=" ok
    . "`nt=0x" Format("{:08X}", t)
    . "`nx=" x
    . "`ny=" y
