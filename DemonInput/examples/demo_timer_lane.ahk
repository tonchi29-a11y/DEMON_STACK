#Requires AutoHotkey v2.0
#Include ..\src\DemonInput.ahk

global gLast := Map("dx", 0, "dy", 0, "t", 0, "src", "")

gOnSample(dx, dy, tMs, source) {
    global gLast
    gLast["dx"] := dx
    gLast["dy"] := dy
    gLast["t"] := tMs
    gLast["src"] := source
}

inp := DemonInput(gOnSample)
inp.StartTimerLane(4)

SetTimer(UpdateTip, 250)

UpdateTip() {
    global gLast
    ToolTip(
        "timer lane`n"
        . "dx=" gLast["dx"] " dy=" gLast["dy"] "`n"
        . "t=" gLast["t"]
    )
}

Esc::ExitApp
