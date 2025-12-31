#Requires AutoHotkey v2.0
#Include ..\src\DemonPack64.ahk

buf := DemonPack64.New()

accel := [1.0, 2.0, 3.0, 4.0]
sens := [0.10, 0.20, 0.30, 0.40]

DemonPack64.PackFull(buf, 123456789, 0x3, 1.5, -2.5, accel, sens)

m := DemonPack64.Unpack(buf)

pass := (m["ts"] = 123456789)
    && (m["flags"] = 0x3)
    && (Abs(m["emaX"] - 1.5) < 0.0001)
    && (Abs(m["emaY"] + 2.5) < 0.0001)

MsgBox "PASS=" (pass ? "YES" : "NO")
    . "`nts=" m["ts"]
    . "`nflags=0x" Format("{:X}", m["flags"])
    . "`nemaX=" m["emaX"]
    . "`nemaY=" m["emaY"]
