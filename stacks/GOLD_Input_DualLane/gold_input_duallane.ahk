#Requires AutoHotkey v2.0
#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk

; GOLD demo: Dual-lane input -> SPSC -> EMA -> ToolTip
;
; Toggle lanes with Ctrl+Alt+R:
; - Timer lane: MouseGetPos deltas
; - Raw lane: WM_INPUT deltas (inputSink + aggregatePerTick enabled)

global gLane := "timer"
global gInp := 0
global gQ := DemonSpscRing(2048)
global gEma := DemonEma(25, 0.12)

global gLastSrc := ""
global gSamples := 0

OnSample(dx, dy, tMs, source) {
    global gQ, gLastSrc, gSamples
    gLastSrc := source
    gSamples += 1
    gQ.Push(dx, dy, tMs)
}

StartTimerLane() {
    global gInp, gLane, gQ, gEma, gSamples
    gLane := "timer"
    gQ.Clear()
    gEma.Reset(0, 0)
    gSamples := 0
    gInp.Stop()
    gInp.StartTimerLane(4)
}

StartRawLane() {
    global gInp, gLane, gQ, gEma, gSamples
    gLane := "raw"
    gQ.Clear()
    gEma.Reset(0, 0)
    gSamples := 0
    gInp.Stop()
    ; inputSink=true, aggregatePerTick=true
    gInp.StartRawInputLane(A_ScriptHwnd, true, true)
}

Drain(*) {
    global gQ, gEma
    while gQ.Pop(&dx, &dy, &tMs) {
        gEma.UpdateSample(dx, dy, tMs)
    }
}

Show(*) {
    global gLane, gLastSrc, gSamples, gQ, gEma

    h := gQ.GetHealth()
    ToolTip "GOLD_Input_DualLane"
        . "`nLane: " gLane " (lastSrc=" gLastSrc ")"
        . "`nEMA: x=" Round(gEma.X(), 2) " y=" Round(gEma.Y(), 2)
        . "`nQ: fill=" h["fill"] "/" h["cap"] " drops=" h["drops"]
        . "`nSamples: " gSamples
        . "`nCtrl+Alt+R = toggle lane"
}

ToggleLane(*) {
    global gLane
    if (gLane = "timer")
        StartRawLane()
    else
        StartTimerLane()
}

; --- Init ---
gInp := DemonInput(OnSample)
StartTimerLane()

SetTimer(Drain, 8)
SetTimer(Show, 100)

Hotkey("^!r", ToggleLane)
Hotkey("Esc", (*) => ExitApp())

OnExit((*) => ShutdownAll())
return

ShutdownAll() {
    global gInp
    try SetTimer(Drain, 0)
    try SetTimer(Show, 0)
    try ToolTip()
    try gInp.Stop()
}
