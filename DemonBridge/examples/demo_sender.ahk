#Requires AutoHotkey v2.0
#Include ..\src\DemonBridge.ahk

br := DemonBridge("Local\DemonBridgeDemo", 64, 3, true)

buf := Buffer(64, 0)
Loop {
    NumPut("UInt", A_TickCount, buf, 0)
    NumPut("Float", Random(-50, 50), buf, 4)
    NumPut("Float", Random(-50, 50), buf, 8)
    br.Write(buf)
    Sleep 10
}
