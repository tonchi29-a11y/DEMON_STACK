#Requires AutoHotkey v2.0
#Include ..\src\DemonHotkeys.ahk

hk := DemonHotkeys()

hk.Add("^!h", (name) => ToolTip("Pressed: " name))
hk.Add("^!c", (name) => ToolTip(""))
hk.Add("^!q", (name) => ExitApp())

hk.Enable()
ToolTip "DemonHotkeys live`nCtrl+Alt+H show`nCtrl+Alt+C clear`nCtrl+Alt+Q quit"

OnExit((*) => hk.Disable())
