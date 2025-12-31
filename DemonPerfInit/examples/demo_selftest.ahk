#Requires AutoHotkey v2.0
#Include ..\src\DemonPerfInit.ahk

before := Map(
    "HotkeyInterval", A_HotkeyInterval,
    "MaxHotkeysPerInterval", A_MaxHotkeysPerInterval
)

token := DemonPerfInit.ApplyPreset("MATCH")

after := Map(
    "HotkeyInterval", A_HotkeyInterval,
    "MaxHotkeysPerInterval", A_MaxHotkeysPerInterval
)

MsgBox "PASS"
    . "`nPreset=" token["preset"]
    . "`nBefore: HotkeyInterval=" before["HotkeyInterval"] " Max=" before["MaxHotkeysPerInterval"]
    . "`nAfter:  HotkeyInterval=" after["HotkeyInterval"] " Max=" after["MaxHotkeysPerInterval"]
    . "`nProcessPriorityApplied=" (token["applied"]["ProcessPriority"] ? "true" : "false")
    . "`nThreadPriorityApplied=" (token["applied"]["ThreadPriority"] ? "true" : "false")
