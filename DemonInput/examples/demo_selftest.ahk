#Requires AutoHotkey v2.0
#Include ..\src\DemonInput.ahk

samples := 0

OnSample(dx, dy, tMs, source) {
    global samples
    if (source = "timer")
        samples += 1
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4)

Sleep 2000
inp.Stop()

MsgBox "DemonInput self-test complete." 
    . "`nTimer samples: " samples
