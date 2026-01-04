#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

#Include ..\src\DemonAtomicFile.ahk

p := A_Temp "\\demon_atomicfile_selftest.txt"
try {
    FileDelete(p)
} catch {
}

ok := true
try {
    DemonAtomicFile.WriteTextAtomic(p, "hello`nworld", "UTF-8")
    s := FileRead(p, "UTF-8")
    ok := ok && InStr(s, "hello")
} catch {
    ok := false
}

MsgBox(ok ? "PASS" : "FAIL", "DemonAtomicFile selftest", "T1")
ExitApp(ok ? 0 : 1)
