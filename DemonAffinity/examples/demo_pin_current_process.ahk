#Requires AutoHotkey v2.0
#Include ..\src\DemonAffinity.ahk

; Demonstrates pinning then restores the original mask before exit.

before := DemonAffinity.GetCurrentProcess()
orig := before["processMask"]
MsgBox "Before:`nProcess mask: 0x" Format("{:X}", orig)

; Pin to CPUs 2-5 (adjust if you have fewer cores)
mask := DemonAffinity.MakeMask(2, 4)
ok := DemonAffinity.SetCurrentProcess(mask)
after := DemonAffinity.GetCurrentProcess()

MsgBox "SetCurrentProcess ok=" ok
    . "`nAfter:`nProcess mask: 0x" Format("{:X}", after["processMask"])

; Restore original mask so the demo leaves the process unchanged.
DemonAffinity.SetCurrentProcess(orig)
