#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk
#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\src\DemonContextDetect.ahk

; Demo: DemonInput -> SPSC -> EMA -> ContextDetect -> ToolTip
; Default lane: timer (no RawAccel). Press Esc to exit.

q := DemonSpscRing(2048)
ema := DemonEma(25, 0.12)
ema.Reset(0, 0)
ctx := DemonContextDetect()

OnSample(dx, dy, tMs, source) {
    global q
    q.Push(dx, dy, tMs)
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4)

SetTimer(Drain, 8)
SetTimer(UpdateTip, 100)

Drain() {
    global q, ema
    while q.Pop(&dx, &dy, &tMs) {
        ema.UpdateSample(dx, dy, tMs)
    }
}

UpdateTip() {
    global ema, ctx
    ; Note: ctx.Update clamps dt and uses nowMs for HoldMs.
    r := ctx.Update(ema.X(), ema.Y(), 4, A_TickCount)

    ToolTip(
        "context=" r["context"] "  conf=" Round(r["confidence"], 2)
        . "`nvel=" Round(r["vel"], 4) "  avg=" Round(r["avgSpeed"], 4)
        . "`nhvRatio=" Round(r["hvRatio"], 2) "  spike=" Round(r["spike"], 2)
        . "`nholdLeftMs=" r["holdLeftMs"]
    )
}

Esc::
{
    inp.Stop()
    ToolTip()
    ExitApp
}
