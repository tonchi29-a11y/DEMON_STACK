#Requires AutoHotkey v2.0
#Include ..\..\DemonInput\src\DemonInput.ahk
#Include ..\..\DemonSPSC\src\DemonSpscRing.ahk
#Include ..\..\DemonEMA\src\DemonEma.ahk
#Include ..\..\DemonContextDetect\src\DemonContextDetect.ahk
#Include ..\src\DemonPredict.ahk

q := DemonSpscRing(2048)
ema := DemonEma(25, 0.12)
ctx := DemonContextDetect(Map("HoldMs", 120))
pred := DemonPredict()

OnSample(dx, dy, tMs, source) {
    global q
    q.Push(dx, dy, tMs)
}

inp := DemonInput(OnSample)
inp.StartTimerLane(4)

SetTimer(Drain, 8)
SetTimer(Show, 100)

Drain(*) {
    global q, ema, ctx
    while q.Pop(&dx, &dy, &tMs) {
        ema.UpdateSample(dx, dy, tMs)
        ; ContextDetect uses raw deltas; dt fixed-ish for demo
        ctx.Update(dx, dy, 4, tMs)
    }
}

Show(*) {
    global ctx, pred
    st := ctx.GetState()
    r := pred.Update(
        st["context"],
        st["confidence"],
        st["vel"],
        st["avgSpeed"],
        st["hvRatio"],
        st["spike"],
        false,
        8,
        A_TickCount
    )

    ToolTip "DemonPredict live"
        . "`nctx=" st["context"] " conf=" Round(st["confidence"], 2)
        . "`nadsProb=" Round(r["adsProb"], 2) " desired=" r["desired"]
        . "`nreason=" r["reason"] " cdLeft=" r["cooldownLeftMs"]
}

Esc::ExitApp
OnExit((*) => inp.Stop())
