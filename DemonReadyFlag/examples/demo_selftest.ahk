#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

#Include ..\src\DemonReadyFlag.ahk

name := "Local\DemonReadyFlagSelftest_" DllCall("kernel32.dll\GetCurrentProcessId", "UInt")

a := DemonReadyFlag(name)
b := DemonReadyFlag(name)

ok := true
ok := ok && !a.IsReady()
ok := ok && a.SetReady(true)
ok := ok && b.IsReady()
ok := ok && b.SetReady(false)
ok := ok && !a.IsReady()

MsgBox(ok ? "PASS" : "FAIL", "DemonReadyFlag selftest", "T1")
ExitApp(ok ? 0 : 1)
