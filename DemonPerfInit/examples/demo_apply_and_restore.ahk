#Requires AutoHotkey v2.0
#Include ..\src\DemonPerfInit.ahk

MsgBox "Applying SAFE preset..."
token := DemonPerfInit.ApplyPreset("SAFE")

MsgBox "Preset applied. HotkeyInterval=" A_HotkeyInterval " Max=" A_MaxHotkeysPerInterval

MsgBox "Restoring (best-effort)..."
DemonPerfInit.Restore(token)

MsgBox "Done." "`nHotkeyInterval=" A_HotkeyInterval "`nMaxHotkeysPerInterval=" A_MaxHotkeysPerInterval
