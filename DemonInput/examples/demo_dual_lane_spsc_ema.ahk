#Requires AutoHotkey v2.0
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk
#Include ..\src\DemonInput.ahk

q := DemonSpscRing(2048)
ema := DemonEma(25, 0.12)
ema.Reset(0, 0)

lane := "timer"

OnSample(dx, dy, tMs, source) {
    global q
    ; Push into SPSC. Drop is fine; health can be queried from q.
    q.Push(dx, dy, tMs)
}

inp := DemonInput(OnSample)

StartTimerLane() {
    global inp, lane
    inp.Stop()
    inp.StartTimerLane(4)
    lane := "timer"
}

StartRawLane() {
    global inp, lane
    inp.Stop()
    inp.StartRawInputLane(A_ScriptHwnd, true, true)
    lane := "raw"
}

StartTimerLane()

SetTimer(Drain, 8)
SetTimer(UpdateTip, 100)

Drain() {
    global q, ema
    while q.Pop(&dx, &dy, &tMs) {
        ema.UpdateSample(dx, dy, tMs)
    }
}

UpdateTip() {
    global ema, lane
    ToolTip "lane=" lane "  emaX=" Round(ema.X(), 2) "  emaY=" Round(ema.Y(), 2)
}

; Toggle lane
F1::(lane = "timer" ? StartRawLane() : StartTimerLane())

; Stop all
F2::(inp.Stop(), ToolTip "stopped")

Esc::ExitApp
