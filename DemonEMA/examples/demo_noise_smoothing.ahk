#Requires AutoHotkey v2.0
#Include ..\src\DemonEma.ahk

ema := DemonEma(25, 0.12)
ema.Reset()

t0 := A_TickCount
Loop 200 {
    ; noisy signal around 0
    dx := Random(-30, 30)
    dt := 4
    ema.Update(dx, 0, dt)
}
MsgBox "Noise smoothing demo`nFinal X=" Round(ema.X(), 4)
