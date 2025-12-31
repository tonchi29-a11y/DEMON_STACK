#Requires AutoHotkey v2.0
#Include ..\src\DemonAffinity.ahk

info := DemonAffinity.GetCurrentProcess()
MsgBox "PASS"
    . "`nCPU count: " DemonAffinity.CpuCount()
    . "`nProcess mask: 0x" Format("{:X}", info["processMask"])
    . "`nSystem mask:  0x" Format("{:X}", info["systemMask"])
